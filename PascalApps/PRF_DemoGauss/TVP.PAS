program TVProf;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,ColorSel,
     Gadgets,StrmErr,StdDlg,TvrComm,TvrUnit,ProGraph,Validate,ProfDin,
     Graph,ProfComm,ProfMain,ProMain1,ProfView;
Type

    PApp = ^TApp;
    TApp = object(TApplication)
           Heap:PHeapView;
           constructor init;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           Procedure HandleEvent(var Event:TEvent);virtual;
           destructor Done;virtual;
           procedure Idle;virtual;
           procedure CreateMain;
           procedure DoneMain;
           procedure MainParam;
           procedure ProfParam;
           procedure BoundParam;
           procedure GraphicManager;
           procedure StoreMain;
           function FileDlg(var FileName:FNameStr;aTitle,OnIStr:string):word;
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
{   What:=StartGraph;
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
{  Graphic:=New(PGraphic,Init(GraphicRec));}
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
{  DisableCommands(AfterCreateSet);
  ENableCommands([cmCreateObj,cmOpenObj]);}
end;
Procedure TApp.InitStatusLine;
Begin
   StatusLine:=PStatusLine(Res.Get(StatusLineId));
End;
Procedure TApp.InitMenuBar;
Begin
  MenuBar:=PMenuBar(Res.Get(MenusId));
End;
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
Procedure TApp.HandleEvent(var Event:TEvent);
var N,i:integer;
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
      cmManager : GraphicManager;
      cmCreateObj : CreateMain;
      cmDoneMain :DoneMain;
      cmMainParam : MainParam;
      cmProfParam : ProfParam;
      cmBoundParam : BoundParam;
      cmSaveObj :StoreMain;
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
  Res.Done;
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
  FileDlg(MRec.FileMapContur,'Файл карты профиля','Имя');
  E.What:=evCommand;
  E.Command:=cmMainParam;
  PutEvent(E);
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
function TApp.FileDlg(var FileName:FNameStr;aTitle,OnIStr:string):word;
begin
  FileDlg:=ExecuteDialog(New(PFileDialog, Init(FileName,aTitle,
    OnIStr, fdOpenButton + fdHelpButton, 100)), @FileName)
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

{*********************************************************}
begin
 MyApp:=New(PApp,Init);
 MyApp^.Run;
 Dispose(MyApp,Done);
end.
