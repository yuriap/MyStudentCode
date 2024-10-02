program ACollaps;
uses dbtypes, objects;
var Stream:PBufStream;
    F:text;
    S:string;
    i,j:integer;
    Mem:longint;
begin
  Mem:=MemAvail;
  Assign(F,'dht_2.txt');
  Rewrite(F);
  Stream:=New(PBufStream,Init('dhelp.stm',stOpenRead,2048));
  {******************************}
  DBCollection:=PCollection(Stream^.Get);
  for i:=0 to DBCollection^.Count-1 do
   begin
   DBRecord:=DBCollection^.At(i);
   Writeln(F,DBRecord^.What);
   Writeln(F,DBRecord^.Where);
   Writeln(F,DBRecord^.Declaration);
   for j:=0 to DBRecord^.Description^.Count-1 do
    begin
    Writeln(F,PStr(DBRecord^.Description^.At(j))^.S);
    end;
   end;
  {******************************}
  Close(F);
  Dispose(Stream,Done);
  Dispose(DBCollection,Done);
  Writeln('Баланс памяти: ',Mem,':',MemAvail);
end.