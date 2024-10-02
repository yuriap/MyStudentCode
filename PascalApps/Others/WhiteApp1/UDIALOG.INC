 {      ┌───────────────────────────────────────────┐
        │                                           │
        │     W h i t e   A p p l i c a t o r       │
        │                                           │
        │           U D i a l o g   2.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1995        │
        │             (054) 33-35-94                │
        │                                           │
        │              (interface)                  │
        │                                           │
        └───────────────────────────────────────────┘      }

 unit UDialog;

  {$S-,B-,V-,R-,I-,T-,X+}

 interface

  uses

   UObject, UEvent, UView, Graph;

  type

   PPressor = ^TPressor;
   TPressor = object(TView)
    HelpCtx: word;
    Text: PString;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area :TRect; const AText: string);
    destructor Done; virtual;
   {Методы Контекста Помощи (HelpCtx)}
    function HelpCtx_Get: word; virtual;
   {Действие по нажаитю (Pressed)}
    procedure Pressed; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
   end;

   PKey = ^TKey;
   TKey = object(TPressor)
    Command: word;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string; Comm: word);
    constructor InitAuto(const Area: TRect; const AText: string; Comm: word);
   {Действие по нажаитю (Pressed)}
    procedure Pressed; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    procedure Style_Font; virtual;
    function  Style_Palette: PPalette; virtual;
   end;

   PButton = ^TButton;
   TButton = object(TKey)
    Char_Mask: byte;
    procedure  Area_Mark(var Area: TRect); virtual;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string; Comm: word);
    constructor InitDef(const Area: TRect; const AText: string; Comm: word);
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Paint; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    procedure Style_Font; virtual;
    function  Style_Palette: PPalette; virtual;
   end;

   PCheckBox = ^TCheckBox;
   TCheckBox = object(TPressor)
    Char_Mask: byte;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string);
    constructor InitOn(const Area: TRect; const AText: string);
    procedure Area_Check(var Area: TRect); virtual;
    procedure Area_Mark(var Area: TRect); virtual;
   {Методы обработки "Галочки" (Check)}
    function  Check_Get: byte; virtual;
   {Методы для обмена Данных (Data) }
    procedure Data_Get(var Data); virtual;
    procedure Data_Set(const Data); virtual;
    function  Data_Size: word; virtual;
   {Действие по нажаитю (Pressed)}
    procedure Pressed; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Paint; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    procedure Style_Font; virtual;
    function  Style_Palette: PPalette; virtual;
    function  Style_Symbol: char; virtual;
   end;

   PRadioBox = ^TRadioBox;
   TRadioBox = object(TCheckBox)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string);
    constructor InitAuto(const Area: TRect; const AText: string);
    constructor InitOn(const Area: TRect; const AText: string);
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    procedure Style_Font; virtual;
    function  Style_Palette: PPalette; virtual;
    function  Style_Symbol: char; virtual;
   end;

   PSensor = ^TSensor;
   TSensor = object(TView)
    Command: word;
    HelpCtx: word;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect);
   {Методы Контекста Помощи (HelpCtx)}
    function HelpCtx_Get: word; virtual;
   {Действие по нажаитю (Pressed)}
    procedure Pressed; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
   end;

   PCorner = ^TCorner;
   TCorner = object(TSensor)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect);
   {Методы Обработки (Proc)}
    procedure Proc_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
    function  Style_Palette: PPalette; virtual;
   end;

   PTitleBar = ^TTitleBar;
   TTitleBar = object(TSensor)
    Text: PString;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect;const AText: string);
    destructor Done; virtual;
   {Методы работы с Областью (Area) отображения}
    procedure Area_Limit(var Limit: TRect); virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Paint; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
    procedure Style_Font; virtual;
    function  Style_Palette: PPalette; virtual;
   end;

   PFrame = ^TFrame;
   TFrame = object(TSensor)
    Thick: TPoint;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; AThick: TPoint);
   {Методы Обработки (Proc)}
    procedure Proc_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
    function  Style_Palette: PPalette; virtual;
   end;

   PLabel = ^TLabel;
   TLabel = object(TView)
    Char_Mask: byte;
    Text: PString;
    Master: PView;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string; AMaster: PView);
    constructor InitPack(const Area: TRect; const AText: string; AMaster: PView);
    destructor Done; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Paint; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    procedure Style_Font; virtual;
    function  Style_Palette: PPalette; virtual;
   end;

   PTextBox = ^TTextBox;
   TTextBox = object(TBackground)
    Text: PString;
    Position: TPoint;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; Pos: TPoint; const AText: string);
    destructor Done; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    procedure Style_Font; virtual;
    function Style_Palette: PPalette; virtual;
   end;

   TAttr = record
    Pos,Curr,Home: integer;
   end;

   PInputBar = ^TInputBar;
   TInputBar = object(TView)
    Attr: TAttr;
    Text: PString;
    HelpCtx: word;
    MaxLen: byte;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; AMaxLen: byte);
    destructor  Done; virtual;
   {Методы работы с Областью (Area) отображения}
    procedure Area_Limit(var Limit: TRect); virtual;
   {Методы для обмена Данных (Data) }
    procedure Data_Get(var Rec); virtual;
    procedure Data_Set(const Rec); virtual;
    function  Data_Size: Word; virtual;
    function  HelpCtx_Get: word; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Paint; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    procedure Style_Font; virtual;
    function  Style_Palette: PPalette; virtual;
   {Методы управления Текстом (Text)}
    procedure Text_Cursor(C: integer);
    procedure Text_Scroll(P: integer);
    procedure Text_Select(H,C: integer);
    procedure Text_Set(S: string); virtual;
    function  Text_Vis: byte;
    function  Text_Valid(var A: TAttr; var S: string): boolean; virtual;
   private
    procedure Attr_Valid(var A: TAttr; var S: string);
   end;

   PEditBar = ^TEditBar;
   TEditBar = object(TGroup)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(R: TRect; AMaxLen: integer; AOptions: word);
   {Методы создания (New) вспомагательных объектов}
    function  New_InputBar(const Area: TRect; AMaxLen: byte): PView; virtual;
    function  New_KeyForw(const Area: TRect): PView; virtual;
    function  New_KeyBack(const Area: TRect): PView; virtual;
   end;

   PPanel = ^TPanel;
   TPanel = object(TBackground)
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PDial = ^TDial;
   TDial = object(TBackground)
    Hour,Minute,Second: Word;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect);
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
    procedure Proc_Paint; virtual;
    procedure Arrow_Hour; virtual;
    procedure Arrow_Minute; virtual;
    procedure Arrow_Second; virtual;
    function  Style_Palette: PPalette; virtual;
   end;

   PHIndicator = ^THIndicator;
   THIndicator = object(TView)
    Min,Max,Value: longint;
    Color: byte;
    constructor Init(const Area :TRect; AColor: byte);
   {Методы Обработки (Proc)}
    procedure Proc_Paint; virtual;
   {Методы настройки Прокрутки (Scroll)}
    procedure Progress_By(Step: longint);
    procedure Progress_Param(AMin,AMax,AValue:longint); virtual;
    procedure Progress_Range(AMin,AMax:longint);
    procedure Progress_To(AValue:longint);
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PVIndicator = ^TVIndicator;
   TVIndicator = object(THIndicator)
   {Методы Обработки (Proc)}
    procedure Proc_Paint; virtual;
   {Методы настройки Прокрутки (Scroll)}
    procedure Progress_Param(AMin,AMax,AValue:longint); virtual;
   end;

   PPageBar = ^TPageBar;
   TPageBar = object(TBackground)
   {Методы Обработки (Proc)}
    procedure Proc_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PHRail = ^THRail;
   THRail = object(TBackground)
   {Методы Обработки (Proc)}
    procedure Proc_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PVRail = ^TVRail;
   TVRail = object(TBackground)
   {Методы Обработки (Proc)}
    procedure Proc_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PLever = ^TLever;
   TLever = object(TView)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect);
   {Методы создания (New) вспомагательных объектов}
    function New_Drager: PDrager; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E:TEvent); virtual;
    procedure Proc_Paint; virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    function Style_Palette:PPalette; virtual;
   end;

   PSlider = ^TSlider;
   TSlider = object(TGroup)
    Min,Max,Value: longint;
    AtStep,PgStep: longint;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; AOptions: word);
   {Методы создания (New) вспомагательных объектов}
    function  New_Lever(const Area: TRect):PView; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Area(const Area: TRect); virtual;
    procedure Proc_Event(var E:TEvent);virtual;
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы настройки Рычага (Lever)}
    procedure Lever_Area(var Area: TRect); virtual;
    procedure Lever_Check;
    procedure Power_By(Step: longint);
    procedure Power_Param(AMin,AMax,AValue,APgStep,AAtStep:longint);
    procedure Power_Range(AMin,AMax:longint);
    procedure Power_Step(APgStep,AAtStep:integer);
    procedure Power_To(AValue:longint);
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   private
   {Методы управления Ползунком (Lever)}
    procedure Lever_Locate(const Area: TRect);
    function  Power_Value: longint; virtual;
   end;

   PHSlider = ^THSlider;
   THSlider = object(TSlider)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; AOptions: word);
   {Методы управления Ползунком (Lever)}
    procedure Lever_Area(var Area: TRect); virtual;
   {Методы создания (New) вспомагательных объектов}
    function  New_Rail(const Area: TRect):PView; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
   private
    function  Power_Value: longint; virtual;
   end;

   PVSlider = ^TVSlider;
   TVSlider = object(TSlider)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; AStyle: byte);
   {Методы управления Ползунком (Lever)}
    procedure Lever_Area(var Area: TRect); virtual;
   {Методы создания (New) вспомагательных объектов}
    function New_Rail(const Area: TRect):PView;
   {Методы Обработки (Proc)}
    procedure Proc_Event(var E: TEvent); virtual;
   private
    function  Power_Value: longint; virtual;
   end;

   PHScrollBar =^ THScrollBar;
   THScrollBar = object(THSlider)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; AOptions: word);
   {Методы работы с Областью (Area) отображения}
    procedure Area_Limit(var Limit: TRect); virtual;
   {Методы управления Ползунком (Lever)}
    procedure Lever_Area(var Area: TRect); virtual;
   {Методы создания (New) вспомагательных объектов}
    function  New_Corner(const Area: TRect):PView; virtual;
    function  New_KeyBack(const Area: TRect):PView; virtual;
    function  New_KeyForw(const Area: TRect):PView; virtual;
    function  New_Rail(const Area: TRect):PView; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PVScrollBar = ^TVScrollBar;
   TVScrollBar = object(TVSlider)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; AOptions: word);
   {Методы работы с Областью (Area) отображения}
    procedure Area_Limit(var Limit: TRect); virtual;
   {Методы управления Ползунком (Lever)}
    procedure Lever_Area(var Area: TRect); virtual;
   {Методы создания (New) вспомагательных объектов}
    function  New_Corner(const Area: TRect):PView; virtual;
    function  New_KeyBack(const Area: TRect):PView; virtual;
    function  New_KeyForw(const Area: TRect):PView; virtual;
    function  New_Rail(const Area: TRect):PView; virtual;
   {Методы Обработки (Proc)}
    procedure Proc_State(AState: word; On: boolean); virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

  const

   cm_Default      = 24;
   cm_IsButton     = 25;
   cm_MouseGrow    = 26;
   cm_MouseMove    = 27;
   cm_OffCheck     = 28;
   cm_Forw         = 29;
   cm_Back         = 30;
   cm_Scroll       = 31;

   of_AutoPress    = of_Vacant1;
   of_Default      = of_Vacant2;
   of_AutoCheck    = of_Vacant2;
   of_DoublePress  = of_Vacant1;
   of_PackSize     = of_Vacant2;

   sf_Down         = sf_Vacant1;
   sf_Default      = sf_Vacant2;
   sf_Check        = sf_Default;
   sf_NoBack       = sf_Vacant2;
   sf_NoForw       = sf_Vacant3;
   sf_NoCorner     = sf_Vacant4;

   Palette_Key:       string[09] = #0#0+#15#8#5+#0#5+#7#15;
   Palette_Button:    string[09] = #8#0+#15#7#5+#0#5+#7#15;
   Palette_CheckBox:  string[13] = #0#0+#15#8#5+#0#5+#7#15+#0#15+#7#15;
   Palette_RadioBox:  string[13] = #0#0+#15#8#5+#0#5+#7#15+#0#15+#0#15;
   Palette_Corner:    string[03] = #7#8+#5;
   Palette_TitleBar:  string[10] = #0#0+#1#1#1+#15+#7#7#7+#5;
   Palette_Frame:     string[04] = #15#8+#5;
   Palette_Label:     string[08] = #0#0+#5+#0#15+#7#15;
   Palette_InputBar:  string[04] = #0#0+#15#7+#0;
   Palette_Panel:     string[03] = #15#7+#5;
   Palette_TextBox:   string[05] = #15#8+#5+#0#15;
   Palette_Dial:      string[07] = #8#15#5+#15+#15+#15+#1;
   Palette_Indicator: string[03] = #8#15+#5;
   Palette_Rail:      string[06] = #8#15+#5#0+#15#7#0;
   Palette_Lever:     string[05] = #0#0+#15#8#5;
   Palette_Slider:    string[06] = #8#15+#5#0+#15#7#0;
   Palette_PageBar:   string[04] = #0#0+#5;
   Palette_ScrollBar: string[02] = #15#8;

   Pattern_PageBar: FillPatternType = ($AF,$5F,$AF,$5F,$F5,$FA,$F5,$FA);
   Pattern_HRail:   FillPatternType = ($77,$77,$77,$77,$77,$77,$77,$77);
   Pattern_VRail:   FillPatternType = ($FF,$FF,$FF,$00,$FF,$FF,$FF,$00);

   Font_Key:         word = $0100;
   Font_Button:      word = $0100;
   Font_CheckBox:    word = $0100;
   Font_RadioBox:    word = $0100;
   Font_TitleBar:    word = $0100;
   Font_Label:       word = $0100;
   Font_InputBar:    word = $0100;
   Font_TextBox:     word = $0100;

   Char_DefMask: byte = kf_Alt+kf_Char;

  var

   Metric_TitleBar: TPoint;
   Metric_Edit: TPoint;
   Metric_Frame: TPoint;
   Metric_Key: integer;
   Metric_Button: integer;
   Metric_ScrollBar: TPoint;
   Metric_Lever: integer;

  {end interafce }

