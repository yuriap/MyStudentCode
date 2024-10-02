unit ProfComm;
Interface
Uses Objects,Crt,Graph,Dos;
Const IsItGr:boolean=false;
Type
   PColor = ^TColor;
   TColor = array [0..6] of byte;

    PPoints = ^TPoints;
    TPoints = record
      X,Y:Real;
      end;
    PVecValue = ^TVecValue;
    TVecValue = record{Вектор математический}
      ProX,ProY:real;{проекции вектора}
      end;
    TSpeed = TVecValue;
    PSpeed = ^TVecValue;

    PCorner = ^TCorner;
    TCorner = record
      CX,CY:Real;
      end;
function sign1(x:real):integer;
function Lg(X:real):real;
function XInN(x,n:real):real;
function RealStr(x:real):string;
function RealToStr(I:Real):String;
function IntToStr(I: Longint): String;
function StrToReal(S:string):real;
function StrToInteger(S:string):integer;
function StartGraph:string;
procedure DoneGraph;
function FileSearching:string;
function FindFile(FIleName:PathStr):boolean;
function IsItSetFlag(Options,Flag:word):boolean;
procedure ReadConfigFile;
var
 grDriver: Integer;
 grMode: Integer;
 ErrCode: Integer;
procedure ConvGrd(var C:TCorner);
procedure ConvRad(var C:TCorner);
procedure ConvCoord(Tang,Norm:TVecValue;P0,P:TPoints;var Point:TPoints);
procedure ConvVector(Tang,Norm,VecBegin:TVecValue;var VecEnd:TVecValue);
function GetProection(Napravlenie,Vector:TVecValue):real;
procedure Beep;
procedure SoundTrac;
Const
   idBasePoint = 9999;
   idProfile = 10000;
   idBreakPoint = 10001;
   idCyclon = 10002;
   idControlPoint = 10003;
   idCyclonAdd = 10004;
   idViewer = 10005;
   idVector = 10006;
   idMatrix = 10007;
   idMapProf = 10008;
   idMain = 10009;
   idOptMassiv = 10010;
   idMainSetka = 10011;
   idCompSetka = 10012;
   idBuffer = 10014;
   idFunction = 10015;
   idBoundlayer = 10016;
   idCharact = 10017;
   idCharCollect = 10018;
   idMain1 = 10019;
   idBufferCollection = 10020;
{Флаги опций}
{Опции TMapProfile}
  moNoOption = $0000;
  moCPoint = $0001;
  moCAdd = $0002;
  moBackBound = $0004;{Флаг задней кромки}
  moAutoBreak = $0008;{Автоматическая разбивка контура профиля на участки}
  moDissipation = $0010;{Диссипация компенсаторная}
  moDissipationTime = $0020;{Диссипация во времени}
  moNotFreeCyclon = $0040;{Без св. вихрей}
  moDisposeMeddle = $0080;{Игнор. возмущения в доп. условии}
  moIdealFluid = $01000;{идеальная жидкость}
  {без свободных вихрей}
  moQwathy =
    moNotFreeCyclon and not(moDissipation) and not(moDissipationTime);
  {**********************}
  {Коэфф. толщины ПС в первой расчетной нормали}
  EttaDelta:real = 2.0;
  {Вихри меньшей интенсивности удаляются из потока}
  SmallCyclon:real = 1e-2;
  {Величина малых возмущений в правой части (сумма интенсивностей св.в.)}
  LittleMeddle:real = 1e-10;
  {Hачальная завихренность потока}
  BeginCyrculation:real = -1;
  {Коэфф. диссипации свободных вихрей во времени}
  KoeffDissipation:real = 0.8;
  BValueMain = 'BeloMain';
  BValueComp = 'BeloComp';
  Tablice = 'tablfunc.tvr';
  WPowerResource = 'wpower.tvr';
  GraphicDriver = 'egavga.bgi';
  ConfigFile = 'wpower.cfg';
implementation
procedure ConvGrd(var C:TCorner);
begin
  C.CX:=C.CX*180/Pi;
  C.CY:=C.CY*180/Pi;
end;

procedure ConvRad(var C:TCorner);
begin
  C.CX:=C.CX*pi/180;
  C.CY:=C.CY*pi/180;
end;
procedure ConvCoord(Tang,Norm:TVecValue;P0,P:TPoints;var Point:TPoints);
begin
   Point.X:=Tang.ProX*P.X+Norm.ProX*P.Y+P0.X;
   Point.Y:=Tang.ProY*P.X+Norm.ProY*P.Y+P0.Y;
