{$N+,E+,O+,F+,X+,I-,S-}
unit UObject;


interface

const

{ TStream access modes }

  stCreate    = $3C00;           { Create new file }
  stOpenRead  = $3D00;           { Read access only }
  stOpenWrite = $3D01;           { Write access only }
  stOpen      = $3D02;           { Read and write access }

{ TStream error codes }

  stOk         =  0;              { No error }
  stError      = -1;              { Access error }
  stInitError  = -2;              { Cannot initialize stream }
  stReadError  = -3;              { Read beyond end of stream }
  stWriteError = -4;              { Cannot expand stream }
  stGetError   = -5;              { Get of unregistered object type }
  stPutError   = -6;              { Put of unregistered object type }

{ Maximum TCollection size }

  MaxCollectionSize = 65520 div SizeOf(Pointer);

{ TCollection error codes }

  coIndexError = -1;              { Index out of range }
  coOverflow   = -2;              { Overflow }

{ VMT header size }

  vmtHeaderSize = 8;

type

{ Type conversion records }

  WordRec = record
    Lo, Hi: Byte;
  end;

  LongRec = record
    Lo, Hi: Word;
  end;

  PtrRec = record
    Ofs, Seg: Word;
  end;

{ String pointers }

  PString = ^String;

{ Character set type }

  PCharSet = ^TCharSet;
  TCharSet = set of Char;

{ General arrays }

  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of Byte;

  PWordArray = ^TWordArray;
  TWordArray = array[0..16383] of Word;

{ TObject base object }

  PObject = ^TObject;
  TObject = object
    constructor Init;
    procedure Free;
    destructor Done; virtual;
  end;

{ TStreamRec }

  PStreamRec = ^TStreamRec;
  TStreamRec = record
    ObjType: Word;
    VmtLink: Word;
    Load: Pointer;
    Store: Pointer;
    Next: Word;
  end;

{ TStream }

  PStream = ^TStream;
  TStream = object(TObject)
    Status: Integer;
    ErrorInfo: Integer;
    constructor Init;
    procedure CopyFrom(var S: TStream; Count: Longint);
    procedure Error(Code, Info: Integer); virtual;
    procedure Flush; virtual;
    function Get: PObject;
    function GetPos: Longint; virtual;
    function GetSize: Longint; virtual;
    procedure Put(P: PObject);
    procedure Read(var Buf; Count: Word); virtual;
    function ReadStr: PString;
    procedure Reset;
    procedure Seek(Pos: Longint); virtual;
    function StrRead: PChar;
    procedure StrWrite(P: PChar);
    procedure Truncate; virtual;
    procedure Write(var Buf; Count: Word); virtual;
    procedure WriteStr(P: PString);
  end;

{ DOS file name string }

  FNameStr = string[79];

{ TDosStream }

  PDosStream = ^TDosStream;
  TDosStream = object(TStream)
    Handle: Word;
    constructor Init(FileName: FNameStr; Mode: Word);
    destructor Done; virtual;
    function GetPos: Longint; virtual;
    function GetSize: Longint; virtual;
    procedure Read(var Buf; Count: Word); virtual;
    procedure Seek(Pos: Longint); virtual;
    procedure Truncate; virtual;
    procedure Write(var Buf; Count: Word); virtual;
  end;

{ TBufStream }

  PBufStream = ^TBufStream;
  TBufStream = object(TDosStream)
    Buffer: Pointer;
    BufSize: Word;
    BufPtr: Word;
    BufEnd: Word;
    constructor Init(FileName: FNameStr; Mode, Size: Word);
    destructor Done; virtual;
    procedure Flush; virtual;
    function GetPos: Longint; virtual;
    function GetSize: Longint; virtual;
    procedure Read(var Buf; Count: Word); virtual;
    procedure Seek(Pos: Longint); virtual;
    procedure Truncate; virtual;
    procedure Write(var Buf; Count: Word); virtual;
  end;

{ TEmsStream }

  PEmsStream = ^TEmsStream;
  TEmsStream = object(TStream)
    Handle: Word;
    PageCount: Word;
    Size: Longint;
    Position: Longint;
    constructor Init(MinSize, MaxSize: Longint);
    destructor Done; virtual;
    function GetPos: Longint; virtual;
    function GetSize: Longint; virtual;
    procedure Read(var Buf; Count: Word); virtual;
    procedure Seek(Pos: Longint); virtual;
    procedure Truncate; virtual;
    procedure Write(var Buf; Count: Word); virtual;
  end;

{ TCollection types }

  PItemList = ^TItemList;
  TItemList = array[0..MaxCollectionSize - 1] of Pointer;

