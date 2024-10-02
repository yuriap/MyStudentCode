unit alpha;
interface
type
 TTypeCoder = record
   LenghtWord : word;
   AlphabeticPar : byte;
   MovingPar : byte;
   AllCycl : byte;
   end;
var
  A1: array [0..233] of char;
  A2: array [0..233] of byte absolute A1;
procedure Codeing(var W:string;TypeC:TTypeCoder);
procedure DeCodeing(var W:string;TypeC:TTypeCoder);
implementation
procedure InitAlphaBetical;
var i:byte;
begin
  For i:= 21 to 253 do  A1[i-21]:=Chr(i);
end;
procedure Codeing(var W:string;TypeC:TTypeCoder);
var L,i,j:byte;
    Ch:char;
begin
  L:=Length(W);
  Ch:=W[1];
  For j:=1 to TypeC.MovingPar do
   For i:=2 to L do W[i-1]:=W[i];
  W[L]:=Ch;
  For i:=1 to L do
    W[i]:=Chr(byte(W[i])+TypeC.AlphabeticPar);
end;
procedure DeCodeing(var W:string;TypeC:TTypeCoder);
var L,i,j:byte;
    Ch:char;
begin
  L:=Length(W);
  For i:=1 to L do
    W[i]:=Chr(byte(W[i])-TypeC.AlphabeticPar);
  Ch:=W[L];
  For j:=1 to TypeC.MovingPar do
   For i:=L Downto 2 do W[i]:=W[i-1];
  W[1]:=Ch;
end;

begin
 InitAlphabetical;
end.