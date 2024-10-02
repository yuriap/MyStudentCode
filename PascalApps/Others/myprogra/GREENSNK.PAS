program GreenSnk;
uses Snake;
var
  Dir:PDirector;
  Mem:LongInt;
begin
  Mem:=MemAvail;
  Dir:=New(PDirector,Init);
  Dir^.Run;
  Dispose(Dir,Done);
{ Write('Баланс кучи: ',Mem,':',MemAvail);}
end.