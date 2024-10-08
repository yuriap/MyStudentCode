unit TesBUnit;
interface
uses ProBound,ProfDin,ProfComm,ProGraph,Graph,Objects;
const Norm = 20;
      Tang = 50;
      FileName = 'fi&fiblz.dat';
var
  MS:PMainSetka;
  CS:PCompSetka;
  BL:PBoundLayer;
  BRec:TBRec;
  GRec:TGrRec;
  G:PGraphic;
  Buf:PBuffer;
  MainF,CompF:PFunction;
  Mem:LongInt;
  fil:text;
  x,y:real;
  i:integer;
procedure MakeGraphRec(var aGRec:TGrRec);
procedure MakeBoundRec(var aBRec:TBRec);
procedure GetGrUslBlaz(var MainUsl,CompUsl:PFunction);
procedure GetGrUslBelo(var MainUsl,CompUsl:PFunction);
procedure PutBoundaryValue(aMS:PMainSetka;aCS:PCompSetka;BR:TBRec);
procedure PutBufParam(Buff:PBuffer;Lab:string);
function MakeBufPS:PBuffer;
function MakeMainNorm(Num:integer):PBuffer;
function MakeMainGor(Num:integer):PBuffer;
function MakeCompNorm(Num:integer):PBuffer;
procedure PrintFileBuffer(FName:string;B:PBuffer);
procedure ViewBuffer;
implementation
procedure ViewBuffer;
begin
 SetGraphMode(grMode);
 G^.Execute;
{ G^.Collect^.AtDelete(G^.Collect^.Count-1);}
 RestoreCrtMode;
end;
procedure MakeGraphRec(var aGRec:TGrRec);
begin
with aGRec do begin
     MasX:='100';
     MasY:='100';
     StepX:='0.2';
     StepY:='0.2';
     X:='50';
     Y:='50';
     XName:='Arg';
     YName:='Func';
      Color[2]:=1;
      Color[3]:=4;
      Color[1]:=5;
      Color[0]:=7;
      OptionMas:=0;
     end;
end;{MakeGraphRec}
procedure MakeBoundRec(var aBRec:TBRec);
begin
  with aBRec do begin
  X0:=1;{�����樥�� ��� ������� �࠭�筮�� �᫮��� (� �.-�. "�")}
  Psi:=0.001;{����� ������⥫쭮� �᫮ ��� dU/dy �� y=delta <= Psi}
  S:=0.75;{��ࠬ��� ��।�����}
  N:=Norm;{ࠧ��୮��� ������ �⪨ �� " ��ଠ��" � ����⨭� (0..N)}
  M:=Tang;{ࠧ��୮��� ������ �⪨ �� "���⥫쭮�" � ����⨭�(0..M)}
  MaxIter:=50;{���ᨬ��쭮� �᫮ ���権}
  parNevazka:=1;{����稭� ���離�}
  end;
end;{MakeBoundRec}
procedure GetGrUslBlaz(var MainUsl,CompUsl:PFunction);
var
  fil:text;
  x,dx,y1,y2:real;
  N,i:integer;
  S:PBufStream;
  F:TResourceFile;
begin
{  Assign(Fil,FileName);
  Reset(Fil);
  Readln(Fil,N);
  MainUsl:=New(PFunction,Init(N));
  CompUsl:=New(PFunction,Init(N));
  dx:=1/N;x:=0;
  for i:=1 to N do begin
   Readln(fil,y1,y2);
   MainUsl^.PutX(i,x);
   MainUsl^.PutY(i,y1);
   CompUsl^.PutX(i,x);
   CompUsl^.PutY(i,y2);
   x:=x+dx;
   end;  }
  S:=New(PBufStream,Init('tablfunc.tvr',stOpenRead,2048));
  F.Init(S);
  MainUsl:=PFunction(F.Get('BlazMain'));
  CompUsl:=PFunction(F.Get('BlazComp'));
  F.Done;
end;{GetGrUslBlaz}
procedure GetGrUslBelo(var MainUsl,CompUsl:PFunction);
var
  S:PBufStream;
  F:TResourceFile;
begin
  S:=New(PBufStream,Init('tablfunc.tvr',stOpenRead,2048));
  F.Init(S);
  MainUsl:=PFunction(F.Get('BeloMain'));
  CompUsl:=PFunction(F.Get('BeloComp'));
  F.Done;
end;{GetGrUslBelo}
procedure PutBoundaryValue(aMS:PMainSetka;aCS:PCompSetka;BR:TBRec);
var
   i,j:integer;
   x,dx,y,a,dFi:real;
