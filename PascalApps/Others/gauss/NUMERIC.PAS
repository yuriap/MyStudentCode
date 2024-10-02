program Numeric;
uses crt,dos,bstgauss,windows;
var
   Ar,A1:PLeftPart;
   Br,Xr,Xr1:PRightIncPart;
   Ad:TLeftPart;
   Bd,Xd:TRightIncPart;
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
 NewInvertMatrix(Ar,A1,dim);
 MultiplyMatrix(A1,Br,Xr,dim);
{  Gauss2(Ar,Br,Xr,Dim);}
 GetTime(Hr,Mr,Sr,S100r);
 Hv:=Hr-H;Mv:=Mr-M;Sv:=Sr-s;
 S100v:=S100r+(100-S100);
{   S100v:=S100r-S100;           }

 GetTime(H,M,S,S100);
{ InvertMatrix(Ar,A1,dim);
 MultiplyMatrix(A1,Br,Xr1,dim);}
 Gauss1(Ad,Bd,Xd,Dim,I);
 GetTime(Hr,Mr,Sr,S100r);
 Hr:=Hr-H;Mr:=Mr-M;Sr:=Sr-s;
{ S100v:=S100r+(100-S100);}
  S100v:=S100r-S100;


 MakeWindow(1,1,79,24,1,14);
 Writeln;
 Writeln('     BestGauus                 BadGauss');
 Writeln;
 for i:=1 to dim do  Writeln('     ',Xr^[i],'      ',Xd[i]);
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
