unit Profile;
interface
uses Objects,ProfComm,ProfDin,MsgBox,Crt;
Const
     obNoOption = $0000;
     ocNew = $0001;
     ocOld = $0002;

Type
    PProfileRec = ^TProfileRec;
    TProfileRec = record
      CountCP:integer;
      CornerSys:real;
      R:real;
      Azimut:real;
      NFree:integer;
      Norm:integer;
      Tang:integer;
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
      S:real;{криволинейная координата}
      Moving:TPoints;
      constructor Init(ANumber:word;Plase:TPoints);
      constructor Load(var SS:TStream);
      procedure Store(var SS:TStream);
      procedure PutCyclon(ACyclon:real);
      function GetCyclon:real;
      procedure GetInduction(Plase:TPoints;var ASpeed:TSpeed);
      procedure PutMovingPlase(P:TPoints);
      procedure Move;
      end;
    {**************************************}
    PControlPoint = ^TControlPoint;
    TControlPoint = object(TCyclon)
      Norm,Tang:TVecValue;{нормаль и касательная}
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
      dS:real;{длина участка контура профиля}
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
       NFree:word;{кол-во св. вихрей в коллекции данного профиля}
       FreePreserve:integer;
       R:real;{радиус}
       CornerSystem:real;{угол между осью Х-абс. и осью Х-локальной}
       Azimut:real;{угол азимутальный}
       Re:real;{число Рейнольдса}
       Cx,Cy:real;{коэфф. аэродинамических сил}
       Tang,Norm:TVecValue;
       ControlPoint:PCollection;
       CyclonAdd:PCollection;
       CyclonFree:PCollection;
{       BreakPoint:PCollection;}
       Map:PMapProf;
       Main:PMainSetka;
       Comp:PCompSetka;
       constructor Init(ANumber:word;PR:PProfileRec);
       constructor Load(var S:TStream);
       procedure Store(var S:Tstream);
       destructor Done;virtual;
       procedure InitProfilePoint(PRec:PProfileRec);virtual;
       procedure PointOnMap;virtual;
       procedure AutoBreak;virtual;
       procedure InitSetka(PR:PProfileRec);virtual;
       procedure PutdSForCyclonAdd;virtual;
       function GetCP(ANumber:word):PControlPoint;
       function GetCA(ANumber:word):PCyclonAdd;
       function GetCF(ANumber:word):PCyclon;
       procedure InsCP(P:PControlPoint);
       procedure InsCA(P:PCyclonAdd);
       procedure InsCF(P:PCyclon);
       procedure DelCF(aNumber:word);
       procedure GetSpeed(var Speed:TSpeed);
       function GetReynolds:real;
       procedure PutNormtang;
       function GetW:PFunction;
       procedure DigitNewPlase;
       procedure ConvLocAbs(var Plase:TPoints);
       procedure ConvAbsLoc(var Plase:TPoints);
       procedure ConvVecLocAbs(var Vec:TVecValue);
       procedure GetForce;
       procedure GetForceForNorm(var Force:TVecValue);
       procedure GetForceForTang(var Force:TvecValue);
       procedure UnitedFreeCyclon;
       procedure Dissipation;virtual;
       procedure DissipationFirstTime;virtual;
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
      ObjType : idCyclonAdd;
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
uses ProfMain,ProBound;
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
end;
procedure TControlPoint.Store(var SS:TStream);
begin
  inherited Store(SS);
  SS.Write(Norm,SizeOf(Norm));
  SS.Write(Tang,SizeOf(Tang));
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
constructor TCyclon.Load(var SS:TStream);
begin
  inherited Load(SS);
  SS.Read(Cyclon,SizeOf(Cyclon));
  SS.Read(S,SizeOf(S));
end;
procedure TCyclon.Store(var SS:TStream);
begin
  inherited Store(SS);
  SS.Write(Cyclon,SizeOf(Cyclon));
  SS.Write(S,SizeOf(S));
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
  R:=Sqr(Plase.X-Coord.X)+Sqr(Plase.Y-Coord.Y);
  If R > 1e-7 then
    begin
    ASpeed.ProX:=-1*Cyclon*(Plase.Y-Coord.Y)/(2*Pi*R);
    ASpeed.ProY:=Cyclon*(Plase.X-Coord.X)/(2*Pi*R);
    end
  else
    begin
    ASpeed.ProX:=0;
    ASpeed.ProY:=0;
    end;
