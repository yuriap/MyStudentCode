Unit STRM;
interface
uses
  Objects, Graph;

const
  PathToDrivers = '\TP\BGI';  { Default location of *.BGI files }

{ ********************************** }
{ ******  Graphical Objects  ******* }
{ ********************************** }

type
  PGraphObject = ^TGraphObject;
  TGraphObject = object(TObject)
    X,Y: Integer;
    constructor Init;
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure Store(var S: TStream); virtual;
  end;

  PGraphPoint = ^TGraphPoint;
  TGraphPoint = object(TGraphObject)
    procedure Draw; virtual;
  end;

  PGraphCircle = ^TGraphCircle;
  TGraphCircle = object(TGraphObject)
    Radius: Integer;
    constructor Init;
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure Store(var S: TStream); virtual;
  end;

  PGraphRect = ^TGraphRect;
  TGraphRect = object(TGraphObject)
    Width, Height: Integer;
    constructor Init;
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure Store(var S: TStream); virtual;
  end;
{ ********************************** }
{ **  Stream Registration Records ** }
{ ********************************** }

const
  RGraphPoint: TStreamRec = (
    ObjType: 150;
    VmtLink: Ofs(TypeOf(TGraphPoint)^);
    Load: @TGraphPoint.Load;
    Store: @TGraphPoint.Store);

  RGraphCircle: TStreamRec = (
    ObjType: 151;
    VmtLink: Ofs(TypeOf(TGraphCircle)^);
    Load: @TGraphCircle.Load;
    Store: @TGraphCircle.Store);

  RGraphRect: TStreamRec = (
    ObjType: 152;
    VmtLink: Ofs(TypeOf(TGraphRect)^);
    Load: @TGraphRect.Load;
    Store: @TGraphRect.Store);
procedure Abort(Msg: String);
procedure StreamRegistration;
procedure StartGraphics;
procedure DrawAll(C: PCollection);
var
  GraphicsList: PCollection;
  GraphicsStream: TBufStream;

{*******************************************}
implementation
{ TGraphObject }
constructor TGraphObject.Init;
begin
  X := Random(GetMaxX) div 2;
  Y := Random(GetMaxY) div 2;
end;

constructor TGraphObject.Load(var S: TStream);
begin
  S.Read(X, SizeOf(X));
  S.Read(Y, SizeOf(Y));
end;

procedure TGraphObject.Draw;
begin
  Abstract;     { Give error: This object should never be drawn }
end;

procedure TGraphObject.Store(var S: TStream);
begin
  S.Write(X, SizeOf(X));
  S.Write(Y, SizeOf(Y));
end;

{ TGraphPoint }
procedure TGraphPoint.Draw;
var
  DX, DY: Integer;
begin
  { Make it a fat point so you can see it }
  for DX := x - 2 to x + 2 do
    for DY := y - 2 to y + 2 do
      PutPixel(DX, DY, 1);
end;

{ TGraphCircle }
constructor TGraphCircle.Init;
begin
  inherited Init;
  Radius := 30 + Random(20);
end;

constructor TGraphCircle.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Radius, SizeOf(Radius));
end;

procedure TGraphCircle.Draw;
begin
  Circle(X, Y, Radius);
end;

procedure TGraphCircle.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Radius, SizeOf(Radius));
end;

{ TGraphRect }
constructor TGraphRect.Init;
begin
  inherited Init;
  Width := 5 + Random(10) + X;
  Height := 3 + Random(8) + Y;
end;

constructor TGraphRect.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Width, SizeOf(Width));
  S.Read(Height, SizeOf(Height));
end;

procedure TGraphRect.Draw;
begin
  Rectangle(X, Y, X + Width, Y + Height);
end;

procedure TGraphRect.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Width, SizeOf(Width));
  S.Write(Height, SizeOf(Height));
end;



{ ********************************** }
{ ************  Globals ************ }
{ ********************************** }

{ Abort the program and give a message }

procedure Abort(Msg: String);
begin
  Writeln;
  Writeln(Msg);
  Writeln('Program aborting');
  Halt(1);
end;

{ Register all object types that will be put onto the stream.
  This includes standard TVision types, like TCollection.
}

procedure StreamRegistration;
begin
  RegisterType(RCollection);
  RegisterType(RGraphPoint);
  RegisterType(RGraphCircle);
  RegisterType(RGraphRect);
end;

{ Put the system into graphics mode }

procedure StartGraphics;
var
  Driver, Mode: Integer;
begin
  Driver := Detect;
  InitGraph(Driver, Mode, PathToDrivers);
  if GraphResult <> GrOK then
  begin
    Writeln(GraphErrorMsg(Driver));
    if Driver = grFileNotFound then
    begin
      Writeln('in ', PathToDrivers,
        '. Modify this program''s "PathToDrivers"');
      Writeln('constant to specify the actual location of this file.');
      Writeln;
    end;
    Writeln('Press Enter...');
    Readln;
    Halt(1);
  end;
end;

{ Use the ForEach iterator to traverse and
  show all the collection of graphical objects.
}

procedure DrawAll(C: PCollection);

{ Nested, far procedure. Receives one
  collection element--a GraphObject, and
  calls that elements Draw method.
}

procedure CallDraw(P: PGraphObject); far;
begin
  P^.Draw;                                   { Call Draw method }
end;

begin { DrawAll }
  C^.ForEach(@CallDraw);                     { Draw each object }
end;

{ ********************************** }
{ **********  Main Program ********* }
{ ********************************** }

begin
end.