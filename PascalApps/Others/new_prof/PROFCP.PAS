Unit ProfCP;
interface
uses Objects,ProfComm,ProfBase;
Type
    PControlPoint = ^TControlPoint;
    TControlPoint = object(TBasePoint)
      CNorm,
      CTang:TCorner;
      constructor Init(ANumber:word;Plase:TPoints;Norm,Tang:TCorner);
      constructor Load(var S:TStream);
      procedure Store(var S:TStream);
      procedure GetCorner(var Norm,Tang:TCorner);
      procedure PutCorner(Norm,Tang:TCorner);
      end;
implementation
constructor TControlPoint.Init(ANumber:word;Plase:TPoints;Norm,Tang:TCorner);
begin
  inherited Init(idControlPoint,ANumber);
  PutCorner(Norm,Tang);
  PutCoord(Plase);
end;
constructor TControlPoint.Load(var S:TStream);
begin
  inherited Load(S);
  S.Read(CNorm,SizeOf(CNorm));
  S.Read(CTang,SizeOf(CTang));
end;
procedure TControlPoint.Store(var S:TStream);
begin
  inherited Store(S);
  S.Write(CNorm,SizeOf(CNorm));
  S.Write(CTang,SizeOf(CTang));
end;
procedure TControlPoint.GetCorner(var Norm,Tang:TCorner);
begin
  Norm:=CNorm;
  Tang:=CTang;
end;
procedure TControlPoint.PutCorner(Norm,Tang:TCorner);
begin
  CNorm:=Norm;
  CTang:=Tang;
end;
begin
end.
