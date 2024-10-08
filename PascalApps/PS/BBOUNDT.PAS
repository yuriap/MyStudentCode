{***********************************************}
{**  ��᪨� ���㤠��⢥��� 㭨������      **}
{**  ��䥤� ���஬�設                       **}
{**  �������� �������ࣥ⨪�              **}
{***********************************************}
{**  �ணࠬ�� ���� ��ࠬ��஢ 	      **}
{**  ��樮��୮�� ������୮�� ���࠭�筮��   **}
{**  ᫮�                                     **}
{***********************************************}
{** Copyright (c) ����� �.�.     19.07.95     **}
{***********************************************}
Unit BBoundT;
Interface
uses Objects,Views,Memory,Drivers,App,Dialogs,MsgBox,
      Graph,Dos,Crt,
     BGraphic;
const
    DimHor = 100;
    DimVert = 40;

    FileGrUsl:PathStr='Fi&FiBlz.dat';{����� � ⠡��栬� �㭪権 � � �_����
                                  �� �.-�.}
    EttaDelta=2.4;{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�.)}
    Top:boolean=true;{�࠭�� �.�.}
    Bottom:boolean=false;{�����孮���}
var
{  Left:L;
  Right,Incp:R;}
  ParW:real;
type
  TBoundRec = record
  Nu,{�離���� [�^2/c]}
  U0,{᪮���� ��⮪� [�/c]}
  L ,{����� ����⨭� [�]}
  Ro,{�������� ������� [��/�^3]}

  X0,{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
  Psi,{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
  S,{��ࠬ��� ��।�����}
  M,{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..M)}
  N,{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..N)}
  MaxIter{���ᨬ��쭮� �᫮ ���権}  :string[7];

  IfView:word;
  ParW:string[7];
  parNevazka:String[7];{����稭� ���離�}
  end;
var
   BoundRec:TBoundRec;

type
    TMainSetka = array [0..DimVert,0..DimHor] of real;
    TComplSetka = TMainSetka;
    TDelta = array [0..DimHor] of real;
    TABCoeff = array [0..DimVert] of real;

    PBoundLayer = ^TBoundLayer;
    TBoundLayer = object(TObject)
       Nu:real;{�離����}
       U0:real;{᪮���� ��⮪�}
       L :real;{����� ����⨭�}
       Ro:real;{�������� �������}
       Re:real;{�᫮ ��������}
       X0:real;{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
       Psi:real;{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
       S:real;{��ࠬ��� ��।�����}
       M:word;{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..M)}
       N:word;{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..N)}
       dDelta:real;{��砫쭮� ���饭�� ⮫騭� �.�.}
       cDelta:real;{⥪�饥 ���饭�� ⮫騭� �.�.}
       dEtta:real;{蠣 �⪨ �� ��ଠ��}
       dDzetta:real;{蠣 �⪨ ����� �����孮��}
       Iteration:word;{���稪 ���権}
       MaxIter:word;{���ᨬ��쭮� �᫮ ���権}
       parNevazka:real;{����稭� ���離�}
       CurrN,CurrM:integer;{���稪� ⥪��� ��ଠ�� � ᫮� ᮮ⢥��⢥���}
       MainSetka:TMainSetka;{�᭮���� �⪠}
       ComplementSetka:TComplSetka;{�ᯮ����⥫쭠� �⪠}
       Delta:TDelta;{⮫騭� �.�. ����� �����孮��}
       A,B:TABCoeff;{���ᨢ� �ண������ �����樥�⮢}
       Fi,FiStrih:TABCoeff;
       Tay:TDelta;{���⥫�� ����殮��� �� �����孮��}
       C_m:TDelta;{�����樥�� �७��}
       F_tr,C_tr:real;{ᨫ� �७�� � �� �����.}
       constructor Init;
       procedure PutParam;
       Procedure NewParam;
       procedure Run(Plase:Word);{���� �.�.}
       {�����砥� ��砫�� ���祭�� ��ࠬ. � ���������� 㧫��}
       procedure PutFirstValue;
       procedure GoingForU;{�ண���� �� 㧫�� �᭮���� �⪨}
       procedure GoingForV;{�ண���� �� 㧫�� �ᯮ����⥫쭮� �⪨}
       procedure StoreNormal;{���������� �।��騩 १����}
       function GetNevazkaForU:real;{���᫥��� ���離�}
       {���᫥��� �ண������ �����樥�⮢ ��� ⥪�饩 ��ଠ��}
       procedure GetAB;
       {�����. � ��㫠� �ண������ �����.}
       procedure Alfa_Tetta(var Alf,Be,Ga,Te:real);
       {�����. ��� �।���� �㭪権, �� �.-�. a,b,c,d}
       procedure AmBmCmDm(var Aa,Bb,Cc,Dd:real);
       {�ந������� �த����� ᪮��� �� ��ଠ�� True - �� �࠭��(Top)}
       { False - �� �����孮�� (Bottom)}
       function Diff(TopOrBottom:Boolean):real;
       procedure GetTay;{���. ���⥫쭮�� ����殮��� �� �����孮��}
       procedure GetC_m;{�����樥�� �७��}
       procedure GetF_tr;{ᨫ� �७��}
       procedure GetC_tr;{����. ᨫ� �७��}
       destructor Done;virtual;
       private
       Last:real;{�।��饥 ���祭�� ��� ���. ���離�}
       end;

       PBoundDlgBox = ^TBoundDlgBox;
       TBoundDlgBox = object(TDialog)
          constructor Init;
          end;
