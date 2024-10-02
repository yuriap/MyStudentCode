unit Profile;
interface
uses Objects,ProfComm,ProfBase,ProfCycl,ProfCAdd,ProfCP,ProBreak;
type
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
implementation
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
