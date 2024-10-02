Program Koeff;
Const
     T0 = 273;
     P0 = 100000;
     M = 29;
     C = 1.05;
     Mv = 18;
     Msv = 29;
     Vo = 22.4;
Var
   n,betta,t,w,x,x2:real;
   P,P1,P2,Ro_sr,betta_v : real;
Begin
  Writeln('Ввод данных');
  Write('Частота вращение барабана? ');
  Readln(n);
  Write('Степень заполнения барабана? ');
  Readln(betta);
  Write('Средняя температура в барабане? ');
  Readln(t);
  Write('Скорость газа в барабане? ');
  Readln(w);
  Write('Начальное влагосодержание сушильного агента? ');
  Readln(x);
  Write('Конечное влагосодержание сушильного агента? ');
  Readln(x2);
  Ro_sr:=(M/Vo)*(T0/(T0-t));
  P1:=((x/Mv)*P0)/((1/Msv)+(x/Mv));
  P2:=((x2/Mv)*P0)/((1/Msv)+(x2/Mv));
  P:=(P1+P2)/2;
  betta_v:=1.6e-2*Exp(0.9*Ln(w*Ro_sr))*Exp(0.7*Ln(n))*
           Exp(0.54*Ln(betta))*P0/(C*Ro_sr*(P0-P));
  Write('Объемный коеффициент массоотдачи = ',betta_v);
End.


    Объемный коеффициент массоотдачи = 0.3114161