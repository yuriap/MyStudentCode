 {      ┌───────────────────────────────────────────┐
        │                                           │
        │     W h i t e   A p p l i c a t o r       │
        │                                           │
        │              U V i e w    2.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1995        │
        │             (054) 33-35-94                │
        │                                           │
        │               (interface)                 │
        │                                           │
        └───────────────────────────────────────────┘      }

 unit UView;

  {$S-,B-,V-,R-,I-,T-,X+}

 interface

  uses

   UObject, Graph, UGraph, UEvent;

  type

   PGroup = ^TGroup;
   PView = ^TView;
   PPalette = ^TPalette;

   TPalette = record
    Power :byte;
    Color: array [1..255] of byte
   end;

   TView  = object(TObject)
    Event_Mask: word;
    GrowMode: byte;
    Options: word;
    Origin: TPoint;
    Parent: PGroup;
    Sibling_Next: PView;
    Size: TPoint;
    State: word;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect);
    destructor  Done; virtual;
   {Методы работы с Областью (Area) отображения}
    procedure Area_Calc(Delta: TPoint); virtual;
    procedure Area_Free(var Area: TRect);
    procedure Area_Full(var Area: TRect);
    procedure Area_Get(var Area: TRect);
    procedure Area_Global(var Area: TRect);
    procedure Area_Limit(var Limit: TRect); virtual;
    procedure Area_Local(var Area: TRect);
    procedure Area_Mark(var Area: TRect); virtual;
    procedure Area_Set(const Area: TRect);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Area(var Area: TRect);
    procedure Canvas_Init(Area: TRect);
    procedure Canvas_Done;
   {Методы для контроля над Командами (Comm) }
    procedure Comm_Enable(Comm: word; On: boolean);  virtual;
    function  Comm_Valid(Comm: word) :boolean; virtual;
   {Методы для обмена Данных (Data) }
    procedure Data_Get(var Data); virtual;
    procedure Data_Set(const Data); virtual;
    function  Data_Size: word; virtual;
   {Методы управления Диалогово (Dlg) режима}
    function  Dlg_Exec: word;
    procedure Dlg_Stop(Comm: word); virtual;
   {Методы обновления Изображенияия (Draw)}
    procedure Draw;
    procedure Draw_Rect(const Area: TRect);
   {Методы для управления Событиями (Event)}
    procedure Event_Clr(var E: TEvent);
    procedure Event_Err(var E: TEvent); virtual;
    procedure Event_Get(Mask: word; var E: TEvent); virtual;
    procedure Event_Put(const E: TEvent); virtual;
    procedure Event_Set(Mask: word; On: boolean);
   {Методы Контекста Помощи (HelpCtx)}
    function  HelpCtx_Get: word; virtual;
   {Методы измененния Уровня (Level) Окна}
    procedure Level_Over(View: PView);
    procedure Level_Top;
   {Методы работы с Родительским (Parent) окном}
    function  Parent_Get: PView;
    function  Parent_Server: PGroup;
    function  Parent_Is(View: PView): boolean;
    procedure Parent_Set(Group: PGroup);
   {Методы преобразования координат Точки (Point)}
    procedure Point_Global(Point: TPoint; var Result: TPoint);
    procedure Point_Local(Point: TPoint; var Result: TPoint);
   {Методы Обработки (Proc)}
    procedure Proc_Area(const Area: TRect); virtual;
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Paint; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы для работы с окнами Сестрами (Subling)}
    function  Sibling_Prev: PView;
    function  Sibling_Under: PView;
    function  Sibling_Upper: PView;
   {Методы для изменения Состояния (State)}
    function  State_Get(AState: word) :boolean;
    procedure State_Set(AState: word; On: boolean);
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
    procedure Style_Font; virtual;
    function  Style_Palette: PPalette; virtual;
   {Методы управления Окном (Wnd)}
    function  Wnd_Group: boolean; virtual;
    procedure Wnd_Hide;
    function  Wnd_Focus: boolean;
    function  Wnd_Select: boolean;
    procedure Wnd_Show;
   {Личные (Private) методы объекта}
   private
    function  Child_Find(Point: TPoint): PView; virtual;
    function  Child_Is(View: PView): boolean; virtual;
   {Дополнительные методы Прорисовки}
    procedure DoMark(const Area :TRect);
    procedure DoDraw;
    procedure DoHide; virtual;
    procedure DoShow; virtual;
   {Методы работы с видимым Пространством (Space) екрана}
    procedure Space_Clip(var Area: TRect);
    procedure Space_Max(var Area: TRect);
    procedure Space_Min(var Area: TRect);
   {Методы работы с Верхними (Upper) Окнами}
    function  Upper_Clip(const Area: TRect): boolean;
    function  Upper_Case(Method: pointer): PView;
   end;

   PBackground = ^TBackground;
   TBackground = object(TView)
   {Методы Обработки (Proc) событий}
    procedure Proc_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   TGroup = object(TView)
    Child_Curr,
    Child_Last: PView;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    destructor  Done; virtual;
   {Методы работы с Областью (Area) отображения}
    procedure Area_Limit(var Limit: TRect); virtual;
    procedure Area_Desktop(var Area: TRect);
   {Методы работы с дочерными (Child) окнами}
    function  Child_Case(Method: pointer): PView;
    function  Child_Client: PGroup; virtual;
    function  Child_Del(View: PView): pointer;
    function  Child_Exec(View: PView): word;
    function  Child_Find(Point: TPoint): PView; virtual;
    function  Child_First: PView;
    procedure Child_For(Method: pointer);
    function  Child_Ind(View: PView): word;
    function  Child_Ins(View: PView): pointer;
    function  Child_Is(View: PView): boolean; virtual;
    function  Child_Ptr(Ind: word): PView;
    procedure Child_Select(Forw: boolean);
   {Методы Проверки (Valid) Команд (Comm)}
    procedure Comm_Enable(Comm: word; On: boolean);  virtual;
    function  Comm_Valid(Comm: word): boolean; virtual;
   {Методы для обмена Данных (Data) }
    procedure Data_Get(var Data); virtual;
    function  Data_Size: word; virtual;
    procedure Data_Set(const Data); virtual;
   {Методы Добавления(Insert) Удаления (Delete)}
    function  Delete(View: PView): PView;
    function  Insert(View: PView): PView;
   {Методы Контекста Помощи (HelpCtx)}
    function  HelpCtx_Get: word; virtual;
   {Методы Обработки (Proc) событий}
    procedure Proc_Area(const Area: TRect); virtual;
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Paint; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы управления Окном (Wnd)}
    function  Wnd_Group: boolean; virtual;
   {Личные (Private) методы объекта}
   private
    procedure DoDelete(View: PView);
    procedure DoInsert(Prev,View: PView);
   end;

   PClient = ^TClient;
   TClient = object(TGroup)
    Desktop :PView;
    constructor Init(const Area: TRect);
   {Методы работы с Областью (Area) отображения}
    procedure Area_Limit(var Limit: TRect); virtual;
    procedure Proc_Event(var E: TEvent); virtual;
   {Методы работы с дочерными (Child) окнами}
    function  Child_Client: PGroup; virtual;
   end;

   PProgram = ^TProgram;
   TProgram = object(TGroup)
    Commander: PCommander;
    Indicator: PView;
    KeyBoard: PKeyBoard;
    Mouse: PMouse;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init;
    destructor  Done; virtual;
   {Методы работы с дочерными (Child) окнами}
    function  Child_Client: PGroup; virtual;
   {Методы управления Диалогово (Dlg) режима}
    procedure Dlg_Stop(Comm: word); virtual;
   {Методы для управления Событиями (Event)}
    procedure Event_Err(var E: TEvent); virtual;
    procedure Event_Get(Mask: word; var E: TEvent); virtual;
    procedure Event_Put(const E: TEvent); virtual;
   {Методы создания (New) вспомагательных объектов}
    function  New_Commander: PCommander; virtual;
    function  New_Client(Area: TRect): PClient; virtual;
    function  New_Keyboard: PKeyBoard; virtual;
    function  New_Mouse(const Area: TRect): PMouse; virtual;
   {Методы иницизации (Init) Палитры (Palette)}
    procedure Palette_Init; virtual;
    procedure Palette_Done; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определени Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
   {Методы иницизации (Init) Видио (Video) режима}
    procedure Video_Init; virtual;
    procedure Video_Done; virtual;
   {Личные (Private) методы объекта}
   private
    Client: PClient;
   {Дополнительные методы Прорисовки}
    procedure DoHide; virtual;
    procedure DoShow; virtual;
   end;

   PDrager = ^TDrager;
   TDrager = object(TView)
    DragMode: word;
    Limit: TRect;
    MinStep,MaxStep: integer;
    MousePos: TPoint;
    Poligon: TRect;
    Step: integer;
    Style_Ln: word;
    Zoom: TRect;
    View: PView;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Build(AView: PView; ADragMode: word);
    constructor Init(const Area, APoligon, ALimit: TRect; ADragMode: word);
   {Методы работы с Областью (Area) отображения}
    procedure Area_Set(const Area: TRect);
   {Методы Обработки (Proc) событий}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Paint; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   private
    procedure DoHide; virtual;
   end;

  const

   cm_NoComm      = 00;
   cm_Cancel      = 01;
   cm_Quit        = 02;
   cm_Ok          = 03;
   cm_UnSelect    = 04;
   cm_Select      = 05;
   cm_Insert      = 06;
   cm_Delete      = 07;
   cm_Locate      = 08;
   cm_Visual      = 09;
   cm_Disable     = 10;
   cm_CnvInit     = 12;
   cm_CnvDone     = 13;

   dm_DragMove    = $01;
   dm_DragGrow    = $02;
   dm_DragMouse   = $04;
   dm_AutoEsc     = $08;
   dm_LimitLoX    = $10;
   dm_LimitLoY    = $20;
   dm_LimitHiX    = $40;
   dm_LimitHiY    = $80;
   dm_LimitAll    = $F0;

   err_AppNil      = 41;
   err_ModalNil    = 43;
   err_ParentNil   = 44;

   ev_Focused: word  = ev_Command+ev_KeyDown;
   ev_Position: word = ev_Mouse;
   ev_Public: word   = ev_Broadcast+ev_FreeTime+ev_Valid+ev_Notify;
   ev_Modal: word    = ev_AnyEvent-ev_FreeTime;

   gm_GrowHiX      = $01;
   gm_GrowHiY      = $02;
   gm_GrowLoX      = $04;
   gm_GrowLoY      = $08;
   gm_GrowAll      = $0F;
   gm_CenterX      = $10;
   gm_CenterY      = $20;
   gm_Vacant1      = $40;
   gm_Vacant2      = $80;

   hc_NoContext    = 00;

   of_Not          = $0000;
   of_Selectable   = $0001;
   of_AutoHide     = $0002;
   of_NoFirstClick = $0004;
   of_TopSelect    = $0008;
   of_Vacant1      = $0010;
   of_Vacant2      = $0020;
   of_Vacant3      = $0040;
   of_Vacant4      = $0080;
   of_Left         = $0100;
   of_Top          = $0200;
   of_Right        = $0400;
   of_Bottom       = $0800;
   of_Border       = $0F00;
   of_Shadow       = $1000;
   of_Glass        = $2000;
   of_VertDir      = $4000;
   of_Vacant5      = $8000;

   sf_Not          = $0000;
   sf_Active       = $0001;
   sf_Disabled     = $0002;
   sf_Exposed      = $0004;
   sf_Focused      = $0008;
   sf_Modal        = $0010;
   sf_Selected     = $0020;
   sf_Visible      = $0040;
   sf_Present      = $0080;
   sf_Reserve1     = $0100;
   sf_Reserve2     = $0200;
   sf_Vacant1      = $0400;
   sf_Vacant2      = $0800;
   sf_Vacant3      = $1000;
   sf_Vacant4      = $2000;
   sf_Vacant5      = $4000;
   sf_Vacant6      = $8000;
   sf_Visual       = sf_Exposed+sf_Visible;
   sf_Actual       = sf_Active+sf_Selected;

  const

   Palette_Drager:     string[1] = #7;
   Palette_Client:    string[3] = #2#2#2;
   Palette_View:       string[2] = #7#15;
   Palette_Shadow:     byte = 0;

   Font_Program : word = $0100;

   Symbol: string[12]  = '√'#9#10;

  var

   Metric_Init: procedure;
   Metric_Scr: TPoint;
   Metric_Box: TPoint;
   Metric_Shadow: TPoint;

   function Application: PProgram;
   function Dialog: PView;
   function Message(Whom: PView; What, Comm: word; Info: Pointer): pointer;
   procedure Scr_Lock;
   procedure Scr_UnLock;

