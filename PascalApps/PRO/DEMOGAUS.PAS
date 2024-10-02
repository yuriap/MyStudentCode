program DemoGauss;
Uses ProfDin,Gauss,Crt;
var
   A:PMatrix;
   B,X:PVector;
   fil : text;
   i,j : integer;
   buff:real;
const
   Dim=11;
begin
 A:=New(PMatrix,Init(1,dim,1,dim,SizeOf(real)));
 B:=New(PVector,Init(1,dim,SizeOf(Real)));
 X:=New(PVector,Init(1,dim,SizeOf(Real)));
 Assign(fil,'gauss.dat');
 Reset(fil);
  for i:= 1 to dim do begin
   for j:= 1 to dim do begin
    read(fil,buff);
    A^.Put(i,j,buff)
    end;
    readln(fil,buff);
    B^.Put(i,buff);
    end;
 Close(fil);

 Gaussmem(A,X,B);
 ClrScr;
 for i:=1 to dim do  Writeln('     ',X^.Get(i));

 Writeln;
 Writeln('This is a GaussMem');
 readkey;
 Assign(fil,'gauss.dat');
 Reset(fil);
  for i:= 1 to dim do begin
   for j:= 1 to dim do begin
    read(fil,buff);
    A^.Put(i,j,buff)
    end;
    readln(fil,buff);
    B^.Put(i,buff);
    end;
 Close(fil);

 Gaussstm(A,X,B);
 for i:=1 to dim do  Writeln('     ',X^.Get(i));
 Writeln;
 Writeln('This is a GaussStm');
 readkey;

 Dispose(A,Done);
 Dispose(B,Done);
 Dispose(X,Done);
end.