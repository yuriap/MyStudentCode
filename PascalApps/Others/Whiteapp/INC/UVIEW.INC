 {      旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        �                                           �
        �            E a s t  S t u d i o           �
        �                                           �
        �              U V i e w    4.0             �
        �                                           �
        �       Copyright (c)  S.Novak  1996        �
        �             (054) 33-35-94                �
        �                                           �
        �               (interface)                 �
        �                                           �
        읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      }

 unit UView;

  {$S-,B-,V-,R-,I-,T-,X+}

 interface

  uses

   Graph, UObject, UGraph, UEvent;

  const

   cm_DataRead     = 01;
   cm_DataShow     = 02;
   cm_DataFind     = 03;

   cm_ChildSelect  = 04;
   cm_ChildLocate  = 05;
   cm_ChildShow    = 06;
   cm_ChildHide    = 07;
   cm_ChildPaint   = 08;
   cm_Quit         = 09;

   sf_Visible      = 00;
   sf_Exposed      = 01;
   sf_Modal        = 02;
   sf_Selected     = 03;
   sf_Active       = 04;
   sf_Disabled     = 05;
   sf_Present      = 06;
   sf_Focus        = 07;
   sf_Reserve2     = 08;
   sf_Reserve3     = 09;
   sf_Vacant1      = 10;
   sf_Vacant2      = 11;
   sf_Vacant3      = 12;
   sf_Vacant4      = 13;
   sf_Vacant5      = 14;
   sf_Vacant6      = 15;
   sf_Visual       = [sf_Exposed,sf_Visible];

   Validate        = ev_Reserve1;
   State           = ev_Reserve2;

  type

   TState = set of 1..15;

   PGroup = ^TGroup;

   PPalette = ^TPalette;
   TPalette = record
    Power :byte;
    Color: array [1..255] of byte
   end;

   PView = ^TView;
   TView  = object(TObject)
    Data_Ptr: pointer;
    GrowMode: byte;
    Options: word;
    Origin: TPoint;
    Parent: PGroup;
    Sibling_Next: PView;
    Size: TPoint;
    State: TState;
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    constructor Init(const Area: TRect);
    destructor  Done; virtual;
   {뙠獸ㅻ �젩�瞬 � 렊쳽飡溢 (Area) �獸□젲��⑨}
    procedure Area_Calc(Delta: TPoint); virtual;
    procedure Area_Free(var Area: TRect);
    procedure Area_Get(var Area: TRect);
    procedure Area_Limit(var Limit: TRect); virtual;
    procedure Area_Local(var Area: TRect);
    procedure Area_Mark(var Area: TRect); virtual;
    procedure Area_Proc(const Area: TRect); virtual;
    procedure Area_Set(const Area: TRect);
   {뙠獸ㅻ 承�젪ゥ�⑨ 빇メ獸� (Canvas)}
    procedure Canvas_Area(var Area: TRect);
    procedure Canvas_Done;
    procedure Canvas_Frame;
    procedure Canvas_Init(Area: TRect);
    procedure Canvas_Paint; virtual;
   {뙠獸ㅻ ㄻ� ぎ�循�ワ 췅� 뒶쵟�쩆Ж (Comm) }
    procedure Comm_Audit(cm_XXXX: word; On: boolean); virtual;
    procedure Comm_Enable(cm_XXXX: word; On: boolean);
    function  Comm_Valid(cm_XXXX: word) :boolean;
   {뙠獸ㅻ ㄻ� �＼�췅 꽑��音 (Data) }
    function  Data_Proc(var Data; ds_XXXX :boolean): word; virtual;
    procedure Data_Swap(ds_XXXX: boolean);
   {뙠獸ㅻ 承�젪ゥ�⑨ 꽙젷�．¡ (Dlg) 誓┬쵟}
    function  Dlg_Exec: word;
    procedure Dlg_Stop(cm_XXXX: word);
   {뙠獸ㅻ ㄻ� 롞젩�洙� (Do) 貰〓殊�) }
    procedure Do_DataFind(var E: TEvent); virtual ev_Command+cm_DataFind;
    procedure Do_DataRead(var E: TEvent); virtual ev_Command+cm_DataRead;
    procedure Do_DataShow(var E: TEvent); virtual ev_Command+cm_DataShow;
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
   {뙠獸ㅻ �∼�˙��⑨ 닱�□젲��⑨⑨ (Draw)}
    procedure Draw;
    procedure Draw_Rect(const Area: TRect);
   {뙠獸ㅻ ㄻ� 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
    procedure Event_Clr(var E: TEvent);
    procedure Event_Diler(var E: TEvent); virtual;
    procedure Event_Err(var E: TEvent); virtual;
    procedure Event_Get(ev_XXXX: word; var E: TEvent); virtual;
    function  Event_Mask: word; virtual;
    procedure Event_Put(const E: TEvent); virtual;
   {뙠獸ㅻ 뒶�收め�� 룼М蟯 (HelpCtx)}
    function  HelpCtx_Get: word; virtual;
   {뙠獸ㅻ �㎚�����⑨ 볙�˛� (Level) oき�}
    procedure Level_Over(View: PView);
    procedure Level_Top;
   {뙠獸ㅻ ㄻ� 信�젺�˚� (On) 뫌飡�輾Ł}
    procedure On_Disabled(On: boolean); virtual State + sf_Disabled;
    procedure On_Focus(On: boolean); virtual State + sf_Focus;
    procedure On_Modal(On: boolean); virtual State + sf_Modal;
    procedure On_Visible(On: boolean); virtual State + sf_Visible;
    procedure On_Selected(On: boolean); virtual State + sf_Selected;
   {뙠獸ㅻ �젩�瞬 � 맢ㄸ收レ稅º (Parent) �き��}
    function  Parent_Case(Method: pointer): PGroup;
    function  Parent_Get: PView;
    function  Parent_Is(View: PView): boolean;
    procedure Parent_Set(Owner: PGroup);
    procedure Parent_For(Method: pointer);
   {뙠獸ㅻ �誓�□젳�쥯�⑨ ぎ�西Þ졻 뮢囹� (Point)}
    procedure Point_Global(Point: TPoint; var Result: TPoint);
    function  Point_In(Point: TPoint): boolean;
    procedure Point_Local(Point: TPoint; var Result: TPoint);
   {뙠獸ㅻ ㄻ� �젩�瞬 � �き젹� 뫁飡�젹� (Subling)}
    function  Sibling_Prev: PView;
    function  Sibling_Under: PView;
    function  Sibling_Upper: PView;
   {뙠獸ㅻ ㄻ� �㎚����⑨ 뫌飡�輾⑨ (State)}
    function  State_Get(AState: TState) :boolean;
    function  State_Set(sf_XXXX: byte; On: boolean): boolean;
   {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
    function  Style_Cursor: PMouseCursor; virtual;
    function  Style_Palette: PPalette; virtual;
   {뙠獸ㅻ 承�젪ゥ�⑨ 렕��� (Wnd)}
    function  Group: boolean; virtual;
    function  Focus: boolean;
    procedure Hide;
    function  Ptr: PView;
    function  Select: boolean;
    procedure Show;
   {떒嶺瑜 (Private) Д獸ㅻ �↔ⅹ��}
   private
   {뙠獸ㅻ �젩�瞬 � 렊쳽飡溢 (Area) �獸□젲��⑨}
    procedure Area_Clip(var Area: TRect);
    procedure Area_Max(var Area: TRect);
    procedure Area_Min(var Area: TRect);
    procedure Area_Full(var Area: TRect);
   {뙠獸ㅻ 承�젪ゥ�⑨ 빇メ獸� (Canvas)}
    procedure Canvas_Free; virtual;
   {뙠獸ㅻ �젩�瞬 � ㄾ曄惜臾� (Child) �き젹�}
    function  Child_Find(Point: TPoint): PView; virtual;
    function  Child_Is(View: PView): boolean; virtual;
   {꽡��キⓥ�レ�瑜 Д獸ㅻ 뤲�黍貰˚�}
    procedure DoMark;
    procedure DoDraw;
    procedure DoHide; virtual;
    procedure DoMouseCursor;
    procedure DoShow; virtual;
   {뙠獸ㅻ �젩�瞬 � 궏齧�º� (Upper) 렕췅Ж}
    function  Upper_Clip(const Area: TRect): boolean;
    function  Upper_Case(Method: pointer): PView;
    function  Upper_UnClip(var Area: TRect): boolean;
   end;

   TPainter = procedure (View: PView);

   PPanel = ^TPanel;
   TPanel = object(TView)
    Style_Paint: TPainter;
    constructor Init(const Area: TRect; APainter: TPainter);
   {뙠獸ㅻ 承�젪ゥ�⑨ 빇メ獸� (Canvas)}
    procedure Canvas_Paint; virtual;
   {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
    function  Style_Palette: PPalette; virtual;
   end;

   PDrager = ^TDrager;
   TDrager = object(TView)
    Mode: word;
    MousePos: TPoint;
    Step: integer;
    Step_Min: integer;
    Step_Max: integer;
    View: PView;
    View_Size: TRect;
    View_Desk: TRect;
    View_Zoom: TRect;
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    constructor Init(AView: PView; Desk: TRect; dm_XXXX: word);
   {뙠獸ㅻ �젩�瞬 � 렊쳽飡溢 (Area) �獸□젲��⑨}
    procedure Area_Set(const Area: TRect);
   {뙠獸ㅻ 承�젪ゥ�⑨ 빇メ獸� (Canvas)}
    procedure Canvas_Paint; virtual;
   {뙠獸ㅻ ㄻ� 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
    procedure Do_MouseMove(var E: TEvent); virtual ev_MouseMove;
    procedure Do_MouseUp(var E: TEvent); virtual ev_MouseUp;
   {뙠獸ㅻ ㄻ� 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
    function  Event_Mask: word; virtual;
   {뙠獸ㅻ 볚�젺�˚� (On) 貰飡�輾⑨}
    procedure On_Present(On: boolean); virtual State + sf_Present;
   {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
    function  Style_Cursor: PMouseCursor; virtual;
    function  Style_Palette: PPalette; virtual;
   private
    procedure Canvas_Free; virtual;
    procedure DoHide; virtual;
    procedure DoGrow(P, S: TPoint);
   end;

   TGroup = object(TView)
    Child_Curr,
    Child_Last: PView;
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    destructor  Done; virtual;
   {뙠獸ㅻ �젩�瞬 � 렊쳽飡溢 (Area) �獸□젲��⑨}
    procedure Area_Limit(var Limit: TRect); virtual;
    procedure Area_Proc(const Area: TRect); virtual;
   {뙠獸ㅻ 承�젪ゥ�⑨ 빇メ獸� (Canvas)}
    procedure Canvas_Paint; virtual;
   {뙠獸ㅻ �젩�瞬 � ㄾ曄惜臾� (Child) �き젹�}
    function  Child_Case(Method: pointer): PView;
    function  Child_Del(View: PView): PView;
    function  Child_Exec(View: PView): word;
    function  Child_Find(Point: TPoint): PView; virtual;
    function  Child_First: PView;
    procedure Child_For(Method: pointer);
    function  Child_Ind(View: PView): word;
    function  Child_Ins(View: PView): PView;
    function  Child_Is(View: PView): boolean; virtual;
    function  Child_Ptr(Ind: word): PView;
    function  Child_Select(Forw: boolean): boolean;
    procedure Child_State(AState: word; On: boolean);
   {뙠獸ㅻ 承�젪ゥ�⑨ 뒶쵟�쩆Ж (Comm)}
    procedure Comm_Audit(cm_XXXX: word; On: boolean); virtual;
   {뙠獸ㅻ ㄻ� �＼�췅 꽑��音 (Data) }
    function  Data_Proc(var Data; ds_XXXX :boolean): word; virtual;
   {뙠獸ㅻ ㄻ� 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
    procedure Event_Diler(var E: TEvent); virtual;
    function  Event_Mask: word; virtual;
   {뙠獸ㅻ 뒶�收め�� 룼М蟯 (HelpCtx)}
    function  HelpCtx_Get: word; virtual;
   {뙠獸ㅻ 볚�젺�˚� (On) 貰飡�輾⑨}
    procedure On_Exposed(On: boolean); virtual State + sf_Exposed;
    procedure On_Focus(On: boolean); virtual State + sf_Focus;
    procedure On_Present(On: boolean); virtual State + sf_Present;
    procedure On_Visible(On: boolean); virtual State + sf_Visible;
   {뙠獸ㅻ 承�젪ゥ�⑨ 렕��� (Wnd)}
    function  Group: boolean; virtual;
   {떒嶺瑜 (Private) Д獸ㅻ �↔ⅹ��}
   private
    procedure DoDelete(View: PView);
    procedure DoInsert(Prev, View: PView);
   end;

   PProgram = ^TProgram;
   TProgram = object(TGroup)
    Panel: PPanel;
    Commander: PCommander;
    Indicator: PView;
    Keyboard: PKeyBoard;
    Mouse: PMouse;
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    constructor Init;
    destructor  Done; virtual;
   {뙠獸ㅻ 룼ㄺヮ曄�⑨ ㅰ젵´昔�}
    procedure Init_Palette; virtual;
    procedure Init_Video; virtual;
   {뙠獸ㅻ 롡か蹟��⑨ ㅰ젵´昔�}
    procedure Done_Video; virtual;
    procedure Done_Palette; virtual;
   {뙠獸ㅻ ㄻ� 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
    procedure Do_Quit(var E: TEvent); virtual ev_Command + cm_Quit;
   {뙠獸ㅻ ㄻ� 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
    procedure Event_Err(var E: TEvent); virtual;
    procedure Event_Get(ev_XXXX: word; var E: TEvent); virtual;
    procedure Event_Put(const E: TEvent); virtual;
   {뙠獸ㅻ �猶�쩆 뫌�↓��Ł (Message)}
    function  Msg_Box(const Title,Msg: string; mb_XXXX: word): word; virtual;
    procedure Msg_Err(Pos: TPoint; const Text,Color: string); virtual;
    procedure Msg_OutMem; virtual;
    function  Msg_Text(err_XXXX: integer): string; virtual;
   {뙠獸ㅻ 貰ℓ젺⑨ (New) ㏇��쵟짛收レ�音 �↔ⅹ獸�}
    function  New_Panel: PPanel; virtual;
    function  New_Commander: PCommander; virtual;
    function  New_Keyboard: PKeyBoard; virtual;
    function  New_Mouse(const Area: TRect): PMouse; virtual;
   {뙠獸ㅻ 볚�젺�˚� (On) 貰飡�輾⑨}
    procedure On_Present(On: boolean); virtual State + sf_Present;
    procedure On_Modal(On: boolean); virtual State + sf_Modal;
   {뙠獸ㅻ ��誓ㄵゥ�� 묅Œ� (Style) �き�}
    function  Style_Cursor: PMouseCursor; virtual;
   {떒嶺瑜 (Private) Д獸ㅻ �↔ⅹ��}
   private
    procedure DoHide; virtual;
    procedure DoShow; virtual;
   end;

  const

   dm_LimitLoX    = $0001;
   dm_LimitLoY    = $0002;
   dm_LimitHiX    = $0004;
   dm_LimitHiY    = $0008;
   dm_LimitAll    = $000F;
   dm_DragMove    = $0010;
   dm_DragGrow    = $0020;
   dm_DragMouse   = $0040;
   dm_DragView    = $0080;
   dm_DragEsc     = $0100;

   ds_Export      = False;
   ds_Import      = True;

   ev_BottomUp: word  = ev_Notify;
   ev_Position: word  = ev_Mouse;
   ev_TopDown: word   = ev_AnyEvent-ev_Mouse-ev_Notify;
   ev_Modal: word     = ev_AnyEvent-ev_Idle;

   gm_GrowHiX      = $01;
   gm_GrowHiY      = $02;
   gm_GrowLoX      = $04;
   gm_GrowLoY      = $08;
   gm_GrowAll      = $0F;
   gm_CenterX      = $10;
   gm_CenterY      = $20;
   gm_Vacant1      = $40;
   gm_Vacant2      = $80;

   hc_None         = 00;

   of_None         = $0000;
   of_NoSelect     = $0001;
   of_AutoHide     = $0002;
   of_PopUp        = $0004;
   of_Shadow       = $0008;
   of_Glass        = $0010;
   of_Reserve1     = $0020;
   of_Reserve2     = $0040;
   of_Reserve3     = $0080;
   of_Left         = $0100;
   of_Top          = $0200;
   of_Right        = $0400;
   of_Bottom       = $0800;
   of_Border       = $0F00;
   of_Vacant1      = $1000;
   of_Vacant2      = $2000;
   of_Vacant3      = $4000;
   of_Vacant4      = $8000;

  const

   Palette_Drager:     string[1]  = #7;
   Palette_Panel:      string[3]  = #0#0#2;
   Palette_Shadow:     byte       = 0;
   Palette_View:       string[2]  = #0#0;
   Palette_Bavel:      string[3]  = #7#15#5;

   SysFont_Style:       word       = 0;
   SysFont_Size:        word       = 0;

   Symbol:             string[13]  = '�'#9#10'?';

   LowMemMsg: procedure = nil ;

  var

   Metric_Init: procedure;
   Metric_Scr: TPoint;
   Metric_Box: TPoint;
   Metric_Shadow: TPoint;

   function  Application: PProgram;
   function  Dialog: PView;
   function  Event_Send(Whom: PView; What, Comm: word; Info: Pointer): pointer;
   procedure Process(Clock: word);

   function  Data_Find(var Data): PView;
   procedure Data_Show(var Data);
   procedure Data_Read(var Data);

   function  MessageBox(const Title,Msg: string; Flag: word): word;
   procedure MessageErr(Pos: TPoint; const Text,Color: string);

   procedure Scr_Lock;
   procedure Scr_UnLock;

   procedure Style_Fill(View: PView);
   procedure Style_Valley(View: PView);
   procedure Style_Wall(View: PView);
   procedure Style_Plato(View: PView);
   procedure Style_Canyon(View: PView);
