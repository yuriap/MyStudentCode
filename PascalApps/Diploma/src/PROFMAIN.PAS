unit ProfMain;
interface
uses Dos,Objects,Views,Profile,ProfComm,ProBound,ProfDin,Gauss,StrmErr,Drivers;
type
   PMainRec = ^TMainRec;
   TMainRec = record
     Option:word;
     CountProfile:word;
     b:real;
     dt:real;
     R:real;
     Potok:TSpeed;
     Omega:real;
     Betta0:real;{азимутальный угол первой лопасти}
     Nu:real;{вязкость среды}
     MaxTime:integer;
     FileMapContur:FNameStr;
     ProfRecPtr:PProfileRec;
     BoundRec:PBREc;
     end;
  PCharact = ^TCharact;
  TCharact = object(TObject)
     Moment:real;
     Corner:real;
     Time:integer;
     Cr:real;{радиальная}
     Cq:real;{тянущая}
     Cp:real;{}
     Cx:real;{}
     Cz:real;{}
     constructor Load(var S:TStream);
     procedure Store(var S:TStream);
     end;
   PMain = ^TMain;
   PCharCollect = ^TCharCollect;
   TCharCollect = object(TCollection)
     Owner:PMain;
     function GetMoment_Corner:PFunction;
     function GetCp_Corner:PFunction;
     function GetMoment_Time:PFunction;
     function GetCp_Time:PFunction;
     function GetMiddleCp:real;
     function GetMiddleMoment:real;
     function GetCz_Corner:PFunction;
     function GetCx_Corner:PFunction;
     function GetCz_Time:PFunction;
     function GetCx_Time:PFunction;
     function GetMiddleCz:real;
     function GetMiddleCx:real;
     function GetCr_Corner:PFunction;
     function GetCq_Corner:PFunction;
     function GetCr_Time:PFunction;
     function GetCq_Time:PFunction;
     end;

  TMain = object(TBasePoint)
      CountProfil:word;{колличество профилей}
      CountCP:word;{колличество контрольных точек на профиле}
      CountCF:word;{колл. свободных вихрей в потоке}
      FileMap:string[12];
      b:real;{хорда}
      bb:real;{хорда безразмерная}
      dt:real;{шаг по времени}
      bdt:real;{шаг по времени безразмерный}
      R:real;{радиус ВК}
      bR:real;{радиус ВК безразмерный}
      Potok:TSpeed;{скорость невозмущенного потока (вектор)}
      U0:real;{скорость невозмущенного потока}
      bU0:real;{скорость невозмущенного потока безразмерная}
      Omega:real;{частота вращения ротора}
      bOmega:real;{частота вращения ротора безразмерная}
      Betta0:real;{азимут первой лопасти}
      Nu:real;{вязкость среды}
      Time:integer;{счетчик моментов времени}
      MaxTime:integer;
      Profiles:PCollection;
      Map:PMapProf;
      LeftPart:PMatrix;
      RightPart:PVector;
      IncPart:PVector;
      BLayer:PBoundLayer;
      CharCollect:PCharCollect;
      Fasa:string[22];
      constructor Init(MainRec:TMainRec);
      constructor Load(var S:TStream);
      destructor Done;virtual;
      procedure Store(var S:TStream);
      function GetProfile(i:word):PProfile;
      function GetGlobalCP(i:word):PControlPoint;
      function GetGlobalCA(i:word):PCyclonAdd;
      function GetGlobalCF(i:word):PCyclon;
      procedure DelGlobalCF(i:word);
      procedure GetInductSpeed(Plase:TPoints;var Speed:TSpeed);
      procedure GetInductionAll(Plase:TPoints;var Speed:TSpeed);
      procedure GetLeftPart;virtual;
      procedure GetRightPart;virtual;
      procedure GetIncogPart;virtual;
      procedure Diskreet;virtual;
      procedure BoundaryLayer;virtual;
      procedure TheoremaThomsona;virtual;
      procedure TimeDissipation;virtual;
      procedure DelSmallCyclon;virtual;
      procedure MoveProfile;virtual;
      procedure MoveFreeCyclon;virtual;
      procedure GetForce;virtual;
      procedure StoreCharacteristic;
      procedure Execute;virtual;
      end;
