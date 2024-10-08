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
Unit BoundT;
Interface
uses Graphict,Graph,Objects,Dialogs,Views,MsgBox,Dos,Memory,Crt;
const
    DimHor = 20;
    DimVert = 10;

    FileGrUsl:PathStr='Fi&Fi.dat';{����� � ⠡��栬� �㭪権 � � �_����
                                  �� �.-�.}
    EttaDelta=2.4;{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�.)}
    Top:boolean=true;{�࠭�� �.�.}
    Bottom:boolean=false;{�����孮���}
type
  TBoundRec = record
  Nu,{�離���� [�^2/c]}
  U0,{᪮���� ��⮪� [�/c]}
  L ,{����� ����⨭� [�]}
  Ro,{�������� ������� [��/�^3]}

  al,{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
  Psi,{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
  S,{��ࠬ��� ��।�����}
  M,{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..M)}
  N,{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..N)}
  MaxIter{���ᨬ��쭮� �᫮ ���権}  :string[7];

  IfView:word;
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
       al:real;{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
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
       CurrN,CurrM:integer;{���稪� ⥪��� ��ଠ�� � ᫮� ᮮ⢥��⢥���}
       MainSetka:TMainSetka;{�᭮���� �⪠}
       ComplementSetka:TComplSetka;{�ᯮ����⥫쭠� �⪠}
       Delta:TDelta;{⮫騭� �.�. ����� �����孮��}
       A,B:TABCoeff;{���ᨢ� �ண������ �����樥�⮢}
       Fi,FiStrih:TABCoeff;
       constructor Init;
       Procedure NewParam;
       procedure Run(Plase:Word);{���� �.�.}
       {�����砥� ��砫�� ���祭�� ��ࠬ. � ���������� 㧫��}
       procedure PutFirstValue;
       procedure GoingForU;{�ண���� �� 㧫�� �᭮���� �⪨}
       procedure GoingForV;{�ண���� �� 㧫�� �ᯮ����⥫쭮� �⪨}
       {���᫥��� �ண������ �����樥�⮢ ��� ⥪�饩 ��ଠ��}
       procedure GetA;
       procedure GetB;
       {�����. � ��㫠� �ண������ �����.}
       function Alfa:real;
       function Betta:real;
       function Gamma:real;
       function Tetta:real;
       {�����. ��� �।���� �㭪権, �� �.-�. a,b,c,d}
       function Am:real;
       function Bm:real;
       function Cm:real;
       function Dm:real;
       {�ந������� �த����� ᪮��� �� ��ଠ�� True - �� �࠭��(Top)}
       { False - �� �����孮�� (Bottom)}
       function Diff(TopOrBottom:Boolean):real;
       destructor Done;virtual;
       end;

       PBoundDlgBox = ^TBoundDlgBox;
       TBoundDlgBox = object(TDialog)
          constructor Init;
          end;
function Sign(Numer:real):shortint;
var      ABound:PBoundLayer;
Implementation
Uses Work001t;

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
    read(DataFile,Fi[i]);
    end;
  for i:= 0 to DimVert do begin
    read(DataFile,FiStrih[i]);
    end;
 Close(DataFile);

  {��樠������ �����}
  Val(BoundRec.Nu,Nu,z);{�離���� [�^2/c]}
  Val(BoundRec.U0,U0,z);{᪮���� ��⮪� [�/c]}
  Val(BoundRec.L,L,z);{����� ����⨭� [�]}
  Val(BoundRec.Ro,Ro,z);{�������� ������� [��/�^3]}

  Val(BoundRec.al,al,z);{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
  Val(BoundRec.Psi,Psi,z);{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
  Val(BoundRec.S,S,z);{��ࠬ��� ��।�����}
  M:=DimVert;{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..M)}
  N:=DimHor;{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..N)}
  Val(BoundRec.MaxIter,MaxIter,z);{���ᨬ��쭮� �᫮ ���権}
  Re:=U0*L/Nu;{�᫮ ��������}
  dEtta:=1/(M);{蠣 �⪨ �� ��ଠ��}
  dDzetta:=1/(N);{蠣 �⪨ ����� �����孮��}
  {���樠������ ����� ⮫設� �.�.}
  Delta[0]:=EttaDelta*Sqrt(Nu/al);{⮫騭� �.�. � 1-� ��ଠ��}
  dDelta:=Delta[0]*0.1;{��砫쭮� ���饭�� ⮫騭� �.�.}
  {����. �᭮���� �⪨}
  {�࠭�筮� �᫮��� - �த��쭠� ᪮���� �� �࠭�� �⪨}
  For i:=0 to M do  MainSetka[i,0]:=FiStrih[i]*1;
  {����. �ᯮ����⥫쭮� �⪨}
  {�࠭�筮� �᫮��� - �����筠� ᪮���� �� �࠭�� �⪨}
  For i:=0 to M do  ComplementSetka[i,0]:=-1*Fi[i]*Sqrt(al*Nu);
  {����. ���ᨢ�� �ண������ �����樥�⮢}
end;{TBoundLayer.Init}
procedure TBoundLayer.NewParam;
var z : integer;
    i:word;
    x:real;
begin
  {��樠������ �����}
  Val(BoundRec.Nu,Nu,z);{�離���� [�^2/c]}
  Val(BoundRec.U0,U0,z);{᪮���� ��⮪� [�/c]}
  Val(BoundRec.L,L,z);{����� ����⨭� [�]}
  Val(BoundRec.Ro,Ro,z);{�������� ������� [��/�^3]}

  Val(BoundRec.al,al,z);{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
  Val(BoundRec.Psi,Psi,z);{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
  Val(BoundRec.S,S,z);{��ࠬ��� ��।�����}
  Re:=U0*L/Nu;{�᫮ ��������}
  dEtta:=1/(M);{蠣 �⪨ �� ��ଠ��}
  dDzetta:=1/(N);{蠣 �⪨ ����� �����孮��}
  Val(BoundRec.MaxIter,MaxIter,z);{���ᨬ��쭮� �᫮ ���権}
  {���樠������ ����� ⮫設� �.�.}
  Delta[0]:=EttaDelta*Sqrt(Nu/al);{⮫騭� �.�. � 1-� ��ଠ��}
  dDelta:=Delta[0]*0.1;{��砫쭮� ���饭�� ⮫騭� �.�.}
  {����. �᭮���� �⪨}
  {�࠭�筮� �᫮��� - �த��쭠� ᪮���� �� �࠭�� �⪨}
  For i:=0 to M do  MainSetka[i,0]:=FiStrih[i]*1;
  {����. �ᯮ����⥫쭮� �⪨}
  {�࠭�筮� �᫮��� - �����筠� ᪮���� �� �࠭�� �⪨}
  For i:=0 to M do  ComplementSetka[i,0]:=-1*Fi[i]*Sqrt(al*Nu);
end;{TBoundLayer.NewParam}

destructor TBoundLayer.Done;
begin
  inherited Done;
end;
procedure TBoundLayer.Run(Plase:Word);
Label A1,A2;
var af,bf:boolean;
    df:real;
    As:word;
    Criterium:string[17];
    IfIteration : boolean;
      Vec:PZVector;
      i:word;
  procedure InstalValue(Vector:PZVector);
  begin
      If Iteration > MaxIter Then Vector^.Labels:='first'
         else Vector^.Labels:=IntToStr(CurrN)+'.'+IntToStr(Iteration);
      Vector^.Color:=4;
      Vector^.Visible:=true;
  end;

function DirectBox(S:string):boolean;
var D:word;
begin
  D:=MessageBox(#3+S+#13+
            #3'�����?',nil,mfinformation or mfYesNoCancel);
  If D = cmYes Then DirectBox:=false;
  If D = cmNo Then DirectBox:=true;
  If D = cmCancel Then begin DirectBox:= false;IfIteration:= false;end;
end;
begin
{   CurrN:=1;{���稪 ��ଠ���
   IfIteration:=true;
   If Plase = 1 then Goto A2;}
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
   cDelta:=Delta[CurrN]*0.01;{⥪�饥 ���饭�� ⮫騭� �.�.}
   repeat{横� ���権 �� ⮫騭� �.�.}
   {�������� ⮫騭� �.�. � ⥪�饩 ���樨}
   Delta[CurrN]:=Delta[CurrN]+cDelta;
   GoingForU;{�ண���� �� 㧫�� �᭮���� �⪨}
{   If DirectBox('�ண���� �� U') then exit;}
   GoingForV;{�ண���� �� 㧫�� �ᯮ����⥫쭮� �⪨}
   {�஢�ઠ ����� �ந������� dU/dy �� y = ⮫騭� �.�.}
   If not(Sign(cDelta) = Sign(Diff(Top))) then begin
     cDelta:=cDelta/2;
     cDelta:=Abs(cDelta)*Sign(Diff(Top));
     end;
{    If IFIteration Then
      If (DirectBox('�����祭� �����: '+IntToStr(Iteration))) then Exit;}
   {****************************************}
    If BoundRec.IfView = 0 then begin
    Vec:=New(PZVector,Init(DimVert+1));
    For i:=0 to DimVert do
      Vec^.Put(i,MainSetka[i,CurrN]);
    InstalValue(Vec);
    Graphic^.InsertVector(Vec);
    Graphic^.Execute;
    Graphic^.DelLastVector;
    Graphic^.StoreParam;end;
    {*******************************************}

A2:Iteration:=Iteration+1;{���饭�� ���稪� ���権}
   {�஢�ઠ �᫮��� dU/dy �� y=delta <= Psi}
   df:=Diff(Top);
   af:=(Iteration > MaxIter);
   bf:=((0 <= df) and (df <= Psi));
   Sound(1000);
   Delay(1);
   NoSound;
   until af or bf;
{****************************************}
     If BoundRec.IfView = 0 then begin
     RestoreCrtMode;
     DoneMemory;
     MyApp^.Redraw;end;
{****************************************}
   If BoundRec.IfView < 2 then begin
   if af and not(bf) Then Criterium:='-����� ���権.';
   If bf and not(af) Then Criterium:='-�ந�������.';
   If bf and af Then Criterium:='- ���.';
   As:=MessageBox(^C'����� ⥪�饩 ��ଠ��: '+IntToStr(CurrN)
             +^M^C'����砭��: '+Criterium
             +^M^C'�த������ �����? Yes'
             +^M^C'��� �ਮ�⠭�����? No'
               ,nil,mfInformation or mfYesNoCancel);
   case As of
     cmYes   : IfIteration := false;
     cmCancel: IfIteration := true;
     cmNo    : begin
               CurrN:=CurrN+1;
               IF CurrN > N Then Goto A1;
               Exit;
               end;
    end;end;
   CurrN:=CurrN+1;
   until CurrN > N;
A1:MessageBox(^C'���᫥��� �����祭�',nil,mfInformation or mfOkButton);
end;{TBounLayer.Run}
function TBoundLayer.Diff(TopOrBottom:Boolean):real;
{�ந������� dU/dy}
begin
  If TopOrBottom
    Then
      {�� �࠭�� �.�.}
      Diff:=(MainSetka[M,CurrN]-MainSetka[M-1,CurrN])/dEtta
    Else
      {�� �����孮��}
      Diff:=(MainSetka[1,CurrN]-MainSetka[0,CurrN])/dEtta;
end;{TBoundLayer.Diff}
procedure TBoundLayer.PutFirstValue;
var i:word;
begin
   Delta[CurrN]:=Delta[CurrN-1];
   for i:=0 to M do begin
   {��᢮���� ���祭�� � �������⭮� ��ଠ�� �� �।��饩}
    MainSetka[i,CurrN]:=MainSetka[i,CurrN-1];
    ComplementSetka[i,CurrN]:=ComplementSetka[i,CurrN-1];
   end;
end;{TBoundLaer.PutFirstValue}
procedure TBoundLayer.GoingForU;{�ண���� �� 㧫�� �᭮���� �⪨}
var
  z:real;
begin
   {��������� �ண����� �����樥��� ��� ⥪�饩 ��ଠ��}
   GetA;
   GetB;
   CurrM:=M-1;{���稪 ᫮��}
   {᪮���� �� �࠭�� ��⮪� ࠢ�� �. ���譥�� ��⮪�}
   MainSetka[M,CurrN]:=1;
   {横� ���᫥��� �த��쭮� ᪮��� �� ४�७⭮� ��㫥 (�.-�.)}
   repeat
   MainSetka[CurrM,CurrN]:=A[CurrM]*MainSetka[CurrM+1,CurrN]+B[CurrM];
   CurrM:=CurrM-1;
   until CurrM < 0;
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
      (((a1-a2)*CurrM/(dDzetta*(a1+a2)))*(b1+c-d-e-(d-e+b1-c)/(2*dDzetta)));
   ComplementSetka[CurrM,CurrN]:=f;
   CurrM:=CurrM+1;
   until CurrM > M;
end;{GoingForV}
procedure TBoundLayer.GetA;
{���᫥��� �ண���筮�� �����樥�� � ��� ⥪�饩 ��ଠ��}
begin
  CurrM:=1;{���稪 ᫮��}
  A[0]:=0.0;{��⠭���� ���祭�� ��}
  {横� ���᫥��� �����. �m (�� �.-�.)}
  repeat
  A[CurrM]:=-1*(Gamma/(Alfa*A[CurrM-1]+Betta));
  CurrM:=CurrM+1;
  until CurrM > M-1;
end;{TBoundLayer.GetA}
procedure TBoundLayer.GetB;
{���᫥��� �ண���筮�� �����樥�� B ��� ⥪�饩 ��ଠ��}
var g:real;
begin
  CurrM:=1;{���稪 ᫮��}
  B[0]:=0.0;{��⠭���� ���祭�� B�}
  {横� ���᫥��� �����. Bm (�� �.-�.)}
  repeat
  B[CurrM]:=(Tetta-Alfa*B[CurrM-1])/(Alfa*A[CurrM-1]+Betta);
  CurrM:=CurrM+1;
  until CurrM > M-1;
end;{TBoundLayer.GetB}
{�����. � ��㫠� �ண������ �����.}
function TBoundLayer.Alfa:real;
begin
  if CurrM <> 1 then  Alfa:=-1*(S/(2*dEtta))*(Bm+2*Cm/dEtta)
                else  Alfa:=0.0;
end;{TBoundLayer.Alfa}
function TBoundLayer.Betta:real;
begin
   Betta:=(Am/dDzetta)+(S/(2*dEtta*dEtta))*4*Cm;
end;{TBoundLayer.Betta}
function TBoundLayer.Gamma:real;
begin
   If CurrM <> M-1 then Gamma:=(S/(2*dEtta))*(Bm-2*Cm/dEtta)
                   else Gamma:=0.0;
end;{TBoundLayer.Gamma}
function TBoundLayer.Tetta:real;
var
  n1,n2,n3:real;
begin
  n1:=((1-S)/(2*dEtta))*(Bm+2*Cm/dEtta)*MainSetka[CurrM-1,CurrN-1];
  n2:=((Am/dDzetta)-((1-S)/(2*dEtta*dEtta))*4*Cm)*
         MainSetka[CurrM,CurrN-1];
  n3:=((1-S)/(2*dEtta))*(Bm-2*Cm/dEtta)*MainSetka[CurrM+1,CurrN-1];
  Tetta:=n1+n2-n3+Dm;
end;{TBoundLayer.Tetta}
{�����. ��� �।���� �㭪権, �� �.-�. a,b,c,d}
function TBoundLayer.Am:real;
begin
   Am:=0.5*(MainSetka[CurrM,CurrN]+MainSetka[CurrM,CurrN-1]);
end;{TBoundLayer.A}
function TBoundLayer.Bm:real;
var x,y:real;
begin
    x:=Delta[CurrN];
    y:=Delta[CurrN-1];
    Bm:=(2/(x+y))*(ComplementSetka[CurrM,CurrN]-
       0.5*Am*dEtta*CurrM*((x-y)/dDzetta));
end;{TBoundLayer.B}
function TBoundLayer.Cm:real;
begin
   Cm:=4/Sqr(Delta[CurrN]+Delta[CurrN-1]);
end;{TBoundLayer.C}
function TBoundLayer.Dm:real;
var x,y:real;
begin
   {��筨�� ����!}
   Dm:=0.0;
end;{TBoundLayer.D}
constructor TBoundDlgBox.Init;
var
   R:TRect;
   View:PView;
   Button:PView;
begin
   R.Assign(6,5,74,18);
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
    Insert(New(PLabel,Init(R,'~E~.�����樥�� A:',View)));
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
     nil)))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(39,8,49,9);
    Insert(New(PLabel,Init(R,'~K~.��ᬮ��',Button)));

{**************************************************}

      R.Assign(3,9,12,11);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(15,9,24,11);
      Insert(New(PButton,Init(R,'Ca~n~cel',cmCancel,bfNormal)));

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