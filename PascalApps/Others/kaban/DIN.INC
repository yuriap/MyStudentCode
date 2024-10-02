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
