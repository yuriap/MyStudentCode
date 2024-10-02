{***********************************************}
{**  Сумский государственный университет      **}
{**  Кафедра гидромашин                       **}
{**  Лаборатория ветроэнергетики              **}
{***********************************************}
{**  Подпрограмма расчета параметров          **}
{**  стационарного ламинарного пограничного   **}
{**  слоя                                     **}
{***********************************************}
{** Copyright (c) Педан Ю.А.     3.04.96      **}
{***********************************************}
Unit ProBound;
Interface
uses Objects,Dos,Crt,ProfDin,ProfComm;
const
    Top:boolean=true;{граница П.С.}
    Bottom:boolean=false;{поверхность}
type
  TBoundRec = record
  Nu,{вязкость [м^2/c]}
  U0,{скорость потока [м/c]}
  L ,{длина пластины [м]}
  Ro,{плотнщсть жидкости [кг/м^3]}

  X0,{коеффициент для задания граничного условия (см Б.-Н. "а")}
  Psi,{малое положительное число для dU/dy при y=delta <= Psi}
  S,{параметр усреднения}
  N,{размерность матрицы сетки по " нормали" к пластине (0..N)}
  M,{размерность матрицы сетки по "касательной" к пластине(0..M)}
  MaxIter{максимальное число итераций}  :string[7];
  IfView:word;
  ParW:string[7];
  parNevazka:String[7];{величина невязки}
  end;
  TBRec = record
  X0:real;{коеффициент для задания граничного условия (см Б.-Н. "а")}
  Psi:real;{малое положительное число для dU/dy при y=delta <= Psi}
  S:real;{параметр усреднения}
  N:integer;{размерность матрицы сетки по " нормали" к пластине (0..N)}
  M:integer;{размерность матрицы сетки по "касательной" к пластине(0..M)}
  MaxIter:integer;{максимальное число итераций}
  parNevazka:real;{величина невязки}
  end;
const
  {Флаги массива Options}
  psKritical = $0000;{критическая точка натекания потока}
  psPositive = $0001;{направление касательной скорости
  совпадает с нумерацией нормалей в сетке}
  psNegative = $0002;{направление касательной скорости
  не совпадает с нумерацией нормалей в сетке}
  psFirst = $0004;{первая нормаль рядом с критической точкой}
  psOk = $0008;{нормаль успешно просчитаная}
  psBreak = $0010;{нормаль в которой произошел отрыв ПС}
  {Маски массива Options}
  psFirstPositive = psFirst or psPositive;
  psFirstPositiveOk = psFirstPositive or psOk;
  psFirstNegative = psFirst or psNegative;
  psFirstNegativeOk = psFirstNegative or psOk;
  psPositiveOk = psPositive or psOk;
  psNegativeOk = psNegative or psOk;
