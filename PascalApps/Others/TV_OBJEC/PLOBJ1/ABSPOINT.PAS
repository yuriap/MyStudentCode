unit AbsPoint;
interface
uses Objects,PlCommon,Graph;

type
    PAbsPoint = ^TAbsPoint;
    TAbsPoint = object (TObject)   {������ ��ꥪ�}
        X,Y : real;{���न����}
        ScrX,ScrY :integer;{���न���� �� ��࠭�}
        Vx,Vy : real;{᪮���� � �窥 � ����. Location}
        StreamMove : boolean;{��������� �� ����� � ��⮪��}
        DTime : real;{�஬���⮪ �६��� tau}
        Color : word;
        constructor Init(NewLocation:TAPoint;NewDTime:real;StrMove:boolean);
        procedure Move;
        procedure Show;virtual;
        procedure Hide;virtual;
        procedure Draw;
        destructor Done;virtual;
        constructor Load( var S : TStream);
        procedure Store( var S : TStream);
        end;
implementation
constructor TAbsPoint.Init(NewLocation:TAPoint;NewDTime:real;StrMove:boolean);
begin

 X:=NewLocation.X;
 Y:=NewLocation.Y;
 ScrX:=Trunc(X*Screen.MasX)+Screen.DeltaX;
 ScrY:=Screen.DeltaY-1*Trunc(Y*Screen.MasY);
 Vx := 0.0;
 Vy := 0.0;
 StreamMove := StrMove;
 DTime := NewDTime;
 Color := 0;
end;
procedure TAbsPoint.Move;
begin
  X := X + Vx * DTime;
  Y := Y + Vy * DTime;
  ScrX:=Trunc(X*Screen.MasX)+Screen.DeltaX;
  ScrY:=Screen.DeltaY-1*Trunc(Y*Screen.MasY);
end;
procedure TAbsPoint.Show;
begin
  SetColor(Lo(Color));
end;
procedure TAbsPoint.Hide;
begin
  SetColor(Hi(Color));
end;
procedure TAbsPoint.Draw;
begin
   Hide;
   If StreamMove Then Move;
   Show;
end;
destructor TAbsPoint.Done;
begin
  inherited Done;
end;
constructor TAbsPoint.Load( var S:TStream);
begin
  S.Read(X,SizeOf(real));
  S.Read(Y,SizeOf(real));
  S.Read(ScrX,SizeOf(integer));
  S.Read(ScrY,SizeOf(integer));
  S.Read(Vx,SizeOf(real));
  S.Read(Vy,SizeOf(real));
  S.Read(StreamMove,SizeOf(Boolean));
  S.Read(DTime,SizeOf(real));
  S.Read(Color,SizeOf(Word));
end;
procedure TAbsPoint.Store( var S:TStream);
begin
  S.Write(X,SizeOf(real));
  S.Write(Y,SizeOf(real));
  S.Write(ScrX,SizeOf(integer));
  S.Write(ScrY,SizeOf(integer));
  S.Write(Vx,SizeOf(real));
  S.Write(Vy,SizeOf(real));
  S.Write(StreamMove,SizeOf(Boolean));
  S.Write(DTime,SizeOf(real));
  S.Write(Color,SizeOf(Word));
end;

begin
end.
