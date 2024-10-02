unit Profile;
interface
uses Objects,ProfComm;
Const
     obNoOption = $0000;
     ocNew = $0001;
     ocOld = $0002;

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
    {**************************************}
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
    {**************************************}
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
    {**************************************}
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
    {**************************************}
    PBreakPoint = ^TBreakPoint;
    TBreakPoint = object(TBasePoint)
      constructor Init(ANumber:word;Plase:TPoints);
      constructor Load(var S:TStream);
      procedure Store(var S:TStream);
      end;
    {**************************************}
    PProfile = ^TProfile;
    TProfile = object(TBasePoint)
       b:real;{хорда}
       t,dt:real;{время, шаг по времени}
       N:word;{кол-во контрольных точек}
       NBreak:byte;{кол-во точек схода вихрей}
       NFree:word;{кол-во сохраняемых св. вихрей}

       ControlPoint:PCollection;
       CyclonAdd:PCollection;
       CyclonFree:PCollection;
       BreakPoint:PCollection;

       constructor Init(ANumber:word;PR:PProfileRec);
       constructor Load(var S:TStream);
       procedure Store(var S:Tstream);
       destructor Done;virtual;
       procedure InitProfilePoint(DataPtr:Pointer);virtual;
       procedure InitBreakPoint(DataPtr:Pointer);virtual;
       function GetCP(ANumber:word):PControlPoint;
       function GetCA(ANumber:word):PCyclonAdd;
       function GetCF(ANumber:word):PCyclon;
       function GetBP(ANumber:word):PBreakPoint;
       procedure InsCP(P:PControlPoint);
       procedure InsCA(P:PCyclonAdd);
       procedure InsCF(P:PCyclon);
       procedure InsBP(P:PBreakPoint);
       end;
const
   RBasePoint : TStreamRec = (
      ObjType : idBasePoint;
      VmtLink: Ofs(TypeOf(TBasePoint)^);
      Load:@TBasePoint.Load;
      Store:@TBasePoint.Store);
   RControlPoint : TStreamRec = (
      ObjType : idControlPoint;
      VmtLink: Ofs(TypeOf(TControlPoint)^);
      Load:@TControlPoint.Load;
      Store:@TControlPoint.Store);
   RCyclon : TStreamRec = (
      ObjType : idCyclon;
      VmtLink: Ofs(TypeOf(TCyclon)^);
      Load:@TCyclon.Load;
      Store:@TCyclon.Store);
   RCyclonAdd : TStreamRec = (
      ObjType : 1001;
      VmtLink: Ofs(TypeOf(TCyclonAdd)^);
      Load:@TCyclonAdd.Load;
      Store:@TCyclonAdd.Store);
   RBreakPoint : TStreamRec = (
      ObjType : idBreakPoint;
      VmtLink: Ofs(TypeOf(TBreakPoint)^);
      Load:@TBreakPoint.Load;
      Store:@TBreakPoint.Store);

   RProfile : TStreamRec = (
      ObjType : idProfile;
      VmtLink: Ofs(TypeOf(TProfile)^);
      Load:@TProfile.Load;
      Store:@TProfile.Store);
procedure RegisterProfile;
implementation
procedure RegisterProfile;
begin
  RegisterType(RBasePoint);
  RegisterType(RControlPoint);
  RegisterType(RCyclon);
  RegisterType(RCyclonAdd);
  RegisterType(RBreakPoint);
  RegisterType(RProfile);
  RegisterType(RCollection);
end;
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
{************************************************}
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
{************************************************}

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
{************************************************}
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
{************************************************}
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

{************************************************}
{************************************************}
{************************************************}
constructor TProfile.Init(ANumber:word;PR:PProfileRec);
begin
  Inherited Init(idProfile,ANumber);
  b:=PR^.b;
  t:=PR^.t;
  dt:=PR^.dt;
  N:=PR^.N;
  NBreak:=PR^.NBreak;
  NFree:=PR^.NFree;
  PutCoord(PR^.Plase);
  ControlPoint:=New(PCollection,Init(N,2));
  CyclonAdd:=New(PCollection,Init(N-1,2));
  CyclonFree:=New(PCollection,Init(NFree,2));
  BreakPoint:=New(PCollection,Init(NBreak,2));

  InitProfilePoint(PR);
  InitBreakPoint(PR);
