Unit Plates;
Interface
uses Objects,PlCommon,Collect,Graph;
type

    PPlate = ^TPlate;
    TPlate = object(TObject)
       SumCount:byte;
       Preserve:byte;
       Alfa:real;
       DTime,Time:real;
       ControlPoint:PCollCon;
       RotorAdd:PCollRot;
       TearPointA,TearPointB:PTearPoint;
       constructor Init;
       procedure Draw;
       procedure DrawXY;
       constructor Load(var S :TStream);
       procedure Store(var S :TStream);
       destructor Done;virtual;
       end;
Const
  RPlate : TStreamRec =(
    ObjType:1004;
    VmtLink: Ofs(TypeOf(TPlate)^);
    Load:@TPlate.Load;
    Store:@TPlate.Store);

implementation


{*************************************************}
constructor TPlate.Init;
Var i: integer;
    g: real;
begin
    New(ADataPlate);
    Val(DataPlate.Count,ADataPlate^.SumCount,i);
    Val(DataPlate.Preserve,ADataPlate^.Preserve,i);
    Val(DataPlate.Alfa,g,i);
    ADataPlate^.Alfa:=g*pi/180.0;
    Val(DataPlate.DTime,ADataPlate^.DTime,i);

    SumCount:=ADataPlate^.SumCount;
    Preserve:=ADataPlate^.Preserve;
    Alfa:=ADataPlate^.Alfa;
    DTime:=ADataPlate^.DTime;Time:=0.0;


      TearPointA:=New(PTearPoint,Init(ADataPlate,1));
      TearPointB:=New(PTearPoint,Init(ADataPlate,2));
      ControlPoint:=New(PCollCon,Init(ADataPlate));
      RotorAdd:=New(PCollRot,Init(ADataPlate));
    Dispose(ADataPlate);
end;
procedure TPlate.DrawXY;
var s:real;
begin
   SetColor(14);
   With Screen do begin
   Line(DeltaX,50,DeltaX, GetMaxY-50);
   Line(50,DeltaY,GetMaxX-50,DeltaY);
   SetColor(13);
   OuttextXY(DeltaX-10, 55,'Y');
   OutTextXY(GetMaxX-60,DeltaY-15,'X');
   end;
end;
procedure TPlate.Draw;
var i:integer;
begin
    Val(DataGraph.MasX,Screen.MasX,i);
    Val(DataGraph.MasY,Screen.MasY,i);
    Val(DataGraph.DeltaX,Screen.DeltaX,i);
    Val(DataGraph.DeltaY,Screen.DeltaY,i);

      DrawXY;
      TearPointA^.Draw;
      TearPointB^.Draw;
      ControlPoint^.Draw;
      RotorAdd^.Draw;

end;
destructor TPlate.Done;
begin
      Dispose(TearPointA,Done);
      Dispose(TearPointB,Done);
      Dispose(ControlPoint,Done);
      Dispose(RotorAdd,Done);
     { CloseGraph;}
      inherited done;
end;
constructor TPlate.Load(var S :TStream);
begin
  S.Read(SumCount,SizeOf(SumCount));
  S.Read(Preserve,SizeOf(Preserve));
  S.Read(Alfa,SizeOf(Alfa));
  S.Read(DTime,SizeOf(DTime));
  S.Read(Time,SizeOf(Time));
  ControlPoint:=PCollCon(S.Get);
  RotorAdd:=PCollRot(S.Get);
  TearPointA:=PTearPoint(S.Get);
  TearPointB:=PTearpoint(S.Get);
end;
procedure TPlate.Store(var S :TStream);
begin
  S.Write(SumCount,SizeOf(SumCount));
  S.Write(Preserve,SizeOf(Preserve));
  S.Write(Alfa,SizeOf(Alfa));
  S.Write(DTime,SizeOf(DTime));
  S.Write(Time,SizeOf(Time));
  S.Put(ControlPoint);
  S.Put(RotorAdd);
  S.Put(TearPointA);
  S.Put(TearPointB);
end;

begin
end.
