Program plcollection;
uses Objects,Crt,Graph,UGauss;
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

     Screen : ScreenType =(MasX : 100;
                           MasY : 100;
                           DeltaX : 200;
                           DeltaY : 250);

type
    PAbsPoint = ^TAbsPoint;
    TAbsPoint = object (TObject)   {базовый объект}
        Location : TAPoint;{координаты}
        ScreenLoc :TPoint;{координаты на экране}
        Cyclon:real;
        Speed : TAPoint;{скорость в точке с коорд. Location}
        StreamMove : boolean;{двигается ли вместе с потоком}
        DTime : real;{промежуток времени tau}
        Color : integer;
        constructor Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
        procedure Move;
        procedure Show;virtual;
        procedure Hide;virtual;
        procedure Draw;
        procedure StreamDraw;
        destructor Done;virtual;
        end;
constructor TAbsPoint.Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
begin
 Location:= NewLocation^;
 ScreenLoc.X:=Trunc(Location.X*Screen.MasX)+Screen.DeltaX;
 ScreenLoc.Y:=-1*Trunc(Location.Y*Screen.MasY)+Screen.DeltaY;
 Speed.X := 0.0;
 Speed.Y := 0.0;
 StreamMove := StrMove;
 DTime := NewDTime;
 Color := 0;
 Cyclon:=0.0;
end;
procedure TAbsPoint.Move;
begin
  Location.X := Location.X + Speed.X * DTime;
  Location.Y := Location.Y + Speed.Y * DTime;
  ScreenLoc.X:=Trunc(Location.X*Screen.MasX)+Screen.DeltaX;
  ScreenLoc.Y:=Trunc(Location.Y*Screen.MasY)+Screen.DeltaY;
end;
procedure TAbsPoint.Show;
begin
  SetColor(Lo(Color));
end;
procedure TAbsPoint.Hide;
begin
  SetColor(Hi(Color));
end;
procedure TAbsPoint.Draw;
begin
   Show;
end;
procedure TAbsPoint.StreamDraw;
begin
  Hide;
  if StreamMove Then Move;
  Show;
end;
destructor TAbsPoint.Done;
begin
  Hide;
  inherited Done;
end;
type
    PConPoint = ^TConPoint;
    TConPoint = object(TAbsPoint)   {объект - контрольная точка}
       constructor Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
       procedure Show;virtual;
       procedure Hide;virtual;
       end;
constructor TConPoint.Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
begin
   Inherited Init(NewLocation,NewDTime,StrMove);
   Color:=coConPoint;
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
type
    PRotAdd = ^TRotAdd;
    TRotAdd = object(TAbsPoint)   {объект - присоединенный вихрь}
        constructor Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
        procedure Show;virtual;
        procedure Hide;virtual;
        end;
constructor TRotAdd.Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean);
begin
   inherited Init(NewLocation,NewDTime,StrMove);
   Cyclon:=0.0;
   Color:=coRotAdd;
end;
Procedure TRotAdd.Show;
const p :real = 0.05;
begin
   inherited Show;
   Circle(ScreenLoc.X,ScreenLoc.Y,Trunc(p*sqrt(Screen.MasX*Screen.MasY)));
end;
Procedure TRotAdd.Hide;
const p :real = 0.05;
begin
   inherited Hide;
   Circle(ScreenLoc.X,ScreenLoc.Y,Trunc(p*sqrt(Screen.MasX*Screen.MasY)));
end;

type
    PRotFree = ^TRotFree;
    TRotFree = object(TAbsPoint)  {объект - свободный вихрь}
        constructor Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean;
                         NewColor:word);
        procedure Show;virtual;
        procedure Hide;virtual;
        end;
constructor TRotFree.Init(NewLocation:PAPoint;NewDTime:real;StrMove:boolean;
                          NewColor:word);
begin
   inherited Init(NewLocation,NewDTime,StrMove);
   Color:=NewColor;
end;
procedure TRotFree.Show;
const p : real = 0.1;
begin
   inherited Show;
   Circle(ScreenLoc.X,ScreenLoc.Y,Trunc(p*sqrt(Screen.MasX*Screen.MasY)));
end;
procedure TRotFree.Hide;
const p : real = 0.1;
begin
   inherited Hide;
   Circle(ScreenLoc.X,ScreenLoc.Y,Trunc(p*sqrt(Screen.MasX*Screen.MasY)));
