unit Collect;
interface
uses Objects,Point,PlCommon;

Type
    PCollCon = ^TCollCon;
    TCollCon = object(TCollection)
        constructor Init(NewDataPlate:PDataPlate);
        procedure Draw;
        end;

    PCollRot = ^TCollRot;
    TCollRot = object(TCollection)
        constructor Init(NewDataPlate:PDataPlate);
        procedure Draw;
        end;

    PTearPoint = ^TTearPoint;
    TTearPoint = object(TCollection)
        Number : byte;
        constructor Init(NewDataPlate:PDataPlate;NewNumber:byte);
        procedure Draw;
        constructor Load( var S : TStream);
        procedure Store( var S : TStream);
        end;
Const
   RCollCon : TStreamRec = (
      ObjType : 1001;
      VmtLink: Ofs(TypeOf(TCollCon)^);
      Load:@TCollCon.Load;
      Store:@TCollCon.Store);
   RCollRot : TStreamRec = (
      ObjType : 1002;
      VmtLink: Ofs(TypeOf(TCollRot)^);
      Load:@TCollRot.Load;
      Store:@TCollRot.Store);
   RTearPoint : TStreamRec = (
      ObjType : 1003;
      VmtLink: Ofs(TypeOf(TTearPoint)^);
      Load:@TTearPoint.Load;
      Store:@TTearPoint.Store);

implementation
constructor TCollCon.Init(NewDataPlate:PDataPlate);
var
   i : byte;
   piece : real;
   Location : TAPoint;
begin
   Inherited Init(NewDataPlate^.SumCount+1,0);
   piece:=1.0/NewDataPlate^.SumCount;
   for i:=0 to NewDataPlate^.SumCount do begin
     Location.X:=i*piece*cos(NewDataPlate^.Alfa);
     Location.Y:=i*piece*sin(NewDataPlate^.Alfa);
     Insert(New(PConPoint,Init(Location,NewDataPlate^.DTime,false)));
     end;
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
   Location : TAPoint;
begin
   Inherited Init(NewDataPlate^.SumCount,0);
   piece:=1.0/NewDataPlate^.SumCount;
   for i:=1 to NewDataPlate^.SumCount do begin
     Location.X:=(i*piece-piece/2)*cos(NewDataPlate^.Alfa);
     Location.Y:=(i*piece-piece/2)*sin(NewDataPlate^.Alfa);
     Insert(New(PRotAdd,Init(Location,NewDataPlate^.DTime,false)));
     end;
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
   Location:TAPoint;
   color:word;
begin
  inherited Init(NewDataPlate^.Preserve,0);
  Number:=NewNumber;
  piece:= 1.0/NewDataPlate^.SumCount;
  Case Number of
   1:begin
     Location.X:=-1.0*(piece/2.0)*cos(NewDataPlate^.Alfa);
     Location.Y:=-1.0*(piece/2.0)*sin(NewDataPlate^.Alfa);
     Color:=coRotFreeA;
     end;
   2:begin
     Location.X:=(1.0+(piece/2.0))*cos(NewDataPlate^.Alfa);
     Location.Y:=(1.0+(piece/2.0))*sin(NewDataPlate^.Alfa);
     Color:=coRotFreeB;
     end;
   end;
   Insert(New(PRotFree,Init(Location,NewDataPlate^.DTime,true,color)));
end;
procedure TTearPoint.Draw;
  procedure DrawOne(S:PRotFree);far;
  begin
     S^.Draw;
  end;
begin
  ForEach(@DrawOne);
end;
constructor TTearPoint.Load( var S : TStream);
begin
  inherited Load(S);
  S.Read(Number,SizeOf(byte));
end;
procedure TTearPoint.Store( var S : TStream);
begin
  inherited Store(S);
  S.Write(Number,SizeOf(byte));
end;

begin
end.
