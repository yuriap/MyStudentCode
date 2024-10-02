Unit plcoll2;
Interface
uses Objects,Crt,Graph;
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
var DataPlate : TDataOfPlate;
    DataGraph : TDataGraph;
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
type
    PAbsPoint = ^TAbsPoint;
    TAbsPoint = object (TObject)   {базовый объект}
        Location : PAPoint;{координаты}
        ScreenLoc :TPoint;{координаты на экране}
        Speed : PAPoint;{скорость в точке с коорд. Location}
        StreamMove : boolean;{двигается ли вместе с потоком}
        DTime : real;{промежуток времени tau}
        Color : ^integer;
        constructor Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
        procedure Move;
        procedure Show;virtual;
        procedure Hide;virtual;
        procedure Draw;
        destructor Done;virtual;
        end;
type
    PConPoint = ^TConPoint;
    TConPoint = object(TAbsPoint)   {объект - контрольная точка}
       constructor Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
       procedure Show;virtual;
       procedure Hide;virtual;
       end;
type
    PRotAdd = ^TRotAdd;
    TRotAdd = object(TAbsPoint)   {объект - присоединенный вихрь}
        Cyclon : real;
        constructor Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
        procedure Show;virtual;
        procedure Hide;virtual;
        end;
type
    PRotFree = ^TRotFree;
    TRotFree = object(TAbsPoint)  {объект - свободный вихрь}
        Cyclon : real;
        constructor Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean;
                     Col:Pointer);
        procedure Show;virtual;
        procedure Hide;virtual;
        end;
{*****************************************************************}
Type
    PCollCon = ^TCollCon;
    TCollCon = object(TCollection)
        constructor Init(NewDataPlate:PDataPlate);
        procedure Draw;
        end;
type
    PCollRot = ^TCollRot;
    TCollRot = object(TCollection)
        constructor Init(NewDataPlate:PDataPlate);
        procedure Draw;
        end;
type
    PTearPoint = ^TTearPoint;
    TTearPoint = object(TCollection)
        Number : byte;
        constructor Init(NewDataPlate:PDataPlate;NewNumber:byte);
        procedure Draw;
        end;

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
implementation
constructor TAbsPoint.Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
begin
 New(Location);
 New(Speed);
 Location^:= NewLocation^;
 ScreenLoc.X:=Trunc(Location^.Y*Screen.MasX)+Screen.DeltaX;
 ScreenLoc.Y:=Trunc(Location^.X*Screen.MasY)+Screen.DeltaY;
 Speed^.X := 0.0;
 Speed^.Y := 0.0;
 StreamMove := StrMove;
 DTime := NewDTime;
 Color := nil;
end;
procedure TAbsPoint.Move;
begin
  Location^.X := Location^.X + Speed^.X * DTime;
  Location^.Y := Location^.Y + Speed^.Y * DTime;
  ScreenLoc.X:=Trunc(Location^.Y*Screen.MasX)+Screen.DeltaX;
  ScreenLoc.Y:=Trunc(Location^.X*Screen.MasY)+Screen.DeltaY;
end;
procedure TAbsPoint.Show;
begin
  SetColor(Lo(Color^));
end;
procedure TAbsPoint.Hide;
begin
  SetColor(Hi(Color^));
end;
procedure TAbsPoint.Draw;
begin
   Hide;
   If StreamMove Then Move;
   Show;
end;
destructor TAbsPoint.Done;
begin
  Hide;
  Dispose(Location);
  Dispose(Speed);
  inherited Done;
end;
{************************************************}
constructor TConPoint.Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
begin
   Inherited Init(NewLocation,NewDTime,StrMove);
   Color:=@coConPoint;
end;
procedure TConPoint.Show;
const P : real = 0.05;
begin
   Inherited Show;
   Bar(ScreenLoc.X+Trunc(P*Screen.MasX),ScreenLoc.Y+Trunc(P*Screen.MasY)
     ,ScreenLoc.X-Trunc(P*Screen.MasX),ScreenLoc.Y-Trunc(P*Screen.MasY));
end;
procedure TConPoint.Hide;
const P : real = 0.05;
begin
   Inherited Hide;
   Bar(ScreenLoc.X+Trunc(P*Screen.MasX),ScreenLoc.Y+Trunc(P*Screen.MasY)
     ,ScreenLoc.X-Trunc(P*Screen.MasX),ScreenLoc.Y-Trunc(P*Screen.MasY));
