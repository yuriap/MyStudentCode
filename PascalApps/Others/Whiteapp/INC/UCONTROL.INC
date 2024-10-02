
 {      ┌───────────────────────────────────────────┐
        │                                           │
        │           E a s t   S t u d i o           │
        │                                           │
        │           U C o n t r o l  4.0            │
        │                                           │
        │       Copyright (c)  S.Novak  1996        │
        │             (054) 33-35-94                │
        │                                           │
        │              (interface)                  │
        │                                           │
        └───────────────────────────────────────────┘      }

 unit UControl;

  {$S-,B-,V-,R-,I-,T-,X+,N+,L+}

 interface

  uses

   Graph, UObject, UEvent, UView;

  const

   cm_RadioOff     = 20;
   cm_DefValid     = 21;
   cm_Ok           = 22;
   cm_Cancel       = 23;
   cm_Pressed      = 24;
   cm_TextChg      = 25;
   cm_TextEnt      = 26;
   cm_ScrollChg    = 27;
   cm_ScrollEnt    = 28;
   cm_Back         = 29;
   cm_Forw         = 30;
   cm_ItemChg      = 31;
   cm_ItemEnt      = 32;
   cm_UnDrap       = 33;
   cm_ListChg      = 34;
   cm_Check        = 34;

   sf_Down         = sf_Vacant1;
   sf_Check        = sf_Vacant2;
   sf_Default      = sf_Vacant2;
   sf_Red          = sf_Vacant1;
   sf_Yellow       = sf_Vacant2;
   sf_Green        = sf_Vacant3;

  type

   PPressor = ^TPressor;
   TPressor = object(TView)
    Command: word;
    Text: PString;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area :TRect; const AText: string);
    destructor Done; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы для установки (On) Состояний}
    procedure On_Disabled(On: boolean); virtual State + sf_Disabled;
    procedure On_Down(On: boolean); virtual State + sf_Down;
   {Действие по нажаитю (Pressed)}
    procedure Pressed; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
   {Методы управления Текстом (Text)}
    procedure Text_Set(const AText: string);
   end;

   PKey = ^TKey;
   TKey = object(TPressor)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string; cm_XXXX, of_XXXX: word);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для контроля над Командами (Comm) }
    procedure Comm_Audit(cm_XXXX: word; On: boolean); virtual;
   {Методы Контекста Помощи (HelpCtx)}
    function  HelpCtx_Get: word; virtual;
   {Действие по нажаитю (Pressed)}
    procedure Pressed; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PButton = ^TButton;
   TButton = object(TKey)
    Char_Mask: byte;
   {Методы Cоздания (Init) окна}
    constructor Init(const Area: TRect; const AText: string; cm_XXXX: word);
    constructor InitDef(const Area: TRect; const AText: string; cm_XXXX: word);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
    procedure Do_Idle(var E: TEvent); virtual ev_Idle+ 1;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
    procedure On_Active(On: boolean); virtual State + sf_Active;
    procedure On_Default(On: boolean); virtual State + sf_Default;
    procedure On_Disabled(On: boolean); virtual State + sf_Disabled;
    procedure On_Focus(On: boolean); virtual State + sf_Focus;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PCheckBox = ^TCheckBox;
   TCheckBox = object(TPressor)
    Char_Mask: byte;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string);
    constructor InitOn(const Area: TRect; const AText: string);
   {Методы работы с Областью (Area) отображения}
    procedure Area_Check(var Area: TRect); virtual;
    procedure Area_Mark(var Area: TRect); virtual;
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы обработки "Галочки" (Check)}
    function  Check_Get: byte; virtual;
   {Методы для обмена Данных (Data) }
    function  Data_Proc(var Data; ds_XXXX: boolean): word; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы для установки (On) Состояний}
    procedure On_Check(On: boolean); virtual State + sf_Check;
   {Действие по нажаитю (Pressed)}
    procedure Pressed; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
    function  Style_Symbol: char; virtual;
   end;

   PRadioBox = ^TRadioBox;
   TRadioBox = object(TCheckBox)
    Master: PView;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string; AMaster: PView);
    constructor InitAuto(const Area: TRect; const AText: string; AMaster: PView);
    constructor InitOn(const Area: TRect; const AText: string; AMaster: PView);
   {Методы для Оработки (Do) событий) }
    procedure Do_RadioOff(var E: TEvent); virtual ev_Command+cm_RadioOff;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы для установки (On) Состояний}
    procedure On_Selected(On: boolean); virtual State + sf_Selected;
   {Действие по нажаитю (Pressed)}
    procedure Pressed; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
    function  Style_Symbol: char; virtual;
   end;

   PSensor = ^TSensor;
   TSensor = object(TView)
    Command: word;
    constructor Init(const Area: TRect);
   {Методы для контроля над Командами (Comm) }
    procedure Comm_Audit(cm_XXXX: word; On: boolean); virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы Контекста Помощи (HelpCtx)}
    function  HelpCtx_Get: word; virtual;
   {Действие по нажаитю (Pressed)}
    procedure Pressed; virtual;
   end;

   PCorner = ^TCorner;
   TCorner = object(TSensor)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; cm_XXXX, of_XXXX: word);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
    function  Style_Palette: PPalette; virtual;
   end;

   PTitle = ^TTitle;
   TTitle = object(TSensor)
    Text: PString;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; cm_XXXX: word; const AText: string);
    destructor Done; virtual;
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для установки (On) Состояний}
    procedure On_Active(On: boolean); virtual State + sf_Active;
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
    function  Style_Palette: PPalette; virtual;
   {Методы управления Текстом (Text)}
    procedure Text_Set(const AText: string);
   end;

   PFrame = ^TFrame;
   TFrame = object(TSensor)
    Thick: TPoint;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; cm_XXXX: word; AThick: TPoint);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Cursor: PMouseCursor; virtual;
    function  Style_Palette: PPalette; virtual;
   end;

   PLabel = ^TLabel;
   TLabel = object(TView)
    Char_Mask: byte;
    Text: PString;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string);
    constructor InitPack(const Area: TRect; const AText: string);
    destructor Done; virtual;
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
    function  Master: PView; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   {Методы управления Текстом (Text)}
    procedure Text_Set(const AText: string);
   end;

   PIndicator = ^TIndicator;
   TIndicator = object(TView)
    Value: single;
    Color: byte;
    constructor Init(const Area :TRect; AColor: byte);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для обмена Данных (Data) }
    function  Data_Proc(var Data; ds_XXXX :boolean): word; virtual;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы установки знаачения(Value)}
    procedure Value_Set(AValue: single);
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   {Личные методы}
   private
    procedure HPaint;
    procedure VPaint;
    procedure HValue_Set(AValue: single);
    procedure VValue_Set(AValue: single);
   end;

   PRemark = ^TRemark;
   TRemark = object(TView)
    Grid: TPoint;
    Text: PString;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; const AText: string; of_XXXX: word);
    destructor Done; virtual;
   {Методы работы с Областью (Area) отображения}
    procedure Area_Proc(const Area: TRect); virtual;
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы управления Холстом (Canvas)}
    procedure Grid_Calc; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   {Методы управления Текстом (Text)}
    procedure Text_Set(const AText: string);
   end;

   PPhrase = ^TPhrase;
   TPhrase = object(TRemark)
    Color :PString;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(APos: TPoint; const AText, AColor: string);
    destructor Done; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   TAttr = record
    Curr:integer;
    Pos,Home: byte;
   end;

   TForm = string[3];

   PEdit = ^TEdit;
   TEdit = object(TGroup)
    Attr: TAttr;
    Text: String;
    HelpCtx: word;
    MaxLen: byte;
    Form: TForm;
    Password: char;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; AForm: TForm; of_XXXX: word);
   {Методы для обмена Данных (Data) }
    function  Data_Proc(var Data; ds_XXXX :boolean): word; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
    procedure Do_ChildPaint(var E: TEvent); virtual ev_Notify+ cm_ChildPaint;
   {Методы обработки Ошибок (Err)}
    function  Err_Text(Code: integer): string; virtual;
    procedure Err_Proc(Pos,Code: integer); virtual;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы для форматирования (Form) текста}
    function  Form_Do(var Buff: string; const Data; var Cod: integer): byte; virtual;
    function  Form_Lng: byte; virtual;
    function  Form_UnDo(var Buff; var Pos, Code: integer): byte; virtual;
   {Методы Контекста Помощи (HelpCtx)}
    function  HelpCtx_Get: word; virtual;
   {Методы Проверки (Valid) команд}
    function  Valid_Cancel: boolean; virtual Validate + cm_Cancel;
    function  Valid_Ok: boolean; virtual Validate + cm_Ok;
   {Методы для установки (On) Состояний}
    procedure On_Focus(On: boolean); virtual State + sf_Focus;
    procedure On_Present(On: boolean); virtual State + sf_Present;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   {Методы управления Текстом (Text)}
    procedure Text_Cursor(D: integer);
    procedure Text_Delete(var SAttr: TAttr; var SText: string);
    function  Text_Entry: boolean;
    procedure Text_Ins(const S: string);
    procedure Text_Save;
    procedure Text_Scroll(D: integer);
    procedure Text_Select(H,C: integer);
    procedure Text_Set(S: string); virtual;
    function  Text_Valid(var A: TAttr; var S: string): boolean; virtual;
    function  Text_Vis: byte;
   private
    procedure Attr_Valid(var A: TAttr; var S: string);
    procedure Attr_Set(var SAttr: TAttr; var  SText: string);
   end;

   PDial = ^TDial;
   TDial = object(TView)
    Hour,Minute,Second: Word;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect);
   {Методы прорисовки Стрелок (Arrow)}
    procedure Arrow_Hour; virtual;
    procedure Arrow_Minute; virtual;
    procedure Arrow_Second; virtual;
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_Idle(var E: TEvent); virtual ev_Idle + 1;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   TCoord = record
    X,Y: real;
   end;

   TTable = array[0..0] of real;
   PTable = ^TTable;

   PGraph = ^TGraph;
   TGraph = object(TGroup)
    Min: TPoint;
    Max: TPoint;
    Name: PString;
    Range: TPoint;
    Table: PTable;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect;const ANames:string; NX,NY: integer; of_XXXX: word);
    destructor Done; virtual;
   {Методы работы с Областью (Area) отображения}
    procedure Area_Proc(const Area: TRect); virtual;
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для обмена Данных (Data) }
    function  Data_Proc(var Data; ds_XXXX: boolean): word; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_ChildPaint(var E: TEvent); virtual ev_Notify + cm_ChildPaint;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
    procedure Style_Font; virtual;
   private
    Axis: TPoint;
    EPow: TPoint;
    Scale: TCoord;
    Step: TCoord;
    procedure Metric_Step;
    procedure Metric_Scale;
    procedure Metric_Limit;
    function  SX(X: real): integer;
    function  SY(Y: real): integer;
   end;

   PSlider = ^TSlider;
   TSlider = object(TView)
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы создания (New) вспомагательных объектов}
    function  New_Drager: PDrager;
   {Методы для установки (On) Состояний}
    procedure On_Focus(On: boolean); virtual State + sf_Focus;
   {Методы определения Стиля (Style) окна}
    function Style_Palette:PPalette; virtual;
   end;

   PSliderBar = ^TSliderBar;
   TSliderBar = object(TGroup)
    Min,Max: longint;
    Step_At: longint;
    Step_Pg: longint;
    Value: longint;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; of_XXXX: word);
   {Методы работы с Областью (Area) отображения}
    procedure Area_Proc(const Area: TRect); virtual;
   {Методы работы с дочерными (Child) окнами}
    function  Child_Rail: PView;
    function  Child_Slider: PSlider;
   {Методы для обмена Данных (Data) }
    function  Data_Proc(var Data; ds_XXXX :boolean): word; virtual;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Методы Обработки (Proc)}
    procedure Do_Back(var E:TEvent);virtual ev_Notify + cm_Back;
    procedure Do_ChildLocate(var E: TEvent); virtual ev_Notify+cm_ChildLocate;
    procedure Do_Forw(var E:TEvent);virtual ev_Notify + cm_Forw;
    procedure Do_KeyDown(var E:TEvent);virtual ev_KeyDown;
    procedure Do_MouseDown(var E:TEvent);virtual ev_MouseDown;
   {Методы создания (New) вспомагательных объектов}
    function  New_Slider(const Area: TRect): PSlider; virtual;
    function  New_Rail(const Area: TRect): PView; virtual;
   {Meтоды скролингования (Scroll)}
    procedure Scroll_By(Step: longint);
    procedure Scroll_Check;
    procedure Scroll_Param(AMin,AMax,AAt,APg,AValue: longint);
    procedure Scroll_Range(AMin,AMax: longint);
    procedure Scroll_Step(APg,AAt:integer);
    procedure Scroll_Value(AValue: longint);
   {Методы управления Ползунком (Slider)}
    procedure Slider_Area(var Area: TRect); virtual;
    procedure Slider_Locate(const Area: TRect);
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   private
    function  Value_Calc: longint; virtual;
   {Meтоды скролингования (Scroll)}
    procedure Scroll_To(AValue: longint);
   end;

   PScrollBar =^ TScrollBar;
   TScrollBar = object(TSliderBar)
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; of_XXXX: word);
   {Методы создания (New) вспомагательных объектов}
    function  New_KeyBack(const Area: TRect):PView; virtual;
    function  New_KeyForw(const Area: TRect):PView; virtual;
    function  New_Rail(const Area: TRect):PView; virtual;
   {Методы управления Ползунком (Slider)}
    procedure Slider_Area(var Area: TRect); virtual;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PListData = ^TListData;
   TListData = record
    List: PCollection;
    Item: integer;
   end;

   PListBox = ^TListBox;
   TListBox = object(TGroup)
    List: PCollection;
    Item_Top: integer;
    Item_Curr: integer;
    Item_Size: integer;
    ScrollBar: PScrollBar;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(const Area: TRect; AList: PCollection; of_XXXX: word);
    destructor Done; virtual;
   {Методы работы с Областью (Area) отображения}
    procedure Area_Proc(const Area: TRect); virtual;
   {Методы для обмена Данных (Data) }
    function  Data_Proc(var Data; ds_XXXX :boolean): word; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_ChildPaint(var E: TEvent); virtual ev_Notify + cm_ChildPaint;
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
    procedure Do_MouseUp(var E: TEvent); virtual ev_MouseUp;
    procedure Do_ScrollChg(var E: TEvent); virtual ev_Notify + cm_ScrollChg;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   {Управление i-тым елементом}
    function  Item_Bottom: integer;
    function  Item_Entry(Item: integer): boolean;
    function  Item_Get(Item: integer): string;
    procedure Item_Draw(Item: integer);
    procedure Item_Scroll(Delta: integer);
    procedure Item_Select(Item: integer);
    procedure Item_Paint(const Area: TRect; Item: integer); virtual;
   {Управление списком (List) отображения}
    procedure List_Set(AList: PCollection);
   {Методы создания (New) вспомагательных объектов}
    function  New_ScrollBar: PScrollBar; virtual;
    function  New_View: PView; virtual;
   {Методы для установки (On) Состояний}
    procedure On_Focus(On: boolean); virtual State + sf_Focus;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   PComboBox = ^TComboBox;
   TComboBox = object(TEdit)
    ListBox: PListBox;
   {Методы Cоздания (Init) и Pозрушения(Done) окна}
    constructor Init(Area: TRect; AForm: TForm; of_XXXX: word; AList: PCollection);
    destructor Done; virtual;
   {Методы для Оработки (Do) событий) }
    procedure Do_ItemChg(var E: TEvent); virtual ev_Notify + cm_ItemChg;
    procedure Do_ItemEnt(var E: TEvent); virtual ev_Notify + cm_ItemEnt;
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
    procedure Do_UnDrap(var E: TEvent); virtual ev_Command+ cm_UnDrap;
   {Методы для управления Списком (List)}
    procedure List_UnDrap;
    procedure List_Set(AList: PCollection);
   {Методы создания (New) вспомагательных объектов}
    function  New_ListBox(const Area: TRect; AList: PCollection): PListBox;
    function  New_Key(const Area: TRect): PKey; virtual;
   {Методы для управления Событиями (Event)}
    function  Event_Mask: word; virtual;
   end;

   PSignal = ^TSignal;
   TSignal = object(TView)
    constructor Init(const Area: TRect; of_XXXX: word);
   {Методы управления Холстом (Canvas)}
    procedure Canvas_Paint; virtual;
   {Методы для установки (On) Состояний}
    procedure On_Green(On: boolean); virtual State + sf_Green;
    procedure On_Red(On: boolean); virtual State + sf_Red;
    procedure On_Yellow(On: boolean); virtual State + sf_Yellow;
   {Методы определения Стиля (Style) окна}
    function  Style_Palette: PPalette; virtual;
   end;

   procedure Style_Desk (View: PView);
   procedure Style_HRail(View: PView);
   procedure Style_VRail(View: PView);

  const

   hc_Ok           = cm_Ok;
   hc_Cancel       = cm_Cancel;

   of_AutoCheck    = of_Vacant2;
   of_VertDir      = of_Vacant1;
   of_AutoPress    = of_Vacant2;
   of_Default      = of_Vacant1;
   of_DoublePress  = of_Vacant1;
   of_ReadOnly     = of_Vacant1;
   of_VCenter      = of_Vacant1;

   of_NoVGrid      = of_Vacant1;
   of_NoHGrid      = of_Vacant2;
   of_NoVInd       = of_Vacant3;
   of_NoHInd       = of_Vacant4;

   Palette_Key:       string[09] = #0#00+#15#7#5+#0#5+#7#15;
   Palette_Button:    string[09] = #0#00+#15#7#5+#0#5+#7#15;
   Palette_CheckBox:  string[13] = #0#00+#15#8#5+#0#5+#7#15+#0#15+#7#15;
   Palette_RadioBox:  string[13] = #0#00+#15#8#5+#0#5+#7#15+#0#15+#0#15;
   Palette_Corner:    string[03] = #7#80+#5;
   Palette_TitleBar:  string[10] = #0#00+#1#1#1+#15+#7#7#7+#5;
   Palette_Frame:     string[05] = #15#8+#5+#15#08;
   Palette_Label:     string[05] = #7#15+#5+#0#15;
   Palette_Edit:      string[05] = #7#15+#15#7#00;
   Palette_Remark:    string[05] = #7#15+#5+#0#5;
   Palette_Indicator: string[03] = #7#15+#5;
   Palette_Dial:      string[07] = #7#15+#5+#15+#15+#15+#1;
   Palette_Rail:      string[06] = #0#00+#5#0+#15#7#0;
   Palette_Desk:      string[03] = #0#00+#5;
   Palette_Slider:    string[05] = #0#00+#15#7#5;
   Palette_SliderBar: string[02] = #7#15;
   Palette_ScrollBar: string[02] = #7#15;
   Palette_Graph :    string[12] = #7#15+#15#5#7#0+#1#2#3#4#5#6;
   Palette_ReplGreen: string[04] = #15#15+#10#15;
   Palette_ReplBlue:  string[04] = #15#15+#09#15;
   Palette_ReplRed:   string[04] = #14#14+#04#15;
   Palette_ReplBrown: string[04] = #00+#14+#00#14;
   Palette_ListBox:   string[06] = #7#15+#0#15+#15+#1;
   Palette_Signal:    string[07] = #8#15#5#12#14#10#7;

   Pattern_Desk :   FillPatternType = ($AF,$5F,$AF,$5F,$F5,$FA,$F5,$FA);
   Pattern_HRail:   FillPatternType = ($77,$77,$77,$77,$77,$77,$77,$77);
   Pattern_VRail:   FillPatternType = ($FF,$FF,$FF,$00,$FF,$FF,$FF,$00);

   Font_Graph:       word = $0402;

   Char_DefMask: byte = kb_Alt+kb_Char;

   Clipboard : string = '';

  {end interafce }

