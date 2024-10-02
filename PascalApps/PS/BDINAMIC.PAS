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
       procedure InitMatrix;virtual;
       function Get(i,j:word):real;virtual;
       procedure Put(i,j:word;NewElement:real);virtual;
       end;
    PZeroMatrix = ^TZeroMatrix;
    TZeroMatrix = object(TMatrix)
       procedure InitMatrix;virtual;
       function Get(i,j:word):real;virtual;
       procedure Put(i,j:word;NewElement:real);virtual;
       end;
    PVector = ^TVector;
    TVector = object(TObject)
       P : pointer;{указатель на блок}
       SegP : word;{сегмент блока}
       OfsP : word;{смещение блока}
       N  : word;{размерность вектора}
       Labels:string[5];{литерал вектора для TGraphic}
       Number:byte;{номер туда же}
       constructor Init(NewN:word);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       destructor Done;virtual;
       procedure Error;virtual;
       procedure InitVector;virtual;
       function Get(i:word):real;virtual;
       procedure Put(i:word;NewElement:real);virtual;
       end;

    PZeroVector = ^TZeroVector;
    TZeroVector = object(TVector)
       function Get(i:word):real;virtual;
       procedure Put(i:word;NewElement:real);virtual;
       procedure InitVector;virtual;
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       end;
Const
   RVector : TStreamRec = (
      ObjType : 1001;
      VmtLink: Ofs(TypeOf(TVector)^);
      Load:@TVector.Load;
      Store:@TVector.Store);
   RZeroVector : TStreamRec = (
      ObjType : 1002;
      VmtLink: Ofs(TypeOf(TZeroVector)^);
      Load:@TZeroVector.Load;
      Store:@TZeroVector.Store);
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
procedure TMatrix.InitMatrix;
var i,j:word;
    A:real;
    S:pointer;
begin
  for i:=1 to N do begin
   for j:=1 to M do begin
     Write('Введите ',i,' ',j,' элемент: ');
     Readln(A);
     Put(i,j,A);
     end;end;
end;
function TMatrix.Get(i,j:word):real;
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+N*(i-1)*6+(j-1)*6);
  Get:=real(S^);
end;
procedure TMatrix.Put(i,j:word;NewElement:real);
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+N*(i-1)*6+(j-1)*6);
  real(S^):=NewElement;
end;
{***********************************}
procedure TZeroMatrix.InitMatrix;
var i,j:word;
    A:real;
    S:pointer;
begin
  for i:=0 to N-1 do begin
   for j:=0 to M-1 do begin
     Write('Введите ',i,' ',j,' элемент: ');
     Readln(A);
     Put(i,j,A);
     end;end;
end;
function TZeroMatrix.Get(i,j:word):real;
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+N*i*6+j*6);
  Get:=real(S^);
end;
procedure TZeroMatrix.Put(i,j:word;NewElement:real);
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+N*i*6+j*6);
  real(S^):=NewElement;
end;

{***********************************}
constructor TVector.Init(NewN:word);
begin
  inherited Init;
  N:=NewN;
  If N > 65535 div 6 then begin Error;Halt(0);end;
  GetMem(P,N*6);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
{  InitVector;}
end;
constructor TVector.Load(var S:TStream);
begin
  S.Read(N,SizeOf(N));
  S.Read(Labels,SizeOf(Labels));
  GetMem(P,N*6);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
  S.Read(P^,N*6);
end;
procedure TVector.Store(var S:TStream);
var A:word;
begin
  S.Write(N,SizeOf(N));
  S.Write(Labels,SizeOf(Labels));
  S.Write(P^,N*6);
end;

destructor TVector.Done;
begin
  FreeMem(P,N*6);
  inherited Done;
end;
procedure TVector.Error;
begin
  Writeln('Error in heap operation');
end;
procedure TVector.InitVector;
var i:word;
    A:real;
    S:pointer;
begin
  for i:=1 to N do begin
     Write('Введите ',i,' элемент: ');
     Readln(A);
     Put(i,A);
     end;
  Write('Введите литерал: ');
  Readln(Labels);
end;
function TVector.Get(i:word):real;
var
   S:pointer;
begin
  If i >= N+1 Then Error;
  S:=Ptr(SegP,OfsP+(i-1)*6);
  Get:=real(S^);
end;
procedure TVector.Put(i:word;NewElement:real);
var
   S:pointer;
begin
  If i > N Then begin Error;exit;end;
  S:=Ptr(SegP,OfsP+(i-1)*6);
  real(S^):=NewElement;
end;

{**********************************************}
constructor TZeroVector.Load(var S:TStream);
begin
  S.Read(N,SizeOf(N));
  S.Read(Labels,SizeOf(Labels));
  GetMem(P,N*6);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
  S.Read(P^,N*6);
end;
procedure TZeroVector.Store(var S:TStream);
var A:word;
begin
  S.Write(N,SizeOf(N));
  S.Write(Labels,SizeOf(Labels));
  S.Write(P^,N*6);
end;

function TZeroVector.Get(i:word):real;
var
   S:pointer;
begin
  If i >= N Then Error;
  S:=Ptr(SegP,OfsP+i*6);
  Get:=real(S^);
end;
procedure TZeroVector.Put(i:word;NewElement:real);
var
   S:pointer;
begin
  If i >= N Then begin Error;exit;end;
  S:=Ptr(SegP,OfsP+i*6);
  real(S^):=NewElement;
end;
procedure TZeroVector.InitVector;
var i:word;
    A:real;
    S:pointer;
begin
  for i:=0 to N-1 do begin
     Write('Введите ',i,' элемент: ');
     Readln(A);
     Put(i,A);
     end;
  Write('Введите литерал: ');
  Readln(Labels);
end;

begin
end.
