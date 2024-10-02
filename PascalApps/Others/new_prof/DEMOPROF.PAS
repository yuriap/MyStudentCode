program DemoProf;
uses Graph,Profile,ProfView,ProfComm;
var
 i:integer;
 grDriver: Integer;
 grMode: Integer;
 ErrCode: Integer;
 PRec:PProfileRec;
 VRec:TViewRec;
 Profiles:PProfile;
 Viewer:PProfViewer;
 Memory:LongInt;
begin
 Memory:=MemAvail;
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin
   Writeln('Graphics error:', GraphErrorMsg(ErrCode));
   Exit;
 end;
 PRec:=New(PProfileRec);
 With PRec^ Do begin
   b:=1;
   t:=0;
   dt:=0.1;
   N:=6;
   NFree:=20;
   NBreak:=2;
   Plase.X:=0;
   Plase.Y:=0;
   end;
  Profiles:=New(PProfile,Init(1,PRec));
  With VRec Do begin
     MX:=100;
     MY:=100;
     DX:=300;
     DY:=150;
     For i:=0 to 5 do Col[i]:=5-i
     end;
   Viewer:=New(PProfViewer,Init(VRec));
   Viewer^.Draw(Profiles);
   readln;
   CloseGraph;
   Dispose(Viewer,Done);
   Dispose(Profiles,Done);
   Writeln('Баланс кучи ',Memory,':',MemAvail);
end.
