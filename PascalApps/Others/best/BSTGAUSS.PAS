unit BstGauss;
interface
const
    dim = 10;
type
    TLeftPart = array [1..dim,1..dim] of real;
    TRightIncPart = array [1..dim] of real;
    PLeftPart = ^TLeftPart;
    PRightIncPart = ^TRightIncPart;
procedure Gauss1(a:TLeftPart;b:TRightIncPart;var x:TRightIncPart;
n :integer;var Ierr:integer);
procedure Gauss2(A : PLeftPart;B,X : PRightIncPart;N :integer);
procedure InvertMatrix(A,Y : PLeftPart;N:integer);
procedure NewInvertMatrix(A,Y:PLeftPart;N:integer);
procedure MultiplyMatrix(A : PLeftPart;B,X:PRightIncPart;N:integer);

implementation
procedure Gauss2(A : PLeftPart;B,X : PRightIncPart;N :integer);
var
   Az:PLeftPart;
   i,j,Imax,d : integer;
   buff : real;
 function MaxI(z : integer): Integer;
 var i,b : integer;
 begin
   b:=z;
   for i:=z+1 to N do
     if Az^[b,z] < Az^[i,z] then b:=i;
   MaxI:=b
 end;{MaxI}
begin
  New(Az);
  Az^:=A^;
  d:=1;
  repeat
  IMax:=MaxI(d);
  If Imax <> d then begin
   for j:=1 to N do begin
    buff:=Az^[Imax,j];
    Az^[Imax,j]:=Az^[d,j];
    Az^[d,j]:=buff;
    end;{for}
   buff:= B^[Imax];
   B^[Imax]:=B^[d];
   B^[d]:=buff;
   end;{if}
  {*************}
  buff:=Az^[d,d];
  for j:=1 to N do
    Az^[d,j]:=Az^[d,j]/buff;
  B^[d]:=B^[d]/buff;
  {******************}
  for i:=d+1 to N do begin
   buff:=Az^[i,d];
   for j:=1 to N do
     Az^[i,j]:=Az^[i,j]-Az^[d,j]*buff;
   B^[i]:=B^[i]-B^[d]*buff;
  end;{for}
  d:=d+1;
  Until d > N;
  {*************}
  for i:=1 to N do X^[i]:=0.0;
  for i:=N downto 1 do begin
   buff:=0.0;
   for j:=1 to N do
     buff:=buff+Az^[i,j]*X^[j];
   X^[i]:=B^[i]-buff;
   end;{for}
  Dispose(Az);
end;{gauss}
procedure InvertMatrix(A,Y : PLeftPart;N:integer);
var{Метод Гаусса старого образца. Конечный результат без погрешности}
  Aq,Yq:TLeftPart;
  X1,E:TRightIncPart;
  i,j,Q:integer;
begin
 Aq:=A^;
for i:=1 to N do E[i]:=0.0;
for i:=1 to N do begin
 If i>1 then E[i-1]:=0.0;
 E[i]:=1.0;
 Gauss1(Aq,E,X1,N,Q);
 for j:=1 to N do Yq[j,i]:=X1[j];
 Y^:=Yq;
end;{for}
end;{InvertMatrix}
procedure NewInvertMatrix(A,Y:PLeftPart;N:integer);
var{Метод Гаусса нового образца. Конечный результат с погрешностью}
  X1,E:PRightIncPart;
  i,j:integer;
begin
 New(E);
 New(X1);
for i:=1 to N do E^[i]:=0.0;
for i:=1 to N do begin
 If i>1 then E^[i-1]:=0.0;
 E^[i]:=1.0;
 Gauss2(A,E,X1,N);
 for j:=1 to N do Y^[j,i]:=X1^[j];
end;{for}
end;{InvertMatrix}

procedure MultiplyMatrix(A : PLeftPart;B,X:PRightIncPart;N:integer);
var
   i,j:integer;
   buff:real;
begin
  for i:=1 to N do begin
   buff:=0.0;
   for j:=1 to N do buff:=buff+ A^[i,j]*B^[j];
   X^[i]:=buff;
   end;{for}
End;{MultiplyMatrix}
PROCEDURE Gauss1(a:TLeftPart;b:TRightIncPart;var x:TRightIncPart;
n :integer;var Ierr:integer);
{решение системы линейных уравнений}
Label 160;
Var
       WorkA                                  :TLeftPart;
       IX,IY                                  :array [1..dim] of integer;
       y,z                                    :real;
       i,j,k,l,m,line,column,cl,cc,cl1,
       cc1,N1,N2,t,r,s,w                      :integer;
Begin
      Ierr:=0;
      N1:=N-1;
      N2:=N-2;
     For i:=1 to N do
     begin
        For j:=1 to N do
        begin
           WorkA[i,j]:=A[i,j];
        end;
        IY[i]:=i;
        IX[i]:=i;
        X[i]:=B[i];
     end;
      For cl:=1 to N1 do
      begin
      cc:=cl;
      line:=cl;
      column:=cc;
      For i:=cl to N do
         begin
         For j:=cc to N do
            begin
            If Abs(WorkA[line,column]) < Abs(WorkA[i,j]) then
               begin
               line:=i;
               column:=j;
               end;
            end;
         end;
      if cl <> line then
         begin
         For j:=cc to N do
            begin
            y:=WorkA[line,j];
            WorkA[line,j]:=WorkA[cl,j];
            WorkA[cl,j]:=y;
            end;
         z:=X[line];
         X[line]:=X[cl];
         X[cl]:=z;
         k:=IY[line];
         IY[line]:=IY[cl];
         IY[cl]:=k;
         end;
      if cc <> column then
         begin
         For i:=1 to N do
            begin
            y:=WorkA[i,column];
            WorkA[i,column]:=WorkA[i,cl];
            WorkA[i,cl]:=y;
            end;
         k:=IX[column];
         IX[column]:=IX[cc];
         IX[cc]:=k;
         end;
      if  Abs(WorkA[cl,cc]) < 1.E-20 then
         begin
         Ierr:=IY[cl];
         Goto 160;
         end;
      cl1:=cl+1;
      cc1:=cc+1;
      For j:=cc1 to N do
         begin
         WorkA[cl,j]:=WorkA[cl,j]/WorkA[cl,cc];
         end;
      X[cl]:=X[cl]/WorkA[cl,cc];
      WorkA[cl,cc]:=1.0;
      For i:=cl1 to N do
         begin
         z:=WorkA[i,cc];
         WorkA[i,cc]:=0.0;
         For j:=cc1 to N do
            begin
            WorkA[i,j]:=WorkA[i,j]-WorkA[cl,j]*z;
            end;
         X[i]:=X[i]-X[cl]*z;
         end;
     end;
      if  Abs(WorkA[N,N]) < 1.E-20 then {знак отношения наоборот}
         begin
         Ierr:=-IY[N];
         Goto 160;
         end;
      X[N]:=X[N]/WorkA[N,N];
      For k:=0 to N2 do
         begin
         j:=N-k;
         m:=k+1;
         For l:=m to N1 do
            begin
            i:=N-l;
            z:=WorkA[i,j];
            X[i]:=X[i]-X[j]*z;
            end;
         end;
      For i:=1 to N do
         begin
         WorkA[i,1]:=X[i];
         end;
      For i:=1 to N do
         begin
         k:=IX[i];
         X[k]:=WorkA[i,1];
         end;
160:
End;
begin
end.
