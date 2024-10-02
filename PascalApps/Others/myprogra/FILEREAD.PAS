program fileRead;
var I:integer;
    C:array [1..2] of byte;
    F:file;
    RN,WN:word;
begin
 Assign(F,'proba.pas');
 reset(f,2);
 for i:=1 to FileSize(F) do begin
  BlockRead(F,C,1,RN);
  Write(C[1],C[2]);
  end;
 Close(F);
end.