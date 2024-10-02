program Test;
uses collect;
var F:text;
    S:string;
    i,j:integer;
    Mem:longint;
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
  Reset(FileTopic);
  Assign(F,'dht_3.txt');
  Rewrite(F);
  {******************************}
  repeat
   ClearTopic(Topic);
   Read(FileTopic,Topic);
   Writeln(F,Topic.What);
   Writeln(F,Topic.Where);
   Writeln(F,Topic.Declaration);
   for i:=1 to 50 do
    begin
    if Topic.Memo[i] <> '' then
     Writeln(F,Topic.Memo[i]);
    end;
  until EOF(FileTopic);
  {******************************}
  Close(FileTopic);
  Close(F);
  Writeln('Баланс памяти: ',Mem,':',MemAvail);
end.