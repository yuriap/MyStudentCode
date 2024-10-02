  Program plast1;
  {Вычисление скорости самовращения пластины (новый ваиант)}
  Uses Crt, Graph, Windows;
  Const
       NK=30;{кол-во контрольных точек}
       N=15;{кол-во сохраняемых свободных вихрей}

  Type
      txt= string[4];
      mas= array [1..N] of real;
      mas1= array [1..NK-1,1..4] of real;
      mas2= array [1..3,1..NK] of real;
      mas3= array [1..3,1..2] of real;
      mas4= array [1..NK+1,1..NK+1] of real;
      mas5= array [1..NK+1] of real;
      FilType = array [1..NK-1] of real;
      v_tang = record
        w_uP : filtype;
        w_Down : filtype;
        time: real;
        end;
  Var
      Coshy : array [1..Nk-1,1..4] of real;
      free_a,free_b,X_a,Y_a,X_b,Y_b             :mas;
      addition                                  :mas1;
      K                                         :mas2;
      Delta                                     :mas3;
      F_left                                    :mas4;
      F_right,F                                 :mas5;
      fee,eps,dom0,dom1,dom2,AWork,tay,omega    :real;
      Step,{turn,turn_1,}Iter,ParExit,NN,x      :integer;
      turn,turn_1,joker,da,SumWork              :real;
      gd,gm,dtay,md,mw                          :integer;
      m,m1,hx,hy,col                            :integer;
      p                                         :pointer;
      size                                      :word;
      s                                         :string[15];
      inp,it                                    :String[2];
      Fil                                       :File of v_tang;
      my_v                                      :v_tang;
      {*****************************************************}

  Procedure Spe(ciklon,x_point,x_ciklon,y_point,y_ciklon:real;var Ux,Uy:real);
            Var distans   : real;
  Begin
        distans:=2*pi*(sqr(x_point-x_ciklon)+sqr(y_point-y_ciklon));
        if distans-1.0/(8*(NK-1)) > 0.0
           then
               begin
                    Ux:=-1*ciklon*(y_point-y_ciklon)/distans;
                    Uy:=ciklon*(x_point-x_ciklon)/distans;
               end
               else
               begin
                ux:=0.0;uy:=0.0;
               end;
  end;
  Procedure Speed (X,Y:real;par:txt;var vx,vy:real);{определяет скорость в}
            Var                                     {точке, индуцированную}
            i1,i2               :integer;           {всеми или только св. }
            v_x,v_y             :real;              {вихрями              }
  Begin
       vx:=0.0;vy:=0.0;
       For i1:=1 to step do
          begin
          spe(free_a[i1],X,X_a[i1],Y,Y_a[i1],v_x,v_y);
          vx:=vx+v_x;
          vy:=vy+v_y;
          spe(free_b[i1],X,X_b[i1],Y,Y_b[i1],v_x,v_y);
          vx:=vx+v_x;
          vy:=vy+v_y;
          end;
       If par='all'
          then
          begin
          For i2:=1 to NK-1 do
             begin
             spe(addition[i2,1],X,addition[i2,2],Y,addition[i2,3],v_x,v_y);
             vx:=vx+v_x;
             vy:=vy+v_y;
             end;
          end;
     end;
  PROCEDURE Gauss(a:mas4;b:mas5;var x:mas5;n :integer;var Ierr:integer);
  {решение системы линейных уравнений}
  Label 160;
  Var
         WorkA                                  :mas4;
         IX,IY                                  :array [1..NK+1] of integer;
         y,z                                    :real;
         i,j,k,l,m,line,column,cl,cc,cl1,
         cc1,N1,N2,t,r,s,w                      :integer;
  Begin
        Ierr:=0;
        N1:=N-1;
        N2:=N-2;
       For i:=1 to N do
       begin
          For j:=1 to N do
          begin
             WorkA[i,j]:=A[i,j];
          end;
          IY[i]:=i;
          IX[i]:=i;
          X[i]:=B[i];
       end;
        For cl:=1 to N1 do
        begin
        cc:=cl;
        line:=cl;
        column:=cc;
        For i:=cl to N do
           begin
           For j:=cc to N do
              begin
              If Abs(WorkA[line,column]) < Abs(WorkA[i,j]) then
                 begin
                 line:=i;
                 column:=j;
                 end;
              end;
           end;
        if cl <> line then
           begin
           For j:=cc to N do
              begin
              y:=WorkA[line,j];
              WorkA[line,j]:=WorkA[cl,j];
              WorkA[cl,j]:=y;
              end;
           z:=X[line];
           X[line]:=X[cl];
           X[cl]:=z;
           k:=IY[line];
           IY[line]:=IY[cl];
           IY[cl]:=k;
           end;
        if cc <> column then
           begin
           For i:=1 to N do
              begin
              y:=WorkA[i,column];
              WorkA[i,column]:=WorkA[i,cl];
              WorkA[i,cl]:=y;
              end;
           k:=IX[column];
           IX[column]:=IX[cc];
           IX[cc]:=k;
           end;
        if  Abs(WorkA[cl,cc]) < 1.E-20 then
           begin
           Ierr:=IY[cl];
           Goto 160;
           end;
        cl1:=cl+1;
        cc1:=cc+1;
        For j:=cc1 to N do
           begin
           WorkA[cl,j]:=WorkA[cl,j]/WorkA[cl,cc];
           end;
        X[cl]:=X[cl]/WorkA[cl,cc];
        WorkA[cl,cc]:=1.0;
        For i:=cl1 to N do
           begin
           z:=WorkA[i,cc];
           WorkA[i,cc]:=0.0;
           For j:=cc1 to N do
              begin
              WorkA[i,j]:=WorkA[i,j]-WorkA[cl,j]*z;
              end;
           X[i]:=X[i]-X[cl]*z;
           end;
       end;
        if  Abs(WorkA[N,N]) < 1.E-20 then {знак отношения наоборот}
           begin
           Ierr:=-IY[N];
           Goto 160;
           end;
        X[N]:=X[N]/WorkA[N,N];
        For k:=0 to N2 do
           begin
           j:=N-k;
           m:=k+1;
           For l:=m to N1 do
              begin
              i:=N-l;
              z:=WorkA[i,j];
              X[i]:=X[i]-X[j]*z;
              end;
           end;
        For i:=1 to N do
           begin
           WorkA[i,1]:=X[i];
           end;
        For i:=1 to N do
           begin
           k:=IX[i];
           X[k]:=WorkA[i,1];
           end;
  160:
  End;
  Procedure Popravca(a3:integer;var vrx,vry:real);
  Begin
     If a3 = step
        then
        begin
        vrx:=-1.0*omega*(0.5+1/(2.0*(NK-1)))*cos(fee);
        vry:=omega*(0.5+1/(2.0*(NK-1)))*sin(fee);
        end
        else
        begin
         vrx:=0.0;vry:=0.0;
        end;
  End;
  Procedure plase;
  {пересчет координат св. вихрей}
  type
      m= array [1..2,1..N] of real;
  var
      Ind_a,Ind_b               :m;
      a1,a2,a3,a4               :integer;
      vx,vy,vrx,vry             :real;
  Begin
     For a1:=1 to step do
        begin
        For a2:=1 to 2 do
           begin
           Ind_a[a2,a1]:=0.0;
           Ind_b[a2,a1]:=0.0;
           end;
        end;
     For a3:=1 to step do
        begin
        Popravca(a3,vrx,vry);
        Speed(X_a[a3],Y_a[a3],'all',vx,vy);
        Ind_a[1,a3]:=vx+vrx;
        Ind_a[2,a3]:=vy+1.0-vry;
        Speed(X_b[a3],Y_b[a3],'all',vx,vy);
        Ind_b[1,a3]:=vx-vrx;
        Ind_b[2,a3]:=vy+1.0+vry;
        end;
     For a4:=1 to step do
        begin
        X_a[a4]:=X_a[a4]+Ind_a[1,a4]*tay;
        Y_a[a4]:=Y_a[a4]+Ind_a[2,a4]*tay;
        X_b[a4]:=X_b[a4]+Ind_b[1,a4]*tay;
        Y_b[a4]:=Y_b[a4]+Ind_b[2,a4]*tay;
        end;
  End;
  Procedure Begining;{Определяет координаты контр. точек,    }
  Var                {присоединенных и вновь отошедших вихрей}
     b1,b2,b3           :integer;
  Begin
     For b1:=1 to NK do
        begin
        K[1,b1]:=K[3,b1]*cos(fee);
        K[2,b1]:=K[3,b1]*sin(fee);
        end;
     For b2:=1 to NK-1 do
        begin
        Addition[b2,2]:=Addition[b2,4]*cos(fee);
        Addition[b2,3]:=Addition[b2,4]*sin(fee);
        end;
     For b3:=1 to 2 do
        begin
        Delta[1,b3]:=Delta[3,b3]*cos(fee);
        Delta[2,b3]:=Delta[3,b3]*sin(fee);
        end;
  End;
  Procedure Right;{Вычисляет правую часть системы}
  Var
     r1,r2                      :integer;
     z,z1,v_x,v_y               :real;
  Begin

     For r1:=1 to NK do
        begin
        Speed(K[1,r1],K[2,r1],'free',v_x,v_y);
        F_right[r1]:=omega*K[3,r1]-cos(fee)+v_x*sin(fee)-v_y*cos(fee);
        end;

  End;
   Function truns(x:real):real;{целая часть числа}
    Var   t:real;
    Begin
    t:=0.0;
    repeat
    t:=t+1.0;
    until t > x;
    truns:=t-1.0;
    End;
  Procedure ExitOut(x:integer);
  Begin
     CloseGraph;
     Makewindow(0,0,79,24,1,3);
     If x = 0
        then
           begin
           ShadowDoubleBoxWindow(9,10,62,5,12,15);
           writexy(5,2,'безразмерная частота вращения  ');
           write(omega:8:4);
           writexy(5,4,'число совершoнных оборотов  ');
           write(truns(fee/(2.0*pi)):5:0);
           end
        else
           begin
           Shadowboxwindow(9,10,62,5,12,15);
           writexy(5,2,'система не имеет решений');
           writexy(5,2,'мал ведущий элемент в строке  ');
           write(x:4);
           end;
     ParExit:=1;
     readkey;
  End;
  Procedure Gauss_opt;{Вычисляет циркуляции неизвестных вихрей}
  Var                 {и пересылает их на свои места          }
     g1,er,g2           :integer;
     su                 :real;
  Begin
     Gauss(F_left,F_right,F,NK+1,er);
     If er <> 0
     then ExitOut(er)
     else
        begin
        For g1:=1 to NK-1 do
           begin
           Addition[g1,1]:=F[g1+1];
           end;
        Free_a[step]:=F[1];
        Free_b[step]:=F[NK+1];
        X_a[step]:=Delta[1,1];
        Y_a[step]:=Delta[2,1];
        X_b[step]:=Delta[1,2];
        Y_b[step]:=Delta[2,2];
        F_right[NK+1]:=F_right[NK+1]-F[1]-F[NK+1];
        end;
  End;
  Procedure first;
