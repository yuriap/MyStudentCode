program TVProf;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,ColorSel,
     Gadgets,StrmErr,StdDlg,TvrComm,TvrUnit,ProGraph,Validate,ProfDin,
     Graph,ProfComm,ProfMain,ProMain1,ProfView;
Type

    PApp = ^TApp;
    TApp = object(TApplication)
           Heap:PHeapView;
{           Clock:PClockView;}
           constructor init;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           Procedure HandleEvent(var Event:TEvent);virtual;
{           function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;}
           destructor Done;virtual;
           procedure Idle;virtual;
           function FileDlg(var FileName:FNameStr;aTitle,OnIStr:string):word;
           procedure CreateMain;
           procedure DoneMain;
           procedure LoadMain;
           procedure StoreMain;
           procedure MainParam;
           procedure ProfParam;
           procedure BoundParam;
           procedure GraphicManager;
           procedure GraphParam;
           procedure ChangeColor;
           procedure ViewBufferGraph;
           procedure Begining;
           procedure ViewerParam;
           procedure ViewerColor;
           procedure ViewPicture;
           procedure DigitResults;
           procedure NewPicture;
           procedure EditPicture;
           procedure DelPicture;
           end;
var
  MyApp:PApp;
  Res:TResourceFile;
  Stream:PBufStream;
constructor TApp.Init;
var R:Trect;
    What:string;
    ViewRec:TViewRec;
    i:integer;
begin
   What:=StartGraph;
{   RegisterObjects;}
   RegisterMain1;
   RegisterViews;
   RegisterMenus;
   RegisterDialogs;
   RegisterType(RSpecialDlg);
   RegisterValidate;
   RegisterType(RInpLineNe);
   RegisterColorSel;
   RegisterColorDlg;

     Stream:=New(PMsgStream,Init(TvrFile,stOpenRead,1024));
     Res.Init(Stream);
     inherited Init;
     Main:=nil;
{     GetExtent(R);
     R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
     Clock := New(PClockView, Init(R));
     Insert(Clock);}

     GetExtent(R);
     Dec(R.B.X);
     R.A.X:=R.B.X-9;R.A.Y:=R.B.Y-1;
     Heap:=New(PHeapView,Init(R));
     Insert(Heap);
{***********************}
with GraphicRec do begin
     MasX:='100';
     MasY:='100';
     StepX:='0.2';
     StepY:='0.2';
     X:='50';
     Y:='50';
     XName:='Arg';
     YName:='Func';
      Color[2]:=1;
      Color[3]:=5;
      Color[1]:=4;
      Color[0]:=7;
     OptionMas:=0;
     Title:='Рис.1. Тест.'
     end;
  Graphic:=New(PGraphic,Init(GraphicRec));
with ViewRec do begin
     MX:=300;
     MY:=300;
     DX:=50;
     DY:=220;
     For i:=0 to 5 do Col[i]:=i
     end;
   Viewer:=New(PViewer,Init(ViewRec,Main));
   Viewer^.StoreParam(ViewerRec);
  with  MRec do begin
   CountProfile:='1';
   Option:=moNoOption;
   b:='1';
   dt:='0.1';
   R:='1';
   PotokProX:='1';
   PotokProY:='0';
   Omega:='0';
   Betta0:='90';
   Nu:='1.01e-6';
   MaxTime:='1';
   FileMapContur:='*.map';
   end;
  with PRec do begin
   CountCP:='40';
   CornerSys:='0';
   NFree:='20';
   Tang:='50';
   Norm:='20';
   end;
  with BRec do begin
   Psi:='0.01';{малое положительное число для dU/dy при y=delta <= Psi}
   S:='0.5';{параметр усреднения}
   MaxIter:='30';{максимальное число итераций}
   parNevazka:='1';{величина невязки, %}
   MaxNevazka:='20';
   Option:=moNoOption;
   Prec:='2';
   Sloy:='0.15';
   end;
  MainRec:=InitMainRec;
  PutMain(MRec,MainRec);
  PutProf(PRec,MainRec^.ProfRecPtr);
  PutBound(BRec,MainRec^.BoundRec);
{  If What <> '' then MessageBox(What,nil,mfWarning or mfOkButton);}
  DisableCommands(AfterCreateSet);
  ENableCommands([cmCreateObj,cmOpenObj]);
