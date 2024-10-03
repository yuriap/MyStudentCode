unit ProfDin;
interface
uses Objects,ProfComm;
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
    PVector = ^TVector;
    TVector = object(TObject)
       P : pointer;{указатель на блок}
       SegP : word;{сегмент блока}
       OfsP : word;{смещение блока}
       N  : word;{размерность вектора}
       BeginH,EndH:integer;{индексация вектора}
       Size:byte;{размер переменных}
       constructor Init(H1,H2:integer);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       destructor Done;virtual;
       function Get(i:integer):real;
       procedure Put(i:integer;NewElement:real);
       end;
   POptMassiv = ^TOptMassiv;
   TOptMassiv = object(TVector)
       constructor Init(Lenght:word);
       function Get(i:integer):word;
       procedure Put(i:integer;NewElement:word);
       end;

    {карта описания профиля}
const
    nmX = 1;
    nmY = 2;
    nmS = 3;
    nmNX = 4;
    nmNY = 5;
    nmTX = 6;
    nmTY = 7;
type
    PMapProf = ^TMapProf;
    TMapProf = object(TMatrix)
       Options:POptMassiv;
       constructor Init(Lenght:integer);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       destructor Done;virtual;
       procedure PutFlag(Num:integer;F:word);
       procedure GetOptions(Num:integer;var Opt:word);
       function GetCountPoint:integer;
       function Search(Argument:real;StrNum:integer):integer;
       function Approx(X1,Y1,X2,Y2,X:real):real;
       procedure PutX(i:integer;X:real);
       procedure PutY(i:integer;Y:real);
       procedure PutS(i:integer;S:real);
       procedure PutNX(i:integer;NX:real);
       procedure PutNY(i:integer;NY:real);
       procedure PutTX(i:integer;TX:real);
       procedure PutTY(i:integer;TY:real);
       function GetX(i:integer):real;
       function GetY(i:integer):real;
       function GetS(i:integer):real;
       function GetMaxS:real;
       function GetNX(i:integer):real;
       function GetNY(i:integer):real;
       function GetTX(i:integer):real;
       function GetTY(i:integer):real;
       function Get_X_S(S:real):real;
       function Get_Y_S(S:real):real;
       function Get_NX_S(S:real):real;
       function Get_NY_S(S:real):real;
       function Get_TX_S(S:real):real;
       function Get_TY_S(S:real):real;
       end;
   PMainSetka = ^TMainSetka;
   TMainSetka = object(TMatrix)
       Options:POptMassiv;
       constructor Init(ForNorm,ForTang:integer);
       constructor Load(var S:TStream);
       procedure Store(var S:TStream);
       function Get_S(Norm:integer):real;
       procedure Put_S(Norm:integer;S:real);
       function Get_Tay(Norm:integer):real;
       procedure Put_Tay(Norm:integer;Tay:real);
       procedure PutFlag(Num:integer;Opt:word);
       procedure GetOptions(Num:integer;var Opt:word);
       destructor Done;virtual;
       end;
   PCompSetka = ^TCompSetka;
   TCompSetka = object(TMatrix)
       constructor Init(ForNorm,ForTang:integer);
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
{***************}
{Вычисление интеграла методом трапеций}
function IntTrapecia(F:PBuffer):real;
Const
   RVector : TStreamRec = (
      ObjType : idVector;
      VmtLink: Ofs(TypeOf(TVector)^);
      Load:@TVector.Load;
      Store:@TVector.Store);
   RMatrix : TStreamRec = (
      ObjType : idMatrix;
      VmtLink: Ofs(TypeOf(TMatrix)^);
      Load:@TMatrix.Load;
      Store:@TMatrix.Store);
   RMapProf : TStreamRec = (
      ObjType : idMapProf;
      VmtLink: Ofs(TypeOf(TMapProf)^);
      Load:@TMapProf.Load;
      Store:@TMapProf.Store);
   ROptMassiv : TStreamRec = (
      ObjType : idOptMassiv;
      VmtLink: Ofs(TypeOf(TOptMassiv)^);
      Load:@TOptMassiv.Load;
      Store:@TOptMassiv.Store);
   RMainSetka : TStreamRec = (
      ObjType : idMainSetka;
      VmtLink: Ofs(TypeOf(TMainSetka)^);
      Load:@TMainSetka.Load;
      Store:@TMainSetka.Store);
   RCompSetka : TStreamRec = (
      ObjType : idCompSetka;
      VmtLink: Ofs(TypeOf(TCompSetka)^);
      Load:@TCompSetka.Load;
      Store:@TCompSetka.Store);
   RBuffer : TStreamRec = (
      ObjType : idBuffer;
      VmtLink: Ofs(TypeOf(TBuffer)^);
      Load:@TBuffer.Load;
      Store:@TBuffer.Store);
   RFunction : TStreamRec = (
      ObjType : idFunction;
      VmtLink: Ofs(TypeOf(TFunction)^);
      Load:@TFunction.Load;
      Store:@TFunction.Store);

