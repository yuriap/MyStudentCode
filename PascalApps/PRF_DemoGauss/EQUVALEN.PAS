program Equvalen;
var
   x1,x2:real;
function Max(y1,y2:real):real;
begin
  If y1 > y2 then Max:=y1
    else Max:=y2;
end;
begin
 repeat
 Write('Введите числа: ');
 Readln(x1,x2);
 Writeln('Большее число: ',Max(x1,x2));
 until false;
end.