program RoundPAS;
var x,y:real;
function Lg(X:real):real;
begin
  If X > 0 then Lg:=Ln(x)/Ln(10)
           else Lg:=0;
end;
begin
  repeat
  Writeln('Input the value');
  Readln(X);
  Writeln('Decimal logarithm',Lg(X));
  until false;
end.
