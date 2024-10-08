{***********************************************}
{**  ��᪨� ���㤠��⢥��� 㭨������      **}
{**  ��䥤� ���஬�設                       **}
{**  �������� �������ࣥ⨪�              **}
{***********************************************}
{**  ����ணࠬ�� ���� ��ࠬ��஢          **}
{**  ��樮��୮�� ������୮�� ���࠭�筮��   **}
{**  ᫮�                                     **}
{***********************************************}
{** Copyright (c) ����� �.�.     3.04.96      **}
{***********************************************}
Unit ProBound;
Interface
uses Objects,Dos,Crt,ProfDin,ProfComm;
const
    Top:boolean=true;{�࠭�� �.�.}
    Bottom:boolean=false;{�����孮���}
type
  TBoundRec = record
  Nu,{�離���� [�^2/c]}
  U0,{᪮���� ��⮪� [�/c]}
  L ,{����� ����⨭� [�]}
  Ro,{�������� ������� [��/�^3]}

  X0,{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
  Psi,{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
  S,{��ࠬ��� ��।�����}
  N,{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..N)}
  M,{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..M)}
  MaxIter{���ᨬ��쭮� �᫮ ���権}  :string[7];
  IfView:word;
  ParW:string[7];
  parNevazka:String[7];{����稭� ���離�}
  end;
  TBRec = record
  X0:real;{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
  Psi:real;{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
  S:real;{��ࠬ��� ��।�����}
  N:integer;{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..N)}
  M:integer;{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..M)}
  MaxIter:integer;{���ᨬ��쭮� �᫮ ���権}
  parNevazka:real;{����稭� ���離�}
  end;
const
  {����� ���ᨢ� Options}
  psKritical = $0000;{����᪠� �窠 ��⥪���� ��⮪�}
  psPositive = $0001;{���ࠢ����� ���⥫쭮� ᪮���
  ᮢ������ � �㬥�樥� ��ଠ��� � �⪥}
  psNegative = $0002;{���ࠢ����� ���⥫쭮� ᪮���
  �� ᮢ������ � �㬥�樥� ��ଠ��� � �⪥}
  psFirst = $0004;{��ࢠ� ��ଠ�� �冷� � ����᪮� �窮�}
  psOk = $0008;{��ଠ�� �ᯥ譮 ����⠭��}
  psBreak = $0010;{��ଠ�� � ���ன �ந��襫 ���� ��}
  {��᪨ ���ᨢ� Options}
  psFirstPositive = psFirst or psPositive;
  psFirstPositiveOk = psFirstPositive or psOk;
  psFirstNegative = psFirst or psNegative;
  psFirstNegativeOk = psFirstNegative or psOk;
  psPositiveOk = psPositive or psOk;
  psNegativeOk = psNegative or psOk;
