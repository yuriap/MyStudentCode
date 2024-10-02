Unit Gauss;
Interface
uses ProfDin,Objects;
procedure Gaussmem(A : PMatrix; X, B : PVector);
procedure GaussStm(var A : PMatrix; X, B : PVector);
{предусмотреть сохранение массива B!!!}
Implementation
const
  GaussTmp = 'gauss.tmp';
procedure DelTMP(FileName:string);
var F:file;
begin
  Assign(F,FileName);
  Erase(F);
end;
procedure Gaussmem(A : PMatrix; X, B : PVector);
var
   i,j,Imax,d : integer;
   buff : real;
   AWork:PMatrix;
   Ha1,Ha2,Va1,Va2:integer;
   ASize:byte;
   N:integer;
 function MaxI(z : integer): Integer;
 var i,b : integer;
 begin
   b:=z;
   for i:=z+1 to N do
     if AWork^.Get(b,z) < AWork^.Get(i,z) then b:=i;
   MaxI:=b
 end;{MaxI}
begin
  Ha1:=A^.BeginH;
  Ha2:=A^.EndH;
  Va1:=A^.BeginV;
  Va2:=A^.EndV;
  ASize:=A^.Size;
  N:=Ha2-Ha1+1;
  AWork:=New(PMatrix,Init(Ha1,Ha2,Va1,Va2));
  for i:=1 to N do begin
   for j:=1 to N do begin
     AWork^.Put(i,j,A^.Get(i,j));
     end;
  end;{for}
  d:=1;
  repeat
  IMax:=MaxI(d);
  If Imax <> d then begin
   for j:=1 to N do begin
    buff:=AWork^.Get(Imax,j);
    AWork^.Put(Imax,j,AWork^.Get(d,j));
    AWork^.Put(d,j,buff);
    end;{for}
   buff:= B^.Get(Imax);
   B^.Put(Imax,B^.Get(d));
   B^.Put(d,buff);
   end;{if}
  {*************}
  buff:=AWork^.Get(d,d);
  for j:=d to N do
    AWork^.Put(d,j,AWork^.Get(d,j)/buff);
  B^.Put(d,B^.Get(d)/buff);
  {******************}
  for i:=d+1 to N do begin
   buff:=AWork^.Get(i,d);
   for j:=d to N do
     AWork^.Put(i,j,AWork^.Get(i,j)-AWork^.Get(d,j)*buff);
   B^.Put(i,B^.Get(i)-B^.Get(d)*buff);
  end;{for}
  d:=d+1;
  Until d > N;
  {*************}
  for i:=1 to N do X^.Put(i,0.0);
  for i:=N downto 1 do begin
   buff:=0.0;
   for j:=1 to N do
     buff:=buff+AWork^.Get(i,j)*X^.Get(j);
   X^.Put(i,B^.Get(i)-buff);
   end;{for}
end;{gaussmem}
procedure GaussStm(var A : PMatrix; X, B : PVector);
var
   i,j,Imax,d : integer;
   buff : real;
   Ha1,Ha2,Va1,Va2:integer;
   ASize:byte;
   N:integer;
   S:PBufStream;
 function MaxI(z : integer): Integer;
 var i,b : integer;
 begin
   b:=z;
   for i:=z+1 to N do
     if A^.Get(b,z) < A^.Get(i,z) then b:=i;
   MaxI:=b
 end;{MaxI}
begin
  S:=New(PBufStream,Init(GaussTmp,stCreate,1024));
  S^.Put(A);
  Dispose(S,Done);
  N:=A^.EndH-A^.BeginH+1;
  d:=1;
  repeat
  IMax:=MaxI(d);
  If Imax <> d then begin
   for j:=1 to N do begin
    buff:=A^.Get(Imax,j);
    A^.Put(Imax,j,A^.Get(d,j));
    A^.Put(d,j,buff);
    end;{for}
   buff:= B^.Get(Imax);
   B^.Put(Imax,B^.Get(d));
   B^.Put(d,buff);
   end;{if}
  {*************}
  buff:=A^.Get(d,d);
  for j:=d to N do
    A^.Put(d,j,A^.Get(d,j)/buff);
  B^.Put(d,B^.Get(d)/buff);
  {******************}
  for i:=d+1 to N do begin
   buff:=A^.Get(i,d);
   for j:=d to N do
     A^.Put(i,j,A^.Get(i,j)-A^.Get(d,j)*buff);
   B^.Put(i,B^.Get(i)-B^.Get(d)*buff);
  end;{for}
  d:=d+1;
  Until d > N;
  {*************}
  for i:=1 to N do X^.Put(i,0.0);
  for i:=N downto 1 do begin
   buff:=0.0;
   for j:=1 to N do
     buff:=buff+A^.Get(i,j)*X^.Get(j);
   X^.Put(i,B^.Get(i)-buff);
   end;{for}

   Dispose(A,Done);
  S:=New(PBufStream,Init(GaussTmp,stOpenRead,1024));
  A:=PMatrix(S^.Get);
  Dispose(S,Done);
  DelTMP(GaussTmp);
end;{gaussstm}

begin
end.
