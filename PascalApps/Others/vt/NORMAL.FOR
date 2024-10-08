 	DIMENSION XB(20),YB(20),XK(20),YK(20),ALFABX(20),ALFABY(20),
     *  ALFAKX(20),ALFAKY(20),DDY(5),GBX(20),GBY(20),GKX(20),GKY(20)
	WRITE(*,*) 'Input KA and CKC'
	READ(*,*) KA,CKC
	WRITE(*,77) KA,CKC
77	FORMAT(1X,'KA=',I2,2X,'CKC=',F5.3)
	PI=3.1415926
	PAR=0.1
	AE=PAR*KA
	CE=PAR*CKC
	AAE=AE**2/(1.-AE)
	DE=1.-AE
	JJK=14+KA
	JJB=13+KA
	IK=1
	Y=0.
6	YK(IK)=Y
	YB(IK)=Y-PAR/2.
	Y=Y-PAR
	IK=IK+1
	IF(Y .GT. (-1.)*(AE-PAR)) GOTO 6
	HB=(-1.)*AE
	YK(IK)=HB+PAR
	YB(IK)=HB+PAR*0.7
	IK=IK+1
	YK(IK)=HB+PAR*0.4
	YB(IK)=HB+PAR*0.2
	IK=IK+1
	LR=IK
	YK(IK)=AE*(-1.)
	YB(IK)=HB+PAR*0.2
	IK=IK+1
	YK(IK)=HB+PAR*0.4
	YB(IK)=HB+PAR*0.7
	IK=IK+1
	YK(IK)=HB+PAR
	YB(IK)=HB+PAR*1.5
	Y=-1.*(AE-2.*PAR)
	IK=IK+1
15	YK(IK)=Y
	YB(IK)=Y+PAR/2.
	IK=IK+1
	Y=Y+PAR
	SD=Y-1.+AE-PAR/2.
	IF(SD) 15,15,16
16	DO 71 LL=JJK,20
	YK(LL)=0.
71	CONTINUE
	DO 72 LQ=JJB,20
	YB(LQ)=0.
72	CONTINUE
	DO 8 IL=1,20
	IF(IL-LR) 51,10,10
51	XK(IL)=-1.*CE*SQRT(AE**2-YK(IL)**2)/AE
	XB(IL)=-1.*CE*SQRT(AE**2-YB(IL)**2)/AE	
	ALFAKX(IL)=ATAN((-1.)*CE*YK(IL)/(AE*SQRT(AE**2-YK(IL)**2)))
	ALFABX(IL)=ATAN((-1.)*CE*YB(IL)/(AE*SQRT(AE**2-YB(IL)**2)))
	ALFAKY(IL)=ALFAKX(IL)-PI/2.
	ALFABY(IL)=ALFABX(IL)-PI/2.
	GOTO 8
10	IF(YK(IL) .GT. AAE) GOTO 11
	XK(IL)=CE*SQRT(AE**2-YK(IL)**2)/AE
	IF(AE+YK(IL)) 41,41,42
42	ALFAKX(IL)=PI+ATAN(CE*YK(IL)/(AE*SQRT(AE**2-YK(IL)**2)))
	GOTO 43
41	ALFAKX(IL)=PI/2.
43	ALFAKY(IL)=ALFAKX(IL)-PI/2.
	IF(YB(IL) .GT. AAE) GOTO 11
	XB(IL)=CE*SQRT(AE**2-YB(IL)**2)/AE
	ALFABX(IL)=PI+ATAN(CE*YB(IL)/(AE*SQRT(AE**2-YB(IL)**2)))
	ALFABY(IL)=ALFABX(IL)-PI/2.
	GOTO 8
11      ALB=SQRT(CE**2-(AE*CE)**2/((1.-AE)**2))/(AE**2/(1.-AE)
     *  -1.+AE)
	ALKX=PI-ATAN(ALB)
	ALKY=ALKX-PI/2.
	ALFAKX(IL)=ALKX
	ALFAKY(IL)=ALKY
	XK(IL)=(YK(IL)+AE-1.)*ALB
	ALFABX(IL)=ALKX
	ALFABY(IL)=ALKY
	XB(IL)=(YB(IL)+AE-1.)*ALB
8	CONTINUE
	DO 91 IV=JJK,20
	XK(IV)=0.
	ALFAKX(IV)=0.
	ALFAKY(IV)=0.
91	CONTINUE
	DO 92 IC=JJB,20
	XB(IC)=0.
	ALFABX(IC)=0.
	ALFABY(IC)=0.
92	CONTINUE
	DO 7 IU=1,20
	GKX(IU)=ALFAKX(IU)*180./PI
	GKY(IU)=ALFAKY(IU)*180./PI
	GBX(IU)=ALFABX(IU)*180./PI
	GBY(IU)=ALFABY(IU)*180./PI
7	CONTINUE
	WRITE(*,*) 'CONTROL POINT'
	DO 9 K=1,20
	WRITE(*,22) K,XK(K),YK(K),GKX(K),GKY(K),ALFAKX(K),ALFAKY(K)
22	FORMAT(1X,'N',I2,1X,'X=',F5.3,1X,'Y=',F5.3,1X,'GRD X:',1X,F7.3, 
     * 1X,'Y:',1X,F9.3,1X,'RAD X:',1X,F7.3,1X,'Y:',F7.3)
9	CONTINUE
	WRITE (*,*) 'ROTOR'
	DO 12 ID=1,20
	WRITE (*,88) ID,XB(ID),YB(ID),GBX(ID),GBY(ID),ALFABX(ID),ALFABY
     *	(ID)
88	FORMAT(1X,'N',I2,1X,'X=',F5.3,1X,'Y=',F5.3,1X,'GRD X:',1X,F7.3,
     * 1X,'Y:',1X,F9.3,1X,'RAD X:',1X,F7.3,1X,'Y:',F7.3)
12	CONTINUE
	END		