end;
{********************************************************}
constructor TRotAdd.Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
begin
   inherited Init(NewLocation,NewDTime,StrMove);
   Cyclon:=0.0;
   Color:=@coRotAdd;
end;
Procedure TRotAdd.Show;
const p :real = 0.05;
begin
   inherited Show;
   Circle(ScreenLoc.X,ScreenLoc.Y,Trunc(p*(Screen.MasX+Screen.MasY)/2));
end;
Procedure TRotAdd.Hide;
const p :real = 0.05;
begin
   inherited Hide;
   Circle(ScreenLoc.X,ScreenLoc.Y,Trunc(p*(Screen.MasX+Screen.MasY)/2));
end;

{*******************************************************}
constructor TRotFree.Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean;
                     Col:Pointer);
begin
   inherited Init(NewLocation,NewDTime,StrMove);
   Cyclon:=0.0;
   Color:=Col
end;
procedure TRotFree.Show;
const p : real = 0.1;
begin
   inherited Show;
   Circle(ScreenLoc.X,ScreenLoc.Y,Trunc(p*(Screen.MasX+Screen.MasY)/2));
end;
procedure TRotFree.Hide;
const p : real = 0.1;
var s :real;
begin
   inherited Hide;
   Circle(ScreenLoc.X,ScreenLoc.Y,Trunc(p*(Screen.MasX+Screen.MasY)/2));
end;

{************************************************}
constructor TCollCon.Init(NewDataPlate:PDataPlate);
var
   i : byte;
   piece : real;
   Location : PAPoint;
begin
   New(Location);
   Inherited Init(NewDataPlate^.SumCount+1,0);
   piece:=1.0/NewDataPlate^.SumCount;
   for i:=0 to NewDataPlate^.SumCount do begin
     Location^.X:=i*piece*sin(NewDataPlate^.Alfa);
     Location^.Y:=i*piece*cos(NewDataPlate^.Alfa);
     Insert(New(PConPoint,Init(Location,NewDataPlate^.DTime,false)));
     end;
   Dispose(location);
end;
procedure TCollCon.Draw;
  procedure DrawOne(S:PConPoint);far;
  begin
     S^.Draw;
  end;
begin
  ForEach(@DrawOne);
end;
{*************************************************************************}
constructor TCollRot.Init(NewDataPlate:PDataPlate);
var
   i : byte;
   piece : real;
   Location : PAPoint;
begin
   New(Location);
   Inherited Init(NewDataPlate^.SumCount,0);
   piece:=1.0/NewDataPlate^.SumCount;
   for i:=1 to NewDataPlate^.SumCount do begin
     Location^.X:=(i*piece-piece/2)*sin(NewDataPlate^.Alfa);
     Location^.Y:=(i*piece-piece/2)*cos(NewDataPlate^.Alfa);
     Insert(New(PRotAdd,Init(Location,NewDataPlate^.DTime,false)));
     end;
  Dispose(Location);
end;
procedure TCollRot.Draw;
  procedure DrawOne(S:PRotAdd);far;
  begin
     S^.Draw;
  end;
begin
  ForEach(@DrawOne);
end;

{*************************************************************************}
constructor TTearPoint.Init(NewDataPlate:PDataPlate;NewNumber:byte);
var
   piece : real;
   Location : PAPoint;
   Color : Pointer;
begin
  New(Location);
  inherited Init(NewDataPlate^.Preserve,0);
  Number:=NewNumber;
  piece:= 1.0/NewDataPlate^.SumCount;
  Case Number of
   1:begin
     Location^.X:=-1.0*(piece/2.0)*sin(NewDataPlate^.Alfa);
     Location^.Y:=-1.0*(piece/2.0)*cos(NewDataPlate^.Alfa);
     Color:=@coRotFreeA;
     end;
   2:begin
     Location^.X:=(1.0+(piece/2.0))*sin(NewDataPlate^.Alfa);
     Location^.Y:=(1.0+(piece/2.0))*cos(NewDataPlate^.Alfa);
     Color:=@coRotFreeB;
     end;
   end;
   Insert(New(PRotFree,Init(Location,NewDataPlate^.DTime,true,color)));
   Dispose(Location);
end;
procedure TTearPoint.Draw;
  procedure DrawOne(S:PRotFree);far;
  begin
     S^.Draw;
  end;
begin
  ForEach(@DrawOne);
end;

{**************************************************************************}



var     
        grDriver: Integer;
        grMode: Integer;
        ErrCode: Integer;

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
      CloseGraph;
      inherited done;
end;
begin
end.
