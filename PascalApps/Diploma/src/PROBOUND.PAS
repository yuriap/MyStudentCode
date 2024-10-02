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
uses Objects,ProfDin,ProfComm,Profile,Views,Drivers,Crt;
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
  PBRec = ^TBRec;
  TBRec = record
  Psi:real;{малое положительное число для dU/dy при y=delta <= Psi}
  S:real;{параметр усреднения}
  MaxIter:integer;{максимальное число итераций}
  parNevazka:real;{величина невязки}
  MaxNevazka:integer;{максимальное колличество итераций по невязке}
  Option:word;
  Prec:real;{точность определения начала изгиба эпюры}
  Sloy:real;{коллич. слоев от верхнего края в которых допускается
  безизгибная эпюра продольной скорости}
  end;
const
  {Флаги массива Options}
  psNoFlag = $0000;
  psKritical = $0080;{критическая точка натекания потока}
  psKriticalStec = $0040;{критическая точка стекания потока}
  psPositive = $0001;{направление касательной скорости
  совпадает с нумерацией нормалей в сетке}
  psNegative = $0002;{направление касательной скорости
  не совпадает с нумерацией нормалей в сетке}
  psFirst = $0004;{первая нормаль рядом с критической точкой}
  psOk = $0008;{нормаль успешно просчитаная}
  psBreak = $0010;{нормаль в которой произошел отрыв ПС}
  psCorrectDelta = $0020;{корректировка толщины ПС в сторону уменьшения}
  psBackBound = $0100;{флаг задней кромки}
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
       Option:word;
       Psi:real;{малое положительное число для dU/dy при y=delta <= Psi}
       S:real;{параметр усреднения}
       N:word;{размерность матрицы сетки по " нормали" к пластине (0..N)}
       M:word;{размерность матрицы сетки по "касательной" к пластине(0..M)}
       dDelta:real;{начальное приращение толщины П.С.}
       cDelta:real;{текущее приращение толщины П.С.}
       cDeltaOld:real;{предыдущее приращение толщины ПС}
       dEtta:real;{шаг сетки по нормали}
       dDzetta:real;{шаг сетки вдоль поверхности}
       MaxIter:word;{максимальное число итераций}
       Iteration:integer;
       parNevazka:real;{величина невязки}
       MaxNevazka:integer;{максимальное колличество итераций по невязке}
       CurrN,LastN,CurrM:integer;{счетчики текущих нормали и слоя соответственно}
       Prec:real;{точность определения начала изгиба эпюры}
       Sloy:real;{коллич. слоев от верхнего края в которых допускается
       безизгибная эпюра продольной скорости}
       MainSetka:PMainSetka;{основная сетка}
       ComplementSetka:PCompSetka;{вспомогательная сетка}
       ProfilePtr:PProfile;{текущий профиль}
       A,B:PVector;{массивы прогоночных коэффициентов}
       constructor Init(BRec:TBRec);
       constructor Load(var SS:TStream);
       procedure Store(var SS:TStream);
       procedure InstallProfile(P:PProfile);
{       procedure InstallSetka(Main:PMainSetka;Comp:PCompSetka);}
       procedure Execute;
       procedure DigitNormal(var IterPar,NevPar,DiffPar,EpuraPar:boolean);
       {назначает начальные значения парам. в неизвестных узлах}
       procedure PutFirstValue;
       procedure GoingForU;{прогонка по узлам основной сетки}
       procedure GoingForV;{прогонка по узлам вспомогательной сетки}
       procedure StoreNormal;{запоминает предыдущий результат}
       function GetNevazkaForU:real;{вычисление невязки}
       {коррект. толщину ПС по эпюре скоростей}
       procedure CorrectDelta(var Criterium:boolean);
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
       procedure Analizator;{устанавливает флаги}
       function Monitor:boolean;{определяет нормаль начала расчета}
       procedure PutBoundaryValue;{устанавливает начальные эпюры скоростей}
       procedure RestoreU;{восст. знаки у скоростей там где они были '-'}
       procedure GetSuccNormal(var ST:boolean);
       procedure PutFlag(Normal:integer;Flag:word);
       procedure GetOptions(Normal:integer;var Options:word);
       procedure PutFreeCyclon;
       procedure MakeFreeCyclon(Normal:integer);
       function Diff_U(i,j:integer):real;
       function Diff_V(i,j:integer):real;
       function Vitesnenie(Normal:integer):real;
       function IntensivFreeCyclon(Normal:Integer):real;
       destructor Done;virtual;
       private
       Last:real;{предыдущее значение для выч. невязки}
       end;
