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

 unit UWindow;

  {$S-,B-,V-,R-,I-,T-,X+,Q-}

 interface

  uses

   UObject, UEvent, UView, UDialog, UMenu;

  type

   PViewer = ^TViewer;
   TViewer = object(TGroup)
    HScrollBar: PHScrollBar;
    Scroller: PView;
    VScrollBar: PVScrollBar;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; const Box: TRect; AOptions: word);
   {Методы работы с Областью (Area) отображения}
    procedure Area_Limit(var Limit: TRect); virtual;
   {Методы работы с дочерными (Child) окнами}
    function  Child_Client :PGroup; virtual;
   {Методы создания (New) вспомагательных объектов}
    function  New_HScrollBar(const Area: TRect): PHScrollBar ; virtual;
    function  New_Scroller(const Area: TRect): PView; virtual;
    function  New_VScrollBar(const Area: TRect): PVScrollBar; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Area(const Area: TRect) ; virtual;
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Param; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Настройка Параметров (Param) Прокрутки (Scroll)}
    function  Style_Palette: PPalette; virtual;
   {Личные (Private) методы объекта}
   private
    procedure Scroller_Check;
    procedure Scroller_Locate(const Area: TRect);
   end;

   PWindow = ^TWindow;
   TWindow = object(TGroup)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; AOption :word; const Name: string);
   {Методы работы с Областью (Area) отображения}
    procedure Area_Limit(var Limit: TRect); virtual;
   {Методы работы с дочерными (Child) окнами}
    function  Child_Client: PGroup; virtual;
   {Методы манипулирования Окном}
    procedure Close; virtual;
    procedure Drag(Mode: byte; Area: TRect);
   {Методы создания (New) вспомагательных объектов}
    function  New_Corner(const Area: TRect): PView; virtual;
    function  New_Desktop(const Area: TRect): PView; virtual;
    function  New_Drager(Mode: word): PDrager; virtual;
    function  New_Frame(const Area: TRect): PView; virtual;
    function  New_KeyMax(const Area: TRect): PView; virtual;
    function  New_KeyMin(const Area: TRect): PView; virtual;
    function  New_KeyZoom(const Area: TRect): PView; virtual;
    function  New_MenuBar(const Area: TRect): PView; virtual;
    function  New_MenuTree: PMenuTree; virtual;
    function  New_MenuSys(const Area: TRect): PView; virtual;
    function  New_StatusBar(const Area: TRect): PView; virtual;
    function  New_Title(const Area: TRect; const Name: string): PView; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Area(const Area: TRect); virtual;
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
    function  Style_Palette: PPalette; virtual;
   private
    Client: PClient;
    Zoom: TRect;
    FocusTime: word;
    procedure State_Check;
   end;

   PDialog = ^TDialog;
   TDialog = object(TWindow)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; const Name: string);
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    function  Comm_Valid(Comm: word): boolean; virtual;
   end;

   PGroupBox = ^TGroupBox;
   TGroupBox = object(TGroup)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; AOptions: word);
   {Методы создания (New) вспомагательных объектов}
    function  New_Panel(const Area: TRect): PView; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
   end;

   PClock = ^TClock;
   TClock = object(TWindow)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect);
   {Методы создания (New) вспомагательных объектов}
    function  New_Desktop(const Area: TRect): PView; virtual;
   end;

  const

   cm_Close        = 80;
   cm_Drag         = 82;
   cm_Grow         = 83;
   cm_Maximize     = 84;
   cm_Minimize     = 85;
   cm_Move         = 86;
   cm_MoveGrow     = 87;
   cm_Zoom         = 88;
   cm_Yes          = 89;
   cm_No           = 90;
   cm_Next         = 91;
   cm_Prev         = 92;
   cm_FindNext     = 93;
   cm_FindPrev     = 94;
   cm_Arrange      = 95;

   hc_Close        = 80;
   hc_Drag         = 81;
   hc_Maximize     = 82;
   hc_Minimize     = 83;
   hc_Zoom         = 84;
   hc_Yes          = 84;
   hc_No           = 85;
   hc_Next         = 86;
   hc_Prev         = 87;

   of_ArrowSelect  = of_Vacant1;
   of_TabulSelect  = of_Vacant2;

   of_NoGrow       = of_Vacant1;
   of_NoMove       = of_Vacant2;
   of_NoClose      = of_Vacant3;

   sf_Minimize     = sf_Vacant2;
   sf_Maximize     = sf_Vacant3;

   mf_Warning      = $0000;
   mf_Error        = $0001;
   mf_Information  = $0002;
   mf_Confirmation = $0003;
   mf_YesNo        = $0100;
   mf_YesNoCancel  = $0200;
   mf_Ok           = $0300;

   Palette_Window:    string[2] = #8#0;
   Palette_Viewer:    string[2] = #8#15#8;

   Text_Warning:      string[32] = 'Предупреждение';
   Text_Error:        string[32] = 'Ошибка';
   Text_Information:  string[32] = 'Информация';
   Text_Confirmation: string[32] = 'Подтверждение';
   Text_Close:        string[32] = '&Закрыть';
   Text_Next:         string[32] = '&Следующий';
   Text_Size_Move:    string[32] = '&Розмерять/Тащить';
   Text_Size:         string[32] = '&Розмерять';
   Text_Move:         string[32] = '&Тащить';
   Text_Maximize:     string[32] = 'М&аксимизировать';
   Text_Minimize:     string[32] = '&Минимизировать';
   Text_Zoom:         string[32] = '&Востановить';
   Text_Clock:        string[32] = 'Часы';


   function MsgBox(Msg: string; Flag: word): word;

  var

   Metric_MsgBox :TPoint;

  {end interface}