end;
procedure ConvVector(Tang,Norm,VecBegin:TVecValue;var VecEnd:TVecValue);
begin
   VecEnd.ProX:=Tang.ProX*VecBegin.ProX+Norm.ProX*VecBegin.ProY;
   VecEnd.ProY:=Tang.ProY*VecBegin.ProX+Norm.ProY*VecBegin.ProY;
end;
function GetProection(Napravlenie,Vector:TVecValue):real;
var P,R:real;
begin
  R:=Sqrt(Sqr(Napravlenie.ProX)+Sqr(Napravlenie.ProY));
  If R <> 0.0 then
  P:=(Napravlenie.ProX*Vector.ProX+
                 Napravlenie.ProY*Vector.ProY)/R
   else P:=0.0;
  GetProection:=P;
end;
procedure Beep;
begin
  Sound(1000);
  Delay(150);
  NoSound;
end;
procedure SoundTrac;
var i:integer;
begin
  for i:=1 to 5 do begin
    Sound(i*220);
    delay(30);
    NoSound;
    end;
end;
function sign1(x:real):integer;
begin
   If x = 0.0 Then Sign1:=0
    else sign1:=Trunc(x/Abs(x));
End;
function Lg(X:real):real;
begin
  If X > 0 then Lg:=Ln(x)/Ln(10)
           else Lg:=0;
end;
function XInN(x,n:real):real;
begin
  if X > 0 then XInN:=Exp(n*ln(x))
           else XInN:=0;
end;
function RealStr(x:real):string;
label 1;
Var
       d:string[6];
       i:byte;
       Point:boolean;
Begin
   Str(x:7:5,d);
   Point:=false;
   for i:=1 to Length(d) do
    If d[i] = '.' then Point:=true;
   If not(Point) Then begin RealStr:=d;Exit;end;
1: If (Copy(d,Length(d),1) = '0')
    then begin delete(d,Length(d),1);Goto 1; end;
   If (Copy(d,Length(d),1) = '.')
    then delete(d,Length(d),1);
    RealStr:=d;
End;
function RealToStr(I:Real):String;
var S:string[7];
begin
  Str(I:7:5,S);
  RealToStr:=S;
end;
function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string[7];
begin
 Str(I, S);
 IntToStr := S;
end;
function StrToReal(S:string):real;
var Z:integer;
    R:real;
begin
  Val(S,R,Z);
  if Z = 0 then StrToReal:=R
    else StrToReal:=0;
end;
function StrToInteger(S:string):integer;
var Z:integer;
    R:integer;
begin
  Val(S,R,Z);
  if Z = 0 then StrToInteger:=R
    else StrToInteger:=0;
end;

function StartGraph:string;
begin
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin  { Do graphics }
  StartGraph:=^C'Ошибка графики:'+^M^C+GraphErrorMsg(ErrCode);
 end
 else begin
  SetBkColor(0);
  IsItGr := true;
  RestoreCrtMode;
  StartGraph:='';
  end;
end;

procedure DoneGraph;
begin
  CloseGraph;
  IsItGr:=False;
end;
function FindFile(FileName:PathStr):boolean;
begin
 if FSearch(FileName,GetEnv('PATH')) = FileName then FindFile:=true
   else Findfile:=false;
end;
function FileSearching:string;
var NoFind:string;
begin
  NoFind:='';
  If not(FindFile(Tablice)) then NoFind:=' '+Tablice;
  If not(FindFile(WPowerResource)) then NoFind:=NoFind+' '+WPowerResource;
  If not(FindFile(GraphicDriver)) then NoFind:=NoFind+' '+GraphicDriver;
  FileSearching:=NoFind;
end;
function IsItSetFlag(Options,Flag:word):boolean;
begin
  IsItSetFlag:=(Options and Flag) = Flag;
end;
procedure ReadConfigFile;
var f:text;
label 1;
begin
  If FindFile(ConfigFile) then begin
     Assign(f,ConfigFile);
     {I-}
     Reset(F);
     if IOResult <> 0 then goto 1;
     {Коэфф. толщины ПС в первой расчетной нормали}
     Readln(f,EttaDelta);
     if IOResult <> 0 then goto 1;
     {Вихри меньшей интенсивности удаляются из потока}
     Readln(f,SmallCyclon);
     if IOResult <> 0 then goto 1;
     {Величина малых возмущений в правой части (сумма интенсивностей св.в.)}
     Readln(F,LittleMeddle);
     if IOResult <> 0 then goto 1;
     {Hачальная завихренность потока}
     Readln(f,BeginCyrculation);
     if IOResult <> 0 then goto 1;
     Readln(f,KoeffDissipation);
     if IOResult <> 0 then goto 1;
     {I+}
     exit;
     end
     else exit;
1:   Writeln('Hеправильный формат файла конфигурации ',ConfigFile);
     Halt(0);
end;
begin
end.