 {      旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        �                                           �
        �          E a s t   S t u d i o            �
        �                                           �
        �            U D i a l o g  4.0             �
        �                                           �
        �       Copyright (c)  S.Novak  1996        �
        �             (054) 33-35-94                �
        �                                           �
        �               (interface)                 �
        �                                           �
        읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      }

 unit UDialog;

  {$S-,E+,N+,B-,V-,R-,I-,T-,X+,Q-}

 interface

  uses

   UObject, UEvent, UView, UControl, UMenu, Graph;

  const

   cm_WinDrag       = 61;
   cm_WinGrow       = 62;
   cm_WinMax        = 63;
   cm_WinMin        = 64;
   cm_WinMove       = 65;
   cm_WinZoom       = 66;
   cm_WinClose      = 67;
   cm_WinNext       = 68;
   cm_WinPrev       = 69;
   cm_Yes           = 70;
   cm_No            = 71;

   sf_Minimize      = sf_Vacant2;
   sf_Maximize      = sf_Vacant3;

  type

   PWindow = ^TWindow;
   TWindow = object(TGroup)
    Title: PTitle;
    Client: PGroup;
    Desktop: PGroup;
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    constructor Init(Area: TRect; const Name: string; of_XXXX :word);
   {뙠獸ㅻ �젩�瞬 � 렊쳽飡溢 (Area) �獸□젲��⑨}
    procedure Area_Limit(var Limit: TRect); virtual;
    procedure Area_Proc(const Area: TRect); virtual;
    procedure Area_Check;
   {뙠獸ㅻ ㄻ� 롞젩�洙� (Do) 貰〓殊�) }
    procedure Do_Cancel(var E: TEvent); virtual ev_Command+cm_Cancel;
    procedure Do_KeyDown(var E: TEvent); virtual ev_KeyDown;
    procedure Do_No(var E: TEvent); virtual ev_Command+cm_No;
    procedure Do_Ok(var E: TEvent); virtual ev_Command+cm_Ok;
    procedure Do_WinClose(var E: TEvent); virtual ev_Command+cm_WinClose;
    procedure Do_WinDrag(var E: TEvent); virtual ev_Command+cm_WinDrag;
    procedure Do_WinGrow(var E: TEvent); virtual ev_Command+cm_WinGrow;
    procedure Do_WinMax(var E: TEvent); virtual ev_Command+cm_WinMax;
    procedure Do_WinMin(var E: TEvent); virtual ev_Command+cm_WinMin;
    procedure Do_WinMove(var E: TEvent); virtual ev_Command+cm_WinMove;
    procedure Do_WinZoom(var E: TEvent); virtual ev_Command+cm_WinZoom;
    procedure Do_Yes(var E: TEvent); virtual ev_Command+cm_Yes;
   {뙠獸ㅻ 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
    function  Event_Mask: word; virtual;
   {뙠獸ㅻ 貰ℓ젺⑨ (New) ㏇��쵟짛收レ�音 �↔ⅹ獸�}
    function  New_Panel(const Area: TRect): PView; virtual;
    function  New_Client(const Area: TRect): PGroup; virtual;
    function  New_Corner(const Area: TRect): PView; virtual;
    function  New_Desktop(const Area: TRect): PGroup; virtual;
    function  New_Drager(Mode: word): PDrager; virtual;
    function  New_Frame(const Area: TRect): PView; virtual;
    function  New_HelpBar(const Area: TRect): PView; virtual;
    function  New_HelpKey(const Area: TRect): PView; virtual;
    function  New_KeyMax(const Area: TRect): PView; virtual;
    function  New_KeyMin(const Area: TRect): PView; virtual;
    function  New_KeyZoom(const Area: TRect): PView; virtual;
    function  New_MenuBar(const Area: TRect): PView; virtual;
    function  New_MenuSys(const Area: TRect): PView; virtual;
    function  New_Title(const Area: TRect; const Name: string): PView; virtual;
   {뙠獸ㅻ ㄻ� 信�젺�˚� (On) 뫌飡�輾Ł}
    procedure On_Maximize(On: boolean); virtual State + sf_Maximize;
    procedure On_Minimize(On: boolean); virtual State + sf_Minimize;
    procedure On_Modal(On: boolean); virtual State + sf_Modal;
    procedure On_Present(On: boolean); virtual State + sf_Present;
   {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
    function  Style_Palette: PPalette; virtual;
   private
    Zoom: TRect;
   end;

   PWinClock = ^TWinClock;
   TWinClock = object(TWindow)
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    constructor Init(Area: TRect);
   {뙠獸ㅻ 貰ℓ젺⑨ (New) ㏇��쵟짛收レ�音 �↔ⅹ獸�}
    function  New_Panel(const Area: TRect): PView; virtual;
   end;

   PWinGraph = ^TWinGraph;
   TWinGraph = object(TWindow)
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    constructor Init(Area: TRect; const Name, ATitle:string;N,M: integer);
   {뙠獸ㅻ 貰ℓ젺⑨ (New) ㏇��쵟짛收レ�音 �↔ⅹ獸�}
    function  New_Panel(const Area: TRect): PView; virtual;
   end;

   PWinFile = ^TWinFile;
   TWinFile = object(TWindow)
    CombDrv: PComboBox;
    CombMask: PComboBox;
    EditFile: PEdit;
    ListDir: PListBox;
    ListFile: PListBox;
    RemarkDir: PRemark;
    StrRes: PString;
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    constructor Init(Name: string; Mask: PChar; APath: PString);
    destructor Done; virtual;
   {뙠獸ㅻ �젩�瞬 � 렊쳽飡溢 (Area) �獸□젲��⑨}
    procedure Area_Limit(var Limit: TRect); virtual;
   {뙠獸ㅻ ㄻ� 롞젩�洙� (Do) 貰〓殊�) }
    procedure Do_ItemChg(var E: TEvent); virtual ev_Notify + cm_ItemChg;
    procedure Do_ItemEnt(var E: TEvent); virtual ev_Notify + cm_ItemEnt;
    procedure Do_TextEnt(var E: TEvent); virtual ev_Notify + cm_TextEnt;
   {뙠獸ㅻ 貰ℓ젺⑨ (New) ㏇��쵟짛收レ�音 �↔ⅹ獸�}
    function  New_CombDrv(const Area: TRect): PComboBox; virtual;
    function  New_CombMask(const Area: TRect; Mask: PChar): PComboBox; virtual;
    function  New_ListDir(const Area: TRect): PListBox;  virtual;
    function  New_RemarkDir(const Area: TRect): PRemark; virtual;
    function  New_EditFile(const Area: TRect): PEdit; virtual;
    function  New_ListFile(const Area: TRect): PListBox; virtual;
    function  New_Label(const Area: TRect; const Text: string): PLabel; virtual;
   {뙠獸ㅻ 뤲�´夕� (Valid) ぎ쵟��}
    function  Valid_Ok:boolean; virtual Validate + cm_Ok;
   private
    Dir_Curr: string;
    procedure DoOk;
    procedure DoFocus;
    procedure DoLoad(Path: string);
   end;

   PWinPassword = ^TWinPassword;
   TWinPassword = object(TWindow)
    EditDuplicate: PEdit;
    EditOriginal: PEdit;
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    constructor Init(Name: string; Lng: byte; var Res: string);
   {뙠獸ㅻ 貰ℓ젺⑨ (New) ㏇��쵟짛收レ�音 �↔ⅹ獸�}
    function  New_Edit(const Area: TRect; Lng: byte): PEdit; virtual;
    function  New_Label(const Area: TRect; const Text: string): PView; virtual;
   {뙠獸ㅻ 뤲�´夕� (Valid) ぎ쵟��}
    function  Valid_Ok:boolean; virtual Validate + cm_Ok;
   end;

   PWinMouse = ^TWinMouse;
   TWinMouse = object(TWindow)
    SliderSpeed: PSliderBar;
    SliderClick: PSliderBar;
    CheckLeft: PCheckBox;
    ViewTest: PView;
   {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
    constructor Init(Name: string);
   {뙠獸ㅻ 貰ℓ젺⑨ (New) ㏇��쵟짛收レ�音 �↔ⅹ獸�}
    function  New_Slider(const Area: TRect): PSliderBar; virtual;
    function  New_Label(const Area: TRect; const Text: string): PView; virtual;
    function  New_Group(const Area: TRect): PView; virtual;
    function  New_CheckBox(const Area: TRect; const Text: string): PCheckBox; virtual;
   {뙠獸ㅻ ㄻ� 롞젩�洙� (Do) 貰〓殊�) }
    procedure Do_Cancel(var E: TEvent); virtual ev_Command+ cm_Cancel;
    procedure Do_Check(var E: TEvent); virtual ev_Command+ cm_Check;
    procedure Do_ChildPaint(var E: TEvent); virtual ev_Notify + cm_ChildPaint;
    procedure Do_MouseDown(var E: TEvent); virtual ev_MouseDown;
    procedure Do_ScrollChg(var E: TEvent); virtual ev_Notify + cm_ScrollChg;
   {뙠獸ㅻ ㄻ� 췅飡昔ø� 뫇�昔飡� (Speed) }
    procedure Speed_Set(ASpeed: integer);
   private
    Flag: boolean;
    Double: word;
    Speed: integer;
    Left: boolean;
   end;

   PApplication = ^TApplication;
   TApplication = object(TProgram)
   {뙠獸ㅻ ㄻ� 롞젩�洙� (Do) 貰〓殊�) }
    procedure Do_WinNext(var E: TEvent); virtual ev_Command+cm_WinNext;
    procedure Do_WinPrev(var E: TEvent); virtual ev_Command+cm_WinPrev;
   {뙠獸ㅻ �猶�쩆 뫌�↓��Ł (Message)}
    function  Msg_Box(const Title,Msg: string; mb_XXXX: word): word; virtual;
    procedure Msg_Err(Pos: TPoint; const Text,Color: string); virtual;
    procedure Msg_OutMem; virtual;
    function  Msg_Text(err_XXXX: integer): string; virtual;
   end;

  const

   of_NoGrow        = of_Vacant1;
   of_NoMove        = of_Vacant2;
   of_NoClose       = of_Vacant3;
   of_NoNext        = of_Vacant4;

   mb_Yes         = $01;
   mb_No          = $02;
   mb_Ok          = $04;
   mb_Cancel      = $08;
   mb_Red         = $10;
   mb_Yellow      = $20;
   mb_Green       = $40;

   Palette_Window:      string[02] = #8#0;
   Palette_ClickTest:   string[07] = #15#8#7#15#8#1#15;

   function  InputBox(const Title,Text: string; Form: TForm; var Res: string): word;

  {end interface}