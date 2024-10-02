Unit Blaz001;
Interface
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,
     Gadgets,BBoundT,BGraphic,BGraphDl,BDinamic,Graph;
Const
      cmBoundParam = 1000;
      cmBegining = 1001;
      cmGoNext = 1002;
      cmInsertVector = 1003;
      cmServiseVector = 1004;
      cmViewVector =1007;
      cmGraphParam = 1006;
      cmEditVecAttr = 1005;
      cmDelVector = 1008;
      cmViewDecVector = 1009;
      cmDelAllVector = 1010;
      cmRezult = 1012;

      cmParFuncView = 1011;
      IsHelp : boolean = false;
Type

    PApp = ^TApp;
    TApp = object({tvdEBUG.}TApplication)
           Heap:PHeapView;
{           Clock:PClockView;}
           constructor init;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           Procedure HandleEvent(var Event:TEvent);virtual;
     {      function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;}
           procedure GraphParam;
           procedure ServiseVector;
           procedure InsertVector;
           procedure EditVecAttr;
           procedure DelVector;
           procedure DelAllVector;
           procedure ViewDecVector;
           procedure ViewVector;
           procedure BoundParam;
           procedure Begining;
           procedure GoNext;
           destructor Done;virtual;
           procedure Idle;virtual;
           end;
var
  MyApp:PApp;

implementation
constructor TApp.Init;
var R:Trect;
    ErrorMessage:string;
begin
     RegisterType(RZeroVector);

{     Writeln;
     Writeln(' Wind Machine Version 0.0 Copyright (c) 1995 Sumy State University');
     Delay(1000);}
{************************************************************************}
     With GrRec Do begin
     masx:='400';
     masy:='150';
     x:='100'; y:='100';
     stepx:='0.1';stepy:='0.2';
     step_arg:='0.1';
     x1:='0';x2:='1';
     XName:='Etta';
     YName:='Func';
     LineColor:=1-1;LabelsColor:=2-1;{чтобы получить номер цвета прибавить единицу}
     ColSetka:=3-1;ColGraphic:=4-1;
     ColDesk:=0;
     end;
{**********************************************************************}
     With BoundRec do begin
       Nu:='1.01e-6';{вязкость [м^2/c]}
       U0:='0.101';{скорость потока [м/c]}
       L :='1.0';{длина пластины [м]}
       Ro:='1000';{плотнщсть жидкости [кг/м^3]}
       X0:='1';{коеффициент для задания граничного условия (см Б.-Н. "а")}
       Psi:='1e-2';{малое положительное число для dU/dy при y=delta <= Psi}
       S:='0.5';{параметр усреднения}
       M:=IntToStr(DimVert);{размерность матрицы сетки по " нормали" к пластине (0..M)}
       N:=IntToStr(DimHor);{размерность матрицы сетки по "касательной" к пластине(0..N)}
       MaxIter:='50';{максимальное число итераций}
       IfView := 1;{прогонка по нормали без просмотра графиков}
       ParW:='0';
       parNevazka:='0.1';{величина невязки, %}
       end;
{*************************************************************************}
     Graphic:=New(PZGraphic,Init);
     ABound:=New(PBoundLayer,Init);
     ErrorMessage:= StartGraph;

     inherited Init;
{     GetExtent(R);
     R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
     Clock := New(PClockView, Init(R));
     Insert(Clock);}

     GetExtent(R);
     Dec(R.B.X);
     R.A.X:=R.B.X-9;R.A.Y:=R.B.Y-1;
     Heap:=New(PHeapView,Init(R));
     Insert(Heap);
     If ErrorMessage <> '' Then
       MessageBox(ErrorMessage,nil,mfWarning or mfOkButton);
end;
Procedure TApp.InitStatusLine;
Var R : TRect;
Begin
     GetExtent(R);
     R.A.Y:=R.B.Y-1;
     StatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FFFF,
      NewStatusKey('~F1~ Помощь ',kbF1,cmHelp,
        NewStatusKey('~Alt-X~ Выход',kbAltX,cmQuit,
          NewStatusKey('~F10~ Меню',kbF10,cmMenu,
              StdStatusKeys(
        nil)))),nil)));
End;
Procedure TApp.InitMenuBar;
Var R : TRect;
Begin
  GetExtent(R);
  R.B.Y:=R.A.Y+1;
  MenuBar:=New(PMenuBar,Init(R,NewMenu(
    NewSubMenu('Параметры ',hcNoContext,NewMenu(
     NewItem('Параметры пограничного слоя...','',0,cmBoundParam,hcNoContext,
     NewItem('Расчет с начала','',0,cmBegining,hcNoContext,
     NewItem('Продолжение расчета','',0,cmGoNext,hcNoContext,
     NewItem('Результаты расчета','',0,cmRezult,hcNoContext,
     nil))))),
    NewSubMenu('Просмотр',hcNoContext,NewMenu(
{     NewSubMenu('1-й график',hcNoContext,NewMenu(}
        NewItem('Параметры графики...','',0,cmGraphParam,hcNoContext,
        NewItem('Векторы... ','',0,cmServiseVector,hcNoContext,
        NewItem('Просмотр  ','',0,cmViewVector,hcNoContext,
     nil)))),
     nil)))));{,nil)))));}
