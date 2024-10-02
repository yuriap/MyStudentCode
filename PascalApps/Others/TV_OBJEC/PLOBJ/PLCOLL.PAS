Program plcollection;
uses Objects,Crt;
type
    TDataPlate = record
      SumCount:byte;{колличество участов разбиения}
      Preserve:byte;{колличество сохраняемых свободных вихрей}
      Alfa:real;{угол установки пластины [рад]}
      end;

    TAPoint = record
       X,Y:real;
       end;
    PAbsPoint = ^TAbsPoint;
    TAbsPoint = object (TObject)   {базовый объект}
        Location : TAPoint;
        constructor Init(NewLocation:TAPoint);
        destructor Done;virtual;
        end;
constructor TAbsPoint.Init(NewLocation:TAPoint);
begin
 Location:=NewLocation;
end;
destructor TAbsPoint.Done;
begin
end;
type
    PConPoint = ^TConPoint;
    TConPoint = object(TAbsPoint)   {объект - контрольная точка}
       end;

    PRotAdd = ^TRotAdd;
    TRotAdd = object(TAbsPoint)   {объект - присоединенный вихрь}
        Cyclon : real;
        constructor Init(NewLocation:TAPoint);
        end;
constructor TRotAdd.Init(NewLocation:TAPoint);
begin
   inherited Init(NewLocation);
   Cyclon:=0.0;
end;
type
    PRotFree = ^TRotFree;
    TRotFree = object(TAbsPoint)  {объект - свободный вихрь}
        Cyclon : real;
        constructor Init(NewLocation:TAPoint);
        procedure MoveRot(NewLocation:TAPoint);
        end;
constructor TRotFree.Init(NewLocation:TAPoint);
begin
   inherited Init(NewLocation);
   Cyclon:=0.0;
end;
procedure TRotFree.MoveRot(NewLocation:TAPoint);
begin
  Location:=NewLocation;
end;
{*****************************************************************}
Type
    PCollCon = ^TCollCon;
    TCollCon = object(TCollection)
        SumCount,Number : byte;
        constructor Init(NewDataPlate:TDataPlate;NewNumber:byte);
        end;
constructor TCollCon.Init(NewDataPlate:TDataPlate;NewNumber:byte);
var
   i : byte;
   piece : real;
   Location : TAPoint;
begin

   Inherited Init(NewDataPlate.SumCount+1,0);
   Number:=NewNumber;
   SumCount:=NewDataPlate.SumCount;

   piece:=1.0/SumCount;
   for i:=0 to SumCount do begin
     Location.X:=i*piece*sin(NewDataPlate.Alfa);
     Location.Y:=i*piece*cos(NewDataPlate.Alfa);
     Insert(New(PConPoint,Init(Location)));
     end;
end;
{*************************************************************************}
type
    PCollRot = ^TCollRot;
    TCollRot = object(TCollection)
        SumCount,Number : byte;
        constructor Init(NewDataPlate:TDataPlate;NewNumber:byte);
        end;
constructor TCollRot.Init(NewDataPlate:TDataPlate;NewNumber:byte);
var
   i : byte;
   piece : real;
   Location : TAPoint;
begin

   Inherited Init(NewDataPlate.SumCount,0);
   Number:=NewNumber;
   SumCount:=NewDataPlate.SumCount;

   piece:=1.0/SumCount;
   for i:=1 to SumCount do begin
     Location.X:=(i*piece-piece/2)*sin(NewDataPlate.Alfa);
     Location.Y:=(i*piece-piece/2)*cos(NewDataPlate.Alfa);
     Insert(New(PRotAdd,Init(Location)));
     end;
end;
{*************************************************************************}
type
    PTearPoint = ^TTearPoint;
    TTearPoint = object(TCollection)
        SumCount,Number,Preserve : byte;
        constructor Init(NewDataPlate:TDataPlate;NewNumber:byte);
        end;
constructor TTearPoint.Init(NewDataPlate:TDataPlate;NewNumber:byte);
var
   piece : real;
   Location : TAPoint;
begin

  inherited Init(NewDataPlate.Preserve,0);
  SumCount:=NewDataPlate.SumCount;
  Number:=NewNumber;
  Preserve:=NewDataPlate.Preserve;

  piece:= 1.0/SumCount;
  Case Number of
   1:begin
     Location.X:=-1.0*(piece/2.0)*sin(NewDataPlate.Alfa);
     Location.Y:=-1.0*(piece/2.0)*cos(NewDataPlate.Alfa);
     end;
   2:begin
     Location.X:=(1.0+(piece/2.0))*sin(NewDataPlate.Alfa);
     Location.Y:=(1.0+(piece/2.0))*cos(NewDataPlate.Alfa);
     end;
   end;
   Insert(New(PRotFree,Init(Location)));
end;
{**************************************************************************}
var     ADataPlate:TDataPlate;
type

    PPlate = ^TPlate;
    TPlate = object(TCollection)
       SumCount,Preserve:byte;
       Alfa:real;
       constructor Init;
       end;
constructor TPlate.Init;
begin
    ADataPlate.SumCount:=4;
    ADataPlate.Preserve:=10;
    ADataPlate.Alfa:=0.0;
    SumCount:=4;
    Preserve:=10;
    Alfa:=0.0;

    inherited Init(4,0);
      Insert(New(PTearPoint,Init(ADataPlate,1)));
      Insert(New(PTearPoint,Init(ADataPlate,2)));
      Insert(New(PCollCon,Init(ADataPlate,3)));
      Insert(New(PCollRot,Init(ADataPlate,4)));
end;
procedure PrintLocAll(C:PCollection);
 procedure PrintLoc(A:PCollection);far;
  procedure PrintOs(S:PAbsPoint);far;
  begin
   with S^ do
   WriteLn('X = ',Location.X:8:3,' Y = ',Location.Y:8:3);
  end;
 begin
 WriteLn;
 A^.ForEach(@PrintOs);
 end;
begin
  Writeln;
  C^.ForEach(@PrintLoc);
end;

Var
  APlate : PPlate;
Begin
  APlate :=New(PPlate,Init);

  PrintLocAll(APlate);
  Readkey;
  Dispose(APlate,Done);
end.