end;
procedure TCyclon.PutMovingPlase(P:TPoints);
begin
  Moving:=P;
end;
procedure TCyclon.Move;
begin
  Coord:=Moving;
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
  SS.Read(dS,SizeOf(dS));
end;
procedure TCyclonAdd.Store(var SS:TStream);
begin
  inherited Store(SS);
  SS.Write(Pressure,SizeOf(Pressure));
  SS.Write(dS,SizeOf(dS));
end;
procedure TCyclonAdd.GetCoeff(Plase:TPoints;var Coeff:TSpeed);
var Cycl:real;C:TPoints;
begin
  Cycl:=GetCyclon;
  GetCoord(C);
  PProfile(Owner)^.ConvLocAbs(Coord);
  PutCyclon(1);
  GetInduction(Plase,Coeff);
  PutCyclon(Cycl);
  PutCoord(C);
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
  NFree:=0;
  FreePreserve:=PR^.NFree;
  R:=PMainRec(PR^.MainPtr)^.R;
  Option:=PMainRec(PR^.MainPtr)^.Option;
  CornerSystem:=PR^.CornerSys;
  Azimut:=PR^.Azimut;
  Map:=PR^.MapPtr;
  if (Option and moAutoBreak) = moAutoBreak then N:=PR^.CountCP
    else N:=Map^.GetCountPoint;
  InitSetka(PR);
  DigitNewPlase;
  CyclonFree:=New(PCollection,Init(PR^.NFree,6));
  ControlPoint:=New(PCollection,Init(N,0));
  CyclonAdd:=New(PCollection,Init(N,0));
  InitProfilePoint(PR);
end;
constructor TProfile.Load(var S:TStream);
var i:integer;
begin
  inherited Load(S);
  S.Read(N,SizeOf(N));
  S.Read(NFree,SizeOf(NFree));
  S.Read(R,SizeOf(R));
  S.Read(CornerSystem,SizeOf(CornerSystem));
  S.Read(Azimut,SizeOf(Azimut));
  S.Read(Re,SizeOf(Re));
  S.Read(Cx,SizeOf(Cx));
  S.Read(Cy,SizeOf(Cy));
  S.Read(FreePreserve,SizeOf(FreePreserve));
  S.Read(Norm,SizeOf(Norm));
  S.Read(Tang,SizeOf(Tang));
  ControlPoint:=PCollection(S.Get);
  CyclonAdd:=PCollection(S.Get);
  CyclonFree:=PCollection(S.Get);
  Main:=PMainSetka(S.Get);
  Comp:=PCompSetka(S.Get);
  For i:=1 To N do begin
    GetCP(i)^.PutOwner(@Self);
    GetCA(i)^.PutOwner(@Self);
    end;
  for i:=1 to NFree do  GetCF(i)^.PutOwner(@Self);
end;
procedure TProfile.Store(var S:Tstream);
begin
  inherited Store(S);
  S.Write(N,SizeOf(N));
  S.Write(NFree,SizeOf(NFree));
  S.Write(R,SizeOf(R));
  S.Write(CornerSystem,SizeOf(CornerSystem));
  S.Write(Azimut,SizeOf(Azimut));
  S.Write(Re,SizeOf(Re));
  S.Write(Cx,SizeOf(Cx));
  S.Write(Cy,SizeOf(Cy));
  S.Write(FreePreserve,SizeOf(FreePreserve));
  S.Write(Norm,SizeOf(Norm));
  S.Write(Tang,SizeOf(Tang));
  S.Put(ControlPoint);
  S.Put(CyclonAdd);
  S.Put(CyclonFree);
  S.Put(Main);
  S.Put(Comp);
end;
destructor TProfile.Done;
begin
  inherited done;
  Dispose(ControlPoint,Done);
  Dispose(CyclonAdd,Done);
  Dispose(CyclonFree,Done);
  Dispose(Main,Done);
  Dispose(Comp,Done);
end;
procedure TProfile.InitSetka(PR:PProfileRec);
var dS:real;
    i:integer;
