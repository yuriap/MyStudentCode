program MakeTabl;
uses Objects,ProfDin,Dos,ProGraph,Graph,ProfComm;
var Fi,FiStrih:PFunction;
    S:PBufStream;
    F:TResourceFile;
    GREc:TGrRec;
    G:PGraphic;
Const
     Blazius:FNameStr='fi&fiblz.dat';
     Belocerkovskiy:FNameStr='fi&fi.dat';
procedure BlaziusBoundValue(var MainUsl,CompUsl:PFunction);
var
  fil:text;
  x,dx,y1,y2:real;
  N,i:integer;
begin
  Assign(Fil,Blazius);
  Reset(Fil);
  Readln(Fil,N);
  MainUsl:=New(PFunction,Init(N));
  CompUsl:=New(PFunction,Init(N));
  dx:=1/(N-1);x:=0;
  for i:=1 to N do begin
   Readln(fil,y1,y2);
   MainUsl^.PutX(i,x);
   MainUsl^.PutY(i,y1);
   CompUsl^.PutX(i,x);
   CompUsl^.PutY(i,y2);
   x:=x+dx;
   end;
end;{MakeGrUsl}
procedure BeloBoundValue(var MainUsl,CompUsl:PFunction);
var
  fil:text;
  x,dx,y1,y2:real;
  N,i:integer;
begin
  Assign(Fil,Belocerkovskiy);
  Reset(Fil);
  Readln(Fil,N);
  MainUsl:=New(PFunction,Init(N));
  CompUsl:=New(PFunction,Init(N));
  dx:=1/(N-1);x:=0;
  for i:=1 to N do begin
   Readln(fil,y1,y2);
   MainUsl^.PutX(i,x);
   MainUsl^.PutY(i,y1);
   CompUsl^.PutX(i,x);
   CompUsl^.PutY(i,y2);
   x:=x+dx;
   end;
end;{MakeGrUsl}
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
      Color[2]:=1;
      Color[3]:=4;
      Color[1]:=5;
      Color[0]:=7;
      OptionMas:=0;
     end;
end;{MakeGraphRec}

begin
  RegisterDinamic;
{  S:=New(PBufStream,Init('tablfunc.tvr',stCreate,2048));
  F.Init(S);
  BlaziusBoundValue(FiStrih,Fi);
  F.Put(FiStrih,'BlazMain');
  F.Put(Fi,'BlazComp');
  Dispose(Fi,Done);
  Dispose(FiStrih,Done);
  BeloBoundValue(FiStrih,Fi);
  {********************}
  StartGraph;
  MakeGraphRec(GRec);
  G:=New(PGraphic,Init(GRec));
  BeloBoundValue(FiStrih,Fi);
  FiStrih^.Labels:='FiStrih';
  Fi^.Labels:='Fi';
  FiStrih^.Color:=1;
  Fi^.Color:=2;
  G^.InsertBuffer(FiStrih);
  G^.InsertBuffer(Fi);
  SetGraphMode(grMode);
  G^.Execute;
  DoneGraph;
  {********************}
  S:=New(PBufStream,Init(Tablice,stCreate,2048));
  F.Init(S);
  F.Put(FiStrih,'BeloMain');
  F.Put(Fi,'BeloComp');
  F.Done;
  Dispose(G,Done);
  SoundTrac;
  Writeln('Ok Create The Tablice of Function.');
end.