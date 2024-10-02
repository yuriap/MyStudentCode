unit ProfMain;
interface
uses Dos,Objects,Profile,ProfComm,ProfDin;
type
   PMainRec = ^TMainRec;
   TMainRec = record
     CountProfile:word;
     b:real;
     dt:real;
     R:real;
     Betta0:real;{азимутальный угол первой лопасти}
     FileMapContur:FNameStr;
     ProfRecPtr:PProfileRec;
     end;

  PMain = ^TMain;
  TMain = object(TBasePoint)
      CountProfil:word;{колличество профилей}
      CountCP:word;{колличество контрольных точек на профиле}
      CountCF:word;{колл. свободных вихрей в потоке}
      b:real;{хорда}
      dt:real;{шаг по времени}
      R:real;{радиус ВК}
      Betta0:real;{азимут первой лопасти}
      Profiles:PCollection;
      Map:PMapProf;
      constructor Init(MainRec:TMainRec);
      constructor Load(var S:TStream);
      destructor Done;virtual;
      procedure Store(var S:TStream);
      function GetProfile(i:word):PProfile;
      function GetGlobalCP(i:word):PControlPoint;
      function GetGlobalCA(i:word):PCyclonAdd;
      function GetGlobalCF(i:word):PCyclon;
      procedure GetLeftPart;
      procedure GetRightPart;
      procedure GetIncogPart;
      procedure MiddleProcess;virtual;
      procedure Execute;
      end;
const
   RMain : TStreamRec = (
      ObjType : idMain;
      VmtLink: Ofs(TypeOf(TMain)^);
      Load:@TMain.Load;
      Store:@TMain.Store);
procedure RegisterMain;
implementation
procedure RegisterMain;
begin
  RegisterProfile;
  RegisterType(RMain);
end;

constructor TMain.Init;
var i:integer;
    PR:PProfile;
    PLase:TPoints;
    f:text;
    Len:integer;
    Lit:string[2];
    x,y,S:real;
    db:real;{азимутальный шаг лопастей}
begin
  CountProfil:=MainRec.CountProfile;
  Profiles:=New(PCollection,Init(CountProfil,0));
  CountCF:=0;
  b:=MainRec.b;
  dt:=MainRec.dt;
  R:=MainRec.R;
  Betta0:=MainRec.Betta0;
  Assign(f,MainRec.FileMapContur);
  {$I-}
  Reset(f);
  If IOResult <> 0 Then begin Beep; Halt(0);end;
  Readln(f,Len);
  If IOResult <> 0 Then begin Beep; Halt(0);end;
  Readln(f,CountCP);
  If IOResult <> 0 Then begin Beep; Halt(0);end;
  Map:=New(PMapProf,Init(Len));
  For i:=1 to Len do begin
    Readln(f,Lit,x,y,S);
  If IOResult <> 0 Then begin Beep; Halt(0);end;
    Map^.PutX(i,x);
    Map^.PutY(i,y);
    Map^.PutS(i,S);
    end;
  {$I+}
  MakeCos(Map);
  Close(f);
  with MainRec.ProfRecPtr^ do begin
    MapPtr:=Map;
    N:=CountCP;
    end;
  db:=2*pi/CountProfil;
  for i:=1 to CountProfil do begin
  MainRec.ProfRecPtr^.Azimut:=Betta0+(i-1)*db;
  PR:=New(PProfile,Init(i,MainRec.ProfRecPtr));
  PR^.PutOwner(@Self);
  Profiles^.Insert(PR);
  end;
end;
procedure TMain.Store(var S:TStream);
begin
   inherited Store(S);
   S.Write(CountProfil,SizeOf(CountProfil));
   S.Write(CountCP,SizeOf(CountCP));
   S.Write(CountCF,SizeOf(CountCF));
   S.Write(b,SizeOf(b));
   S.Write(dt,SizeOf(dt));
   S.Write(R,SizeOf(R));
   S.Write(Betta0,SizeOf(Betta0));
   S.Put(Profiles);
   S.Put(Map);
end;
constructor TMain.Load(var S:TStream);
var i:integer;
begin
   inherited Load(S);
   S.Read(CountProfil,SizeOf(CountProfil));
   S.Read(CountCP,SizeOf(CountCP));
   S.Read(CountCF,SizeOf(CountCF));
   S.Read(b,SizeOf(b));
   S.Read(dt,SizeOf(dt));
   S.Read(R,SizeOf(R));
   S.Read(Betta0,SizeOf(Betta0));
   Profiles:=PCollection(S.Get);
   Map:=PMapProf(S.Get);
   For i:=1 to CountProfil do
     GetProfile(i)^.PutOwner(@Self);
end;
destructor TMain.Done;
begin
  Dispose(Profiles,Done);
  Dispose(Map,Done);
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
var j:integer;
begin
  If i > CountProfil*CountCF Then GetGlobalCF:=nil
    else begin
    for j:=1 to CountProfil do begin
      if (i > CountCF*(j-1)) and (i <= CountCF*j)
        then
          GetGlobalCF:=GetProfile(j)^.GetCF(i-CountCF*(j-1));
    end;{for}
    end;{else}
end;
procedure TMain.GetLeftPart;
begin
end;
procedure TMain.GetRightPart;
begin
end;
procedure TMain.GetIncogPart;
begin
end;
procedure TMain.MiddleProcess;
begin
end;
procedure TMain.Execute;
begin
end;
begin
end.