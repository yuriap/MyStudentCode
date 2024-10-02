program t;
uses Views,Drivers,Graph,Crt;
type
   PGButton = ^TGButton;
   TGButton = object(TView)
      end;
var
   GButtun : PGButton;
   Event : TEvent;
        grDriver: Integer;
        grMode: Integer;
        ErrCode: Integer;
const   MasX : integer=1;
        MasY : integer=1;
procedure GraphInit;
begin
 grDriver := Detect;
 InitGraph(grDriver, grMode,'e:\tp7\bgi ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin
   Writeln('Graphics error:', GraphErrorMsg(ErrCode));
   Halt(0);
 end;
end;
procedure PutPixelMouse;
begin
  If Event.Buttons and evMouseUp <> 0
   then begin
    SetViewPort(1,1,GetMaxX,GetMaxY,ClipOff);
    MasX:=GetMaxX div Event.Where.X;
    MasY:=GetMaxY div Event.Where.Y;

   end;
  If Event.Buttons and evMouseDown <> 0
   then begin
    PutPixel(Trunc(MasX*Event.Where.X),Trunc(MasY*Event.Where.Y),15);
    end;
end;

procedure PrnPixel;
var i,j:integer;
begin
   i := 1;j:=1;
   repeat
    repeat
    PutPixel(i,j,14);
    i:=i+10;
    until i > GetMaxX;
   i:=1;
   j:=j+10;
   until j > GetMaxY;

end;

procedure PrintLocation;
var
   X,Y : string[4];
   Xz,Yz:integer;
begin
   Xz:=GetX;
   Yz:=GetY;
   SetViewPort(1,1,150,40,clipOff);
   ClearViewPort;
   Str(Event.Where.X*MasX,X);
   Str(Event.Where.Y*MasY,Y);
   OutTextXY(50,10,X);
   OutTextXY(100,10,Y);
   Str(Xz,X);
   Str(Yz,Y);
   OutTextXY(50,30,X);
   OutTextXY(100,30,Y);
end;
begin
   GraphInit;
   InitEvents;
   repeat
   GetMouseEvent(Event);
   If Event.What and evMouse <> 0 then
      begin
      PutPixelMouse;
      PrintLocation;

      end
   until KeyPressed;
   DoneEvents;
end.