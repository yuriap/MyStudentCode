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
 Write('������ �᫠: ');
 Readln(x1,x2);
 Writeln('����襥 �᫮: ',Max(x1,x2));
 until false;
end.