Unit plcoll3;
Interface
uses Objects,Crt,Graph,Collect;
type
    TDataOfPlate = record
      count : String[10];
      preserve : String[10];
      alfa : String[10];
      dtime : String[10];
      end;
    TDataGraph = record
      MasX,MasY,DeltaX,DeltaY:string[10];
      end;
type
    PDataPlate = ^TDataPlate;
    TDataPlate = record
      SumCount:byte;{колличество участов разбиения}
      Preserve:byte;{колличество сохраняемых свободных вихрей}
      Alfa:real;{угол установки пластины [рад]}
      DTime :real{шаг по времени}
      end;

    PAPoint = ^TAPoint;
    TAPoint = record
       X,Y:real;
       end;
    DrawAttr = word;
    ScreenType = record
       MasX,MasY,DeltaX,DeltaY:integer;
       end;
const
     coConPoint : DrawAttr = $000F;
     coRotAdd : DrawAttr = $0003;
     coRotFreeA : DrawAttr = $0001;
     coRotFreeB : DrawAttr = $0002;


var ADataPlate:PDataPlate;
    Screen : ScreenType ;
    DataPlate : TDataOfPlate;
    DataGraph : TDataGraph;

{*****************************************************************}

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
       destructor Done;virtual;
       end;
var
        grDriver: Integer;
        grMode: Integer;
        ErrCode: Integer;
procedure GraphInit;
implementation


procedure GraphInit;
begin
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin  { Do graphics }
   Writeln('Graphics error:', GraphErrorMsg(ErrCode));
   Halt(0);
 end;
end;
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
    Dispose(ADataPlate);
    GraphInit;
    SetBkColor(0);
end;
procedure TPlate.DrawXY;
begin
   SetColor(14);
   Line(Screen.DeltaX,50,Screen.DeltaX, GetMaxY-50);
   Line(50,Screen.DeltaY,GetMaxX-50,Screen.DeltaY);
   SetColor(13);
   OuttextXY(Screen.DeltaX+10, GetMaxY-55,'X');
   OutTextXY(GetMaxX-60,Screen.DeltaY-15,'Y');
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
     { CloseGraph;}
      inherited done;
end;
begin
end.
