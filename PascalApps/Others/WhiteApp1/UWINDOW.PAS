 {      ┌───────────────────────────────────────────┐
        │                                           │
        │     W h i t e   A p p l i c a t o r       │
        │                                           │
        │              U V i e w    2.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1995        │
        │             (054) 33-35-94                │
        │                                           │
        │            (implementation)               │
        │                                           │
        └───────────────────────────────────────────┘      }

  {$I UWINDOW.INC}

  implementation

   uses

    Graph, UGraph, Dos;

{Реализация объкта Просмотрщика (Viewer) }
{---------------------------------------------------------------------------}

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TViewer.Init;
    begin
     inherited Init(Area);
     Event_Mask:=ev_AnyEvent;
     Options:=of_Selectable or AOptions;
     with Area do begin
      Area_Free(Area);
      A.X:=B.X-Metric_ScrollBar.X;
      VScrollBar:=New_VScrollBar(Area);
      if VScrollBar <> nil then
      with VScrollBar^ do GrowMode:=gm_GrowLoX+gm_GrowHiY;
      Area_Free(Area);
      A.Y:=B.Y-Metric_ScrollBar.Y;
      HScrollBar:=New_HScrollBar(Area);
      if HScrollBar <> nil then
      with HScrollBar^ do GrowMode:=gm_GrowLoY+gm_GrowHiX
     end;
     Scroller:=Child_Ins(New_Scroller(Box));
     Child_Ins(HScrollBar);
     Child_Ins(VScrollBar)
    end;

{Методы работы с Областью (Area) отображения}

   procedure TViewer.Area_Limit(var Limit: TRect);
    begin
     inherited Area_Limit(Limit);
     if Scroller <> nil then  with Limit, Scroller^ do begin
      if B.X > Size.X then B.X:=Size.X;
      if B.Y > Size.Y then B.Y:=Size.Y
     end
    end;

{Методы работы с дочерными (Child) окнами}

   function TViewer.Child_Client :PGroup;
    begin
     if (Scroller <> nil) and Scroller^.Wnd_Group
     then Child_Client:=PGroup(Scroller) else Child_Client:=nil
    end;

{Методы создания (New) вспомагательных объектов}

   function TViewer.New_HScrollBar;
    begin
     New_HScrollBar:=New(PHScrollBar,Init(Area,of_Top))
    end;

   function TViewer.New_Scroller;
     var P: PView;
    begin
     P:=New(PGroupBox,Init(Area,0));
     with P^ do Options:=Options or of_TabulSelect;
     New_Scroller:=P
    end;

   function TViewer.New_VScrollBar;
    begin
     New_VScrollBar:=New(PVScrollBar,Init(Area,of_Left))
    end;

{Методы Обработки (Proc)}

   procedure TViewer.Proc_Area(const Area: TRect);
     var Rect: TRect;
    begin
     inherited Proc_Area(Area);
     Scroller_Check
    end;

   procedure TViewer.Proc_Event(var E: TEvent);

    procedure Scroller_Scroll;
      var Area: TRect;
     begin
      with Size, Scroller^,Area do begin
       if E.InfoPtr = HScrollBar
       then Open(-HScrollBar^.Value,Origin.Y,Size.X,Size.Y)
       else if E.InfoPtr = VScrollBar
       then Open(Origin.X,-VScrollBar^.Value,Size.X,Size.Y)
       else Exit;
       Scroller_Locate(Area);
       Self.Event_Clr(E)
      end
     end;

    begin
     inherited Proc_Event(E);
     if Scroller <> nil then case E.What of
      ev_Broadcast:
       if (E.Command = cm_Scroll) then Scroller_Scroll;
      ev_Notify:
       case E.Command of
        cm_Locate:
         if E.InfoPtr = Scroller then Scroller_Check;
        cm_Visual:
         if E.InfoPtr = VScrollBar
         then HScrollBar^.State_Set(sf_NoCorner,VScrollBar^.State and sf_Visible = sf_Not)
         else if E.InfoPtr = HScrollBar
         then VScrollBar^.State_Set(sf_NoCorner,HScrollBar^.State and sf_Visible = sf_Not)
       end
     end
    end;

   procedure TViewer.Proc_State(AState: word; On: boolean);
    begin
     inherited Proc_State(AState,On);
     case AState of
      sf_Present:
       if On then Scroller_Check;
      sf_Focused:
       Event_Set(ev_Focused or (ev_Mouse and not ev_MouseDown), On)
      end
    end;

   procedure TViewer.Proc_Param;
     var Page: TPoint;
    begin
     if Scroller = nil then Exit;
     Page.X:=Size.X;
     Page.Y:=Size.Y;
     if VScrollBar <> nil then Dec(Page.X,VScrollBar^.Size.X);
     if HScrollBar <> nil then Dec(Page.Y,HScrollBar^.Size.Y);
     with Size, Scroller^ do begin
      if HScrollBar <> nil then HScrollBar^.Power_Param(0,Size.X-X,-Origin.X,Page.X,Metric_Box.X);
      if VScrollBar <> nil then VScrollBar^.Power_Param(0,Size.Y-Y,-Origin.Y,Page.Y,Metric_Box.Y)
     end;
    end;

