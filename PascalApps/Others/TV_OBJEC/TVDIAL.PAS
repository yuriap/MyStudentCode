program mObject1;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,StdDlg,MyContext,
     MyButton,Line, Scroll;
Const cmNewWin = 199;
      cmFileOpen = 200;
      cmDialog = 201;
      cmInfo = 1000;
      cmInput = 1001;
      cmNewDialog = 1002;
      cmFirst = 1003;
      cmFileInput = 1004;
      WinCount: integer = 0;

Var
      Ev :TEvent;

Type
    PMyApp = ^TMyApp;
    TMyApp = object(TApplication)
           constructor init;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           procedure NewWindow;
           procedure HandleEvent(var Event : TEvent);virtual;
           Procedure Info;
           Procedure Dialog;
           procedure Input;
           Procedure NewDialog;
           procedure FileInput;
           destructor Done;virtual;
           end;

      PMyDialog = ^TMyDialog;
      TMyDialog = object(TDialog)
        procedure HandleEvent(var Event : TEvent);virtual;
        procedure DialogInfo;
        end;

      PFileInput = ^TFileInput;
      TFileInput = object(TFileInputLine)
      constructor Init(  Bounds : TRect;AMaxLen:integer);
          end;
Constructor TFileInput.Init(  Bounds : TRect;AMaxLen:integer);
begin
   inherited Init(Bounds,AMaxLen);
end;
Procedure TMyApp.FileInput;
Var
   R:TRect;
   FileWindow : PFileInput;
begin
 R.Assign(20,5,30,15);
 FileWindow:=New(PFileInput,Init(R,10));
 Insert(FileWindow);
end;
constructor TMyApp.Init;
begin
     TApplication.Init;
     With DData do begin
       CheckBoxData :=0;
       RadioButtonsData :=0;
       InputLineData :='scroll.pas';
       ReadFile;
       end;
End;

Procedure TMyApp.InitStatusLine;
Var R : TRect;
Begin
     GetExtent(R);
     R.A.Y:=R.B.Y-1;
     StatusLine:=New(PHintStatusLine,Init(R,
      NewStatusDef(0,$FFFF,
       NewStatusKey('~Alt-X~ Выход',kbAltX,cmQuit,
         NewStatusKey('~F4~ Новый ',kbF4,cmNewWin,
          NewStatusKey('~F10~ Меню',kbF10,cmMenu,
        nil))),nil)));
End;
Procedure TMyApp.InitMenuBar;
Var R : TRect;
Begin
  GetExtent(R);
  R.B.Y:=R.A.Y+1;
  MenuBar:=New(PMenuBar,Init(R,NewMenu(
    NewSubMenu('~F~ile',hcFile,NewMenu(
     NewItem('~O~pen','F3',kbF3,cmFileInput,hcOpen,
     NewItem('~N~ew','F4',kbF4,cmNewWin,hcNewWin,
     NewItem('~S~ave','F2',kbF2,cmSave,hcNoContext,
     NewLine(
     NewItem('~A~bout','',0,cmInfo,hcNoContext,
     NewItem('E~x~it','Alt-X',kbAltX,cmQuit,hcNoContext,nil))))))),
    NewSubMenu('~W~indow',hcNoContext,NewMenu(
     NewItem('~N~ext','F6',kbF6,cmNext,hcNoContext,
     NewItem('~Z~oom','F5',kbF5,cmZoom,hcNoContext,
     NewItem('~S~ize/move ','Ctrl-F5',kbCtrlF5,cmResize,hcNoContext,
     NewItem('~C~lose','Alt-F3',kbAltF3,cmClose,hcClose,nil ))))),
    NewSubMenu('~S~omeSing',hcNoContext,NewMenu(
     NewItem('~D~ialog Box Primitive','',0,cmDialog,hcNoContext,
     NewItem('~I~nput Dialog Box','',0,cmInput,hcNoContext,
     NewItem('~N~ew Dialog Box','',0,cmNewDialog,hcNoContext,nil)))),
    NewSubMenu('FileSt~a~ndart',hcNoContext,NewMenu(
    StdFileMenuItems(nil)),nil)))))));