{ TCollection object }

  PCollection = ^TCollection;
  TCollection = object(TObject)
    Items: PItemList;
    Count: Integer;
    Limit: Integer;
    Delta: Integer;
    constructor Init(ALimit, ADelta: Integer);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function At(Index: Integer): Pointer;
    procedure AtDelete(Index: Integer);
    procedure AtFree(Index: Integer);
    procedure AtInsert(Index: Integer; Item: Pointer);
    procedure AtPut(Index: Integer; Item: Pointer);
    procedure Delete(Item: Pointer);
    procedure DeleteAll;
    procedure Error(Code, Info: Integer); virtual;
    function FirstThat(Test: Pointer): Pointer;
    procedure ForEach(Action: Pointer);
    procedure Free(Item: Pointer);
    procedure FreeAll;
    procedure FreeItem(Item: Pointer); virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    function IndexOf(Item: Pointer): Integer; virtual;
    procedure Insert(Item: Pointer); virtual;
    function LastThat(Test: Pointer): Pointer;
    procedure Pack;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
    procedure SetLimit(ALimit: Integer); virtual;
    procedure Store(var S: TStream);
  end;

{ TSortedCollection object }

  PSortedCollection = ^TSortedCollection;
  TSortedCollection = object(TCollection)
    Duplicates: Boolean;
    constructor Init(ALimit, ADelta: Integer);
    constructor Load(var S: TStream);
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    function IndexOf(Item: Pointer): Integer; virtual;
    procedure Insert(Item: Pointer); virtual;
    function KeyOf(Item: Pointer): Pointer; virtual;
    function Search(Key: Pointer; var Index: Integer): Boolean; virtual;
    procedure Store(var S: TStream);
  end;

