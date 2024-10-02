program Collaps;
uses dbtypes, objects;
var Stream:PBufStream;
    F:text;
    S:string;
    Mem:longInt;
begin
  Mem:=MemAvail;
  Assign(F,'dht_1.txt');
  Reset(F);
  DBCollection:=New(PCollection,Init(200,20));
  Stream:=New(PBufStream,Init('dhelp.stm',stCreate,2048));
  {******************************}
  Readln(F,S);
  repeat
  if (Copy(S,1,8) = 'Свойство') or (Copy(S,1,5) = 'Метод') then
   begin
   DBRecord:=New(PDBRecord,Init);
   DBRecord^.What:=S;
   Readln(F,S);
   DBRecord^.Where:=S;
   Readln(F,S);
   DBRecord^.Declaration:=S;
   end
   else
   begin
   DBRecord^.AddString(S);
   end;
  Readln(F,S);
  if (Copy(S,1,8) = 'Свойство') or (Copy(S,1,5) = 'Метод') then
   begin
    DBCollection^.Insert(DBRecord);
   end;
  until Eof(F);
  DBCollection^.Insert(DBRecord);
  {******************************}
  Close(F);
  Stream^.Put(DBCollection);
  Dispose(DBCollection,Done);
  Dispose(Stream,Done);
  Writeln('Баланс памяти: ',Mem,':',MemAvail);
end.