procedure RegisterDinamic;
implementation
procedure RegisterDinamic;
begin
  RegisterType(RVector);
  RegisterType(RMatrix);
  RegisterType(RMapProf);
  RegisterType(ROptMassiv);
  RegisterType(RMainSetka);
  RegisterType(RCompSetka);
  RegisterType(RBuffer);
  RegisterType(RFunction);
end;
function IntTrapecia(F:PBuffer):real;
var
   i:integer;
   S:real;
begin
   S:=0;
   with F^ do begin
   for i:=BeginH to EndH-1 do
    S:=S+(GetX(i+1)-GetX(i))*(GetY(i+1)+GetY(i))/2;
   end;{with}
   IntTrapecia:=S;
end;{IntTrapecia}
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
  If P = nil then Fail;
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
constructor TVector.Init(H1,H2:integer);
begin
  inherited Init;
  BeginH:=H1;
  EndH:=H2;
  N:=H2-H1+1;
  Size:=6;
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
function TVector.Get(i:integer):real;
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+(i-BeginH)*Size);
  Get:=real(S^);
end;
procedure TVector.Put(i:integer;NewElement:real);
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+(i-BeginH)*Size);
  real(S^):=NewElement;
end;
{**************************************}
constructor TMapProf.Init(Lenght:integer);
begin
  inherited Init(1,7,1,Lenght);
  Options:=New(POptMassiv,Init(Lenght));
end;
constructor TMapProf.Load(var S:TStream);
begin
  inherited Load(S);
  Options:=POptMassiv(S.Get);
end;
procedure TMapProf.Store(var S:TStream);
begin
  inherited Store(S);
  S.Put(Options);
end;
destructor TMapProf.Done;
begin
  Dispose(Options,Done);
  inherited Done;
end;
procedure TMapProf.PutFlag(Num:integer;F:word);
begin
  Options^.Put(Num,Options^.Get(Num) or F);
end;
procedure TMapProf.GetOptions(Num:Integer;var Opt:word);
begin
  Opt:=Options^.Get(Num);
end;
function TMapProf.GetCountPoint:integer;
var i:integer;
    Opt:word;
    Count:integer;
begin
  Count:=0;
  for i:=BeginH to EndH do begin
    GetOptions(i,Opt);
    if (Opt and moCPoint) = moCPoint Then Inc(Count);
    end;
  GetCountPoint:=Count;
end;
function TMapProf.Search(Argument:real;StrNum:integer):integer;
var i:integer;
begin
  For i:=BeginH to EndH-1 do begin{проверить с EndH-1. Было EndH}
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
function TMapProf.Approx(X1,Y1,X2,Y2,X:real):real;
begin
  if Abs(X2-X1) =0 Then Approx:=Y1
    else
      Approx:=(Y2-Y1)*(X-X1)/(X2-X1)+Y1;
end;
procedure TMapProf.PutX(i:integer;X:real);
begin
  Put(nmX,i,X);
end;
procedure TMapProf.PutY(i:integer;Y:real);
begin
  Put(nmY,i,Y);
end;
procedure TMapProf.PutS(i:integer;S:real);
begin
  Put(nmS,i,S);
end;
procedure TMapProf.PutNX(i:integer;NX:real);
begin
  Put(nmNX,i,NX);
end;
procedure TMapProf.PutNY(i:integer;NY:real);
begin
  Put(nmNY,i,NY);
end;
procedure TMapProf.PutTX(i:integer;TX:real);
begin
  Put(nmTX,i,TX);
end;
procedure TMapProf.PutTY(i:integer;TY:real);
begin
  Put(nmTY,i,TY);
end;
function TMapProf.GetX(i:integer):real;
begin
  GetX:=Get(nmX,i);
