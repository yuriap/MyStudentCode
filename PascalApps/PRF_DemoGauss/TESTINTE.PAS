program TestInte;
Uses ProfDin,ProGraph,TesBUnit;
const Len=100;
var
   Buf:PBuffer;
   x,dx,y:real;
   i:integer;
begin
 StartGraph;
 MakeGraphRec(GRec);
 G:=New(PGraphic,Init(GRec));
 Buf:=New(PBuffer,Init(Len));
 i:=1;
 dx:=(1-0)/(len-1);
 x:=0;
 repeat
   y:=exp(x);
   Buf^.PutX(i,x);
   Buf^.PutY(i,y);
   x:=x+dx;
   Inc(i);
 until i > len;
 PutBufParam(Buf,'Функция');
 G^.InsertBuffer(Buf);
 {*******************}
 ViewBuffer;
 DoneGraph;
 Writeln('Интеграл: ',IntTrapecia(Buf));
 Dispose(G,Done);
 readln;
end.