{Методы управления Прокрутчиком (Scroller)}

   procedure TViewer.Scroller_Check;
     var Rect: TRect;
    begin
     if Scroller <> nil then with Size, Rect, Scroller^ do begin
      Area_Get(Rect);
      if B.X < X then Move(X-B.X,0);
      if B.Y < Y then Move(0,Y-B.Y);
      if A.X > 0 then A.X:=0;
      if A.Y > 0 then A.Y:=0;
      Scroller_Locate(Rect)
     end;
     Proc_Param
    end;

   procedure TViewer.Scroller_Locate(const Area: TRect);
      var Save_Mask: word;
    begin
     Save_Mask:=Event_Mask;
     Event_Mask:=0;
     Scroller^.Area_Set(Area);
     Event_Mask:=Save_Mask
    end;

   function TViewer.Style_Palette: PPalette;
    begin
     Style_Palette:=pointer(@Palette_Viewer);
    end;

{Реализация объекта Окна (Window)}
{---------------------------------------------------------------------------}

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   const

    WinTime :word = 0;

   var

    WinHome :TPoint;

   constructor TWindow.Init;
    var
     Frame: PFrame;
     Title,Menu: PView;
     Rect :TRect;

    procedure Child_Key(Key :PView);
     begin
      if Key = nil then Exit;
      if Child_Ins(New_KeyZoom(Area)) <> nil then
      Child_Last^.GrowMode:=gm_GrowLoX;
      Child_Ins(Key);
      with Key^ do begin
       Options:=Options or of_AutoHide;
       Dec(Title^.Size.X,Succ(Size.X));
       GrowMode:=gm_GrowLoX;
       Area.Move(-Succ(Size.X),0)
      end
     end;

    begin
     inherited Init(Area);
     Options:=(of_Selectable+of_TopSelect+of_NoFirstClick + of_Border +of_Shadow) or AOption;
     Event_Mask:=(ev_AnyEvent-(ev_Focused or ev_Position-ev_Valid)) or ev_MouseDown;
     Area_Free(Area);
     Frame:=Child_Ins(New_Frame(Area));
     Rect:=Area;
     if Frame <> nil then with Rect, Frame^,Thick do begin
      GrowMode:=GrowMode or (gm_GrowHiX+gm_GrowHiY);
      if Self.Options and of_NoGrow = 0 then begin
       A.X:=B.X-X-Metric_ScrollBar.X;
       A.Y:=B.Y-Y-Metric_ScrollBar.Y;
       if Child_Ins(New_Corner(Rect)) <> nil then with Child_Last^ do
       GrowMode:=GrowMode or (gm_GrowLoX+gm_GrowLoY)
      end;
      Area.Grow(-X-1,-Y-1);
      Rect:=Area
     end;
     Area.B.Y:=Area.A.Y+Metric_TitleBar.Y;
     Title:=Child_Ins(New_Title(Area,Name));
     if Title <> nil then with Title^ do begin
      GrowMode:=GrowMode or gm_GrowHiX;
      Area.B.X:=Area.A.X+Metric_TitleBar.X;
      if Child_Ins(New_MenuSys(Area)) <> nil then with Child_Last^ do begin
       Inc(Title^.Origin.X,Succ(Size.X));
       Dec(Title^.Size.X,Succ(Size.X))
      end;
      if Self.Options and of_NoGrow = of_Not then begin
       Area_Get(Area);
       Area.A.X:=Area.B.X-Succ(Metric_TitleBar.X);
       Child_Key(New_KeyMin(Area));
       Child_Key(New_KeyMax(Area));
      end;
      Inc(Rect.A.Y,Succ(Size.Y))
     end;
     Client:=Child_Ins(New(PClient,Init(Rect)));
     Client^.Area_Local(Rect);
     Area:=Rect;
     Area.B.Y:=Area.A.Y+Metric_Menu.Y;
     Menu:=Insert(New_MenuBar(Area));
     if Menu <> nil then with Menu^ do begin
      GrowMode:=GrowMode or gm_GrowHiX;
      Inc(Rect.A.Y,Succ(Size.Y))
     end;
     Area:=Rect;
     Area.A.Y:=Area.B.Y-Metric_Box.Y;
     Menu:=Insert(New_StatusBar(Area));
     if Menu <> nil then with Menu^ do begin
      GrowMode:=GrowMode or (gm_GrowHiX+gm_GrowHiY);
      Dec(Rect.B.Y,Succ(Size.Y))
     end;
     with Client^ do begin
      Desktop:=Insert(New_Desktop(Rect));
      if Desktop <> nil then Desktop^.GrowMode:=gm_GrowHiX+gm_GrowHiY
     end
    end;

   procedure TWindow.Area_Limit(var Limit: TRect);
    begin
     inherited Area_Limit(Limit);
     with Limit, Parent^.Size do begin
      if B.X > X then B.X:=X;
      if B.Y > Y then B.Y:=Y
     end
    end;

