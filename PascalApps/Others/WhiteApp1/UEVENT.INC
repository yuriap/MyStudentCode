 {      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³                                           ³
        ³     W h i t e   A p p l i c a t o r       ³
        ³                                           ³
        ³              U E v e n t   2.0            ³
        ³                                           ³
        ³       Copyright (c)  S.Novak  1995        ³
        ³                                           ³
        ³                (interface)                ³
        ³                                           ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      }

 unit UEvent;

{$X+,I-,S-,P-}

 interface

  uses

   UObject;

  const

   ev_Nothing     = $0000;
   ev_MouseDown   = $0001;
   ev_MouseUp     = $0002;
   ev_MouseMove   = $0004;
   ev_MouseAuto   = $0008;
   ev_KeyDown     = $0010;
   ev_KeyUp       = $0020;
   ev_Valid       = $0040;
   ev_Command     = $0100;
   ev_Broadcast   = $0200;
   ev_Notify      = $0400;
   ev_FreeTime    = $0800;

  type

   TSysKey = record
    Char: char;
    Supp: byte;
   end;

   TAbsKey = record
   case word of
    0:(Flag: byte; Scan: byte);
    1:(Code: word)
   end;

   PEvent = ^TEvent;
   TEvent = record
    What: word;
    case word of
     ev_Nothing :
      ();
     ev_KeyDown,
     ev_KeyUp,
     ev_Valid:
      (SysKey: TSysKey;
      AbsKey: TAbsKey;
      Status: word);
     ev_Valid,
     ev_Command,
     ev_Broadcast,
     ev_Notify:
      (Command: word;
      case word of
      0:(InfoPtr: pointer);
      1:(InfoLon: longint);
      2:(InfoInt: integer);
      3:(InfoWord: word);
      4:(InfoByte: byte);
      5:(InfoBool: boolean);
      6:(InfoChar: char));
     ev_MouseDown,
     ev_MouseUp,
     ev_MouseMove,
     ev_MouseAuto:
      (Buttons: byte;
      Double:  boolean;
      Where:   TPoint);
     ev_FreeTime:
      (FreeTime: word)
   end;

   PGenerator = ^TGenerator;
   TGenerator = object(TObject)
    constructor Init;
    destructor  Done; virtual;
    procedure Event_Clr; virtual;
    procedure Event_Get(var E: TEvent); virtual;
    procedure Event_Put(const E: TEvent); virtual;
   private
    Next: PGenerator;
    function Testor(Method: pointer): PGenerator;
   end;

   PCommander = ^TCommander;
   TCommander = object(TGenerator)
    constructor Init(ARange: byte);
    destructor  Done; virtual;
    procedure Event_Clr; virtual;
    procedure Event_Get(var E: TEvent); virtual;
    procedure Event_Put(const E: TEvent); virtual;
   private
    Queue: TQueue;
   end;

   PWord  = ^word;
   PMouseCursor = ^TMouseCursor;
   TMouseCursor = record
    Center: TPoint;
    Image: array [0..31] of word;
   end;

   PMouse = ^TMouse;
   TMouse = object(TGenerator)
    constructor Init(const Area: TRect);
    destructor  Done; virtual;
{    function  Buttons: byte;}
    procedure Area_Set(const Area: TRect);
    procedure Cursor_Hide;
    procedure Cursor_Show;
    function  Cursor_Set(const Cursor: PMouseCursor): pointer;
    procedure Cursor_Pos(var Point: TPoint);
    procedure Event_Get(var E: TEvent); virtual;
    procedure Event_Clr; virtual;
{    function  Ticks_Down: PWord;
    function  Ticks_Auto: PWord; }
   end;

   PKeyBoard = ^TKeyBoard;
   TKeyBoard = object(TGenerator)
    constructor Init;
    destructor  Done; virtual;
    procedure Click_Set(On: boolean);
    procedure Event_Clr; virtual;
    procedure Event_Get(var E: TEvent); virtual;
    procedure Speed_Set(D,S: byte);
    function  Status: PWord;
   end;

  const

   Mouse_Buttons: byte = 0;
   Mouse_Events: boolean = False;
   Mouse_Reverse: boolean = False;
   Mouse_Double: word = 8;
   Mouse_Repeat: word = 8;

   ms_LeftButton  = $01;
   ms_RightButton = $02;

   ev_Mouse       = ev_MouseDown+ev_MouseUp+ev_MouseMove+ev_MouseAuto;
   ev_Keyboard    = ev_KeyDown+ev_KeyUp;
   ev_Message     = ev_Command+ev_Broadcast+ev_Notify+ev_Valid;
   ev_AnyEvent    = $FFFF;

   ks_RightShift = $0001;
   ks_LeftShift  = $0002;
   ks_Ctrl       = $0004;
   ks_Alt        = $0008;
   ks_ScrollOn   = $0010;
   ks_NumOn      = $0020;
   ks_CapsOn     = $0040;
   ks_InsertOn   = $0080;
   ks_LeftCtrl   = $0100;
   ks_LeftAlt    = $0200;
   ks_SysReq     = $0400;
   ks_PauseOn    = $0800;
   ks_ScrollLock = $1000;
   ks_NumbLock   = $2000;
   ks_CapsLock   = $4000;
   ks_Insert     = $8000;

   kf_Char       = $0010;
   kf_Shift      = $0003;
   kf_Ctrl       = $0004;
   kf_Alt        = $0008;

   kb_Esc        = $0100;
   kb_Back       = $0E00;
   kb_Tab        = $0F00;
   kb_Enter      = $1C00;
   kb_Space      = $3900;
   kb_PrtScr     = $3700;
   kb_Ins        = $5200;
   kb_Del        = $5300;
   kb_F1         = $3B00;
   kb_F2         = $3C00;
   kb_F3         = $3D00;
   kb_F4         = $3E00;
   kb_F5         = $3F00;
   kb_F6         = $4000;
   kb_F7         = $4100;
   kb_F8         = $4200;
   kb_F9         = $4300;
   kb_F10        = $4400;
   kb_Gray5      = $4C00;
   kb_Home       = $4700;
   kb_Up         = $4800;
   kb_PgUp       = $4900;
   kb_GrayMinus  = $4A00;
   kb_Left       = $4B00;
   kb_Right      = $4D00;
   kb_GrayPlus   = $4E00;
   kb_End        = $4F00;
   kb_Down       = $5000;
   kb_PgDn       = $5100;
   kb_NoKey      = $0000;

   kb_Scan:  string =
    #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
    #0#0#0#0#0#0#0#0#0#0#0#1#0#0#0#0+
    #57#2#40#4#5#6#8#40#10#11#9#13#51#12#52#53+
    #11#2#3#4#5#6#7#8#9#10#39#39#51#13#52#53+
    #3#30#48#46#32#18#33#34#35#23#36#37#38#50#49#24+
    #25#16#19#31#20#22#47#17#45#21#44#26#43#27#7#12+
    #41#30#48#46#32#18#33#34#35#23#36#37#38#50#49#24+
    #25#16#19#31#20#22#47#17#45#21#44#26#43#27#41#0+
    #33#51#32#22#38#20#39#25#48#16#19#37#47#21#36#34+
    #35#46#49#18#30#26#17#45#23#24#27#31#50#40#52#44+
    #33#51#32#22#38#20#39#25#48#16#19#37#47#21#36#34+
    #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
    #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
    #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
    #35#46#49#18#30#26#17#45#23#24#27#31#50#40#52#44+
    #53#53#0#0#0#0#0#0#0#0#0#0#0#0#0#0;

   kb_Char:  string[127] =
    '€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ'+
    '€‚ƒ„…†‡ˆ‰Š‹Œ°±²³´µ¶·¸¹º»¼½¾¿'+
    'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÍÒÓÔÕÖ×ØÙÚÛÜİŞß'+
    '‘’“”•–—˜™š›œŸğñòòôôö÷øùúûış'#255;

   Cursor_Arrow: TMouseCursor =
    (Center:(X:0; Y:0);
    Image:(40959,36863,34815,33791,33279,33023,32895,32831,32799,32783,
    32783,32895,32831,38943,63551,63743,0,8192,12288,14336,15360,15872,
    16128,16256,16320,16352,16256,16128,9088,960,512,0));

   Cursor_Wait:  TMouseCursor =
    (Center:(X:0; Y:0);
    Image:(57351,57351,62415,62415,62415,63903,64575,64575,64575,
    63903,62415,62415,62415,62415,57351,57351,0,4080,1056,1056,2016,
    960,384,384,384,576,1056,1440,2016,2016,4080,0));

   Cursor_SizeNS: TMouseCursor =
    (Center:(X:7; Y:7);
    Image:(65535,32895,33023,33279,33279,33023,36991,47167,64541,65033,
    65281,65409,65409,65281,65025,65535,0,0,15872,15360,15360,11776,1792,
    896,448,224,116,60,60,124,0,0));

   Cursor_Hand: TMouseCursor =
    (Center:(X:3; Y:0);
    Image:(64767,63615,63615,63615,63615,63531,63489,63489,63489,
    63489,63489,49153,1,1,1,64515, 0,768,768,768,768,768,852,852,
    852,1020,1020,1020,16380,32764,504,0));

   Cursor_Size: TMouseCursor =
    (Center:(X:7; Y:7);
    Image:(65279,64639,63551,64639,64639,56439,32771,1,32771,56439,64639,
    64639,63551,64639,65279,65535,0,256,896,256,256,256,8456,32764,8456,
    256,256,256,896,256,0,0));

   function  Char_Code(Ch: char): word;
   function  Char_Scan(Ch: char): byte;
   function  UpCase(Ch: char): char;
   procedure Event_Find(var E: TEvent);

  {end inteface}
