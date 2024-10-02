unit Snake;
interface
uses Drivers,Objects,Crt;
Type
     TSumbol = record
       sumb : char;
       attr : byte
       end;
    PScreen = ^TScreen;
    TScreen = array [1..25,1..80] of TSumbol;
    PPlate = PScreen;
Var
    Plate : TScreen absolute $b800:$0000;
    GameDone:boolean;
    LastEvent,Pending:TEvent;
Type
   PMain = ^TMain;
   TMain = object
      Id:byte;
      Owner:Pointer;
      end;
   PBorder = ^TBorder;
   PSnake = ^TSnake;
   PDirector = ^TDirector;
   TDirector = object(TMain)
      Pole:PPlate;
      Border:PBorder;
      Snake:PSnake;
      Level:byte;
      Speed:byte;
      Score:word;
      Bound:PCollection;
      Brick:PCollection;
      Present:PCollection;
      constructor Init;
      destructor Done;virtual;
      procedure Run;virtual;
      procedure GetEvent(var Event:TEvent);virtual;
      procedure HandleEvent(var Event:TEvent);virtual;
      procedure ClearEvent(var Event:TEvent);
      procedure PutEvent(Event:TEvent);
      procedure Put_Event(evConst,cmConst:word);
      procedure Idle;virtual;
      function IfBreak(Coord:TPoint):boolean;
      function IfPresent(Coord:TPoint):boolean;
      procedure InitBound;
      procedure InitBrick;
      procedure InitPresent;
      end;

   TSnake = object(TMain)
      X,Y:byte;
      Shleif:PCollection;
      constructor Init(ALevel:byte;AOwner:Pointer);
      destructor Done;virtual;
      procedure ShowSnake;
      procedure MoveSnake(NewX,NewY:Byte);
      procedure EndGame;
      procedure ReMovePresent;
      end;
   PElem = ^TElem;
   TElem = object
      X,Y:byte;
      Owner:Pointer;
      constructor Init(AOwner:Pointer;AX,AY:byte);
      destructor Done;virtual;
      end;
const{Id constant}
 IdDirector = 1;
 IdBorder = 2;
 IdSnake = 3;
 WhalChar : TSumbol = (Sumb:'H';Attr:$1F);
 BrickChar : TSumbol = (Sumb:'*';Attr:$1E);
 Space : TSumbol = (Sumb:' ';Attr:$1F);
 PresentChar : TSumbol = (Sumb:'$';Attr:$1F);
 HeadChar : TSumbol = (Sumb:'†';Attr:$1F);
const
 cmEndGame = $0001;
implementation
Procedure CleanScreen;
var i,j:integer;
begin
 for i:=1 to 80 do begin
  for j:=1 to 25 do Plate[j,i]:=Space;
  end;
end;
procedure OutScr(X,Y:byte;S:string;Attr:byte;);
var C:TSumbol;
begin
  C.Attr:=Attr
  for i:=X to S[0]+X do begin
    C.Sumb:=S[i-X+1];
    Plate[Y,i]:=C;
    end;
end;
constructor TDirector.Init;
begin
 Pending.What:=evNothing;
 Id:=IdDirector;
 Level:=1;
 Speed:=1;
 Score:=0;
 Pole:=@Plate;
 CleanScreen;
 Bound:=New(PCollection,Init(200,0));
 Brick:=New(PCollection,Init(10*ALevel,10));
 Present:=New(PCollection,Init(15*ALevel,10));
 InitBound;
 InitBrick;
 InitPresent;
 Snake:=New(PSnake,Init(Level,@Self));
 OutScr(40,2,'Score:',$1D);
end;
destructor TDirector.Done;
begin
  Dispose(Bound,Done);
  Dispose(Brick,Done);
  Dispose(Present,Done);
  Dispose(Snake,Done);
end;
procedure TDirector.Run;
var Event:TEvent;
begin
 GameDone:=false;
 repeat
  GetEvent(Event);
  HandleEvent(Event);
 until GameDone;
end;
procedure TDirector.GetEvent(var Event: TEvent);
begin
   if Pending.What <> evNothing then begin
      Event:=Pending;
      ClearEvent(Pending);
      exit;
      end;
   GetKeyEvent(Event);
   if Event.What = evNothing then Idle;
end;
procedure TDirector.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evKeyDown) and (Event.KeyCode = kbEsc) then
  begin
      GameDone:=True;
      ClearEvent(Event);
    end;
  LastEvent:=Event;
  if Event.What = evKeyDown then begin
   case Event.KeyCode of
    kbLeft: Snake^.MoveSnake(Snake^.X-1,Snake^.Y);
    kbRight: Snake^.MoveSnake(Snake^.X+1,Snake^.Y);
    kbUp: Snake^.MoveSnake(Snake^.X,Snake^.Y-1);
    kbDown: Snake^.MoveSnake(Snake^.X,Snake^.Y+1);
   end;
   ClearEvent(Event);
   end;
  if Event.What = evCommand then begin
    case Event.Command of
     cmEndGame : GameDone:=True;
     end;
    ClearEvent(Event);
    end;
end;
procedure TDirector.ClearEvent;
begin
  Event.What:=evNoThing;
end;
procedure TDirector.PutEvent(Event:TEvent);
begin
  Pending:=Event;
end;
procedure TDirector.Put_Event(evConst,cmConst:word);
var E:TEvent;
begin
  E.What:=evConst;
  E.Command:=cmConst;
  PutEvent(E);
