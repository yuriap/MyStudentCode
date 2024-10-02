{***********************************************}
{**  Сумский государственный университет      **}
{**  Кафедра гидромашин                       **}
{**  Лаборатория ветроэнергетики              **}
{***********************************************}
{**  Программа расчета параметров 	      **}
{**  стационарного ламинарного пограничного   **}
{**  слоя                                     **}
{***********************************************}
{** Copyright (c) Педан Ю.А.     19.07.95     **}
{***********************************************}
Unit BBoundT;
Interface
uses Objects,Views,Memory,Drivers,App,Dialogs,MsgBox,
      Graph,Dos,Crt,
     BGraphic;
const
    DimHor = 100;
    DimVert = 40;

    FileGrUsl:PathStr='Fi&FiBlz.dat';{ресурс с таблицами функций фи и фи_штрих
                                  по Б.-Н.}
    EttaDelta=2.4;{коеффициент для задания граничного условия (см Б.-Н.)}
    Top:boolean=true;{граница П.С.}
    Bottom:boolean=false;{поверхность}
var
{  Left:L;
  Right,Incp:R;}
  ParW:real;
type
  TBoundRec = record
  Nu,{вязкость [м^2/c]}
  U0,{скорость потока [м/c]}
  L ,{длина пластины [м]}
  Ro,{плотнщсть жидкости [кг/м^3]}

  X0,{коеффициент для задания граничного условия (см Б.-Н. "а")}
  Psi,{малое положительное число для dU/dy при y=delta <= Psi}
  S,{параметр усреднения}
  M,{размерность матрицы сетки по " нормали" к пластине (0..M)}
  N,{размерность матрицы сетки по "касательной" к пластине(0..N)}
  MaxIter{максимальное число итераций}  :string[7];

  IfView:word;
  ParW:string[7];
  parNevazka:String[7];{величина невязки}
  end;
var
   BoundRec:TBoundRec;

type
    TMainSetka = array [0..DimVert,0..DimHor] of real;
    TComplSetka = TMainSetka;
    TDelta = array [0..DimHor] of real;
    TABCoeff = array [0..DimVert] of real;

    PBoundLayer = ^TBoundLayer;
    TBoundLayer = object(TObject)
       Nu:real;{вязкость}
       U0:real;{скорость потока}
       L :real;{длина пластины}
       Ro:real;{плотнщсть жидкости}
       Re:real;{число Рейнольдса}
       X0:real;{коеффициент для задания граничного условия (см Б.-Н. "а")}
       Psi:real;{малое положительное число для dU/dy при y=delta <= Psi}
       S:real;{параметр усреднения}
       M:word;{размерность матрицы сетки по " нормали" к пластине (0..M)}
       N:word;{размерность матрицы сетки по "касательной" к пластине(0..N)}
       dDelta:real;{начальное приращение толщины П.С.}
       cDelta:real;{текущее приращение толщины П.С.}
       dEtta:real;{шаг сетки по нормали}
       dDzetta:real;{шаг сетки вдоль поверхности}
       Iteration:word;{счетчик итераций}
       MaxIter:word;{максимальное число итераций}
       parNevazka:real;{величина невязки}
       CurrN,CurrM:integer;{счетчики текущих нормали и слоя соответственно}
       MainSetka:TMainSetka;{основная сетка}
       ComplementSetka:TComplSetka;{вспомогательная сетка}
       Delta:TDelta;{толщина П.С. вдоль поверхности}
       A,B:TABCoeff;{массивы прогоночных коэффициентов}
       Fi,FiStrih:TABCoeff;
       Tay:TDelta;{касательные напряжения на поверхности}
       C_m:TDelta;{коеффициент трения}
       F_tr,C_tr:real;{сила трения и ее коэфф.}
       constructor Init;
       procedure PutParam;
       Procedure NewParam;
       procedure Run(Plase:Word);{расчет П.С.}
       {назначает начальные значения парам. в неизвестных узлах}
       procedure PutFirstValue;
       procedure GoingForU;{прогонка по узлам основной сетки}
       procedure GoingForV;{прогонка по узлам вспомогательной сетки}
       procedure StoreNormal;{запоминает предыдущий результат}
       function GetNevazkaForU:real;{вычисление невязки}
       {вычисление прогоночных коэффициентов для текущей нормали}
       procedure GetAB;
       {коэфф. в формулах прогоночных коэфф.}
       procedure Alfa_Tetta(var Alf,Be,Ga,Te:real);
       {коэфф. для предыдущих функций, по Б.-Н. a,b,c,d}
       procedure AmBmCmDm(var Aa,Bb,Cc,Dd:real);
       {производная продолной скорости по нормали True - на границе(Top)}
       { False - на поверхности (Bottom)}
       function Diff(TopOrBottom:Boolean):real;
       procedure GetTay;{выч. касательного напряжения на поверхности}
       procedure GetC_m;{коэффициент трения}
       procedure GetF_tr;{сила трения}
       procedure GetC_tr;{кэфф. силы трения}
       destructor Done;virtual;
       private
       Last:real;{предыдущее значение для выч. невязки}
       end;

       PBoundDlgBox = ^TBoundDlgBox;
       TBoundDlgBox = object(TDialog)
          constructor Init;
          end;
