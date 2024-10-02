program BstGauss;
Uses Dos,Crt,Ugauss,Windows;
const
    dim = 10;
type
    TAMas = LeftPartType;{array [1..dim,1..dim] of real;}
    TBXMas = RightIncPartType;{array [1..dim] of real;}
    PAMas = ^TAMas;
    PBXMas = ^TBXMas;

procedure GaussA(A,B,X:pointer;N :integer);
var
   Az : PAMas;
   Bz,Xz: PBXMas;
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
  Az^:=PAMas(A)^;
  Bz:=PBXMas(B);
  Xz:=PBXMas(X);
  d:=1;
  repeat
  IMax:=MaxI(d);
  If Imax <> d then begin
   for j:=1 to N do begin
    buff:=Az^[Imax,j];
    Az^[Imax,j]:=Az^[d,j];
    Az^[d,j]:=buff;
    end;{for}
   buff:= Bz^[Imax];
   Bz^[Imax]:=Bz^[d];
   Bz^[d]:=buff;
   end;{if}
  {*************}
  buff:=Az^[d,d];
  for j:=1 to N do
    Az^[d,j]:=Az^[d,j]/buff;
  Bz^[d]:=Bz^[d]/buff;
  {******************}
  for i:=d+1 to N do begin
   buff:=Az^[i,d];
   for j:=1 to N do
     Az^[i,j]:=Az^[i,j]-Az^[d,j]*buff;
   Bz^[i]:=Bz^[i]-Bz^[d]*buff;
  end;{for}
  d:=d+1;
  Until d > N;
  {*************}
  for i:=1 to N do Xz^[i]:=0.0;
  for i:=N downto 1 do begin
   buff:=0.0;
   for j:=1 to N do
     buff:=buff+Az^[i,j]*Xz^[j];
   Xz^[i]:=Bz^[i]-buff;
   end;{for}
  Dispose(Az);
end;{gauss}
procedure InvertMatrix(A,Y:pointer;N:integer);
var{Метод Гаусса старого образца. Конечный результат без погрешности}
  Aq,Yq:LeftPartType;
  X1,E:RightIncPartType;
  i,j,Q:integer;
begin
 Aq:=PAMas(A)^;
for i:=1 to N do E[i]:=0.0;
for i:=1 to N do begin
 If i>1 then E[i-1]:=0.0;
 E[i]:=1.0;
 Gauss(Aq,E,X1,N,Q);
 for j:=1 to N do Yq[j,i]:=X1[j];
 PAMas(Y)^:=Yq;
end;{for}
end;{InvertMatrix}
procedure NewInvertMatrix(A,Y:pointer;N:integer);
var{Метод Гаусса нового образца. Конечный результат с погрешностью}
  Aq,Yq:PAMas;
  X1,E:PBXMas;
  i,j:integer;
begin
 Aq:=PAMas(A);
 Yq:=PAMas(Y);
 New(E);
 New(X1);
for i:=1 to N do E^[i]:=0.0;
for i:=1 to N do begin
 If i>1 then E^[i-1]:=0.0;
 E^[i]:=1.0;
 GaussA(Aq,E,X1,N);
 for j:=1 to N do Yq^[j,i]:=X1^[j];
end;{for}
end;{InvertMatrix}

procedure MultiplyMatrix(A,B,X:pointer;N:integer);
var
   Az : PAMas;
   Bz,Xz: PBXMas;
   i,j:integer;
   buff:real;
begin
  Az:=PAMas(A);
  Bz:=PBXMas(B);
  Xz:=PBXMas(X);
  for i:=1 to N do begin
   buff:=0.0;
   for j:=1 to N do buff:=buff+ Az^[i,j]*Bz^[j];
   Xz^[i]:=buff;
   end;{for}
End;{MultiplyMatrix}
var
   Ar,A1:PAMas;
   Br,Xr,Xr1:PBXMas;
   Ad:LeftPartType;
   Bd,Xd:RightIncPartType;
   fil : text;
   i,j : integer;
   {time}
   H,M,S,S100:word;
   Hr,Mr,Sr,S100r:word;
   Hv,Mv,Sv,S100v:word;
begin
 New(Ar);
 New(Br);
 New(Xr);
 New(Xr1);
 New(A1);
 Assign(fil,'gauss.dat');
 Reset(fil);
  for i:= 1 to dim do begin
   for j:= 1 to dim do begin read(Fil,Ar^[i,j]);Ad[i,j]:=Ar^[i,j];end;
   readln(fil,Br^[i]);
   Bd[i]:=Br^[i];
   end;{for}
 Close(fil);




 GetTime(H,M,S,S100);
{ NewInvertMatrix(Ar,A1,dim);
 MultiplyMatrix(A1,Br,Xr,dim);}
  GaussA(Ar,Br,Xr,Dim);
 GetTime(Hr,Mr,Sr,S100r);
 Hv:=Hr-H;Mv:=Mr-M;Sv:=Sr-s;
 S100v:=S100r+(100-S100);


 GetTime(H,M,S,S100);
{ InvertMatrix(Ar,A1,dim);
 MultiplyMatrix(A1,Br,Xr1,dim);}
 Gauss(Ad,Bd,Xd,Dim,I);
 GetTime(Hr,Mr,Sr,S100r);
 Hr:=Hr-H;Mr:=Mr-M;Sr:=Sr-s;
 S100v:=S100r+(100-S100);
 MakeWindow(1,1,79,24,1,14);
 Writeln;
 Writeln('     BestGauus     BadGauss');
 Writeln;
 for i:=1 to dim do  Writeln('     ',Xr^[i]:8:5,'      ',Xd[i]:8:5);
 Writeln;
 Writeln(' Time of work');
 Writeln;
 Writeln(' Hour ',Hv:8,'      ',Hr:8);
 Writeln(' Min  ',Mv:8,'      ',Mr:8);
 Writeln(' Sec  ',Sv:8,'      ',Sr:8);
 Writeln(' S100 ',S100v:8,'      ',S100r:8);
 readkey;
 Dispose(Ar);
 Dispose(Br);
 Dispose(Xr);
 Dispose(A1);
 Dispose(xr1);
end.