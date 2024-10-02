unit dbtypes;
interface
uses Objects;
type
  PStr = ^TStr;
  TStr = object(TObject)
    S:string;
    constructor Init;
    constructor Load( var SS:TStream);
    procedure Store( var SS:TStream);
    end;
  PDBRecord = ^TDbRecord;
  TDBRecord = object(TObject)
    What:string[20];
    Where:string[60];
    Declaration:string[60];
    Description:PCollection;
    constructor Init;
    destructor Done;virtual;
    constructor Load( var S:TStream);
    procedure Store( var S:TStream);
    procedure AddString(S:string);
    end;
const
  RDBRecord: TStreamRec = (
    ObjType: 2001;
    VmtLink: Ofs(TypeOf(TDBRecord)^);
    Load: @TDBRecord.Load;
    Store: @TDBRecord.Store);
  RStr: TStreamRec = (
    ObjType: 2002;
    VmtLink: Ofs(TypeOf(TStr)^);
    Load: @TStr.Load;
    Store: @TStr.Store);
var
  DBRecord:PDBRecord;
  DBCollection:PCollection;
implementation
constructor TDBRecord.Init;
begin
  What:='';
  Declaration:='';
  Description:=New(PCollection,Init(10,2));
end;
destructor TDBRecord.Done;
begin
  Dispose(Description,Done);
  inherited Done;
end;
constructor TDBRecord.Load( var S:TStream);
begin
  S.Read(What,SizeOf(What));
  S.Read(Where,SizeOf(Where));
  S.Read(Declaration,SizeOf(Declaration));
  Description:=PCollection(S.Get);
end;
procedure TDBRecord.Store( var S:TStream);
begin
 S.Write(What,SizeOf(What));
 S.Write(Where,SizeOf(Where));
 S.Write(Declaration,SizeOf(Declaration));
 S.Put(Description);
end;
procedure TDBRecord.AddString(S:string);
var Line:PStr;
begin
  Line:=New(PStr,Init);
  Line^.S:=S;
  Description^.Insert(Line);
end;

constructor TStr.Init;
begin
 S:='';
end;
constructor TStr.Load( var SS:TStream);
begin
 SS.Read(S,SizeOf(S));
end;
procedure TStr.Store( var SS:TStream);
begin
 SS.Write(S,SizeOf(S));
end;
begin
 RegisterType(RDBRecord);
 RegisterType(RCollection);
 RegisterType(RStr);
end.