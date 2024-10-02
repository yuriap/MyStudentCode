unit Profile;
interface
uses Objects,ProfComm,ProfDin;
Const
     obNoOption = $0000;
     ocNew = $0001;
     ocOld = $0002;

Type
    PProfileRec = ^TProfileRec;
    TProfileRec = record
      Plase:TPoints;
      CornerSys:real;
      Azimut:real;
      N:integer;
      NFree:integer;
      MapPtr:PMapProf;
      MainPtr:Pointer;
      end;

    PBasePoint = ^TBasePoint;
    TBasePoint = object(TObject)
      Iden:word;
      Number:word;
      Option:word;
      Coord:TPoints;
      Owner:Pointer;
      constructor Init(AIden,ANumber:word);
      constructor Load(var S:TStream);
      procedure Store(var S:TStream);
      procedure PutOption(AOption:word);
      function GetOption:word;
      procedure GetCoord(var Plase:TPoints);
      procedure PutCoord(var Plase:TPoints);
      procedure PutOwner(Ptr:Pointer);
      function GetOwner:Pointer;
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
    PControlPoint = ^TControlPoint;
    TControlPoint = object(TCyclon)
      Norm,Tang:TVecValue;{нормаль и касательная}
      S:real;{криволинейная координата}
      constructor Init(ANumber:word;Plase:TPoints);
      constructor Load(var SS:TStream);
      procedure Store(var SS:TStream);
      procedure GetNorm(var aNorm:TVecValue);
      procedure PutNorm(aNorm:TVecValue);
      procedure GetTang(var aTang:TVecValue);
      procedure PutTang(aTang:TVecValue);
      end;
    {**************************************}
    PCyclonAdd = ^TCyclonAdd;
    TCyclonAdd = object(TControlPoint)
      Pressure:real;
      constructor Init(ANumber:word;Plase:TPoints);
      constructor Load(var SS:TStream);
      procedure Store(var SS:TStream);
      procedure GetCoeff(Plase:TPoints;var Coeff:TSpeed);
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
       N:word;{кол-во контрольных точек}
       NFree:word;{кол-во сохраняемых св. вихрей}
       R:real;{радиус}
       CornerSystem:real;{угол между осью Х-абс. и осью Х-локальной}
       Azimut:real;{угол азимутальный}
       ControlPoint:PCollection;
       CyclonAdd:PCollection;
       CyclonFree:PCollection;
{       BreakPoint:PCollection;}
       Map:PMapProf;

       constructor Init(ANumber:word;PR:PProfileRec);
       constructor Load(var S:TStream);
       procedure Store(var S:Tstream);
       destructor Done;virtual;
       procedure InitProfilePoint(PRec:PProfileRec);virtual;
{       procedure InitBreakPoint(DataPtr:PProfileRec);virtual;}
       function GetCP(ANumber:word):PControlPoint;
       function GetCA(ANumber:word):PCyclonAdd;
       function GetCF(ANumber:word):PCyclon;
{       function GetBP(ANumber:word):PBreakPoint;}
       procedure InsCP(P:PControlPoint);
       procedure InsCA(P:PCyclonAdd);
       procedure InsCF(P:PCyclon);
{       procedure InsBP(P:PBreakPoint);            }
       procedure DigitNewPlase;
       procedure ConvLocAbs(var Plase:TPoints);
       procedure ConvAbsLoc(var Plase:TPoints);
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
procedure MakeSCoord(MapPtr:PMapProf);
procedure MakeCos(MapPtr:PMapProf);
procedure RegisterProfile;
implementation
uses ProfMain;
procedure RegisterProfile;
begin
  RegisterType(RBasePoint);
  RegisterType(RControlPoint);
  RegisterType(RCyclon);
  RegisterType(RCyclonAdd);
  RegisterType(RBreakPoint);
  RegisterType(RProfile);
  RegisterType(RCollection);
  RegisterType(RMapProf);
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
end;
procedure TBasePoint.Store(var S:TStream);
begin
  S.Write(Iden,SizeOf(Iden));
  S.Write(Number,SizeOf(Number));
  S.Write(Option,SizeOf(Option));
  S.Write(Coord,SizeOf(Coord));
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
procedure TBasePoint.PutOwner(Ptr:Pointer);
begin
  Owner:=Ptr;
end;
function TBasePoint.GetOwner:Pointer;
begin
  GetOwner:=Owner;
end;

{************************************************}
constructor TControlPoint.Init(ANumber:word;Plase:TPoints);
begin
  TBasePoint.Init(idControlPoint,ANumber);
  PutCoord(Plase);
end;
constructor TControlPoint.Load(var SS:TStream);
begin
  inherited Load(SS);
  SS.Read(Norm,SizeOf(Norm));
  SS.Read(Tang,SizeOf(Tang));
  SS.Read(S,SizeOf(S));
