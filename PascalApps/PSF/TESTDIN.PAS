program TestDin;
uses ProfDin,Crt,Windows,Objects;
Label A1;
const
      A=-50;A0=-70;
      B=15;B0=-10;
type
    TMassiv = array [A0..A,B0..B] of real;
    TVect = array [A0..A] of real;
var
   M:TMassiv;
   V:TVect;
   MD:PMatrix;
   VD:PVector;
   k,i1,j1:integer;
   Rnd:real;
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
{************************************************}
{  RegisterDinamic;
  MD:=New(PMatrix,Init(A0,A,B0,B));
  Randomize;
  WriteXY(1,2,'���� �������᪮�� ���ᨢ�:');
  For k:=1 to Turn do begin
  For i1:=A0 to A do begin
    For j1:=B0 to B do begin
      Rnd:=Random(65000);
      M[i1,j1]:=Rnd;
      MD^.Put(i1,j1,Rnd);
      end;end;
  Stream:=New(PBufStream,Init('dinamic.tvr',stCreate,1024));
  Stream^.Put(MD);
  Dispose(Stream,Done);
  Dispose(MD,Done);
  Stream:=New(PBufStream,Init('dinamic.tvr',stOpenRead,1024));
  MD:=PMatrix(Stream^.Get);
  Dispose(Stream,Done);
  For i1:=A0 to A do begin
    For j1:=B0 to B do begin
      Rnd:=MD^.Get(i1,j1);
      If M[i1,j1] <> Rnd then begin
        Test:=True;
        Writeln;
        Writeln('�訡�� � ������� ',i1,':',j1);
      If KeyPressed then begin
         Writeln;
         Writeln('�ணࠬ�� ��ࢠ�� ���짮��⥫��');
         end;
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
  VD:=New(PVector,Init(A0,A));
  Randomize;
  WriteXY(1,2,'���� �������᪮�� ���ᨢ�:');
  For k:=1 to Turn do begin
  For i1:=A0 to A do begin
      Rnd:=Random(255);
      V[i1]:=Rnd;
      VD^.Put(i1,Rnd);
      end;
  Stream:=New(PBufStream,Init('dinamic.tvr',stCreate,1024));
  Stream^.Put(VD);
  Dispose(Stream,Done);
  Dispose(VD,Done);
  Stream:=New(PBufStream,Init('dinamic.tvr',stOpenRead,1024));
  VD:=PVector(Stream^.Get);
  Dispose(Stream,Done);
  For i1:=A0 to A do begin
      Rnd:=VD^.Get(i1);
      If V[i1] <> Rnd then Test:=True;
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