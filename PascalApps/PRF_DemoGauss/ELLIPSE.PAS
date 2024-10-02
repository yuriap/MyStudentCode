program Ellipse;
uses ProfComm;
const
  a = 1.0/2;{большая полуось эллипса}
  b = 1.0/2;{малая полуось эллипса}
  N = 80;{колличество определяемых точек контура}
  FName = 'ell1_02.mpc';
var
  f:text;
  fi,dfi:real;
  lit:string[2];
  i:integer;
  x,y:real;
begin
  Assign(f,FName);
  ReWrite(F);
  dfi:=2*pi/N;
  fi:=pi;
  for i:=0 to N do begin
    x:=a+a*cos(fi);
    y:=b*sin(fi);
    fi:=fi-dfi;
    if not(Odd(i)) then lit:='cp'
      else lit:='ca';
    if i = N Then lit:='  ';
    Writeln(f,lit,' ',x:7:5,'  ',y:7:5);
    end;
  Close(f);
  SoundTrac;
end.