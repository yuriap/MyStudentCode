Unit Plates;
Interface
uses Objects,PlCommon,Collect,BstGauss,Graph;
const
    spNew = 1;
    spSaveDisk = 2;
    spReadDisk = 3;
type

    PPlate = ^TPlate;
    TPlate = object(TObject)
       SumCount:byte;
       Preserve:byte;
       Alfa:real;
       DTime,Time:real;
       Status:word;
       LeftPart:PLeftPart;
       RightPart,IncPart:PRightIncPart;
       ControlPoint:PCollCon;
       RotorAdd:PCollRot;
       TearPointA,TearPointB:PTearPoint;
       constructor Init;
       procedure Draw;
       procedure DrawXY;
       constructor Load(var S :TStream);
       procedure Store(var S :TStream);
       procedure CreatLeft( LeftPtr:PLeftPart);
       procedure GetRight( RightPtr:PRightIncPart);
       procedure GetIncog( IncogPtr:PRightIncPart);
       destructor Done;virtual;
       end;
Const
  RPlate : TStreamRec =(
    ObjType:100;
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

    Val(DataGraph.MasX,Screen.MasX,i);
    Val(DataGraph.MasY,Screen.MasY,i);
    Val(DataGraph.DeltaX,Screen.DeltaX,i);
    Val(DataGraph.DeltaY,Screen.DeltaY,i);

      TearPointA:=New(PTearPoint,Init(ADataPlate,1));
      TearPointB:=New(PTearPoint,Init(ADataPlate,2));
      ControlPoint:=New(PCollCon,Init(ADataPlate));
      RotorAdd:=New(PCollRot,Init(ADataPlate));
      New(LeftPart);
      New(RightPart);
      New(IncPart);
    Dispose(ADataPlate);
    Status:=spNew;
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
begin
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
      Dispose(LeftPart);
      Dispose(RightPart);
      Dispose(IncPart);
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

  New(LeftPart);
  New(RightPart);
  New(IncPart);

  S.Read(LeftPart^,SizeOf(LeftPart^));
  S.Read(RightPart^,SizeOf(RightPart^));
  S.Read(IncPart^,SizeOf(IncPart^));
  ControlPoint:=PCollCon(S.Get);
  RotorAdd:=PCollRot(S.Get);
  TearPointA:=PTearPoint(S.Get);
  TearPointB:=PTearpoint(S.Get);
  Status:=spReadDisk;
end;
procedure TPlate.Store(var S :TStream);
begin
  S.Write(SumCount,SizeOf(SumCount));
  S.Write(Preserve,SizeOf(Preserve));
  S.Write(Alfa,SizeOf(Alfa));
  S.Write(DTime,SizeOf(DTime));
  S.Write(Time,SizeOf(Time));
  S.Write(LeftPart^,SizeOf(LeftPart^));
  S.Write(RightPart^,SizeOf(RightPart^));
  S.Write(RightPart^,SizeOf(RightPart^));
  S.Put(ControlPoint);
  S.Put(RotorAdd);
  S.Put(TearPointA);
  S.Put(TearPointB);
  Status:=spSaveDisk;
end;
procedure TPlate.CreatLeft( LeftPtr:PLeftPart);
Var
     in1,in2                    :integer;
     ch,ch1                     :real;
Begin
     ch:=1.0;
     For in1:=1 to SumCount+1 do
        begin
        ch1:=ch;
        for in2:=1 to SumCount+2 do
           begin
           LeftPtr^[in1,in2]:=(SumCount)/(ch1*pi);
           ch1:=ch1-2;
           LeftPtr^[SumCount+2,in2]:=1.0;
           end;
        ch:=ch+2.0;
        end;
End;
procedure TPlate.GetRight( RightPtr: PRightIncPart);
begin

begin
end.
