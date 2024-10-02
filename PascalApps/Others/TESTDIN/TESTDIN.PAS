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
  Write('Введите число циклов теста: ');
  Readln(Turn);
  Memory:=MemAvail;
  MD:=New(PMatrix,Init(A,B));
  Randomize;
  WriteXY(1,2,'Тест динамического массива:');
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
         Writeln('Программа прервана пользователем');
         Goto A1;
         end;
      end;end;

      Str(Trunc(100*(k/turn)),S);
      S:=S+'%';
      WriteXY(30,2,S);
      end;
A1:Dispose(MD,Done);
   Writeln;
   If Test Then Writeln('Найдена ошибка чтение/запись')
           else Writeln('Ошибок не обнаружено');
   Writeln('Баланс кучи ',Memory,':',MemAvail);
   Delay(1200);
end.