end;
procedure TControlPoint.Store(var SS:TStream);
begin
  inherited Store(SS);
  SS.Write(Norm,SizeOf(Norm));
  SS.Write(Tang,SizeOf(Tang));
  SS.Write(S,SizeOf(S));
end;
procedure TControlPoint.GetNorm(var aNorm:TVecValue);
begin
  aNorm:=Norm;
end;
procedure TControlPoint.GetTang(var aTang:TVecValue);
begin
  aTang:=Tang;
end;
procedure TControlPoint.PutNorm(aNorm:TVecValue);
begin
  Norm:=aNorm;
end;
procedure TControlPoint.PutTang(aTang:TVecValue);
begin
  Tang:=aTang;
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
    ASpeed.U:=-1*Cyclon*(Coord.Y-Plase.Y)/(2*Pi*R);
    ASpeed.V:=Cyclon*(Coord.X-Plase.X)/(2*Pi*R);
    end
  else
    begin
    ASpeed.U:=0;
    ASpeed.V:=0;
    end;
end;
{************************************************}
constructor TCyclonAdd.Init(ANumber:word;Plase:TPoints);
begin
  TBasePoint.Init(idCyclon,ANumber);
  PutCoord(Plase);
  Pressure:=0;
end;
constructor TCyclonAdd.Load(var SS:TStream);
begin
  inherited Load(SS);
  SS.Read(Pressure,SizeOf(Pressure));
end;
procedure TCyclonAdd.Store(var SS:TStream);
begin
  inherited Store(SS);
  SS.Write(Pressure,SizeOf(Pressure));
end;
procedure TCyclonAdd.GetCoeff(Plase:TPoints;var Coeff:TSpeed);
var Cycl:real;
begin
  Cycl:=GetCyclon;
  PutCyclon(1);
  GetInduction(Plase,Coeff);
  PutCyclon(Cycl);
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
  N:=PR^.N;
  NFree:=PR^.NFree;
  PutCoord(PR^.Plase);
  R:=PMainRec(PR^.MainPtr)^.R;
  CornerSystem:=PR^.CornerSys;
  Azimut:=PR^.Azimut;
  Map:=PR^.MapPtr;
  DigitNewPlase;
  CyclonFree:=New(PCollection,Init(NFree,0));
  ControlPoint:=New(PCollection,Init(N,0));
  CyclonAdd:=New(PCollection,Init(N,0));
  InitProfilePoint(PR);
{  InitBreakPoint(PR);}
end;
constructor TProfile.Load(var S:TStream);
var i:integer;
begin
  inherited Load(S);
  S.Read(N,SizeOf(N));
  S.Read(NFree,SizeOf(NFree));
  S.Read(CornerSystem,SizeOf(CornerSystem));
  S.Read(Azimut,SizeOf(Azimut));
  S.Read(R,SizeOf(R));
  ControlPoint:=PCollection(S.Get);
  CyclonAdd:=PCollection(S.Get);
  CyclonFree:=PCollection(S.Get);
{  Map:=PMapProf(S.Get);}
  For i:=1 To N do begin
    GetCP(i)^.PutOwner(@Self);
    GetCA(i)^.PutOwner(@Self);
    end;
end;
procedure TProfile.Store(var S:Tstream);
begin
  inherited Store(S);
  S.Write(N,SizeOf(N));
  S.Write(NFree,SizeOf(NFree));
  S.Write(CornerSystem,SizeOf(CornerSystem));
  S.Write(Azimut,SizeOf(Azimut));
  S.Write(R,SizeOf(R));
  S.Put(ControlPoint);
  S.Put(CyclonAdd);
  S.Put(CyclonFree);
{  S.Put(Map);}
end;
destructor TProfile.Done;
begin
  Dispose(ControlPoint,Done);
  Dispose(CyclonAdd,Done);
  Dispose(CyclonFree,Done);
{  Dispose(Map,Done);}
end;
procedure TProfile.InitProfilePoint(PRec:PProfileRec);
var
  i:integer;
  Plase:TPoints;
  S:real;
  f:text;
  Lit:string[2];
  NumCP,NumCA:integer;
  len:integer;
  x,y:real;
  CP:PControlPoint;
  CA:PCyclonAdd;
  aNorm,aTang:TVecValue;