end;
procedure TDirector.Idle;
begin
  Delay(Speed*300);
  PutEvent(LastEvent);
end;
end;
function TDirector.IfBreak(Coord:TPoint):boolean;
var IfBr:Boolean;
 procedure IfTheBreak(B:PBrick);far;
 begin
   if (B^.X = Coord.X) and
      (B^.Y = Coord.Y) then IfBr:=True;
 end;
begin
  IfBr:=false;
  Bound^.ForEach(@IfTheBreak);
  Brick^.ForEach(@IfTheBreak);
  IfBreak:=IfBr;
end;
function TDirector.IfPresent(Coord:TPoint):boolean;
var IfBr:Boolean;
 procedure IfTheBreak(B:PPresent);far;
 begin
   if (B^.X = Coord.X) and
      (B^.Y = Coord.Y) then IfBr:=True;
 end;
begin
  IfBr:=false;
  Present^.ForEach(@IfTheBreak);
  IfPresent:=IfBr;
end;
procedure TDirector.InitBound;
 procedure ShowBound(Brick:PBrick);far;
 begin
   Plate[Brick^.Y,Brick^.X]:=WhalChar;
 end;
var i:integer;
begin
  For i:=1 to 80 do Bound^.Insert(New(PBrick,Init(@Self,i,3)));
  For i:=1 to 80 do Bound^.Insert(New(PBrick,Init(@Self,i,22)));
  For i:=4 to 21 do Bound^.Insert(New(PBrick,Init(@Self,1,i)));
  For i:=4 to 21 do Bound^.Insert(New(PBrick,Init(@Self,80,i)));
  Bound^.ForEach(@ShowBound);
end;
procedure TDirector.InitBrick;
 procedure ShowBrick(Brick:PBrick);far;
 begin
   Plate[Brick^.Y,Brick^.X]:=BrickChar;
 end;
var i:integer;
    X,Y:Word;
    P:TPoint;
begin
  Randomize;
  i:=1;
  repeat
    X:=Random(78);
    Y:=Random(17);
    P.X:=X+1;P.Y:=Y+3;
    If not(IfBreak(P)) then begin
      Brick^.Insert(New(PElem,Init(@Self,X+1,Y+3)));
      Inc(i);
      end;
  until i > 10*Level;
  Brick^.ForEach(@ShowBrick);
end;
procedure TDirector.InitPresent;
 procedure ShowPresent(Pres:PPresent);far;
 begin
   Plate[Pres^.Y,Pres^.X]:=PresentChar;
 end;
var i:integer;
    X,Y:Word;
    P:TPoint;
begin
  Randomize;
  i:=1;
  repeat
    X:=Random(78);
    Y:=Random(17);
    P.X:=X+1;P.Y:=Y+3;
    If not(IfBreak(P)) then begin
      Present^.Insert(New(PElem,Init(@Self,X+1,Y+3)));
      Inc(i);
      end;
  until i > 15*Level;
  Present^.ForEach(@ShowPresent);
end;
constructor TSnake.Init(ALevel:byte;AOwner:Pointer);
begin
  Owner:=AOwner;
  Shleif:=New(PCollection,Init(15*ALevel,0));
  X:=40;
  Y:=12;
  ShowSnake;
end;
destructor TSnake.Done;
begin
 Dispose(Shleif,Done);
end;
procedure TSnake.ShowSnake;
 procedure ShowShleif(Pres:PPresent);far;
 begin
   Plate[Pres^.Y,Pres^.X]:=PresentChar;
 end;
begin
  Plate[Y,X]:=HeadChar;
  Shleif^.ForEach(@ShowShleif);
end;
procedure TSnake.MoveSnake(NewX,NewY:byte);
var X1,Y1,A,B:byte;
 procedure MovePresent(P:PPresent);far;
 var X2,Y2:Byte;
 begin
  X2:=P^.X;Y2:=P^.Y;
  P^.X:=X1;P^.Y:=Y1;
  X1:=X2;Y1:=Y2;
 end;
var P:TPoint;
begin
  X1:=X;Y1:=Y;
  X:=NewX;Y:=NewY;
  P.X:=X;P.Y:=Y;
  Plate[Y1,X1]:=Space;
  if PDirector(Owner)^.IfBreak(P) then EndGame;
  if PDirector(Owner)^.IfPresent(P) then ReMovePresent;
  if Shleif^.Count <> 0 Then begin
    A:=PPresent(Shleif^.At(Shleif^.Count-1))^.X;
    B:=PPresent(Shleif^.At(Shleif^.Count-1))^.Y;
    Plate[B,A]:=Space;
    Shleif^.ForEach(@MovePresent);
    end;
  ShowSnake;
end;
procedure TSnake.EndGame;
begin
  PDirector(Owner)^.Put_Event(evCommand,cmEndGame);
end;
procedure TSnake.ReMovePresent;
var P:PPresent;
 procedure WP(PP:PPresent);far;
 begin
   If (PP^.X = X) and (PP^.Y = Y) then P:=PP;
 end;
begin
  PDirector(Owner)^.Present^.ForEach(@WP);
  Shleif^.Insert(P);
  PDirector(Owner)^.Present^.Delete(P);
end;
constructor TElem.Init(AOwner:Pointer;AX,AY:byte);
begin
  Owner:=AOwner;
  X:=AX;
  Y:=AY;
end;
destructor TElem.Done;
begin
end;
end.