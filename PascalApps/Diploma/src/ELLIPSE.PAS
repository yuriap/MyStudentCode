program Ellipse;
uses ProfComm;
var
  a,b:real;
  N:integer;
  FName : string[12];
  f:text;
  fi,dfi:real;
  lit,lit1:string[2];
  i:integer;
  x,y:real;
begin
  Write('Имя файла *.mpc :');
  Readln(FName);
  Write('Большая полуось :');
  Readln(a);
  Write('Малая полуось :');
  Readln(b);
  Write('Колличество точек (четное число):');
  Readln(N);
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
    if (Odd(i)) and ((N div 2) = i) then lit1:='bb'
      else lit1:='';
    Writeln(f,lit,' ',x:7:5,'  ',y:7:5,' ',lit1);
    end;
  Close(f);
  SoundTrac;
end.