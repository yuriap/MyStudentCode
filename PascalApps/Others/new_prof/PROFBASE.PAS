Unit ProfBase;
interface
uses Objects,ProfComm;
Const
     obNoOption = $0000;
Type
    PBasePoint = ^TBasePoint;
    TBasePoint = object(TObject)
      Iden:word;
      Number:word;
      Option:word;
      Coord:TPoints;
      Speed:TSpeed;
      constructor Init(AIden,ANumber:word);
      constructor Load(var S:TStream);
      procedure Store(var S:TStream);
      procedure PutOption(AOption:word);
      function GetOption:word;
      procedure GetCoord(var Plase:TPoints);
      procedure PutCoord(var Plase:TPoints);
      procedure GetSpeed(var ASpeed:TSpeed);
      procedure PutSpeed(var ASpeed:TSpeed);
      end;
implementation
constructor TBasePoint.Init(AIden,ANumber:word);
begin
  Iden:=AIden;
  Number:=ANumber;
  PutOption(obNoOption);
end;
constructor TBasePoint.Load(var S:TStream);
begin
  S.Read(Iden,SizeOf(Iden));
  S.Read(Number,SizeOf(Number));
  S.Read(Option,SizeOf(Option));
  S.Read(Coord,SizeOf(Coord));
  S.Read(Speed,SizeOf(Speed));
end;
procedure TBasePoint.Store(var S:TStream);
begin
  S.Write(Iden,SizeOf(Iden));
  S.Write(Number,SizeOf(Number));
  S.Write(Option,SizeOf(Option));
  S.Write(Coord,SizeOf(Coord));
  S.Write(Speed,SizeOf(Speed));
end;
procedure TBasePoint.PutOption(AOption:word);
begin
 Option:=AOption;
end;
function TBasePoint.GetOption:word;
begin
  GetOption:=Option;
end;
procedure TBasePoint.GetCoord(var Plase:TPoints);
begin
  Plase:=Coord;
end;
procedure TBasePoint.PutCoord(var Plase:TPoints);
begin
  Coord:=Plase;
end;
procedure TBasePoint.GetSpeed(var ASpeed:TSpeed);
begin
  ASpeed:=Speed;
end;
procedure TBasePoint.PutSpeed(var ASpeed:TSpeed);
begin
  Speed:=ASpeed;
end;
begin
end.