function Sign(Numer:real):shortint;
var      ABound:PBoundLayer;
Implementation
Uses Blaz001;

function Sign(Numer:real):shortint;
{знак числа}
begin
  If Numer > 0.00000000001 Then Begin Sign:=1;Exit;end;
  If Numer < -0.00000000001 Then Begin Sign:=-1;Exit;end;
  If Numer = 0.0 Then Begin Sign:=0;Exit;end;
end;
constructor TBoundLayer.Init;
var
   i:word;
   x:real;
   z:integer;
   DataFile : text;
begin
  inherited Init;
  {загрузка таблиц функций фи и фи_штрих(создание их см. MkBound.pas)}
 Assign(DataFile,FileGrUsl);
 Reset(DataFile);
  for i:= 0 to DimVert do begin
    read(DataFile,FiStrih[i]);
    readln(DataFile,Fi[i]);
    end;
 Close(DataFile);
 PutParam;
end;{TBoundLayer.Init}
procedure TBoundLayer.PutParam;
var i,z:integer;
  begin
  {инциализация полей}
  Val(BoundRec.Nu,Nu,z);{вязкость [м^2/c]}
  Val(BoundRec.U0,U0,z);{скорость потока [м/c]}
  Val(BoundRec.L,L,z);{длина пластины [м]}
  Val(BoundRec.Ro,Ro,z);{плотнщсть жидкости [кг/м^3]}

  Val(BoundRec.X0,X0,z);{X0 в % от dDzetta для
  задания граничного условия (см Б.-Н.стр 93)}
  Val(BoundRec.Psi,Psi,z);{малое положительное число для dU/dy при y=delta <= Psi}
  Val(BoundRec.S,S,z);{параметр усреднения}
  M:=DimVert;{размерность матрицы сетки по " нормали" к пластине (0..M)}
  N:=DimHor;{размерность матрицы сетки по "касательной" к пластине(0..N)}
  Val(BoundRec.MaxIter,MaxIter,z);{максимальное число итераций}
  Val(BoundRec.ParW,ParW,z);
  Val(BoundRec.parNevazka,parNevazka,z);{величина невязки}
  Re:=U0*L/Nu;{число Рейнольдса}
  dEtta:=1/(M);{шаг сетки по нормали}
  dDzetta:=1/(N);{шаг сетки вдоль поверхности}
  {инициализация вектора толшины П.С.}
{  al:=U0/(dDzetta*0.01*X0*L);{коэфф. 'a' по Б.-H.}
  Delta[0]:=7*Sqrt(X0/(N*100));{толщина П.С. в 1-й нормали}
  dDelta:=Delta[0]*0.05;{начальное приращение толщины П.С.}
  {иниц. основной сетки}
  {граничное условие - продольная скорость на границе сетки}
  For i:=0 to M do  MainSetka[i,0]:=FiStrih[i];
  {иниц. вспомогательной сетки}
  {граничное условие - поперечная скорость на границе сетки}
  For i:=0 to M do  ComplementSetka[i,0]:=Fi[i]*0.5*Sqrt(N*100/X0);
  {иниц. массивов прогоночных коэффициентов}
end;
procedure TBoundLayer.NewParam;
begin
  PutParam;
end;{TBoundLayer.NewParam}

destructor TBoundLayer.Done;
begin
  inherited Done;
end;
procedure TBoundLayer.Run(Plase:Word);
Label A1;
var af,bf:boolean;
    df:real;
    As:word;
    cDeltaOld:real;
    Criterium:string[17];
    PrChar:char;
      Vec:PZVector;
      i:word;
      r:real;
    EndProgon:boolean;
  procedure InstalValue(Vector:PZVector);
  begin
      If Iteration > MaxIter Then Vector^.Labels:='first'
         else Vector^.Labels:=IntToStr(CurrN)+'.'+IntToStr(Iteration);
         {RealToStr(Sign(cDelta));}
      Vector^.Color:=5;
      Vector^.Visible:=true;
  end;
begin
   PrChar:='-';
   repeat{цикл вычислений параметров в нормалях}
   PutFirstValue;{назначает начальные значения парам. в неизвестных узлах}
   {****************************************}
   If BoundRec.IfView = 0 then begin
     SetGraphMode(grMode);
    Iteration:=MaxIter+2;
    Vec:=New(PZVector,Init(DimVert+1));
    For i:=0 to DimVert do
      Vec^.Put(i,MainSetka[i,CurrN]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
    Graphic^.Execute;
    Graphic^.DelLastVector;
    Graphic^.StoreParam;end;
    {*******************************************}
   Iteration:=1;{счетчик итераций}
   cDelta:=dDelta;{Delta[CurrN]*0.01;{текущее приращение толщины П.С.}
   cDeltaOld:=cDelta;
   repeat{цикл итераций по толщине П.С.}
   {вычисляется толщина П.С. в текущей итерации}
   If BoundRec.IfView = 3 Then  Delta[CurrN]:=Delta[CurrN]
    else begin
   Delta[CurrN]:=Delta[CurrN]+cDelta;
   EndProgon:=false;
   repeat{нелинейная система и ее решение}
   StoreNormal;{запоминает предыдущий результат}
   GoingForU;{прогонка по узлам основной сетки}
   GoingForV;{прогонка по узлам вспомогательной сетки}
   If Abs(GetNevazkaForU) <= parNevazka Then EndProgon:=true;

   {****************************************}
    If BoundRec.IfView = 0 then begin
    Vec:=New(PZVector,Init(DimVert+1));
    For i:=0 to DimVert do
      Vec^.Put(i,MainSetka[i,CurrN]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
    Graphic^.Execute;
    Graphic^.DelLastVector;
    Graphic^.StoreParam;
    end;
    {*******************************************}

   until EndProgon;
   end;
   {проверка знака производной dU/dy при y = толщине П.С.}
   if (CurrN = 1) and (Iteration = 18) then
       begin
       Criterium:='9';
       end;
   cDelta:=-1*Abs(cDelta)*Sign(Diff(Top));
   If not(Sign(cDelta) = Sign(cDeltaOld)) then begin
     cDelta:=cDelta*0.75;
     end;
     cDeltaOld:=cDelta;

   Iteration:=Iteration+1;{приращение счетчика итераций}
   {проверка условия dU/dy при y=delta <= Psi}
   df:=Diff(Top);
   af:=(Iteration > MaxIter);
   bf:=((0 <= Abs(df)) and (Abs(df) <= Psi));
   MyApp^.Idle;
   until af or bf;
{****************************************}
     If BoundRec.IfView = 0 then begin
     RestoreCrtMode;
     DoneMemory;
     MyApp^.Redraw;
     ShowMouse;end;
{****************************************}
   If BoundRec.IfView < 2 then begin
   if af and not(bf) Then Criterium:='-конец итераций.';
   If bf and not(af) Then Criterium:='-производная '+IntToStr(Iteration);
   If bf and af Then Criterium:='- оба.';
   As:=MessageBox(^C'Номер текущей нормали: '+IntToStr(CurrN)
             +^M^C'Окончание: '+Criterium
             +^M^C'Продолжить дальше? Yes'
             +^M^C'Или приостановить? No'
               ,nil,mfInformation or mfYesButton or mfNoButton);

   case As of
     cmNo    : begin
               CurrN:=CurrN+1;
               IF CurrN > N Then Goto A1;
               Exit;
               end;
    end;end;
    If BoundRec.IfView >= 2 then begin
       case Ord(PrChar) of
         Ord('-') : PrChar:='\';
         Ord('\') : PrChar:='|';
         Ord('|') : PrChar:='/';
         Ord('/') : PrChar:='-';
         end;
       DeskTop^.WriteChar(38,10,PrChar,1,5);
       end;

   CurrN:=CurrN+1;
   until CurrN > N;
   GetTay;
   GetC_m;
   GetF_tr;
   GetC_tr;
A1:MessageBox(^C'Вычисления завершены',nil,mfInformation or mfOkButton);
end;{TBounLayer.Run}
function TBoundLayer.Diff(TopOrBottom:Boolean):real;
{производная dU/dy}
begin
  If TopOrBottom
    Then
      {на границе П.С.}
      Diff:=(MainSetka[M,CurrN]-MainSetka[M-1,CurrN])/(dEtta)
{      Diff:=((MainSetka[M,CurrN]-MainSetka[M-1,CurrN])
           +(MainSetka[M-1,CurrN]-MainSetka[M-2,CurrN]))
      /(2*dEtta)}
    Else
      {на поиерхности}
      Diff:=(MainSetka[1,CurrN]-MainSetka[0,CurrN])/dEtta;
end;{TBoundLayer.Diff}
procedure TBoundLayer.PutFirstValue;
var i:word;
begin
        Delta[CurrN]:=7*Sqrt(dDzetta*CurrN);
{        Delta[CurrN]:=Delta[CurrN-1]*1.2;}
   for i:=0 to M do begin
   {присвоение значений в неизвестной нормали из предыдущей}
    MainSetka[i,CurrN]:=MainSetka[i,CurrN-1];
    ComplementSetka[i,CurrN]:=ComplementSetka[i,CurrN-1];
   end;
end;{TBoundLaer.PutFirstValue}
procedure TBoundLayer.StoreNormal;
var i:integer;
begin
  Last:=0;
  For i:=0 to DimVert do Last:=Last+MainSetka[i,CurrN];
end;
function TBoundLayer.GetNevazkaForU:real;
var i:integer;
    This:real;
begin
  This:=0;
  For i:=0 to DimVert do This:=This+MainSetka[i,CurrN];
  GetNevazkaForU:=100*(1-This/Last);
end;

procedure TBoundLayer.GoingForU;{прогонка по узлам основной сетки}
var
  z:real;
  Alfa,Betta,Gamma,Tetta:real;
  i:integer;
begin
   {вычисляются прогоночные коэффициенты для текущей нормали}
   GetAB;
   CurrM:=M-1;{счетчик слоев}
   {скорость на границе потока равна ск. внешнего потока}
   MainSetka[M,CurrN]:=MainSetka[M,0];
   {цикл вычислений продольной скорости по рекурентной формуле (Б.-Н.)}
   repeat
   MainSetka[CurrM,CurrN]:=A[CurrM]*MainSetka[CurrM+1,CurrN]+B[CurrM];
   CurrM:=CurrM-1;
   until CurrM < 1;
{   CurrM:=1;
   repeat
   Alfa_Tetta(Alfa,Betta,Gamma,Tetta);
     Right[CurrM]:=Tetta;
     If CurrM = 1 Then begin
        Left[CurrM,CurrM]:=Betta;
        Left[CurrM,CurrM+1]:=Gamma;
        end;
     If (CurrM <> 1) and (CurrM <> M-1) then
     begin
        Left[CurrM,CurrM-1]:=Alfa;
        Left[CurrM,CurrM]:=Betta;
        Left[CurrM,CurrM+1]:=Gamma;
     end;
     If CurrM = M-1 Then begin
        Left[CurrM,CurrM-1]:=Alfa;
        Left[CurrM,CurrM]:=Betta;
        Right[CurrM]:=Right[CurrM]-Gamma;
        end;
   CurrM:=CurrM+1;
   until CurrM > M-1;
   Gauss(Left,Right,Incp,19);
   For i:=1 to 19 do MainSetka[i,CurrN]:=Incp[i];}
end;{TBounLaeyr.GoingForU}
procedure TBoundLayer.GoingForV;{прогонка по узлам вспомогательной сетки}
var
   a1,a2,b1,c,d,e,f:real;
begin
   CurrM:=1;{счетчик слоев}
   ComplementSetka[0,CurrN]:=0.0;{поперечная ск. равна 0 на поверхн.}
   {цикл вычислений пoперечной скорости по рекурентной формуле (Б.-Н.)}
   repeat
   a1:=Delta[CurrN];
   a2:=Delta[CurrN-1];
   b1:=MainSetka[CurrM,CurrN];
   c:=MainSetka[CurrM,CurrN-1];
   d:=MainSetka[CurrM-1,CurrN];
   e:=MainSetka[CurrM-1,CurrN-1];
   f:=ComplementSetka[CurrM-1,CurrN]+(dEtta*(a1+a2)/2)*
      (((a1-a2)*CurrM/(dDzetta*(a1+a2)))*(b1+c-d-e)-(d-e+b1-c)/(2*dDzetta));
   ComplementSetka[CurrM,CurrN]:=f;
   CurrM:=CurrM+1;
   until CurrM > M;
end;{GoingForV}
procedure TBoundLayer.GetAB;
{вычисление прогоночного коэффициента А для текущей нормали}
var D:real;
    Alfa,Betta,Gamma,Tetta:real;
begin
  CurrM:=1;{счетчик слоев}
  A[0]:=0.0;{установка значения Ао}
  B[0]:=0.0;{установка значения Bо}
  {цикл вычисления коэфф. Аm (по Б.-Н.)}
  repeat
  Alfa_Tetta(Alfa,Betta,Gamma,Tetta);
  D:=Alfa*A[CurrM-1]+Betta;
  A[CurrM]:=-1*(Gamma/D);
  B[CurrM]:=(Tetta-Alfa*B[CurrM-1])/D;
  CurrM:=CurrM+1;
  until CurrM > M-1;
end;{TBoundLayer.GetAB}
{коэфф. в формулах прогоночных коэфф.}
procedure TBoundLayer.Alfa_Tetta(var Alf,Be,Ga,Te:real);
var
  n1,n2,n3,iGa:real;
  Am,Bm,Cm,Dm:real;
begin
  AmBmCmDm(Am,Bm,Cm,Dm);
  if CurrM <> 1 then  Alf:=-1*(S/(2*dEtta))*(Bm+2*Cm/dEtta)
                else  Alf:=0.0;
{***********************************************************}
  Be:=(Am/dDzetta)+(S/(2*dEtta*dEtta))*4*Cm;
{***********************************************************}
  n1:=((1-S)/(2*dEtta))*(Bm+2*Cm/dEtta)*MainSetka[CurrM-1,CurrN-1];
  n2:=((Am/dDzetta)-((1-S)/(2*dEtta*dEtta))*4*Cm)*
         MainSetka[CurrM,CurrN-1];
  n3:=((1-S)/(2*dEtta))*(Bm-2*Cm/dEtta)*MainSetka[CurrM+1,CurrN-1];
{***********************************************************}
  If CurrM <> M-1 then begin
     Ga:=(S/(2*dEtta))*(Bm-2*Cm/dEtta);
     Te:=1*(n1+n2-n3+Dm);end
     else begin
     Ga:=(S/(2*dEtta))*(Bm-2*Cm/dEtta);
     Te:=1*(n1+n2-n3+Dm)-Ga;
     Ga:=0.0;
     end;
end;{TBoundLayer.Alfa_Tetta}
{коэфф. для предыдущих функций, по Б.-Н. a,b,c,d}
procedure TBoundLayer.AmBmCmDm(var Aa,Bb,Cc,Dd:real);
var x,y:real;
begin
   Aa:=0.5*(MainSetka[CurrM,CurrN]+MainSetka[CurrM,CurrN-1]);
{***********************************************************}
    x:=Delta[CurrN];
    y:=Delta[CurrN-1];
    Bb:=(2/(x+y))*(ComplementSetka[CurrM,CurrN]-
        Aa*dEtta*CurrM*((x-y)/dDzetta));
{***********************************************************}
   Cc:=4/Sqr(Delta[CurrN]+Delta[CurrN-1]);
{***********************************************************}
   {уточнить формулу!}
   Dd:=ParW*exp(-0.2*ln(CurrN));{;*Exp(-1*CurrN/50);}
end;{TBoundLayer.AmBmCmDm}
procedure TBoundLayer.GetTay;{выч. касательного напряжения на поверхности}
var
  Complex:real;
  i:integer;
  z:real;
begin
  If BoundRec.IfView = 3 Then Begin
  For i:=0 to DimHor do begin
  if i = 0 then Tay[i]:=0.332*Ro*Sqrt(Nu*U0*U0*U0/((X0/100)*dDzetta*L))
  else  Tay[i]:=0.332*Ro*Sqrt(Nu*U0*U0*U0/(dDzetta*i*L));
  end;end
  else begin
  Complex:=Ro*Sqrt(U0*U0*U0*Nu/L);
  For i:=0 to DimHor do begin
   z:=MainSetka[1,i]/(dEtta*Delta[i]);
   Tay[i]:=Complex*z;
   end;end;
end;{TBoundLayer.GetTay;}
procedure TBoundLayer.GetC_m;{коэффициент трения}
var i:integer;
begin
  For i:=0 to DimHor do
  C_m[i]:=(MainSetka[1,i]/(dEtta*Delta[i]))/Sqrt(Re);
end;{TBoundLayer.GetC_m}
procedure TBoundLayer.GetF_tr;{сила трения}
var
   Complex:real;
   Sum1,Sum2:real;
   i,mn:integer;
begin
  If BoundRec.IfView = 3 Then   F_tr:=1.328*Ro*Sqrt(Nu*U0*U0*U0*L)
  else begin
  Complex:=Ro*dDzetta*Sqrt(U0*U0*U0*L*Nu)/(dEtta*3);
  Sum1:=0.0;Sum2:=0.0;
  mn:=DimHor div 2;
  For i:=1 to mn-1 do begin
    Sum1:=Sum1+MainSetka[1,(2*i-1)]/Delta[2*i-1];
    Sum2:=Sum2+MainSetka[1,(2*i)]/Delta[2*i];
    end;
  F_tr:=2*Complex*(MainSetka[1,0]/Delta[0]+4*Sum1+2*Sum2+
        MainSetka[1,2*mn]/Delta[2*mn]);end;
end;{TBoundLayer.GetF_tr}
procedure TBoundLayer.GetC_tr;{кэфф. силы трения}
var
  Complex,Sum:real;
  i:integer;
   Sum1,Sum2:real;
   mn:integer;

begin
  If BoundRec.IfView = 3 Then C_tr:=1.328/Sqrt(Re)
  else begin
  Complex:=dDzetta/(dEtta*Sqrt(Re)*3);
  Sum1:=0.0;Sum2:=0.0;
  mn:=DimHor div 2;
    For i:=1 to mn-1 do begin
    Sum1:=Sum1+MainSetka[1,(2*i-1)]/Delta[2*i-1];
    Sum2:=Sum2+MainSetka[1,(2*i)]/Delta[2*i];
    end;
  C_tr:=2*Complex*(MainSetka[1,0]/Delta[0]+4*Sum1+2*Sum2+
        MainSetka[1,2*mn]/Delta[2*mn]);end;
end;{TBoundLayer.GetC_tr}
constructor TBoundDlgBox.Init;
var
    R:TRect;
   View:PView;
   Button:PView;
begin
   R.Assign(6,3,74,20);
   Inherited Init(R,'Параметры пограничного слоя');
    R.Assign(25,3,32,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,3,24,4);
    Insert(New(PLabel,Init(R,'~A~.Вязкость жидкости:',View)));

{*******************************************}
    R.Assign(25,4,32,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,4,24,5);
    Insert(New(PLabel,Init(R,'~B~.Скорость потока:',View)));

{*******************************************}
    R.Assign(25,5,32,6);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,5,24,6);
    Insert(New(PLabel,Init(R,'~C~.Длина пластины:',View)));

{*******************************************}
    R.Assign(25,6,32,7);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,6,24,7);
    Insert(New(PLabel,Init(R,'~D~.Плотность:',View)));

{*******************************************}
    R.Assign(25,7,32,8);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,7,24,8);
    Insert(New(PLabel,Init(R,'~E~.X0 в % от dDzetta:',View)));
{*******************************************}
    R.Assign(56,3,63,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,3,55,4);
    Insert(New(PLabel,Init(R,'~F~.Коэффициент Psi:',View)));

    R.Assign(56,4,63,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,4,55,5);
    Insert(New(PLabel,Init(R,'~G~.Параметр S:',View)));

    R.Assign(56,5,63,6);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,5,56,6);
    Insert(New(PLabel,Init(R,'~H~.Размерность сетки M:',View)));

    R.Assign(56,6,63,7);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,6,56,7);
    Insert(New(PLabel,Init(R,'~I~.Размерность сетки N:',View)));

    R.Assign(56,7,63,8);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,7,55,8);
    Insert(New(PLabel,Init(R,'~J~.MaxIter:',View)));

    R.Assign(36,9,60,11);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('Да ',
     NewSItem('Нет',
     NewSItem('Без',
     NewSItem('Точно',
     nil))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(39,8,49,9);
    Insert(New(PLabel,Init(R,'~K~.Просмотр',Button)));

{**************************************************}

      R.Assign(3,9,12,11);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(15,9,24,11);
      Insert(New(PButton,Init(R,'Ca~n~cel',cmCancel,bfNormal)));

    R.Assign(25,11,32,12);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,11,23,12);
    Insert(New(PLabel,Init(R,'~L~.Параметр W',View)));

    R.Assign(25,12,32,13);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,12,23,13);
    Insert(New(PLabel,Init(R,'~M~.Пар. невязки, % :',View)));

{**************************************************}
    SelectNext(false);
end;

begin
end.
{var
   ABound:PBoundLayer;
   Graphic:PZGraphic;
   Stream:PBufStream;
   Res:TResourceFile;

begin
  ABound:=New(PBoundLayer,Init);
  ABound^.Run;
{With Graphic^ do begin
  InsertVector(ABound^.Delta);
  StartGraph;
  Execute;
  Done;
  end;
  DoneGraph;

end.}
 { WriteLn('Ok пограничный слой');

  Stream:=New(PBufStream,Init(ResFName,stCreate,1024));
  Res.Init(Stream);
{  Res.Put(ABound^.MainSetka,'Main');
  Res.Put(ABound^.Complementtka,'Complement');}
 { Res.Put(ABound^.Delta,'Delta');
  Res.Done;
  WriteLn('Ok ресурс');
  Dispose(ABound,Done);
{  Dispose(Graphic,Done);}
{end.