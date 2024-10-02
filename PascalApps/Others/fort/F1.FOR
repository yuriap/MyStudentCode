	DIMENSION AM(5,5),DELA(20),DELB(20),GAM1(20),GAM2(20),GAM3(20),
     *  VM(5),FRA(5),XK(4,20),YK(4,20),XB(3,20),YB(3,20)
	DIMENSION XBA(20,20),YBA(20,20),XBB(20,20),YBB(20,20),S1(4),
     *  S2(3),S3(2),S4(3),OM1(4),UDA(2,20),UDB(2,20)
	DATA AM/.95493,.31813,.19099,.13642,1.,-.95493,.95493,.31813,
     *  .19099,1.,-.31813,-.95493,.95493,.31813,1.,-.19099,-.31813,
     *  -.95493,.95493,1.,-.13642,-.19099,-.31813,-.95493,1./
	DATA DELA/20*0./,DELB/20*0./,XBA/400*0./,XBB/400*0./,YBA/400*
     *  0./,YBB/400*0./
	DATA S1/-.5,-.166666,.166666,.5/,S2/-.33333,0.0,.33333/,
     *  S3/-.66666,.66666/
	PI=3.1415926
	WRITE(*,*) 'ขฅคจโฅ กฅงเ งฌฅเญใ๎ ็ แโฎโใ ขเ ้ฅญจ๏ จ'
	WRITE(*,*) '่ ฃ ฏฎ ขเฅฌฅญจ'
	READ(*,*) OM,TAY
C        2
	DO 2 N=1,20
	DO 1 N1=1,4
	XK(N1,N)=S1(N1)*COS(N*OM*TAY)
	YK(N1,N)=S1(N1)*SIN(N*OM*TAY)
1	CONTINUE
	DO 3 N2=1,3
	XB(N2,N)=S2(N2)*COS(N*OM*TAY)
	YB(N2,N)=S2(N2)*SIN(N*OM*TAY)
3	CONTINUE
	PP1=-2./3.
	PP2=N*OM*TAY
	XBA(N,N)=PP1*COS(PP2)
	YBA(N,N)=PP1*SIN(PP2)
	XBB(N,N)=-1.*XBA(N,N)
	YBB(N,N)=-1.*YBA(N,N)
2	CONTINUE
C        3
	DO 100 IT=1,20
	DO 5 I1=1,4
	Z=1.
	IF(XK(1,IT).GT.0.) Z=-1.
	OM1(I1)=OM*S1(I1)*Z
5	CONTINUE
	CS=COS(OM*TAY*IT)
	SN=SIN(OM*TAY*IT)
	DO 6 I2=1,4
	VX=0.
	VY=0.
	DO 7 I3=1,20
	IF(DELA(I3).EQ.0.)GOTO 8
	CALL SPE(DELA(I3),XK(I2,IT),XBA(I3,IT),YK(I2,IT),YBA(I3,IT),VX1,
     *  VY1)	
	VX=VX+VX1
	VY=VY+VY1
8	IF(DELB(I3).EQ.0.)GOTO 7
	CALL SPE(DELB(I3),XK(I2,IT),XBB(I3,IT),YK(I2,IT),YBB(I3,IT),VX2,
     *  VY2)
	VX=VX+VX2
	VY=VY+VY2
7	CONTINUE
	FRA(I2)=OM1(I2)-CS-VX*CS-VY*SN
6	CONTINUE
	FRA(5)=0.
C        4
	CALL GAUSS (AM,FRA,VM,5,IER)
	IF(IER.NE.0)GOTO 9
	DELA(IT)=VM(1)
	GAM1(IT)=VM(2)
	GAM2(IT)=VM(3)
	GAM3(IT)=VM(4)
	DELB(IT)=VM(5)
	GOTO 10
9	WRITE(*,*)'–จเชใซ๏ๆจจ ญฅ ฎฏเฅคฅซฅญ๋ ญ ',IT,'่ ฃใ'
	WRITE(*,*)'ฎญฅๆ ข๋็จแซฅญจฉ'
C        5
10	S4(1)=GAM1(IT)
	S4(2)=GAM2(IT)
	S4(3)=GAM3(IT)
	DO 51 J1=1,20
	UDA(1,J1)=0.
	UDA(2,J1)=0.
	UDB(1,J1)=0.
	UDB(2,J1)=0.
	DO 52 J2=1,20
	IF(J1.EQ.J2) GOTO 52
	IF(DELA(J2).EQ.0.) GOTO 521
	CALL SPE(DELA(J2),XBA(J1,IT),XBA(J2,IT),YBA(J1,IT),YBA(J2,IT),D1
     *  ,D2)
	UDA(1,J1)=UDA(1,J1)+D1
	UDA(2,J1)=UDA(2,J1)+D2
521	IF(DELB(J2).EQ.0.) GOTO 52
	CALL SPE(DELB(J2),XBB(J1,IT),XBB(J2,IT),YBB(J1,IT),YBB(J2,IT),D3
     *  D4)
	UDB(1,J1)=UDB(1,J1)+D3
	UDB(2,J1)=UDB(2,J1)+D4
52	CONTINUE
	DO 53 J3=1,20
	IF(DELB(J3).EQ.0.)GOTO 531
	CALL SPE(DELB(J3),XBA(J1,IT),XBB(J3,IT),YBA(J1,IT),YBB(J3,IT),D5
     *  ,D6)
	UDA(1,J1)=UDA(1,J1)+D5
	UDA(2,J1)=UDA(2,J1)+D6