type
    PBoundLayer = ^TBoundLayer;
    TBoundLayer = object(TObject)
       X0:real;{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
       Psi:real;{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
       S:real;{��ࠬ��� ��।�����}
       N:word;{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..N)}
       M:word;{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..M)}
       dDelta:real;{��砫쭮� ���饭�� ⮫騭� �.�.}
       cDelta:real;{⥪�饥 ���饭�� ⮫騭� �.�.}
       dEtta:real;{蠣 �⪨ �� ��ଠ��}
       dDzetta:real;{蠣 �⪨ ����� �����孮��}
       Iteration:word;{���稪 ���権}
       MaxIter:word;{���ᨬ��쭮� �᫮ ���権}
       parNevazka:real;{����稭� ���離�}
       CurrN,CurrM:integer;{���稪� ⥪��� ��ଠ�� � ᫮� ᮮ⢥��⢥���}
       MainSetka:PMainSetka;{�᭮���� �⪠}
       ComplementSetka:PCompSetka;{�ᯮ����⥫쭠� �⪠}
       A,B:PVector;{���ᨢ� �ண������ �����樥�⮢}
       constructor Init(BRec:TBRec);
       procedure InstallSetka(Main:PMainSetka;Comp:PCompSetka);
       procedure Execute;
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
{       procedure GetTay;{���. ���⥫쭮�� ����殮��� �� �����孮��}
{       procedure GetC_m;{�����樥�� �७��}
{       procedure GetF_tr;{ᨫ� �७��}
{       procedure GetC_tr;{����. ᨫ� �७��}
       procedure Monitor;
       destructor Done;virtual;
       private
       Last:real;{�।��饥 ���祭�� ��� ���. ���離�}
       end;
function Sign(Numer:real):shortint;
Implementation
uses TesBUnit;
function Sign(Numer:real):shortint;
{���� �᫠}
begin
  If Numer = 0.0 Then Sign:=0
   else sign:=Round(Numer/Abs(Numer));
end;
constructor TBoundLayer.Init(BRec:TBRec);
begin
  inherited Init;
  Psi:=BRec.Psi;{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
  S:=BRec.S;{��ࠬ��� ��।�����}
  MaxIter:=BRec.MaxIter;{���ᨬ��쭮� �᫮ ���権}
  parNevazka:=BRec.parNevazka;{����稭� ���離�}
end;{TBoundLayer.Init}
procedure TBoundLayer.InstallSetka(Main:PMainSetka;Comp:PCompSetka);
begin
  MainSetka:=Main;
  ComplementSetka:=Comp;
  N:=MainSetka^.EndV-1;{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..N)}
  M:=MainSetka^.EndH;{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..M)}
  dEtta:=1/N;{蠣 �⪨ �� ��ଠ��}
  dDzetta:=1/M;{蠣 �⪨ ����� �����孮��}
  A:=New(PVector,Init(0,N));{���ᨢ� �ண������ �����樥�⮢}
  B:=New(PVector,Init(0,N));{���ᨢ� �ண������ �����樥�⮢}
  dDelta:=MainSetka^.Get(N+1,0)*0.5;{��砫쭮� ���饭�� ⮫騭� �.�.}
end;
destructor TBoundLayer.Done;
begin
  {㤠����� �������᪨� ��ꥪ⮢}
  Dispose(A,Done);{���ᨢ� �ண������ �����樥�⮢}
  Dispose(B,Done);
  {************************************}
  inherited Done;
end;
procedure TBoundLayer.Execute;
var af,bf:boolean;
    df:real;
    cDeltaOld:real;
    EndProgon:boolean;
    Buf:PBuffer;
    Nev:integer;
begin
   ClrScr;
   Writeln('Please, wait some time...');
   CurrN:=1;
   repeat{横� ���᫥��� ��ࠬ��஢ � ��ଠ���}
   PutFirstValue;{�����砥� ��砫�� ���祭�� ��ࠬ. � ���������� 㧫��}
   Iteration:=1;{���稪 ���権}
   cDelta:=dDelta;{Delta^.Get(CurrN-1)*0.05;{⥪�饥 ���饭�� ⮫騭� �.�.}
   cDeltaOld:=cDelta;
   repeat{横� ���権 �� ⮫騭� �.�.}
   {�������� ⮫騭� �.�. � ⥪�饩 ���樨}
   MainSetka^.Put(N+1,CurrN,MainSetka^.Get(N+1,CurrN)+cDelta);
   EndProgon:=false;
   Nev:=0;
   repeat{���������� ��⥬� � �� �襭��}
   StoreNormal;{���������� �।��騩 १����}
   GoingForU;{�ண���� �� 㧫�� �᭮���� �⪨}
   GoingForV;{�ண���� �� 㧫�� �ᯮ����⥫쭮� �⪨}
   If Abs(GetNevazkaForU) <= parNevazka Then EndProgon:=true;
   Inc(Nev);
   until EndProgon or (Nev > 20);
   If Nev > 20 Then begin
          Writeln;
          Writeln('BreakFree the Boundary Layer!');
          readln;
          Exit;end;
   {�஢�ઠ ����� �ந������� dU/dy �� y = ⮫騭� �.�.}
   cDelta:=Abs(cDelta)*Sign(Diff(Top));
   If not(Sign(cDelta) = Sign(cDeltaOld)) then begin
     cDelta:=cDelta*0.75;
     end;
     cDeltaOld:=cDelta;
   {****************************************}
   Iteration:=Iteration+1;{���饭�� ���稪� ���権}
   {�஢�ઠ �᫮��� dU/dy �� y=delta <= Psi}
   df:=Diff(Top);
   af:=(Iteration > MaxIter);
   bf:=((0 <= Abs(df)) and (Abs(df) <= Psi));
   GotoXY(1,2);
   Write('Processe: iteration: ',Iteration,'; Normal: ',CurrN,'  ');
   if KeyPressed then begin
     Writeln;
     Writeln('Program terminated');
     Exit;
     end;
   until af or bf;
   CurrN:=CurrN+1;
   if CurrN = M then
     begin
      Beep;
     end;
   until CurrN > M;
   Writeln;
   Writeln('Ok digital Boundary Layer');
   readln
end;{TBounLayer.Execute}
function TBoundLayer.Diff(TopOrBottom:Boolean):real;
{�ந������� dU/dy}
var x:real;
begin
  If TopOrBottom
    Then
      {�� �࠭�� �.�.}
      x:=(MainSetka^.Get(N,CurrN)-MainSetka^.Get(N-1,CurrN))/dEtta
    Else
      {�� �����孮��}
      x:=(MainSetka^.Get(1,CurrN)-MainSetka^.Get(0,CurrN))/dEtta;
    Diff:=x;
end;{TBoundLayer.Diff}
procedure TBoundLayer.PutFirstValue;
var i:word;
    y:real;
begin
   y:=MainSetka^.Get(N+1,CurrN-1);
   MainSetka^.Put(N+1,CurrN,y);
   {��᢮���� ���祭�� � �������⭮� ��ଠ�� �� �।��饩}
   for i:=0 to N-1 do begin
   {��ଠ�� �᭮���� �⪨, �� �������� �� �᪫�祭��� ��᫥�����
    ����� ���� �࠭��� �᫮���� (᪮���� �� �࠭�� ��)}
    y:=MainSetka^.Get(i,CurrN-1);
    MainSetka^.Put(i,CurrN,y);end;
   For i:=0 to N do begin
   {��ଠ�� �ᯮ����⥫쭮� �⪨, �� ��������}
    y:=ComplementSetka^.Get(i,CurrN-1);
    ComplementSetka^.Put(i,CurrN,y);end;
end;{TBoundLaer.PutFirstValue}
procedure TBoundLayer.StoreNormal;
var i:integer;
begin
  Last:=0;
  For i:=0 to MainSetka^.N-1 do Last:=Last+MainSetka^.Get(i,CurrN);
end;
function TBoundLayer.GetNevazkaForU:real;
var i:integer;
    This:real;
begin
  This:=0;
  For i:=0 to MainSetka^.N-1 do This:=This+MainSetka^.Get(i,CurrN);
  GetNevazkaForU:=100*(1-This/Last);
end;

procedure TBoundLayer.GoingForU;{�ண���� �� 㧫�� �᭮���� �⪨}
var
  z,z1:real;
  Alfa,Betta,Gamma,Tetta:real;
  i:integer;
begin
   {��������� �ண����� �����樥��� ��� ⥪�饩 ��ଠ��}
   GetAB;
   CurrM:=N-1;{���稪 ᫮��}
   {横� ���᫥��� �த��쭮� ᪮��� �� ४�७⭮� ��㫥 (�.-�.)}
   repeat
   z1:=MainSetka^.Get(CurrM+1,CurrN);
   z:=A^.Get(CurrM)*z1+B^.Get(CurrM);
   MainSetka^.Put(CurrM,CurrN,z);
   CurrM:=CurrM-1;
   until CurrM < 0;
end;{TBounLaeyr.GoingForU}
procedure TBoundLayer.GoingForV;{�ண���� �� 㧫�� �ᯮ����⥫쭮� �⪨}
var
   a1,a2,b1,c,d,e,f:real;
begin
   CurrM:=1;{���稪 ᫮��}
   ComplementSetka^.Put(0,CurrN,0.0);{�����筠� �. ࠢ�� 0 �� ������.}
   {横� ���᫥��� �o���筮� ᪮��� �� ४�७⭮� ��㫥 (�.-�.)}
   repeat
   a1:=MainSetka^.Get(N+1,CurrN);
   a2:=MainSetka^.Get(N+1,CurrN-1);
   b1:=MainSetka^.Get(CurrM,CurrN);
   c:=MainSetka^.Get(CurrM,CurrN-1);
   d:=MainSetka^.Get(CurrM-1,CurrN);
   e:=MainSetka^.Get(CurrM-1,CurrN-1);
   f:=ComplementSetka^.Get(CurrM-1,CurrN)+(dEtta*(a1+a2)/2)*
      (((a1-a2)*CurrM/(dDzetta*(a1+a2)))*(b1+c-d-e)-(d-e+b1-c)/(2*dDzetta));
   ComplementSetka^.Put(CurrM,CurrN,f);
   CurrM:=CurrM+1;
   until CurrM > N;
end;{GoingForV}
procedure TBoundLayer.GetAB;
{���᫥��� �ண���筮�� �����樥�� � ��� ⥪�饩 ��ଠ��}
var D:real;
    Alfa,Betta,Gamma,Tetta:real;
begin
  CurrM:=1;{���稪 ᫮��}
  A^.Put(0,0.0);{��⠭���� ���祭�� ��}
  B^.Put(0,0.0);{��⠭���� ���祭�� B�}
  {横� ���᫥��� �����. �m (�� �.-�.)}
  repeat
  Alfa_Tetta(Alfa,Betta,Gamma,Tetta);
  D:=Alfa*A^.Get(CurrM-1)+Betta;
  A^.Put(CurrM,-1*(Gamma/D));
  B^.Put(CurrM,(Tetta-Alfa*B^.Get(CurrM-1))/D);
  CurrM:=CurrM+1;
  until CurrM > N-1;
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
  n1:=((1-S)/(2*dEtta))*(Bm+2*Cm/dEtta)*MainSetka^.Get(CurrM-1,CurrN-1);
  n2:=((Am/dDzetta)-((1-S)/(2*dEtta*dEtta))*4*Cm)*
         MainSetka^.Get(CurrM,CurrN-1);
  n3:=((1-S)/(2*dEtta))*(Bm-2*Cm/dEtta)*MainSetka^.Get(CurrM+1,CurrN-1);
{***********************************************************}
  If CurrM <> N-1 then begin
     Ga:=(S/(2*dEtta))*(Bm-2*Cm/dEtta);
     Te:=n1+n2-n3+Dm;end
     else begin
     Ga:=(S/(2*dEtta))*(Bm-2*Cm/dEtta);
     Te:=n1+n2-n3+Dm-Ga*MainSetka^.Get(N,CurrN);
     Ga:=0.0;
     end;
end;{TBoundLayer.Alfa_Tetta}
{�����. ��� �।���� �㭪権, �� �.-�. a,b,c,d}
procedure TBoundLayer.AmBmCmDm(var Aa,Bb,Cc,Dd:real);
var x,y:real;
begin
   Aa:=0.5*(MainSetka^.Get(CurrM,CurrN)+MainSetka^.Get(CurrM,CurrN-1));
{***********************************************************}
    x:=MainSetka^.Get(N+1,CurrN);
    y:=MainSetka^.Get(N+1,CurrN-1);
    Bb:=(2/(x+y))*(ComplementSetka^.Get(CurrM,CurrN)-
        Aa*dEtta*CurrM*((x-y)/dDzetta));
{***********************************************************}
   Cc:=4/Sqr(MainSetka^.Get(N+1,CurrN)+MainSetka^.Get(N+1,CurrN-1));
{***********************************************************}
   x:=MainSetka^.Get(N,CurrN);
   y:=MainSetka^.Get(N,CurrN-1);
   Dd:=0.5*(x+y)*(x-y)/dDzetta;

end;{TBoundLayer.AmBmCmDm}
{procedure TBoundLayer.GetTay;{���. ���⥫쭮�� ����殮��� �� �����孮��}
{var
  Complex:real;
  i:integer;
begin
  Complex:=Ro*Sqrt(U0*U0*U0*Nu/L);
  For i:=0 to DimHor do begin
   Tay[i]:=Complex*MainSetka^.Get(1,i)/(dEtta*Delta^.Get(i));
   end;
end;{TBoundLayer.GetTay;}
{procedure TBoundLayer.GetC_m;{�����樥�� �७��}
{var i:integer;
begin
  For i:=0 to DimHor do
  C_m[i]:=(MainSetka[1,i]/(dEtta*Delta[i]))/Sqrt(Re);
end;{TBoundLayer.GetC_m}
{procedure TBoundLayer.GetF_tr;{ᨫ� �७��}
{var
   Complex:real;
   Sum:real;
   i:integer;
begin
  Complex:=Ro*dDzetta*Sqrt(U0*U0*U0*L*Nu);
  Sum:=0.0;
  For i:=0 to DimHor-1 do begin
    Sum:=Sum+MainSetka[1,i]/(dEtta*Delta[i])
            +MainSetka[1,i+1]/(dEtta*Delta[i+1]);
    end;
  F_tr:=Complex*Sum;
end;{TBoundLayer.GetF_tr}
{procedure TBoundLayer.GetC_tr;{����. ᨫ� �७��}
{var
  Sum:real;
  i:integer;
begin
  Sum:=0.0;
  For i:=0 to DimHor-1 do begin
    Sum:=Sum+MainSetka[1,i]/(dEtta*Delta[i])
            +MainSetka[1,i+1]/(dEtta*Delta[i+1]);
    end;
  C_tr:=dDzetta*Sum/Sqrt(Re);
end;{TBoundLayer.GetC_tr}
begin
end.
