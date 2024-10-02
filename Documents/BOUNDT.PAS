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
Unit BoundT;
Interface
uses Graphict,Graph,Objects,Dialogs,Views,MsgBox,Dos,Memory,Crt;
const
    DimHor = 20;
    DimVert = 10;

    FileGrUsl:PathStr='Fi&Fi.dat';{ресурс с таблицами функций фи и фи_штрих
                                  по Б.-Н.}
    EttaDelta=2.4;{коеффициент для задания граничного условия (см Б.-Н.)}
    Top:boolean=true;{граница П.С.}
    Bottom:boolean=false;{поверхность}
type
  TBoundRec = record
  Nu,{вязкость [м^2/c]}
  U0,{скорость потока [м/c]}
  L ,{длина пластины [м]}
  Ro,{плотнщсть жидкости [кг/м^3]}

  al,{коеффициент для задания граничного условия (см Б.-Н. "а")}
  Psi,{малое положительное число для dU/dy при y=delta <= Psi}
  S,{параметр усреднения}
  M,{размерность матрицы сетки по " нормали" к пластине (0..M)}
  N,{размерность матрицы сетки по "касательной" к пластине(0..N)}
  MaxIter{максимальное число итераций}  :string[7];

  IfView:word;
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
       al:real;{коеффициент для задания граничного условия (см Б.-Н. "а")}
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
       CurrN,CurrM:integer;{счетчики текущих нормали и слоя соответственно}
       MainSetka:TMainSetka;{основная сетка}
       ComplementSetka:TComplSetka;{вспомогательная сетка}
       Delta:TDelta;{толщина П.С. вдоль поверхности}
       A,B:TABCoeff;{массивы прогоночных коэффициентов}
       Fi,FiStrih:TABCoeff;
       constructor Init;
       Procedure NewParam;
       procedure Run(Plase:Word);{расчет П.С.}
       {назначает начальные значения парам. в неизвестных узлах}
       procedure PutFirstValue;
       procedure GoingForU;{прогонка по узлам основной сетки}
       procedure GoingForV;{прогонка по узлам вспомогательной сетки}
       {вычисление прогоночных коэффициентов для текущей нормали}
       procedure GetA;
       procedure GetB;
       {коэфф. в формулах прогоночных коэфф.}
       function Alfa:real;
       function Betta:real;
       function Gamma:real;
       function Tetta:real;
       {коэфф. для предыдущих функций, по Б.-Н. a,b,c,d}
       function Am:real;
       function Bm:real;
       function Cm:real;
       function Dm:real;
       {производная продолной скорости по нормали True - на границе(Top)}
       { False - на поверхности (Bottom)}
       function Diff(TopOrBottom:Boolean):real;
       destructor Done;virtual;
       end;

       PBoundDlgBox = ^TBoundDlgBox;
       TBoundDlgBox = object(TDialog)
          constructor Init;
          end;
function Sign(Numer:real):shortint;
var      ABound:PBoundLayer;
Implementation
Uses Work001t;

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
    read(DataFile,Fi[i]);
    end;
  for i:= 0 to DimVert do begin
    read(DataFile,FiStrih[i]);
    end;
 Close(DataFile);

  {инциализация полей}
  Val(BoundRec.Nu,Nu,z);{вязкость [м^2/c]}
  Val(BoundRec.U0,U0,z);{скорость потока [м/c]}
  Val(BoundRec.L,L,z);{длина пластины [м]}
  Val(BoundRec.Ro,Ro,z);{плотнщсть жидкости [кг/м^3]}

  Val(BoundRec.al,al,z);{коеффициент для задания граничного условия (см Б.-Н. "а")}
  Val(BoundRec.Psi,Psi,z);{малое положительное число для dU/dy при y=delta <= Psi}
  Val(BoundRec.S,S,z);{параметр усреднения}
  M:=DimVert;{размерность матрицы сетки по " нормали" к пластине (0..M)}
  N:=DimHor;{размерность матрицы сетки по "касательной" к пластине(0..N)}
  Val(BoundRec.MaxIter,MaxIter,z);{максимальное число итераций}
  Re:=U0*L/Nu;{число Рейнольдса}
  dEtta:=1/(M);{шаг сетки по нормали}
  dDzetta:=1/(N);{шаг сетки вдоль поверхности}
  {инициализация вектора толшины П.С.}
  Delta[0]:=EttaDelta*Sqrt(Nu/al);{толщина П.С. в 1-й нормали}
  dDelta:=Delta[0]*0.1;{начальное приращение толщины П.С.}
  {иниц. основной сетки}
  {граничное условие - продольная скорость на границе сетки}
  For i:=0 to M do  MainSetka[i,0]:=FiStrih[i]*1;
  {иниц. вспомогательной сетки}
  {граничное условие - поперечная скорость на границе сетки}
  For i:=0 to M do  ComplementSetka[i,0]:=-1*Fi[i]*Sqrt(al*Nu);
  {иниц. массивов прогоночных коэффициентов}
