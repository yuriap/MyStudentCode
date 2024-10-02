unit figure;
interface
uses Objects,Graph;
type
  PFigure = ^TFigure;
  TFigure = object(TObject)
    X,Y:integer;
    Text:String[10];
    constructor Init(Xi,Yi:integer;iText:String);
    procedure Draw;virtual;
    constructor Load ( var S:TStream );
    procedure Store ( var S:TStream );
    end;

  PBar = ^TBar;
  TBar = object(TFigure)
    Width,Heght:integer;
    constructor Init (iX,iY,iWidth,iHeght:integer);
    procedure  Draw;virtual;
    constructor Load( var S:TStream );
    procedure Store( var S:TStream );
    end;

  PCFigure = ^TCFigure;
  TCFigure = object(TCollection)
    Style,High:Word;
    constructor Init(F,S:integer;iHigh,iStyle:word);
    procedure Draw;
    constructor Load( var S:TStream );
    procedure Store( var S:TStream );
    end;

  PFGroup = ^TFGroup;
  TFGroup = object(TObject)
    First,Second,Third:PCFigure;
    constructor Init(Param:word);
    procedure Draw;
    constructor Load( var S:TStream );
    procedure Store ( var S:TStream );
    destructor Done;virtual;
    end;

const
   RFigure : TStreamRec = (
      ObjType : 1001;
      VmtLink: Ofs(TypeOf(TFigure)^);
      Load:@TFigure.Load;
      Store:@TFigure.Store);
   RBar : TStreamRec = (
      ObjType : 1002;
      VmtLink: Ofs(TypeOf(TBar)^);
      Load:@TBar.Load;
      Store:@TBar.Store);
   RCFigure : TStreamRec = (
      ObjType : 1003;
      VmtLink: Ofs(TypeOf(TCFigure)^);
      Load:@TCFigure.Load;
      Store:@TCFigure.Store);
   RFGroup : TStreamRec = (
      ObjType : 1004;
      VmtLink: Ofs(TypeOf(TFGroup)^);
      Load:@TFGroup.Load;
      Store:@TFGroup.Store);

implementation

constructor TFigure.Init;
begin
 inherited Init;
 X:=Xi;Y:=Yi;
 Text:=iText;
end;
procedure TFigure.Draw;
begin
  Rectangle(X,Y,X+150,Y+20);
  SetTExtJustify(0,2);
  OutTextXY(X,Y,Text);
end;
constructor TFigure.Load;
begin
 S.Read(X,SizeOf(X));
 S.Read(Y,SizeOf(Y));
 S.Read(Text,SizeOf(Text));
end;
procedure TFigure.Store;
begin
 S.Write(X,SizeOf(X));
 S.Write(Y,SizeOf(Y));
 S.Write(Text,SizeOf(Text));
end;

constructor TBar.Init;
begin
 inherited Init(iX,iY,'Probabilit');
 Width:=iWidth;
 Heght:=iHeght;
end;
procedure TBar.Draw;
begin
  Bar3D(X,Y,X+Width,Y+Heght,10,true);
end;
constructor TBar.Load;
begin
 inherited Load(S);
 S.Read(Width,SizeOf(Width));
 S.Read(Heght,SizeOf(Heght));
end;
procedure TBar.Store;
begin
 inherited Store(S);
 S.Write(Width,SizeOf(Width));
 S.Write(Heght,SizeOf(Heght));
end;

constructor TCFigure.Init;
var i:Integer;
begin
  Inherited Init(3,2);
  Style:=iStyle;
  High:=iHigh;
  For i:=1 to 3 do
   Insert(New(PBar,Init(F*i,S+High,F-10,S)));
end;
procedure TCFigure.Draw;
 procedure DrawAll( S:PBar);far;
 begin
   S^.Draw;
 end;
begin
  SetColor(2);
  SetBkColor(15);
  SetFillStyle(Style,5);
  ForEach(@DrawAll);
end;
constructor TCFigure.Load;
begin
  inherited Load(S);
  S.Read(High,SizeOf(High));
  S.Read(Style,SizeOf(Style));
end;
procedure TCFigure.Store;
begin
  inherited Store(S);
  S.Write(High,SizeOf(High));
  S.Write(Style,SizeOf(Style));
end;

constructor TFGroup.Init;
begin
  inherited Init;
  First:=New(PCFigure,Init(50,20,Param*30,Param));
  Second:=New(PCFigure,Init(50,25,Param*30+25,Param+1));
  Third:=New(PCFigure,Init(60,30,Param*30+55,Param+2));
end;
procedure TFGroup.Draw;
begin
  First^.Draw;
  Second^.Draw;
  Third^.Draw;
end;
constructor TFGroup.Load;
begin
  First:=PCFigure(S.Get);
  Second:=PCFigure(S.Get);
  Third:=PCFigure(S.Get);
end;
procedure TFGroup.Store;
begin
  S.Put(First);
  S.Put(Second);
  S.Put(Third);
end;
destructor TFGroup.Done;
begin
  Dispose(First,Done);
  Dispose(Second,Done);
  Dispose(Third,Done);
end;

begin
end.