const
   RMain : TStreamRec = (
      ObjType : idMain;
      VmtLink: Ofs(TypeOf(TMain)^);
      Load:@TMain.Load;
      Store:@TMain.Store);
   RCharact : TStreamRec = (
      ObjType : idCharact;
      VmtLink: Ofs(TypeOf(TCharact)^);
      Load:@TCharact.Load;
      Store:@TCharact.Store);
   RCharCollect : TStreamRec = (
      ObjType : idCharCollect;
      VmtLink: Ofs(TypeOf(TCharCollect)^);
      Load:@TCharCollect.Load;
      Store:@TCharCollect.Store);

procedure RegisterMain;
implementation
Uses TVRUnit,TVRComm;
procedure RegisterMain;
begin
  RegisterDinamic;
  RegisterProfile;
  RegisterBoundLayer;
  RegisterType(RMain);
  RegisterType(RCharact);
  RegisterType(RCharCollect);
end;

constructor TMain.Init;
var i:integer;
    PR:PProfile;
    PLase:TPoints;
    db:real;{азимутальный шаг лопастей}
    SS:PMsgStream;
    Opt:Word;
    D: DirStr;
    N: NameStr;
    E: ExtStr;
begin
  Option:=MainRec.Option;
  CountProfil:=MainRec.CountProfile;
  Profiles:=New(PCollection,Init(CountProfil,0));
  CountCF:=0;
  b:=MainRec.b;
  dt:=MainRec.dt;
  R:=MainRec.R;
  Potok:=MainRec.Potok;
  U0:=Sqrt(Sqr(Potok.ProX)+Sqr(Potok.ProY));
  Omega:=MainRec.Omega;
  bb:=1;
  bdt:=dt*U0/b;
  bR:=R/b;
  bU0:=1;
  bOmega:=Omega*b/U0;
  Betta0:=MainRec.Betta0;
  Time:=0;
  MaxTime:=MainRec.MaxTime;
  Nu:=MainRec.Nu;
  CharCollect:=New(PCharCollect,Init(50,10));
  CharCollect^.Owner:=@Self;
  SS:=New(PMsgStream,Init(MainRec.FileMApContur,stOpenRead,2048));
  Map:=PMapProf(SS^.Get);
  Dispose(SS,Done);
  if not((Option and moAutoBreak) = moAutoBreak) then
      CountCP:=Map^.GetCountPoint
      else
      CountCP:=MainRec.ProfRecPtr^.CountCP;
  with MainRec.ProfRecPtr^ do begin
    MapPtr:=Map;
    end;
  db:=2*pi/CountProfil;
  for i:=1 to CountProfil do begin
  MainRec.ProfRecPtr^.Azimut:=Betta0+(i-1)*db;
  MainRec.ProfRecPtr^.R:=bR;
  PR:=New(PProfile,Init(i,MainRec.ProfRecPtr));
  PR^.PutOwner(@Self);
  Profiles^.Insert(PR);
  end;
  LeftPart:=
   New(PMatrix,Init(1,CountProfil*(CountCP+1),1,CountProfil*(CountCP+1)));
  RightPart:=New(PVector,Init(1,CountProfil*(CountCP+1)));
  IncPart:=New(PVector,Init(1,CountProfil*(CountCP+1)));
  GetLeftPart;
  BLayer:=New(PBoundLayer,Init(MainRec.BoundRec^));
  Fasa:='Hачало расчета';
  FSplit(MainRec.FileMApContur,D,N,E);
  FileMap:=N;
end;
procedure TMain.Store(var S:TStream);
begin
   inherited Store(S);
   S.Write(CountProfil,SizeOf(CountProfil));
   S.Write(CountCP,SizeOf(CountCP));
   S.Write(CountCF,SizeOf(CountCF));
   S.Write(b,SizeOf(b));
   S.Write(bb,SizeOf(bb));
   S.Write(dt,SizeOf(dt));
   S.Write(bdt,SizeOf(bdt));
   S.Write(R,SizeOf(R));
   S.Write(bR,SizeOf(bR));
   S.Write(Potok,SizeOf(Potok));
   S.Write(U0,SizeOf(U0));
   S.Write(bU0,SizeOf(bU0));
   S.Write(Omega,SizeOf(Omega));
   S.Write(bOmega,SizeOf(bOmega));
   S.Write(Betta0,SizeOf(Betta0));
   S.Write(Nu,SizeOf(Nu));
   S.Write(Time,SizeOf(Time));
   S.Write(MaxTime,SizeOf(MaxTime));
   S.Write(Fasa,SizeOf(Fasa));
   S.Write(FileMap,SizeOf(FileMap));
   S.Put(Profiles);
   S.Put(Map);
   S.Put(LeftPart);
   S.Put(RightPart);
   S.Put(IncPart);
   S.Put(BLayer);
   S.Put(CharCollect);