end;

{*****************************************************************}
Type
    PPointColl = ^TPointColl;
    TPointColl = object(TCollection)
        Number:byte;
        end;

    PCollCon = ^TCollCon;
    TCollCon = object(TPointColl)
        constructor Init(NewDataPlate:PDataPlate;NewNumber:Byte);
        procedure Draw;
        procedure StreamDraw;
        end;
constructor TCollCon.Init(NewDataPlate:PDataPlate;NewNumber:Byte);
var
   i : byte;
   piece : real;
   Location : PAPoint;
begin
   New(Location);
   Inherited Init(NewDataPlate^.SumCount+1,0);
   piece:=1.0/NewDataPlate^.SumCount;
   Number:=NewNumber;
   for i:=0 to NewDataPlate^.SumCount do begin
     Location^.X:=i*piece*cos(NewDataPlate^.Alfa);
     Location^.Y:=i*piece*sin(NewDataPlate^.Alfa);
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
procedure TCollCon.StreamDraw;
  procedure DrawTwo(S:PConPoint);far;
  begin
     S^.StreamDraw;
  end;
begin
  ForEach(@DrawTwo);
end;

{*************************************************************************}
type
    PCollRot = ^TCollRot;
    TCollRot = object(TPointColl)
        constructor Init(NewDataPlate:PDataPlate;NewNumber:Byte);
        procedure Draw;
        procedure StreamDraw;
        end;
constructor TCollRot.Init(NewDataPlate:PDataPlate;NewNumber:Byte);
var
   i : byte;
   piece : real;
   Location : PAPoint;
begin
   New(Location);
   Inherited Init(NewDataPlate^.SumCount,0);
   piece:=1.0/NewDataPlate^.SumCount;
   Number:=NewNumber;
   for i:=1 to NewDataPlate^.SumCount do begin
     Location^.X:=(i*piece-piece/2)*cos(NewDataPlate^.Alfa);
     Location^.Y:=(i*piece-piece/2)*sin(NewDataPlate^.Alfa);
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
procedure TCollRot.StreamDraw;
  procedure DrawTwo(S:PRotAdd);far;
  begin
     S^.StreamDraw;
  end;
begin
  ForEach(@DrawTwo);
end;

{*************************************************************************}
type
    PTearPoint = ^TTearPoint;
    TTearPoint = object(TPointColl)
        constructor Init(NewDataPlate:PDataPlate;NewNumber:byte);
        procedure RotIns(NewDataPlate:PDataPlate);
        procedure Draw;
        procedure StreamDraw;
        end;
constructor TTearPoint.Init(NewDataPlate:PDataPlate;NewNumber:byte);
var
   piece : real;
   Location : PAPoint;
   coColor : word;
begin
  New(Location);
  inherited Init(NewDataPlate^.Preserve,0);
  Number:=NewNumber;
  piece:= 1.0/NewDataPlate^.SumCount;
  Case Number of
   1:begin
     Location^.X:=-1.0*(piece/2.0)*cos(NewDataPlate^.Alfa);
     Location^.Y:=-1.0*(piece/2.0)*sin(NewDataPlate^.Alfa);
     coColor:=coRotFreeA;
     end;
   2:begin
     Location^.X:=(1.0+(piece/2.0))*cos(NewDataPlate^.Alfa);
     Location^.Y:=(1.0+(piece/2.0))*sin(NewDataPlate^.Alfa);
     coColor:=coRotFreeB;
     end;
   end;
   Insert(New(PRotFree,Init(Location,NewDataPlate^.DTime,true,coColor)));
   Dispose(Location);
end;
procedure TTearPoint.RotIns(NewDataPlate:PDataPlate);
var
   piece : real;
   Location : PAPoint;
   Color : word;

begin
  New(Location);
  piece:= 1.0/NewDataPlate^.SumCount;
  Case Number of
   1:begin
     Location^.X:=-1.0*(piece/2.0)*cos(NewDataPlate^.Alfa);
     Location^.Y:=-1.0*(piece/2.0)*sin(NewDataPlate^.Alfa);
     Color:=coRotFreeA;
     end;
   2:begin
     Location^.X:=(1.0+(piece/2.0))*cos(NewDataPlate^.Alfa);
     Location^.Y:=(1.0+(piece/2.0))*sin(NewDataPlate^.Alfa);
     Color:=coRotFreeB;
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
procedure TTearPoint.StreamDraw;
  procedure DrawTwo(S:PRotFree);far;
  begin
     S^.StreamDraw;
  end;