{Методы работы с дочерными (Child) окнами}

   function TWindow.Child_Client: PGroup;
    begin
     Child_Client:= Client
    end;

{Методы манипулирования Окном}

   procedure TWindow.Close;
    begin
     Free
    end;

   procedure TWindow.Drag(Mode: byte; Area: TRect);
    var
     Drager: PDrager;
    begin
     Drager:=New_Drager(Mode);
     if Parent^.Child_Exec(Drager) = cm_Ok then begin
      Drager^.Area_Get(Area);
      Area_Set(Area)
     end;
     Drager^.Free
    end;

{Методы создания (New) вспомагательных объектов}

   function TWindow.New_Corner;
    begin
     with PView(New(PCorner,Init(Area)))^ do begin
      Options:=OPtions or of_Border;
      New_Corner:=Self_Ptr
     end
    end;

   function TWindow.New_Desktop(const Area :TRect): PView;
     var P: PView;
    begin
     with PView(New(PGroupBox,Init(Area,0)))^ do begin
      New_Desktop:=Self_Ptr;
      Options:=Options or of_TabulSelect
     end
    end;

   function TWindow.New_Drager(Mode: word): PDrager;
    begin
     with PDrager(New(PDrager,Build(@Self,Mode)))^ do begin
      View:=nil;
      New_Drager:=Self_Ptr
     end
    end;

   function TWindow.New_Frame;
    begin
     New_Frame:=New(PFrame,Init(Area,Metric_Frame))
    end;

   function TWindow.New_KeyMax;
    begin
     New_KeyMax:=New(PKey,Init(Area,Symbol[6],cm_Maximize))
    end;

   function TWindow.New_KeyZoom;
    begin
     New_KeyZoom:=New(PKey,Init(Area,Symbol[11],cm_Zoom))
    end;

   function TWindow.New_KeyMin;
    begin
     New_KeyMin:=New(PKey,Init(Area,Symbol[7],cm_Minimize))
    end;

   function TWindow.New_MenuBar;
    begin
     New_MenuBar:=nil
    end;

   function TWindow.New_MenuTree: PMenuTree;
     var Menu: PMenuItem;
    begin
     Menu:=nil;
     if Options and of_NoClose = 0 then
      Menu:=New_Line(New_Item(Text_Close,'Alt+F3',kf_Alt+kb_F3,cm_Close,hc_Close,Menu));
      Menu:=New_Line(New_Item(Text_Next,'F6',kb_F6,cm_Next,hc_Next,Menu));
     if Options and (of_NoGrow+of_NoMove) = 0 then
      Menu:=New_Item(Text_Size_Move,'Ctrl+F5',kf_Ctrl+kb_F5,cm_Drag,hc_Drag,Menu)
     else if Options and of_NoGrow = 0 then
     Menu:=New_Item(Text_Size,'Ctrl+F5',kf_Ctrl+kb_F5,cm_Grow,hc_Drag,Menu)
     else if Options and of_NoMove = 0 then
     Menu:=New_Item(Text_Move, 'Ctrl+F5', kf_Ctrl+kb_F5,cm_Move, hc_Drag, Menu);
     if Options and of_NoGrow = 0 then
      Menu:=New_Item(Text_Maximize, '', kb_NoKey, cm_Maximize, hc_Maximize,
      New_Item(Text_Minimize, '', kb_NoKey, cm_Minimize, hc_Minimize,Menu
     ));
     if Options and of_NoGrow = 0 then
     Menu:=New_Item(Text_Zoom, 'F5', kb_F5, cm_Zoom, hc_Zoom,Menu);
     New_MenuTree:=New_Tree(Menu)
    end;

   function TWindow.New_MenuSys;
    begin
     New_MenuSys:=New(PMenuSys,Init(Area,0,'& ',New_MenuTree))
    end;

   function TWindow.New_StatusBar;
    begin
     New_StatusBar:=nil
    end;

   function TWindow.New_Title;
    begin
     New_Title:=New(PTitleBar,Init(Area,Name))
    end;

