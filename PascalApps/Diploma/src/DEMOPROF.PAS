program DemoProf;
uses Crt,Objects,Graph,Profile,ProfView,ProfComm,StrmErr,ProfDin,ProfMain,
      ProGraph,ProBound,ProMain1;
var
 G:PGraphic;
 B:PFunction;
 D:PBuffer;
 Buf:PBuffer;
 GRec:TGrRec;
 VR:TViewRec;
 Viewer:PViewer;
 i,j:integer;
 MRec:PMainRec;
 Main:PMain1;
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
   Option:=moNoOption;
{   Option:=moAutoBreak;}
   b:=1;
   dt:=0.1;
   R:=1;
   Potok.ProX:=1;
   Potok.ProY:=0;
   Omega:=0;{2*pi/4}
   Betta0:=pi/2;
   Nu:=1.01e-6;
   MaxTime:=1;
   FileMapContur:='sphire.map';
   With ProfRecPtr^ do begin
      CountCP:=20;
      CornerSys:=-1*pi/18;{-1*pi/6;}
      NFree:=20;
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
  RegisterMain1;
  InitViewRec(VR);

  {****************************************}
  MRec:=InitMainRec;
  Main:=New(PMain1,Init(MRec^));
  Viewer:=New(PViewer,Init(VR,Main));
  Main^.Execute;
  {****************************************}
{  S:=NEw(PMsgStream,Init('main.tmp',stCreate,1024));
  S^.Put(Main);
  Dispose(S,Done);
  Dispose(Main,Done);
  S:=NEw(PMsgStream,Init('main.tmp',stOpenRead,1024));
  Main:=PMain1(S^.Get);
  Dispose(S,Done);
{  Main^.Execute;}
  Writeln(StartGraph);
    SetGraphMode(grMode);
   Viewer^.Main:=Main;
   Viewer^.Execute;
   REstoreCrtMode;

  MakeGraphRec(GRec);
  G:=New(PGraphic,Init(GRec));
  D:=Main^.Get_Delta_X(1);
  D^.Color:=1;
  D^.labels:='U';
  G^.InsertBuffer(D);
  ViewBuffer;
  Dispose(G,Done);
  DoneGraph;
  {*****************************************}
  Writeln('Cp: ',Main^.GetMiddleCP);
  {*****************************************}
   Dispose(Main,Done);
   Dispose(MRec^.ProfRecPtr);
   Dispose(MRec^.BoundRec);
   Dispose(MRec);
   Dispose(Viewer,Done);
   Writeln('Баланс кучи ',Memory,':',MemAvail);
end.
