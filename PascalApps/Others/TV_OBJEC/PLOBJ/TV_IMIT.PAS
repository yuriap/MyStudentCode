Program TV_Imit;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,StdDlg,HistList,
     ImitCont,PlColl2,Imit,
     HelpFile, ColorSel,Dos,Crt ;
     {MyButton,Line, Scroll;}
Const
      cmInput = 1000;
      cmMainParam = 1001;
      cmGraphica = 1002;
      cmStart = 1003;
      cmPrint = 1004;
      cmHelper = 1005;
      cmInfo = 1006;
      cmViewer = 1007;
      cmUseProgHelp = 1008;
      cmSomeSing = 1009;
      cmHelp=1010;
      cmGraphParam=1011;
      IsHelp : boolean = false;
      CurrentPalette:PathStr='';
Type
    PMyApp = ^TMyApp;
    TMyApp = object(TApplication)
           constructor init;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           Procedure HandleEvent(var Event:TEvent);virtual;
           procedure MainParam;
           procedure GraphParam;
           procedure RunProgram;
           procedure Viewer;
           function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;
           procedure OpenFile;
           end;
      PMyDialog = ^TMyDialog;
      TMyDialog = object(TDialog)
        end;

constructor TMyApp.Init;
begin

     TApplication.Init;
     RegisterHelpFile;
     With DataPlate do begin
     count := '4';
     preserve := '10';
     alfa := '30';
     dtime := '0.1';
     end;
     with DataGraph do begin
     MasX:='100';
     MasY:='100';
     DeltaX:='200';
     DeltaY:='250';
     end;
end;
Procedure TMyApp.InitStatusLine;
Var R : TRect;
Begin
     GetExtent(R);
     R.A.Y:=R.B.Y-1;
     StatusLine:=New(PHintStatusLine,Init(R,
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
    NewSubMenu(' И~c~ходные данные  ',hcOne,NewMenu(
     NewItem(' Фaйл... ','',0,cmInput,hcOne,
     NewItem(' Ввод основных параметров... ','',0,cmMainParam,hcTwo,
     NewItem(' Параметры графики... ','',0,cmGraphParam,hcThree,
     NewLine(
     NewItem('Инф~o~рмация','',0,cmInfo,hcInfo,nil)))))),
    NewSubMenu('  ~P~асчет  ',hcRaschet,NewMenu(
     NewItem('~B~ыполнение ','',0,cmStart,hcStart,nil)),
    NewSubMenu('  Рез~y~льтат  ',hcRezult,NewMenu(
     NewItem('Пр~o~смотр','',0,cmViewer,hcViewer,
     NewItem('Гр~a~фический просмотр','',0,cmGraphica,hcGraphica,
     NewItem('П~e~чать','',0,cmPrint,hcPrint,nil)))),
    NewSubMenu('  Спр~a~вка  ',hcSpravca,NewMenu(
     NewItem('Исп~o~льзование программы','',0,cmUseProgHelp,hcUseProgHelp,
     NewItem('~P~азное','',0,cmSomeSing,hcSomeSing,nil))),
     nil)))))));
End;
Procedure TMyApp.MainParam;
Var
   MyDialog : PMyDialog;
   CheckRadio : PView;
   Button : PButton;
   R:TRect;
   Control:Word;
