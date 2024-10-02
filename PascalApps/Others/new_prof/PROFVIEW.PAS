Unit ProfView;
interface
uses Objects,ProfComm,Profile,Graph;

type
   TColors = array [0..5] of byte;
   {0 - фон
    1 - контрольние точки
    2 - присоединеные вихри
    3 - свободние вихри
    4 - точки схода вихрей
    5 - оси координат}
   TViewRec = record
     MX,MY:real;
     DX,DY:integer;
     Col:TColors;
     end;
   PProfViewer = ^TProfViewer;
   TProfViewer = object(TObject)
       MashX,MashY:real;
       DelX,DelY:integer;
       Colors:TColors;
       constructor Init(ViewRec:TViewRec);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
{       procedure Show(P:PProfile);
       procedure Hide(P:PProfile);}
       procedure Draw(P:PProfile);
       procedure Fig1(R:TPoint);
       procedure Fig2(R:TPoint);
       procedure Fig3(R:TPoint);
       end;
implementation
constructor TProfViewer.Init(ViewRec:TViewRec);
begin
  inherited Init;
  With ViewRec do begin
  MashX:=MX;
  MashY:=MY;
  DelX:=DX;
  DelY:=DY;
  Colors:=Col;
  end;
end;
constructor TProfViewer.Load(var S:TStream);
begin
  S.Read(MashX,SizeOf(MashX));
  S.Read(MashY,SizeOf(MashY));
  S.Read(DelX,SizeOf(DelX));
  S.Read(DelY,SizeOf(DelY));
  S.Read(Colors,SizeOf(Colors));
end;
procedure TProfViewer.Store(var S:TStream);
begin
  S.Write(MashX,SizeOf(MashX));
  S.Write(MashY,SizeOf(MashY));
  S.Write(DelX,SizeOf(DelX));
  S.Write(DelY,SizeOf(DelY));
  S.Write(Colors,SizeOf(Colors));
end;
procedure TProfViewer.Draw(P:PProfile);
var i:integer;
    Rg:TPoint;
    Rr:TPoints;
begin
  SetColor(Colors[1]);
  For i:= 1 to P^.N do begin
    P^.GetCP(i)^.GetCoord(Rr);
    Rg.X:=Trunc(Rr.X*MashX)+DelX;
    Rg.Y:=Trunc(Rr.Y*MashY)+DelY;
    Fig1(Rg);
    end;
  SetColor(Colors[2]);
  For i:= 1 to P^.N-1 do begin
    P^.GetCA(i)^.GetCoord(Rr);
    Rg.X:=Trunc(Rr.X*MashX)+DelX;
    Rg.Y:=Trunc(Rr.Y*MashY)+DelY;
    Fig2(Rg);
    end;
  SetColor(Colors[3]);
  For i:= 1 to P^.NBreak do begin
    P^.GetBP(i)^.GetCoord(Rr);
    Rg.X:=Trunc(Rr.X*MashX)+DelX;
    Rg.Y:=Trunc(Rr.Y*MashY)+DelY;
    Fig3(Rg);
    end;
end;
procedure TProfViewer.Fig1(R:TPoint);
begin
  Bar(R.X-2,R.Y-2,R.X+2,R.Y+2);
end;
procedure TProfViewer.Fig2(R:TPoint);
begin
  Circle(R.X,R.Y,4);
end;
procedure TProfViewer.Fig3(R:TPoint);
begin
  Circle(R.X,R.Y,5);
  Line(R.X,R.Y-10,R.X,R.Y+10);
  Line(R.X-10,R.Y,R.X+10,R.Y);
end;
{procedure TProfViever.Show(P:PProfile);
procedure TProfViever.Hide(P:PProfile);}
begin
end.