begin
  Main:=New(PMainSetka,Init(PR^.Norm,PR^.Tang));
  If Main = nil then SoundTrac;
  Comp:=New(PCompSetka,Init(PR^.Norm,PR^.Tang));
  If Comp = nil then SoundTrac;
  dS:=Map^.GetMaxS/(PR^.Tang+1);
  for i:=0 to PR^.Tang do Main^.Put_S(i,dS*i);
end;
procedure TProfile.InitProfilePoint(PRec:PProfileRec);
begin
  if (Option and moAutoBreak) = moAutoBreak then
    AutoBreak
    else
    PointOnMap;
    PutdSForCyclonAdd;
end;
procedure TProfile.AutoBreak;
var
  i,j:integer;
  Plase:TPoints;
  NumCP,NumCA:integer;
  CP:PControlPoint;
  CA:PCyclonAdd;
  aNorm,aTang:TVecValue;
  Opt:word;
  S1,S2,dS1,dS2,SCP,SCA:real;
  Bound:integer;
  Back,Meddle:boolean;
  CountCP:integer;
 procedure MakeConturPoint(S_CP,S_CA:real);
 begin
  Plase.X:=Map^.Get_X_S(S_CP);
  Plase.Y:=Map^.Get_Y_S(S_CP);
  CP:=New(PControlPoint,Init(NumCP,Plase));
  CP^.S:=S_CP;
  aNorm.ProX:=Map^.Get_NX_S(S_CP);
  aNorm.ProY:=Map^.Get_NY_S(S_CP);
  CP^.PutNorm(aNorm);
  aTang.ProX:=Map^.Get_TX_S(S_CP);
  aTang.ProY:=Map^.Get_TY_S(S_CP);
  CP^.PutTang(aTang);
  CP^.PutOwner(@Self);
  InsCP(CP);
  Inc(NumCP);
  {********}
  Plase.X:=Map^.Get_X_S(S_CA);
  Plase.Y:=Map^.Get_Y_S(S_CA);
  CA:=New(PCyclonAdd,Init(NumCP,Plase));
  CA^.S:=S_CA;
  aNorm.ProX:=Map^.Get_NX_S(S_CA);
  aNorm.ProY:=Map^.Get_NY_S(S_CA);
  CA^.PutNorm(aNorm);
  aTang.ProX:=Map^.Get_TX_S(S_CA);
  aTang.ProY:=Map^.Get_TY_S(S_CA);
  CA^.PutTang(aTang);
  CA^.PutOwner(@Self);
  InsCA(CA);
  Inc(NumCA);
 end;{MakeConturPoint}

begin
  Back:=false;
  CountCP:=N;
  Meddle:=not(Odd(CountCP));
  For i:=Map^.BeginH To Map^.EndH do begin
   Map^.GetOptions(i,Opt);
   if (Opt and moBackBound) = moBackBound then begin
      Back:=True;
      Break;
      end;
      end;
  {*************************************************}
  If back then begin
    S1:=Map^.GetS(i);
    S2:=Map^.GetMaxS-S1;
    {******************}
    if not(Meddle) then begin
      Bound:=(CountCP div 2)+1;
      dS1:=S1/Bound;
      dS2:=S2/(Bound-1);
      end else begin
      Bound:=CountCP div 2;
      dS1:=S1/Bound;
      dS2:=dS1;
      end;
    {******************}
    NumCP:=1;
    NumCA:=1;
    SCP:=0.0;
    SCA:=SCP+0.5*dS1;
    for j:=1 to CountCP do begin
       MakeConturPoint(SCP,SCA);
       if not(j <= Bound) then begin
        SCP:=SCP+dS2;
        SCA:=SCP+0.5*dS2;end
        else begin
        SCP:=SCP+dS1;
        SCA:=SCP+0.5*dS1;end;
       if j = Bound then begin
        SCA:=SCP+0.5*dS2;
        end;end;
    end
    else begin
    S1:=Map^.GetMaxS;
    dS1:=S1/CountCP;
    {******************}
    NumCP:=1;
    NumCA:=1;
    for j:=1 to CountCP do begin
       SCP:=dS1*(j-1);
       SCA:=SCP+0.5*dS1;
       MakeConturPoint(SCP,SCA);
       end;
    end
