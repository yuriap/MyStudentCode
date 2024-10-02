 {      ┌───────────────────────────────────────────┐
        │                                           │
        │      W h i t e  A p p l i c a t o r       │
        │                                           │
        │              U M e n u    2.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1995        │
        │             (054) 33-35-94                │
        │                                           │
        │               (interface)                 │
        │                                           │
        └───────────────────────────────────────────┘      }

  unit UMenu;

   {$S-,B-,V-,R-,I-,X+}

  interface

   uses

    UObject, UEvent, UView;

   const

    mn_Not       = $00;
    mn_Command   = $02;
    mn_Disabled  = $04;
    mn_Line      = $08;
    mn_SubMenu   = $20;
    mn_Visible   = $40;

   type

    PMenuTree = ^TMenuTree;

    PMenuItem = ^TMenuItem;
    TMenuItem = record
     Command: word;
     HelpCtx: word;
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
    {Методы Cоздания (Init) и Pозрушения(Done) окна}
     constructor Init(AItem: PMenuItem);
     destructor Done;virtual;
    {Meтоды управления cписком Пунктов (Item)}
     function  Item_Prev(MenuItem: PMenuItem): PMenuItem;
     function  Item_Case(Method: pointer): PMenuItem;
     procedure Item_For(Method: pointer);
    {Meтоды управления Деревом (Item)}
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
    {Методы Cоздания (Init) и Pозрушения(Done) окна}
     constructor Init(const Area: TRect);
     destructor Done; virtual;
    {Методы Контекста Помощи (HelpCtx)}
     function  HelpCtx_Get: word; virtual;
    {Методы управления Пунктами (Item) меню}
     procedure Item_Area(Item: PMenuItem; var Area: TRect); virtual;
     procedure Item_Select(Item: PMenuItem);
    {Методы создания (New) вспомагательных объектов}
     function  New_Menu(Area: TRect; AList: PMenuTree): PMenu; virtual;
    {Методы Обработки (Proc)}
     procedure Proc_Event(var E: TEvent); virtual;
     procedure Proc_State(AState: word; On: boolean); virtual;
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
    {Методы Cоздания (Init) и Pозрушения(Done) окна}
     constructor Init(const Area: TRect; AOptions :word; AList :PMenuTree);
    {Методы управления Пунктами (Item) меню}
     procedure Item_Area(Item: PMenuItem; var Area: TRect); virtual;
    {Методы Обработки (Proc)}
     procedure Proc_Paint; virtual;
     procedure Proc_Event(var E: TEvent); virtual;
    {Методы определения Стиля (Style) окна}
     function  Style_Palette: PPalette; virtual;
    end;

    PMenuSys = ^TMenuSys;
    TMenuSys = object(TMenu)
    {Методы Cоздания (Init) и Pозрушения(Done) окна}
     constructor Init(const Area: TRect; AOptions :word; const Title: string; AList: PMenuTree);
    {Методы управления Пунктами (Item) меню}
     procedure Item_Area(Item: PMenuItem; var Area: TRect); virtual;
    {Методы Обработки (Proc)}
     procedure Proc_Paint; virtual;
     procedure Proc_Event(var E: TEvent); virtual;
    {Методы определения Стиля (Style) окна}
     function  Style_Palette: PPalette; virtual;
    end;

    PMenuBox = ^TMenuBox;
    TMenuBox = object(TMenu)
    {Методы Cоздания (Init) и Pозрушения(Done) окна}
     constructor Init(const Area: TRect; AOptions :word; AList: PMenuTree);
    {Методы работы с Областью (Area) отображения}
     procedure Area_Check; virtual;
    {Методы управления Пунктами (Item) меню}
     procedure Item_Area(Item: PMenuItem; var Area: TRect); virtual;
    {Методы Обработки (Proc)}
     procedure Proc_Paint; virtual;
     procedure Proc_Event(var E: TEvent); virtual;
     procedure Proc_State(AState: word; On: boolean); virtual;
    {Методы определения Стиля (Style) окна}
     function  Style_Palette: PPalette; virtual;
    end;

   const

    cm_Menu     = 60;
    cm_MenuNext = 61;
    cm_MenuLink = 62;
    cm_MenuExec = 63;

    of_AutoOpen = of_Vacant1;
    sf_AutoOpen = sf_Vacant1;

    hc_MenuSys  = 60;

    Palette_MenuBar: string[12] = #0#0+#15#7#5+#1#1#1+#0#5+#15#1;
    Palette_MenuSys: string[12] = #0#0+#15#7#5+#0#15+#7#15#5+#0#15;
    Palette_MenuBox: string[20] = #7#8+#15#7#5+#7#15+#1#1#1+#15#1+
                                  #7#1+#0#5+#7#15;
   var

    Metric_Menu:  TPoint;

   function New_Item(const AName,AParam: string; AKeyCode,ACommand,AHelpCtx: word;
   ANext: PMenuItem): PMenuItem;
   function New_Line(ANext: PMenuItem): PMenuItem;
   function New_List(const AName: string; AHelpCtx: word; ASubMenu: PMenuTree;
   ANext: PMenuItem): PMenuItem;
   function New_Tree(AItem: PMenuItem): PMenuTree;

  {end interface}