end;
constructor TMain.Load(var S:TStream);
var i:integer;
begin
   inherited Load(S);
   S.Read(CountProfil,SizeOf(CountProfil));
   S.Read(CountCP,SizeOf(CountCP));
   S.Read(CountCF,SizeOf(CountCF));
   S.Read(b,SizeOf(b));
   S.Read(bb,SizeOf(bb));
   S.Read(dt,SizeOf(dt));
   S.Read(bdt,SizeOf(bdt));
   S.Read(R,SizeOf(R));
   S.Read(bR,SizeOf(bR));
   S.Read(Potok,SizeOf(Potok));
   S.Read(U0,SizeOf(U0));
   S.Read(bU0,SizeOf(bU0));
   S.Read(Omega,SizeOf(Omega));
   S.Read(bOmega,SizeOf(bOmega));
   S.Read(Betta0,SizeOf(Betta0));
   S.Read(Nu,SizeOf(Nu));
   S.Read(Time,SizeOf(Time));
   S.Read(MaxTime,SizeOf(MaxTime));
   S.Read(Fasa,SizeOf(Fasa));
   S.Read(FileMap,SizeOf(FileMap));
   Profiles:=PCollection(S.Get);
   Map:=PMapProf(S.Get);
   LeftPart:=PMatrix(S.Get);
   RightPart:=PVector(S.Get);
   IncPart:=PVector(S.Get);
   BLayer:=PBoundLayer(S.Get);
   CharCollect:=PCharCollect(S.Get);
   CharCollect^.Owner:=@Self;
   For i:=1 to CountProfil do begin
     GetProfile(i)^.PutOwner(@Self);
     GetProfile(i)^.Map:=Map;
     end;
end;
destructor TMain.Done;
begin
  Dispose(Profiles,Done);
  Dispose(Map,Done);
  Dispose(LeftPart,Done);
  Dispose(RightPart,Done);
  Dispose(IncPart,Done);
  Dispose(BLayer,Done);
  Dispose(CharCollect,Done);
  inherited Done;
end;
function TMain.GetProfile(i:word):PProfile;
begin
  if i = 0 Then GetProfile:=nil
  else
  GetProfile:=PProfile(Profiles^.At(i-1));
end;
function TMain.GetGlobalCP(i:word):PControlPoint;
var j:integer;
begin
  If i > CountProfil*CountCP Then GetGlobalCP:=nil
    else begin
    for j:=1 to CountProfil do begin
      if (i > CountCP*(j-1)) and (i <= CountCP*j)
        then
          GetGlobalCP:=GetProfile(j)^.GetCP(i-CountCP*(j-1));
    end;{for}
    end;{else}
end;
function TMain.GetGlobalCA(i:word):PCyclonAdd;
var j:integer;
begin
  If i > CountProfil*CountCP Then GetGlobalCA:=nil
    else begin
    for j:=1 to CountProfil do begin
      if (i > CountCP*(j-1)) and (i <= CountCP*j)
        then
          GetGlobalCA:=GetProfile(j)^.GetCA(i-CountCP*(j-1));
    end;{for}
    end;{else}
end;
function TMain.GetGlobalCF(i:word):PCyclon;
var j,k:integer;
    P:PProfile;
