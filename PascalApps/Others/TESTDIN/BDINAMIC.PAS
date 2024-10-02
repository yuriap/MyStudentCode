unit BDinamic;
interface
uses Objects;
type
    PMatrix = ^TMatrix;
    TMatrix = object
       P : pointer;{указатель на блок}
       SegP : word;{сегмент блока}
       OfsP : word;{смещение блока}
       N,M  : word;{размерность матрицы}
       constructor Init(NewN,NewM:word);
       destructor Done;virtual;
       procedure Error;virtual;
       function Get(i,j:word):real;virtual;
       procedure Put(i,j:word;NewElement:real);virtual;
       end;
implementation
constructor TMatrix.Init(NewN,NewM:word);
begin
  N:=NewN;
  M:=NewM;
  If N*M > 65535 div 6 then begin Error;Halt(0);end;
  GetMem(P,N*M*6);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
end;
destructor TMatrix.Done;
begin
  FreeMem(P,N*M*6);
end;
procedure TMatrix.Error;
begin
  Writeln('Error in heap operation');
end;
function TMatrix.Get(i,j:word):real;
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+M*(i-1)*6+(j-1)*6);
  Get:=real(S^);
end;
procedure TMatrix.Put(i,j:word;NewElement:real);
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+M*(i-1)*6+(j-1)*6);
  real(S^):=NewElement;
end;
{***********************************}
begin
end.