const
   RBoundLayer : TStreamRec = (
      ObjType : idBoundLayer;
      VmtLink: Ofs(TypeOf(TBoundLayer)^);
      Load:@TBoundLayer.Load;
      Store:@TBoundLayer.Store);
procedure RegisterBoundLayer;
function Sign(Numer:real):shortint;
Implementation
uses ProfMain,TVRUnit,TVRComm;
procedure RegisterBoundLayer;
begin
  RegisterType(RBoundLayer);
end;
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
  MaxNevazka:=BRec.MaxNevazka;
  Prec:=BRec.Prec;
  Sloy:=BRec.Sloy;
  Option:=BRec.Option;
end;{TBoundLayer.Init}
constructor TBoundLayer.Load;
begin
  SS.Read(Option,SizeOf(Option));
  SS.Read(Psi,SizeOf(Psi));
  SS.Read(S,SizeOf(S));
  SS.Read(MaxIter,SizeOf(MaxIter));
  SS.Read(parNevazka,SizeOf(parNevazka));
  SS.Read(MaxNevazka,SizeOf(MaxNevazka));
  SS.Read(Prec,SizeOf(Prec));
  SS.Read(Sloy,SizeOf(Sloy));
end;
procedure TBoundLayer.Store;
begin
  SS.Write(Option,SizeOf(Option));
  SS.Write(Psi,SizeOf(Psi));
  SS.Write(S,SizeOf(S));
  SS.Write(MaxIter,SizeOf(MaxIter));
  SS.Write(parNevazka,SizeOf(parNevazka));
  SS.Write(MaxNevazka,SizeOf(MaxNevazka));
  SS.Write(Prec,SizeOf(Prec));
  SS.Write(Sloy,SizeOf(Sloy));
end;

procedure TBoundLayer.InstallProfile(P:PProfile);
{procedure TBoundLayer.InstallSetka(Main:PMainSetka;Comp:PCompSetka);}
var F:PFunction;
    i:integer;
begin
  ProfilePtr:=P;
  ProfilePtr^.GetReynolds;
  MainSetka:=P^.Main;
  ComplementSetka:=P^.Comp;
  N:=MainSetka^.EndV-1;{размерность матрицы сетки по " нормали" к пластине (0..N)}
  M:=MainSetka^.EndH;{размерность матрицы сетки по "касательной" к пластине(0..M)}
  dEtta:=1/N;{шаг сетки по нормали}
  dDzetta:=1/M;{шаг сетки вдоль поверхности}
  A:=New(PVector,Init(0,N));{массивы прогоночных коэффициентов}
  B:=New(PVector,Init(0,N));{массивы прогоночных коэффициентов}
  {Установка граничного условия}
  F:=ProfilePtr^.GetW;{таблица с расперделением касательной скорости}
  For i:=0 to M do MainSetka^.Put(N,i,F^.Get_Y_X(MainSetka^.Get_S(i)));
  Dispose(F,Done);
