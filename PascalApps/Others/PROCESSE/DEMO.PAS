program Demo;
uses Procing;
begin
  MyApp:=New(PApp,Init);
  MyApp^.Run;
  Dispose(MyApp,Done);
end.