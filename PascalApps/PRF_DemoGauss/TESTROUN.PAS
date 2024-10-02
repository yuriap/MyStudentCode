program TestRoun;
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
procedure GetAutoMasshtab(Var StepX,StepY:real);

function GetFirstDig(var X:real):real;
  function MR(x:real):Real;
  begin
    If (x > -0.5) and (x < 0) Then begin MR:=-1; exit;end;
    If (x < Round(x)) and (x >= 0) then begin MR:=Int(x);exit;end;
    if (x < Round(x)) and (x <= -0.5) then begin MR:=int(x)-1;exit;end;
    MR:=Round(x);
  end;
var por:real;
begin
   por:=XInN(10,MR(Lg(X)));
   GetFirstDig:=int(X/por)*por;
end;
begin
   StepX:=GetFirstDig(StepX);
{   GetFirstDig(StepY);}
end;
var SX,SY:real;
begin{program}
  Repeat
  SY:=20;
  Write('Введите число ');
  Readln(SX);
{  SX:=3.2;}
  GetAutoMasshtab(SX,SY);
  Writeln('Округление: ',SX:7:4);
  until false;
end.