end;
Procedure TApp.InitStatusLine;
Begin
   StatusLine:=PStatusLine(Res.Get(StatusLineId));
End;
Procedure TApp.InitMenuBar;
Begin
  MenuBar:=PMenuBar(Res.Get(MenusId));
End;
function TApp.FileDlg(var FileName:FNameStr;aTitle,OnIStr:string):word;
begin
  FileDlg:=ExecuteDialog(New(PFileDialog, Init(FileName,aTitle,
    OnIStr, fdOpenButton + fdHelpButton, 100)), @FileName)
end;
procedure TApp.GraphicManager;
var D:PManagerDlg;
    Control:word;
    E:TEvent;
begin
  D:=New(PManagerDlg,Init);
  Control:=ExecView(D);
  If Control <> cmCancel then begin
    E.What:=evCommand;
    E.Command:=Control;
    PutEvent(E);
    end;
end;
procedure TApp.GraphParam;
var
  S:PDialog;
  Comm:word;
  E:TEvent;
begin
  S:=PDialog(Res.Get(BufferGraphParamID));
  S^.SetData(GraphicRec);
  E.Command:=ExecView(S);
  If E.Command <> cmCancel Then begin
    S^.GetData(GraphicRec);
    Graphic^.NewParam(GraphicRec);
    end;
  E.What:=evCommand;
  PutEvent(E);
end;
procedure TApp.ChangeColor;
var
   C:TColor;
   CD:PCDlg;
   E:TEvent;
begin
  Cd:=PCDlg(Res.Get(ColorDlgId));
  Cd^.PutOption('Фон.Сетка.Выноски.Метки.');
  Cd^.SetData(GraphicRec.Color);
  If ExecView(Cd) <> cmCancel Then Cd^.GetData(GraphicRec.Color);
  Graphic^.NewParam(GraphicRec);
  Dispose(Cd,Done);
  E.What:=evCommand;
  E.Command:=cmManager;
  PutEvent(E);

end;
procedure TApp.ViewBufferGraph;
var
  B:PBuffer;
begin
  SetGraphMode(grMode);
  Graphic^.Execute;
  RestoreCrtMode;
  doneMemory;
  Redraw;
end;
Procedure TApp.HandleEvent(var Event:TEvent);
var N,i:integer;
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
      cmOpenObj :LoadMain;
      cmSaveObj :StoreMain;
      cmManager : GraphicManager;
      cmGraphParam : GraphParam;
      cmChColor : ChangeColor;
      cmViewBufferGraph : ViewBufferGraph;
      cmNewPicture : NewPicture;
      cmEditPicture : EditPicture;
      cmDelPicture : DelPicture;
      cmCreateObj : CreateMain;
      cmDoneMain :DoneMain;
      cmMainParam : MainParam;
      cmProfParam : ProfParam;
      cmBoundParam : BoundParam;
      cmBegining : Begining;
      {**********}
      cmDt : begin
             InputDialogBox('Шаг по времени',RealType,Main^.dt);
             with Main^ do bdt:=dt*U0/b;end;
      cmUx : begin
             InputDialogBox('Проекция Ux:',RealType,Main^.Potok.ProX);
             with Main^ do U0:=Sqrt(Sqr(Potok.ProX)+Sqr(Potok.ProY));end;
      cmUy : begin
             InputDialogBox('Проекция Uy:',RealType,Main^.Potok.ProY);
             with Main^ do U0:=Sqrt(Sqr(Potok.ProX)+Sqr(Potok.ProY));end;
      cmOmega : begin
             InputDialogBox('Частота вращения ВК:',RealType,Main^.Omega);
             with Main^ do bOmega:=Omega*b/U0;end;
      cmMaxTime:
        InputDialogBox('Колличество шагов расчета:',IntegerType,Main^.MaxTime);
      cmPsi :InputDialogBox('Точность dU/dy:',RealType,Main^.BLayer^.Psi);
      cmS :InputDialogBox('Параметр усреднения:',RealType,Main^.BLayer^.S);
      cmMaxIter :
        InputDialogBox('Итерации по толщине ПС:',IntegerType,Main^.BLayer^.MaxIter);
      cmParNevazka :
        InputDialogBox('Hевязка, %:',RealType,Main^.BLayer^.parNevazka);
      cmMaxNevazka :
        InputDialogBox('Итерации по невязке',IntegerType,Main^.BLayer^.MaxNevazka);
      cmPrec :InputDialogBox('Точность выч. толщины ПС',RealType,Main^.BLayer^.Prec);
      cmSloy :InputDialogBox('Слой',RealType,Main^.BLayer^.Sloy);
      cmNFree : begin
        InputDialogBox('Кол-во сохраняемых св. вихрей:',IntegerType,
                        Main^.GetProfile(1)^.FreePreserve);
        N:=Main^.GetProfile(1)^.FreePreserve;
        for i:=1 to Main^.CountProfil do Main^.GetProfile(1)^.FreePreserve:=N;
        end;
      {*************}
      cmGParam : ViewerParam;
      cmCColor : ViewerColor;
      cmViewGraph : ViewPicture;
      cmDigitResults : DigitResults;
      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
