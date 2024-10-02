program testGrap;
uses Prograph,Graph;
var
  Graphic:PGraphic;
  Buffer:PBuffer;
  Mem:LongInt;
  f:text;
  x,y:real;
  i:integer;
begin
Mem:=MemAvail;
with GraphicRec do begin
     MasX:='100';
     MasY:='100';
     StepX:='0.2';
     StepY:='0.2';
     X:='50';
     Y:='50';
     XName:='Arg';
     YName:='Func';
      Color[2]:=1;
      Color[3]:=5;
      Color[1]:=4;
      Color[0]:=7;
      OptionMas:=1;
     end;
 StartGraph;
 Graphic:=New(PGraphic,Init(GraphicRec));
 Buffer:=New(PBuffer,Init(31));
 Buffer^.Labels:='Firstis';
 Buffer^.Color:=14;
 Assign(f,'prof2.mpc');
 Reset(f);
 For i:=1 to 31 do begin
   Readln(f,x,y);
   Buffer^.PutX(i,x);
   Buffer^.PutY(i,y);
   end;
 Close(f);
 Graphic^.InsertBuffer(Buffer);

 Buffer:=New(PBuffer,Init(7));
 Buffer^.Labels:='Seconda';
 Buffer^.Color:=15;
 Assign(f,'testgra.dat');
 Reset(f);
 For i:=1 to 7 do begin
   Readln(f,x,y);
   Buffer^.PutX(i,x);
   Buffer^.PutY(i,y*0.7);
   end;
 Close(f);
 Graphic^.InsertBuffer(Buffer);
 {********************}
 SetGraphMode(grMode);
 Graphic^.Execute;
 {********************}
 Dispose(Graphic,Done);
 DoneGraph;
Writeln('Баланс ',Mem,':',MemAvail);
end.