{Методы Обработки (Proc)}

   procedure TWindow.Proc_Area(const Area: TRect);
     var Check :boolean;
    begin
     with Area, Size do Check:=(X <> B.X-A.X) or (Y <> B.Y-A.Y);
     if (State and (sf_Minimize + sf_Maximize) = 0)
     and not Zoom.Equals(Area) then Area_Get(Zoom);
     inherited Proc_Area(Area);
     if Check then State_Check
    end;

   procedure TWindow.Proc_Event(var E: TEvent);

    procedure DoArrange;
      var Area: TRect;
     begin
      if State and sf_Minimize = 0 then Exit;
      if WinHome.Y < Size.Y then begin
       Inc(WinHome.X,Size.X);
       WinHome.Y:=Parent^.Size.Y;
       if WinHome.X > Parent^.Size.X then WinHome.X:=0
      end;
      Dec(WinHome.Y,Size.Y);
      Area_Local(Area);
      with WinHome do Area.Move(X,Y);
      Area_Set(Area)
     end;

    procedure DoNext;
     begin
      E.What:=ev_Broadcast;
      E.Command:=cm_FindNext;
      E.InfoPtr:=@Self;
      Parent_Server^.Proc_Event(E);
      if E.InfoPtr <> @Self then PView(E.InfoPtr)^.Wnd_Focus;
      Event_Clr(E)
     end;

    procedure DoMenu;
     begin
      E.What:=ev_Command;
      E.Command:=cm_Menu;
      E.InfoPtr:=nil;
      Event_Put(E);
      Event_Clr(E)
     end;

    procedure DoDrag(Mode: byte);
      var Limit: TRect;
     begin
      if not Child_Is(E.InfoPtr) then Exit;
      Parent_Get^.Area_Free(Limit);
      Drag(Mode,Limit);
      Event_Clr(E)
     end;

    procedure DoClose;
     begin
      if Options and of_NoClose <> 0 then Exit;
      if not Child_Is(E.InfoPtr) then Exit;
      if State and sf_Modal <> 0 then Dlg_Stop(cm_Cancel) else
      if Comm_Valid(cm_Close) then Close;
      Event_Clr(E)
     end;

    procedure DoZoom(What: word);
      var Area: TRect;
     begin
      if not Child_Is(E.InfoPtr) then Exit;
      case What of
       cm_Zoom:
        Area_Set(Zoom);
       cm_Minimize:
        begin
         Area_Limit(Area);
         Area.Open(Origin.X, Origin.Y, Area.A.X, Area.A.Y);
         Area_Set(Area);
         WinHome.Y:=Parent^.Size.Y;
         WinHome.X:=0;
         Message(Parent_Server,ev_Broadcast,cm_Arrange,Parent_Server)
        end;
       cm_Maximize:
        with Area,Parent_Get^.Size do begin
         Self.Area_Limit(Area);
         longint(Area.A):=0;
         Move((X-B.X) div 2,(Y-B.Y) div 2);
         Self.Area_Set(Area)
        end
      end;
      Event_Clr(E)
     end;

    begin
     if (E.What = ev_Broadcast) and (E.InfoPtr <> @Self )then
     case E.Command of
      cm_FindNext:
       begin
        if PWindow(E.InfoPtr)^.FocusTime > FocusTime then E.InfoPtr:=@Self;
        Exit
       end;
      cm_Arrange:
       begin
        DoArrange;
        Exit
       end
     end;
     inherited Proc_Event(E);
     case E.What of
      ev_Command:
       case E.Command of
        cm_Next: if Child_Is(E.InfoPtr) then DoNext;
        cm_Zoom,cm_Maximize,cm_Minimize:  DoZoom(E.Command);
        cm_Grow: DoDrag(dm_DragGrow);
        cm_Move: DoDrag(dm_DragMove);
        cm_Drag: DoDrag(dm_DragGrow+dm_DragMove);
        cm_MouseGrow: DoDrag(dm_DragGrow+dm_DragMouse);
        cm_MouseMove: DoDrag(dm_DragMove+dm_DragMouse);
        cm_Close: DoClose;
       end;
      ev_KeyDown:
       case E.AbsKey.Code of
        kb_F10 : DoMenu;
        kb_Enter: if State and sf_Minimize <> 0 then Area_Set(Zoom);
       end
     end;
    end;

   procedure TWindow.Proc_State(AState: word; On: boolean);
    begin
     inherited Proc_State(AState,On);
     case AState of
      sf_Modal:
       Comm_Enable(cm_Next,not On);
      sf_Focused:
       begin
        Event_Set(ev_Focused or (ev_Mouse and not ev_MouseDown), On);
        if not On then Exit;
{$R-}   Inc(WinTime);
        FocusTime:=WinTime
       end;
      sf_Present:
       if On then begin
        Comm_Enable(cm_Close,Options and of_NoClose = of_Not);
        Comm_Enable(cm_Drag,Options and (of_NoGrow+of_NoMove) = of_Not);
        Comm_Enable(cm_Grow,Options and of_NoGrow = of_Not);
        Comm_Enable(cm_Move,Options and of_NoMove = of_Not);
        State_Check;
       end;
      sf_Minimize:
       begin
        Comm_Enable(cm_Minimize, not On);
        if On then GrowMode:=GrowMode or (gm_GrowLoY)
        else GrowMode:=GrowMode and not (gm_GrowLoY)
       end;
      sf_Maximize:
       Comm_Enable(cm_Maximize, not On);
     end
    end;

   function TWindow.Style_Palette: PPalette;
    begin
     Style_Palette:=pointer(@Palette_Window);
    end;

   procedure TWindow.State_Check;
     var Limit: TRect;
    begin
     Area_Limit(Limit);
     with Limit, Size do begin
      State_Set(sf_Minimize,(A.X = X) and (A.Y = Y));
      State_Set(sf_Maximize,(B.X = X) and (B.Y = Y));
     end
    end;

  constructor TDialog.Init(Area: TRect; const Name: string);
   begin
    inherited Init(Area,of_NoGrow,Name);
    Event_Mask:=ev_Modal
   end;

  procedure TDialog.Proc_Event(var E: TEvent);
   begin
    inherited Proc_Event(E);
    case E.What of
     ev_KeyDown:
      case E.AbsKey.Code of
       kb_Enter:
        begin
         E.What:=ev_Broadcast;
         E.Command:=cm_Default;
         E.InfoPtr:=@Self;
         Event_Put(E);
         Event_Clr(E)
        end;
       kb_Esc:
        begin
         E.What:=ev_Command;
         E.Command:=cm_Cancel;
         E.InfoPtr:=@Self;
         Event_Put(E);
         Event_Clr(E)
        end
      end;
     ev_Command:
      case E.Command of
       cm_Cancel,cm_Ok,cm_Yes,cm_No:
       if State and sf_Modal <> 0 then begin
        Dlg_Stop(E.Command);
        Event_Clr(E)
       end
      end
     end
   end;

  function TDialog.Comm_Valid(Comm: word): boolean;
   begin
    if Comm = cm_Cancel then Comm_Valid:=True
    else Comm_Valid:=inherited Comm_Valid(Comm);
   end;

