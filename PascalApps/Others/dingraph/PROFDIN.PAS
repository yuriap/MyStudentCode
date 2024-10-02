unit ProfDin;
interface
uses Objects;
type
    PMatrix = ^TMatrix;
    TMatrix = object(TObject)
       P : pointer;{указатель на блок}
       SegP : word;{сегмент блока}
       OfsP : word;{смещение блока}
       Size:byte;{размер переменной}
       BeginV,EndV:Integer;{индексация по вертикали}
       BeginH,EndH:integer;{индексация по горизонтали}
       N,M  : word;{размерность матрицы}
       constructor Init(V1,V2,H1,H2:integer;ASize:Byte);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       destructor Done;virtual;
       function Get(i,j:word):real;virtual;
       procedure Put(i,j:word;NewElement:real);virtual;
       end;
    PVector = ^TVector;
    TVector = object(TObject)
       P : pointer;{указатель на блок}
       SegP : word;{сегмент блока}
       OfsP : word;{смещение блока}
       N  : word;{размерность вектора}
       BeginH,EndH:integer;{индексация вектора}
       Size:byte;{размер переменных}
       constructor Init(H1,H2:word;ASize:byte);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       destructor Done;virtual;
       function Get(i:word):real;virtual;
       procedure Put(i:word;NewElement:real);virtual;
       end;
Const
   RVector : TStreamRec = (
      ObjType : 1001;
      VmtLink: Ofs(TypeOf(TVector)^);
      Load:@TVector.Load;
      Store:@TVector.Store);
   RMatrix : TStreamRec = (
      ObjType : 1002;
      VmtLink: Ofs(TypeOf(TMatrix)^);
      Load:@TMatrix.Load;
      Store:@TMatrix.Store);
implementation
constructor TMatrix.Init(V1,V2,H1,H2:integer;ASize:Byte);
begin
  inherited init;
  N:=V2-V1+1;
  M:=H2-H1+1;
  Size:=ASize;
  GetMem(P,N*M*Size);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
end;
constructor TMatrix.Load(var S:TStream);
begin
  S.Read(Size,SizeOf(Size));
  S.Read(BeginV,SizeOf(BeginV));
  S.Read(EndV,SizeOf(EndV));
  S.Read(BeginH,SizeOf(BeginH));
  S.Read(EndH,SizeOf(EndH));
  S.Read(N,SizeOf(N));
  S.Read(M,SizeOf(M));
  GetMem(P,N*M*Size);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
  S.Read(P^,N*M*Size);
end;
procedure TMatrix.Store(var S:TStream);
begin
  S.Write(Size,SizeOf(Size));
  S.Write(BeginV,SizeOf(BeginV));
  S.Write(EndV,SizeOf(EndV));
  S.Write(BeginH,SizeOf(BeginH));
  S.Write(EndH,SizeOf(EndH));
  S.Write(N,SizeOf(N));
  S.Write(M,SizeOf(M));
  S.Write(P^,N*M*Size);
end;
destructor TMatrix.Done;
begin
  FreeMem(P,N*M*Size);
  inherited Done;
end;
function TMatrix.Get(i,j:word):real;
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+M*(i-1)*Size+(j-1)*Size);
  Get:=real(S^);
end;
procedure TMatrix.Put(i,j:word;NewElement:real);
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+M*(i-1)*Size+(j-1)*Size);
  real(S^):=NewElement;
end;
{***********************************}
constructor TVector.Init(H1,H2:word;ASize:byte);
begin
  inherited Init;
  N:=H2-H1+1;
  Size:=ASize;
  GetMem(P,N*Size);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
end;
constructor TVector.Load(var S:TStream);
begin
  S.Read(N,SizeOf(N));
  S.Read(BeginH,SizeOf(BeginH));
  S.Read(EndH,SizeOf(EndH));
  S.Read(Size,SizeOf(Size));
  GetMem(P,N*Size);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
  S.Read(P^,N*Size);
end;
procedure TVector.Store(var S:TStream);
var A:word;
begin
  S.Write(N,SizeOf(N));
  S.Write(BeginH,SizeOf(BeginH));
  S.Write(EndH,SizeOf(EndH));
  S.Write(Size,SizeOf(Size));
  S.Write(P^,N*Size);
end;

destructor TVector.Done;
begin
  FreeMem(P,N*Size);
  inherited Done;
end;
function TVector.Get(i:word):real;
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+(i-1)*Size);
  Get:=real(S^);
end;
procedure TVector.Put(i:word;NewElement:real);
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+(i-1)*Size);
  real(S^):=NewElement;
end;
begin
end.