{ TStringCollection object }

  PStringCollection = ^TStringCollection;
  TStringCollection = object(TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    procedure FreeItem(Item: Pointer); virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
    procedure Load_Memo(Memo: PChar; D: char);
    procedure Load_Drv;
    procedure Load_Dir(const Path: string; AAttr: word);
    procedure Load_File(Path: string);
  end;

{ TStrCollection object }

  PStrCollection = ^TStrCollection;
  TStrCollection = object(TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    procedure FreeItem(Item: Pointer); virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
  end;

{ TResourceCollection object }

  PResourceCollection = ^TResourceCollection;
  TResourceCollection = object(TStringCollection)
    procedure FreeItem(Item: Pointer); virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    function KeyOf(Item: Pointer): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
  end;

{ TResourceFile object }

  PResourceFile = ^TResourceFile;
  TResourceFile = object(TObject)
    Stream: PStream;
    Modified: Boolean;
    constructor Init(AStream: PStream);
    destructor Done; virtual;
    function Count: Integer;
    procedure Delete(Key: String);
    procedure Flush;
    function Get(Key: String): PObject;
    function KeyAt(I: Integer): String;
    procedure Put(Item: PObject; Key: String);
    function SwitchTo(AStream: PStream; Pack: Boolean): PStream;
  private
    BasePos: Longint;
    IndexPos: Longint;
    Index: TResourceCollection;
  end;

{ TStringList object }

  TStrIndexRec = record
    Key, Count, Offset: Word;
  end;

  PStrIndex = ^TStrIndex;
  TStrIndex = array[0..9999] of TStrIndexRec;

  PStringList = ^TStringList;
  TStringList = object(TObject)
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function Get(Key: Word): String;
  private
    Stream: PStream;
    BasePos: Longint;
    IndexSize: Integer;
    Index: PStrIndex;
    procedure ReadStr(var S: String; Offset, Skip: Word);
  end;

{ TStrListMaker object }

  PStrListMaker = ^TStrListMaker;
  TStrListMaker = object(TObject)
    constructor Init(AStrSize, AIndexSize: Word);
    destructor Done; virtual;
    procedure Put(Key: Word; S: String);
    procedure Store(var S: TStream);
  private
    StrPos: Word;
    StrSize: Word;
    Strings: PByteArray;
    IndexPos: Word;
    IndexSize: Word;
    Index: PStrIndex;
    Cur: TStrIndexRec;
    procedure CloseCurrent;
  end;

{ TPoint object }

  TPoint = object
    X, Y: Integer;
  end;

{ Rectangle object }

  PRect = ^TRect;
  TRect = object
    A, B: TPoint;
    function  Assign(XA, YA, XB, YB: Integer): PRect;
    function  Clip(const R: TRect): boolean;
    function  Contains(P: TPoint): Boolean;
    procedure Copy(const R: TRect);
    function  Equals(const R: TRect): Boolean;
    function  Empty: Boolean;
    function  Grow(X, Y: Integer): PRect;
    procedure Intersect(const R: TRect);
    function  Move(X, Y: Integer): PRect;
    function  Open(X,Y,SX,SY :integer): PRect;
    procedure Union(const R: TRect);
    function  UOpen(XA, YA, SX, SY: Integer): PRect;
    function  UAssign(XA, YA, XB, YB: Integer): PRect;
    function  UMove(XA, YA: Integer): PRect;
    function  UGrow(XA, YA: Integer): PRect;
  end;

{Объект обработки Исключительных Ситуаций (Exception)}

  PException = ^TException;
  TException = object(TObject)
   constructor Try;
   procedure   Setup; virtual;
   destructor  Abort; virtual;
   destructor  Fail; virtual;
   procedure  Retry; virtual;
  private
   RSP,RBP: word;
   RCode: pointer;
   Parent: PException;
   procedure Error_Diler;
  end;

  TFuncX = function(X :extended) :extended;
  TFuncXY = function(X,Y :extended) :extended;

  function ASin(X :extended) :extended;
  function ACos(X :extended) :extended;
  function ACtg(X :extended) :extended;
  function ASh (X :extended) :extended;
  function ACh (X :extended) :extended;
  function ATh (X :extended) :extended;
  function ACth(X :extended) :extended;
  function Sh   (X :extended) :extended;
  function Ch   (X :extended) :extended;
  function Th   (X :extended) :extended;
  function Cth  (X :extended) :extended;
  function Tg   (X :extended) :extended;
  function Ctg  (X :extended) :extended;
  function Log  (X :extended) :extended;
  function Rad  (X :extended) :extended;
  function Grad (X :extended) :extended;
  function Pow  (X :extended; Y :Extended) :extended;
  function AnPow(X :extended; Y :integer) :extended;
  function Fac(I :integer) :longint;
  function Sgn(X: extended): integer;

{ Dynamic string handling routines }

  procedure Str_Dsp(P: PString);
  function  Str_New(const S: string): PString;

  function  LowMemory: boolean;

  function  LongMul(X, Y: Integer): Longint; inline($5A/$58/$F7/$EA);
  function  LongDiv(X: Longint; Y: Integer): Integer; inline($59/$58/$5A/$F7/$F9);

  procedure Abstract;
  procedure Calculator(S :string; var R :extended; var Cod,Pos :integer);
  procedure Find_Proc;
  procedure RegisterType(var S: TStreamRec);
  procedure RegisterObjects;
  procedure RunError(Code :byte);

 const

  err_None                  = 0;
  err_InvalidFuncNumb       = 1;
  err_FileNotFound          = 2;
  err_PathNotFound          = 3;
  err_ManyOpenFiles         = 4;
  err_FileAccessDenied      = 5;
  err_InvalidFileHandle     = 6;
  err_InvalidFileAccess     = 12;
  err_InvalidDriveNumb      = 15;
  err_CannotRemoveCurDir    = 16;
  err_CannotRenameAcrDir    = 17;
  err_NoMoreFiles           = 18;
  err_DiskRead              = 100;
  err_DiskWrite             = 101;
  err_FileNotAssigned       = 102;
  err_FileNotOpen           = 103;
  err_FileNotOpenForInput   = 104;
  err_FileNotOpenForOutput  = 105;
  err_InvalidNumericFormat  = 106;
  err_DiskWriteProtected    = 150;
  err_BadDrvRequestStruct   = 151;
  err_DriveNotReady         = 152;
  err_CRCData               = 154;
  err_DiskSeek              = 156;
  err_UnknownMediaType      = 157;
  err_SectorNotFound        = 158;
  err_PrinterOutOfPaper     = 159;
  err_DeviceWriteFault      = 160;
  err_DeviceReadFault       = 161;
  err_HardwareFailure       = 162;
  err_DivisionByZero        = 200;
  err_RangeCheck            = 201;
  err_StackOverflow         = 202;
  err_HeapOverflow          = 203;
  err_InvalidPointerOper    = 204;
  err_FloatPointOverflow    = 205;
  err_FloatPointUnderflow   = 206;
  err_InvalidFloatPoint     = 207;
  err_OverlayNotInstalled   = 208;
  err_OverlayFileRead       = 209;
  err_ObjectNotInitialized  = 210;
  err_CallAbstractMethod    = 211;
  err_StreamRegistration    = 212;
  err_CollectOutOfRange     = 213;
  err_CollectOverflow       = 214;
  err_ArithmeticOverflow    = 215;
  err_GeneralProtectFault   = 216;

  Metric_Unit: TPoint = (X:1;Y:1);

{ Stream error procedure }

  StreamError: Pointer = nil;

{ EMS stream state variables }

  EmsCurHandle: Word = $FFFF;
  EmsCurPage: Word = $FFFF;

{ Stream registration records }

 const

   RCollection: TStreamRec = (
    ObjType: 50;
    VmtLink: Ofs(TypeOf(TCollection)^);
    Load: @TCollection.Load;
    Store: @TCollection.Store);

   RStringCollection: TStreamRec = (
    ObjType: 51;
    VmtLink: Ofs(TypeOf(TStringCollection)^);
    Load: @TStringCollection.Load;
    Store: @TStringCollection.Store);

   RStrCollection: TStreamRec = (
    ObjType: 69;
    VmtLink: Ofs(TypeOf(TStrCollection)^);
    Load:    @TStrCollection.Load;
    Store:   @TStrCollection.Store);

   RStringList: TStreamRec = (
    ObjType: 52;
    VmtLink: Ofs(TypeOf(TStringList)^);
    Load: @TStringList.Load;
    Store: nil);

   RStrListMaker: TStreamRec = (
    ObjType: 52;
    VmtLink: Ofs(TypeOf(TStrListMaker)^);
    Load: nil;
    Store: @TStrListMaker.Store);

   LowMemSize: word = 1024*5;

{End interface}