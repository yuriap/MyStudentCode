Program TV_Imit;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,StdDlg,HistList,
     HelpFile, ColorSel,Dos,Crt,Graph ;
Const
      cmInput = 1000;
      cmMakeString = 1002;
      cmPrint = 1004;
      cmViewer = 1005;
      cmUseProgHelp = 1008;
      cmSomeSing = 1009;
      cmHelp=1010;
      cmInfo = 1011;
      cmEdit = 1003;
      cmDelete = 1006;
      cmNew = 1007;
      CurrentPalette:PathStr='';
var
 Driver, Mode: Integer;
procedure InitGraphMode;
begin
 Driver := Detect;   { Put in graphics mode }
 InitGraph(Driver, Mode, ' ');
 if GraphResult <> grOk then
   Halt(1);
end;
Type
  PDlg = ^TDlg;
  TDlg = object(TDialog)
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure Edit;
    end;
procedure TDlg.HandleEvent(var Event:TEvent);
Begin
  inherited HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
      cmEdit:Edit;
      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
procedure TDlg.Edit;
var
  Dlg:PDlg;
  R:TRect;
  S:PView;
begin
   R.Assign(10,3,70,21);
   Dlg:=New(PDlg,Init(R,'РЕДАКТОР СТРОКИ'));
   With Dlg^ do
    begin
    R.Assign(3,3,33,4);
    S:=New(PInputLine,Init(R,60));
    Insert(S);
      R.Assign(3,2,11,3);
      Insert(New(PLabel,Init(R,'Строка',S)));

      R.Assign(3,6,20,11);
      S:=New(PRadioButtons,Init(R,
               NewSItem('DefaultFont',
               NewSItem('TriplexFont',
               NewSItem('SmallFont',
               NewSItem('SansSerifFont',
               NewSItem('GothicFont',
               nil)))))));
      Insert(S);
      R.Assign(3,5,20,6);
      Insert(New(PLabel,Init(R,'Шрифты',S)));

      R.Assign(3,13,20,15);
      S:=New(PRadioButtons,Init(R,
               NewSItem('HorizDir',
               NewSItem('VertDir',nil))));
      Insert(S);
      R.Assign(3,12,20,13);
      Insert(New(PLabel,Init(R,'Расположение',S)));



      end;
   Dlg^.SetData(DData);
   Control:=DeskTop^.ExecView(Dlg);
   If Control <> cmCancel Then Dlg^.GetData(DData);

end;

type
  PUnit = ^TUnit;
  TUnit = object(TObject)
    Str:String[60];
    Location:TPoint;
    Font:Word;
    Size:byte;
    Dir:Byte;
    constructor Init(NewStr:string;NewLoc:TPoint;NewFont:word;NewSize:Byte);
    end;
constructor TUnit.Init(NewStr:string;NewLoc:TPoint;NewFont:Word;NewSize:Byte);
begin
  Str:=NewStr;
  Location:=NewLoc;
  Font:=NewFont;
  Size:=NewSize;
end;
Type
  PDrawColl = ^TDrawColl;
  TDrawColl = object(TCollection)
    constructor Init;
    procedure Draw;
    end;
constructor TDrawColl.Init;
var
 Loc:TPoint;
begin
  inherited Init(10,10);
  Loc.X:=100;Loc.Y:=100;
  Insert(New(PUnit,Init('WHAT IS IT ?',Loc,TriplexFont,3)));
end;
procedure TDrawColl.Draw;
 procedure DrawAll(S:PUnit);far;
 begin
  SetTextStyle(S^.Font,HorizDir,S^.Size);
  OutTextXY(S^.Location.X,S^.Location.Y,S^.Str);
 end;
begin
   InitGraphMode;
   ForEach(@DrawAll);
   readkey;
   CloseGraph;
end;
Var DrawColl:PDrawColl;
Type
  PCityColl = ^TCityColl;
  TCityColl = object(TStringCollection)
    constructor Init;
  end;
var CityColl : PCityColl;
type
    PMyApp = ^TMyApp;
    TMyApp = object(TApplication)
           constructor init;
           destructor Done;virtual;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           Procedure HandleEvent(var Event:TEvent);virtual;
           procedure MakeString;
           procedure Viewer;
           function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;
           procedure OpenFile;
           end;
constructor TCityColl.Init;
var
  Loc:TPoint;
begin
  inherited Init(10, 10);
  Insert(NewStr('What is it ?'));
end;


constructor TMyApp.Init;
begin
     TApplication.Init;
     RegisterHelpFile;
     CityColl:=New(PCityColl,Init);
     DRawColl:=New(PDrawColl,Init);

end;
destructor TMyApp.Done;
begin
  inherited Done;
