 {      旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        �                                           �
        �           E a s t   S t u d i o           �
        �                                           �
        �              U M e n u    2.0             �
        �                                           �
        �       Copyright (c)  S.Novak  1996        �
        �             (054) 33-35-94                �
        �                                           �
        �               (interface)                 �
        �                                           �
        읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      }

  unit UMenu;

   {$S-,B-,V-,R-,I-,X+}

  interface

   uses

    UObject, UEvent, UView, UControl;

   const

    mn_Not       = $00;
    mn_Command   = $01;
    mn_Disabled  = $02;
    mn_Line      = $04;
    mn_SubMenu   = $08;
    mn_Visible   = $10;

   type

    PMenuTree = ^TMenuTree;

    PMenuItem = ^TMenuItem;
    TMenuItem = record
     Command: word;
     KeyCode: word;
     Name: PString;
     Next: PMenuItem;
     case State: byte of
      mn_Command: (Param: PString);
      mn_SubMenu: (List: PMenuTree);
    end;


    TMenuTree = object(TObject)
     Item_First: PMenuItem;
     Item_Def: PMenuItem;
    {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
     constructor Init(AItem: PMenuItem);
     destructor Done;virtual;
    {Me獸ㅻ 承�젪ゥ�⑨ c�ⓤぎ� 뤵�も�� (Item)}
     function  Item_Prev(MenuItem: PMenuItem): PMenuItem;
     function  Item_Case(Method: pointer): PMenuItem;
     procedure Item_For(Method: pointer);
    {Me獸ㅻ 承�젪ゥ�⑨ 꽖誓¡� (Item)}
     function  Tree_Case(Method: Pointer): PMenuItem;
     procedure Tree_For(Method: pointer);
    end;

    PMenu = ^TMenu;
    TMenu = object(TView)
     Char_Mask: byte;
     Item_Curr: PMenuItem;
     Item_List: PMenuTree;
     Menu_Next: PMenu;
     Menu_Sub: PMenu;
     Menu_Sup: PMenu;
    {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
     constructor Init(const Area: TRect);
     destructor Done; virtual;
    {뙠獸ㅻ 뒶�收め�� 룼М蟯 (HelpCtx)}
     function  HelpCtx_Get: word; virtual;
     procedure Comm_Audit(Comm: word; On: boolean); virtual;
    {뙠獸ㅻ ㄻ� 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
     function  Event_Mask: word; virtual;
    {뙠獸ㅻ 承�젪ゥ�⑨ 뤵�も젹� (Item) Д��}
     procedure Item_Area(Item: PMenuItem; var Area: TRect); virtual;
     procedure Item_Select(Item: PMenuItem);
    {뙠獸ㅻ 貰ℓ젺⑨ (New) ㏇��쵟짛收レ�音 �↔ⅹ獸�}
     function  New_Menu(Area: TRect; AList: PMenuTree): PMenu; virtual;
    {뙠獸ㅻ 렊�젩�洙� (Proc)}
     procedure Event_Diler(var E: TEvent); virtual;
     procedure On_Exposed(On: boolean); virtual State + sf_Exposed;
     procedure On_Modal(On: boolean); virtual State + sf_Modal;
    private
     function Parent_Get: PView; virtual;
     function Menu_Prev: PMenu;
     procedure DoCommand(Comm: word);
     procedure DoSelect(Forw: boolean);
     procedure DoStart(Item: PMenuItem);
     procedure DoSubMenu;
    end;

    PMenuBar = ^TMenuBar;
    TMenuBar = object(TMenu)
    {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
     constructor Init(const Area: TRect; AOptions :word; AList :PMenuTree);
    {뙠獸ㅻ 承�젪ゥ�⑨ 뤵�も젹� (Item) Д��}
     procedure Item_Area(Item: PMenuItem; var Area: TRect); virtual;
    {뙠獸ㅻ 렊�젩�洙� (Proc)}
     procedure Canvas_Paint; virtual;
     procedure Event_Diler(var E: TEvent); virtual;
    {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
     function  Style_Palette: PPalette; virtual;
    end;

    PMenuSys = ^TMenuSys;
    TMenuSys = object(TMenu)
    {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
     constructor Init(const Area: TRect; AOptions :word; const Title: string; AList: PMenuTree);
    {뙠獸ㅻ 承�젪ゥ�⑨ 뤵�も젹� (Item) Д��}
     procedure Item_Area(Item: PMenuItem; var Area: TRect); virtual;
    {뙠獸ㅻ 렊�젩�洙� (Proc)}
     procedure Canvas_Paint; virtual;
     procedure Event_Diler(var E: TEvent); virtual;
    {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
     function  Style_Palette: PPalette; virtual;
    end;

    PMenuBox = ^TMenuBox;
    TMenuBox = object(TMenu)
    {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
     constructor Init(const Area: TRect; AOptions :word; AList: PMenuTree);
    {뙠獸ㅻ �젩�瞬 � 렊쳽飡溢 (Area) �獸□젲��⑨}
     procedure Area_Check; virtual;
    {뙠獸ㅻ 承�젪ゥ�⑨ 뤵�も젹� (Item) Д��}
     procedure Item_Area(Item: PMenuItem; var Area: TRect); virtual;
    {뙠獸ㅻ 렊�젩�洙� (Proc)}
     procedure Canvas_Paint; virtual;
     procedure Event_Diler(var E: TEvent); virtual;
     procedure On_Exposed(On: boolean); virtual State + sf_Exposed;
    {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
     function  Style_Palette: PPalette; virtual;
    end;

    PHelpBar = ^THelpBar;

    PCtxItem = ^TCtxItem;
    TCtxItem = object
     Ctx: word;
     Text: PString;
     Next: PCtxItem;
     constructor Init(ACtx: word; const AText: string; ANext: PCtxItem);
     destructor Done(Parent: PHelpBar);
    end;

    THelpBar = object(TView)
     Item_Curr: PCtxItem;
     Item_First: PCtxItem;
    {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
     constructor Init(const Area: TRect;AOptions: word; List: PCtxItem);
     destructor Done; virtual;
   {뙠獸ㅻ ㄻ� 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
     function  Event_Mask: word; virtual;
   {뙠獸ㅻ 承�젪ゥ�⑨ 뤵�も젹� (Item) ぎ�收め��}
     function  Item_Last: PCtxItem;
     function  Item_Prev(Item: PCtxItem): PCtxItem;
     function  Item_Find(HelpCtx: word): PCtxItem;
     procedure Item_Ins(Item: PCtxItem);
     procedure Item_Del(Item :PCtxItem);
     procedure Item_Select(Item: PCtxItem);
    {뙠獸ㅻ 렊�젩�洙� (Proc)}
     procedure Event_Diler(var E: TEvent); virtual;
     procedure Canvas_Paint; virtual;
    {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
     function  Style_Palette: PPalette; virtual;
    end;

    PHelpBox = ^THelpBox;
    THelpBox = object(THelpBar)
     procedure Canvas_Paint; virtual;
    {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
     function  Style_Palette: PPalette; virtual;
    end;

    PHelpKey = ^THelpKey;
    THelpKey = object(THelpBar)
    {뙠獸ㅻ C�ℓ젺⑨ (Init) � P�㏅燼��⑨(Done) �き�}
     constructor Init(const Area: TRect;AOptions: word; List: PCtxItem);
   {뙠獸ㅻ ㄻ� 承�젪ゥ�⑨ 뫌〓殊詮� (Event)}
     function  Event_Mask: word; virtual;
    {뙠獸ㅻ 렊�젩�洙� (Proc)}
     procedure Event_Diler(var E: TEvent); virtual;
     procedure Canvas_Paint; virtual;
     procedure On_Down(On: boolean); virtual State + sf_Down;
    {뙠獸ㅻ ��誓ㄵゥ�⑨ 묅Œ� (Style) �き�}
     function  Style_Palette: PPalette; virtual;
    end;

   const

    cm_Menu     = 40;
    cm_MenuNext = 41;
    cm_MenuLink = 42;
    cm_MenuExec = 43;

    of_AutoOpen = of_Vacant1;
    sf_AutoOpen = sf_Vacant1;

    hc_MenuSys  = 60;

    Palette_HelpBar: string[05] = #15#8+#5+#0#5;
    Palette_HelpBox: string[05] = #15#8+#5+#0#5;
    Palette_MenuBar: string[12] = #0#0+#15#7#5+#1#1#1+#0#5+#15#1;
    Palette_MenuSys: string[12] = #0#0+#15#7#5+#0#15+#7#15#5+#0#15;
    Palette_MenuBox: string[20] = #7#8+#15#7#5+#7#15+#1#1#1+#15#1+
                                   #7#1+#0#5+#7#15;
   var

    Metric_Menu:  TPoint;

   function New_Item(const AName, AParam: string; ACommand,AKeyCode: word;
   ANext: PMenuItem): PMenuItem;
   function New_Line(ANext: PMenuItem): PMenuItem;
   function New_List(const AName: string; AHelpCtx: word; ASubMenu: PMenuTree;
   ANext: PMenuItem): PMenuItem;
   function New_Tree(AItem: PMenuItem): PMenuTree;
   function New_Ctx(Ctx:word; const Text: string; Next: PCtxItem): PCtxItem;

  {end interface}