begin
{  If i > CountProfil*CountCF Then GetGlobalCF:=nil
    else begin
    for j:=1 to CountProfil do begin
      if (i > CountCF*(j-1)) and (i <= CountCF*j)
        then
          GetGlobalCF:=GetProfile(j)^.GetCF(i-CountCF*(j-1));
    end;
    end;{else}
    for j:=1 to CountProfil do begin
      P:=GetProfile(j);
      for k:=1 to P^.NFree do
        if i = P^.GetCF(k)^.Number then GetGlobalCF:=P^.GetCF(k);
    end;{for}
end;
procedure TMain.DelGlobalCF(i:word);
var CF:PCyclon;
    P:PProfile;
begin
   CF:=GetGlobalCF(i);
   P:=PProfile(CF^.Owner);
   P^.CyclonFree^.Delete(CF);
   Dispose(CF,Done);
   Dec(CountCF);
   Dec(P^.NFree);
end;
procedure TMain.GetLeftPart;
var
  l,v,k,z,i,j:integer;
  CP:PControlPoint;
  Plase:TPoints;
  Norm,Sp:TVecValue;
  P:PProfile;

begin
{  k:=1;z:=1;
  For i:=1 to CountCP*CountProfil do begin
    For j:=1 to CountCP*CountProfil+1 do begin
    if j = CountCP*CountProfil+1 then LeftPart^.Put(i,j,1) else
      begin
      CP:=GetGlobalCP(k);
      CP^.GetCoord(Plase);
      PProfile(CP^.Owner)^.ConvLocAbs(Plase);
      CP^.GetNorm(Norm);
      PProfile(CP^.Owner)^.ConvVecLocAbs(Norm);
      GetGlobalCA(z)^.GetCoeff(Plase,Sp);
      LeftPart^.Put(i,j,GetProection(Norm,SP));
      Inc(z);
      end;end;
      z:=1;Inc(k);
      end;
    For j:=1 to CountCP*CountProfil do
      LeftPart^.Put(CountCP*CountProfil+1,j,1);
      LeftPart^.Put(CountCP*CountProfil+1,CountCP*CountProfil+1,0);}
  k:=1;z:=1;v:=1;
  For i:=1 to CountCP*CountProfil do begin
    For j:=1 to (CountCP+1)*CountProfil do begin
      if v > CountCP then begin
        LeftPart^.Put(i,j,1);
        v:=1;
        end
        else begin
      CP:=GetGlobalCP(k);
      CP^.GetCoord(Plase);
      PProfile(CP^.Owner)^.ConvLocAbs(Plase);
      CP^.GetNorm(Norm);
      PProfile(CP^.Owner)^.ConvVecLocAbs(Norm);
      GetGlobalCA(z)^.GetCoeff(Plase,Sp);
      LeftPart^.Put(i,j,GetProection(Norm,SP));
      Inc(z);
      Inc(v)
      end;end;
      z:=1;v:=1;Inc(k);
      end;
  {доп условия}
  for i:=1 to CountProfil do begin
   P:=GetProfile(i);
   for l:=1 to P^.N do
     if IsItSetFlag(P^.GetCP(l)^.Option,moBackBound) then break;
     CP:=P^.GetCP(l);
     k:=1;z:=1;
      CP^.GetCoord(Plase);
      P^.ConvLocAbs(Plase);
      CP^.GetTang(Norm);
      P^.ConvVecLocAbs(Norm);
   for j:=1 to (CountCP+1)*CountProfil do
     if z <> CountCP+1 then begin
      GetGlobalCA(k)^.GetCoeff(Plase,Sp);
      LeftPart^.Put(i+CountCP*CountProfil,j,GetProection(Norm,SP));
      inc(k);inc(z);
      end
        else begin
        LeftPart^.Put(i,j,1);
        z:=1;
        end;
        end;
end;
procedure TMain.GetInductSpeed(Plase:TPoints;var Speed:TSpeed);
var
  i:integer;
  CF:PCyclon;
  SP:TSpeed;
begin
   Speed.ProX:=0.0;
   Speed.ProY:=0.0;
   For i:=1 to CountCF do begin
   CF:=GetGlobalCF(i);
   CF^.GetInduction(Plase,SP);
   Speed.ProX:=Speed.ProX+SP.ProX;
   Speed.ProY:=Speed.ProY+SP.ProY;
   end;
end;
procedure TMain.GetInductionAll(Plase:TPoints;var Speed:TSpeed);
var
  i:integer;
  CA:PCyclonAdd;
  SP:TSpeed;
begin
   Speed.ProX:=0.0;
   Speed.ProY:=0.0;
   For i:=1 to CountCP*CountProfil do begin
   CA:=GetGlobalCA(i);
   CA^.GetInduction(Plase,SP);
   Speed.ProX:=Speed.ProX+SP.ProX;
   Speed.ProY:=Speed.ProY+SP.ProY;
   end;
   GetInductSpeed(Plase,SP);
   Speed.ProX:=Speed.ProX+SP.ProX;
   Speed.ProY:=Speed.ProY+SP.ProY;
end;

procedure TMain.GetRightPart;
{var
   i:integer;
   CP:PControlPoint;
   CF:PCyclon;
   Cycl:real;
   SP,SP1:TSpeed;Norm:TVecValue;
   Plase:TPoints;
begin
  For i:=1 to CountCP*CountProfil do begin
    CP:=GetGlobalCP(i);
    PProfile(CP^.Owner)^.GetSpeed(Sp);
    CP^.GetCoord(Plase);
    PProfile(CP^.Owner)^.ConvLocAbs(Plase);
    GetInductSpeed(Plase,SP1);
    SP.ProX:=SP.ProX+SP1.ProX;
    SP.ProY:=SP.ProY+SP1.ProY;
    CP^.GetNorm(Norm);
    PProfile(CP^.Owner)^.ConvVecLocAbs(Norm);
    RightPart^.Put(i,-1*GetProection(Norm,SP));
    end;
    Cycl:=0.0;
    For i:=1 to CountCF do begin
    CF:=GetGlobalCF(i);
    Cycl:=Cycl-CF^.Cyclon;
    end;
    If ((ISITSetFlag(Option,moDissipation) or
       IsItSetFlag(Option,moDissipationTime)) and
       not(IsItSetFlag(Option,moNotFreeCyclon))and
       (IsItSetFlag(Option,moDisposeMeddle))) then Cycl:=0.0;
    Cycl:=Cycl+BeginCyrculation;
    RightPart^.Put(CountCP*CountProfil+1,Cycl);
end;}
var
   i,l:integer;
   CP:PControlPoint;
   CF:PCyclon;
   Cycl:real;
   SP,SP1:TSpeed;Norm:TVecValue;
   Plase:TPoints;
   P:PProfile;
begin
  For i:=1 to CountCP*CountProfil do begin
    CP:=GetGlobalCP(i);
    PProfile(CP^.Owner)^.GetSpeed(Sp);
    CP^.GetCoord(Plase);
    PProfile(CP^.Owner)^.ConvLocAbs(Plase);
    GetInductSpeed(Plase,SP1);
    SP.ProX:=SP.ProX+SP1.ProX;
    SP.ProY:=SP.ProY+SP1.ProY;
    CP^.GetNorm(Norm);
    PProfile(CP^.Owner)^.ConvVecLocAbs(Norm);
    RightPart^.Put(i,-1*GetProection(Norm,SP));
    end;
  for i:=1 to CountProfil do begin
   P:=GetProfile(i);
   for l:=1 to P^.N do
     if IsItSetFlag(P^.GetCP(l)^.Option,moBackBound) then break;
      CP:=P^.GetCP(l);
      P^.GetSpeed(Sp);
      CP^.GetCoord(Plase);
      P^.ConvLocAbs(Plase);
      GetInductSpeed(Plase,SP1);
      SP.ProX:=SP.ProX+SP1.ProX;
      SP.ProY:=SP.ProY+SP1.ProY;
      CP^.GetTang(Norm);
      P^.ConvVecLocAbs(Norm);
      RightPart^.Put(i+CountCP*CountProfil,-1*GetProection(Norm,SP));
      end;
end;
procedure TMain.GetIncogPart;
{var i:integer;
    CA:PCyclonAdd;
begin
  GaussStm(LeftPart,IncPart,RightPart);
  for i:=1 to CountCP*CountProfil do begin
   CA:=GetGlobalCA(i);
   CA^.PutCyclon(IncPart^.Get(i));
   end;
end;}
var i,v,k:integer;
    CA:PCyclonAdd;
begin
  v:=1;k:=1;
  GaussStm(LeftPart,IncPart,RightPart);
  for i:=1 to (1+CountCP)*CountProfil do begin
   if v <= CountCP then begin
     CA:=GetGlobalCA(k);
     CA^.PutCyclon(IncPart^.Get(i));
     inc(v);inc(k);
     end
     else v:=1;
   end;
end;
procedure TMain.Diskreet;
begin
  GetRightPart;
  GetIncogPart;
end;
procedure TMain.BoundaryLayer;
var i:integer;
begin
  for i:=1 to CountProfil do begin
  BLayer^.InstallProfile(GetProfile(i));
  BLayer^.Execute;
  end;
end;
procedure TMain.Execute;
var E:TEvent;
begin
  repeat
  {Расчет по МДВ}
  Fasa:='Расчет по МДВ';
  Message(StatusWindow,evBroadCast,cmChangeFasa,@Self);
  Diskreet;
  {Расчет параметров пограничного слоя на всех лопастях}
  if not(IsItSetFlag(Option,moIdealFluid)) then begin
    Fasa:='Расчет ПС';
    Message(StatusWindow,evBroadCast,cmChangeFasa,@Self);
    BoundaryLayer;
    end;
  {Расчет сил действующих на профили}
  Fasa:='Расчет сил';
  Message(StatusWindow,evBroadCast,cmChangeFasa,@Self);
  GetForce;
  {Сохранение параметров для построения характеристик ротора}
  Fasa:='Расчет характер.';
  Message(StatusWindow,evBroadCast,cmChangeFasa,@Self);
  StoreCharacteristic;
  {Обеспечивает соблюдение теоремы Томсона}
  TheoremaThomsona;
  TimeDissipation;
  {Удаляет из потока малые св. вихри см. ProfComm.SmallCyclon}
{  DelSmallCyclon;
  {Перемещение свободных вихрей вместе с потоком}
  if (not(ISItSetFlag(Option,moNotFreeCyclon))and
      not(IsItSetFlag(Option,moIdealFluid))) then begin
    Fasa:='Перемещение св.в.';
    Message(StatusWindow,evBroadCast,cmChangeFasa,@Self);
    MoveFreeCyclon;
    end;
  {Поворот ротора в следующее расчетное положение}
  Fasa:='Поворот лопастей';
  Message(StatusWindow,evBroadCast,cmChangeFasa,@Self);
  MoveProfile;
  {Увеличивает счетчик шагов времени}
  Inc(Time);
  GetKeyEvent(E);
  until ((E.What = evKeyDown) and (E.KeyCode = kbAltS)) or (Time >= MaxTime);
  if ((E.What = evKeyDown) and (E.KeyCode = kbAltS)) then
       Fasa:='Вычисления прерваны'
       else
       Fasa:='Вычисления окончены';
  Message(StatusWindow,evBroadCast,cmChangeFasa,@Self);
end;
procedure TMain.MoveProfile;
var i:integer;
    P:PProfile;
begin
  for i:=1 to CountProfil do begin
   P:=GetProfile(i);
   P^.Azimut:=P^.Azimut+Omega*dt;
   P^.DigitNewPlase;
   end;
end;{TMain.MoveProfile}
procedure TMain.MoveFreeCyclon;
var i:integer;
    Opt:word;
    CF:PCyclon;
    Plase:TPoints;
    SP:TSpeed;
begin
  for i:=1 to CountCF do begin
   CF:=GetGlobalCF(i);
   Opt:=CF^.GetOption;
   if (Opt and ocOld) = ocOld then begin
     CF^.GetCoord(Plase);
     GetInductionAll(Plase,SP);
     Plase.X:=Plase.X+(SP.ProX+Potok.ProX/U0)*bdt;
     Plase.Y:=Plase.Y+(SP.ProY+Potok.ProY/U0)*bdt;
     CF^.PutMovingPlase(Plase);
     end;
     end;
  for i:=1 to CountCF do begin
   CF:=GetGlobalCF(i);
   Opt:=CF^.GetOption;
   if (Opt and ocOld) = ocOld then  CF^.Move
   end;
  for i:=1 to CountCF do begin
   CF:=GetGlobalCF(i);
   Opt:=CF^.GetOption;
   if (Opt and ocNew) = ocNew then
     begin
     CF^.Option:=CF^.Option and not ocNew;
     CF^.PutOption(ocOld);
     end;end;
   {Объединяет св. вихри}
   For i:=1 to CountProfil do
     GetProfile(i)^.UnitedFreeCyclon;
end;{TMain.MoveFreeCyclon}
procedure TMain.GetForce;
var i:integer;
begin
   For i:=1 to CountProfil do
     GetProfile(i)^.GetForce;
end;{TMain.GetForce}
procedure TMain.StoreCharacteristic;
var Ch:PCharact;
    Pr:PProfile;
    M:real;
    i:integer;
    Cr,Ct,W,Cx,Cz,Cq,Crr:real;
    Sp:TSpeed;
begin
  Ch:=New(PCharact,Init);
  M:=0;
  Cx:=0;Cz:=0;
  for i:=1 to CountProfil do begin
   Pr:=GetProfile(i);
   Pr^.GetSpeed(SP);
   W:=Sqr(Sp.ProX)+Sqr(Sp.ProY);
   Ct:=-1*Pr^.Cx*Cos(Pr^.CornerSystem)+Pr^.Cy*Sin(Pr^.CornerSystem);
   Cr:=Pr^.Cx*Sin(Pr^.CornerSystem)+Pr^.Cy*Cos(Pr^.CornerSystem);
   {коэфф. тянущей и радиальной силы}
{   Cr:=Cr*W;
   Ct:=Ct*W;}
   Cq:=Ct/(2*bR);
   Crr:=Cr/(2*bR);
   if i = 1 then begin
     Ch^.Cq:=Cq;
     Ch^.Cr:=Crr;end;
   M:=M+Cq;
   Cz:=Cz+Crr*Sin(GetProfile(i)^.Azimut)+Cq*Cos(GetProfile(i)^.Azimut);
   Cx:=Cx+Crr*Cos(GetProfile(i)^.Azimut)-Cq*Sin(GetProfile(i)^.Azimut);
   end;
  Ch^.Moment:=M;
  Ch^.Time:=Time;
  Ch^.Cp:=M*bOmega*bR;
  Ch^.Cx:=Cx;
  Ch^.Cz:=Cz;
  Ch^.Corner:=GetProfile(1)^.Azimut;
  CharCollect^.Insert(Ch);
end;{TMain.StoreCharacteristic}
procedure TMain.TheoremaThomsona;
var
    i:integer;
begin
  If (IsItSetFlag(Option,moDissipation) and
     not(ISItSetFlag(Option,moNotFreeCyclon)) and
       not(ISITSetFlag(Option,moIdealFluid))) then
     for i:=1 to CountProfil do GetProfile(i)^.DissipationFirstTime;
end;
procedure TMain.TimeDissipation;
var i:integer;
    CF:PCyclon;
begin
   If (IsItSetFlag(Option,moDissipationTime) and
     not(ISItSetFlag(Option,moNotFreeCyclon)) and
       not(ISITSetFlag(Option,moIdealFluid))) then begin
         for i:=1 to CountCF do begin
           CF:=GetGlobalCF(i);
           if ISItSetFlag(CF^.Option,ocOld) then
             CF^.Cyclon:=CF^.Cyclon*KoeffDissipation;
           end;
           end;
end;
procedure TMain.DelSmallCyclon;
var Yes:boolean;
    i:integer;
    CF:PCyclon;
begin
  repeat
   Yes:=true;
   for i:=1 to CountCF do begin
    CF:=GetGlobalCF(i);
    If ISItSetFlag(CF^.Option,ocOld) then begin
      if Abs(CF^.Cyclon) <= SmallCyclon then begin
        DelGlobalCF(i);
        Yes:=false;
        break;
        end;end;
    end;
  until Yes;
end;
constructor TCharact.Load(var S:TStream);
begin
  S.Read(Moment,SizeOf(Moment));
  S.Read(Corner,SizeOf(Corner));
  S.Read(Time,SizeOf(Time));
  S.Read(Cr,SizeOf(Cr));
  S.Read(Cq,SizeOf(Cq));
  S.Read(Cx,SizeOf(Cx));
  S.Read(Cz,SizeOf(Cz));
  S.Read(Cp,SizeOf(Cp));
end;
procedure TCharact.Store(var S:TStream);
begin
  S.Write(Moment,SizeOf(Moment));
  S.Write(Corner,SizeOf(Corner));
  S.Write(Time,SizeOf(Time));
  S.Write(Cr,SizeOf(Cr));
  S.Write(Cq,SizeOf(Cq));
  S.Write(Cx,SizeOf(Cx));
  S.Write(Cz,SizeOf(Cz));
  S.Write(Cp,SizeOf(Cp));
end;
function TCharCollect.GetMoment_Corner:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Corner*180/pi);
    F^.PutY(i+1,PCharact(At(i))^.Moment);
   end;
   GetMoment_Corner:=F;
end;
function TCharCollect.GetMoment_Time:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Time);
    F^.PutY(i+1,PCharact(At(i))^.Moment);
   end;
   GetMoment_Time:=F;