type
    PBoundLayer = ^TBoundLayer;
    TBoundLayer = object(TObject)
       X0:real;{коеффициент для задания граничного условия (см Б.-Н. "а")}
       Psi:real;{малое положительное число для dU/dy при y=delta <= Psi}
       S:real;{параметр усреднения}
       N:word;{размерность матрицы сетки по " нормали" к пластине (0..N)}
       M:word;{размерность матрицы сетки по "касательной" к пластине(0..M)}
       dDelta:real;{начальное приращение толщины П.С.}
       cDelta:real;{текущее приращение толщины П.С.}
       dEtta:real;{шаг сетки по нормали}
       dDzetta:real;{шаг сетки вдоль поверхности}
       Iteration:word;{счетчик итераций}
       MaxIter:word;{максимальное число итераций}
       parNevazka:real;{величина невязки}
       CurrN,CurrM:integer;{счетчики текущих нормали и слоя соответственно}
       MainSetka:PMainSetka;{основная сетка}
       ComplementSetka:PCompSetka;{вспомогательная сетка}
       A,B:PVector;{массивы прогоночных коэффициентов}
       constructor Init(BRec:TBRec);
       procedure InstallSetka(Main:PMainSetka;Comp:PCompSetka);
       procedure Execute;
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
{       procedure GetTay;{выч. касательного напряжения на поверхности}
{       procedure GetC_m;{коэффициент трения}
{       procedure GetF_tr;{сила трения}
{       procedure GetC_tr;{кэфф. силы трения}
       procedure Monitor;
       destructor Done;virtual;
       private
       Last:real;{предыдущее значение для выч. невязки}
       end;
function Sign(Numer:real):shortint;
Implementation
uses TesBUnit;
function Sign(Numer:real):shortint;
{знак числа}
begin
  If Numer = 0.0 Then Sign:=0
   else sign:=Round(Numer/Abs(Numer));
end;
constructor TBoundLayer.Init(BRec:TBRec);
begin
  inherited Init;
  Psi:=BRec.Psi;{малое положительное число для dU/dy при y=delta <= Psi}
  S:=BRec.S;{параметр усреднения}
  MaxIter:=BRec.MaxIter;{максимальное число итераций}
  parNevazka:=BRec.parNevazka;{величина невязки}
end;{TBoundLayer.Init}
procedure TBoundLayer.InstallSetka(Main:PMainSetka;Comp:PCompSetka);
begin
  MainSetka:=Main;
  ComplementSetka:=Comp;
  N:=MainSetka^.EndV-1;{размерность матрицы сетки по " нормали" к пластине (0..N)}
  M:=MainSetka^.EndH;{размерность матрицы сетки по "касательной" к пластине(0..M)}
  dEtta:=1/N;{шаг сетки по нормали}
  dDzetta:=1/M;{шаг сетки вдоль поверхности}
  A:=New(PVector,Init(0,N));{массивы прогоночных коэффициентов}
  B:=New(PVector,Init(0,N));{массивы прогоночных коэффициентов}
  dDelta:=MainSetka^.Get(N+1,0)*0.5;{начальное приращение толщины П.С.}
end;
destructor TBoundLayer.Done;
begin
  {удаление динамических объектов}
  Dispose(A,Done);{массивы прогоночных коэффициентов}
  Dispose(B,Done);
  {************************************}
  inherited Done;
end;
procedure TBoundLayer.Execute;
var af,bf:boolean;
    df:real;
    cDeltaOld:real;
    EndProgon:boolean;
    Buf:PBuffer;
    Nev:integer;
begin
   ClrScr;
   Writeln('Please, wait some time...');
   CurrN:=1;
   repeat{цикл вычислений параметров в нормалях}
   PutFirstValue;{назначает начальные значения парам. в неизвестных узлах}
   Iteration:=1;{счетчик итераций}
   cDelta:=dDelta;{Delta^.Get(CurrN-1)*0.05;{текущее приращение толщины П.С.}
   cDeltaOld:=cDelta;
   repeat{цикл итераций по толщине П.С.}
   {вычисляется толщина П.С. в текущей итерации}
   MainSetka^.Put(N+1,CurrN,MainSetka^.Get(N+1,CurrN)+cDelta);
   EndProgon:=false;
   Nev:=0;
   repeat{нелинейная система и ее решение}
   StoreNormal;{запоминает предыдущий результат}
   GoingForU;{прогонка по узлам основной сетки}
   GoingForV;{прогонка по узлам вспомогательной сетки}
   If Abs(GetNevazkaForU) <= parNevazka Then EndProgon:=true;
   Inc(Nev);
   until EndProgon or (Nev > 20);
   If Nev > 20 Then begin
          Writeln;
          Writeln('BreakFree the Boundary Layer!');
          readln;
          Exit;end;
   {проверка знака производной dU/dy при y = толщине П.С.}
   cDelta:=Abs(cDelta)*Sign(Diff(Top));
   If not(Sign(cDelta) = Sign(cDeltaOld)) then begin
     cDelta:=cDelta*0.75;
     end;
     cDeltaOld:=cDelta;
   {****************************************}
   Iteration:=Iteration+1;{приращение счетчика итераций}
   {проверка условия dU/dy при y=delta <= Psi}
   df:=Diff(Top);
   af:=(Iteration > MaxIter);
   bf:=((0 <= Abs(df)) and (Abs(df) <= Psi));
   GotoXY(1,2);
   Write('Processe: iteration: ',Iteration,'; Normal: ',CurrN,'  ');
   if KeyPressed then begin
     Writeln;
     Writeln('Program terminated');
     Exit;
     end;
   until af or bf;
   CurrN:=CurrN+1;
   if CurrN = M then
     begin
      Beep;
     end;
   until CurrN > M;
   Writeln;
   Writeln('Ok digital Boundary Layer');
   readln
end;{TBounLayer.Execute}
function TBoundLayer.Diff(TopOrBottom:Boolean):real;
{производная dU/dy}
var x:real;
begin
  If TopOrBottom
    Then
      {на границе П.С.}
      x:=(MainSetka^.Get(N,CurrN)-MainSetka^.Get(N-1,CurrN))/dEtta
    Else
      {на поиерхности}
      x:=(MainSetka^.Get(1,CurrN)-MainSetka^.Get(0,CurrN))/dEtta;
    Diff:=x;
end;{TBoundLayer.Diff}
procedure TBoundLayer.PutFirstValue;
var i:word;
    y:real;
begin
   y:=MainSetka^.Get(N+1,CurrN-1);
   MainSetka^.Put(N+1,CurrN,y);
   {присвоение значений в неизвестной нормали из предыдущей}
   for i:=0 to N-1 do begin
   {нормаль основной сетки, все элементы за исключением последнего
    который является граничным условием (скорость на границе ПС)}
    y:=MainSetka^.Get(i,CurrN-1);
    MainSetka^.Put(i,CurrN,y);end;
   For i:=0 to N do begin
   {нормаль вспомогательной сетки, все элементы}
    y:=ComplementSetka^.Get(i,CurrN-1);
    ComplementSetka^.Put(i,CurrN,y);end;
end;{TBoundLaer.PutFirstValue}
procedure TBoundLayer.StoreNormal;
var i:integer;
begin
  Last:=0;
  For i:=0 to MainSetka^.N-1 do Last:=Last+MainSetka^.Get(i,CurrN);
end;
function TBoundLayer.GetNevazkaForU:real;
var i:integer;
    This:real;
begin
  This:=0;
  For i:=0 to MainSetka^.N-1 do This:=This+MainSetka^.Get(i,CurrN);
  GetNevazkaForU:=100*(1-This/Last);
end;

procedure TBoundLayer.GoingForU;{прогонка по узлам основной сетки}
var
  z,z1:real;
  Alfa,Betta,Gamma,Tetta:real;
  i:integer;
begin
   {вычисляются прогоночные коэффициенты для текущей нормали}
   GetAB;
   CurrM:=N-1;{счетчик слоев}
   {цикл вычислений продольной скорости по рекурентной формуле (Б.-Н.)}
   repeat
   z1:=MainSetka^.Get(CurrM+1,CurrN);
   z:=A^.Get(CurrM)*z1+B^.Get(CurrM);
   MainSetka^.Put(CurrM,CurrN,z);
   CurrM:=CurrM-1;
   until CurrM < 0;
end;{TBounLaeyr.GoingForU}
procedure TBoundLayer.GoingForV;{прогонка по узлам вспомогательной сетки}
var
   a1,a2,b1,c,d,e,f:real;
begin
   CurrM:=1;{счетчик слоев}
   ComplementSetka^.Put(0,CurrN,0.0);{поперечная ск. равна 0 на поверхн.}
   {цикл вычислений пoперечной скорости по рекурентной формуле (Б.-Н.)}
   repeat
   a1:=MainSetka^.Get(N+1,CurrN);
   a2:=MainSetka^.Get(N+1,CurrN-1);
   b1:=MainSetka^.Get(CurrM,CurrN);
   c:=MainSetka^.Get(CurrM,CurrN-1);
   d:=MainSetka^.Get(CurrM-1,CurrN);
   e:=MainSetka^.Get(CurrM-1,CurrN-1);
   f:=ComplementSetka^.Get(CurrM-1,CurrN)+(dEtta*(a1+a2)/2)*
      (((a1-a2)*CurrM/(dDzetta*(a1+a2)))*(b1+c-d-e)-(d-e+b1-c)/(2*dDzetta));
   ComplementSetka^.Put(CurrM,CurrN,f);
   CurrM:=CurrM+1;
   until CurrM > N;
end;{GoingForV}
procedure TBoundLayer.GetAB;
{вычисление прогоночного коэффициента А для текущей нормали}
var D:real;
    Alfa,Betta,Gamma,Tetta:real;
begin
  CurrM:=1;{счетчик слоев}
  A^.Put(0,0.0);{установка значения Ао}
  B^.Put(0,0.0);{установка значения Bо}
  {цикл вычисления коэфф. Аm (по Б.-Н.)}
  repeat
  Alfa_Tetta(Alfa,Betta,Gamma,Tetta);
  D:=Alfa*A^.Get(CurrM-1)+Betta;
  A^.Put(CurrM,-1*(Gamma/D));
  B^.Put(CurrM,(Tetta-Alfa*B^.Get(CurrM-1))/D);
  CurrM:=CurrM+1;
  until CurrM > N-1;
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
  n1:=((1-S)/(2*dEtta))*(Bm+2*Cm/dEtta)*MainSetka^.Get(CurrM-1,CurrN-1);
  n2:=((Am/dDzetta)-((1-S)/(2*dEtta*dEtta))*4*Cm)*
         MainSetka^.Get(CurrM,CurrN-1);
  n3:=((1-S)/(2*dEtta))*(Bm-2*Cm/dEtta)*MainSetka^.Get(CurrM+1,CurrN-1);
{***********************************************************}
  If CurrM <> N-1 then begin
     Ga:=(S/(2*dEtta))*(Bm-2*Cm/dEtta);
     Te:=n1+n2-n3+Dm;end
     else begin
     Ga:=(S/(2*dEtta))*(Bm-2*Cm/dEtta);
     Te:=n1+n2-n3+Dm-Ga*MainSetka^.Get(N,CurrN);
     Ga:=0.0;
     end;
end;{TBoundLayer.Alfa_Tetta}
{коэфф. для предыдущих функций, по Б.-Н. a,b,c,d}
procedure TBoundLayer.AmBmCmDm(var Aa,Bb,Cc,Dd:real);
var x,y:real;
begin
   Aa:=0.5*(MainSetka^.Get(CurrM,CurrN)+MainSetka^.Get(CurrM,CurrN-1));
{***********************************************************}
    x:=MainSetka^.Get(N+1,CurrN);
    y:=MainSetka^.Get(N+1,CurrN-1);
    Bb:=(2/(x+y))*(ComplementSetka^.Get(CurrM,CurrN)-
        Aa*dEtta*CurrM*((x-y)/dDzetta));
{***********************************************************}
   Cc:=4/Sqr(MainSetka^.Get(N+1,CurrN)+MainSetka^.Get(N+1,CurrN-1));
{***********************************************************}
   x:=MainSetka^.Get(N,CurrN);
   y:=MainSetka^.Get(N,CurrN-1);
   Dd:=0.5*(x+y)*(x-y)/dDzetta;

end;{TBoundLayer.AmBmCmDm}
{procedure TBoundLayer.GetTay;{выч. касательного напряжения на поверхности}
{var
  Complex:real;
  i:integer;
begin
  Complex:=Ro*Sqrt(U0*U0*U0*Nu/L);
  For i:=0 to DimHor do begin
   Tay[i]:=Complex*MainSetka^.Get(1,i)/(dEtta*Delta^.Get(i));
   end;
end;{TBoundLayer.GetTay;}
{procedure TBoundLayer.GetC_m;{коэффициент трения}
{var i:integer;
begin
  For i:=0 to DimHor do
  C_m[i]:=(MainSetka[1,i]/(dEtta*Delta[i]))/Sqrt(Re);
end;{TBoundLayer.GetC_m}
{procedure TBoundLayer.GetF_tr;{сила трения}
{var
   Complex:real;
   Sum:real;
   i:integer;
begin
  Complex:=Ro*dDzetta*Sqrt(U0*U0*U0*L*Nu);
  Sum:=0.0;
  For i:=0 to DimHor-1 do begin
    Sum:=Sum+MainSetka[1,i]/(dEtta*Delta[i])
            +MainSetka[1,i+1]/(dEtta*Delta[i+1]);
    end;
  F_tr:=Complex*Sum;
end;{TBoundLayer.GetF_tr}
{procedure TBoundLayer.GetC_tr;{кэфф. силы трения}
{var
  Sum:real;
  i:integer;
begin
  Sum:=0.0;
  For i:=0 to DimHor-1 do begin
    Sum:=Sum+MainSetka[1,i]/(dEtta*Delta[i])
            +MainSetka[1,i+1]/(dEtta*Delta[i+1]);
    end;
  C_tr:=dDzetta*Sum/Sqrt(Re);
end;{TBoundLayer.GetC_tr}
begin
end.
