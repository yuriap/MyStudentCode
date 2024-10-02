program MKSCoord;
var
  x,y,x1,y1,S:real;
  lit:string[2];
  f,f1:text;
  Str:string;
  Name:string[12];
begin
  If ParamStr(1) <> '' then Name:=ParamStr(1) else
    begin
      Writeln('Укажите имя файла как параметр');
      Exit;
    end;
  Assign(f,'prof2b.mpc');
{  Name:='prof.mpc';}
  Assign(f1,'prof2.mpc');
  Reset(f);
  Rewrite(f1);
  Readln(f,Str);
  Writeln(f1,Str);
  Readln(f,Str);
  Writeln(f1,Str);
  S:=0;
  Readln(f,lit,x1,y1);
  Writeln(f1,lit,'  ',x1:8:6,'  ',y1:8:6,'  ',S:8:6);
  While not(EoF(f)) do begin
  Readln(f,lit,x,y);
  S:=S+Sqrt(Sqr(x-x1)+Sqr(y-y1));
  Writeln(f1,lit,'  ',x:8:6,'  ',y:8:6,'  ',S:8:6);
  x1:=x;y1:=y;
  end;
  Close(f);
  Close(f1);
end.