destructor TApp.Done;
begin
  Dispose(Heap,Done);
{  Dispose(Clock,Done);}
  Dispose(Graphic,Done);
  Dispose(Viewer,Done);
  Res.Done;
  If IsItGr Then DoneGraph;
  if Main <> nil then Dispose(Main,Done);
  inherited Done;
end;
procedure TApp.Idle;
begin
  inherited idle;
  Heap^.Update;
{  Clock^.UpDate;}
end;
procedure TApp.CreateMain;
var E:TEvent;
begin
  MRec.FileMapContur:='*.map';
  If FileDlg(MRec.FileMapContur,'Файл карты профиля','Имя файла') <> cmCancel then
  begin
   E.What:=evCommand;
   E.Command:=cmMainParam;
   PutEvent(E);
  end;
end;
procedure TApp.StoreMain;
var
   FName:FNameStr;
   C:word;
   W:PWaitWin;
   S:PMsgStream;
begin
  FName:='*.wpw';
  If FileDlg(FName,'Файл ветроколеса','Сохранить как') <> cmCancel then
  begin
  if FindFile(FName) then begin
  C:=MessageBox(^C'Файл '+FName+' уже существует.'
               +^M^C'Переписать ?',nil,mfInformation or
                 mfOkButton or mfNoButton);
                 If C <> cmYes then exit;
                 end;
      W:=New(PWaitWin,Init);
      DeskTop^.Insert(W);
      S:=New(PMsgStream,Init(FName,stCreate,2048));
      S^.Put(Main);
      Dispose(S,Done);
      Dispose(W,Done);
   end;
end;
procedure TApp.LoadMain;
var
   FName:FNameStr;
   C:word;
   W:PWaitWin;
   S:PMsgStream;
begin
  FName:='*.wpw';
  If FileDlg(FName,'Ветроколесо','Загрузить из файла') <> cmCancel then
  begin
  if not (FindFile(FName)) then begin
     MessageBox(^C'Файл '+FName+' не найден',nil,mfWarning or mfOkButton );
     exit;
     end
    else begin
      W:=New(PWaitWin,Init);
      DeskTop^.Insert(W);
      S:=New(PMsgStream,Init(FName,stOpenRead,2048));
      Main:=PMain1(S^.Get);
      Dispose(S,Done);
      Dispose(W,Done);
      DisableCommands(NotAfterCreateSet);
      EnableCommands(AfterCreateSet);
      MessageBox(^C'Загрузка завершена',nil,mfInformation or mfOkButton);
      end;
      end;
end;

procedure TApp.MainParam;
var
  S:PDialog;
  Control:word;
  E:TEvent;
  W:PWaitWin;
