Program TV_Imit;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,StdDlg,HistList,
     AbsPoint,Plates,PlCommon,Point,Collect,StrmErr,ViewFunc,
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
      IsHelp : boolean = false;
      StreamFile:PathStr='';
var
      Plate : PPlate;
      DataViewFunc:TDataViewFunc;
procedure Registers;
begin
    RegisterViews;
    RegisterDialogs;
    RegisterMenus;
    RegisterStdDlg;
    RegisterApp;
end;

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
{     With DataViewFunc do begin
      rmasx:='100';rmasy:='100';
      rx:='100';ry:='100';
      rstepx:='0.2';rstepy:='0.1';
      rstep_arg:='0.01';
      rx1:='0';rx2:='0.6';
      rColSetka:=3;rColGraphic:=4;
      rColDesk:=1;
      end;}
     GraphInit;
     inherited Init;
     RegisterType(RPlate);
     RegisterType(RCollCon);
     RegisterType(RCollRot);
     RegisterType(RTearPoint);
     RegisterType(RConPoint);
     RegisterType(RRotAdd);
     RegisterType(RRotFree);
     RegisterType(RAbsPoint);

     Registers;
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
     NewItem('Удалить файл с профилем...','',0,cmClearAir,hcNoContext,nil)))))),
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
   Dial : PDialog;
   Cont:Word;
   Res:TResourceFile;
   S:PBufStream;
Begin
   S:=New(PBufStream,Init('tv_plate.stm',stOpenRead,1024));
   Res.Init(S);
   Dial:=PDialog(Res.Get('Dlg_Plate'));
   Res.Done;

   Dial^.SetData(DataPlate);
   Cont:=DeskTop^.ExecView(Dial);
   If Cont <> cmCancel Then Dial^.GetData(DataPlate);
   Dispose(Dial,Done);
end;
procedure TMyApp.GraphParam;
Var
   Dial : PDialog;
   Cont:Word;
   Res:TResourceFile;
   S:PBufStream;
Begin
   S:=New(PBufStream,Init('tv_plate.stm',stOpenRead,1024));
   Res.Init(S);
   Dial:=PDialog(Res.Get('Dlg_Graph'));
   Res.Done;

   Dial^.SetData(DataGraph);
   Cont:=DeskTop^.ExecView(Dial);
   If Cont <> cmCancel Then Dial^.GetData(DataGraph);
   Dispose(Dial,Done);
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
              +^M^C' TPlate ',nil,mfInformation or mfOkButton);
end;end;
procedure TMyApp.DoneObj;
var A : word;
begin
   If Plate <> nil then begin
   A:=MessageBox(^C'Не хотите ли вы сохранить объект'
               ,nil,mfInformation or mfYesButton or mfNoButton);
   Case A of
   cmNo : begin
                    Dispose(Plate,Done);
                    Plate:=nil;end;
   cmYes : SaveObj;
   end;end;
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
     ShowMouse;
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