{Реализация объекта Пользователя (GroupBox)}
{---------------------------------------------------------------------------}

{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TGroupBox.Init;
   begin
    inherited Init(Area);
    Options:=of_Selectable+of_ArrowSelect or AOptions;
    Event_Mask:=ev_AnyEvent;
    Area_Free(Area);
    Child_Ins(New_Panel(Area));
    if Child_Last <> nil then with Child_Last^ do begin
     GrowMode:=GrowMode or (gm_GrowHiX + gm_GrowHiY);
     Options:=Options or of_Border or Self.Options and of_Glass
    end
   end;

{Методы создания (New) вспомагательных объектов}

  function TGroupBox.New_Panel;
   begin
    New_Panel:=New(PPanel,Init(Area))
   end;

{Методы Обработки (Proc)}

  procedure TGroupBox.Proc_Event(var E: TEvent);
    var ExCurr: PView;

   function DoUp (PX,PY: integer): boolean;
     var Result: PView;
    procedure DoSelect(View: PView); far;
     begin
      with View^,Origin do if (Options and of_Selectable = 0)
      or (State and sf_Disabled <> 0) or (PY <= Y) or (PX < X) then Exit
      else if Result=nil then Result:=View else
      with Result^ do if ((Origin.Y < Y) or (Origin.X <= X))
      and (Origin.Y <= Y) then Result:=View;
     end;
    begin
     Result:=nil;
     Child_For(@DoSelect);
     DoUp:=Result <> nil;
     if Result <> nil then Result^.Wnd_Select
    end;

   function DoDn(PX,PY: integer): boolean;
     var Result: PView;
    procedure DoSelect(View: PView); far;
     begin
      with View^,Origin do if (Options and of_Selectable = 0)
      or (State and sf_Disabled <> 0) or (PY >= Y) or (PX > X) then Exit
      else if Result = nil then Result:=View else
      with Result^ do if ((Origin.Y >= Y) or (Origin.X >= X))
      and (Origin.Y > Y) then Result:=View
     end;
    begin
     Result:=nil;
     Child_For(@DoSelect);
     DoDn:=Result <> nil;
     if Result <> nil then Result^.Wnd_Select
    end;

   function DoLeft(PX,PY: integer): boolean;
     var Result: PView;
    procedure DoSelect(View: PView); far;
     begin
      with View^, Origin do if (Options and of_Selectable = 0) or
      (State and sf_Disabled <> 0) or (PY < Y) or (PX <= X) then Exit
      else if Result = nil then Result:=View else
      with Result^ do if ((Origin.X < X) or (Origin.Y <= Y))
      and (Origin.X <= X) then Result:=View;
     end;
    begin
     Result:=nil;
     Child_For(@DoSelect);
     DoLeft:=Result <> nil;
     if Result <> nil then Result^.Wnd_Select
    end;

   function DoRight(PX,PY: integer): boolean;
    var
     Result: PView;
    procedure DoSelect(View: PView); far;
     begin
      with View^, Origin do if (Options and of_Selectable = 0)
      or (State and sf_Disabled <> 0) or (PY > Y) or (PX >= X) then Exit
      else if Result = nil then Result:=View else
      with Result^ do if ((Origin.X > X) or (Origin.Y >= Y))
      and (Origin.X >= X) then Result:=View;
     end;
    begin
     Result:=nil;
     Child_For(@DoSelect);
     DoRight:=Result <> nil;
     if Result <> nil then Result^.Wnd_Select
    end;

   procedure TabSelect(Forw: boolean);
    begin
     if Options and of_TabulSelect = 0 then Exit;
     Child_Select(Forw);
     Event_Clr(E)
    end;

   begin
    inherited Proc_Event(E);
    if E.What = ev_KeyDown then
     case E.AbsKey.Code of
      kb_Tab,kf_Shift+kb_Tab:
       TabSelect(E.AbsKey.Code = kb_Tab);
      else if Options and of_ArrowSelect = of_Not then Exit else begin
      if Child_Curr <> nil then ExCurr:=Child_Curr else
      if Child_Last <> nil then ExCurr:=Child_Last else Exit;
      case E.AbsKey.Code of
       kf_Ctrl+kb_PgUp:
        DoDn(0,0);
       kf_Ctrl+kb_PgDn:
        DoUp(Size.X,Size.Y);
       kb_Up:
        with ExCurr^.Origin do
        if DoUp(X,Y) or DoUp(X-1,Size.Y) or DoUp(Size.X,Size.Y) then;
       kb_Down:
        with ExCurr^.Origin do
        if DoDn(X,Y) or DoDn(X+1,0) or DoDn(0,0) then;
       kb_Left:
        with ExCurr^.Origin do
        if DoLeft(X,Y) or DoLeft(Size.X,Y-1) or DoLeft(Size.X,Size.Y) then;
       kb_Right:
        with ExCurr^.Origin do
        if DoRight(X,Y) or DoRight(0,Y+1) or DoRight(0,0) then;
       kb_PgUp:
        with ExCurr^.Origin do DoDn(X,0);
       kb_PgDn:
        with ExCurr^.Origin do DoUp(X,Size.Y);
       kb_Home:
        with ExCurr^.Origin do DoRight(0,Y);
       kb_End:
        with ExCurr^.Origin do DoLeft(Size.X,Y)
       else Exit;
      end;
     end;
     Event_Clr(E)
    end
   end;

  constructor TClock.Init(Area: TRect);
   begin
    inherited Init(Area,0,Text_Clock)
   end;

  function  TClock.New_Desktop(const Area: TRect): PView;
   begin
    New_Desktop:=New(PDial,Init(Area))
   end;

  function MsgBox(Msg: string; Flag: word): word;
   var
    Area: TRect;
    Dialog: PDialog;
    Title: string;
    W: integer;
   begin
    Area.B:=Metric_MsgBox;
    longint(Area.A):=0;
    case Flag and $000F of
     mf_Warning: Title:=Text_Warning;
     mf_Error: Title:=Text_Error;
     mf_Information: Title:=Text_Information;
     mf_Confirmation: Title:=Text_Confirmation;
    end;
    Dialog:=New(PDialog,Init(Area,Title));
    with Dialog^ do  begin
     GrowMode:=gm_CenterX+gm_CenterY;
     Area_Desktop(Area);
     Insert(New(PTextBox,Init(Area,Metric_Box,Msg)));
     Dec(Area.B.Y,Metric_Box.Y);
     Area.A.Y:=Area.B.Y-Metric_Box.Y;
     W:=Metric_Box.X * 4;
     with Child_Client^, Area do
     case Flag and $0F00 of
      mf_YesNo :
       begin
        A.X:=(B.X-A.X-2*W-Metric_Box.X) div 2; B.X:=A.X+W;
        Insert(New(PButton,InitDef(Area,'&Да',cm_Yes)));
        Area.Move(W+Metric_Box.Y,0);
        Insert(New(PButton,Init(Area,'&Нет',cm_No)))^.
        Parent^.Child_Select(False);
       end;
      mf_YesNoCancel :
       begin
        A.X:=(B.X-A.X-3*W-2*Metric_Box.X) div 2; B.X:=A.X+W;
        Insert(New(PButton,InitDef(Area,'&Да',cm_Yes)));
        Area.Move(W+Metric_Box.Y,0);
        Insert(New(PButton,Init(Area,'&Нет',cm_No)));
        Area.Move(W+Metric_Box.Y,0);
        Insert(New(PButton,Init(Area,'&Отказ',cm_Cancel)))^.
        Parent^.Child_Select(False);
       end;
      mf_Ok :
       begin
        A.X:=(B.X-A.X-W) div 2; B.X:=A.X+W;
        Insert(New(PButton,InitDef(Area,'&Ok',cm_Ok)));
       end
      end
    end;
    MsgBox:=Application^.Child_Exec(Dialog);
    Dispose(Dialog,Done)
   end;

  var

   ProcInit: procedure;

  procedure InitMetrics; far;
   begin
    ProcInit;
    Metric_MsgBox.X:=Metric_Box.X * 16;
    Metric_MsgBOx.Y:=Metric_Box.Y * 10
   end;

  begin
   ProcInit:=Metric_Init;
   Metric_Init:=InitMetrics
  end.

end.