end;
Procedure TMyApp.InitStatusLine;
Var R : TRect;
Begin
     GetExtent(R);
     R.A.Y:=R.B.Y-1;
     StatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FFFF,
      NewStatusKey('~F1~ Помощь ',kbF1,cmHelp,
        NewStatusKey('~Alt-X~ Выход',kbAltX,cmQuit,
          NewStatusKey('~F10~ Меню',kbF10,cmMenu,
        nil))),nil)));
End;
Procedure TMyApp.InitMenuBar;
Var R : TRect;
Begin
  GetExtent(R);
  R.B.Y:=R.A.Y+1;
  MenuBar:=New(PMenuBar,Init(R,NewMenu(
    NewSubMenu(' И~c~ходные данные  ',hcNoContext,NewMenu(
     NewItem(' Фaйл... ','',0,cmInput,hcNoContext,
     NewItem(' Редактор... ','',0,cmMakeString,hcNoContext,
     NewLine(
     NewItem('Инф~o~рмация','',0,cmInfo,hcNoContext,nil))))),
    NewSubMenu('  Рез~y~льтат  ',hcNoContext,NewMenu(
     NewItem('Пр~o~смотр','',0,cmViewer,hcNoContext,
     NewItem('П~e~чать','',0,cmPrint,hcNoContext,nil))),
    NewSubMenu('  Спр~a~вка  ',hcNoContext,NewMenu(
     NewItem('Исп~o~льзование программы','',0,cmUseProgHelp,hcNoContext,
     NewItem('~P~азное','',0,cmSomeSing,hcNoContext,nil))),
     nil))))));
End;
Procedure TMyApp.MakeString;
Var
   Dlg : PDlg;
   Control : PView;
   ScrollBar:PScrollBar;
   R:TRect;

Begin
   R.Assign(10,3,70,18);
   Dlg:=New(PDlg,Init(R,'РЕДАКТОР СТРОК'));
   With Dlg^ do
    begin
      R.Assign(40, 3, 41, 12);
      New(ScrollBar, Init(R));
      Insert(ScrollBar);
      R.Assign(3, 3, 40, 12);
      Control := New(PListBox, Init(R, 1, ScrollBar));
      Insert(Control);
      PListBox(Control)^.NewList(CityColl);
      R.Assign(2, 2, 12, 3);
      Insert(New(PLabel, Init(R, 'СТРОКИ:', Control)));
{****************************************************************}
      R.Assign(45, 3, 55, 5);
      Insert(New(PButton, Init(R, '~O~k', cmOk, bfNormal)));
      R.Assign(45,5,55,7);
      Insert(New(PButton, Init(R, '~E~dit', cmEdit, bfDefault)));
      R.Assign(45,7,55,9);
      Insert(New(PButton, Init(R, '~N~ew', cmNew, bfNormal)));
      R.Assign(45,9,55,11);
      Insert(New(PButton, Init(R, '~D~elete', cmDelete, bfNormal)));
      R.Assign(45,11,55,13);
      Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

    end;
   DeskTop^.ExecView(Dlg);
end;

procedure TMyApp.OpenFile;
var
  S: TBufStream;
  Desc: String;
  D: PFileDialog;
  C: Word;
begin
  D := New(PFileDialog, Init('*.PAS', 'Open Palette', '~N~ame',
    fdOKButton, 100));
  if Desktop^.ExecView(D) <> cmCancel then
    D^.GetFileName(CurrentPalette);
  Dispose(D, Done);

end;
procedure TMyApp.Viewer;
begin
   DrawColl^.Draw;
   DoneMemory;
   Redraw;
end;
Procedure TMyApp.HandleEvent(var Event:TEvent);
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
      cmMakeString : MakeString;
      cmViewer:Viewer;
      cmInput : OpenFile;
      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
Function TMyApp.GetPalette;
Const MyColor : TPalette =CAppColor+CHelpColor;
begin
 GetPalette:=@MyColor;
end;
procedure TMyApp.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
const
  HelpInUse: Boolean = False;
begin
  inherited GetEvent(Event);
  case Event.What of
    evCommand:
      if (Event.Command = cmHelp) and not HelpInUse then
      begin
        HelpInUse := True;
        HelpStrm := New(PDosStream, Init('imit.hlp', stOpenRead));
        HFile := New(PHelpFile, Init(HelpStrm));
        if HelpStrm^.Status <> stOk then
        begin
          MessageBox('Could not open help file.', nil, mfError + mfOkButton);
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


Var
   MyApp : PMyApp;
begin
     MyApp:=New(PMyApp,Init);
     MyApp^.Run;
     Dispose(MyApp,Done);
end.
