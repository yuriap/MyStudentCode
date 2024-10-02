{      ┌───────────────────────────────────────────┐
       │                                           │
       │            TURBO  MATMETOD 1.0            │
       │                                           │
       │     Copyright (c)  S.Novak  1992,1994     │
       │                                           │
       └───────────────────────────────────────────┘      }

  unit MatMetod;

   {$G-  Улучшенная генерация кода для 80286      }
   {$N+  Подключение числового сопроцессора 8087  }
   { $E+  Подключение эмулятора сопроцессора 8087  }

  interface

   const

    Eps :extended = 10E-10;

   type

    TFuncX = function(X :extended) :extended;
    TFuncXY = function(X,Y :extended) :extended;

    function Sign (X :extended) :shortint;
    function Arsin(X :extended) :extended;
    function Arcos(X :extended) :extended;
    function Arctg(X :extended) :extended;
    function Arsh (X :extended) :extended;
    function Arch (X :extended) :extended;
    function Arth (X :extended) :extended;
    function Arcth(X :extended) :extended;
    function Sh   (X :extended) :extended;
    function Ch   (X :extended) :extended;
    function Th   (X :extended) :extended;
    function Cth  (X :extended) :extended;
    function Sec  (X :extended) :extended;
    function Cosec(X :extended) :extended;
    function Tg   (X :extended) :extended;
    function Ctg  (X :extended) :extended;
    function Lg   (X :extended) :extended;
    function Rad  (X :extended) :extended;
    function Grad (X :extended) :extended;
    function Pow  (X :extended; Y :Extended) :extended;
    function AnPow(X :extended; Y :integer) :extended;
    function Fac(I :integer) :longint;

    function Sgn(X: extended): integer;
    function Dich(A,B,E: extended;F: TFuncX): extended;
    function MiniGold(F :TFuncX; A,B :extended) :extended;
    function Integral (F :TFuncX; A,B :extended; N :word) :extended;
    function IntegralE (F :TFuncX; A,B :extended; E :extended) :extended;
    function DIntegral (F:TFuncXY; A,B:extended; N:word; C,D:extended; M:word) :extended;
    procedure Gauss(N :byte; var B,Y; var C :byte);

  implementation

    function Fac(I :integer) :longint;
      var Res :longint;
     begin
      Res:=1;
      for I:=1 to I do Res:=Res*I;
      Fac:=Res
     end;

    function Pow  (X :extended; Y :extended) :extended;
     begin
      Pow:=Exp(Y*Ln(Abs(X)));
     end;

    function AnPow  (X:extended; Y :integer) :extended;
      var F :shortint;
     begin
      if X = 0 then AnPow:=0
      else begin
       F:=1;
       if X < 0 then if Odd(Y) then F:=-1;
       AnPow:=F*Exp(1/Y*Ln(Abs(X)));
      end;
     end;

    function Sign(X :extended) :shortint;
     begin
      if X < 0 then Sign:=-1
      else Sign:=1
     end;

    function Arsin(X :extended) :extended;
     begin
      Arsin:=ArcTan(X/(sqrt(1-sqr(X))))
     end;

    function Arcos(X :extended) :extended;
     begin
      Arcos:=Pi/2-Arsin(X)
     end;

    function Arctg(X :extended) :extended;
     begin
      Arctg:=Pi/2-ArcTan(X)
     end;

    function Arsh(X :extended) :extended;
     begin
      Arsh:=Ln(X+Sqrt(Sqr(X)+1))
     end;

    function Arch(X :extended) :extended;
     begin
      Arch:=Ln(X+Sqrt(Sqr(X)-1))
     end;

    function Arth(X :extended) :extended;
     begin
      Arth:=Ln((1+X)/(1-X))/2
     end;

    function Arcth(X :extended) :extended;
     begin
      Arcth:=Ln((X+1)/(X-1))/2
     end;

    function Sh(X :extended) :extended;
     begin
      Sh:=(Exp(x)-Exp(-X))/2
     end;

    function Ch(X :extended) :extended;
     begin
      Ch:=(Exp(x)+Exp(-X))/2
     end;

    function Th(X :extended) :extended;
     begin
      Th:=(Exp(x)-Exp(-X))/(Exp(x)+Exp(-X))
     end;

    function Cth(X :extended) :extended;
     begin
      Cth:=(Exp(x)+Exp(-X))/(Exp(x)-Exp(-X))
     end;

    function Sec(X :extended) :extended;
     begin
      Sec:=1/Sin(X)
     end;

    function Cosec(X :extended) :extended;
     begin
      Cosec:=1/Cos(X)
     end;

    function Tg(X :extended) :extended;
     begin
      Tg:=Sin(X)/Cos(X)
     end;

    function Ctg(X :extended) :extended;
     begin
      Ctg:=Cos(X)/Sin(X)
     end;

    function Lg(X :extended) :extended;
     begin
      Lg:=Ln(X)/Ln(10)
     end;

    function Rad  (X :extended) :extended;
     begin
      Rad:=X/180*Pi
     end;

    function Grad (X :extended) :extended;
     begin
      Grad:=X/Pi*180
     end;

    function Integral (F :TFuncX; A,B :extended; N :word) :extended;
     {------------------------------------------------------------------}
     {      Возвращает  значение  интеграла  вычесленного  методом      }
     { Симпсона:                                                        }
     {  F - подинтегральная функция ( function(X :extended):extended )  }
     {  A - нижний предел интегрирования;                               }
     {  B - верхний предел интегрирования;                              }
     {  N - количество разбиений интервала интегрирования.              }
     {------------------------------------------------------------------}
     var
      I :word;
      H,H2,X,S :extended;
     begin
      H:=(B-A)/N;
      H2:=H/2;
      S:=(F(A)+F(B))/2+2*F(A+H2);
      X:=A;
      for I:=1 to N-1 do begin
       X:=X+H;
       S:=S+2*F(X+H2)+F(X);
      end;
      Integral:=S*H/3;
     end;

    function IntegralE (F :TFuncX; A,B :extended; E :extended) :extended;
     {------------------------------------------------------------------}
     {      Возвращает  значение  интеграла  вычесленного  методом      }
     { Симпсона c оценкой погрешности:                                  }
     {  F - подинтегральная функция ( function(X :extended):extended )  }
     {  A - нижний предел интегрирования;                               }
     {  B - верхний предел интегрирования;                              }
     {  E - значение погрешность интегрирования.                        }
     {------------------------------------------------------------------}
     var
      I :word;
      E1,H,H2,X,S,S1,S2,S3 :extended;
     begin
      if B<>A then begin
       E1:=E*15;  H:=(B-A)/2;  S:=2*F(A+H);  S1:=F(A)+F(B)+S;  S:=S1+S;
       repeat
        S2:=0;  S3:=S;  H2:=H;  H:=H/2;  X:=A+H;
        while (X<B) = (H>0) do begin
         S2:=S2+F(X);
         X:=X+H2
        end;
        S2:=2*S2;
        S1:=S1+S2;
        S:=S1+S2
       until Abs(1-S/(2*S3))<=E1;
       IntegralE:=S*H/3
      end else IntegralE:=0
     end;

    function DIntegral (F:TFuncXY; A,B:extended; N:word; C,D:extended; M:word) :extended;
     {-----------------------------------------------------------}
     {      Возвращает значение двойното интеграла вычесленного  }
     { методом Симпсона:                                         }
     {  F - подинтегральная функция                              }
     {      ( function (X,Y :extended):extended)                 }
     {  A - нижний предел интегрирования по X;                   }
     {  B - верхний предел интегрирования по X;                  }
     {  N - количество разбиений интервала интегрирования по X;  }
     {  C - нижний предел интегрирования по Y;                   }
     {  D - верхний предел интегрирования по Y;                  }
     {  M - количество разбиений интервала интегрирования по Y.  }
     {-----------------------------------------------------------}
     var
       I :word;
       L,L2,H,H2,X,S :extended;

       function IntegralY (Cnst :extended) :extended;
        var
         I :word;
         Y,S :extended;
        begin
         S:=(F(Cnst,C)+F(Cnst,D))/2+2*F(Cnst,C+L2);
         Y:=C;
         for I:=1 to M-1 do begin
          Y:=Y+L;
          S:=S+2*F(Cnst,Y+L2)+F(Cnst,Y)
         end;
         IntegralY:=S
        end;

       begin
        H:=(B-A)/N;
        H2:=H/2;
        L:=(D-C)/M;
        L2:=L/2;
        S:=(IntegralY(A)+IntegralY(B))/2+2*IntegralY(A+H2);
        X:=A;
        for I:=1 to N-1 do begin
         X:=X+H;
         S:=S+2*IntegralY(X+H2)+IntegralY(X)
        end;
        DIntegral:=S*H*L/9
       end;

    procedure Gauss (N :byte; var B,Y; var C :byte);
     {----------------------------------------------------------}
     {      Pешение СЛАУ методом Гаусса с выбором главного      }
     { элемента:                                                }
     {  N - количество неизвесных (1..50);                      }
     {  B - элементы матрицы ( array[1..N,1..N+1] of extended); }
     {  Y - найденные величины ( array[1..N] of extended);      }
     {  C - код завершения:                                     }
     {   0 - успешное;                                          }
     {   1 - нет однозначного решения;                          }
     {   2 - редкая матрица.                                    }
     {                                                          }
     {  P.S. Матрица перестроена !                              }
     {----------------------------------------------------------}
     var
      A :array [1..2500] of extended absolute B;
      X :array [1..50] of extended absolute Y;
      I,J,K,L,K1,N1 :byte;
      R,S :extended;

       function Ind(I,J :byte) :word;
        begin
         Ind:=(I-1)*(N1)+J
        end;

     begin
      N1:=N+1;
      C:=2;
      for K:=1 to N do begin
       K1:=K+1;
       S:=A[Ind(K,K)];
       J:=K;
       for I:=K1 to N do begin
        R:=A[Ind(I,K)];
        if Abs(R)>Abs(S) then begin
         S:=R;
         J:=I
        end
       end;
       if S=0 then Exit;
       if J<>K then for I:=K to N1 do begin
        R:=A[Ind(K,I)];
        A[Ind(K,I)]:=A[Ind(J,I)];
        A[Ind(J,I)]:=R
       end;
       for J:=K1 to N1 do A[Ind(K,J)]:=A[Ind(K,J)]/S;
       for I:=K1 to N do begin
        R:=A[Ind(I,K)];
        for J:=K1 to N1 do A[Ind(I,J)]:=A[Ind(I,J)]-A[Ind(K,J)]*R
       end
      end;
      C :=1;
      if S = 0 then Exit;
      for I:=N downto 1 do begin
       S:=A[Ind(I,N1)];
       for J:=I+1 to N do S:=S-A[Ind(I,J)]*X[J];
       X[I]:=S
      end;
      C:=0
     end;

   function Sgn(X: extended): integer;
    begin
     if X < 0 then Sgn:=-1 else
     if X > 0 then Sgn:=1 else Sgn:=0
    end;

   function Dich(A,B,E: extended;F: TFuncX): extended;
    var
     I: integer;
     X,Y,Max: extended;
     P: single;
    begin
     I:=Sgn(F(B));
     Max:=Abs(A-B);
     while Abs(B-A) > E do begin
      X:=(A+B)/2;
      Y:=F(X);
      if Abs(Y) < E then Break;
      if Sgn(Y) <> I then A:=X else B:=X;
     end;
     Dich:=(B+A)/2;
    end;

   function MiniGold(F :TFuncX; A,B :extended) :extended;
    {----------------------------------------------------------}
    {      Возвращает аргумент минимального значение функции F }
    { одной переменной вычисленное методом золотого сечения:   }
    {  F - минимизируемая функция;                             }
    {  A - нижний граница аргумента;                           }
    {  B - верхний предел аргумента.                           }
    {----------------------------------------------------------}
    var
     F1,F2,X,G,R :extended;
    begin
     G:=(-1+Sqrt(5))/2;
     R:=(B-A)*G;
     A:=A+R;
     B:=B-R;
     F1:=F(A);
     F2:=F(B);
     while R > Eps do begin
      R:=R*G;
      if F1 < F2 then begin
       X:=B+R;
       B:=A;
       A:=X;
       F2:=F1;
       F1:=F(X);
      end else begin
       X:=A-R;
       A:=B;
       B:=X;
       F1:=F2;
       F2:=F(X)
      end;
      Write('*')
     end;
     MiniGold:=X
    end;

 end.
