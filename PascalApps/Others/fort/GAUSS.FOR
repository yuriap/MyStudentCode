c       CALL GAUSS(A,BB,G,NNN,Ierr)
       Subroutine Gauss(A,B,X,N,Ierr)
Cษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
Cบ               ฅ่ฅญจฅ แจแโฅฌ๋ ซจญฅฉญ๋ๅ ใเ ขญฅญจฉ                    บ
Cบ                          ฌฅโฎคฎฌ  ใแแ                              บ
Cบ                       € - ฌ โเจๆ  แจแโฅฌ๋                           บ
Cบ                           คฎซฆญ  ก๋โ์ ใฏ ชฎข ญ                      บ
Cบ                           ข แ-ง ใฃฎซ                                บ
Cบ                        - ฏเ ข ๏ ็ แโ์                              บ
Cบ                       • - เฅ่ฅญจฅ                                   บ
Cบ                       N - เ งฌฅเญฎแโ์ แจแโฅฌ๋                       บ
Cบ                       Ierr - ฎ่จกช , = 0, ฅแซจ เฅ่ฅญจ๏ ฅแโ์         บ
Cบ                            = ญฎฌฅเใ ฏฅเขฎฃฎ ใเ ขญฅญจ๏, คซ๏          บ
Cบ                              ชฎโฎเฎฃฎ ขฅคใ้จฉ ํซ-โ ฌ ซ.             บ
Cศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
        REAL A(N,N),X(N),B(N),WorkA(20,20),y,z
        INTEGER N,Ierr,IX(20),i,j,k,l,m,line,column,cl,cc,cl1,cc1,N1,
     +        N2,IY(20)
        Ierr=0
        N1=N-1
        N2=N-2
         Do 20 i=1,N
          Do 10 j=1,N
           WorkA(i,j)=A(i,j)
 10    Continue
         IY(i)=i
         IX(i)=i
         X(i)=B(i)
 20     Continue
Cษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
Cบ                  ญ ็ ซ์ญ ๏  ใแโ ญฎขช  ง ชฎญ็ฅญ                      บ
Cศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
        Do 110 cl=1,N1
        cc=cl
        line=cl
        column=cc
Cษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
Cบ                         ฏฎจแช ฌ ๅ.ํซ-โ                              บ
Cศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
        Do 30 i=cl,N
        Do 30 j=cc,N
       If(Abs(WorkA(line,column)).GE.Abs(WorkA(i,j)))Goto 30
         line=i
         column=j
 30     Continue
        If(cl.EQ.line)Goto 50
Cษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
Cบ                  ฏฅเฅแโ ญฎขช  แโเฎช  line จ cl                      บ
Cศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
        Do 40 j=cc,N
         y=WorkA(line,j)
         WorkA(line,j)=WorkA(cl,j)
         WorkA(cl,j)=y
 40   Continue
      z=X(line)
      X(line)=X(cl)
        X(cl)=z
        k=IY(line)
        IY(line)=IY(cl)
        IY(cl)=k
 50   Continue
        If(cc.EQ.column)Goto 70
Cษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
Cบ              ฏฅเฅแโ ญฎขช  แโฎซกๆฎข แแ จ column                      บ
Cศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
        Do 60 i=1,N
         y=WorkA(i,column)
         WorkA(i,column)=WorkA(i,cl)
         WorkA(i,cl)=y
 60   Continue
      k=IX(column)
      IX(column)=IX(cc)
        IX(cc)=k
 70   Continue
        If(Abs(WorkA(cl,cc)).GE.1.E-20)Goto 75
Cษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
Cบ            คฅซฎ - คเ๏ญ์,ขฅคใ้จฉ ํซ-โ แซจ่ชฎฌ ฌ ซ.                   บ
Cศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
        Ierr=IY(cl)
        Goto 160
 75     Continue
        cl1=cl+1
        cc1=cc+1
        Do 80 j=cc1,N
         WorkA(cl,j)=WorkA(cl,j)/WorkA(cl,cc)
 80   Continue
        X(cl)=X(cl)/WorkA(cl,cc)
        WorkA(cl,cc)=1.
        Do 100 i=cl1,N
         z=WorkA(i,cc)
         WorkA(i,cc)=0.
         Do 90 j=cc1,N
          WorkA(i,j)=WorkA(i,j)-WorkA(cl,j)*z
 90    Continue
       X(i)=X(i)-X(cl)*z
100     Continue
110   Continue
Cษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
Cบ                   ฏเ๏ฌฎฉ ๅฎค ง ชฎญ็ฅญ                               บ
Cศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
         If(Abs(WorkA(N,N)).GE.1.E-20)Goto 120
Cษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
Cบ            คฅซฎ - คเ๏ญ์,ขฅคใ้จฉ ํซ-โ แซจ่ชฎฌ ฌ ซ.                   บ
Cศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
         Ierr=-IY(N)
         Goto 160
120    Continue
         X(N)=X(N)/WorkA(N,N)
        Do 140 k=0,N2
         j=N-k
         m=k+1
         Do 130 l=m,N1
          i=N-l
          z=WorkA(i,j)
          X(i)=X(i)-X(j)*z
130    Continue
140   Continue
        Do 150 i=1,N
         WorkA(i,1)=X(i)
150   Continue
        Do 155 i=1,N
         k=IX(i)
         X(k)=WorkA(i,1)
155     Continue
160   Return
        END
