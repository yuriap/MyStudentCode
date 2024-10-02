program Blaz002;
uses Blaz001;
var
  Memory:LongInt;
begin
   Memory:=MemAvail;
     MyApp:=New(PApp,Init);
     MyApp^.Run;
     Dispose(MyApp,Done);
   Writeln('Баланс кучи: ',Memory,':',MemAvail);
end.
