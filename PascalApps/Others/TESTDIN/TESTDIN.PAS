program TestDin;
uses BDinamic,Crt,Windows;
Label A1;
const
      A=50;
      B=100;
type
    TMassiv = array [1..A,1..B] of real;
var
   M:TMassiv;
   MD:PMatrix;
   i,j,k:integer;
   Rnd:real;
   Memory:LongInt;
   Turn:byte;
   S:string[4];
   Test:Boolean;
begin
  Test:=False;
  ClrScr;
  Write('������ �᫮ 横��� ���: ');
  Readln(Turn);
  Memory:=MemAvail;
  MD:=New(PMatrix,Init(A,B));
  Randomize;
  WriteXY(1,2,'���� �������᪮�� ���ᨢ�:');
  For k:=1 to Turn do begin
  For i:=1 to A do begin
    For j:=1 to B do begin
      Rnd:=Random(65000);
      M[i,j]:=Rnd;
      MD^.Put(i,j,Rnd);
      end;end;
  For i:=1 to A do begin
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
   Writeln;
   If Test Then Writeln('������� �訡�� �⥭��/������')
           else Writeln('�訡�� �� �����㦥��');
   Writeln('������ ��� ',Memory,':',MemAvail);
   Delay(1200);
end.