end;{TProfile.AutoBreak}
procedure TProfile.PointOnMap;
var
  i:integer;
  Plase:TPoints;
  NumCP,NumCA:integer;
  CP:PControlPoint;
  CA:PCyclonAdd;
  aNorm,aTang:TVecValue;
  Opt:word;
begin
  NumCP:=1;
  NumCA:=1;
  for i:=Map^.BeginH to Map^.EndH do begin
     Map^.GetOptions(i,Opt);
     If (Opt and moCPoint) = moCPoint then begin
        Plase.X:=Map^.GetX(i);
        Plase.Y:=Map^.GetY(i);
        CP:=New(PControlPoint,Init(NumCP,Plase));
        CP^.S:=Map^.GetS(i);
        aNorm.ProX:=Map^.GetNX(i);
        aNorm.ProY:=Map^.GetNY(i);
        CP^.PutNorm(aNorm);
        aTang.ProX:=Map^.GetTX(i);
        aTang.ProY:=Map^.GetTY(i);
        CP^.PutTang(aTang);
        if IsItSetFlag(Opt,moBackBound) then CP^.PutOption(moBackBound);
        CP^.PutOwner(@Self);
        InsCP(CP);
        Inc(NumCP);
        end;
     If (Opt and moCAdd) = moCAdd then begin
        Plase.X:=Map^.GetX(i);
        Plase.Y:=Map^.GetY(i);
        CA:=New(PCyclonAdd,Init(NumCA,Plase));
        CA^.S:=Map^.GetS(i);
        aNorm.ProX:=Map^.GetNX(i);
        aNorm.ProY:=Map^.GetNY(i);
        CA^.PutNorm(aNorm);
        aTang.ProX:=Map^.GetTX(i);
        aTang.ProY:=Map^.GetTY(i);
        CA^.PutTang(aTang);
        CA^.PutOwner(@Self);
        InsCA(CA);
        Inc(NumCA);
        end;
     end;
end;

procedure TProfile.PutdSForCyclonAdd;
{Вычисляет длину участка контура профиля, на котором расположен
присоединенный вихрь}
var i:integer;
    CA:PCyclonAdd;
begin
  for i:=1 to N-1 do begin
    CA:=GetCA(i);
    CA^.dS:=GetCP(i+1)^.S-GetCP(i)^.S;
    end;
  GetCA(N)^.dS:=Map^.GetMaxS-GetCP(N)^.S;
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
  Inc(NFree);
  Inc(PMain(Owner)^.CountCF);
end;
{procedure TProfile.InsBP(P:PBreakPoint);
begin
  BreakPoint^.Insert(P);
end;}
function TProfile.GetW:PFunction;
var BB:PFunction;
    i:integer;
    CA:PCyclonAdd;
    S:real;
    SP,T,T1:TvecValue;
begin
  Bb:=New(PFunction,Init(N+2));
  Bb^.Color:=1;
  Bb^.Labels:='W';
  For i:=2 to N+1 do begin
    CA:=GetCA(i-1);
    Bb^.PutX(i,CA^.S);
    Bb^.PutY(i,CA^.Cyclon/(-1*CA^.dS));
    end;
    Bb^.PutX(1,0);
    Bb^.PutY(1,(Bb^.GetY(2)+Bb^.GetY(N+1))/2);
    Bb^.PutX(N+2,Map^.GetMaxS);
    Bb^.PutY(N+2,Bb^.GetY(1));
{  GetSpeed(Sp);
  SP.ProX:=SP.ProX-PMain(Owner)^.Potok.ProX/PMain(Owner)^.U0;
  SP.ProY:=SP.ProY-PMain(Owner)^.Potok.ProY/PMain(Owner)^.U0;
  for i:=1 to N+2 do begin
    S:=Bb^.GetX(i);
    T.ProX:=Map^.Get_TX_S(S);
    T.ProY:=Map^.Get_TY_S(S);
    ConvVector(Tang,Norm,T,T1);
    Bb^.PutY(i,Bb^.GetY(i)-GetProection(T1,SP));
    end;}
    GetW:=Bb;
end;

