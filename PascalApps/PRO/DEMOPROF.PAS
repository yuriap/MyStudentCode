program DemoProf;
uses Crt,Objects,Graph,Profile,ProfView,ProfComm,StrmErr,ProfDin,ProfMain;
var
 i,j:integer;
 grDriver: Integer;
 grMode: Integer;
 ErrCode: Integer;
 MRec:PMainRec;
 VRec:TViewRec;
 Main:PMain;
 Viewer:PViewer;
 CA:PCyclonAdd;
 CP:PControlPoint;
 Plase,Plase1:TPoints;
 Memory:LongInt;
 F:text;
 Az,dAz:real;
   S: PMsgStream;
{   Res:TResourceFile;}
procedure GraphInit;
begin
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin
   Writeln('Graphics error:', GraphErrorMsg(ErrCode));
   Halt(0);
 end;
end;{GraphInit}
function InitMainRec:PMainRec;
var
    MRec:PMainRec;
begin
 MRec:=New(PMainRec);
 MRec^.ProfRecPtr:=New(PProfileRec);
 With MRec^ Do begin
   CountProfile:=1;
   b:=1;
   dt:=0.1;
   R:=2;
   Betta0:=pi/2;
   FileMapContur:='prof2.mpc';
   With ProfRecPtr^ do begin
      CornerSys:=0;
      NFree:=20;
      MainPtr:=MRec;
      end;
   end;
 InitMainRec:=MRec;
end;{InitProfRec}
procedure InitViewRec(var D:TViewRec);
begin
  With D Do begin
     MX:=75;
     MY:=75;
     DX:=300;
     DY:=220;
     For i:=0 to 5 do Col[i]:=i
     end;
end;{InitViewRec}
begin
 Memory:=MemAvail;
  {****************************************}
  RegisterMain;
  {****************************************}
  MRec:=InitMainRec;
  Main:=New(PMain,Init(MRec^));
  {****************************************}
  dAz:=2*pi/10;
  For j:=1 to 11 do begin
     Main^.GetProfile(1)^.GetCoord(PLase1);
     Plase:=Plase1;
     Main^.GetProfile(1)^.ConvAbsLoc(Plase);
     Writeln('Profile: ','X = ',Plase1.X:8:6,' Y = ',Plase1.Y:8:6,
             ';X = ',Plase.X:8:6,' Y = ',Plase.Y:8:6);
   For i:=1 To Main^.CountProfil do begin
     Main^.GetProfile(i)^.Azimut:=Main^.GetProfile(i)^.Azimut+dAz;
     Main^.GetProfile(i)^.DigitNewPLase;
     end;
   end;
  readln;
  {****************************************}
{  Assign(f,'main.inf');
  ReWrite(F);
  Writeln(f,'Присоединенные вихри');
  Writeln(f,'Num ','X        Y        S        NX       NY       ',
           'TX       TY');
  For i:=1 to Main^.CountProfil*Main^.CountCP do begin
  CA:=Main^.GetGlobalCA(i);
  Writeln(f,i,' ',CA^.Coord.X:8:4,' ',
     CA^.Coord.Y:8:4,' ',
     CA^.S:8:4,' ',
     CA^.Norm.ProX:8:4,' ',
     CA^.Norm.ProY:8:4,' ',
     CA^.Tang.ProX:8:4,' ',
     CA^.Tang.ProY:8:4);end;
  Writeln(f,'Контрольные точки');
  Writeln(f,'Num ','X        Y        S        NX       NY       ',
           'TX       TY');
  For i:=1 to Main^.CountProfil*Main^.CountCP do begin
  CP:=Main^.GetGlobalCP(i);
  Writeln(f,i,' ',CP^.Coord.X:8:4,' ',
     CP^.Coord.Y:8:4,' ',
     CP^.S:8:4,' ',
     CP^.Norm.ProX:8:4,' ',
     CP^.Norm.ProY:8:4,' ',
     CP^.Tang.ProX:8:4,' ',
     CP^.Tang.ProY:8:4);end;
  Writeln(f,'Map');
  Writeln(f,' X        ','Y        ','S        ','NX       ','NY       ',
  'TX       ','TY');
  with Main^.GetProfile(1)^.Map^ do begin
  For i:=1 to M do
   Writeln(f,GetX(i):7:4,'  ',GetY(i):7:4,'  ',
           GetS(i):7:4,'  ',GetNX(i):7:4,'  ',GetNY(i):7:4,'  ',
           GetTX(i):7:4,'  ',GetTY(i):7:4);
  end;
  Close(f);
  {*****************************************}
{  InitViewRec(VRec);
  Viewer:=New(PViewer,Init(VRec));
  GraphInit;
  {*****************************************}
{  dAz:=2*pi/72;
  For j:=1 to 72 do begin
   Viewer^.Show(Main);
   Delay(200);
   Viewer^.Hide(Main);
   For i:=1 To Main^.CountProfil do begin
     Main^.GetProfile(i)^.Azimut:=Main^.GetProfile(i)^.Azimut+dAz;
     Main^.GetProfile(i)^.DigitNewPLase;
     end;
   end;
   REadln;
   {****************************************}
{   Viewer^.Show(Main);
   readln;
   Viewer^.Hide(Main);
   {****************************************}
{   S:=New(PMsgStream,Init('main.tvr',stCreate,1024));
   S^.Put(Main);
   Dispose(S,Done);
   Viewer^.Hide(Main);
   readln;
   Dispose(Main,Done);
   {****************************************}
{   SetColor(1);
   OutTextXY(100,20,'Загрузка из потока');
   S:=New(PMsgStream,Init('main.tvr',stOpenRead,1024));
   Main:=PMain(S^.Get);
   Viewer^.Show(Main);
   Dispose(S,Done);
   readln;
   Viewer^.Hide(Main);
   readln;
  {*****************************************}
{   CloseGraph;
   Dispose(Viewer,Done);}
   Dispose(Main,Done);
   Dispose(MRec^.ProfRecPtr);
   Dispose(MRec);
   Writeln('Баланс кучи ',Memory,':',MemAvail);
end.
