program TestBoun;
uses TesBUnit,ProGraph,ProfDin,ProfComm,ProBound,Graph;
begin
Mem:=MemAvail;
RegisterDinamic;
 StartGraph;
 MakeGraphRec(GRec);
 G:=New(PGraphic,Init(GRec));
{***************************************}
  MS:=New(PMainSetka,Init(Norm,Tang));
  CS:=New(PCompSetka,Init(Norm,Tang));
  MakeBoundRec(BRec);
  PutBoundaryValue(MS,CS,BRec);
  BL:=New(PBoundLayer,Init(BRec));
  BL^.InstallSetka(MS,CS);
  BL^.Execute;
  Dispose(BL,Done);
{***************************************}
 Buf:=MakeMainGor(Norm+1);
 PutBufParam(Buf,'MN0');
 G^.InsertBuffer(Buf);
{ Buf:=MakeMainNorm(1);
 PutBufParam(Buf,'MN1');
 G^.InsertBuffer(Buf);
 Buf:=MakeMainNorm(10);
 PutBufParam(Buf,'MN10');
 G^.InsertBuffer(Buf);
 Buf:=MakeMainNorm(20);
 PutBufParam(Buf,'MN20');
 G^.InsertBuffer(Buf);
 Buf:=MakeMainNorm(30);
 PutBufParam(Buf,'MN30');
 G^.InsertBuffer(Buf);
 {*******************}
 ViewBuffer;
 Dispose(G,Done);
 DoneGraph;
 Dispose(MS,Done);
 Dispose(CS,Done);
Writeln('Баланс ',Mem,':',MemAvail);
end.