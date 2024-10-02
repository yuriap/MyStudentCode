program Map_Test;
uses ProfDin,ProfComm;
const MapName = 'prof2.mpc';
      MapInfo = 'prof1.inf';
var
   f:text;
   Maps:PMapProf;
   x,y:real;
   Len:integer;
   i:integer;
   Mem:LongInt;
   S:real;
   Lit:string[2];
procedure MakeSCoord(MapPtr:PMapProf);
var S:real;
    i:integer;
    Len:integer;
begin
 S:=0;
 Len:=MapPtr^.M;
 For i:=1 to Len-1 do begin
   MapPtr^.PutS(i,S);
   S:=S+Sqrt(Sqr(MapPtr^.GetX(i+1)-MapPtr^.GetX(i))
       +Sqr(MapPtr^.GetY(i+1)-MapPtr^.GetY(i)));
   end;
   MapPtr^.PutS(Len,S);
end;
function ArcCos(X:real):real;
begin
 if x = 0.0 Then ArcCos:=Pi/2
 else ArcCos := ArcTan (sqrt (1-sqr (x)) /x);
end;
function ArcSin(X:real):real;
begin
 if x = 0.0 Then ArcSin:=0.0
 else ArcSin := ArcTan (x/sqrt (1-sqr (x)));
end;

procedure MakeCos(MapPtr:PMapProf);
var
    i:integer;
    Len:integer;
    RAbs:real;
    x,y:real;
begin
 With MapPtr^ do begin
 Len:=M;
 For i:=2 to Len-1 do begin
   RAbs:=Sqrt(Sqr(GetX(i+1)-GetX(i-1))+Sqr(GetY(i+1)-GetY(i-1)));
   PutTX(i,(GetX(i+1)-GetX(i-1))/RAbs);
   PutTY(i,(GetY(i+1)-GetY(i-1))/RAbs);
   x:=(GetX(i+1)+GetX(i-1))/2;
   y:=(GetY(i+1)+GetY(i-1))/2;
   RAbs:=Sqrt(Sqr(GetX(i)-x)+Sqr(GetY(i)-y));
   PutNX(i,(GetX(i)-x)/RAbs);
   PutNY(i,(GetY(i)-y)/RAbs);
   end;{for}
   RAbs:=Sqrt(Sqr(GetX(2)-GetX(Len-1))+Sqr(GetY(2)-GetY(Len-1)));
   PutTX(1,(GetX(2)-GetX(Len-1))/RAbs);
   PutTY(1,(GetY(2)-GetY(Len-1))/RAbs);
   PutTX(Len,GetTX(1));
   PutTY(Len,GetTY(1));

   RAbs:=Sqrt(Sqr(GetX(1)-(GetX(2)+GetX(Len-1))/2)+
              Sqr(GetY(1)-(GetY(2)+GetY(Len-1))/2));
   PutNX(1,(GetX(1)-(GetX(2)+GetX(Len-1))/2)/RAbs);
   PutNY(1,(GetY(1)-(GetY(2)+GetY(Len-1))/2)/RAbs);
   PutNX(Len,GetNX(1));
   PutNY(Len,GetNY(1));
   end;{with}
end;{MakeCos}
procedure OutMap(var info:text);
var i:integer;
begin
  Writeln(Info,' X        ','Y        ','S        ','NX       ','NY       ',
  'TX       ','TY');
  with Maps^ do begin
  For i:=1 to M do
   Writeln(Info,GetX(i):7:4,'  ',GetY(i):7:4,'  ',
           GetS(i):7:4,'  ',GetNX(i):7:4,'  ',GetNY(i):7:4,'  ',
           GetTX(i):7:4,'  ',GetTY(i):7:4);
  end;{with}
end;{OutMap}
procedure Test(var fil:Text);
var x,dx:real;
    Max:real;
begin
  Writeln(fil,' S        ','X        ','Y        ','NX       ','NY       ',
   'TX       ','TY');
   With Maps^ do begin
   For i:=1 to M do begin
   X:=GetS(i);
   Writeln(fil,X:7:4,'  ',Get_X_S(X):7:4,'  ',
           Get_Y_S(X):7:4,'  ',Get_NX_S(X):7:4,'  ',Get_NY_S(X):7:4,'  ',
           Get_TX_S(X):7:4,'  ',Get_TY_S(X):7:4);
   end;end;
end;
procedure TestAllMap(Map:PMapProf);
var OutInfo:text;
begin
  Assign(OutInfo,MapInfo);
  ReWrite(OutInfo);
  OutMap(OutInfo);
  Close(OutInfo);

  Assign(OutInfo,'prof2bis.inf');
  ReWrite(OutInfo);
  Test(OutInfo);
  Close(OutInfo);
end;{TestAllMap}
begin
 Mem:=MemAvail;
 Assign(f,MapName);
 Reset(f);
 Readln(f,Len);
 Readln(f);
 Maps:=New(PMapProf,Init(Len));
 For i:=1 to Len do begin
   Readln(f,lit,x,y,S);
   Maps^.PutX(i,x);
   Maps^.PutY(i,y);
   Maps^.PutS(i,S);
   end;
 Close(f);
{ MakeSCoord(Maps);}
 MakeCos(Maps);
 TestAllMap(Maps);
 Dispose(Maps,Done);
 Writeln('Баланс ',Mem,':',MemAvail);
end.