end;{TBoundLayer.Init}
procedure TBoundLayer.NewParam;
var z : integer;
    i:word;
    x:real;
begin
  {инциализация полей}
  Val(BoundRec.Nu,Nu,z);{вязкость [м^2/c]}
  Val(BoundRec.U0,U0,z);{скорость потока [м/c]}
  Val(BoundRec.L,L,z);{длина пластины [м]}
  Val(BoundRec.Ro,Ro,z);{плотнщсть жидкости [кг/м^3]}

  Val(BoundRec.al,al,z);{коеффициент для задания граничного условия (см Б.-Н. "а")}
  Val(BoundRec.Psi,Psi,z);{малое положительное число для dU/dy при y=delta <= Psi}
  Val(BoundRec.S,S,z);{параметр усреднения}
  Re:=U0*L/Nu;{число Рейнольдса}
  dEtta:=1/(M);{шаг сетки по нормали}
  dDzetta:=1/(N);{шаг сетки вдоль поверхности}
  Val(BoundRec.MaxIter,MaxIter,z);{максимальное число итераций}
  {инициализация вектора толшины П.С.}
  Delta[0]:=EttaDelta*Sqrt(Nu/al);{толщина П.С. в 1-й нормали}
  dDelta:=Delta[0]*0.1;{начальное приращение толщины П.С.}
  {иниц. основной сетки}
  {граничное условие - продольная скорость на границе сетки}
  For i:=0 to M do  MainSetka[i,0]:=FiStrih[i]*1;
  {иниц. вспомогательной сетки}
  {граничное условие - поперечная скорость на границе сетки}
  For i:=0 to M do  ComplementSetka[i,0]:=-1*Fi[i]*Sqrt(al*Nu);
end;{TBoundLayer.NewParam}

destructor TBoundLayer.Done;
begin
  inherited Done;
end;
procedure TBoundLayer.Run(Plase:Word);
Label A1,A2;
var af,bf:boolean;
    df:real;
    As:word;
    Criterium:string[17];
    IfIteration : boolean;
      Vec:PZVector;
      i:word;
  procedure InstalValue(Vector:PZVector);
  begin
      If Iteration > MaxIter Then Vector^.Labels:='first'
         else Vector^.Labels:=IntToStr(CurrN)+'.'+IntToStr(Iteration);
      Vector^.Color:=4;
      Vector^.Visible:=true;
  end;

