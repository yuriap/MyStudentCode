Unit ProfView;
interface
uses Objects,ProfComm,Profile,ProfMain,Graph;
Type
   PColors = ^TColors;
   TColors = array [0..15] of byte;
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
   PViewer = ^TViewer;
   TViewer = object(TObject)
       MashX,MashY:real;
       DelX,DelY:integer;
       Colors:TColors;
       constructor Init(ViewRec:TViewRec);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       procedure Show(P:PMain);
       procedure Hide(P:PMain);
       procedure ConvScrCoord(Plase:TPoints;var Where:TPoint);
       procedure Fig1(R:TPoint);
       procedure Fig2(R:TPoint);
       procedure Fig3(R:TPoint);
       procedure Fig4(R:TPoint);
       procedure DrawCoord;
       procedure DrawLocalCoord(P:PProfile);
       end;
const
   RViewer : TStreamRec = (
      ObjType : idViewer;
      VmtLink: Ofs(TypeOf(TViewer)^);
      Load:@TViewer.Load;
      Store:@TViewer.Store);

implementation
constructor TViewer.Init(ViewRec:TViewRec);
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
constructor TViewer.Load(var S:TStream);
begin
  S.Read(MashX,SizeOf(MashX));
  S.Read(MashY,SizeOf(MashY));
  S.Read(DelX,SizeOf(DelX));
  S.Read(DelY,SizeOf(DelY));
  S.Read(Colors,SizeOf(Colors));
end;
procedure TViewer.Store(var S:TStream);
begin
  S.Write(MashX,SizeOf(MashX));
  S.Write(MashY,SizeOf(MashY));
  S.Write(DelX,SizeOf(DelX));
  S.Write(DelY,SizeOf(DelY));
  S.Write(Colors,SizeOf(Colors));
end;
procedure TViewer.ConvScrCoord(Plase:TPoints;var Where:TPoint);
begin
  Where.Y:=-1*Trunc(Plase.Y*MashY)+DelY;
  Where.X:=Trunc(Plase.X*MashX)+DelX;
end;
procedure TViewer.Show(P:PMain);
var i:integer;
    Rg:TPoint;
    Rr:TPoints;
begin
  SetBkColor(Colors[0]);
  SetColor(Colors[5]);
  DrawCoord;
  For i:= 1 to P^.CountProfil do DrawLocalCoord(P^.GetProfile(i));
  SetColor(Colors[1]);
  For i:= 1 to P^.CountCP*P^.CountProfil do begin
    P^.GetGlobalCP(i)^.GetCoord(Rr);
    PProfile(P^.GetGlobalCP(i)^.GetOwner)^.ConvLocAbs(Rr);
    ConvScrCoord(Rr,Rg);
    Fig1(Rg);
    end;
  SetColor(Colors[2]);
  For i:= 1 to P^.CountCP*P^.CountProfil do begin
    P^.GetGlobalCA(i)^.GetCoord(Rr);
    PProfile(P^.GetGlobalCA(i)^.GetOwner)^.ConvLocAbs(Rr);
    ConvScrCoord(Rr,Rg);
    Fig3(Rg);
    end;
  SetColor(Colors[3]);
  If P^.CountCF <> 0 Then begin
  For i:=1 to P^.CountCF do begin
    P^.GetGlobalCF(i)^.GetCoord(Rr);
    ConvScrCoord(Rr,Rg);
    Fig3(Rg);
    end;end;
{  SetColor(Colors[4]);
  If P^.BreakPoint^.Count <> 0 Then begin
  For i:= 1 to P^.NBreak do begin
    P^.GetBP(i)^.GetCoord(Rr);
    ConvScrCoord(Rr,Rg);
    Fig4(Rg);
    end;end;}
end;
procedure TViewer.Hide(P:PMain);
var i:integer;
    Rg:TPoint;
    Rr:TPoints;
begin
  SetBkColor(Colors[0]);
  SetColor(Colors[0]);
{  DrawCoord;}
  For i:= 1 to P^.CountProfil do DrawLocalCoord(P^.GetProfile(i));
  For i:= 1 to P^.CountCP*P^.CountProfil do begin
    P^.GetGlobalCP(i)^.GetCoord(Rr);
    PProfile(P^.GetGlobalCP(i)^.GetOwner)^.ConvLocAbs(Rr);
    ConvScrCoord(Rr,Rg);
    Fig1(Rg);
    end;
  For i:= 1 to P^.CountCP*P^.CountProfil do begin
    P^.GetGlobalCA(i)^.GetCoord(Rr);
    PProfile(P^.GetGlobalCA(i)^.GetOwner)^.ConvLocAbs(Rr);
    ConvScrCoord(Rr,Rg);
    Fig3(Rg);
    end;
  If P^.CountCF <> 0 Then begin
  For i:=1 to P^.CountCF do begin
    P^.GetGlobalCF(i)^.GetCoord(Rr);
    ConvScrCoord(Rr,Rg);
    Fig3(Rg);
    end;end;
{  SetColor(Colors[0]);
  If P^.BreakPoint^.Count <> 0 Then begin
  For i:= 1 to P^.NBreak do begin
    P^.GetBP(i)^.GetCoord(Rr);
    ConvScrCoord(Rr,Rg);
    Fig4(Rg);
    end;end;}
end;

procedure TViewer.Fig1(R:TPoint);
begin
  Rectangle(R.X-2,R.Y-2,R.X+2,R.Y+2);
end;
procedure TViewer.Fig2(R:TPoint);
begin
  Circle(R.X,R.Y,4);
end;
procedure TViewer.Fig3(R:TPoint);
var Col:byte;
begin
  Circle(R.X,R.Y,4);
  Col:=GetColor;
  If Col <> Colors[0] Then SetColor(14);
  Circle(R.X,R.Y,3);
  SetColor(Col)
end;
procedure TViewer.Fig4(R:TPoint);
begin
  Circle(R.X,R.Y,5);
  Line(R.X,R.Y-10,R.X,R.Y+10);
  Line(R.X-10,R.Y,R.X+10,R.Y);
end;

procedure TViewer.DrawCoord;
var x,y:integer;
begin
  SetTextJustify(1,1);
  x:=DelX;
  y:=GetMaxY-30;
  Line(x,30,x,y);
  y:=30;
  MoveTo(x,y);
  LineRel(3,12);
  LineRel(-6,0);
  LineRel(3,-12);
  OutTextXY(x+10,y,'Y');
  x:=GetMaxX-30;
  y:=DelY;
  Line(30,y,x,y);
  MoveTo(x,y);
  LineRel(-12,-3);
  LineRel(0,6);
  LineRel(12,-3);
  OutTextXY(x,y-10,'X');
end;
procedure TViewer.DrawLocalCoord(P:PProfile);
var
  x,y:integer;
  R:TPoints;
  L:TPoint;
begin
   R.X:=-0.5;
   R.Y:=0;
   P^.ConvLocAbs(R);
   ConvScrCoord(R,L);
   x:=L.X;y:=L.Y;
   R.X:=1.5;
   R.Y:=0;
   P^.ConvLocAbs(R);
   ConvScrCoord(R,L);
   Line(x,y,L.X,L.Y);
   R.X:=0;
   R.Y:=-0.5;
   P^.ConvLocAbs(R);
   ConvScrCoord(R,L);
   x:=L.X;y:=L.Y;
   R.X:=0;
   R.Y:=1.5;
   P^.ConvLocAbs(R);
   ConvScrCoord(R,L);
   Line(x,y,L.X,L.Y);
end;
begin
end.