Var
    Gsum_a,Gsum_b,xsum_a,ysum_a,xsum_b,ysum_b  :real;
    f1,f2,f3                                   :integer;
Begin
   If step = N
      Then
      Begin
      Gsum_a:=0.0;Gsum_b:=0.0;
      For f1:=1 to 2  do
         begin
         Gsum_a:=Gsum_a+free_a[f1];
         Gsum_b:=Gsum_b+free_b[f1];
         End;
      xsum_a:=0.0;ysum_a:=0.0;
      xsum_b:=0.0;ysum_b:=0.0;
      For f2:=1 to 2  do
         begin
         xsum_a:=xsum_a+free_a[f2]*X_A[f2];
         ysum_a:=ysum_a+free_a[f2]*Y_A[f2];
         xsum_b:=xsum_b+free_b[f2]*X_B[f2];
         ysum_b:=ysum_b+free_b[f2]*Y_B[f2];
         end;
      Free_a[1]:=Gsum_a;
      free_b[1]:=Gsum_b;
      X_A[1]:=xsum_a/Gsum_a;
      Y_A[1]:=ysum_a/Gsum_a;
      X_B[1]:=xsum_b/Gsum_b;
      Y_B[1]:=ysum_b/Gsum_b;
           For f3:=2 to N-1 do
           begin
           free_a[f3]:=free_a[f3+1];
           free_b[f3]:=free_b[f3+1];
           X_a[f3]:=X_a[f3+1];
           Y_a[f3]:=Y_a[f3+1];
           X_b[f3]:=X_b[f3+1];
           Y_b[f3]:=Y_b[f3+1];
           end;
       free_a[N]:=0.0;
       free_b[N]:=0.0;
       X_a[N]:=0.0;
       Y_a[N]:=0.0;
       X_b[N]:=0.0;
       Y_b[N]:=0.0;
      step:=N-1;
      End
    Else step:=step+1;
 End;

  Procedure Zero;
   Var
        r1              :integer;
  Begin
     For r1:=1 to step do

        begin
        Free_a[r1]:=0.0;
        Free_b[r1]:=0.0;
        x_a[r1]:=0.0;
        y_a[r1]:=0.0;
        x_b[r1]:=0.0;
        y_b[r1]:=0.0;
        end;
 End;
 Function Sign(x:real):real;{знак числа}

 Begin
    If x<>0.0
       then
       begin
       If x>0.0
          then
          sign:=1.0
          else
          begin
          sign:=-1.0;
          end;
       end
    else
    sign:=1.0;
 End;

