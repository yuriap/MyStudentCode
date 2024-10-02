 {      ┌───────────────────────────────────────────┐
        │                                           │
        │            E a s t  S t u d i o           │
        │                                           │
        │              U V i e w    4.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1996        │
        │             (054) 33-35-94                │
        │                                           │
        │               (interface)                 │
        │                                           │
        └───────────────────────────────────────────┘      }

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
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect);
    destructor  Done; virtual;
   {Методы работы с Областью (Area) отображения}
    procedure Area_Calc(Delta: TPoint); virtual;
    procedure Area_Free(var Area: TRect);
    procedure Area_Get(var Area: TRect);
    procedure Area_Limit(var Limit: TRect); virtual;
    procedure Area_Local(var Area: TRect);
    procedure Area_Mark(var Area: TRect); virtual;
    procedure Area_Proc(const Area: TRect); virtual;
    procedure Area_Set(const Area: TRect);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Area(var Area: TRect);
    procedure Canvas_Done;
    procedure Canvas_Frame;
    procedure Canvas_Init(Area: TRect);
    procedure Canvas_Paint; virtual;
   {Методы для контроля над Командами (Comm) }
    procedure Comm_Audit(cm_XXXX: word; On: boolean); virtual;
    procedure Comm_Enable(cm_XXXX: word; On: boolean);
    function  Comm_Valid(cm_XXXX: word) :boolean;
   {Методы для обмена Данных (Data) }
    function  Data_Proc(var Data; ds_XXXX :boolean): word; virtual;
    procedure Data_Swap(ds_XXXX: boolean);
   {Методы управления Диалогово (Dlg) режима}
    function  Dlg_Exec: word;
    procedure Dlg_Stop(cm_XXXX: word);
   {Методы для Оработки (Do) событий) }
    procedure Do_DataFind(var E: TEvent); virtual ev_Command+cm_DataFind;
    procedure Do_DataRead(var E: TEvent); virtual ev_Command+cm_DataRead;
    procedure Do_DataShow(var E: TEvent); virtual ev_Command+cm_DataShow;
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
   {Методы обновления Изображенияия (Draw)}
    procedure Draw;
    procedure Draw_Rect(const Area: TRect);
   {Методы для управления Событиями (Event)}
    procedure Event_Clr(var E: TEvent);
    procedure Event_Diler(var E: TEvent); virtual;
    procedure Event_Err(var E: TEvent); virtual;
    procedure Event_Get(ev_XXXX: word; var E: TEvent); virtual;
    function  Event_Mask: word; virtual;
    procedure Event_Put(const E: TEvent); virtual;
   {Методы Контекста Помощи (HelpCtx)}
    function  HelpCtx_Get: word; virtual;
   {Методы измененния Уровня (Level) oкна}
    procedure Level_Over(View: PView);
    procedure Level_Top;
   {Методы для установки (On) Состояний}
    procedure On_Disabled(On: boolean); virtual State + sf_Disabled;
    procedure On_Focus(On: boolean); virtual State + sf_Focus;
    procedure On_Modal(On: boolean); virtual State + sf_Modal;
    procedure On_Visible(On: boolean); virtual State + sf_Visible;
    procedure On_Selected(On: boolean); virtual State + sf_Selected;
   {Методы работы с Родительским (Parent) окном}
    function  Parent_Case(Method: pointer): PGroup;
    function  Parent_Get: PView;
    function  Parent_Is(View: PView): boolean;
    procedure Parent_Set(Owner: PGroup);
    procedure Parent_For(Method: pointer);
   {Методы преобразования координат Точки (Point)}
    procedure Point_Global(Point: TPoint; var Result: TPoint);
    function  Point_In(Point: TPoint): boolean;
    procedure Point_Local(Point: TPoint; var Result: TPoint);
   {Методы для работы с окнами Сестрами (Subling)}
    function  Sibling_Prev: PView;
    function  Sibling_Under: PView;
    function  Sibling_Upper: PView;
   {Методы для изменения Состояния (State)}
    function  State_Get(AState: TState) :boolean;
    function  State_Set(sf_XXXX: byte; On: boolean): boolean;
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
    function  Style_Palette: PPalette; virtual;
   {Методы управления Окном (Wnd)}
    function  Group: boolean; virtual;
    function  Focus: boolean;
    procedure Hide;
    function  Ptr: PView;
    function  Select: boolean;
    procedure Show;
   {Личные (Private) методы объекта}
   private
   {Методы работы с Областью (Area) отображения}
    procedure Area_Clip(var Area: TRect);
    procedure Area_Max(var Area: TRect);
    procedure Area_Min(var Area: TRect);
    procedure Area_Full(var Area: TRect);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Free; virtual;
   {Методы работы с дочерными (Child) окнами}
    function  Child_Find(Point: TPoint): PView; virtual;
    function  Child_Is(View: PView): boolean; virtual;
   {Дополнительные методы Прорисовки}
    procedure DoMark;
    procedure DoDraw;
    procedure DoHide; virtual;
    procedure DoMouseCursor;
    procedure DoShow; virtual;
   {Методы работы с Верхними (Upper) Окнами}
    function  Upper_Clip(const Area: TRect): boolean;
    function  Upper_Case(Method: pointer): PView;
    function  Upper_UnClip(var Area: TRect): boolean;
   end;

   TPainter = procedure (View: PView);

   PPanel = ^TPanel;
   TPanel = object(TView)
    Style_Paint: TPainter;
    constructor Init(const Area: TRect; APainter: TPainter);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы определения Стиля (Style) окна}
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
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(AView: PView; Desk: TRect; dm_XXXX: word);
   {Методы работы с Областью (Area) отображения}
    procedure Area_Set(const Area: TRect);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для управления Событиями (Event)}
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
    procedure Do_MouseMove(var E: TEvent); virtual ev_MouseMove;
    procedure Do_MouseUp(var E: TEvent); virtual ev_MouseUp;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы Установки (On) состояния}
    procedure On_Present(On: boolean); virtual State + sf_Present;
   {Методы определения Стиля (Style) окна}
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
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    destructor  Done; virtual;
   {Методы работы с Областью (Area) отображения}
    procedure Area_Limit(var Limit: TRect); virtual;
    procedure Area_Proc(const Area: TRect); virtual;
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы работы с дочерными (Child) окнами}
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
   {Методы управления Командами (Comm)}
    procedure Comm_Audit(cm_XXXX: word; On: boolean); virtual;
   {Методы для обмена Данных (Data) }
    function  Data_Proc(var Data; ds_XXXX :boolean): word; virtual;
   {Методы для управления Событиями (Event)}
    procedure Event_Diler(var E: TEvent); virtual;
    function  Event_Mask: word; virtual;
   {Методы Контекста Помощи (HelpCtx)}
    function  HelpCtx_Get: word; virtual;
   {Методы Установки (On) состояния}
    procedure On_Exposed(On: boolean); virtual State + sf_Exposed;
    procedure On_Focus(On: boolean); virtual State + sf_Focus;
    procedure On_Present(On: boolean); virtual State + sf_Present;
    procedure On_Visible(On: boolean); virtual State + sf_Visible;
   {Методы управления Окном (Wnd)}
    function  Group: boolean; virtual;
   {Личные (Private) методы объекта}
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
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init;
    destructor  Done; virtual;
   {Методы Подключения драйверов}
    procedure Init_Palette; virtual;
    procedure Init_Video; virtual;
   {Методы Отключения драйверов}
    procedure Done_Video; virtual;
    procedure Done_Palette; virtual;
   {Методы для управления Событиями (Event)}
    procedure Do_Quit(var E: TEvent); virtual ev_Command + cm_Quit;
   {Методы для управления Событиями (Event)}
    procedure Event_Err(var E: TEvent); virtual;
    procedure Event_Get(ev_XXXX: word; var E: TEvent); virtual;
    procedure Event_Put(const E: TEvent); virtual;
   {Методы вывода Сообщений (Message)}
    function  Msg_Box(const Title,Msg: string; mb_XXXX: word): word; virtual;
    procedure Msg_Err(Pos: TPoint; const Text,Color: string); virtual;
    procedure Msg_OutMem; virtual;
    function  Msg_Text(err_XXXX: integer): string; virtual;
   {Методы создания (New) вспомагательных объектов}
    function  New_Panel: PPanel; virtual;
    function  New_Commander: PCommander; virtual;
    function  New_Keyboard: PKeyBoard; virtual;
    function  New_Mouse(const Area: TRect): PMouse; virtual;
   {Методы Установки (On) состояния}
    procedure On_Present(On: boolean); virtual State + sf_Present;
    procedure On_Modal(On: boolean); virtual State + sf_Modal;
   {Методы определени Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
   {Личные (Private) методы объекта}
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

   Symbol:             string[13]  = '√'#9#10'?';

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
