program DemoProf;
uses Crt,Objects,Graph,Profile,ProfView,ProfComm,StrmErr,ProfDin,ProfMain,
      ProGraph,ProBound;
var
 G:PGraphic;
 B:PFunction;
 Buf:PBuffer;
 GRec:TGrRec;
 VR:TViewRec;
 Viewer:PViewer;
 i,j:integer;
 MRec:PMainRec;
 Main:PMain;
 Memory:LongInt;
 S: PMsgStream;
 x:real;
procedure ViewBuffer;
begin
 SetGraphMode(grMode);
 G^.Execute;
 RestoreCrtMode;
end;
procedure MakeGraphRec(var aGRec:TGrRec);
begin
with aGRec do begin
     MasX:='100';
     MasY:='100';
     StepX:='0.2';
     StepY:='0.2';
     X:='50';
     Y:='50';
     XName:='Arg';
     YName:='Func';
      Color[2]:=4;
      Color[3]:=5;
      Color[1]:=14;
      Color[0]:=7;
      OptionMas:=0;
     end;
end;{MakeGraphRec}

function InitMainRec:PMainRec;
var
    MRec:PMainRec;
begin
 MRec:=New(PMainRec);
 MRec^.ProfRecPtr:=New(PProfileRec);
 MRec^.BoundRec:=New(PBRec);
 With MRec^ Do begin
   CountProfile:=1;
{   Option:=moNoOption;}
   Option:=moAutoBreak;
   b:=1;
   dt:=0.1;
   R:=1;
   Potok.ProX:=1;
   Potok.ProY:=0;
   Omega:=0;{2*pi/4}
   Betta0:=pi/2;
   Nu:=1.01e-6;
   MaxTime:=3;
   FileMapContur:='naca0012.map';
   With ProfRecPtr^ do begin
      CountCP:=40;
      CornerSys:=0;{-1*pi/6;}
      NFree:=4;
      Tang:=50;
      Norm:=20;
      MainPtr:=MRec;
      end;
   with BoundRec^ do begin
      Psi:=0.01;{малое положительное число для dU/dy при y=delta <= Psi}
      S:=0.5;{параметр усреднения}
      MaxIter:=30;{максимальное число итераций}
      parNevazka:=1;{величина невязки, %}
      MaxNevazka:=20;
      Option:=psNoFlag;{толщина ПС не корректируется}
      Prec:=2;
      Sloy:=0.15;
      end;
   end;
 InitMainRec:=MRec;
end;{InitProfRec}
procedure InitViewRec(var D:TViewRec);
begin
  With D Do begin
     MX:=300;
     MY:=300;
     DX:=50;
     DY:=220;
     For i:=0 to 5 do Col[i]:=i
     end;
end;{InitViewRec}
begin
 Memory:=MemAvail;
  {****************************************}
  RegisterMain;
  InitViewRec(VR);

  {****************************************}
  MRec:=InitMainRec;
  Main:=New(PMain,Init(MRec^));
  Viewer:=New(PViewer,Init(VR,Main));
  Main^.Execute;
  {****************************************}
{  S:=NEw(PMsgStream,Init('main.tmp',stCreate,1024));
  S^.Put(Main);
  Dispose(S,Done);
  S:=NEw(PMsgStream,Init('main.tmp',stOpenRead,1024));
  Main:=PMain(S^.Get);
  Dispose(S,Done);}

  Writeln(StartGraph);
   SetGraphMode(grMode);
   Viewer^.Execute;
   REstoreCrtMode;

  MakeGraphRec(GRec);
  G:=New(PGraphic,Init(GRec));
{  Buf:=New(PBuffer,Init(Main^.GetProfile(1)^.Main^.EndH+1));
  for i:=1 to Main^.GetProfile(1)^.Main^.EndH+1 do begin
   x:=Main^.GetProfile(1)^.Main^.Get_S(i-1);
   Buf^.PutX(i,x);
   x:=Main^.GetProfile(1)^.Main^.Get(20,i-1);
   Buf^.PutY(i,x);
   end;
  Buf^.Color:=5;
  Buf^.Labels:='W';
  G^.InsertBuffer(Buf);}
  G^.InsertBuffer(Main^.GetProfile(1)^.GetW);
  ViewBuffer;
  Dispose(G,Done);
  DoneGraph;

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
   CloseGraph;
   Dispose(Main,Done);
   Dispose(MRec^.ProfRecPtr);
   Dispose(MRec^.BoundRec);
   Dispose(MRec);
   Dispose(Viewer,Done);
   Writeln('Баланс кучи ',Memory,':',MemAvail);
end.