End;
Procedure TMyApp.NewWindow;
Var
   Window : PDemoWindow;
   R : TRect;
begin
  Inc(WinCount);
  R.Assign(0,0,30,10);
  R.Move(WinCount-1,WinCount-1);
  Window:=New(PDemoWindow,Init(R,'Окно',WinCount));
  Window^.HelpCtx := hcWindow;
  DeskTop^.Insert(Window);
End;
Procedure TMyApp.Info;
    begin
      MessageBox(#3'Это Turbo Vision'#13#3'Статический текст',
      nil,mfInformation or mfOkButton);
    end;
procedure TMyApp.Input;
Var R : TRect;
    ReturnVal: Word;
begin
  ReturnVal := ExecuteDialog(New(PLineDialog,Init),nil);
end;

Procedure TMyApp.Dialog;
var
  ReturnVal: Word;
  TheCommand: PString;
  R :TRect;
const
  CommandName: array[cmOK..cmNo] of string[8] =
    ('cmOK', 'cmCancel', 'cmYes', 'cmNo');

    begin
      ReturnVal := ExecuteDialog(New(PButtonDialog, Init),nil);
      TheCommand := @CommandName[ReturnVal];
      MessageBox(#3'Modal state ended'#13#3'with command %s.',
         @TheCommand, mfInformation or mfOKButton);
      TheCommand := @CommandName[ReturnVal];
end;
Procedure TMyApp.NewDialog;
Var
   MyDialog : PMyDialog;
   CheckRadio : PView;
   R:TRect;
   Control:Word;
Begin
   R.Assign(20,6,60,19);
   MyDialog:=New(PMyDialog,Init(R,'Диалоговое окно'));
   With MyDialog^ do
      begin

      R.Assign(15,10,25,12);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(28,10,38,12);
      Insert(New(PButton,Init(R,'~H~elp',cmFirst,bfNormal)));
      R.Assign(3,3,18,6);
      CheckRadio:=New(PCheckBoxes,Init(R,
               NewSItem('~F~irst',
               NewSItem('~S~econd',
               NewSItem('~T~hird',
               nil)))));
      Insert(CheckRadio);
      R.Assign(3,2,11,3);
      Insert(New(PLabel,Init(R,'~N~umber',CheckRadio)));
      R.Assign(21,3,37,6);
      CheckRadio:=New(PRadioButtons,Init(R,
               NewSItem('~R~ed',
               NewSItem('~G~reen',
               NewSItem('~B~lue',
               nil)))));
      Insert(CheckRadio);
      R.Assign(21,2,33,3);
      Insert(New(PLabel,Init(R,'~C~olor',CheckRadio)));
      R.Assign(3,8,37,9);
      CheckRadio:=New(PInputLine,Init(R,128));
      Insert(CheckRadio);
      R.Assign(2,7,24,8);
      Insert(New(PLabel,Init(R,'~I~nstruction',CheckRadio)));
      end;
   MyDialog^.SetData(DData);
   Control:=DeskTop^.ExecView(MyDialog);
   If Control <> cmCancel Then MyDialog^.GetData(DData);
end;
procedure TMyDialog.DialogInfo;
begin
      MessageBox(#3'Это Turbo Vision'#13#3'Кнопка Help',
      nil,mfInformation or mfOkButton);
    end;

procedure TMyDialog.HandleEvent(var Event:TEvent);
begin
   inherited HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
         cmFirst : DialogInfo;
         else exit;
         end;
    ClearEvent(Event);
    end;
end;
Procedure TMyApp.HandleEvent(var Event:TEvent);
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of

      cmNewWin : NewWindow;
      cmInfo : Info;
      cmDialog : Dialog;
      cmInput : Input;
      cmNewDialog : NewDialog;
      cmFileInput : FileInput;
      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
destructor TMyApp.Done;
begin
   DoneFile;
   inherited Done;
end;
Var
   MyApp : PMyApp;
begin
     MyApp:=New(PMyApp,Init);
     MyApp^.Run;
     Dispose(MyApp,Done);
end.