end;
destructor TBoundLayer.Done;
begin
  {удаление динамических объектов}
{  Dispose(A,Done);
  Dispose(B,Done);
  {************************************}
  inherited Done;
end;
function TBoundLayer.Monitor:boolean;
var Opt:word;
    i:integer;
    Search:boolean;
begin
  For i:=0 to M do begin
   GetOptions(i,Opt);
   if (Opt and psFirst = psFirst) and not(Opt and psOk = psOk)
          then begin
          Search:=true;
          break;end
       else Search:=false;
   end;
  If Search then begin
     if (Opt and psPositive = psPositive) then begin
        if i <> M then begin
           CurrN:=i+1;
           LastN:=i;end
           else begin
           CurrN:=0;
           LastN:=i;end
        end;
     if (Opt and psNegative = psNegative) then begin
        if i <> 0 then begin
           CurrN:=i-1;
           LastN:=i;end
           else begin
           CurrN:=M;
           LastN:=i;end
        end;
     PutFlag(i,psOk);end;
   Monitor:=Search;
{  CurrN:=1;
  CurrM:=0;}
end;
procedure TBoundLayer.PutFlag(Normal:integer;Flag:word);
begin
  MainSetka^.Options^.Put(Normal,MainSetka^.Options^.Get(Normal) or
    Flag);
end;
procedure TBoundLayer.GetOptions(Normal:integer;var Options:word);
begin
  Options:=MainSetka^.Options^.Get(Normal);
end;
procedure TBoundLayer.GetSuccNormal(var ST:boolean);
var Opt:word;
begin
   GetOptions(CurrN,Opt);
   if (Opt and psPositive = psPositive) and
        not((Opt and psKriticalStec = psKriticalStec)
        or (Opt and psBackBound = psBackBound))then begin
      Inc(CurrN);
      If CurrN > M then CurrN:=0;
      Inc(LastN);
      If LastN > M then LastN:=0;
      ST:=false;
      exit;
      end;
   if (Opt and psNegative = psNegative) and
        not((Opt and psKriticalStec = psKriticalStec)
        and (Opt and psBackBound = psBackBound))then begin
      Dec(CurrN);
      If CurrN < 0 then CurrN:=M;
      Dec(LastN);
      If LastN < 0 then LastN:=M;
      ST:=false;
      exit;
      end;
   if (Opt and psKriticalStec) = psKriticalStec then begin
     if (Opt and psPositive) = psPositive then begin
           If CurrN > 0 Then PutFlag(CurrN-1,psBreak)
               else PutFlag(M,psBreak)end;
     if (Opt and psNegative) = psNegative then begin
           If CurrN < M Then PutFlag(CurrN+1,psBreak)
               else PutFlag(0,psBreak)end;end;
   St:=true;
{   Inc(CurrN);
   Inc(LastN);
   if CurrN > M Then St:=true else St:=false;}
end;
procedure TBoundLayer.Analizator;
{Устанавливает флаги в соотв. с касательной скоростью}
var
   i,Pr,Mid,Suc:integer;
   a1,a2,a3:real;
begin
 For i:=0 to M do MainSetka^.Options^.Put(i,psNoFlag);
 {поиск критических точек}
 i:=0;
 repeat
  {выборка трех соседних нормалей}
  if i-1 < 0 then Pr:=M else Pr:=i-1;
  Mid:=i;
  if i+1 > M then Suc:=0 else Suc:=i+1;
  a1:=MainSetka^.Get(N,Pr);
  a2:=MainSetka^.Get(N,Mid);
  a3:=MainSetka^.Get(N,Suc);
  {анализ скоростей в оных}
  If (Sign(a1) < Sign(a2)) and
     ((Sign(a2) <> 0) and (Sign(a1) <> 0)) then
    begin
      PutFlag(Pr,psFirst);
      PutFlag(Mid,psFirst);
    end;
   If (Sign(a1) > Sign(a2)) and
      ((Sign(a2) <> 0) and (Sign(a1) <> 0)) then
      begin
      PutFlag(Pr,psKriticalStec);
      PutFlag(Mid,psKriticalStec);
      end;
  If (Sign(a2) = 0) then begin
    if (Sign(a1) < Sign(a3)) then begin
        PutFlag(Pr,psFirst);
        PutFlag(Mid,psKritical);
        PutFlag(Suc,psFirst);
        end
        else PutFlag(Mid,psKriticalStec);end;
  Inc(i);
 until i > M;
  {Установка направлений скоростей}
  for i:=0 to M do begin
    if Sign(MainSetka^.Get(N,i)) > 0 then PutFlag(i,psPositive);
    if Sign(MainSetka^.Get(N,i)) < 0 then PutFlag(i,psNegative);
    end;
end;
procedure TBoundLayer.PutBoundaryValue;
  procedure GetGrUslBelo(var MainUsl,CompUsl:PFunction);
  var
   S:PBufStream;
   F:TResourceFile;
  begin
   S:=New(PBufStream,Init(Tablice,stOpenRead,2048));
   F.Init(S);
   MainUsl:=PFunction(F.Get(BValueMain));
   CompUsl:=PFunction(F.Get(BValueComp));
   F.Done;
  end;{GetGrUslBelo}
var
  MainF,CompF:PFunction;
  Opt:Word;
  dS,dx:real;
  C,i,j:integer;
  aa,t,x,y:real;
begin
  GetGrUslBelo(MainF,CompF);
  dx:=1/N;
  for j:=0 to M do begin
  MainSetka^.Put(N+1,j,0);
  MainSetka^.Put(N,j,Abs(MainSetka^.Get(N,j)));
  GetOptions(j,Opt);
  if (Opt and psFirst) = psFirst then begin
        dS:=Abs(MainSetka^.Get_S(2)-MainSetka^.Get_S(1));
        t:=MainSetka^.Get(N,j);
        aa:=Sqrt(Abs(t/dS));
        x:=0;
        For i:=0 to N-1 do begin
            MainSetka^.Put(i,j,MainF^.Get_Y_X(x)*MainSetka^.Get(N,j));
            x:=x+dx;
            end;
        x:=0;
        For i:=0 to N do begin
            ComplementSetka^.Put(i,j,CompF^.Get_Y_X(x)*aa*(-1));
            x:=x+dx;
            end;
        y:=EttaDelta/aa;
        MainSetka^.Put(N+1,j,y);
        {начальное приращение толщины П.С.}
        dDelta:=MainSetka^.Get(N+1,j)*0.1;
        end;{if}
    end;{for}
  Dispose(MainF,Done);
  Dispose(CompF,Done);
  {*********************************************************}
end;{TBoundLayer.PutBoundaryValue;}
procedure TBoundLayer.RestoreU;
{восст. знаки у скоростей там где они были '-'}
var Opt:word;
    i,j:integer;
begin
  For i:=0 to M do begin
   GetOptions(i,Opt);
   if (Opt and psNegative) = psNegative then
    For j:=0 to N do MainSetka^.Put(j,i,-1*MainSetka^.Get(j,i));
   end;
end;
procedure TBoundLayer.Execute;
var Iter,Dif,Nevaz,Otriv,StopPar:boolean;
    Opt:word;
    Succes:boolean;
const Dig:boolean=false;
begin
   Analizator;{Устанавливает флаги в соотв. с касательной скоростью}
   PutBoundaryValue;{Устанавливает начальные эпюры скоростей}
   {поиск нормали для начала вычислений
   устанавливает начальные номера текущей и предыдущей нормалей}
   while Monitor do begin;
   repeat
   DigitNormal(Iter,Nevaz,Dif,Otriv);
   Succes:=(iter or dif) and not(Nevaz) and not(Otriv);
   if Succes then begin
        PutFlag(CurrN,psOk);
        GetSuccNormal(StopPar);
        end;
   if Nevaz or Otriv then PutFlag(CurrN,psBreak);
   dig:=StopPar or Nevaz or Otriv;
   until dig;
   end;{while}
   RestoreU;
   if not(IsItSetFlag(PMain(ProfilePtr^.Owner)^.Option,moNotFreeCyclon)) then
      PutFreeCyclon;{определяет свободные вихри}
   Dispose(A,Done);
   Dispose(B,Done);
end;{TBounLayer.Execute}
procedure TBoundLayer.CorrectDelta(var Criterium:boolean);
{Корректировка толщины ПС в сторону уменьшения по эпюре скоростей}
var it:boolean;
    dU:real;
    CM:integer;
begin
  if not(Criterium) then exit;
  it:=false;
  CM:=N;{счетчик слоев}
  repeat
  Dec(CM);{уменьшить счетчик на 1}
  {вычислить разность скоростей на соответствующих слоях}
  dU:=MainSetka^.Get(CM+1,CurrN)-MainSetka^.Get(CM,CurrN);
  {если производная скорости больше заданной величины
  то считается что на данном слое граница ПС}
  If Abs(dU/dEtta) > Psi*Prec then it:=true;
  until it;
  {если вичисленный слой достаточно удален от последнего
  то корректируется толщина ПС и производится прогонка}
  if CM < N-Trunc(N*Sloy) then begin
    MainSetka^.Put(N+1,CurrN,MainSetka^.Get(N+1,CurrN)*CM/N);
    Criterium:=false;
    end;
end;

procedure TBoundLayer.DigitNormal
          (var IterPar,NevPar,DiffPar,EpuraPar:boolean);
var
    EndProgon:boolean;
    Nev:integer;
begin
   PutFirstValue;{назначает начальные значения парам. в неизвестных узлах}
   Iteration:=1;{счетчик итераций}
   cDelta:=dDelta;{текущее приращение толщины П.С.}
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
   NevPar:=(Nev > MaxNevazka);{колличество итераций по невязке}
   until EndProgon or NevPar;
   {проверка знака производной dU/dy при y = толщине П.С.}
   cDelta:=Abs(cDelta)*Sign(Diff(Top));
   If not(Sign(cDelta) = Sign(cDeltaOld)) then begin
     cDelta:=cDelta*0.75;
     end;
     cDeltaOld:=cDelta;
   {****************************************}
   Iteration:=Iteration+1;{приращение счетчика итераций}
   {проверка условия dU/dy при y=delta <= Psi}
   IterPar:=(Iteration > MaxIter);
   DiffPar:=Abs(Diff(Top)) <= Psi;
   if ((Option and psCorrectDelta) = psCorrectDelta) and not(NevPar)
    then CorrectDelta(DiffPar);
{   GotoXY(1,2);
   Write('Processe: iteration: ',Iteration,'; Normal: ',CurrN,'  ');
   if KeyPressed then begin
     Writeln;
     Writeln('Program terminated');
     Exit;
     end;}
   Message(StatusWindow,evBroadCast,cmChangeBoundStatus,@Self);
   until IterPar or DiffPar or NevPar;
   EpuraPar:=Diff(Bottom) <= Psi;
   {IterPar да, если число итераций превышает назначенное MaxIter}
   {DiffPar да, если dU/dy при y стремящемся к толщине ПС < Psi}
   {NevPar да, если решение дифф. ур-ий не сходится}
   {EpuraPar да, если в наличии отрывная эпюра продольной скорости}
end;
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
   y:=MainSetka^.Get(N+1,LastN);
   MainSetka^.Put(N+1,CurrN,y);
   {присвоение значений в неизвестной нормали из предыдущей}
   for i:=0 to N-1 do begin
   {нормаль основной сетки, все элементы за исключением последнего
    который является граничным условием (скорость на границе ПС)}
    y:=MainSetka^.Get(i,LastN);
    MainSetka^.Put(i,CurrN,y);end;
   For i:=0 to N do begin
   {нормаль вспомогательной сетки, все элементы}
    y:=ComplementSetka^.Get(i,LastN);
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
   a2:=MainSetka^.Get(N+1,LastN);
   b1:=MainSetka^.Get(CurrM,CurrN);
   c:=MainSetka^.Get(CurrM,LastN);
   d:=MainSetka^.Get(CurrM-1,CurrN);
   e:=MainSetka^.Get(CurrM-1,LastN);
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
  n1:=((1-S)/(2*dEtta))*(Bm+2*Cm/dEtta)*MainSetka^.Get(CurrM-1,LastN);
  n2:=((Am/dDzetta)-((1-S)/(2*dEtta*dEtta))*4*Cm)*
         MainSetka^.Get(CurrM,LastN);
  n3:=((1-S)/(2*dEtta))*(Bm-2*Cm/dEtta)*MainSetka^.Get(CurrM+1,LastN);
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
   Aa:=0.5*(MainSetka^.Get(CurrM,CurrN)+MainSetka^.Get(CurrM,LastN));
{***********************************************************}
    x:=MainSetka^.Get(N+1,CurrN);
    y:=MainSetka^.Get(N+1,LastN);
    Bb:=(2/(x+y))*(ComplementSetka^.Get(CurrM,CurrN)-
        Aa*dEtta*CurrM*((x-y)/dDzetta));
{***********************************************************}
   Cc:=4/Sqr(MainSetka^.Get(N+1,CurrN)+MainSetka^.Get(N+1,LastN));
{***********************************************************}
   x:=MainSetka^.Get(N,CurrN);
   y:=MainSetka^.Get(N,LastN);
   Dd:=0.5*(x+y)*(x-y)/dDzetta;
end;{TBoundLayer.AmBmCmDm}
procedure TBoundLayer.PutFreeCyclon;
var i:integer;
    Opt:word;
begin
  For i:=0 to M do begin
   GetOptions(i,Opt);
   if (Opt and psBreak) = psBreak then begin
    if (Opt and psPositive) = psPositive then
       MakeFreeCyclon(i-1);
    if (Opt and psNegative) = psNegative then
       MakeFreeCyclon(i+1);
   end;end;
end;
procedure TBoundLayer.MakeFreeCyclon(Normal:integer);
var
  CF:PCyclon;
  P0,P,T:TPoints;
  Norm,Tang,S0,SS:TVecValue;
  SC:real;
  i:integer;
begin
  T.X:=0;
  T.Y:=Vitesnenie(Normal);
  for i:=0 to N do if dEtta*i >= Abs(T.Y) then Break;
  T.Y:=T.Y*MainSetka^.Get(N+1,Normal)/Sqrt(ProfilePtr^.Re);
  SC:=MainSetka^.Get_S(Normal);
  Tang.ProX:=ProfilePtr^.Map^.Get_TX_S(SC);
  Tang.ProY:=ProfilePtr^.Map^.Get_TY_S(SC);
  Norm.ProX:=ProfilePtr^.Map^.Get_NX_S(SC);
  Norm.ProY:=ProfilePtr^.Map^.Get_NY_S(SC);
  P0.X:=ProfilePtr^.Map^.Get_X_S(SC);
  P0.Y:=ProfilePtr^.Map^.Get_Y_S(SC);
  {переход в коорд. сист. профиля}
  ConvCoord(Tang,Norm,P0,T,P);
  S0.ProX:=MainSetka^.Get(i,Normal);
  S0.ProY:=ComplementSetka^.Get(i,Normal)/Sqrt(ProfilePtr^.Re);
  ConvVector(Tang,Norm,S0,SS);
  P.X:=P.X+SS.ProX*PMain(ProfilePtr^.Owner)^.bdt;
  P.Y:=P.Y+SS.ProY*PMain(ProfilePtr^.Owner)^.bdt;
  T:=P;
  ConvCoord(ProfilePtr^.Tang,ProfilePtr^.Norm,ProfilePtr^.Coord,T,P);
  i:=PMain(ProfilePtr^.Owner)^.CountCF;
  Inc(i);
  CF:=New(PCyclon,Init(i,P));
  CF^.Cyclon:=IntensivFreeCyclon(Normal);
  CF^.PutOption(ocNew);
  CF^.Owner:=ProfilePtr;
  ProfilePtr^.InsCF(CF);
end;
function TBoundLayer.Diff_U(i,j:integer):real;
begin
   If i < N Then
      Diff_U:=(MainSetka^.Get(i+1,j)-MainSetka^.Get(i,j))/dEtta
      else
      Diff_U:=(MainSetka^.Get(i,j)-MainSetka^.Get(i-1,j))/dEtta;
end;
function TBoundLayer.Diff_V(i,j:integer):real;
begin
   If j > 0 Then
      Diff_V:=(ComplementSetka^.Get(i,j)-ComplementSetka^.Get(i,j-1))/dDzetta
      else
      Diff_V:=(ComplementSetka^.Get(i,j)-ComplementSetka^.Get(i,M))/dDzetta;
end;
function TBoundLayer.Vitesnenie(Normal:integer):real;
var
   Buf:PBuffer;
   i:integer;
   x:real;
begin
   Buf:=New(PBuffer,Init(N+1));
   for i:=0 to N do begin
     Buf^.PutX(i+1,i*dEtta);
     x:=MainSetka^.Get(N,Normal)-MainSetka^.Get(i,Normal);
     Buf^.PutY(i+1,x);
     end;
   Vitesnenie:=IntTrapecia(Buf);
   Dispose(Buf,Done);
end;
function TBoundLayer.IntensivFreeCyclon(Normal:Integer):real;
var
   Buf:PBuffer;
   i:integer;
   W,D:real;
begin
{   Buf:=New(PBuffer,Init(N+1));
   for i:=0 to N do begin
     x1:=i*dEtta;
     Buf^.PutX(i+1,x1);
     x2:=MainSetka^.Get(i,Normal);
     x3:=Diff_U(i,Normal);
     x4:=Diff_V(i,Normal);
     x5:=x2*(x3-x4);
     Buf^.PutY(i+1,x5);
     end;
   x6:=IntTrapecia(Buf);
   x7:=PMain(ProfilePtr^.Owner)^.bdt;
   IntensivFreeCyclon:=x6*x7;
   Dispose(Buf,Done);}
{   IntensivFreeCyclon:=-1*Sign(Mainsetka^.Get(N,Normal))*
                       Sqr(Mainsetka^.Get(N,Normal))*
                       PMain(ProfilePtr^.Owner)^.bdt/2;}
   W:=Mainsetka^.Get(N,Normal);
   D:=Mainsetka^.Get(N+1,Normal);
   IntensivFreeCyclon:= -1*W*D/Sqrt(ProfilePtr^.Re);
end;

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
