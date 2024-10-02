Program TV_Imit;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,StdDlg,HistList,
     ImitCont,Plates,Imit,PlCommon,Point,Collect,Graph,SomeObj,
     HelpFile, Strm,ColorSel,StrmErr,Dos,Crt;
Const
      cmGraphica = 1000;
      cmHelp = 1001;
      cmCreate = 1002;
      cmExtract = 1003;
      cmSaveObj = 1004;
      cmDoneObj =1007;
      cmInput = 1005;
      cmGraphParam = 1006;
      cmViewer = 1008;
      cmClearAir = 1009;
      IsHelp : boolean = false;
      StreamFile:PathStr='';
var
      Plate : PPlate;
Type

    PMyApp = ^TMyApp;
    TMyApp = object(TApplication)
           constructor init;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           Procedure HandleEvent(var Event:TEvent);virtual;
           procedure MainParam;
           procedure GraphParam;
           procedure CreateObj;
           procedure DoneObj;
           procedure Viewer;
           procedure SaveObj;
           procedure Extract;
           procedure ClearAir;
           function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;
           procedure OpenFile;
           destructor Done;virtual;
           end;

     P1Dialog = ^T1Dialog;
     T1Dialog = object(TDialog)
{      procedure HandleEvent( var Event:TEvent);virtual;}
      end;
     PMyBufStream = ^TMyBufStream;
     TMyBufStream = object(TMsgStream)
        end;
constructor TMyApp.Init;
begin
     Writeln;
     Writeln(' Wind Machine Version 0.0 Copyright (c) 1995 Sumy State University');
     Delay(1000);
     With DataGraph do begin
      MasX := '100';
      MasY := '100';
      DeltaX := '300';
      DeltaY := '250';
      end;
     With DataPlate do begin
      count := '5';
      preserve := '10';
      alfa := '45';
      Dtime := '0.1';
      end;
     GraphInit;
     inherited Init;
     RegisterType(RPlate);
     RegisterType(RCollCon);
     RegisterType(RCollRot);
     RegisterType(RTearPoint);
     RegisterType(RConPoint);
     RegisterType(RRotAdd);
     RegisterType(RRotFree);
     RegisterHelpFile;
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
    NewSubMenu('Потоки ',hcRaschet,NewMenu(
     NewItem('Создать новый объект','',0,cmCreate,hcStart,
     NewItem('Уничтожить объект','',0,cmDoneObj,hcNoContext,
     NewItem('Записать объект в поток','',0,cmSaveObj,hcNoContext,
     NewItem('Извлечь объект из потока','',0,cmExtract,hcNoContext,
     NewItem('Удалить файл с профилем','',0,cmClearAir,hcNoContext,nil)))))),
    NewSubMenu('Просмотр',hcRezult,NewMenu(
     NewItem('Параметры графики','',0,cmGraphParam,hcNoContext,
     NewItem('Просмотр графического экрана ','',0,cmViewer,hcGraphica,
     nil))),nil)))));
End;
Procedure TMyApp.MainParam;
Var
   MyDialog : PDialog;
   CheckRadio: PView;
   Button : PButton;
   R:TRect;
   Cont:Word;
Begin
   R.Assign(10,3,70,18);
   MyDialog:=New(PDialog,Init(R,'Окно ввода данных'));
   With MyDialog^ do  begin

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
   Cont:=DeskTop^.ExecView(MyDialog);
   If Cont <> cmCancel Then MyDialog^.GetData(DataPlate);
end;
procedure TMyApp.GraphParam;
Var
   MyDialog : PDialog;
   CheckRadio : PView;
   Button : PButton;
   R:TRect;
   Control:Word;
Begin
   R.Assign(10,3,70,18);
   MyDialog:=New(PDialog,Init(R,'Окно ввода данных'));
   With MyDialog^ do
      begin
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
  D := New(PFileDialog, Init('*.air', 'Ввод файла с профилем', '~N~ame',
    fdOKButton, 100));
  if Desktop^.ExecView(D) <> cmCancel then
    D^.GetFileName(StreamFile);
  Dispose(D, Done);

end;

Procedure TMyApp.HandleEvent(var Event:TEvent);
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of

      cmGraphParam : GraphParam;
      cmExtract : Extract;
      cmCreate : CreateObj;
      cmDoneObj : DoneObj;
      cmViewer : Viewer;
      cmSaveObj : SaveObj;
      cmClearAir : ClearAir;
      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