function Sign(Numer:real):shortint;
var      ABound:PBoundLayer;
Implementation
Uses Blaz001;

function Sign(Numer:real):shortint;
{���� �᫠}
begin
  If Numer > 0.00000000001 Then Begin Sign:=1;Exit;end;
  If Numer < -0.00000000001 Then Begin Sign:=-1;Exit;end;
  If Numer = 0.0 Then Begin Sign:=0;Exit;end;
end;
constructor TBoundLayer.Init;
var
   i:word;
   x:real;
   z:integer;
   DataFile : text;
begin
  inherited Init;
  {����㧪� ⠡��� �㭪権 � � �_����(ᮧ����� �� �. MkBound.pas)}
 Assign(DataFile,FileGrUsl);
 Reset(DataFile);
  for i:= 0 to DimVert do begin
    read(DataFile,FiStrih[i]);
    readln(DataFile,Fi[i]);
    end;
 Close(DataFile);
 PutParam;
end;{TBoundLayer.Init}
procedure TBoundLayer.PutParam;
var i,z:integer;
  begin
  {��樠������ �����}
  Val(BoundRec.Nu,Nu,z);{�離���� [�^2/c]}
  Val(BoundRec.U0,U0,z);{᪮���� ��⮪� [�/c]}
  Val(BoundRec.L,L,z);{����� ����⨭� [�]}
  Val(BoundRec.Ro,Ro,z);{�������� ������� [��/�^3]}

  Val(BoundRec.X0,X0,z);{X0 � % �� dDzetta ���
  ������� �࠭�筮�� �᫮��� (� �.-�.��� 93)}
  Val(BoundRec.Psi,Psi,z);{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
  Val(BoundRec.S,S,z);{��ࠬ��� ��।�����}
  M:=DimVert;{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..M)}
  N:=DimHor;{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..N)}
  Val(BoundRec.MaxIter,MaxIter,z);{���ᨬ��쭮� �᫮ ���権}
  Val(BoundRec.ParW,ParW,z);
  Val(BoundRec.parNevazka,parNevazka,z);{����稭� ���離�}
  Re:=U0*L/Nu;{�᫮ ��������}
  dEtta:=1/(M);{蠣 �⪨ �� ��ଠ��}
  dDzetta:=1/(N);{蠣 �⪨ ����� �����孮��}
  {���樠������ ����� ⮫設� �.�.}
{  al:=U0/(dDzetta*0.01*X0*L);{�����. 'a' �� �.-H.}
  Delta[0]:=7*Sqrt(X0/(N*100));{⮫騭� �.�. � 1-� ��ଠ��}
  dDelta:=Delta[0]*0.05;{��砫쭮� ���饭�� ⮫騭� �.�.}
  {����. �᭮���� �⪨}
  {�࠭�筮� �᫮��� - �த��쭠� ᪮���� �� �࠭�� �⪨}
  For i:=0 to M do  MainSetka[i,0]:=FiStrih[i];
  {����. �ᯮ����⥫쭮� �⪨}
  {�࠭�筮� �᫮��� - �����筠� ᪮���� �� �࠭�� �⪨}
  For i:=0 to M do  ComplementSetka[i,0]:=Fi[i]*0.5*Sqrt(N*100/X0);
  {����. ���ᨢ�� �ண������ �����樥�⮢}
end;
procedure TBoundLayer.NewParam;
begin
  PutParam;
end;{TBoundLayer.NewParam}

destructor TBoundLayer.Done;
begin
  inherited Done;
end;
procedure TBoundLayer.Run(Plase:Word);
Label A1;
var af,bf:boolean;
    df:real;
    As:word;
    cDeltaOld:real;
    Criterium:string[17];
    PrChar:char;
      Vec:PZVector;
      i:word;
      r:real;
    EndProgon:boolean;
  procedure InstalValue(Vector:PZVector);
  begin
      If Iteration > MaxIter Then Vector^.Labels:='first'
         else Vector^.Labels:=IntToStr(CurrN)+'.'+IntToStr(Iteration);
         {RealToStr(Sign(cDelta));}
      Vector^.Color:=5;
      Vector^.Visible:=true;
  end;
begin
   PrChar:='-';
   repeat{横� ���᫥��� ��ࠬ��஢ � ��ଠ���}
   PutFirstValue;{�����砥� ��砫�� ���祭�� ��ࠬ. � ���������� 㧫��}
   {****************************************}
   If BoundRec.IfView = 0 then begin
     SetGraphMode(grMode);
    Iteration:=MaxIter+2;
    Vec:=New(PZVector,Init(DimVert+1));
    For i:=0 to DimVert do
      Vec^.Put(i,MainSetka[i,CurrN]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
    Graphic^.Execute;
    Graphic^.DelLastVector;
    Graphic^.StoreParam;end;
    {*******************************************}
   Iteration:=1;{���稪 ���権}
   cDelta:=dDelta;{Delta[CurrN]*0.01;{⥪�饥 ���饭�� ⮫騭� �.�.}
   cDeltaOld:=cDelta;
   repeat{横� ���権 �� ⮫騭� �.�.}
   {�������� ⮫騭� �.�. � ⥪�饩 ���樨}
   If BoundRec.IfView = 3 Then  Delta[CurrN]:=Delta[CurrN]
    else begin
   Delta[CurrN]:=Delta[CurrN]+cDelta;
   EndProgon:=false;
   repeat{���������� ��⥬� � �� �襭��}
   StoreNormal;{���������� �।��騩 १����}
   GoingForU;{�ண���� �� 㧫�� �᭮���� �⪨}
   GoingForV;{�ண���� �� 㧫�� �ᯮ����⥫쭮� �⪨}
   If Abs(GetNevazkaForU) <= parNevazka Then EndProgon:=true;

   {****************************************}
    If BoundRec.IfView = 0 then begin
    Vec:=New(PZVector,Init(DimVert+1));
    For i:=0 to DimVert do
      Vec^.Put(i,MainSetka[i,CurrN]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
    Graphic^.Execute;
    Graphic^.DelLastVector;
    Graphic^.StoreParam;
    end;
    {*******************************************}

   until EndProgon;
   end;
   {�஢�ઠ ����� �ந������� dU/dy �� y = ⮫騭� �.�.}
   if (CurrN = 1) and (Iteration = 18) then
       begin
       Criterium:='9';
       end;
   cDelta:=-1*Abs(cDelta)*Sign(Diff(Top));
   If not(Sign(cDelta) = Sign(cDeltaOld)) then begin
     cDelta:=cDelta*0.75;
     end;
     cDeltaOld:=cDelta;

   Iteration:=Iteration+1;{���饭�� ���稪� ���権}
   {�஢�ઠ �᫮��� dU/dy �� y=delta <= Psi}
   df:=Diff(Top);
   af:=(Iteration > MaxIter);
   bf:=((0 <= Abs(df)) and (Abs(df) <= Psi));
   MyApp^.Idle;
   until af or bf;
{****************************************}
     If BoundRec.IfView = 0 then begin
     RestoreCrtMode;
     DoneMemory;
     MyApp^.Redraw;
     ShowMouse;end;
{****************************************}
   If BoundRec.IfView < 2 then begin
   if af and not(bf) Then Criterium:='-����� ���権.';
   If bf and not(af) Then Criterium:='-�ந������� '+IntToStr(Iteration);
   If bf and af Then Criterium:='- ���.';
   As:=MessageBox(^C'����� ⥪�饩 ��ଠ��: '+IntToStr(CurrN)
             +^M^C'����砭��: '+Criterium
             +^M^C'�த������ �����? Yes'
             +^M^C'��� �ਮ�⠭�����? No'
               ,nil,mfInformation or mfYesButton or mfNoButton);

   case As of
     cmNo    : begin
               CurrN:=CurrN+1;
               IF CurrN > N Then Goto A1;
               Exit;
               end;
    end;end;
    If BoundRec.IfView >= 2 then begin
       case Ord(PrChar) of
         Ord('-') : PrChar:='\';
         Ord('\') : PrChar:='|';
         Ord('|') : PrChar:='/';
         Ord('/') : PrChar:='-';
         end;
       DeskTop^.WriteChar(38,10,PrChar,1,5);
       end;

   CurrN:=CurrN+1;
   until CurrN > N;
   GetTay;
   GetC_m;
   GetF_tr;
   GetC_tr;
A1:MessageBox(^C'���᫥��� �����襭�',nil,mfInformation or mfOkButton);
end;{TBounLayer.Run}
function TBoundLayer.Diff(TopOrBottom:Boolean):real;
{�ந������� dU/dy}
begin
  If TopOrBottom
    Then
      {�� �࠭�� �.�.}
      Diff:=(MainSetka[M,CurrN]-MainSetka[M-1,CurrN])/(dEtta)
{      Diff:=((MainSetka[M,CurrN]-MainSetka[M-1,CurrN])
           +(MainSetka[M-1,CurrN]-MainSetka[M-2,CurrN]))
      /(2*dEtta)}
    Else
      {�� �����孮��}
      Diff:=(MainSetka[1,CurrN]-MainSetka[0,CurrN])/dEtta;
end;{TBoundLayer.Diff}
procedure TBoundLayer.PutFirstValue;
var i:word;
begin
        Delta[CurrN]:=7*Sqrt(dDzetta*CurrN);
{        Delta[CurrN]:=Delta[CurrN-1]*1.2;}
   for i:=0 to M do begin
   {��᢮���� ���祭�� � �������⭮� ��ଠ�� �� �।��饩}
    MainSetka[i,CurrN]:=MainSetka[i,CurrN-1];
    ComplementSetka[i,CurrN]:=ComplementSetka[i,CurrN-1];
   end;
end;{TBoundLaer.PutFirstValue}
procedure TBoundLayer.StoreNormal;
var i:integer;
begin
  Last:=0;
  For i:=0 to DimVert do Last:=Last+MainSetka[i,CurrN];
end;
function TBoundLayer.GetNevazkaForU:real;
var i:integer;
    This:real;
begin
  This:=0;
  For i:=0 to DimVert do This:=This+MainSetka[i,CurrN];
  GetNevazkaForU:=100*(1-This/Last);
end;

procedure TBoundLayer.GoingForU;{�ண���� �� 㧫�� �᭮���� �⪨}
var
  z:real;
  Alfa,Betta,Gamma,Tetta:real;
  i:integer;
begin
   {��������� �ண����� �����樥��� ��� ⥪�饩 ��ଠ��}
   GetAB;
   CurrM:=M-1;{���稪 ᫮��}
   {᪮���� �� �࠭�� ��⮪� ࠢ�� �. ���譥�� ��⮪�}
   MainSetka[M,CurrN]:=MainSetka[M,0];
   {横� ���᫥��� �த��쭮� ᪮��� �� ४�७⭮� ��㫥 (�.-�.)}
   repeat
   MainSetka[CurrM,CurrN]:=A[CurrM]*MainSetka[CurrM+1,CurrN]+B[CurrM];
   CurrM:=CurrM-1;
   until CurrM < 1;
{   CurrM:=1;
   repeat
   Alfa_Tetta(Alfa,Betta,Gamma,Tetta);
     Right[CurrM]:=Tetta;
     If CurrM = 1 Then begin
        Left[CurrM,CurrM]:=Betta;
        Left[CurrM,CurrM+1]:=Gamma;
        end;
     If (CurrM <> 1) and (CurrM <> M-1) then
     begin
        Left[CurrM,CurrM-1]:=Alfa;
        Left[CurrM,CurrM]:=Betta;
        Left[CurrM,CurrM+1]:=Gamma;
     end;
     If CurrM = M-1 Then begin
        Left[CurrM,CurrM-1]:=Alfa;
        Left[CurrM,CurrM]:=Betta;
        Right[CurrM]:=Right[CurrM]-Gamma;
        end;
   CurrM:=CurrM+1;
   until CurrM > M-1;
   Gauss(Left,Right,Incp,19);
   For i:=1 to 19 do MainSetka[i,CurrN]:=Incp[i];}
end;{TBounLaeyr.GoingForU}
procedure TBoundLayer.GoingForV;{�ண���� �� 㧫�� �ᯮ����⥫쭮� �⪨}
var
   a1,a2,b1,c,d,e,f:real;
begin
   CurrM:=1;{���稪 ᫮��}
   ComplementSetka[0,CurrN]:=0.0;{�����筠� �. ࠢ�� 0 �� ������.}
   {横� ���᫥��� �o���筮� ᪮��� �� ४�७⭮� ��㫥 (�.-�.)}
   repeat
   a1:=Delta[CurrN];
   a2:=Delta[CurrN-1];
   b1:=MainSetka[CurrM,CurrN];
   c:=MainSetka[CurrM,CurrN-1];
   d:=MainSetka[CurrM-1,CurrN];
   e:=MainSetka[CurrM-1,CurrN-1];
   f:=ComplementSetka[CurrM-1,CurrN]+(dEtta*(a1+a2)/2)*
      (((a1-a2)*CurrM/(dDzetta*(a1+a2)))*(b1+c-d-e)-(d-e+b1-c)/(2*dDzetta));
   ComplementSetka[CurrM,CurrN]:=f;
   CurrM:=CurrM+1;
   until CurrM > M;
end;{GoingForV}
procedure TBoundLayer.GetAB;
{���᫥��� �ண���筮�� �����樥�� � ��� ⥪�饩 ��ଠ��}
var D:real;
    Alfa,Betta,Gamma,Tetta:real;
begin
  CurrM:=1;{���稪 ᫮��}
  A[0]:=0.0;{��⠭���� ���祭�� ��}
  B[0]:=0.0;{��⠭���� ���祭�� B�}
  {横� ���᫥��� �����. �m (�� �.-�.)}
  repeat
  Alfa_Tetta(Alfa,Betta,Gamma,Tetta);
  D:=Alfa*A[CurrM-1]+Betta;
  A[CurrM]:=-1*(Gamma/D);
  B[CurrM]:=(Tetta-Alfa*B[CurrM-1])/D;
  CurrM:=CurrM+1;
  until CurrM > M-1;
end;{TBoundLayer.GetAB}
{�����. � ��㫠� �ண������ �����.}
procedure TBoundLayer.Alfa_Tetta(var Alf,Be,Ga,Te:real);
var
  n1,n2,n3,iGa:real;
  Am,Bm,Cm,Dm:real;
begin
  AmBmCmDm(Am,Bm,Cm,Dm);
  if CurrM <> 1 then  Alf:=-1*(S/(2*dEtta))*(Bm+2*Cm/dEtta)
                else  Alf:=0.0;
{***********************************************************}
  Be:=(Am/dDzetta)+(S/(2*dEtta*dEtta))*4*Cm;
{***********************************************************}
  n1:=((1-S)/(2*dEtta))*(Bm+2*Cm/dEtta)*MainSetka[CurrM-1,CurrN-1];
  n2:=((Am/dDzetta)-((1-S)/(2*dEtta*dEtta))*4*Cm)*
         MainSetka[CurrM,CurrN-1];
  n3:=((1-S)/(2*dEtta))*(Bm-2*Cm/dEtta)*MainSetka[CurrM+1,CurrN-1];
{***********************************************************}
  If CurrM <> M-1 then begin
     Ga:=(S/(2*dEtta))*(Bm-2*Cm/dEtta);
     Te:=1*(n1+n2-n3+Dm);end
     else begin
     Ga:=(S/(2*dEtta))*(Bm-2*Cm/dEtta);
     Te:=1*(n1+n2-n3+Dm)-Ga;
     Ga:=0.0;
     end;
end;{TBoundLayer.Alfa_Tetta}
{�����. ��� �।���� �㭪権, �� �.-�. a,b,c,d}
procedure TBoundLayer.AmBmCmDm(var Aa,Bb,Cc,Dd:real);
var x,y:real;
begin
   Aa:=0.5*(MainSetka[CurrM,CurrN]+MainSetka[CurrM,CurrN-1]);
{***********************************************************}
    x:=Delta[CurrN];
    y:=Delta[CurrN-1];
    Bb:=(2/(x+y))*(ComplementSetka[CurrM,CurrN]-
        Aa*dEtta*CurrM*((x-y)/dDzetta));
{***********************************************************}
   Cc:=4/Sqr(Delta[CurrN]+Delta[CurrN-1]);
{***********************************************************}
   {��筨�� ����!}
   Dd:=ParW*exp(-0.2*ln(CurrN));{;*Exp(-1*CurrN/50);}
end;{TBoundLayer.AmBmCmDm}
procedure TBoundLayer.GetTay;{���. ���⥫쭮�� ����殮��� �� �����孮��}
var
  Complex:real;
  i:integer;
  z:real;
begin
  If BoundRec.IfView = 3 Then Begin
  For i:=0 to DimHor do begin
  if i = 0 then Tay[i]:=0.332*Ro*Sqrt(Nu*U0*U0*U0/((X0/100)*dDzetta*L))
  else  Tay[i]:=0.332*Ro*Sqrt(Nu*U0*U0*U0/(dDzetta*i*L));
  end;end
  else begin
  Complex:=Ro*Sqrt(U0*U0*U0*Nu/L);
  For i:=0 to DimHor do begin
   z:=MainSetka[1,i]/(dEtta*Delta[i]);
   Tay[i]:=Complex*z;
   end;end;
end;{TBoundLayer.GetTay;}
procedure TBoundLayer.GetC_m;{�����樥�� �७��}
var i:integer;
begin
  For i:=0 to DimHor do
  C_m[i]:=(MainSetka[1,i]/(dEtta*Delta[i]))/Sqrt(Re);
end;{TBoundLayer.GetC_m}
procedure TBoundLayer.GetF_tr;{ᨫ� �७��}
var
   Complex:real;
   Sum1,Sum2:real;
   i,mn:integer;
begin
  If BoundRec.IfView = 3 Then   F_tr:=1.328*Ro*Sqrt(Nu*U0*U0*U0*L)
  else begin
  Complex:=Ro*dDzetta*Sqrt(U0*U0*U0*L*Nu)/(dEtta*3);
  Sum1:=0.0;Sum2:=0.0;
  mn:=DimHor div 2;
  For i:=1 to mn-1 do begin
    Sum1:=Sum1+MainSetka[1,(2*i-1)]/Delta[2*i-1];
    Sum2:=Sum2+MainSetka[1,(2*i)]/Delta[2*i];
    end;
  F_tr:=2*Complex*(MainSetka[1,0]/Delta[0]+4*Sum1+2*Sum2+
        MainSetka[1,2*mn]/Delta[2*mn]);end;
end;{TBoundLayer.GetF_tr}
procedure TBoundLayer.GetC_tr;{����. ᨫ� �७��}
var
  Complex,Sum:real;
  i:integer;
   Sum1,Sum2:real;
   mn:integer;

begin
  If BoundRec.IfView = 3 Then C_tr:=1.328/Sqrt(Re)
  else begin
  Complex:=dDzetta/(dEtta*Sqrt(Re)*3);
  Sum1:=0.0;Sum2:=0.0;
  mn:=DimHor div 2;
    For i:=1 to mn-1 do begin
    Sum1:=Sum1+MainSetka[1,(2*i-1)]/Delta[2*i-1];
    Sum2:=Sum2+MainSetka[1,(2*i)]/Delta[2*i];
    end;
  C_tr:=2*Complex*(MainSetka[1,0]/Delta[0]+4*Sum1+2*Sum2+
        MainSetka[1,2*mn]/Delta[2*mn]);end;
end;{TBoundLayer.GetC_tr}
constructor TBoundDlgBox.Init;
var
    R:TRect;
   View:PView;
   Button:PView;
begin
   R.Assign(6,3,74,20);
   Inherited Init(R,'��ࠬ���� ���࠭�筮�� ᫮�');
    R.Assign(25,3,32,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,3,24,4);
    Insert(New(PLabel,Init(R,'~A~.�離���� �������:',View)));

{*******************************************}
    R.Assign(25,4,32,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,4,24,5);
    Insert(New(PLabel,Init(R,'~B~.������� ��⮪�:',View)));

{*******************************************}
    R.Assign(25,5,32,6);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,5,24,6);
    Insert(New(PLabel,Init(R,'~C~.����� ����⨭�:',View)));

{*******************************************}
    R.Assign(25,6,32,7);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,6,24,7);
    Insert(New(PLabel,Init(R,'~D~.���⭮���:',View)));

{*******************************************}
    R.Assign(25,7,32,8);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,7,24,8);
    Insert(New(PLabel,Init(R,'~E~.X0 � % �� dDzetta:',View)));
{*******************************************}
    R.Assign(56,3,63,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,3,55,4);
    Insert(New(PLabel,Init(R,'~F~.�����樥�� Psi:',View)));

    R.Assign(56,4,63,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,4,55,5);
    Insert(New(PLabel,Init(R,'~G~.��ࠬ��� S:',View)));

    R.Assign(56,5,63,6);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,5,56,6);
    Insert(New(PLabel,Init(R,'~H~.�����୮��� �⪨ M:',View)));

    R.Assign(56,6,63,7);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,6,56,7);
    Insert(New(PLabel,Init(R,'~I~.�����୮��� �⪨ N:',View)));

    R.Assign(56,7,63,8);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(33,7,55,8);
    Insert(New(PLabel,Init(R,'~J~.MaxIter:',View)));

    R.Assign(36,9,60,11);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('�� ',
     NewSItem('���',
     NewSItem('���',
     NewSItem('��筮',
     nil))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(39,8,49,9);
    Insert(New(PLabel,Init(R,'~K~.��ᬮ��',Button)));

{**************************************************}

      R.Assign(3,9,12,11);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(15,9,24,11);
      Insert(New(PButton,Init(R,'Ca~n~cel',cmCancel,bfNormal)));

    R.Assign(25,11,32,12);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,11,23,12);
    Insert(New(PLabel,Init(R,'~L~.��ࠬ��� W',View)));

    R.Assign(25,12,32,13);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,12,23,13);
    Insert(New(PLabel,Init(R,'~M~.���. ���離�, % :',View)));

{**************************************************}
    SelectNext(false);
end;

begin
end.
{var
   ABound:PBoundLayer;
   Graphic:PZGraphic;
   Stream:PBufStream;
   Res:TResourceFile;

begin
  ABound:=New(PBoundLayer,Init);
  ABound^.Run;
{With Graphic^ do begin
  InsertVector(ABound^.Delta);
  StartGraph;
  Execute;
  Done;
  end;
  DoneGraph;

end.}
 { WriteLn('Ok ���࠭��� ᫮�');

  Stream:=New(PBufStream,Init(ResFName,stCreate,1024));
  Res.Init(Stream);
{  Res.Put(ABound^.MainSetka,'Main');
  Res.Put(ABound^.Complementtka,'Complement');}
 { Res.Put(ABound^.Delta,'Delta');
  Res.Done;
  WriteLn('Ok �����');
  Dispose(ABound,Done);
{  Dispose(Graphic,Done);}
{end.