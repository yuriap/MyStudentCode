program TestDin;
uses ProfDin,Crt,Windows,Objects;
Label A1;
const
      A=10000;
      B=100;
type
{    TMassiv = array [1..A,1..B] of real;}
    TVect = array [0..A] of byte;
var
{   M:TMassiv;}
   V:TVect;
   MD:PMatrix;
   VD:POptMassiv;
   i,j,k:integer;
   Rnd:byte;
   Memory:LongInt;
   Turn:integer;
   S:string[4];
   Test:Boolean;
   Stream:PBufStream;
begin
  Test:=False;
  ClrScr;
  Write('������ �᫮ 横��� ���: ');
  Readln(Turn);
  Memory:=MemAvail;
{  RegisterType(RMatrix);
  MD:=New(PMatrix,Init(1,A,1,B,SizeOf(real)));
  Randomize;
  WriteXY(1,2,'���� �������᪮�� ���ᨢ�:');
  For k:=1 to Turn do begin
  For i:=1 to A do begin
    For j:=1 to B do begin
      Rnd:=Random(65000);
      M[i,j]:=Rnd;
      MD^.Put(i,j,Rnd);
      end;end;
{************************************************}
{  Stream:=New(PBufStream,Init('dinamic.tvr',stCreate,1024));
  Stream^.Put(MD);
  Dispose(Stream,Done);
  Dispose(MD,Done);
  Stream:=New(PBufStream,Init('dinamic.tvr',stOpenRead,1024));
  MD:=PMatrix(Stream^.Get);
  Dispose(Stream,Done);
{************************************************}

{  For i:=1 to A do begin
    For j:=1 to B do begin
      Rnd:=MD^.Get(i,j);
      If M[i,j] <> Rnd then Test:=True;
      If KeyPressed then begin
         Writeln;
         Writeln('�ணࠬ�� ��ࢠ�� ���짮��⥫��');
         Goto A1;
         end;
      end;end;

      Str(Trunc(100*(k/turn)),S);
      S:=S+'%';
      WriteXY(30,2,S);
      end;
A1:Dispose(MD,Done);
{************************************************}
  RegisterDinamic;
  VD:=New(POptMassiv,Init(A));
  Randomize;
  WriteXY(1,2,'���� �������᪮�� ���ᨢ�:');
  For k:=1 to Turn do begin
  For i:=1 to A do begin
      Rnd:=Random(255);
      V[i]:=Rnd;
      VD^.Put(i,Rnd);
      end;
{************************************************}
  Stream:=New(PBufStream,Init('dinamic.tvr',stCreate,1024));
  Stream^.Put(VD);
  Dispose(Stream,Done);
  Dispose(VD,Done);
  Stream:=New(PBufStream,Init('dinamic.tvr',stOpenRead,1024));
  VD:=POptMassiv(Stream^.Get);
  Dispose(Stream,Done);
{************************************************}
  For i:=1 to A do begin
      Rnd:=VD^.Get(i);
      If V[i] <> Rnd then Test:=True;
      If KeyPressed then begin
         Writeln;
         Writeln('�ணࠬ�� ��ࢠ�� ���짮��⥫��');
         Goto A1;
         end;
      end;

      Str(Trunc(100*(k/turn)),S);
      S:=S+'%';
      WriteXY(30,2,S);
      end;
A1:Dispose(VD,Done);

{************************************************}
   Writeln;
   If Test Then Writeln('������� �訡�� �⥭��/������')
           else Writeln('�訡�� �� �����㦥��');
   Writeln('������ ��� ',Memory,':',MemAvail);
   Delay(1200);
end.