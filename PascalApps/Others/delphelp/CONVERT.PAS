program Convert;
uses dbtypes, objects, collect;
var Stream:PBufStream;
    F:text;
    S:string;
    i,j:integer;
    Mem:longint;
procedure ReadTopicFromStream(S:PDBRecord; var T:TTopic);
var j:integer;
begin
   T.What:=S^.What;
   T.Where:=S^.Where;
   T.Declaration:=S^.Declaration;
   for j:=0 to S^.Description^.Count-1 do
    begin
    T.Memo[j+1]:=PStr(S^.Description^.At(j))^.S;
    end;
end;
procedure ClearTopic(var T:TTopic);
var k:integer;
begin
 T.What:='';
 T.Where:='';
 T.Declaration:='';
 for k:=1 to 50 do T.Memo[k]:='';
end;

begin
  Mem:=MemAvail;
  Assign(FileTopic,'dht_2.ft');
  Rewrite(FileTopic);
  Stream:=New(PBufStream,Init('dhelp.stm',stOpenRead,2048));
  {******************************}
  DBCollection:=PCollection(Stream^.Get);
  for i:=0 to DBCollection^.Count-1 do
   begin
   DBRecord:=DBCollection^.At(i);
   ClearTopic(Topic);
   ReadTopicFromStream(DBRecord,Topic);
   Write(FileTopic,Topic);
   end;
  {******************************}
  Close(FileTopic);
  Dispose(Stream,Done);
  Dispose(DBCollection,Done);
  Writeln('Баланс памяти: ',Mem,':',MemAvail);
end.