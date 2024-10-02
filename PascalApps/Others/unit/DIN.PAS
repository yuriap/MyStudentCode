unit Din;
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
       constructor Init(V1,V2,H1,H2:integer);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       destructor Done;virtual;
       function Get(i,j:integer):real;virtual;
       procedure Put(i,j:integer;NewElement:real);virtual;
       end;
   PBuffer = ^TBuffer;
   TBuffer = object(TMatrix)
       Color:word;
       Labels:string[7];
       constructor Init(Lenght:integer);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       function GetX(i:integer):real;
       function GetY(i:integer):real;
       procedure PutX(i:integer;X:real);
       procedure PutY(i:integer;Y:real);
       end;

   PFunction = ^TFunction;
   TFunction = object(TBuffer)
       function Get_Y_X(X:real):real;
       function Search(Argument:real;StrNum:integer):integer;
       function Approx(X1,Y1,X2,Y2,X:real):real;
       end;
Const
   RMatrix : TStreamRec = (
      ObjType : 10000;
      VmtLink: Ofs(TypeOf(TMatrix)^);
      Load:@TMatrix.Load;
      Store:@TMatrix.Store);
   RBuffer : TStreamRec = (
      ObjType : 10001;
      VmtLink: Ofs(TypeOf(TBuffer)^);
      Load:@TBuffer.Load;
      Store:@TBuffer.Store);
   RFunction : TStreamRec = (
      ObjType : 10002;
      VmtLink: Ofs(TypeOf(TFunction)^);
      Load:@TFunction.Load;
      Store:@TFunction.Store);

procedure RegisterDinamic;
implementation
procedure RegisterDinamic;
begin
  RegisterType(RMatrix);
  RegisterType(RBuffer);
  RegisterType(RFunction);
end;
constructor TMatrix.Init(V1,V2,H1,H2:integer);
begin
  inherited init;
  BeginV:=V1;
  EndV:=V2;
  BeginH:=H1;
  EndH:=H2;
  N:=V2-V1+1;
  M:=H2-H1+1;
  Size:=6;
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
function TMatrix.Get(i,j:integer):real;
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+M*(i-BeginV)*Size+(j-BeginH)*Size);
  Get:=real(S^);
end;
procedure TMatrix.Put(i,j:integer;NewElement:real);
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+M*(i-BeginV)*Size+(j-BeginH)*Size);
  real(S^):=NewElement;
end;
{***********************************}
constructor TBuffer.Init(Lenght:integer);
begin
  inherited Init(1,2,1,Lenght);
end;
constructor TBuffer.Load;
begin
  Inherited Load(S);
  S.Read(Labels,SizeOf(Labels));
  S.Read(Color,SizeOf(Color));
end;
procedure TBuffer.Store;
begin
  Inherited Store(S);
  S.Write(Labels,SizeOf(Labels));
  S.Write(Color,SizeOf(Color));
end;
function TBuffer.GetX(i:integer):real;
begin
  GetX:=Get(1,i);
end;
function TBuffer.GetY(i:integer):real;
begin
  GetY:=Get(2,i);
end;
procedure TBuffer.PutX(i:integer;X:real);
begin
  Put(1,i,X);
end;
procedure TBuffer.PutY(i:integer;Y:real);
begin
  Put(2,i,Y);
end;
{************************************}
function TFunction.Get_Y_X(X:real):real;
var Num : integer;
begin
  Num:=Search(X,1);
  If Num < EndH then
  Get_Y_X:=Approx(GetX(Num),GetY(Num),GetX(Num+1),GetY(Num+1),X)
  else
  Get_Y_X:=GetY(M);
end;
function TFunction.Search(Argument:real;StrNum:integer):integer;
var i:integer;
begin
  For i:=BeginH to EndH-1 do begin
   If (Get(StrNum,i) <= Argument)
      and
      (Get(StrNum,i+1) > Argument)Then
     begin
     Search:=i;
     Exit;
     end;
     end;
     Search:=EndH;
end;
function TFunction.Approx(X1,Y1,X2,Y2,X:real):real;
begin
  if Abs(X2-X1) = 0 Then Approx:=Y1
    else
      Approx:=(Y2-Y1)*(X-X1)/(X2-X1)+Y1;
end;

begin
end.
