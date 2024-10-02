program TestFunc;
uses ProfDin,ProGraph,Graph;
const Len = 100;
var
  F:PFunction;
  B,B1:PBuffer;
  G:PGraphic;
  i:integer;
  x,y:real;
  dx:real;
  Mem:LongInt;
begin
Mem:=MemAvail;
  F:=New(PFunction,Init(Len));
  B:=New(PBuffer,Init(Len*2));
  B^.Labels:='Точный';
  B^.Color:=1;
  B1:=New(PBuffer,Init(Len*2));
  B1^.Labels:='Approx';
  B1^.Color:=1;
  dx:=2*Pi/(Len-1);
  x:=0;
  For i:=1 to len do begin
  y:=1*Sin(x);
  F^.PutX(i,x);
  F^.PutY(i,y);
  x:=x+dx;
  end;
  dx:=2*Pi/(2*Len-1);
  x:=0;
  For i:=1 to len*2 do begin
  y:=1*Sin(x);
  B^.PutX(i,x);
  B^.PutY(i,y);
  x:=x+dx;
  end;
{  Writeln('  X        Y;       X        Y');}
  For i:=1 to len*2 do begin
  x:=B^.GetX(i);
  B1^.PutX(i,x);
  B1^.PutY(i,-2*F^.Get_Y_X(x));
{  Writeln(B^.GetX(i):8:4,' ',B^.GetY(i):8:4,' ',B1^.GetX(i):8:4,' ',
          B1^.GetY(i):8:4);}
  end;
{  Readln;}
with GraphicRec do begin
     MasX:='70';
     MasY:='100';
     StepX:='1';
     StepY:='0.2';
     X:='50';
     Y:='50';
     XName:='Arg';
     YName:='Func';
     Title:='Рис. 1. Грачи прилетели, воробьи тоже';
      Color[2]:=1;
      Color[3]:=1;
      Color[1]:=1;
      Color[0]:=0;
      OptionMas:=0;
     end;
 StartGraph;
 G:=New(PGraphic,Init(GraphicRec));
 G^.InsertBuffer(B);
 G^.InsertBuffer(B1);
 SetGraphMode(grMode);
 G^.Execute;
 Dispose(G,Done);
 {********************}
 Dispose(F,Done);
{ Dispose(B,Done);
 Dispose(B1,Done);}
 DoneGraph;
Writeln('Баланс ',Mem,':',MemAvail);
end.