Unit ProfCAdd;
interface
uses Objects,ProfComm,ProfCycl;
Type
    PCyclonAdd = ^TCyclonAdd;
    TCyclonAdd = object(TCyclon)
      CNorm,
      CTang:TCorner;
      Pressure:real;
      constructor Init(ANumber:word;Plase:TPoints;Norm,Tang:TCorner);
      constructor Load(var S:TStream);
      procedure Store(var S:TStream);
      procedure GetCorner(var Norm,Tang:TCorner);
      procedure PutCorner(Norm,Tang:TCorner);
      end;
implementation
constructor TCyclonAdd.Init(ANumber:word;Plase:TPoints;Norm,Tang:TCorner);
begin
  inherited Init(ANumber,Plase);
  Iden:=idCyclon;
  PutCorner(Norm,Tang);
  Pressure:=0;
end;
constructor TCyclonAdd.Load(var S:TStream);
begin
  inherited Load(S);
  S.Read(CNorm,SizeOf(CNorm));
  S.Read(CTang,SizeOf(CTang));
  S.Read(Pressure,SizeOf(Pressure));
end;
procedure TCyclonAdd.Store(var S:TStream);
begin
  inherited Store(S);
  S.Write(CNorm,SizeOf(CNorm));
  S.Write(CTang,SizeOf(CTang));
  S.Write(Pressure,SizeOf(Pressure));
end;
procedure TCyclonAdd.GetCorner(var Norm,Tang:TCorner);
begin
  Norm:=CNorm;
  Tang:=CTang;
end;
procedure TCyclonAdd.PutCorner(Norm,Tang:TCorner);
begin
  CNorm:=Norm;
  CTang:=Tang;
end;
begin
end.
