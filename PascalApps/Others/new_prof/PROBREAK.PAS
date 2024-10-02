Unit ProBreak;
interface
uses Objects,ProfComm,ProfBase;
Type
    PBreakPoint = ^TBreakPoint;
    TBreakPoint = object(TBasePoint)
      constructor Init(ANumber:word;Plase:TPoints);
      constructor Load(var S:TStream);
      procedure Store(var S:TStream);
      end;
implementation
constructor TBreakPoint.Init(ANumber:word;Plase:TPoints);
begin
  inherited Init(idBreakPoint,ANumber);
  PutCoord(Plase);
end;
constructor TBreakPoint.Load(var S:TStream);
begin
  inherited Load(S);
end;
procedure TBreakPoint.Store(var S:TStream);
begin
  inherited Store(S);
end;
begin
end.