end;
constructor TProfile.Load(var S:TStream);
begin
  inherited Load(S);
  S.Read(b,SizeOf(b));
  S.Read(t,SizeOf(t));
  S.Read(dt,SizeOf(dt));
  S.Read(N,SizeOf(N));
  S.Read(NBreak,SizeOf(NBreak));
  S.Read(NFree,SizeOf(NFree));
  ControlPoint:=PCollection(S.Get);
  CyclonAdd:=PCollection(S.Get);
  CyclonFree:=PCollection(S.Get);
  BreakPoint:=PCollection(S.Get);
end;
procedure TProfile.Store(var S:Tstream);
begin
  inherited Store(S);
  S.Write(b,SizeOf(b));
  S.Write(t,SizeOf(t));
  S.Write(dt,SizeOf(dt));
  S.Write(N,SizeOf(N));
  S.Write(NBreak,SizeOf(NBreak));
  S.Write(NFree,SizeOf(NFree));
  S.Put(ControlPoint);
  S.Put(CyclonAdd);
  S.Put(CyclonFree);
  S.Put(BreakPoint);
end;
destructor TProfile.Done;
begin
  Dispose(ControlPoint,Done);
  Dispose(CyclonAdd,Done);
  Dispose(CyclonFree,Done);
  Dispose(BreakPoint,Done);
end;
procedure TProfile.InitProfilePoint(DataPtr:Pointer);
var
  i:integer;
  Norm,Tang:TCorner;
  Plase:TPoints;
begin
  For i:=1 to N do begin
    Plase.X:=-0.5+(i-1)*(1/(N-1));
    Plase.Y:=0;
    Norm.CX:=pi/2;
    Norm.CY:=0;
    Tang.CX:=0;
    Tang.CY:=-1*pi/2;
    InsCP(New(PControlPoint,Init(i,Plase,Norm,Tang)));
    end;
  For i:=1 to N-1 do begin
    Plase.X:=-0.5+(1/(2*(N-1)))+(i-1)*(1/(N-1));
    Plase.Y:=0;
    Norm.CX:=pi/2;
    Norm.CY:=0;
    Tang.CX:=0;
    Tang.CY:=-1*pi/2;
    InsCA(New(PCyclonAdd,Init(i,Plase,Norm,Tang)));
    end;
end;
procedure TProfile.InitBreakPoint(DataPtr:Pointer);
var
   i:integer;
   Plase:TPoints;
begin
  Plase.X:=-0.5-(1/(2*(n-1)));
  Plase.Y:=0;
  InsBP(New(PBreakPoint,Init(1,Plase)));
  Plase.X:=0.5+(1/(2*(n-1)));
  InsBP(New(PBreakPoint,Init(2,Plase)));
end;
function TProfile.GetCP(ANumber:word):PControlPoint;
begin
  GetCP:=PControlPoint(ControlPoint^.At(ANumber-1));
end;
function TProfile.GetCA(ANumber:word):PCyclonAdd;
begin
  GetCA:=PCyclonAdd(CyclonAdd^.At(ANumber-1));
end;
function TProfile.GetCF(ANumber:word):PCyclon;
begin
  GetCF:=PCyclon(CyclonFree^.At(ANumber-1));
end;
function TProfile.GetBP(ANumber:word):PBreakPoint;
begin
  GetBP:=PBreakPoint(BreakPoint^.At(ANumber-1));
end;
procedure TProfile.InsCP(P:PControlPoint);
begin
  ControlPoint^.Insert(P);
end;
procedure TProfile.InsCA(P:PCyclonAdd);
begin
  CyclonAdd^.Insert(P);
end;
procedure TProfile.InsCF(P:PCyclon);
begin
  CyclonFree^.Insert(P);
end;
procedure TProfile.InsBP(P:PBreakPoint);
begin
  BreakPoint^.Insert(P);
end;
begin
end.
