program MkSphire;
const
   MapName = 'profsph.mpc';
   MapPoint = 'prof2.mpp';
   Count =70 ;
   CountPoint = 35;
var
   f:text;
   i:integer;
procedure MakeMPC(var Fil:Text);
var
   x,y,t,dt:real;
   i:integer;
   Lit:string[2];
begin
  Rewrite(Fil);
  Writeln(f,' ',Count+1,' -  колличество точек');
  Writeln(f,' ',CountPoint,' - колличество участков разбиения');
  t:=Pi;dt:=-2*Pi/Count;
  for i:=1 to Count+1 do begin
  x:=cos(t);
  y:=sin(t);
  If not(Odd(i)) Then Lit:='ca' Else Lit:='cp';
  If i = Count+1 Then Lit:='';
  Writeln(f,lit,'  ',x:8:6,'  ',y:8:6);
  t:=t+dt;
  end;
end;
procedure MakeMPP(var Fil:Text);
var
  x,y,t,dt:real;
  i:integer;
begin
  Rewrite(Fil);
  Writeln(f,' ',CountPoint,' -  колличество участков разбиения');
  Writeln(f,'   Контрольные точки');
  t:=Pi;dt:=-2*Pi/CountPoint;
  For i:=1 to CountPoint do begin
  x:=cos(t);
  y:=sin(t);
  Writeln(f,x:8:6,'  ',y:8:6);
  t:=t+dt;
  end;
  t:=Pi;
  Writeln(f,'   Присоединенные вихри');
  For i:=1 to CountPoint do begin
  x:=cos(t+dt/2);
  y:=sin(t+dt/2);
  Writeln(f,x:8:6,'  ',y:8:6);
  t:=t+dt;
  end;
end;
begin
  Assign(f,MapName);
  MakeMPC(f);
  Close(f);
{  Assign(f,MapPoint);
  MakeMPP(f);
  Close(f);}
  Writeln('Ok!!!');
end.