program comport;
const
  Long=136;{длина блока передачи}
type
  ComBlock = array [1..Long] of byte;{блок передачи}
var
  FBlock:file of ComBlock;{файловая переменная для передачи на плоттер}
  Block:ComBlock;
  i:integer;
begin
  Assign(FBlock,'COM2');
  Rewrite(FBlock);
  {**************}
  for i:=1 to long do Block[i]:=i;
  Write(FBlock,Block);
  {**************}
  Close(FBlock);
end.