procedure TProfile.GetSpeed(var Speed:TSpeed);
begin
  Speed.ProX:=(PMain(Owner)^.Omega*PMain(Owner)^.R*Sin(Azimut)+
               PMain(Owner)^.Potok.ProX)/PMain(Owner)^.U0;
  Speed.ProY:=(PMain(Owner)^.Potok.ProY-PMain(Owner)^.Omega*
               PMain(Owner)^.R*Cos(Azimut))/PMain(Owner)^.U0;
end;
function TProfile.GetReynolds:real;
var SP:TSpeed;
    Spe:real;
begin
  GetSpeed(SP);
  Spe:=Sqrt(Sqr(Sp.ProX)+Sqr(Sp.ProY));
  With PMain(Owner)^ do begin
  SPe:=SPe*U0;
  Re:=SPe*b/Nu;
  end;
  GetReynolds:=Re;
end;
procedure TProfile.PutNormtang;
var Temp:TPoints;
    Fi:real;
    TT,NN:TVecValue;
begin
  Fi:=CornerSystem+(Azimut-pi/2);
  Tang.ProX:=Cos(Fi);Tang.ProY:=Sin(Fi);
  Norm.ProX:=-1*Sin(Fi);Norm.ProY:=Cos(Fi);
end;
procedure TProfile.ConvLocAbs(var Plase:TPoints);
var Temp:TPoints;
    Fi:real;
    TT,NN:TVecValue;
begin
{  Temp:=Plase;
  Fi:=CornerSystem+(Azimut-pi/2);
  Plase.X:=Cos(Fi)*Temp.X-Sin(Fi)*Temp.Y+Coord.X;
  Plase.Y:=Sin(Fi)*Temp.X+Cos(Fi)*Temp.Y+Coord.Y;}
  Temp:=Plase;
  Fi:=CornerSystem+(Azimut-pi/2);
  TT.ProX:=Cos(Fi);TT.ProY:=Sin(Fi);
  NN.ProX:=-1*Sin(Fi);NN.ProY:=Cos(Fi);
  ConvCoord(TT,NN,Coord,Temp,Plase);
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
procedure TProfile.ConvVecLocAbs(var Vec:TVecValue);
var
    Fi:real;
    Temp,TT,NN:TVecValue;
begin
  Temp:=Vec;
  Fi:=CornerSystem+(Azimut-pi/2);
  TT.ProX:=Cos(Fi);TT.ProY:=Sin(Fi);
  NN.ProX:=-1*Sin(Fi);NN.ProY:=Cos(Fi);
  ConvVector(TT,NN,Temp,Vec);
end;
procedure TProfile.DigitNewPlase;
begin
   Coord.X:=R*Cos(Azimut);
   Coord.Y:=R*Sin(Azimut);
   PutNormTang;
end;
procedure TProfile.GetForce;
var C,C1:TVecValue;
begin
  GetForceForNorm(C);
  if IsItSetFlag(PMain(Owner)^.Option,moIdealFluid) then begin
    C1.ProX:=0.0;
    C1.ProY:=0.0;
    end
    else GetForceForTang(C1);
  Cx:=C.ProX+C1.ProX;
  Cy:=C.ProY+C1.ProY;
end;{GetForce}
procedure TProfile.GetForceForNorm(var Force:TVecValue);
var F:PFunction;
    i:integer;
    CA:PCyclonAdd;
    W,P,dF:real;
    WVec,WVec1,OmegaR:TVecValue;
    Fi,ORAbs:real;
