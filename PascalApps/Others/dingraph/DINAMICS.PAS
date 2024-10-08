unit ProfDin;
interface
uses Objects;
type
    PMatrix = ^TMatrix;
    TMatrix = object
       P : pointer;{㪠��⥫� �� ����}
       SegP : word;{ᥣ���� �����}
       OfsP : word;{ᬥ饭�� �����}
       Size:byte;{ࠧ��� ��६�����}
       BeginV,EndV:Integer;{�������� �� ���⨪���}
       BeginH,EndH:integer;{�������� �� ��ਧ��⠫�}
       N,M  : word;{ࠧ��୮��� ������}
       constructor Init(V1,V2,H1,H2:integer;Size:Byte);
       destructor Done;virtual;
       function Get(i,j:word):real;virtual;
       procedure Put(i,j:word;NewElement:real);virtual;
       end;
    PZeroMatrix = ^TZeroMatrix;
    TZeroMatrix = object(TMatrix)
       function Get(i,j:word):real;virtual;
       procedure Put(i,j:word;NewElement:real);virtual;
       end;
    PVector = ^TVector;
    TVector = object(TObject)
       P : pointer;{㪠��⥫� �� ����}
       SegP : word;{ᥣ���� �����}
       OfsP : word;{ᬥ饭�� �����}
       N  : word;{ࠧ��୮��� �����}
       Labels:string[5];{���ࠫ ����� ��� TGraphic}
       Number:byte;{����� �㤠 ��}
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
constructor Init(V1,V2,H1,H2:integer;ASize:Byte);
begin
  N:=V2-V1+1;
  M:=H2-H1+1;
  Size:=ASize;
  GetMem(P,N*M*Size);
  SegP:=Seg(P^);
  OfsP:=Ofs(P^);
end;
destructor TMatrix.Done;
begin
  FreeMem(P,N*M*Size);
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
function TZeroMatrix.Get(i,j:word):real;
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+M*i*6+j*6);
  Get:=real(S^);
end;
procedure TZeroMatrix.Put(i,j:word;NewElement:real);
var
   S:pointer;
begin
  S:=Ptr(SegP,OfsP+M*i*6+j*6);
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
     Write('������ ',i,' �������: ');
     Readln(A);
     Put(i,A);
     end;
  Write('������ ���ࠫ: ');
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
     Write('������ ',i,' �������: ');
     Readln(A);
     Put(i,A);
     end;
  Write('������ ���ࠫ: ');
  Readln(Labels);
end;

begin
end.