begin
  Assign(f,PMainRec(PRec^.MainPtr)^.FileMapContur);
  {$I-}
  Reset(f);
  If IOResult <> 0 Then begin Beep; Halt(0);end;
  Readln(f,Len);
  If IOResult <> 0 Then begin Beep; Halt(0);end;
  Readln(f);
  NumCP:=1;
  NumCA:=1;
  for i:=1 to Len do begin
     Readln(f,Lit,Plase.X,Plase.Y,S);
     If IOResult <> 0 Then begin Beep; Halt(0);end;
     If Lit = 'cp' then begin
        CP:=New(PControlPoint,Init(NumCP,Plase));
        CP^.S:=S;
        CP^.PutOwner(@Self);
        InsCP(CP);
        Inc(NumCP);
        end;
     If Lit = 'ca' then begin
        CA:=New(PCyclonAdd,Init(NumCA,Plase));
        CA^.S:=S;
        CA^.PutOwner(@Self);
        InsCA(CA);
        Inc(NumCA);
        end;
     end;
  {$I+}
  for i:=1 To N do begin
   CP:=GetCP(i);
   aNorm.ProX:=Map^.Get_NX_S(CP^.S);
   aNorm.ProY:=Map^.Get_NY_S(CP^.S);
   CP^.PutNorm(aNorm);
   aTang.ProX:=Map^.Get_TX_S(CP^.S);
   aTang.ProY:=Map^.Get_TY_S(CP^.S);
   CP^.PutTang(aTang);
   CA:=GetCA(i);
   aNorm.ProX:=Map^.Get_NX_S(CA^.S);
   aNorm.ProY:=Map^.Get_NY_S(CA^.S);
   CA^.PutNorm(aNorm);
   aTang.ProX:=Map^.Get_TX_S(CA^.S);
   aTang.ProY:=Map^.Get_TY_S(CA^.S);
   CA^.PutTang(aTang);
   end;
end;
{procedure TProfile.InitBreakPoint(DataPtr:Pointer);
var
   i:integer;
   Plase:TPoints;
begin
  Plase.X:=-0.5-(1/(2*(n-1)));
  Plase.Y:=0;
  InsBP(New(PBreakPoint,Init(1,Plase)));
  Plase.X:=0.5+(1/(2*(n-1)));
  InsBP(New(PBreakPoint,Init(2,Plase)));
end;}
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
{function TProfile.GetBP(ANumber:word):PBreakPoint;
begin
  GetBP:=PBreakPoint(BreakPoint^.At(ANumber-1));
end;}
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
{procedure TProfile.InsBP(P:PBreakPoint);
begin
  BreakPoint^.Insert(P);
end;}
procedure TProfile.ConvLocAbs(var Plase:TPoints);
var Temp:TPoints;
    Fi:real;
begin
  Temp:=Plase;
  Fi:=CornerSystem+(Azimut-pi/2);
  Plase.X:=Cos(Fi)*Temp.X-Sin(Fi)*Temp.Y+Coord.X;
  Plase.Y:=Sin(Fi)*Temp.X+Cos(Fi)*Temp.Y+Coord.Y;
end;
procedure TProfile.ConvAbsLoc(var Plase:TPoints);
var x,y,Fi:real;
    Temp:TPoints;
begin
  Fi:=CornerSystem+(Azimut-pi/2);
  {x,y - коорд. начала абс. системы в локальной}
  y:=Coord.X*Sin(Fi)-Cos(Fi)*Coord.Y;
  x:=-1*(Coord.X*Cos(Fi)+Coord.Y*Sin(Fi));
  Temp:=Plase;
  Plase.X:=Cos(Fi)*Temp.X+Sin(Fi)*Temp.Y+x;
  Plase.Y:=-1*Sin(Fi)*Temp.X+Cos(Fi)*Temp.Y+y;
end;
procedure TProfile.DigitNewPlase;
begin
   Coord.X:=R*Cos(Azimut);
   Coord.Y:=R*Sin(Azimut);
end;
procedure MakeSCoord(MapPtr:PMapProf);
var S:real;
    i:integer;
    Len:integer;
begin
 S:=0;
 Len:=MapPtr^.M;
 For i:=1 to Len-1 do begin
   MapPtr^.PutS(i,S);
   S:=S+Sqrt(Sqr(MapPtr^.GetX(i+1)-MapPtr^.GetX(i))
       +Sqr(MapPtr^.GetY(i+1)-MapPtr^.GetY(i)));
   end;
   MapPtr^.PutS(Len,S);
end;
procedure MakeCos(MapPtr:PMapProf);
var
    i:integer;
    Len:integer;
    RAbs:real;
    x,y:real;
begin
 With MapPtr^ do begin
 Len:=M;
 For i:=1 to Len-1 do begin
   RAbs:=Sqrt(Sqr(GetX(i+1)-GetX(i))+Sqr(GetY(i+1)-GetY(i)));
   PutTX(i,(GetX(i+1)-GetX(i))/RAbs);
   PutTY(i,(GetY(i+1)-GetY(i))/RAbs);
   PutNX(i,-1*GetTY(i));
   PutNY(i,GetTX(i));
   end;{for}
   PutTX(Len,GetTX(1));
   PutTY(Len,GetTY(1));
   PutNX(Len,GetNX(1));
   PutNY(Len,GetNY(1));
   end;{with}
end;{MakeCos}

begin
end.