function DirectBox(S:string):boolean;
var D:word;
begin
  D:=MessageBox(#3+S+#13+
            #3'Дальше?',nil,mfinformation or mfYesNoCancel);
  If D = cmYes Then DirectBox:=false;
  If D = cmNo Then DirectBox:=true;
  If D = cmCancel Then begin DirectBox:= false;IfIteration:= false;end;
end;
begin
{   CurrN:=1;{счетчик нормалей
   IfIteration:=true;
   If Plase = 1 then Goto A2;}
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
   cDelta:=Delta[CurrN]*0.01;{текущее приращение толщины П.С.}
   repeat{цикл итераций по толщине П.С.}
   {вычисляется толщина П.С. в текущей итерации}
   Delta[CurrN]:=Delta[CurrN]+cDelta;
   GoingForU;{прогонка по узлам основной сетки}
{   If DirectBox('Прогонка по U') then exit;}
   GoingForV;{прогонка по узлам вспомогательной сетки}
   {проверка знака производной dU/dy при y = толщине П.С.}
   If not(Sign(cDelta) = Sign(Diff(Top))) then begin
     cDelta:=cDelta/2;
     cDelta:=Abs(cDelta)*Sign(Diff(Top));
     end;
{    If IFIteration Then
      If (DirectBox('Закончена итерация: '+IntToStr(Iteration))) then Exit;}
   {****************************************}
    If BoundRec.IfView = 0 then begin
    Vec:=New(PZVector,Init(DimVert+1));
    For i:=0 to DimVert do
      Vec^.Put(i,MainSetka[i,CurrN]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
    Graphic^.Execute;
    Graphic^.DelLastVector;
    Graphic^.StoreParam;end;
    {*******************************************}

A2:Iteration:=Iteration+1;{приращение счетчика итераций}
   {проверка условия dU/dy при y=delta <= Psi}
   df:=Diff(Top);
   af:=(Iteration > MaxIter);
   bf:=((0 <= df) and (df <= Psi));
   Sound(1000);
   Delay(1);
   NoSound;
   until af or bf;
{****************************************}
     If BoundRec.IfView = 0 then begin
     RestoreCrtMode;
     DoneMemory;
     MyApp^.Redraw;end;
{****************************************}
   If BoundRec.IfView < 2 then begin
   if af and not(bf) Then Criterium:='-конец итераций.';
   If bf and not(af) Then Criterium:='-производная.';
   If bf and af Then Criterium:='- оба.';
   As:=MessageBox(^C'Номер текущей нормали: '+IntToStr(CurrN)
             +^M^C'Окончание: '+Criterium
             +^M^C'Продолжить дальше? Yes'
             +^M^C'Или приостановить? No'
               ,nil,mfInformation or mfYesNoCancel);
   case As of
     cmYes   : IfIteration := false;
     cmCancel: IfIteration := true;
     cmNo    : begin
               CurrN:=CurrN+1;
               IF CurrN > N Then Goto A1;
               Exit;
               end;
    end;end;
   CurrN:=CurrN+1;
   until CurrN > N;
A1:MessageBox(^C'Вычисления закончены',nil,mfInformation or mfOkButton);
end;{TBounLayer.Run}
function TBoundLayer.Diff(TopOrBottom:Boolean):real;
{производная dU/dy}
begin
  If TopOrBottom
    Then
      {на границе П.С.}
      Diff:=(MainSetka[M,CurrN]-MainSetka[M-1,CurrN])/dEtta
    Else
      {на поиерхности}
      Diff:=(MainSetka[1,CurrN]-MainSetka[0,CurrN])/dEtta;
end;{TBoundLayer.Diff}
procedure TBoundLayer.PutFirstValue;
var i:word;
begin
   Delta[CurrN]:=Delta[CurrN-1];
   for i:=0 to M do begin
   {присвоение значений в неизвестной нормали из предыдущей}
    MainSetka[i,CurrN]:=MainSetka[i,CurrN-1];
    ComplementSetka[i,CurrN]:=ComplementSetka[i,CurrN-1];
   end;
end;{TBoundLaer.PutFirstValue}
procedure TBoundLayer.GoingForU;{прогонка по узлам основной сетки}
var
  z:real;
begin
   {вычисляются прогоночные коэффициенты для текущей нормали}
   GetA;
   GetB;
   CurrM:=M-1;{счетчик слоев}
   {скорость на границе потока равна ск. внешнего потока}
   MainSetka[M,CurrN]:=1;
   {цикл вычислений продольной скорости по рекурентной формуле (Б.-Н.)}
   repeat
   MainSetka[CurrM,CurrN]:=A[CurrM]*MainSetka[CurrM+1,CurrN]+B[CurrM];
   CurrM:=CurrM-1;
   until CurrM < 0;
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
      (((a1-a2)*CurrM/(dDzetta*(a1+a2)))*(b1+c-d-e-(d-e+b1-c)/(2*dDzetta)));
   ComplementSetka[CurrM,CurrN]:=f;
   CurrM:=CurrM+1;
   until CurrM > M;
end;{GoingForV}
procedure TBoundLayer.GetA;
{вычисление прогоночного коэффициента А для текущей нормали}
begin
  CurrM:=1;{счетчик слоев}
  A[0]:=0.0;{установка значения Ао}
  {цикл вычисления коэфф. Аm (по Б.-Н.)}
  repeat
  A[CurrM]:=-1*(Gamma/(Alfa*A[CurrM-1]+Betta));
  CurrM:=CurrM+1;
  until CurrM > M-1;
end;{TBoundLayer.GetA}
procedure TBoundLayer.GetB;
{вычисление прогоночного коэффициента B для текущей нормали}
var g:real;
begin
  CurrM:=1;{счетчик слоев}
  B[0]:=0.0;{установка значения Bо}
  {цикл вычисления коэфф. Bm (по Б.-Н.)}
  repeat
  B[CurrM]:=(Tetta-Alfa*B[CurrM-1])/(Alfa*A[CurrM-1]+Betta);
  CurrM:=CurrM+1;
  until CurrM > M-1;
end;{TBoundLayer.GetB}
{коэфф. в формулах прогоночных коэфф.}
function TBoundLayer.Alfa:real;
begin
  if CurrM <> 1 then  Alfa:=-1*(S/(2*dEtta))*(Bm+2*Cm/dEtta)
                else  Alfa:=0.0;
end;{TBoundLayer.Alfa}
function TBoundLayer.Betta:real;
begin
   Betta:=(Am/dDzetta)+(S/(2*dEtta*dEtta))*4*Cm;
end;{TBoundLayer.Betta}
function TBoundLayer.Gamma:real;
begin
   If CurrM <> M-1 then Gamma:=(S/(2*dEtta))*(Bm-2*Cm/dEtta)
                   else Gamma:=0.0;
end;{TBoundLayer.Gamma}
function TBoundLayer.Tetta:real;
var
  n1,n2,n3:real;
begin
  n1:=((1-S)/(2*dEtta))*(Bm+2*Cm/dEtta)*MainSetka[CurrM-1,CurrN-1];
  n2:=((Am/dDzetta)-((1-S)/(2*dEtta*dEtta))*4*Cm)*
         MainSetka[CurrM,CurrN-1];
  n3:=((1-S)/(2*dEtta))*(Bm-2*Cm/dEtta)*MainSetka[CurrM+1,CurrN-1];
  Tetta:=n1+n2-n3+Dm;
end;{TBoundLayer.Tetta}
{коэфф. для предыдущих функций, по Б.-Н. a,b,c,d}
function TBoundLayer.Am:real;
begin
   Am:=0.5*(MainSetka[CurrM,CurrN]+MainSetka[CurrM,CurrN-1]);
end;{TBoundLayer.A}
function TBoundLayer.Bm:real;
var x,y:real;
begin
    x:=Delta[CurrN];
    y:=Delta[CurrN-1];
    Bm:=(2/(x+y))*(ComplementSetka[CurrM,CurrN]-
       0.5*Am*dEtta*CurrM*((x-y)/dDzetta));
end;{TBoundLayer.B}
function TBoundLayer.Cm:real;
begin
   Cm:=4/Sqr(Delta[CurrN]+Delta[CurrN-1]);
end;{TBoundLayer.C}
function TBoundLayer.Dm:real;
var x,y:real;
begin
   {уточнить формулу!}
   Dm:=0.0;
end;{TBoundLayer.D}
constructor TBoundDlgBox.Init;
var
   R:TRect;
   View:PView;
   Button:PView;
begin
   R.Assign(6,5,74,18);
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
    Insert(New(PLabel,Init(R,'~E~.Коэффициент A:',View)));
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
     nil)))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(39,8,49,9);
    Insert(New(PLabel,Init(R,'~K~.Просмотр',Button)));

{**************************************************}

      R.Assign(3,9,12,11);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(15,9,24,11);
      Insert(New(PButton,Init(R,'Ca~n~cel',cmCancel,bfNormal)));

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