531	IF(DELA(J3).EQ.0.) GOTO 53
	CALL SPE(DELA(J3),XBB(J1,IT),XBA(J3,IT),YBB(J1,IT),YBA(J3,IT),D7
     *  ,D8)
	UDB(1,J1)=UDB(1,J1)+D7
	UDB(2,J1)=UDB(2,J1)+D8
53	CONTINUE
	DO 54 J4=1,3
	CALL SPE(S4(J4),XBA(J1,IT),XB(J4,IT),YBA(J1,IT),YB(J4,IT),F1,F2)
	CALL SPE(S4(J4),XBB(J1,IT),XB(J4,IT),YBB(J1,IT),YB(J4,IT),F3,F4)
	UDA(1,J1)=UDA(1,J1)+F1
	UDA(2,J1)=UDA(2,J1)+F2
	UDB(1,J1)=UDB(1,J1)+F3
	UDB(2,J1)=UDB(2,J1)+F4
54	CONTINUE
	UDA(2,J1)=UDA(2,J1)+1.
	UDB(2,J1)=UDB(2,J1)+1.
51	CONTINUE
C	 6
	DO 61 L1=1,19
	XBA(L1,IT+1)=XBA(L1,IT)+UDA(1,L1)*TAY
	YBA(L1,IT+1)=YBA(L1,IT)+UDA(2,L1)*TAY
	XBB(L1,IT+1)=XBB(L1,IT)+UDB(1,L1)*TAY
	YBB(L1,IT+1)=YBB(L1,IT)+UDB(2,L1)*TAY
61	CONTINUE
100	CONTINUE
C	 7
711	WRITE(*,*)'๋ขฎค ชฎฎเซจญ โ แขฎกฎคญ๋ๅ ขจๅเฅฉ'
	WRITE(*,*)'1 ข โฅ็ฅญจฅ ฎคญฎฃฎ ่ ฃ '
	WRITE(*,*)'2 ฏ เ๋ ขจๅเฅฉ ง  ขเฅฌ๏ จๅ แใ้ฅแโขฎข ญจ๏'
	WRITE(*,*)'3 ง ชฎญ็จโ์ เ กฎโใ'
	READ(*,*) MM1
	GOTO(71,72,721) MM1
71	WRITE(*,*)'ขฅคจโฅ ญฎฌฅเ ่ ฃ '
	READ(*,*) IST
	WRITE(*,*) IST
	U=IST*OM*TAY
	U1=U*180./PI
	U2=U1
C	IF(U1.GE.360.)U2=AMOD(U1,360)
	WRITE(*,*)'’ฅชใ้จฉ ใฃฎซ ฏฎขฎเฎโ ',U2,'ฃเ ค'
	WRITE(*,*)'จๅเจ, แฎ่ฅค่จฅ แ ชฎญๆ  €'
	DO 73 LL=1,IST
	WRITE(*,70) LL,XBA(LL,IST),YBA(LL,IST)
73	CONTINUE
	WRITE(*,*)'จๅเจ แฎ่ฅค่จฅ แ ชฎญๆ  '
	DO 74 LLL=1,IST
	WRITE(*,70) LLL,XBB(LLL,IST),YBB(LLL,IST)
74	CONTINUE
	WRITE(*,*)'เฎคฎซฆจโ์ โฅชใ้จฉ ข๋ขฎค 1'
	WRITE(*,*)'๋ฉโจ ข ฏฅเขฎฅ ฌฅญ๎ 2'
	READ(*,*) MM2
	GOTO(71,711) MM2
72	WRITE(*,*)'ขฅคจโฅ ญฎฌฅเ ฏ เ๋ ขจๅเฅฉ'
	READ(*,*) NO
	WRITE(*,*) NO
	DO 75 KK=NO,20
	UUU=KK*OM*TAY
	UU1=UUU*180./PI
	UU2=UU1
C	IF(UU1.GE.360.) UU2=AMOD(UU1,360)
	WRITE(*,701) KK,UU2,XBA(NO,KK),YBA(NO,KK),XBB(NO,KK),YBB(NO,KK)
75	CONTINUE
	WRITE(*,*)'เฎคฎซฆจโ์ โฅชใ้จฉ ข๋ขฎค 1'
	WRITE(*,*)'๋ฉโจ ข ฏฅเขฎฅ ฌฅญ๎ 2'
	READ(*,*) MM3
	GOTO(72,711)MM3
70	FORMAT(2X,'ญฎฌฅเ ขจๅเ๏',I3,'X=',G10.5,3X,'Y=',G10.5)
701	FORMAT(2X,I2,1X,F8.4,1X,'XA=',G10.5,1X,'YA=',G10.5,1X,'XB=',G10
     *	.5,1X,'YB=',G10.5)
721	STOP
	END
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
        REAL A(N,N),X(N),B(N),WorkA(5,5),y,z
        INTEGER N,Ierr,IX(5),i,j,k,l,m,line,column,cl,cc,cl1,cc1,N1,
     +        N2,IY(5)
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
	SUBROUTINE SPE(GM,XT,XV,YT,YV,UX,UY)
	R1=2.*3.1415926*((XT-XV)**2.+(YT-YV)**2.)
	UX=-1.*GM*(YT-YV)/R1
	UY=GM*(XT-XV)/R1
	RETURN
	END
