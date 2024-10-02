Program Viewer;
Uses app,objects,menus,HelpFile,Views,Drivers,MsgBox,StdDlg,Dos;
Const
      cmHelp=1010;
      IsHelp : boolean = false;
      IniFile='viewer.ini';
      SelfHelpFile='viewers.stf';
      IsSelfHelp:boolean=false;
      cmOpenFile = 1000;
      cmExit = 1001;
      cmViewHelp = 1002;
      cmReplaseBook = 201;
Type
    PMyApp = ^TMyApp;
    TMyApp = object(TApplication)
           constructor init;
           procedure initStatusLine;virtual;
           procedure initmenubar;virtual;
           function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;
           procedure HandleEvent(var Event:TEvent);virtual;
           function GetHelpCtx:word;virtual;
           procedure OpenFile;
           procedure WriteIniFile(AIniFile:string);
           procedure ReadIniFile(AIniFile:string);
           procedure ViewHelp;
           destructor Done;virtual;
           end;

var
   SaveCurrentFile:string;
   SaveCurrentTopic:word;
constructor TMyApp.Init;
var
   Event:TEvent;
   N: NameStr;
   E: ExtStr;
begin
     TApplication.Init;
     RegisterHelpFile;
     CurrentTopic:=0;
     ReadIniFile(IniFile);
     Event.What:=evCommand;
     Event.Command:=cmHelp;
     PutEvent(Event);
     DisableCommands([cmReplaseBook]);
end;
destructor TMyApp.Done;
begin
  WriteIniFile(IniFile);
  inherited Done;
end;
procedure TMyApp.InitMenuBar;
var
  R: TRect;
  P: PView;
  SubMenu:PMenuItem;
begin
  R.Assign(0, 0, 80, 1);
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('Ф~a~йл', hcNoContext, NewMenu(
      NewItem('~O~ткрыть', 'F3', kbF3, cmOpenFile, hcNoContext,
      NewItem('О п~p~ограмме','F7',kbF7,cmViewHelp,hcNoContext,
      NewItem('~B~ернуться в книгу','F4',kbF4,cmReplaseBook,hcNoContext,
      NewLine(
      NewItem('Выход', '', kbAltX, cmQuit, hcNoContext, nil)))))),
      nil))));
end;
Procedure TMyApp.InitStatusLine;
Var R : TRect;
Begin
     GetExtent(R);
     R.A.Y:=R.B.Y-1;
     StatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FFFF,
      NewStatusKey('~F1~ Вернуться в книгу ',kbF1,cmHelp,
        NewStatusKey('~Esc, Alt-X~ Выход',kbAltX,cmQuit,
          NewStatusKey(' ~Tab~ Перемещение по книге',kbF5,cmZoom,
            NewStatusKey('~F10~ Меню',kbF10,cmMenu,
        nil)))),nil)));
End;

Function TMyApp.GetPalette;
Const MyColor : TPalette =CAppColor+CHelpColor;
begin
 GetPalette:=@MyColor;
end;
function TMyApp.GetHelpCtx:word;
begin
 GetHelpCtx:=CurrentTopic;
end;
procedure TMyApp.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
  E:TEvent;
const
  HelpInUse: Boolean = False;
begin
  inherited GetEvent(Event);
  case Event.What of
    evCommand:
      if (Event.Command = cmHelp) and not HelpInUse then
      begin
        HelpInUse := True;
        HelpStrm := New(PDosStream, Init(HelpFileName, stOpenRead));
        HFile := New(PHelpFile, Init(HelpStrm));
        if HelpStrm^.Status <> stOk then
        begin
          MessageBox('Невозможно открыть файл: '+HelpFileName,
            nil, mfError + mfOkButton);
          Dispose(HFile, Done);
        end
        else
        begin
          W := New(PHelpWindow,Init(HFile, GetHelpCtx));
          if ValidView(W) <> nil then
          begin
            ExecView(W);
            Dispose(W, Done);
          end;
          ClearEvent(Event);
        end;
        HelpInUse := False;
      end;
    evMouseDown:
      if Event.Buttons <> 1 then Event.What := evNothing;
  end;
end;
procedure TMyApp.HandleEvent;
begin
  Inherited HandleEvent(Event);
  if Event.What = evCommand then
   begin
    case Event.Command of
    cmOpenFile : OpenFile;
    cmViewHelp : ViewHelp;
    cmReplaseBook : ViewHelp;
    else
     Exit;
    end;
    ClearEvent(Event);
   end;
end;
procedure TMyApp.OpenFile;
var FD:PFileDialog;
    HFN:string;
const FDO:word=fdOkButton+fdOpenButton;
begin
  Hfn:='*.stf';
  FD:=New(PFileDialog,Init(Hfn,'Открыть файл с книгой','Файл книги',FDO,0));
  if ExecuteDialog(FD,@hfn) <> cmCancel then
   begin
   HelpFileName:=hfn;
   CurrentTopic:=0;
   end;
end;
procedure TMyApp.WriteIniFile(AIniFile:string);
var F:text;
begin
  Assign(F,AIniFile);
  ReWrite(F);
  if IsSelfHelp then
   begin
   HelpFileName:=SaveCurrentFile;
   CurrentTopic:=SaveCurrentTopic;
   end;
  Writeln(F,HelpFileName);
  Writeln(F,CurrentTopic);
  Close(F);
end;
procedure TMyApp.ReadIniFile(AIniFile:string);
var F:text;
begin
  Assign(F,AIniFile);
  Reset(F);
  Readln(F,HelpFileName);
  Readln(F,CurrentTopic);
  Close(F);
end;
procedure TMyApp.ViewHelp;
var Event:TEvent;
begin
  if not(IsSelfHelp) then
   begin
   EnableCommands([cmReplaseBook]);
   SaveCurrentFile:=HelpFileName;
   SaveCurrentTopic:=CurrentTopic;
   HelpFileName:=SelfHelpFile;
   CurrentTopic:=0;
   end
   else
   begin
   HelpFileName:=SaveCurrentFile;
   CurrentTopic:=SaveCurrentTopic;
   DisableCommands([cmReplaseBook]);
   end;
  IsSelfHelp:=not(IsSelfHelp);
  Event.What:=evCommand;
  Event.Command:=cmHelp;
  PutEvent(Event);
end;

Var
   MyApp : PMyApp;
   F:text;
begin
     Assign(F,IniFile);
     Reset(F);
     Readln(F,HelpFileName);
     Close(F);
     MyApp:=New(PMyApp,Init);
     MyApp^.Run;
     Dispose(MyApp,Done);
end.
