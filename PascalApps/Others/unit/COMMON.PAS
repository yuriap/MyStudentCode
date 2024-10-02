unit Common;
Interface
Uses Objects,Crt,Graph;
Type
   PColor = ^TColor;
   TColor = array [0..5] of byte;
var
 grDriver: Integer;
 grMode: Integer;
 ErrCode: Integer;
function sign1(x:real):integer;
function Lg(X:real):real;
function XInN(x,n:real):real;
function RealStr(x:real):string;
function RealToStr(I:Real):String;
function IntToStr(I: Longint): String;
function StartGraph:string;
procedure DoneGraph;
procedure Beep;
procedure SoundTrac;
implementation
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
  RestoreCrtMode;
  StartGraph:='';
  end;
end;

procedure DoneGraph;
begin
  CloseGraph;
end;


begin
end.