begin
  {�࠭��� �᫮��� ��� ����⨭� ��� 0-� 㣫�� �⠪�}
{  GetGrUslBlaz(MainF,CompF);
  dx:=1/Norm;x:=0;
  {��砫�� ����� ᪮��⥩}
{  For i:=0 to Norm do begin
    aMS^.Put(i,0,MainF^.Get_Y_X(x));
    aCS^.Put(i,0,CompF^.Get_Y_X(x)*0.5*Sqrt(Tang*100/BR.X0));
    x:=x+dx;
    end;
  {������� �� �࠭�� ��}
{  For i:=1 to Tang do aMS^.Put(Norm,i,aMS^.Get(Norm,0)*(1-0.1*i/tang));
  {���騭� �� � ��ࢮ� ��ଠ��}
{  y:=7*Sqrt(BR.X0/(Tang*100));
  aMS^.Put(Norm+1,0,y);
  For i:=1 to Tang do aMS^.Put(Norm+1,i,0);
  Dispose(MainF,Done);
  Dispose(CompF,Done);
  {*********************************************************}
  {�࠭��� �᫮��� �� �����મ�᪮�� ��� ��⥪���� 樫����}
  GetGrUslBelo(MainF,CompF);
  dx:=1/Norm;x:=0;
  dFi:=Pi/(1+Tang);
  For i:=0 to Tang do begin
    y:=2*sin(Pi-dFi*(i+1));
    aMS^.Put(Norm,i,y);
    end;

  a:=-1*Sqrt(aMS^.Get(Norm,0)*pi/dFi);
  For i:=0 to Norm-1 do begin
      aMS^.Put(i,0,MainF^.Get_Y_X(x)*aMs^.Get(Norm,0));
      x:=x+dx;
      end;
      x:=0;
  For i:=0 to Norm do begin
      aCS^.Put(i,0,CompF^.Get_Y_X(x)*a);
      x:=x+dx;
      end;
  y:=-2.4/a;
  aMS^.Put(Norm+1,0,y);
  For i:=1 to Tang do aMS^.Put(Norm+1,i,0);
  Dispose(MainF,Done);
  Dispose(CompF,Done);
  {*********************************************************}
end;{PutBoundaryValue}
procedure PutBufParam(Buff:PBuffer;Lab:string);
begin
 Buff^.Labels:=Lab;
 Buff^.Color:=4;
end;
function MakeBufPS:PBuffer;
var x,dx:real;
    i:integer;
    Buf:PBuffer;
begin
 Buf:=New(PBuffer,Init(Tang+1));
 dx:=1/Tang;
 x:=0;
 For i:=1 to Tang+1 do begin
   Buf^.PutX(i,x);
   Buf^.PutY(i,MS^.Get(Norm+1,i));
   x:=x+dx;
   end;
  MakeBufPS:=Buf;
end;
function MakeMainNorm(Num:integer):PBuffer;
var x,dx,y:real;
    i:integer;
    Buf:PBuffer;
begin
 Buf:=New(PBuffer,Init(Norm+1));
 dx:=1/(Norm);
 x:=0;
 For i:=0 to Norm do begin
   Buf^.PutX(i+1,x);
   y:=MS^.Get(i,Num);
   Buf^.PutY(i+1,y);
   x:=x+dx;
   end;
  MakeMainNorm:=Buf;
end;
function MakeMainGor(Num:integer):PBuffer;
var x,dx,y:real;
    i:integer;
    Buf:PBuffer;
begin
 Buf:=New(PBuffer,Init(Tang+1));
 dx:=1/(Tang);
 x:=0;
 For i:=0 to Tang do begin
   Buf^.PutX(i+1,x);
   y:=MS^.Get(Num,i);
   Buf^.PutY(i+1,y);
   x:=x+dx;
   end;
  MakeMainGor:=Buf;
end;

function MakeCompNorm(Num:integer):PBuffer;
var x,dx,y:real;
    i:integer;
    Buf:PBuffer;
begin
 Buf:=New(PBuffer,Init(Norm+1));
 dx:=1/(Norm);
 x:=0;
 For i:=0 to Norm do begin
   Buf^.PutX(i+1,x);
   y:=CS^.Get(i,Num);
   Buf^.PutY(i+1,y);
   x:=x+dx;
   end;
  MakeCompNorm:=Buf;
end;

procedure PrintFileBuffer(FName:string;B:PBuffer);
var F:text;
begin
 Assign(f,FName);
 Rewrite(F);
 For i:=B^.BeginH to B^.EndH do
 Writeln(f,'x: ',B^.GetX(i):8:6,' y: ',B^.GetY(i):8:6);
 Close(F);
end;
begin
end.