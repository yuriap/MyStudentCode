Unit ProfCycl;
interface
uses Objects,ProfComm,ProfBase;
const
   ocNew = $0001;
   ocOld = $0002;
Type
    PCyclon = ^TCyclon;
    TCyclon = object(TBasePoint)
      Cyclon:real;
      constructor Init(ANumber:word;Plase:TPoints);
      constructor Load(var S:TStream);
      procedure Store(var S:TStream);
      procedure PutCyclon(ACyclon:real);
      function GetCyclon:real;
      procedure GetInduction(Plase:TPoints;var ASpeed:TSpeed);
      end;
implementation
constructor TCyclon.Init(ANumber:word;Plase:TPoints);
begin
  inherited Init(idCyclon,ANumber);
  PutOption(ocNew);
  PutCoord(Plase);
  PutCyclon(1);
end;
constructor TCyclon.Load(var S:TStream);
begin
  inherited Load(S);
  S.Read(Cyclon,SizeOf(Cyclon));
end;
procedure TCyclon.Store(var S:TStream);
begin
  inherited Store(S);
  S.Write(Cyclon,SizeOf(Cyclon));
end;
procedure TCyclon.PutCyclon(ACyclon:real);
begin
 Cyclon:=ACyclon;
end;
function TCyclon.GetCyclon:real;
begin
  GetCyclon:=Cyclon;
end;
procedure TCyclon.GetInduction(Plase:TPoints;var ASpeed:TSpeed);
var R:real;
begin
  R:=Sqrt(Sqr(Plase.X-Coord.X)+Sqr(Plase.Y-Coord.Y));
  If R > 1e-5 then
    begin
    {?????????????????????}
    ASpeed.U:=Cyclon*(Plase.Y-Coord.Y)/R;
    ASpeed.V:=Cyclon*(Plase.X-Coord.X)/R;
    end
  else
    begin
    ASpeed.U:=0;
    ASpeed.V:=0;
    end;
end;
begin
end.