End;
procedure TApp.GraphParam;
Var
   M : PGrDlgBox;
   C:Word;
Begin

     M:=New(PGrDlgBox,Init);
     M^.SetData(GrRec);
     C:=DeskTop^.ExecView(M);
     If C <> cmCancel Then begin M^.GetData(GrRec);
                                 Graphic^.NewParam;end;
     Dispose(M,Done);
end;

procedure TApp.ServiseVector;
var T:PVecList;
    C:word;
    E:TEvent;
begin
   T:=New(PVecList,Init);
   C:=ExecView(T);
   T^.Lb^.GetData(ListRec);
      case C   of
      cmNewVec : E.Command:=cmInsertVector;
      cmEditVec : E.Command:=cmEditVecAttr;
      cmDelVec : E.Command:=cmDelVector;
      cmViewDecVec : E.Command:=cmViewDecVector;
      cmDelVecAll : E.Command:=cmDelAllVector;
      cmViewVec : E.Command:=cmViewVector;
      cmGrParam : E.Command:=cmGraphParam;
      end;
      E.What:=evCommand;
      PutEvent(E);
      Dispose(T,Done);
end;
procedure TApp.InsertVector;
var
   C:Word;z:integer;
   E:TEvent;
   Num:word;

   T:PNewVecBox;

  procedure InstalValue(Vector:PZVector);
  begin
      Vector^.Labels:=VecRec.Name;
      Vector^.Color:=VecRec.Color;
      If VecRec.Visible = 0 then Vector^.Visible:=true
        else Vector^.Visible:=false;
  end;
  procedure InsDelta;
  var
     Vec:PZVector;
     i:integer;
  begin
    Vec:=New(PZVector,Init(DimHor+1));
    for i:=0 to DimHor do Vec^.Put(i,ABound^.Delta[i]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
  end;
  procedure InsMainNorm;
  var Vec:PZVector;
      i:word;
  begin
    Vec:=New(PZVector,Init(DimVert+1));
    For i:=0 to DimVert do
      Vec^.Put(i,ABound^.MainSetka[i,Num]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
  end;
  procedure InsSecNorm;
  var Vec:PZVector;
      i:word;
  begin
    Vec:=New(PZVector,Init(DimVert+1));
    For i:=0 to DimVert do
      Vec^.Put(i,ABound^.ComplementSetka[i,Num]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
  end;

  procedure InsMainGor;
  var Vec:PZVector;
      i:word;
  begin
    Vec:=New(PZVector,Init(DimHor+1));
    For i:=0 to DimHor do
      Vec^.Put(i,ABound^.Tay[i]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
  end;

  procedure InsSecGor;
  var Vec:PZVector;
      i:word;
  begin
    Vec:=New(PZVector,Init(DimHor+1));
    For i:=0 to DimHor do
      Vec^.Put(i,ABound^. C_m[i]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
  end;

begin
  with VecRec do begin
    Number:='0';
    Name := 'First';
    Visible :=0;
    Color :=1;
    end;

   T:=New(PNewVecBox,Init);
{   VecRec.Option.List:=T^.LB^.OptionCollect;
   VecRec.Option.Selection:=0;}
   T^.SetData(VecRec);
   C:=ExecView(T);
   If C <> cmCancel Then begin
   T^.GetData(VecRec);
{   T^.LB^.GetData(ListOption);}
   Val(VecRec.Number,Num,z);
   case VecRec.Option.Selection of
{    case VecRec.Option of}
     0: InsDelta;
     1: InsMainNorm;
     2: InsSecNorm;
     3: InsMainGor;{Вставляет распред. касательных напряжений}
     4: InsSecGor;{коэфф. касательных напряжений}
     5: MessageBox('Окно',nil,mfInformation or mfOkButton);
     end;end;
   E.What:=evCommand;
   E.Command:=cmServiseVector;
   PutEvent(E);
   Dispose(T,Done);
end;
procedure TApp.EditVecAttr;
var
   E:TEvent;
   T:PEditVec;
   C:word;
   D:record
     NameVec : string[5];
     Color : word;
     Visible : word;
     end;
   Vector:PZVector;
begin
   Vector:=PZVector(Graphic^.Collect^.At(ListRec.Selection));
   With D do begin
     NameVec := Vector^.Labels;
     Color := Vector^.Color-1;
     if Vector^.Visible then Visible := 0 else Visible := 1;
     end;
   T:=New(PEditVec,Init);
   T^.SetData(D);
   C:=ExecView(T);
   if C = cmOk Then begin
     T^.GetData(D);
     With D do begin
        Vector^.Labels:=NameVec;
        Vector^.Color:=Color+1;
        if Visible = 0 then Vector^.Visible:=true else Vector^.Visible:=false;
       end;
     end;
   E.What:=evCommand;
   E.Command:=cmServiseVector;
   PutEvent(E);
   Dispose(T,Done);
end;
procedure TApp.DelVector;
var
   E:TEvent;
   C:word;
   Vector:PZVector;
begin
   If Graphic^.IsInsert then begin
   C:=MessageBox(^C'Вы действительно хотите'
           +^M^C'удалить вектор с меткой'
           +^M^C+PZVector(Graphic^.Collect^.At(ListRec.Selection))^.Labels
               ,nil,mfWarning or mfYesButton or mfNoButton);

   If C = cmYes then begin
      Graphic^.Collect^.AtDelete(ListRec.Selection);
      If Graphic^.Collect^.Count = 0 then Graphic^.IsInsert:=false
      end;end;
   E.What:=evCommand;
   E.Command:=cmServiseVector;
   PutEvent(E);
end;
{*********************************************************}
procedure TApp.DelAllVector;
var
   E:TEvent;
   C:word;
   Vector:PZVector;
   counter,i:integer;
begin
   If Graphic^.IsInsert then begin
   Counter:=Graphic^.Collect^.Count;
   for i:=1 to Counter do
   begin
   C:=MessageBox(^C'Вы действительно хотите'
           +^M^C'удалить вектор с меткой'
           +^M^C+PZVector(Graphic^.Collect^.At(ListRec.Selection))^.Labels
               ,nil,mfWarning or mfYesButton or mfNoButton);

   If C = cmYes then begin
      Graphic^.Collect^.AtDelete(ListRec.Selection);
      If Graphic^.Collect^.Count = 0 then Graphic^.IsInsert:=false
      end;end;end;
   E.What:=evCommand;
   E.Command:=cmServiseVector;
   PutEvent(E);
end;

{*********************************************************}
procedure TApp.ViewDecVector;
var
   E:TEvent;
   T:PViewDec;
   C:word;
   V:PZVector;
begin
   V:=PZVector(Graphic^.Collect^.At(ListRec.Selection));
   T:=New(PViewDec,Init(V));
   ExecView(T);
   E.What:=evCommand;
   E.Command:=cmServiseVector;
   PutEvent(E);
   Dispose(T,Done);
end;

procedure TApp.ViewVector;
begin
  If Graphic^.IsInsert and IsItGr Then begin
  SetGraphMode(grMode);
     ShowMouse;
  Graphic^.Execute;
     RestoreCrtMode;
     DoneMemory;
     Redraw;
     ShowMouse;
  Graphic^.StoreParam;
     end;
end;
procedure TApp.BoundParam;
var Dlg:PBoundDlgBox;
    C:word;
begin
    Dlg:=New(PBoundDlgBox,Init);
     Dlg^.SetData(BoundRec);
     C:=DeskTop^.ExecView(Dlg);
     If C <> cmCancel Then begin Dlg^.GetData(BoundRec);ABound^.NewParam;end;
     Dispose(Dlg,Done);
end;
Procedure TApp.Begining;
begin
 ABound^.CurrN:=1;
 ABound^.Run(0);
end;
Procedure TApp.GoNext;
begin
  ABound^.Run(1);
end;
Procedure TApp.HandleEvent(var Event:TEvent);
var a,b:string[10];
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
      cmDelVector : DelVector;
      cmDelAllVector : DelAllVector;
      cmGraphParam : GraphParam;
      cmServiseVector : ServiseVector;
      cmViewVector : ViewVector;
      cmInsertVector : InsertVector;
      cmEditVecAttr : EditVecAttr;
      cmViewDecVector : ViewDecVector;
      cmBoundParam : BoundParam;
      cmBegining : Begining;{begin ABound^.CurrN:=1;ABound^.Run(0);end;}
      cmGoNext : GoNext;{begin ABound^.Run(1);end;}
      cmRezult : begin
                 a:=RealStr(ABound^.F_tr);
                 b:=RealStr(ABound^.C_tr);
                 MessageBox(^C'Результаты вичислений:'
                            +^M^C'Сила трения: '+a
                            +^M^C'Коэфф. силы трения: '+b,
                            nil,mfInformation or mfOkButton);
                 end;
      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
destructor TApp.Done;
begin
  If IsItGr Then DoneGraph;
  Dispose(Graphic,Done);
  Dispose(ABound,Done);
  inherited Done;
end;
procedure TApp.Idle;
begin
  inherited idle;
  Heap^.Update;
{  Clock^.UpDate;}
end;
begin
end.