end;

function TCharCollect.GetCp_Corner:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Corner*180/pi);
    F^.PutY(i+1,PCharact(At(i))^.Cp);
   end;
   GetCp_Corner:=F;
end;
function TCharCollect.GetCp_Time:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Time);
    F^.PutY(i+1,PCharact(At(i))^.Cp);
   end;
   GetCp_Time:=F;
end;
function TCharCollect.GetMiddleCp:real;
var
   F:PFunction;
   i:integer;
begin
   F:=GetCp_Time;
   if (F^.GetX(F^.EndH)-F^.GetX(F^.BeginH)) = 0 then
   GetMiddleCP:=F^.GetY(F^.EndH)
   else
   GetMiddleCp:=IntTrapecia(F)/(F^.GetX(F^.EndH)-F^.GetX(F^.BeginH));
end;
function TCharCollect.GetMiddleMoment:real;
var
   F:PFunction;
   i:integer;
begin
   F:=GetMoment_Time;
   if (F^.GetX(F^.EndH)-F^.GetX(F^.BeginH)) = 0 then
   GetMiddleMoment:=F^.GetY(F^.BeginH)
   else
   GetMiddleMoment:=IntTrapecia(F)/(F^.GetX(F^.EndH)-F^.GetX(F^.BeginH));
end;
function TCharCollect.GetCz_Corner:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Corner*180/pi);
    F^.PutY(i+1,PCharact(At(i))^.Cz);
   end;
   GetCz_Corner:=F;
