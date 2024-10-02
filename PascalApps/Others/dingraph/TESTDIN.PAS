program TestDin;
uses ProfDin,Crt,Windows,Objects;
Label A1;
const
      A=100;
      B=100;
type
    TMassiv = array [1..A,1..B] of real;
    TVect = array [1..A] of real;
var
   M:TMassiv;
   V:TVect;
   MD:PMatrix;
   VD:PVector;
   i,j,k:integer;
   Rnd:real;
   Memory:LongInt;
   Turn:integer;
   S:string[4];
   Test:Boolean;
   Stream:PBufStream;
begin
  Test:=False;
  ClrScr;
  Write('Введите число циклов теста: ');
  Readln(Turn);
  Memory:=MemAvail;
  RegisterType(RMatrix);
  MD:=New(PMatrix,Init(1,A,1,B,SizeOf(real)));
  Randomize;
  WriteXY(1,2,'Тест динамического массива:');
  For k:=1 to Turn do begin
  For i:=1 to A do begin
    For j:=1 to B do begin
      Rnd:=Random(65000);
      M[i,j]:=Rnd;
      MD^.Put(i,j,Rnd);
      end;end;
{************************************************}
  Stream:=New(PBufStream,Init('dinamic.tvr',stCreate,1024));
  Stream^.Put(MD);
  Dispose(Stream,Done);
  Dispose(MD,Done);
  Stream:=New(PBufStream,Init('dinamic.tvr',stOpenRead,1024));
  MD:=PMatrix(Stream^.Get);
  Dispose(Stream,Done);
{************************************************}

  For i:=1 to A do begin
    For j:=1 to B do begin
      Rnd:=MD^.Get(i,j);
      If M[i,j] <> Rnd then Test:=True;
      If KeyPressed then begin
         Writeln;
         Writeln('Программа прервана пользователем');
         Goto A1;
         end;
      end;end;

      Str(Trunc(100*(k/turn)),S);
      S:=S+'%';
      WriteXY(30,2,S);
      end;
A1:Dispose(MD,Done);
{************************************************}
{  RegisterType(RVector);
  VD:=New(PVector,Init(1,A,SizeOf(real)));
  Randomize;
  WriteXY(1,2,'Тест динамического массива:');
  For k:=1 to Turn do begin
  For i:=1 to A do begin
      Rnd:=Random(65000);
      V[i]:=Rnd;
      VD^.Put(i,Rnd);
      end;
{************************************************}
{  Stream:=New(PBufStream,Init('dinamic.tvr',stCreate,1024));
  Stream^.Put(VD);
  Dispose(Stream,Done);
  Dispose(VD,Done);
  Stream:=New(PBufStream,Init('dinamic.tvr',stOpenRead,1024));
  VD:=PVector(Stream^.Get);
  Dispose(Stream,Done);
{************************************************}
{  For i:=1 to A do begin
      Rnd:=VD^.Get(i);
      If V[i] <> Rnd then Test:=True;
      If KeyPressed then begin
         Writeln;
         Writeln('Программа прервана пользователем');
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
   If Test Then Writeln('Найдена ошибка чтение/запись')
           else Writeln('Ошибок не обнаружено');
   Writeln('Баланс кучи ',Memory,':',MemAvail);
   Delay(1200);
end.