begin
  ForEach(@DrawTwo);
end;

{**************************************************************************}



var     ADataPlate:PDataPlate;
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
{*******************************************************************}
var
   LeftPart : LeftPartType;
   RightPart,IncogPart : RightIncPartType;
Type
   PUnit = ^TUnit;
   TUnit = object(TObject)
      Location:TAPoint;
      Rotor:real;
      constructor Init;
      destructor Done;virtual;
      end;
constructor TUnit.Init;
begin
 inherited Init;
 Location.X:=0.0;
 Location.Y:=0.0;
 Rotor:=0.0;
end;
destructor TUnit.Done;
begin
  inherited Done;
end;
type
   PPotencial = ^TPotencial;
   TPotencial = object(TCollection)
       SumCount,Preserve:byte;
       Number:byte;
       constructor init(NewDataPlate:PDataPlate;NewNumber:byte);
       procedure GetSpeed(Ptr:PPointColl);
       procedure PutSpeed(Ptr:PPointColl);
       destructor Done;virtual;
       end;
constructor TPotencial.Init;
Var
  Size:word;
  i:byte;
begin
   Size:=NewDataPlate^.SumCount+2*NewDataPlate^.Preserve;
   inherited Init(size,0);
   Number:=NewNumber;
   SumCount:=NewDataPlate^.SumCount;
   Preserve:=NewDataPlate^.Preserve;
   For i:=0 to size-1 do
    Insert(New(PUnit,Init));
end;
procedure TPotencial.GetSpeed(Ptr:PPointColl);
var
   first,last,i:byte;
   locat:TAPoint;
   rot:real;
begin
  case Ptr^.Number of
   4:begin first:=0;last:=Ptr^.Count-1;end;
   1:begin first:=SumCount; last:=Ptr^.Count+First-1;end;
   2:begin first:=SumCount+Preserve; last:=Ptr^.Count+First-1;end;
   end;
  For i := first to last do begin
    Locat:=PAbsPoint(Ptr^.At(i-first))^.Location;
    PUnit(At(i))^.Location:=LOcat;
    rot:=PAbsPoint(Ptr^.At(i-first))^.Cyclon;
    PUnit(At(i))^.Rotor:=rot;
    end;
end;
procedure TPotencial.PutSpeed(Ptr:PPointColl);
var
   Location,Speed:TAPoint;
   i,j:byte;
 procedure TakeSpeed(S:PUnit);far;
  var dist:real;
  begin
    dist:=sqr(S^.Location.X-Location.X)+sqr(S^.Location.Y-Location.Y);
    if dist-0.0001 >= 0.0 then begin
     Speed.X:=Speed.X-S^.Rotor*(Location.Y-S^.Location.Y)/(2*pi*dist);
     Speed.Y:=Speed.Y+S^.Rotor*(Location.X-S^.Location.X)/(2*pi*dist);
     end;
  end;
begin
 If (Ptr^.Number = 1) or (Ptr^.Number = 2) then begin
   For i :=0 to Ptr^.Count-1 do begin
   Location:=PAbsPoint(Ptr^.At(i))^.Location;
   Speed.X:=0.0;Speed.Y:=0.0;
   ForEach(@TakeSpeed);
   PAbsPoint(Ptr^.At(i))^.Speed:=Speed;
   end;
   end;
 If (Ptr^.Number = 3) or (Ptr^.Number = 4) then begin
   For i :=0 to Ptr^.Count-1 do begin
   Location:=PAbsPoint(Ptr^.At(i))^.Location;
   Speed.X:=0.0;Speed.Y:=0.0;
   For j:=SumCount to Count-1 do  begin
   TakeSpeed(At(j));
   PAbsPoint(Ptr^.At(i))^.Speed:=Speed;
   end;
   end;
   end;