end;
function TCharCollect.GetCz_Time:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Time);
    F^.PutY(i+1,PCharact(At(i))^.Cz);
   end;
   GetCz_Time:=F;
end;
function TCharCollect.GetCx_Corner:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Corner*180/pi);
    F^.PutY(i+1,PCharact(At(i))^.Cx);
   end;
   GetCx_Corner:=F;
end;
function TCharCollect.GetCx_Time:PFunction;
var
   F:PFunction;
   i:integer;
   Cc:real;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    Cc:=PCharact(At(i))^.Time;
    F^.PutX(i+1,Cc);
    F^.PutY(i+1,PCharact(At(i))^.Cx);
   end;
   GetCx_Time:=F;
end;
function TCharCollect.GetMiddleCz:real;
var
   F:PFunction;
   i:integer;
begin
   F:=GetCz_Time;
   if (F^.GetX(F^.EndH)-F^.GetX(F^.BeginH)) = 0 then
   GetMiddleCz:=F^.GetY(F^.BeginH)
   else
   GetMiddleCz:=IntTrapecia(F)/(F^.GetX(F^.EndH)-F^.GetX(F^.BeginH));
end;
function TCharCollect.GetMiddleCx:real;
var
   F:PFunction;
   i:integer;
begin
   F:=GetCx_Time;
   if (F^.GetX(F^.EndH)-F^.GetX(F^.BeginH)) = 0 then
   GetMiddleCx:=F^.GetY(F^.BeginH)
   else
   GetMiddleCx:=IntTrapecia(F)/(F^.GetX(F^.EndH)-F^.GetX(F^.BeginH));
end;
function TCharCollect.GetCr_Corner:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Corner*180/pi);
    F^.PutY(i+1,PCharact(At(i))^.Cr);
   end;
   GetCr_Corner:=F;
end;
function TCharCollect.GetCr_Time:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Time);
    F^.PutY(i+1,PCharact(At(i))^.Cr);
   end;
   GetCr_Time:=F;
end;
function TCharCollect.GetCq_Corner:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Corner*180/pi);
    F^.PutY(i+1,PCharact(At(i))^.Cq);
   end;
   GetCq_Corner:=F;
end;
function TCharCollect.GetCq_Time:PFunction;
var
   F:PFunction;
   i:integer;
begin
   F:=New(PFunction,Init(Owner^.Time));
   for i:=0 to F^.EndH-1 do begin
    F^.PutX(i+1,PCharact(At(i))^.Time);
    F^.PutY(i+1,PCharact(At(i))^.Cq);
   end;
   GetCq_Time:=F;
end;
begin
end.