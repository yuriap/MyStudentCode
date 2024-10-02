unit Collect;
interface
type
  TMemo = array [1..50] of string[120];
  TTopic = record
   What,Where,Declaration:string;
   Memo:TMemo;
   end;
var
  Topic:TTopic;
  FileTopic: file of TTopic;
implementation
end.