program DemoGauss;
Uses Gausses,Crt;
var
   A:LeftPartType;
   B,X:RightIncPartType;
   fil : text;
   i,j : integer;
begin
 Assign(fil,'gauss1.dat');
 Reset(fil);
  for i:= 1 to dim do begin
   for j:= 1 to dim do begin
    read(fil,A[i,j]);
    end;
    readln(fil,B[i]);
    end;
 Close(fil);

 Gauss(A,B,X,Dim);

 for i:=1 to dim do  Writeln('     ',X[i]);
 Writeln;
 Writeln('Press any key to continue');
 readkey;
end.