Program TV_Imit;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,StdDlg,HistList,
     {Plates,}PlCommon,{Point,Collect,}StrmErr,{ViewFunc,}SomeObj,
     Graph,Dos,Crt;
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
      cmViewFunc = 1010;
      cmParFuncView = 1011;
      cmPutResourse = 1012;
      cmGetResourse = 1014;
      IsHelp : boolean = false;
      StreamFile:PathStr='';
      Resource:string[12]='Wind.stm';
var
      Plate : PTry;{PPlate}
{      DataViewFunc:TDataViewFunc;}
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
     {      function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;}
           procedure PutResourse;
           procedure GetResourse;
           procedure OpenFile;
    {       procedure ViewFunc;
           procedure ParFuncView;}
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
{     With DataGraph do begin
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
      end;}
{     With DataViewFunc do begin
      rmasx:='100';rmasy:='100';
      rx:='100';ry:='100';
      rstepx:='0.2';rstepy:='0.1';
      rstep_arg:='0.01';
      rx1:='0';rx2:='0.6';
      rColSetka:=3;rColGraphic:=4;
      rColDesk:=1;
      end;}
      With DCircle do begin
      dX:='100';
      dY:='100';
      dR:='60';
      end;
     GraphInit;
     inherited Init;
{     RegisterType(RPlate);
     RegisterType(RCollCon);
     RegisterType(RCollRot);
     RegisterType(RTearPoint);
     RegisterType(RConPoint);
     RegisterType(RRotAdd);
     RegisterType(RRotFree);}
     RegisterType(RTry);
{     RegisterHelpFile;}
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
    NewSubMenu('Потоки ',hcNoContext,NewMenu(
     NewItem('Создать новый объект...','',0,cmCreate,hcNoContext,
     NewItem('Уничтожить объект','',0,cmDoneObj,hcNoContext,
     NewItem('Записать объект в поток...','',0,cmSaveObj,hcNoContext,
     NewItem('Извлечь объект из потока...','',0,cmExtract,hcNoContext,
     NewItem('Удалить файл с профилем...','',0,cmClearAir,hcNoContext,
     NewLine(
     NewItem('Записать объект в ресурс...','',0,cmPutResourse,hcNoContext,
     NewItem('Загрузить объект из ресурса...','',0,cmGetResourse,hcNoContext,
      nil))))))))),
    NewSubMenu('Просмотр',hcNoContext,NewMenu(
     NewItem('Параметры графики...','',0,cmGraphParam,hcNoContext,
     NewItem('Просмотр графического экрана ','',0,cmViewer,hcNoContext,
     nil))),
    NewSubMenu('График функции',hcNoContext,NewMenu(
     NewItem('Параметры просмотра...','',0,cmParFuncView,hcNoContext,
     NewItem('Просмотр','',0,cmViewFunc,hcNoContext,nil))),
     nil))))));
End;
Procedure TMyApp.MainParam;
Var
   MyDialog : PDlgCircle;
   Cont:Word;
Begin
   MyDialog:=New(PDlgCircle,Init);
   MyDialog^.SetData(DCircle);
   Cont:=DeskTop^.ExecView(MyDialog);
   If Cont <> cmCancel Then MyDialog^.GetData(DCircle);
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
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(3,5,39,6);
      Insert(New(PLabel,Init(R,'Масштаб по вертикали',CheckRadio)));

      R.Assign(40,7,55,8);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(3,7,39,8);
      Insert(New(PLabel,Init(R,'Смещение т.(0,0) по горизонтали',CheckRadio)));

      R.Assign(40,9,55,10);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
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
{      cmViewFunc : ViewFunc;
      cmParFuncView : ParFuncView;}
      cmPutResourse : PutResourse;
      cmGetResourse : GetResourse;
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
     Plate :=New(PTry,Init(DCircle)); {PPlate}
     MessageBox(^C'Создан экземпляр объекта'
              +^M^C' TPlate ',nil,mfInformation or mfOkButton);
end;end;
procedure TMyApp.DoneObj;
var A : word;
begin
   If Plate <> nil then begin
   if Plate^.Status = stNew then begin
   A:=MessageBox(^C'Не хотите ли вы сохранить объект ?'
               ,nil,mfInformation or mfYesButton or mfNoButton);
   if A = cmYes then  SaveObj;end;
   Dispose(Plate,Done);
   Plate:=nil;end