begin
  S:=PDialog(Res.Get(MainParamId));
  S^.SetData(MRec);
  Control:=ExecView(S);
  if Control <> cmCancel then begin
      S^.GetData(MRec);
      PutMain(MRec,MainRec);
      end;
  Dispose(S,Done);
  if (Control <> cmOk) and (Control <> cmCancel) then begin
    E.What:=evCommand;
    E.Command:=Control;
    PutEvent(E);
    end;
  if Control = cmOk then begin
    W:=New(PWaitWin,Init);
    DeskTop^.Insert(W);
    Main:=New(PMain1,Init(MainRec^));
    Dispose(W,Done);
    Viewer^.Main:=Main;
    DisableCommands(NotAfterCreateSet);
    EnableCommands(AfterCreateSet);
    MessageBox(^C'Инициализация завершена',nil,mfInformation or mfOkButton);
    end
end;{TApp.CreateMain}
procedure TApp.DoneMain;
begin
  If Main <> nil then begin
    Dispose(Main,Done);
    Main:=nil;
    DisableCommands(AfterCreateSet);
    ENableCommands(NotAfterCreateSet);
    end;
end;
procedure TApp.ProfParam;
var E:TEvent;
    S:PDialog;
    Control:word;
begin
  S:=PDialog(Res.Get(ProfParamId));
  S^.SetData(PRec);
  Control:=ExecView(S);
  if Control <> cmCancel then begin
      S^.GetData(PRec);
      PutProf(PRec,MainRec^.ProfRecPtr);
      end;
    Dispose(S,Done);
    E.What:=evCommand;
    E.Command:=cmMainParam;
    PutEvent(E);
end;
procedure TApp.BoundParam;
var E:TEvent;
    S:PDialog;
    Control:word;
begin
  S:=PDialog(Res.Get(BoundParamId));
  S^.SetData(BRec);
  Control:=ExecView(S);
  if Control <> cmCancel then begin
      S^.GetData(BRec);
      PutBound(BRec,MainRec^.BoundRec);
      end;
    Dispose(S,Done);
    E.What:=evCommand;
    E.Command:=cmMainParam;
    PutEvent(E);
end;
procedure TApp.Begining;
begin
  StatusWindow:=New(PStatusWindow,Init);
  StatusWindow^.HelpCtx:=hcStatusWindow;
  StatusWindow^.UpGrade(Main);
  ExecView(StatusWindow);
  Dispose(StatusWindow,Done);
end;
procedure TApp.ViewerParam;
var D:PSpecialDlg;
    Control:word;
    E:TEvent;
begin
  D:=PSpecialDlg(Res.Get(ViewerDialogID));
  D^.SetData(ViewerRec);
  Control:=ExecView(D);
  if Control <> cmCancel Then D^.GetData(ViewerRec);
  E.What:=evCommand;
  E.Command:=Control;
  PutEvent(E);
  Dispose(D,Done);
  Viewer^.PutParam(ViewerRec);
end;
procedure TApp.ViewerColor;
var
   C:TColor;
   CD:PCDlg;
begin
  Cd:=PCDlg(Res.Get(ColorDlgId));
  Cd^.PutOption(
  'Фон.Контрольные точки.Присоединенные вихри.Свободные вихри.Оси координат');
  Cd^.SetData(Viewer^.Colors);
  If ExecView(Cd) <> cmCancel Then Cd^.GetData(Viewer^.Colors);
  Dispose(Cd,Done);
end;
procedure TApp.ViewPicture;
begin
  SetGraphMode(grMode);
  Viewer^.Execute;
  RestoreCrtMode;
  DoneMemory;
  Redraw;
  Viewer^.StoreParam(ViewerRec);
end;
procedure TApp.DigitResults;
var
  mCp,mM,mCz,mCx:string[10];
  R:TRect;
begin
  mCp:=RealToStr(Main^.GetMiddleCP);
  mM:=RealToStr(Main^.GetMiddleMoment);
  mCz:=RealToStr(Main^.GetMiddleCz);
  mCx:=RealToStr(Main^.GetMiddleCx);
  R.Assign(15,8,65,17);
  MessageBoxRect(R,^C'Средний Cp: '+mCp
                   +^M^C'Средний коэффициент крутящий момент: '+mM
                   +^M^C'Cредний коэффициент боковой силы: '+mCz
                   +^M^C'Cредний коэффициент лобовой силы: '+mCx,
                   nil,mfInformation or mfOkButton);
