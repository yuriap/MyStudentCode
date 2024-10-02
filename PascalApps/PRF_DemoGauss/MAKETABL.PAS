program MakeTabl;
uses Objects,ProfDin,Dos,TesBUnit,ProGraph,Graph;
var Fi,FiStrih:PFunction;
    S:PBufStream;
    F:TResourceFile;
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
begin
  RegisterDinamic;
  S:=New(PBufStream,Init('tablfunc.tvr',stCreate,2048));
  F.Init(S);
  BlaziusBoundValue(FiStrih,Fi);
  F.Put(FiStrih,'BlazMain');
  F.Put(Fi,'BlazComp');
  Dispose(Fi,Done);
  Dispose(FiStrih,Done);
  BeloBoundValue(FiStrih,Fi);
  {********************}
{  StartGraph;
  MakeGraphRec(GRec);
  G:=New(PGraphic,Init(GRec));
  PutBufParam(FiStrih,'F1');
  G^.InsertBuffer(FiStrih);
  SetGraphMode(grMode);
  G^.Execute;
  Dispose(G,Done);
  DoneGraph;
  {********************}

  F.Put(FiStrih,'BeloMain');
  F.Put(Fi,'BeloComp');
  Dispose(Fi,Done);
  Dispose(FiStrih,Done);
  F.Done;
  Writeln('Ok!!!');
end.