procedure TMyApp.CreateObj;
begin
   If Plate <> nil then
     MessageBox(^C'Экземпляр объекта'
              +^M^C' TPlate уже существует',nil,mfInformation or mfOkButton)

     else begin
     MainParam;
     Plate :=New(PPlate,Init);
     MessageBox(^C'Создан экземпляр объекта'
              +^M^C' TPlate ',nil,mfInformation or mfOkButton);end

end;
procedure TMyApp.DoneObj;
var A : word;
begin
   If Plate^.Status = spNew then begin
   A:=MessageBox(^C'Не хотите ли вы сохранить объект ?'
               ,nil,mfInformation or mfYesButton or mfNoButton);
   Case A of
   cmNo : begin   If Plate <> nil then begin
                    Dispose(Plate,Done);
                    Plate:=nil;end;end;
   cmYes : begin SaveObj;
                 Dispose(Plate,Done);
                 Plate:=nil;end;
   end;
   end
   else     If Plate <> nil then begin
                    Dispose(Plate,Done);
                    Plate:=nil;end;

end;
procedure TMyApp.Viewer;
begin
   If Plate = nil then begin
     MessageBox(^C'Создайте экземпляр объекта'
              +^M^C' TPlate ',nil,mfInformation or mfOkButton);
   Exit;end;
   If not IsItGraph then begin
      MessageBox(^C'Ошибка графики.'
       +^M^C'Установите драйвер EGAVGA.BGI в текущий'
       +^M^C'каталог. Перезапустите систему.' ,nil,mfWarning or mfOkButton);
   Exit;end;
     SetGraphMode(grMode);
     Plate^.Draw;
     readkey;
     RestoreCrtMode;
     DoneMemory;
     Redraw;
end;


procedure TMyApp.SaveObj;
var
  S: TMyBufStream;
  D: PFileDialog;
begin
  If (Plate <> nil) then begin
  case Plate^.Status of
  spNew : begin
          D := New(PFileDialog, Init('*.air', 'Запись профиля в файл ',
           '~N~ame',fdOKButton, 100));
          if Desktop^.ExecView(D) <> cmCancel then
          D^.GetFileName(StreamFile);
          Dispose(D, Done);
          S.Init(StreamFile,stCreate,1024);
          S.Put(Plate);
          S.Done;
          end;
  spSaveDisk : MessageBox(^C'Копия объекта на диске'
              +^M^C' уже существует ',nil,mfInformation or mfOkButton);
  spReadDisk : MessageBox(^C'Копия объекта '
              +^M^C' считана с диска ',nil,mfInformation or mfOkButton);
  end;{case}
  end
  else  MessageBox(^C'Создайте экземпляр объекта'
              +^M^C' TPlate ',nil,mfInformation or mfOkButton);

end;
procedure TMyApp.Extract;
var
  S: TMyBufStream;
  D: PFileDialog;
  C: Word;
begin
  If Plate =  nil then begin
    D := New(PFileDialog, Init('*.air', 'Извлечение профиля из файла', '~N~ame',
      fdOKButton, 100));
    if Desktop^.ExecView(D) <> cmCancel then
      D^.GetFileName(StreamFile);
    Dispose(D, Done);
    S.Init(StreamFile,stOpen,1024);
    Plate:=PPlate(S.Get);
    S.Done;
  end
  else
     MessageBox(^C'Уничтожте экземпляр объекта'
              +^M^C' TPlate ',nil,mfInformation or mfOkButton);

end;
procedure TMyApp.ClearAir;
var
  D: PFileDialog;
  A:Word;
  F:file;
begin
    D := New(PFileDialog, Init('*.air', 'Удаление файла профиля', '~N~ame',
      fdOKButton, 100));
    if Desktop^.ExecView(D) <> cmCancel then
      D^.GetFileName(StreamFile);
    Dispose(D, Done);
    A:=MessageBox(^C'Вы действительно хотите удалить'
              +^M^C'файл '+StreamFile,nil,mfInformation or mfYesNoCancel);
    If A = cmYes Then begin
     Assign(F,StreamFile);
     Erase(F);
     end;
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

destructor TMyApp.Done;
begin
   If IsItGraph Then CloseGraph;
   DoneObj;
   inherited Done;
end;

Var
   MyApp : PMyApp;
begin
     MyApp:=New(PMyApp,Init);
     MyApp^.Run;
     Dispose(MyApp,Done);
end.