end;
procedure TApp.NewPicture;
var
   C:Word;z:integer;
   E:TEvent;
   Num,
   NumProfile:integer;
   T:PNewVecBox;
   Buff:PBuffer;
begin
  with BufferRec do begin
    Number1:='1';
    Number2:='1';
    Name := 'First';
    Color :=1;
    end;
   T:=New(PNewVecBox,Init);
   T^.SetData(BufferRec);
   C:=ExecView(T);
   If C <> cmCancel Then begin
   T^.GetData(BufferRec);
   NumProfile:=StrToInteger(BufferRec.Number1);
   Num:=StrToInteger(BufferRec.Number2);
   case BufferRec.Option.Selection of
     0: Buff:=Main^.Get_W_S(NumProfile);
     1: Buff:=Main^.Get_W_X(NumProfile);
     2: Buff:=Main^.Get_P_S(NumProfile);
     3: Buff:=Main^.Get_P_X(NumProfile);
     4: Buff:=Main^.Get_T_S(NumProfile);
     5: Buff:=Main^.Get_T_X(NumProfile);
     6: Buff:=Main^.Get_Delta_S(NumProfile);
     7: Buff:=Main^.Get_Delta_X(NumProfile);
     8: Buff:=Main^.Get_MainNorm(NumProfile,Num);
     9: Buff:=Main^.Get_MainGor(NumProfile,Num);
     10:Buff:=Main^.Get_CompNorm(NumProfile,Num);
     11:Buff:=Main^.Get_CompGor(NumProfile,Num);
     12:Buff:=Main^.GetMoment_Corner;
     13:Buff:=Main^.GetCp_Corner;
     14:Buff:=Main^.GetCz_Corner;
     15:Buff:=Main^.GetCx_Corner;
     16:Buff:=Main^.GetCr_Corner;
     17:Buff:=Main^.GetCq_Corner;
     18:Buff:=Main^.GetContur;
     end;end;
   Graphic^.InsertBuffer(Buff);
   E.What:=evCommand;
   E.Command:=cmManager;
   PutEvent(E);
   Dispose(T,Done);
end;
procedure TApp.EditPicture;
var
   E:TEvent;
   T:PEditBuffer;
   C:word;
   Buf:PBuffer;
   D:record
     NameBuf : string[7];
     Color : word;
     end;
begin
   Buf:=PBuffer(Graphic^.Collect^.At(ListRec.Selection));
   With D do begin
     NameBuf := Buf^.Labels;
     Color := Buf^.Color;
     end;
   T:=New(PEditBuffer,Init);
   T^.SetData(D);
   C:=ExecView(T);
   if C = cmOk Then begin
     T^.GetData(D);
     With D do begin
        Buf^.Labels:=NameBuf;
        Buf^.Color:=Color;
       end;
     end;
   E.What:=evCommand;
   E.Command:=cmManager;
   PutEvent(E);
   Dispose(T,Done);
end;
procedure TApp.DelPicture;
var
   E:TEvent;
   C:word;
   B:PBuffer;
begin
   If Graphic^.IsInsert then begin
   C:=MessageBox(^C'Вы действительно хотите'
           +^M^C'удалить вектор с меткой'
           +^M^C+PBuffer(Graphic^.Collect^.At(ListRec.Selection))^.Labels
               ,nil,mfWarning or mfYesButton or mfNoButton);
   If C = cmYes then begin
      Graphic^.Collect^.AtDelete(ListRec.Selection);
      If Graphic^.Collect^.Count = 0 then Graphic^.IsInsert:=false
      end;end;
   E.What:=evCommand;
   E.Command:=cmManager;
   PutEvent(E);
end;
{*********************************************************}
begin
 MyApp:=New(PApp,Init);
 MyApp^.Run;
 Dispose(MyApp,Done);
end.
