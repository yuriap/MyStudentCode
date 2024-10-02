program testbou1;
uses TesBUnit,ProGraph,ProfDin,ProfComm,ProBound,Graph;
var i:integer;
    Opt:word;
begin
Mem:=MemAvail;
  MS:=New(PMainSetka,Init(Norm,Tang));
  CS:=New(PCompSetka,Init(Norm,Tang));
  PutBoundaryValue(MS,CS,BRec);
  MakeBoundRec(BRec);
  BL:=New(PBoundLayer,Init(BRec));
  BL^.InstallSetka(MS,CS);
{  BL^.Execute;}
  BL^.Analizator;
  Writeln;
  For i:=0 to Tang do begin
   Opt:=BL^.MainSetka^.Options^.Get(i);
   Write('i=',i,' ');
   if (Opt and psKritical) = psKritical Then Write('KR ');
   if (Opt and psKriticalStec) = psKriticalStec Then Write('KR_Stec ');
   if (Opt and psFirst) = psFirst Then Write('1 ');
   if (Opt and psPositive) = psPositive Then Write('+ ');
   if (Opt and psNegative) = psNegative Then Write('- ');
   readln;
   end;
  Dispose(BL,Done);
 Dispose(MS,Done);
 Dispose(CS,Done);
Writeln('Баланс ',Mem,':',MemAvail);
end.