end;
destructor TPotencial.Done;
begin
  inherited Done;
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
       Potencial:PPotencial;
       Dim : byte;{размерность массива}

       constructor Init;
       procedure Draw;
       procedure StreamDraw;
       procedure GetLeft;
       procedure GetRight;
       procedure GetIncog;
       destructor Done;virtual;
       end;
constructor TPlate.Init;
begin
    New(ADataPlate);
    ADataPlate^.SumCount:=4;
    ADataPlate^.Preserve:=100;
    ADataPlate^.Alfa:=-1*pi/4;
    ADataPlate^.DTime:=0.2;
    SumCount:=4;
    Preserve:=10;
    Alfa:=pi/2.0;
    DTime:= 0.5;Time:=0.0;
    Dim:=SumCount+2;
    RightPart[Dim]:=0.0;
      TearPointA:=New(PTearPoint,Init(ADataPlate,1));
      TearPointB:=New(PTearPoint,Init(ADataPlate,2));
      ControlPoint:=New(PCollCon,Init(ADataPlate,3));
      RotorAdd:=New(PCollRot,Init(ADataPlate,4));
      Potencial:=New(PPotencial,Init(ADataPlate,5));
    GraphInit;
    SetBkColor(Hi(coConPoint));
end;
procedure TPlate.GetRight;
var i:byte;
begin
  for i:=0 to ControlPoint^.Count-1 do
    RightPart[i+1]:=PAbsPoint(ControlPoint^.At(i))^.Speed.X*sin(Alfa)-
                    PAbsPoint(ControlPoint^.At(i))^.Speed.Y*cos(Alfa)-cos(Alfa);
end;
procedure TPlate.GetIncog;
var
  Err,i:integer;
begin
 Gauss(LeftPart,RightPart,IncogPart,Dim,Err);
 RightPart[Dim]:=RightPart[Dim]-IncogPart[1]-IncogPart[Dim];
   PAbsPoint(TearPointA^.At(TearPointA^.Count-1))^.Cyclon:=IncogPart[1];

   PAbsPoint(TearPointB^.At(TearPointB^.Count-1))^.Cyclon:=IncogPart[Dim];
   for i := 0 to ControlPoint^.Count-1 do
    PAbsPoint(ControlPoint^.At(i))^.Cyclon:=IncogPart[i+2];
end;

procedure TPlate.Draw;
begin
      TearPointA^.Draw;
      TearPointB^.Draw;
      ControlPoint^.Draw;
      RotorAdd^.Draw;
end;
procedure TPlate.StreamDraw;
begin
      TearPointA^.StreamDraw;
      TearPointB^.StreamDraw;
end;

destructor TPlate.Done;
begin
      Dispose(TearPointA,Done);
      Dispose(TearPointB,Done);
      Dispose(ControlPoint,Done);
      Dispose(RotorAdd,Done);
      Dispose(Potencial,Done);
      Dispose(ADataPlate);
      CloseGraph;
      inherited done;
end;
procedure TPlate.GetLeft;

var c1,c2:real;
    i1,i2:byte;
begin
  c1:=1.0;
  For i1:=1 to Dim-1 do begin
    c2:=c1;
    For i2:=1 To Dim do begin
      LeftPart[i1,i2]:=(Dim-2)/(c2*pi);
      c2:=c2-2;
      LeftPart[Dim,i2]:=1.0;
      end;
    c1:=c1+2.0;
    end;
end;

Var
  APlate : PPlate;
Begin
  APlate :=New(PPlate,Init);

  APlate^.Draw;
  APlate^.GetLeft;
  repeat
  APlate^.GetRight;
  APlate^.GetIncog;
  APlate^.Draw;
  APlate^.Potencial^.GetSpeed(APlate^.TearPointA);
  APlate^.Potencial^.GetSpeed(APlate^.TearPointB);
  APlate^.Potencial^.GetSpeed(APlate^.RotorAdd);
  APlate^.Potencial^.PutSpeed(APlate^.TearPointA);
  APlate^.Potencial^.PutSpeed(APlate^.TearPointB);
  APlate^.TearPointA^.RotIns(ADataPlate);
  APlate^.TearPointB^.RotIns(ADataPlate);

  APlate^.StreamDraw;
  APlate^.Potencial^.PutSpeed(APlate^.ControlPoint);
  Until KeyPressed;
  Dispose(APlate,Done);
end.