end;
procedure TMyApp.Viewer;
begin
   If Plate = nil then begin
     MessageBox(^C'Создайте экземпляр объекта'
              +^M^C' TPlate ',nil,mfInformation or mfOkButton);
   Exit;end;
   If not IsItGraph then begin
      MessageBox(^C'Ошибка графики.'
       +^M^C'Установите драйвер EGAVGA.BGI.'
       +^M^C'Перезапустите систему.' ,nil,mfWarning or mfOkButton);
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
  If Plate <> nil then begin
    D := New(PFileDialog, Init('*.air', 'Запись профиля в файл ', '~N~ame',
      fdOKButton, 100));
    if Desktop^.ExecView(D) <> cmCancel then

      D^.GetFileName(StreamFile);
    Dispose(D, Done);
    S.Init(StreamFile,stCreate,1024);
    S.Put(Plate);
    S.Done;
  end
  else
     MessageBox(^C'Создайте экземпляр объекта'
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
    Plate:=PTry(S.Get);{PPlate}
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
procedure TMyApp.PutResourse;
var
   Res:TResourceFile;
   Stream:PMyBufStream;
   D:PFileDialog;
   F:PDialog;
   R:TRect;
   CR:PInputLine;

   B:PathStr;
   Collect:PStringCollection;
   i:integer;
   ScrollBar:PScrollBar;
   Control:PView;
   Dir:String[10];
const    A:String[10]='Number';
begin
    If Plate <> nil Then Begin
    GetDir(0,Dir);
    B:=FSearch(Dir+'\'+Resource,'');
    if B <> '' then Stream:=New(PMyBufStream,Init(Resource,stOpenWrite,1024))
     else Stream:=New(PMyBufStream,Init(Resource,stCreate,1024));
    Res.Init(Stream);
    Collect:=New(PStringCollection,Init(10,10));
    for i:=0 to Res.Count-1 do
      Collect^.Insert(NewStr(Res.KeyAt(i)));

    R.Assign(0,0,80,24);
    F:=New(PDialog,Init(R,'Resource Servis'));
    with F^ do begin
      R.Assign(4,3,36,4);
      CR:=New(PInputLine,Init(R,11));
      Insert(CR);
      R.Assign(3,2,35,3);
      Insert(New(PLabel,Init(R,'~K~люч объекта ( <10 символов)',CR)));
      R.Assign(5,7,15,9);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(25,7,35,9);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
      R.Assign(34, 10, 35, 16);
      New(ScrollBar, Init(R));
      Insert(ScrollBar);
      R.Assign(5, 10, 34, 16);
      Control := New(PListBox, Init(R, 1, ScrollBar));
      Insert(Control);
      PListBox(Control)^.NewList(Collect);
      R.Assign(4, 9, 12, 10);
      Insert(New(PLabel, Init(R, 'Ключи:', Control)));

      SelectNext(false);
      SetData(A);
    if Desktop^.ExecView(F) <> cmCancel then
      GetData(A);
     end;
   Res.Put(Plate,A);
   Res.Done;
   end;
end;
procedure TMyApp.GetResourse;
begin
end;

{Function TMyApp.GetPalette;
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
end;}
{procedure TMyApp.ViewFunc;
var S:PGraphic;
begin
   If not IsItGraph then begin
      MessageBox(^C'Ошибка графики.'
       +^M^C'Установите драйвер EGAVGA.BGI.'
       +^M^C'Перезапустите систему.' ,nil,mfWarning or mfOkButton);
   Exit;end;
     SetGraphMode(grMode);

   S:=New(PGraphic,Init(DataViewFunc));
   with S^ do begin
     Run;
     Done;
     end;
     RestoreCrtMode;
     DoneMemory;
     Redraw;
end;
procedure TMyApp.ParFuncView;
Var
   MyDialog : PInpDlg;
   CheckRadio : PView;
   Button : PButton;
   R:TRect;
   Control:Word;
Begin
   MyDialog:=New(PInpDlg,Init);
   MyDialog^.SetData(DataViewFunc);
   Control:=DeskTop^.ExecView(MyDialog);
   If Control <> cmCancel Then MyDialog^.GetData(DataViewFunc);
end;}
destructor TMyApp.Done;
begin
  If IsItGraph Then CloseGraph;
  DoneObj;
  inherited Done;
end;
var
  MyApp:PMyApp;
begin
     MyApp:=New(PMyApp,Init);
     MyApp^.Run;
     MyApp^.Done;
end.

   {************************************************}
