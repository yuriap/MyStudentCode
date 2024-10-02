program G;
{Interface}
Uses Crt,Windows;
const
    dim = 11;{Размерность решаемой системы}
type
    LeftPartType = array [1..dim,1..dim] of real;{левая часть}
    RightIncPartType = array [1..dim] of real;{правая часть и массив неизвестных}

{procedure Gauss(A : LeftPartType; B,X : RightIncPartType; N :integer);

Implementation}

procedure Gauss(A : LeftPartType; B,X : RightIncPartType; N :integer);
var
   AWork : LeftPartType;
   i,j,Imax,d : integer;
   buff : real;
 function MaxI(z : integer): Integer;
 var i,b : integer;
 begin
   b:=z;
   for i:=z+1 to N do
     if A[b,z] < A[i,z] then b:=i;
   MaxI:=b
 end;{MaxI}
begin
  AWork:=A;
  d:=1;
  repeat
  IMax:=MaxI(d);
  If Imax <> d then begin
   for j:=1 to N do begin
    buff:=AWork[Imax,j];
    AWork[Imax,j]:=AWork[d,j];
    AWork[d,j]:=buff;
    end;{for}
   buff:= B[Imax];
   B[Imax]:=B[d];
   B[d]:=buff;
   end;{if}
  {*************}
  buff:=AWork[d,d];
  for j:=1 to N do
    AWork[d,j]:=AWork[d,j]/buff;
  B[d]:=B[d]/buff;
  {******************}
  for i:=d+1 to N do begin
   buff:=AWork[i,d];
   for j:=1 to N do
     AWork[i,j]:=AWork[i,j]-AWork[d,j]*buff;
   B[i]:=B[i]-B[d]*buff;
  end;{for}
  d:=d+1;
  Until d > N;
  {*************}
  for i:=1 to N do X[i]:=0.0;
  for i:=N downto 1 do begin
   buff:=0.0;
   for j:=1 to N do
     buff:=buff+AWork[i,j]*X[j];
   X[i]:=B[i]-buff;
   end;{for}
end;{gauss}
var
   A:LeftPartType;
   B,X:RightIncPartType;
   fil : text;
   i,j : integer;
begin
 Assign(fil,'gauss.dat');
 Reset(fil);
  for i:= 1 to dim do begin
   for j:= 1 to dim do begin
    read(fil,A[i,j]);
    end;
    read(fil,B[i]);
    end;
 Close(fil);
  Gauss(A,B,X,Dim);
 MakeWindow(1,1,79,24,1,14);
 Writeln;
 Writeln('     BestGauus     BadGauss');
 Writeln;
 for i:=1 to dim do  Writeln('     ',X[i]);
 Writeln;
 readkey;
end.