Unit ImiVideo;

Interface
Uses Objects,Graph,Crt;
 Var
     Screen : Pointer;
 Type
      PVideoObj = ^TVideoObj;
      TVideoObj = object(TObject)
          function VideoMemory:Longint;
          procedure SaveScreen;
          procedure RestoreScreen;
          end;
var
 grDriver: Integer;
 grMode: Integer;
 ErrCode: Integer;

 Procedure InitGVideo;



 Implementation
 procedure TVideoObj.SaveScreen;
 begin
   GetMem(Screen,4000);
   Move(Mem[VideoMemory:0],Screen^,4000);
 end;

 function TVideoObj.VideoMemory;
 begin
   VideoMemory:=SegB800;
   If Mem[Seg0040:$0049] = 7 Then VideoMemory:=SegB000;
 end;
 procedure TVideoObj.RestoreScreen;
 begin
   If Screen = nil Then Exit;
   Move(Screen^,Mem[VideoMemory:0],4000);
 End;
 Procedure InitGVideo;
begin
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode = grOk then
 begin  { Do graphics }
   Line(0, 0, GetMaxX, GetMaxY);
   ReadKey;
   CloseGraph;
 end
 else
   Writeln('Graphics error:', GraphErrorMsg(ErrCode));
end;


 begin
 end.