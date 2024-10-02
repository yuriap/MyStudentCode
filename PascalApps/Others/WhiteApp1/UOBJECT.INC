{      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³                                           ³
       ³       W h i t e  A p p l i c a t o r      ³
       ³                                           ³
       ³            U O b j e c t  2.0             ³
       ³                                           ³
       ³       Copyright (c)  S.Novak  1995        ³
       ³                                           ³
       ³               (interface)                 ³
       ³                                           ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      }

 unit UObject;

  {$S-,B-,V-,R-,I-,T-}

 interface

  type

   PPoint = ^TPoint;
   TPoint = record
    X,Y :integer;
   end;

   PRect = ^TRect;
   TRect = object
    A,B: TPoint;
    procedure Assign(XA,YA,XB,YB: integer);
    procedure Center(var Pos :TPoint);
    function  Clip(const R: TRect): boolean;
    procedure Copy(const R: TRect);
    function  Contains(P: TPoint): boolean;
    function  Equals(const R: TRect): boolean;
    function  Empty: boolean;
    procedure Grow(X,Y: integer);
    procedure Intersect(const R: TRect);
    procedure Move(X,Y: integer);
    procedure Open(X,Y,SX,SY :integer);
    procedure Union(const R: TRect);
   end;

   PQueue = ^TQueue;
   TQueue = object
    constructor Init(ARange,ADataSize :word);
    destructor Done;
    procedure Clear;
    function  Power_Get :word;
    function  Power_Max :word;
    procedure Rec_Get(var Data);
    procedure Rec_Put(const Data);
   private
    Size :word;
    Queue :pointer;
    Range :byte;
    Power :byte;
    Last : word;
    Head : word;
    Tail : word;
   end;

   PObject = ^TObject;
   TObject = object
    constructor Init;
    destructor Done; virtual;
    procedure Free;
    function  Self_IDT :word;
    function  Self_Ptr :pointer;
   private
    procedure DoData; virtual;
    procedure DoLoad; virtual;
    procedure DoStore; virtual;
   end;

   PFantom = ^TFantom;
   TFantom = object(TObject)
    Protect_Count :word;
    constructor Init;
    destructor Done; virtual;
    procedure GoToHit;
    procedure Protect; virtual;
    procedure UnProtect; virtual;
   private
    Next,Prev :PFantom;
    procedure DoDel;
    procedure DoIns;
   end;

   PString = ^string;

   PChannel = ^TChannel;
   TChannel = object(TObject)
    Status :integer;
    ErrorInfo : integer;
    procedure Buf_Get(var Data; Count: word); virtual;
    procedure Buf_Put(const Data; Count: word); virtual;
    procedure Clear; virtual;
    procedure Copy(const Channel: TChannel; Count: longint);
    procedure Error(Code, Info: integer); virtual;
    procedure Flush; virtual;
    function  Obj_Get :pointer;
    procedure Obj_Put(Obj :PObject);
    procedure Reset;
    function  Str_Get :PString;
    procedure Str_Put(Str :PString);
    function  Size: longint; virtual;
   end;

   PNul = ^TNul;
   TNul = object(TChannel)
    constructor Init;
    constructor Load(Channel :PChannel);
    procedure   Store(Channel :PChannel);
    procedure Buf_Get(var Data; Count: word); virtual;
    procedure Buf_Put(const Data; Count: word); virtual;
    procedure Clear; virtual;
    function  Size: longint; virtual;
   private
    Position :longint;
   end;

   PVector = ^TVector;
   TVector = object(TObject)
    procedure Del(Addr :longint); virtual;
    procedure Get(Addr :longint; var Data); virtual;
    procedure Ins(Addr :longint; const Data); virtual;
    procedure Put(Addr :longint; const Data); virtual;
   end;

  const

   err_IdtDouble      = 25;
   err_StackFull      = 26;
   err_Abstract       = 27;
   err_QueueFull      = 28;
   err_QueueEmpty     = 29;

   TObject_Vmt        = 4;
   TObject_Done       = TObject_Vmt + 4;
   TObject_Data       = TObject_Vmt + 8;
   TObject_Load       = TObject_Vmt + 12;
   TObject_Store      = TObject_Vmt + 16;
   TObject_Top        = TObject_Vmt + 20;

   IDT_Nul            = 1;

   st_Ok              =  0;
   st_Error           = -1;
   st_InitError       = -2;
   st_ReadError       = -3;
   st_WriteError      = -4;
   st_GetError        = -5;
   st_PutError        = -6;

   TChannel_BufGet    = TObject_Top;
   TChannel_BufPut    = TObject_Top + 4;
   TChannel_Clear     = TObject_Top + 8;
   TChannel_Error     = TObject_Top + 12;
   TChannel_Flush     = TObject_Top + 16;
   TChannel_ErrorProc  : procedure (const Channel :TChannel) = nil;

   procedure Abstract;
   function  Buf_Equals(const Buf1,Buf2; Count :word) :boolean;
   procedure Buf_Copy(const Source; var Dest; Count :word);
   function  Long_Mul(X, Y: integer): longint; inline($5A/$58/$F7/$EA);
   function  Long_Div(X: longint; Y: integer): integer; inline($59/$58/$5A/$F7/$F9);
   function  Obj_Size(Obj :PObject) :longint;
   procedure Register_Nul;
   procedure Register_Type(IDT, VMT :word; Load, Store :pointer);
   procedure RunError(Code : byte);
   procedure Str_Del(Str :PString);
   function  Str_New(const Str :string) :PString;

  {end interface}