begin
{  F:=GetW;
  for i:=1 to F^.EndH do
    F^.PutY(i,-1*(1-Sqr(F^.GetY(i)))*Map^.Get_NX_S(F^.GetX(i)));
  Force.ProX:=IntTrapecia(F);
  Dispose(F,Done);
  F:=GetW;
  for i:=1 to F^.EndH do
    F^.PutY(i,-1*(1-Sqr(F^.GetY(i)))*Map^.Get_NY_S(F^.GetX(i)));
  Force.ProY:=IntTrapecia(F);
  Dispose(F,Done);}
{  F:=New(PFunction,Init(N+1));}
  Force.ProX:=0;
  Force.ProY:=0;
    Fi:=Azimut;
    ORAbs:=PMain(Owner)^.bOmega*PMain(Owner)^.bR;
  for i:=1 to N do begin
    CA:=GetCA(i);
{    F^.PutX(i,GetCP(i)^.S);}
    W:=CA^.Cyclon/(-1*CA^.dS);{касательная скорость}
    WVec.ProX:=W;
    WVec.ProY:=0.0;{вектор касательной скорости}
    ConvVector(CA^.Tang,CA^.Norm,WVec,WVec1);{в локальной системе}
    ConvVector(Tang,Norm,WVec1,WVec);{тоже в центральной системе координат}
    OmegaR.ProX:=-1*sin(Fi)*ORAbs;
    OmegaR.ProY:=cos(Fi)*ORAbs;{скорость движения профиля}
    WVec.ProX:=WVec.ProX-OmegaR.ProX;
    WVec.ProY:=WVec.ProY-OmegaR.ProY;
    W:=Sqrt(Sqr(WVec.ProX)+Sqr(WVec.ProY));{абсолютная скорость потока}
    P:=1-Sqr(W){нормальное давление};
    dF:=-1*P*CA^.Norm.ProX*CA^.dS;{элементарная сила}
    CA^.Pressure:=P;
    Force.ProX:=Force.ProX+dF;
    dF:=-1*P*CA^.Norm.ProY*CA^.dS;
    Force.ProY:=Force.ProY+dF
    end;
{  F^.PutX(N+1,F^.GetX(1));
  F^.PutY(N+1,F^.GetY(1));}
{  Force.ProY:=IntTrapecia(F);}
{  Force.ProY:=0;
  for i:=1 to N do begin
    CA:=GetCA(i);
    W:=CA^.Cyclon/(-1*CA^.dS);
    P:=1-Sqr(W);
    end;
{  GetSpeed(Sp);
  SP.ProX:=SP.ProX-PMain(Owner)^.Potok.ProX/PMain(Owner)^.U0;
  SP.ProY:=SP.ProY-PMain(Owner)^.Potok.ProY/PMain(Owner)^.U0;
  for i:=1 to N+2 do begin
    S:=Bb^.GetX(i);
    T.ProX:=Map^.Get_TX_S(S);
    T.ProY:=Map^.Get_TY_S(S);
    ConvVector(Tang,Norm,T,T1);
    Bb^.PutY(i,Bb^.GetY(i)-GetProection(T1,SP));
    end;}

{  F^.PutY(N+1,F^.GetY(1));
  Force.ProY:=-1*IntTrapecia(F);
  Dispose(F,Done);}
end;{GetForceForNorm}
procedure TProfile.GetForceForTang(var Force:TVecValue);
var F,F1:PFunction;
    i:integer;
    tay:real;
    Opt:word;
    L,H:integer;
    dS:real;
begin
  L:=Main^.EndH+1;
  H:=Main^.EndV-1;
  F:=New(PFunction,Init(L));
  F1:=New(PFunction,Init(L));
  dS:=Map^.GetMaxS/(L-1);
  for i:=1 to L do begin
    F^.PutX(i,Main^.Get_S(i-1));
    F1^.PutX(i,Main^.Get_S(i-1));
    Main^.GetOptions(i-1,Opt);
    If (Opt and psOk) = psOk then
      tay:=2*Main^.Get(1,i-1)*H/(Main^.Get(H+1,i-1)*Sqrt(Re))
    else
     tay:=0.0;
    F^.PutY(i,tay*Map^.Get_TX_S(F^.GetX(i)));
    F1^.PutY(i,tay*Map^.Get_TY_S(F1^.GetX(i)));
    Main^.Put_Tay(i-1,tay);
    end;
  Force.ProX:=IntTrapecia(F);
  Force.ProY:=IntTrapecia(F1);
end;{GetForceForTang}
procedure TProfile.UnitedFreeCyclon;
var C1,C2,C3,C4,C:PCyclon;
    Dc,Xc,Yc,Cycl:real;
    Plase:TPoints;
    i:integer;
begin
  If NFree < FreePreserve then exit;
{  C1:=GetCF(NFree);
  C2:=GetCF(NFree-1);
  C3:=GetCF(NFree-2);
  C4:=GetCF(NFree-3);
  Dc:=Abs(C1^.Cyclon)+Abs(C2^.Cyclon)+Abs(C3^.Cyclon)+Abs(C4^.Cyclon);
  Xc:=C1^.Coord.X*Abs(C1^.Cyclon)+C2^.Coord.X*Abs(C2^.Cyclon)+
      C3^.Coord.X*Abs(C3^.Cyclon)+C4^.Coord.X*Abs(C4^.Cyclon);
  Yc:=C1^.Coord.Y*Abs(C1^.Cyclon)+C2^.Coord.Y*Abs(C2^.Cyclon)+
      C3^.Coord.Y*Abs(C3^.Cyclon)+C4^.Coord.Y*Abs(C4^.Cyclon);
  Cycl:=C1^.Cyclon+C2^.Cyclon+C3^.Cyclon+C4^.Cyclon;
  Xc:=Xc/Dc;
  Yc:=Yc/Dc;
  Plase.X:=Xc;Plase.Y:=Yc;
  For i:=1 to 4 do DelCF(NFree);
  C:=New(PCyclon,Init(PMain(Owner)^.CountCF+1,Plase));
  C^.Cyclon:=Cycl;
  InsCF(C);}
  MessageBox(^C'Своболных вихрей слишком много.'
            +^M^C'Вычисления останавливаются',nil,mfWarning or mfOkButton);
  PMain(Owner)^.Time:=PMain(Owner)^.MaxTime;
end;
procedure TProfile.DelCF;
var C:PCyclon;
begin
  C:=PCyclon(CyclonFree^.At(ANumber-1));
  CyclonFree^.AtDelete(ANumber-1);
  Dec(NFree);
  Dec(PMain(Owner)^.CountCF);
  Dispose(C,Done);
end;
procedure TProfile.DissipationFirstTime;
var i,CC:integer;
    DNew:real;
    C:PCyclon;
begin
   CC:=0;
   DNew:=0;
   for i:=1 to NFree do begin
    C:=GetCF(i);
    If ISItSetFlag(C^.Option,ocNew) then begin
      DNew:=DNew+Abs(C^.Cyclon);
      Inc(CC);
    end;end;
   DNew:=DNew/CC;
   for i:=1 to NFree do begin
    C:=GetCF(i);
    If ISItSetFlag(C^.Option,ocNew) then
      C^.Cyclon:=DNew*sign(C^.Cyclon);
    end;
end;
procedure TProfile.Dissipation;
var DNew,DOld,D,Dissip:real;
    i:integer;
    CF:PCyclon;
begin
  DNew:=0;
  {Сумма интенсивностей вновь сошедших вихрей}
  for i:=1 to NFree do begin
    CF:=GetCF(i);
    If ISItSetFlag(CF^.Option,ocNew) then DNew:=DNew+CF^.Cyclon;
    end;
  if DNew = 0.0 then exit;
  {Если сумма положительна то диссипируют положительные св. вихри}
  {иначе - отрицательные}
  {сумма положительных или отрицательных вихрей в потоке}
  DOld:=0;
  for i:=1 to NFree do begin
    CF:=GetCF(i);
    If ISItSetFlag(CF^.Option,ocOld) then
      if sign(DNew) = sign(CF^.Cyclon) then DOld:=DOld+CF^.Cyclon;
    end;
  {если нечему диссипировать, то как в первый момент времени}
  if Abs(DOld) < Abs(DNew) then begin
     DissipationFirstTime;
     exit;
     end;
  if DOld = 0.0 then Dissip:=1
    else  Dissip:=Abs((DOld-DNew)/DOld);{коэфф. диссипации}
  for i:=1 to NFree do begin
    CF:=GetCF(i);
    If ISItSetFlag(CF^.Option,ocOld) then
      if sign(DNew) = sign(CF^.Cyclon) then CF^.Cyclon:=CF^.Cyclon*Dissip;
    end;
  D:=0.0;
  for i:=1 to NFree do
    D:=D+GetCF(i)^.Cyclon;
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
    x,y,t:real;
begin
 With MapPtr^ do begin
 Len:=M;
 For i:=1 to Len-1 do begin
   RAbs:=Sqrt(Sqr(GetX(i+1)-GetX(i))+Sqr(GetY(i+1)-GetY(i)));
   x:=GetX(i+1);
   y:=GetX(i);
   t:=(x-y)/RAbs;
   PutTX(i,t);
   x:=GetY(i+1);
   y:=GetY(i);
   t:=(x-y)/RAbs;
   PutTY(i,t);
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