Begin
   R.Assign(10,3,70,18);
   MyDialog:=New(PMyDialog,Init(R,'Окно ввода данных'));
   With MyDialog^ do
      begin
      HelpCtx:=hcThree;

      R.Assign(40,3,55,4);
      CheckRadio:=New(PInputLine,Init(R,10));
      Insert(CheckRadio);
      R.Assign(3,3,39,4);
      Insert(New(PLabel,Init(R,'Колличество участков разбиения',CheckRadio)));

      R.Assign(40,5,55,6);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcOne;
      Insert(CheckRadio);
      R.Assign(3,5,39,6);
      Insert(New(PLabel,Init(R,'Кол-во сохраняемых свободных вихрей',CheckRadio)));

      R.Assign(40,7,55,8);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcTwo;
      Insert(CheckRadio);
      R.Assign(3,7,39,8);
      Insert(New(PLabel,Init(R,'Угол установки пластины [грд]',CheckRadio)));

      R.Assign(40,9,55,10);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcTwo;
      Insert(CheckRadio);
      R.Assign(3,9,39,10);
      Insert(New(PLabel,Init(R,'Безразмерный шаг по времени',CheckRadio)));

      R.Assign(15,12,25,14);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(35,12,45,14);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);
      end;
   MyDialog^.SetData(DataPlate);
   Control:=DeskTop^.ExecView(MyDialog);
   If Control <> cmCancel Then MyDialog^.GetData(DataPlate);
end;
procedure TMyApp.GraphParam;
Var
   MyDialog : PMyDialog;
   CheckRadio : PView;
   Button : PButton;
   R:TRect;
   Control:Word;
Begin
   R.Assign(10,3,70,18);
   MyDialog:=New(PMyDialog,Init(R,'Окно ввода данных'));
   With MyDialog^ do
      begin
      HelpCtx:=hcThree;

      R.Assign(40,3,55,4);
      CheckRadio:=New(PInputLine,Init(R,10));
      Insert(CheckRadio);
      R.Assign(3,3,39,4);
      Insert(New(PLabel,Init(R,'Масштаб по горизонтали',CheckRadio)));

      R.Assign(40,5,55,6);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcOne;
      Insert(CheckRadio);
      R.Assign(3,5,39,6);
      Insert(New(PLabel,Init(R,'Масштаб по вертикали',CheckRadio)));

      R.Assign(40,7,55,8);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcTwo;
      Insert(CheckRadio);
      R.Assign(3,7,39,8);
      Insert(New(PLabel,Init(R,'Смещение т.(0,0) по горизонтали',CheckRadio)));

      R.Assign(40,9,55,10);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcTwo;
      Insert(CheckRadio);
      R.Assign(3,9,39,10);
      Insert(New(PLabel,Init(R,'Смещение т.(0,0) по вертикали',CheckRadio)));

      R.Assign(15,12,25,14);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(35,12,45,14);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);
      end;
   MyDialog^.SetData(DataGraph);
   Control:=DeskTop^.ExecView(MyDialog);
   If Control <> cmCancel Then MyDialog^.GetData(DataGraph);
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

{  Message(Desktop, evBroadcast, cmEditor, nil);}
end;

Procedure TMyApp.HandleEvent(var Event:TEvent);
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of

      cmMainParam : MainParam;
      cmStart  : RunProgram;
{      cmViewer : Viewer;}
      cmGraphParam : GraphParam;
      cmInput : OpenFile;
      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
procedure TMyApp.RunProgram;
Var
   Plate : PPlate;
begin
   Plate :=New(PPlate,Init);
   Plate^.Draw;
   ShowMouse;readkey;
   Dispose(Plate,Done);
  DoneMemory;
  Redraw;
  ShowMouse;

end;
procedure TMyApp.Viewer;
Var
   MyDialog : PMyDialog;
   R : TRect;
   Control : word;
   St: PStaticText;
begin
   R.Assign(15,4,65,20);
   MyDialog:=New(PMyDialog,Init(R,'Окно вывода данных'));
   With MyDialog^ do begin
      R.Assign(5,3,45,10);
      HelpCtx:=hcOne;
      St:=New(PStaticText,Init(R,^C'Для исходных данных:'
     { +^M^C'Напора = '+APumpData.H
      +^M^C'Подачи = '+APumpData.Q
      +^M^C'Оборотов = '+APumpData.n
      +^M^C''
      +^M^C'Быстроходность'
      +^M^C'Ns = '+APumpData.Ns}));

      St^.Options:=St^.Options or ofFramed;
      Insert(st);
      R.Assign(20,13,30,15);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      end;
      Control:=DeskTop^.ExecView(MyDialog);
end;
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
