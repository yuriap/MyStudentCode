Program TV_Imit;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,StdDlg,HistList,
     ImitCont,ImitExec,Imit,ImiVideo,
     HelpFile, ColorSel,Dos;
     {MyButton,Line, Scroll;}
Const
      cmInput = 1000;
      cmEditor = 1001;
      cmGraphica = 1002;
      cmStart = 1003;
      cmPrint = 1004;
      cmHelper = 1005;
      cmInfo = 1006;
      cmViewer = 1007;
      cmUseProgHelp = 1008;
      cmSomeSing = 1009;
      cmHelp=1010;
      IsHelp : boolean = false;
      CurrentPalette:PathStr='';
Var APumpData : TPumpData;

Type
    PMyApp = ^TMyApp;
    TMyApp = object(TApplication)
           V : TVideoObj;
           constructor init;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           Procedure HandleEvent(var Event:TEvent);virtual;
           procedure NewDialog;
           procedure RunProgram;
           procedure Viewer;
           function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;
           procedure ViewGraphica;
           procedure OpenFile;
           end;
      PMyDialog = ^TMyDialog;
      TMyDialog = object(TDialog)
        end;

constructor TMyApp.Init;
begin

     TApplication.Init;
     RegisterHelpFile;
     With APumpData do begin
     H := 'напор';
     Q := 'подача';
     n := 'обороты';
     Ns := 'ничего';
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
     NewItem(' Ф~a~йл ','',0,cmInput,hcOne,
     NewItem(' Р~e~дактирование данных... ','',0,cmEditor,hcTwo,
     NewItem(' Г~p~афический просмотр ','',0,cmGraphica,hcThree,
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
Procedure TMyApp.NewDialog;
Var
   MyDialog : PMyDialog;
   CheckRadio : PView;
   Button : PButton;
   R:TRect;
   Control:Word;
Begin
   R.Assign(20,6,60,19);
   MyDialog:=New(PMyDialog,Init(R,'Окно ввода данных'));
   With MyDialog^ do
      begin
      HelpCtx:=hcThree;
      R.Assign(3,5,37,6);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcOne;
      Insert(CheckRadio);
      R.Assign(2,4,24,5);
      Insert(New(PLabel,Init(R,'П~o~дача [м^3/сек]',CheckRadio)));

      R.Assign(3,7,37,8);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcTwo;
      Insert(CheckRadio);
      R.Assign(2,6,24,7);
      Insert(New(PLabel,Init(R,'Обо~p~оты [об/мин]',CheckRadio)));

      R.Assign(2,10,12,12);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(15,10,25,12);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      R.Assign(3,3,37,4);
      CheckRadio:=New(PInputLine,Init(R,10));
      Insert(CheckRadio);
      R.Assign(2,2,24,3);
      Insert(New(PLabel,Init(R,'~H~апор [м]',CheckRadio)));

      end;
   MyDialog^.SetData(APumpData);
   Control:=DeskTop^.ExecView(MyDialog);
   If Control <> cmCancel Then MyDialog^.GetData(APumpData);
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
  APumpData.H:=CurrentPalette

{  Message(Desktop, evBroadcast, cmEditor, nil);}
end;

Procedure TMyApp.HandleEvent(var Event:TEvent);
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of

      cmEditor : NewDialog;
      cmStart  : RunProgram;
      cmViewer : Viewer;
      cmGraphica : ViewGraphica;
      cmInput : OpenFile;
      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
procedure TMyApp.RunProgram;
Var
   Pump : PPump;
begin
   Pump :=New(PPump,Init(APumpData));
   Pump^.GetNs(APumpData);
   MessageBox(#3'Вычисления завершены',nil,mfInformation or mfOkButton);
   Dispose(Pump);
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
      +^M^C'Напора = '+APumpData.H
      +^M^C'Подачи = '+APumpData.Q
      +^M^C'Оборотов = '+APumpData.n
      +^M^C''
      +^M^C'Быстроходность'
      +^M^C'Ns = '+APumpData.Ns));

      St^.Options:=St^.Options or ofFramed;
      Insert(st);
      R.Assign(20,13,30,15);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      end;
      Control:=DeskTop^.ExecView(MyDialog);
end;
procedure TMyApp.ViewGraphica;

begin
  InitGVideo;
  DoneMemory;
  Redraw;
  ShowMouse;
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