Function Conc(x:real):string;
Var    a:string[4];
       b:string[7];
       c:string[1];
       v:real;
       i:byte;
Begin
   b:='';
   Str(Trunc(abs(x)),a);
   v:=abs(Frac(x));
   for i:=1 to 7 do begin
     v:=v*10;
     str(trunc(v),c);
     b:=Concat(b,c);
     v:=Frac(v);
     end;
   if sign(x)= -1.0 then c:='-' else c:='';
   Conc:=Concat(c,a,'.',b);
End;

Procedure OutParam;
Var
    z     :string[12];
    i     :byte;
Begin
   SetColor(4);
   For i:=1 to 4 do begin
      case i of
      1    : z:=Conc(omega);
      2    : z:=conc(tay);
      3    : str(NN,z);
      4    : z:=conc(dom1);
      end;{case}
   SetViewPort(552,(103+25*(i-1)),636,(122+25*(i-1)),clipon);
   ClearViewPort;
   OutTextXY(8 ,10,z);
   end;
End;

  Procedure Iteration;
 var z  :real;
 Begin
    If (abs(AWork)-eps)<0.0
       then
       ExitOut(0)
       else
          begin
          If iter<NN
             then
             begin
             iter:=iter+1;
             SumWork:=SumWork+awork;
             end
             else
                begin
                iter:=1;
                Sound(1760);
                Delay(100);
                NoSound;
                REadKey;

                if it = 'on' then
                begin
                If sign(dom1) <> sign(dom2)
                   then begin dom2:=dom1; dom1:=dom1/2.0;end;
                   dom2:=dom1;
                end;
                if nn=1
                then z:=sign(Awork)
                else z:=sign(SumWork);
                If sign(dom1) <> z
                   then
                      begin
                      dom1:=dom1*(-1.0);
                      end;
                SumWork:=0.0;
                omega:=omega+dom1;
               outparam;
               readkey;

                end;
          end;
  End;

   Procedure Gr_Work1;

 Begin
    SetViewPort(291,251,637,474,clipOn);
    Size:=imageSize(5,60,330,170);
    GetMem(p,Size);
    GetImage(5,60,330,170,p^);

 End;
 Procedure GR_Work2;
 Begin
    SetViewPort(291,251,637,474,clipOn);
    ClearViewPort;
    SetColor(4);
    line(330,110,330,Trunc(110-da*Md));
    OutTextXY(10,20,'dA=');
    OutTextXY(50,20,Conc(dA));
    If turn <> turn_1 Then Begin
    SetColor(1);Line(329,110,329,Trunc(110-Awork*mw));
    OutTextXY(150,20,'AWork=');
    OutTextXY(220,20,Conc(AWork));
    end;
    PutImage(3,60,P^,NormalPut);
    GetImage(5,60,330,170,p^);

    End;
 function sign1(x:real):integer;
 begin
    if abs(x)-1e-10 < 0.0
    then sign1:=0
    else begin if x > 0.0 then sign1:=1 else sign1:= -1;
    end;
 End;
 Procedure Work;
 Var

    w1,w2,w3,w6,w7,w8,K_point1,K_point2               :integer;
    Pn1,Pn2,vxx,vyy,t,c,Delta_G                       :real;

 Procedure Kr1(Var Krit_point:integer);
 Var w     :integer;
 Begin
    For w:=1 to NK-2 do begin
       If Sign1(Coshy[w,4]) <> Sign1(Coshy[w+1,4])
          then begin Krit_point:=w;
{          If Sign1(Coshy[w+1,4]) = 0 Then K_point2:=w+2
          Else K_point2:=w+1;}
          Exit;
          end;
       End;
 End;
 Procedure Kr2(Var Krit_point:integer);
 Var w     :integer;
 Begin
    For w:=NK-2 downto 1 do begin
       If Sign1(Coshy[w,4]) <> Sign1(Coshy[w+1,4])
          then begin Krit_point:=w+1;Exit;end;
       End;
 End;
 Procedure Inpfile(s:string);
 begin
    assign(fil,s);
    rewrite(fil);
    write(fil,my_v);
    close(fil);
 end;
 Function Delta_Gamma1(current:byte):real;
 Var      w5     :integer;
          summa  :real;
 Begin
    summa:=0.0;
    For w5:=1 to current do
      summa:=summa+Coshy[w5,2]-Coshy[w5,1];
      summa:=summa+Free_a[step];
      Delta_Gamma1:=summa;
 end;
 Function Delta_Gamma2(current:byte):real;
 Var w5   :integer;
     summa,s :real;
 begin
   summa:=0.0;
   For w5:=current to NK-1 do
   summa:=summa+Coshy[w5,2]-Coshy[w5,1];
   summa:=summa+Free_b[step];
   Delta_Gamma2:=summa;
 end;
 Begin
    da:=0.0;
    If K[1,1] <= 0.0 then c:=1.0 else c:=-1.0;
    For w2:=1 to NK-1 do
       begin
       speed(addition[w2,2],addition[w2,3],'free',vxx,vyy);
       vyy:=vyy+1.0;
       t:=vxx*cos(fee)+vyy*sin(fee);
       Coshy[w2,3]:=t;
       Coshy[w2,4]:=t+(NK-1)*addition[w2,1]*c/2.0;
       Coshy[w2,2]:=addition[w2,1];
{       my_v.w_Up[w2]:=Coshy[w2,2];
       my_v.w_Down[w2]:=Coshy[w2,1];}
       end;
{   Kr1(K_point1);
   Kr2(K_point2); K_point1:=NK;K_point2:=Nk;
    If (K_point1 <= NK-1) and (K_point2 <= NK-1) then begin}
    For w6:=1 to NK-1 do begin
      { if w6 <= K_point1
       Then Delta_G:=Delta_Gamma1(w6)
       else begin
       if w6 >= K_point2
       Then Delta_G:=Delta_Gamma2(w6)
       else delta_G:=0.0;
       end;}
{       Delta_G:=Delta_Gamma1(w6)-Delta_Gamma2(w6);}
{       Delta_G:=Delta_Gamma1(w6);}
       Delta_G:=Delta_Gamma2(w6);
       Pn1:=-2*(Coshy[w6,3]*Coshy[w6,2]*(NK-1)-(Delta_G/tay));
{       Pn2:=2*(Coshy[w6,3]*Coshy[w6,2]*(NK-1)-(Delta_Gamma2(w6)/tay));}
       da:=da+omega*tay*Pn1*addition[w6,4];
       my_v.w_Up[w6]:=Pn1;
       my_v.w_Down[w6]:=pn1;
       end;
{       else begin
    For w1:=1 to NK-1 do
       begin
       Pn:=addition[w1,1]*(NK-1)*Coshy[w1,3]*2;
{       Pn:=Coshy[w1,3]*addition[w1,1];}
{       my_v.w_Up[w1]:=Pn;
       my_v.w_Down[w1]:=pn;
       da:=da-omega*tay*Pn*addition[w1,4];
       end;
       end;}
    For w7:=1 to NK-1 do Coshy[w7,1]:=addition[w7,1];
{    my_v.time:=dtay*tay;
    Case Trunc(my_v.time*100) of
       5  : InpFile('pl1.dat');
       10 : InpFile('pl2.dat');
       25 : InpFile('pl3.dat');
       50 : InpFile('pl4.dat');
       100: InpFile('pl5.dat');
       200: InpFile('pl6.dat');
       300: InpFile('pl7.dat');
       400: InpFile('pl8.dat');
    End;{case}
    turn:=truns(fee/(2.0*pi));
    Gr_Work2;
    If turn=turn_1
       then
       AWork:=AWork+da

       else
          begin
          Iteration;

          turn_1:=turn;
          AWork:=0.0;
          end;

 End;
{ Procedure Work;
 Var
    w1,w2               :integer;
    vxx,vyy,vt,Gsum,Pv :real;
    Pn                                :FilType;
 Begin
    da:=0.0;
    Gsum:=0.0;
    For w2:=1 to NK-1 do Gsum:=Gsum+Addition[w2,1];
    For w1:=1 to NK-1 do
       begin
       speed(addition[w1,2],addition[w1,3],'free',vxx,vyy);
       vyy:=vyy+1.0;
       vt:=vxx*cos(fee)+vyy*sin(fee);
       Pn[w1]:=Vt*addition[w1,1];
       da:=da-omega*tay*Pn[w1]*addition[w1,4];
       end;
    write(fil,pn);
    turn:=truns(fee/(2.0*pi));
    Gr_Work2;
    If turn=turn_1
       then
       AWork:=AWork+da

       else
          begin
          Iteration;
          turn_1:=turn;
          end;

 End;   }

  Procedure Init;
  Var
     in1,in2,in3,in4                    :integer;
     ch,ch1,cr                          :real;
  Begin
     ch:=1.0;
     For in1:=1 to NK do
        begin
        ch1:=ch;
        for in2:=1 to NK+1 do
           begin
           F_left[in1,in2]:=(NK-1)/(ch1*pi);
           ch1:=ch1-2;
           F_left[NK+1,in2]:=1.0;
           end;
        ch:=ch+2.0;
        end;
     cr:=1.0;
     for in3:=1 to NK-1 do
        begin
        addition[in3,4]:=-0.5+cr/(2.0*(NK-1));
        cr:=cr+2.0;
        end;
     for in4:=1 to NK do
        begin
        K[3,in4]:=-0.5+(in4-1.0)/(NK-1)
        end;
     delta[3,1]:=-0.5-1/((NK-1)*2.0);
     delta[3,2]:=delta[3,1]*(-1.0);
     For in4:=1 to NK-1 do Coshy[in4,1]:=0.0;
  End;
  Procedure Inputpar;
  Label 2;
  Begin
  	  MakeWindow(1,1,79,24,1,15);
	   ShadowDoubleBoxWindow(15,3,50,4,10,15);
	   WriteXY(6,3,'САМОВРАЩЕНИЕ              ПЛАСТИНЫМ');
	   ShadowBoxWindow(10,9,60,10,4,15);
		  WriteXY(20,1,' Окно ввода данных ');
		  WriteXY(5,3,'Введите частоту вращения omega     ');
                  WriteXY(5,5,'Введите  шаг  по  времени  tay     ');
		  WriteXY(5,7,'Введите    прирашение    omega     ');
		  WriteXY(5,9,'Введите  параметр стабилизации     ');
                 MakeWindow(58,13,9,0,5,15);
                 MakeWindow(58,15,9,0,5,15);
                 MakeWindow(58,17,9,0,5,15);
                 MakeWindow(58,11,9,0,11,15);
                 GoToXY(3,1);
                 Read(omega);
                 GoToXY(1,1);
                 Write(omega:8:4);
                 MakeWindow(58,13,9,0,11,15);
                 GoToXY(3,1);
                 Read(tay);
                 GoToXY(1,1);
                 Write(tay:8:4);
                 MakeWindow(58,15,9,0,11,15);
                 GoToXY(3,1);
                 Read(dom0);
                 GoToXY(1,1);
                 Write(dom0:8:4);
                 Makewindow(58,17,9,0,11,15);
                 GotoXY(3,1);
                 Read(NN);
                 GotoXY(1,1);
                 Write(NN:4);
                 readkey;
  End;
  procedure includ;
  var  f1          :text;
  Begin
  if ParamStr(1) = '' then begin
      Writeln('Укажите имя управляющего файла plbegin.dat как параметр');
      Writeln('Повторите запуск программы');
      halt(0);
      end;

  Assign(F1, ParamStr(1));
 {$I-}
 Reset(F1);
 {$I+}
 if IOResult <> 0 then
      begin
      Writeln('Файл не найден');
      Writeln('Повторите запуск программы');
      halt(0);
      end;
      Readln(f1,omega);
      Readln(f1,tay);
      Readln(f1,dom0);
      Readln(f1,NN);
      Readln(f1,md);
      Readln(f1,mw);
      Readln(f1,fee);
      fee:=Fee*pi/180;
      Readln(f1,inp);
      readln(f1,eps);
      readln(f1,it);
  Close(f1);
  End;
   Procedure Graphic;
   Var
      gr1,gr2,gr3,gr4   :integer;
  Begin
        SetViewPort(2,2,447,225, ClipOn);
     ClearViewPort;
     Setcolor(4);
     Setbkcolor(7);
     SetLineStyle(0,2,normwidth);
     OutTextXY(45,100,'Vo');
     OutTextXY(360,10,'Time ');
     Str(trunc(dtay),s);
     outtextXY(400,10,s);
     OutTextXY(360,35,'turn ');
     str(trunc(turn),s);
     OuttextXY(400,35,s);
     line(20,125,70,125);
     line(65,124,70,125);
     line(65,126,70,125);
     Line(125,125,275,125);
     OutTextXY(265,110,'Y');
     Line(200,50 ,200,200);
     OutTextXY(210,190,'X');
     Setcolor(8);
     m:=50;hx:=200;hy:=125;
     Line(trunc(K[2,1]*m+hx),trunc(K[1,1]*m+hy),trunc(K[2,NK]*m+hx)
     ,trunc(K[1,NK]*m+hy));
     Setcolor(13);
     Setfillstyle(1,3);
     For gr1:=1 to NK do
        begin
        Bar(trunc(K[2,gr1]*m+hx-2),trunc(K[1,gr1]*m+hy-2),trunc(K[2,gr1]*
        m+hx+2),trunc(K[1,gr1]*m+hy+2));
        end;
     Setcolor(6);
     For gr2:=1 to NK-1 do
        begin
        Circle(Trunc(addition[gr2,3]*m+hx),trunc(addition[gr2,2]*m+hy)
        ,3);
        end;
     Setcolor(4);
     for gr3:=1 to step do
        begin
        Circle(trunc(Y_A[gr3]*m+hx),trunc(X_A[gr3]*m+hy),2);
        end;
     Setcolor(5);
     for gr4:=1 to step do
        begin
        Circle(trunc(Y_B[gr4]*m+hx),trunc(X_B[gr4]*m+hy),2);
        end;
  End;
Procedure GRI;
  var ErrorCode:integer;
  begin
       gd:=detect;
     initgraph(gd,gm,' ');
     ErrorCode:=GraphResult;
     If ErrorCode  <> grok
        then
          begin
          Writeln('Ошибка графики  ',ErrorCode  );
          Writeln(GraphErrorMsg(ErrorCode ));
          Writeln('Поместите файл egavga.bgi в текущую директорию');
          Writeln('Повторите запуск программы');
          parExit:=1;
          exit;
          end;
end;
 Procedure Gr_Init;
 begin
   SetBkColor(7);
   SetColor(4);
 Rectangle(449, 1,638,226);
  Rectangle(1, 1,448,226);
   Rectangle(1,250,638,475);
   OutTextXy(100,235,'Speed');
   OutTextXy(320,235,'dA   and   A');
   OutTextXy(460,235,'history');
   OutTextXy(440,235,chr($1B));
   OutTextXy(550,235,'current');
 SetViewPort(450,2,637,225, ClipOn);

   for m1:=1 to 8 do Line(0,25*m1,187,25*m1);
   Line(0,98,187,98);
   Line(100,100,100,200);
 OutTextXY(10,10, 'MENU (press any key)');
 OutTextXY(50,35,'GO ');
 OutTextXY(50,60,'REGULATE');
 OutTextXY(50,85,'EXIT');
 OutTextXY(10,110,'omega');
 OutTextXY(10,135,'tay');
 OutTextXY(10,160,'NN');
 OutTextXY(10,185,'dom1');
 OutTextXY(10,210,'Up');
 OutTextXY(30,210,chr($18));
 OutTextXY(40,210,'Down');
 OutTextXY(75,210,chr($19));
 OutTextXY(85,210,'<Enter>');
 OutTextXY(145,210,'<Esc>');
 End;
 Const Color=1; ColorBk=7;
Type proc = Procedure(x:integer);
Var Ex:boolean;

Procedure Correct(x:integer);
Begin
   Case x of
    5   : ReadLn(omega);
    6   : ReadLn(tay);
    7   : ReadLn(NN);
    8   : ReadLn(dom1);
   end;{case}
   OutParam;
End;
Procedure Rest(x,col:integer);
begin
   SetColor(col);
   Rectangle(2,(x-1)*25+1,185,(X-1)*25+24);
end;{rest}
Procedure Enter2(x:integer);Far;
Begin
   rest(x,14);
   Correct(x);
   Ex:=True;
   SetViewPort(450,2,637,225, ClipOn);
   rest(x,colorbk);
End;{Enter2}
Procedure Menu(min,max:integer;op:proc); Forward;
Procedure Enter1(x:integer);Far;
Begin
   rest(x,colorbk);
   Case x of
     2  :Ex:=True;
     3  : Begin Menu(5,8,Enter2); Ex:=False; End;
     4  :Halt(0);
   End;
End;{Enter1}
Procedure Menu;

Var opt,st:integer;
Begin
   st:=min;
   Ex:=false;
   Repeat
   SetViewPort(450,2,637,225, ClipOn);
   Rest(st,color);

   opt:=ord(readkey);
   if (opt<>72) and (opt<>27) and (opt<>80) and (opt<>13) Then  opt:=ord(readkey);
   Case opt of
     72:Begin
          rest(st,colorbk);
          If st = min then st:=max else st:=st-1;
        end;
     80:Begin
          rest(st,colorbk);
          If st = max then st:=min else st:=st+1;
        end;
     13: Op(st);
     27: begin rest(st,colorbk); ex:=true;end;
   end;
   Until ex;
End;{Menu}
Procedure Circ(x,y:integer);far;
begin
   Circle(x,y,2);
end;

Procedure Swiev(s:V_tang);
Var
       max,min:real;
       i1,i2                                     : integer;
       horiz,vert,dX,x0,state_y              : integer;
Procedure MaxMin;
Var i                                 :integer;
Begin
   For i:=1 to NK-1 Do begin
   If s.w_Up[i] > max Then max:= s.w_Up[i];
   If s.w_Up[i] < min Then min:= s.w_Up[i];
   end;
   For i:=1 to NK-1 Do begin
   If s.w_Down[i] > max Then max:= s.w_Down[i];
   If s.w_Down[i] < min Then min:= s.w_Down[i];
   end;

end;
 function sign1(x:real):integer;
 begin
    if abs(x)-1e-10 < 0.0
    then sign1:=0
    else begin if x > 0.0 then sign1:=1 else sign1:= -1;
    end;
 End;

Function Conc1(x:real):string;
Var    a:string[1];
       b:string[1];
       c:string[1];
       v:real;
       i:byte;
Begin
   b:='';
   Str(Trunc(abs(x)),a);
   v:=abs(Frac(x));
   for i:=1 to 7 do begin
     v:=v*10;
     str(trunc(v),c);
     b:=Concat(b,c);
     v:=Frac(v);
     end;
   If Sign1(x) < 0 then c:='-' else c:='';
   Conc1:=Concat(c,a,'.',b);
End;

Procedure PrnScreen;
Type
    Helper = procedure(x,y:integer);
Var cl     :integer;
procedure lines(lld:helper);
Var    i3 : integer;
begin
    SetColor(14);
   for i3:=1 to NK-1 do begin
   lld(X0+dX*(i3-1),state_y-round(s.w_Up[i3]*horiz));
   moveto(X0+dX*(i3-1),state_y-round(s.w_Up[i3]*horiz));
   If i3 <> NK-1 then
   lineto(X0+dX*(i3),state_y-round(s.w_Up[i3+1]*horiz));
   end;
    SetColor(12);
   for i3:=1 to NK-1 do begin
   lld(X0+dX*(i3-1),1+state_y-round(s.w_Down[i3]*horiz));
   moveto(X0+dX*(i3-1),1+state_y-round(s.w_Down[i3]*horiz));
   If i3 <> NK-1 then
   lineto(X0+dX*(i3),1+state_y-round(s.w_Down[i3+1]*horiz));
   end;

end;
Begin
    { col:=9;
     SetColor(col);}
     lines(circ);
End;
Begin
  max:=0.0;min:=0.0;
  MaxMin;
  Vert:=round(max-min+2);
  Horiz:=round(200/vert) ;
  State_y:=10+(round(max)+1)*Horiz;
   dX:=round(250/(NK-1));
   X0:=20+Round(dX/2);
        SetViewPort(2,251,290,474,clipOn);
        ClearViewPort;
  line(287,1,287,222);
  For i1:=0 to 10 do begin
  line(20+25*i1,10,20+25*i1,210);
  OutTextXY(11+i1*25,1,Conc1(i1/10));
  end;
  for i2:=0 to vert do begin
  line(20,10+horiz*i2,270,10+horiz*i2);
  end;
  line(20,State_y+2,270,State_y+2);
  PrnScreen;
end;
  {********************************************************}
  {основная часть программы}
  BEGIN
     {************************}
     GetDir(0,s);
     Includ;
     if inp = 'on' then  InputPar;
     ChDir(s);            {***}
     step:=1;             {***}
     F_right[NK+1]:=0.0;  {***}{присвоение началных значений}
     AWork:=0.0;          {***}
     turn:=0;             {***}
     turn_1:=0;           {***}
     dom1:=dom0;          {***}
     dom2:=dom0;          {***}
     iter:=1;             {***}
     ParExit:=0;          {***}
     dtay:=0;
     SumWork:=0.0;
     {************************}
     GRI;
     If ParExit = 1 Then Exit;
     Gr_Init;
     Gr_Work1;
{     Assign(fil,'plast1.dat');
     Rewrite(fil);}

     {********************************************}
     Init;
     Zero;
     Begining;
     Repeat
     Right;
     Gauss_opt;
      If ParExit = 1
         then begin CloseGraph; Exit; end;
     Graphic;
     Work;
      If ParExit = 1
         then begin CloseGraph; Exit; end;
     Swiev(my_v);
     outparam;
     If KeyPressed Then Menu(2,4,Enter1);
     Plase;
     First;
     fee:=fee+omega*tay;
     dtay:=dtay+1;
     Begining;
     {******************************}
     until false;
End.