end;
function TMapProf.GetY(i:integer):real;
begin
  GetY:=Get(nmY,i);
end;
function TMapProf.GetS(i:integer):real;
begin
  GetS:=Get(nmS,i);
end;
function TMapProf.GetMaxS:real;
begin
  GetMaxS:=Get(nmS,EndH);
end;
function TMapProf.GetNX(i:integer):real;
begin
  GetNX:=Get(nmNX,i);
end;
function TMapProf.GetNY(i:integer):real;
begin
  GetNY:=Get(nmNY,i);
end;
function TMapProf.GetTX(i:integer):real;
begin
  GetTX:=Get(nmTX,i);
end;
function TMapProf.GetTY(i:integer):real;
begin
  GetTY:=Get(nmTY,i);
end;
function TMapProf.Get_X_S(S:real):real;
var Num : integer;
begin
  Num:=Search(S,nmS);
  If Num <> EndH Then
  Get_X_S:=Approx(GetS(Num),GetX(Num),GetS(Num+1),GetX(Num+1),S)
  else
  Get_X_S:=Approx(GetS(Num),GetX(Num),GetS(1),GetX(1),S);
end;
function TMapProf.Get_Y_S(S:real):real;
var Num : integer;
begin
  Num:=Search(S,nmS);
  If Num <> EndH then
  Get_Y_S:=Approx(GetS(Num),GetY(Num),GetS(Num+1),GetY(Num+1),S)
  else
  Get_Y_S:=Approx(GetS(Num),GetY(Num),GetS(1),GetY(1),S)
end;
function TMapProf.Get_NX_S(S:real):real;
var Num : integer;
begin
  Num:=Search(S,nmS);
  Get_NX_S:=GetNX(Num);
end;
function TMapProf.Get_NY_S(S:real):real;
var Num : integer;
begin
  Num:=Search(S,nmS);
  Get_NY_S:=GetNY(Num);
end;
function TMapProf.Get_TX_S(S:real):real;
var Num : integer;
begin
  Num:=Search(S,nmS);
  Get_TX_S:=GetTX(Num);
end;
function TMapProf.Get_TY_S(S:real):real;
var Num : integer;
begin
  Num:=Search(S,nmS);
  Get_TY_S:=GetTY(Num);
end;
{**************************************}
constructor TOptMassiv.Init(Lenght:word);
begin
  TObject.Init;
  BeginH:=0;
  EndH:=Lenght;
  N:=EndH-BeginH+1;
  Size:=SizeOf(word);
  GetMem(P,N*Size);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
end;
function TOptMassiv.Get(i:integer):word;
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+(i-BeginH)*Size);
  Get:=word(S^);
end;
procedure TOptMassiv.Put(i:integer;NewElement:word);
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+(i-BeginH)*Size);
  word(S^):=NewElement;
end;
{**************************************}
constructor TMainSetka.Init(ForNorm,ForTang:integer);
begin
   inherited Init(-2,ForNorm+1,0,ForTang);
   Options:=New(POptMassiv,Init(ForTang));
end;
constructor TMainSetka.Load(var S:TStream);
begin
  inherited Load(S);
  Options:=POptMassiv(S.Get);
end;
procedure TMainSetka.Store(var S:TStream);
begin
  inherited Store(S);
  S.Put(Options);
end;
function TMainSetka.Get_S(Norm:integer):real;
begin
  Get_S:=Get(-1,Norm);
end;
procedure TMainSetka.Put_S(Norm:integer;S:real);
begin
  Put(-1,Norm,S);
end;
function TMainSetka.Get_Tay(Norm:integer):real;
begin
  Get_Tay:=Get(-2,Norm);
end;
procedure TMainSetka.Put_Tay(Norm:integer;Tay:real);
begin
  Put(-2,Norm,Tay);
end;
procedure TMainSetka.PutFlag(Num:integer;Opt:word);
begin
  Options^.Put(Num,Options^.Get(Num) or Opt);
end;
procedure TMainSetka.GetOptions(Num:integer;var Opt:word);
begin
  Opt:=Options^.Get(Num);
end;
destructor TMainSetka.Done;
begin
  Dispose(Options,Done);
  inherited Done;
end;
{**************************************}
constructor TCompSetka.Init(ForNorm,ForTang:integer);
begin
  Inherited Init(0,ForNorm,0,ForTang);
end;
{**************************************}
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
