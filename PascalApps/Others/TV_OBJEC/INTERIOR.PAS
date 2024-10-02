unit interior;
interface
uses Views,Objects,Drivers;
type

    PInteriors = ^TInteriors;
    TInteriors = object(TView)
       constructor Init(var Bounds:TRect);
       procedure Draw;virtual;
       end;
Const MaxLines = 100;
Var   Lines : array[0..MaxLines] of PString;
      LineCount : integer;

Implementation
constructor TInteriors.Init(var Bounds:TRect);
begin
   inherited Init(Bounds);
   GrowMode:=gfGrowHiX+gfGrowHiY;
end;
procedure TInteriors.Draw;
Var
   Color:Byte;
   I,Y:Integer;
   B:TDrawBuffer;
Begin
{   Color:=GetColor(1);
   For Y:=1 to Size.Y-1 do begin
      MoveChar(B,' ',Color,Size.X);
      i:=Delta.Y+Y;
      If (I<LineCount)and(Lines[1]<>nil) then
        MoveStr(B,Copy(Lines[I]^,Delta.X+1,Size.X),color);
        WriteLine(0,Y,Size.X,1,B);
   end;}
End;

begin
end.