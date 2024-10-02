{      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³                                           ³
       ³       W h i t e  A p p l i c a t o r      ³
       ³                                           ³
       ³            U S t r e e m  2.0             ³
       ³                                           ³
       ³       Copyright (c)  S.Novak  1995        ³
       ³                                           ³
       ³               (interface)                 ³
       ³                                           ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      }

 unit UStream;

  {$S-,B-,V-,R-,I-,T-}

 interface

  uses

   UObject;

  type

   TNameStr = string[79];

   PStream = ^TStream;
   TStream = object(TChannel)
    procedure Clear; virtual;
    function  Pos_Get: longint; virtual;
    procedure Pos_Set(Pos: longint); virtual;
    procedure Buf_Del(Count :longint);
    procedure Buf_Ins(const Buf; Count :word);
    procedure Buf_Move(Source,Dest,Count :longint);
    procedure Truncate; virtual;
   end;

   PDosStream = ^TDosStream;
   TDosStream = object(TStream)
    constructor Init(const FileName: TNameStr; AMode: word);
    constructor Load(Channel :PChannel);
    destructor Done; virtual;
    procedure Buf_Get(var Buf; Count: word); virtual;
    procedure Buf_Put(const Buf; Count: word); virtual;
    function  Pos_Get: longint; virtual;
    procedure Pos_Set(Pos: longint); virtual;
    function  Name_Get :TNameStr;
    function  Size: longint; virtual;
    procedure Store(Channel :PChannel);
    procedure Truncate; virtual;
   private
    Handle :word;
    Name : PString;
    Mode : word;
   end;

   PBufStream = ^TBufStream;
   TBufStream = object(TDosStream)
    constructor Init(const FileName: TNameStr; AMode, ASize: word);
    constructor Load(Channel :PChannel);
    destructor Done; virtual;
    procedure Flush; virtual;
    procedure Buf_Get(var Buf; Count: word); virtual;
    procedure Buf_Put(const Buf; Count: word); virtual;
    function  Pos_Get: longint; virtual;
    procedure Pos_Set(Pos: longint); virtual;
    function  Size: longint; virtual;
    procedure Store(Channel :PChannel);
    procedure Truncate; virtual;
   private
    Buffer  :pointer;
    BufSize :word;
    BufPtr  :word;
    BufEnd  :word;
   end;

   PEmsStream = ^TEmsStream;
   TEmsStream = object(TStream)
    constructor Init(AMinSize, AMaxSize: longint);
    constructor Load(Channel :PChannel);
    destructor Done; virtual;
    procedure Buf_Get(var Buf; Count: word); virtual;
    procedure Buf_Put(const Buf; Count: word); virtual;
    function  Pos_Get: longint; virtual;
    procedure Pos_Set(Pos: longint); virtual;
    function  Size: longint; virtual;
    procedure Store(Channel :PChannel);
    procedure Truncate; virtual;
   private
    Handle    :word;
    PageCount :word;
    EmsSize   :longint;
    Position  :longint;
   end;

   PDosVector = ^TDosVector;
   TDosVector = object(TVector)
    DataSize :word;
    HeadSize :word;
    Stream   :PStream;
    constructor Build(AStream :PStream; AHeadSize,ADataSize :word);
    constructor Load(Channel :PChannel);
    destructor Done; virtual;
    function Power :longint;
    procedure Clear; virtual;
    procedure Del(Addr :longint); virtual;
    procedure Flush; virtual;
    procedure Get(Addr :longint; var Data); virtual;
    procedure Ins(Addr :longint; const Data); virtual;
    procedure Move(Source,Dest :longint); virtual;
    procedure Put(Addr :longint; const Data); virtual;
    procedure Store(Channel :PChannel);
   end;

   PBufVector = ^TBufVector;
   TBufVector = object(TDosVector)
    constructor Build(AStream :PStream; AHeadSize,ADataSize,APageSize :word);
    constructor Load(Channel :PChannel);
    destructor Done; virtual;
    function Power :longint;
    function RPtr(Addr :longint) :pointer;
    function WPtr(Addr :longint) :pointer;
    procedure Clear; virtual;
    procedure Del(Addr :longint); virtual;
    procedure FreeBuffer;
    procedure Flush; virtual;
    procedure Get(Addr :longint; var Data); virtual;
    procedure Ins(Addr :longint; const Data); virtual;
    procedure Move(Source,Dest :longint); virtual;
    procedure Put(Addr :longint; const Data); virtual;
    procedure Store(Channel :PChannel);
   private
    PageSize :word;
    Pages :pointer;
    function DoFind(Addr :longint) :pointer;
    function DoPage(Addr :longint) :pointer;
    procedure DoFree(Source, Dest :longint);
   end;

  const

   IDT_DosStream     = 4;
   IDT_BufStream     = 5;
   IDT_EmsStream     = 6;
   IDT_DosVector     = 7;
   IDT_BufVector     = 8;

   sm_Create         = $3C00;
   sm_OpenRead       = $3D00;
   sm_OpenWrite      = $3D01;
   sm_Open           = $3D02;

   procedure Register_BufStream;
   procedure Register_BufVector;
   procedure Register_DosStream;
   procedure Register_DosVector;
   procedure Register_EmsStream;

  {end interface}