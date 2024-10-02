 {      ┌───────────────────────────────────────────┐
        │                                           │
        │          E a s t   S t u d i o            │
        │                                           │
        │            U D i a l o g  4.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1996        │
        │             (054) 33-35-94                │
        │                                           │
        │            (implementation)               │
        │                                           │
        └───────────────────────────────────────────┘      }

 {$I INC\UDialog.inc}

  implementation

   uses

    Dos, Strings, UGraph;

{Реализация типа TWindow}
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TWindow.Init;
    var
     Frame: PFrame;
     Menu: PView;
     Rect: TRect;

    procedure Child_Key(Key :PView);
     begin
      if Key = nil then Exit;
      if Child_Ins(New_KeyZoom(Area)) <> nil then
      Child_Last^.GrowMode:=gm_GrowLoX+gm_GrowHiX;
      Child_Ins(Key);
      with Key^ do begin
       Options:=Options or of_AutoHide;
       Dec(Title^.Size.X,Succ(Size.X));
       GrowMode:=gm_GrowLoX+gm_GrowHiX;
       Area.Move(-Succ(Size.X),0)
      end
     end;

    begin
     inherited Init(Area);
     Options:=(of_PopUp+of_Border+of_Shadow) or of_XXXX;
     Area_Free(Area);
     Frame:=pointer(Child_Ins(New_Frame(Area)));
     Rect:=Area;
     if Frame <> nil then with Rect, Frame^,Thick do begin
      GrowMode:=GrowMode or (gm_GrowHiX+gm_GrowHiY);
      if Self.Options and of_NoGrow = 0 then begin
       A.X:=B.X-X-Metric_Box.X;
       A.Y:=B.Y-Y-Metric_Box.Y;
       if Child_Ins(New_Corner(Rect)) <> nil then with Child_Last^ do
       GrowMode:=gm_GrowAll
      end;
      Area.Grow(-X-1,-Y-1);
      Rect:=Area
     end;
     Area.B.Y:=Area.A.Y+Metric_Box.Y;
     Title:=pointer(Child_Ins(New_Title(Area,Name)));
     if Title <> nil then with Title^ do begin
      GrowMode:=GrowMode or gm_GrowHiX;
      Area.B.X:=Area.A.X+Metric_Box.X;
      if Child_Ins(New_MenuSys(Area)) <> nil then with Child_Last^ do begin
       Inc(Title^.Origin.X,Succ(Size.X));
       Dec(Title^.Size.X,Succ(Size.X));
       Area.Move(Succ(Size.X),0)
      end;
      if Child_Ins(New_HelpKey(Area)) <> nil then with Child_Last^ do begin
       Inc(Title^.Origin.X,Succ(Size.X));
       Dec(Title^.Size.X,Succ(Size.X))
      end;
      if Self.Options and of_NoGrow = of_None then begin
       Area_Get(Area);
       Area.A.X:=Area.B.X-Succ(Metric_Box.X);
       Child_Key(New_KeyMin(Area));
       Child_Key(New_KeyMax(Area));
      end;
      Inc(Rect.A.Y,Succ(Size.Y))
     end;
     Client:=pointer(Child_Ins(New_Client(Rect)));
     with Client^ do begin
      GrowMode:=gm_GrowHiX+gm_GrowHiY;
      Area_Free(Rect);
      Area:=Rect;
      Area.B.Y:=Area.A.Y+Metric_Menu.Y;
      Menu:=Child_Ins(New_MenuBar(Area));
      if Menu <> nil then with Menu^ do begin
       GrowMode:=GrowMode or gm_GrowHiX;
       Inc(Rect.A.Y,Succ(Size.Y))
      end;
      Area:=Rect;
      Area.A.Y:=Area.B.Y-Metric_Box.Y;
      Menu:=Child_Ins(New_HelpBar(Area));
      if Menu <> nil then with Menu^ do begin
       GrowMode:=GrowMode or (gm_GrowHiX+gm_GrowHiY+gm_GrowLoY);
       Dec(Rect.B.Y,Succ(Size.Y))
      end;
      Desktop:=pointer(Child_Ins(New_Desktop(Rect)));
      if Desktop <> nil then with Desktop^ do begin
       GrowMode:=GrowMode or (gm_GrowHiX+gm_GrowHiY);
       Area_Free(Area);
       with Child_Ins(New_Panel(Area))^ do
       GrowMode:=GrowMode or (gm_GrowHiX+gm_GrowHiY);
      end
     end;
    end;

{Методы работы с Областью (Area) отображения}

   procedure TWindow.Area_Check;
     var Limit: TRect;
    begin
     Area_Limit(Limit);
     with Limit, Size do begin
      State_Set(sf_Minimize,(A.X = X) and (A.Y = Y));
      State_Set(sf_Maximize,(B.X = X) and (B.Y = Y));
     end
    end;

   procedure TWindow.Area_Limit(var Limit: TRect);
     var P: TPoint;
    begin
     inherited Area_Limit(Limit);
     with Client^ do begin
      P.Y:=(Self.Size.Y-Size.Y)-1;
      P.X:=Metric_Box.X*7;
     end;
     with Limit, Parent^.Size do begin
      if B.X > X then B.X:=X;
      if B.Y > Y then B.Y:=Y;
      if P.X > A.X then A.X:=P.X;
      if P.Y > A.Y then A.Y:=P.Y;
     end
    end;

   procedure TWindow.Area_Proc(const Area: TRect);
     var Check :boolean;
    begin
     with Area, Size do Check:=(X <> B.X-A.X) or (Y <> B.Y-A.Y);
     if (State * [sf_Minimize,sf_Maximize] = [])
     and not Zoom.Equals(Area) then Area_Get(Zoom);
     inherited Area_Proc(Area);
     if Check then Area_Check
    end;

{Методы для Оработки (Do) событий) }

   procedure TWindow.Do_Cancel;
    begin
     if not (sf_Modal in State) or not Comm_Valid(E.Command) then Exit;
     Data_Swap(True);
     Dlg_Stop(E.Command);
     Event_Clr(E);
    end;

   procedure TWindow.Do_KeyDown;

    procedure Comm_Put(Comm: word);
      var E: TEvent;
     begin
      E.What:=ev_Command;
      E.Command:=Comm;
      E.InfoPtr:=@Self;
      Event_Put(E);
     end;

    procedure Desktop_Next(Forw: boolean);
     begin
      if Desktop^.Child_Select(Forw) then Event_Clr(E)
     end;

    begin
     case E.AbsKey.Code of
      kb_Tab: Desktop_Next(True);
      kb_Tab+kb_Shift: Desktop_Next(False);
      kb_F10: Comm_Put(cm_Menu);
      kb_Enter: if sf_Minimize in State then Comm_Put(cm_WinZoom);
      kb_Esc: if sf_Modal in State then Comm_Put(cm_Cancel);
     end
    end;

   procedure TWindow.Do_No;
    begin
     TWindow.Do_Cancel(E)
    end;

   procedure TWindow.Do_Ok;
    begin
     if not (sf_Modal in State) or not Comm_Valid(E.Command) then Exit;
     Data_Swap(False);
     Dlg_Stop(E.Command);
     Event_Clr(E);
    end;

   procedure TWindow.Do_WinClose;
    begin
     if (sf_Modal in State) then TWindow.Do_Cancel(E) else begin
      if not Comm_Valid(E.Command) then Exit;
      Event_Clr(E);
      Free
     end
    end;

   procedure TWindow.Do_WinDrag;
    var
     Limit: TRect;
     Mode: word;
    begin
     Mode:=dm_DragMove+dm_DragGrow;
     if Mouse_Down <> 0 then Mode:=Mode or dm_DragMouse;
     Parent^.Child_Exec(New_Drager(Mode));
     Event_Clr(E)
    end;

   procedure TWindow.Do_WinGrow;
    var
     Limit: TRect;
     Mode: word;
    begin
     Mode:=dm_DragGrow;
     if Mouse_Down <> 0 then Inc(Mode,dm_DragMouse);
     Parent^.Child_Exec(New_Drager(Mode));
     Event_Clr(E)
    end;

   procedure TWindow.Do_WinMax;
     var Area: TRect;
    begin
     with Area,Parent_Get^.Size do begin
      Self.Area_Limit(Area);
      longint(Area.A):=0;
      Move((X-B.X) div 2,(Y-B.Y) div 2);
      Self.Area_Set(Area);
      Event_Clr(E)
     end
    end;

   procedure TWindow.Do_WinMin;
     var Area: TRect;
    begin
     Area_Limit(Area);
     Area.Open(Origin.X, Origin.Y, Area.A.X, Area.A.Y);
     Area_Set(Area);
     Event_Clr(E)
    end;

   procedure TWindow.Do_WinMove;
    var
     Limit: TRect;
     Mode: word;
    begin
     Mode:=dm_DragMove;
     if Mouse_Down <> 0 then Inc(Mode,dm_DragMouse);
     Parent^.Child_Exec(New_Drager(Mode));
     Event_Clr(E)
    end;

   procedure TWindow.Do_WinZoom;
    begin
     Area_Set(Zoom);
     Event_Clr(E)
    end;

   procedure TWindow.Do_Yes;
    begin
     TWindow.Do_Ok(E)
    end;

{Методы манипулирования Окном}

   function TWindow.Event_Mask;
     var Mask :word;
    begin
     Mask:=ev_AnyEvent;
     if not (sf_Focus in State) then Dec(Mask,ev_KeyDown+ev_MouseMove);
     Event_Mask:=Mask
    end;

{Методы создания (New) вспомагательных объектов}

   function TWindow.New_Panel;
    begin
     New_Panel:=(New(PPanel,Init(Area,Style_Plato)));
    end;

   function TWindow.New_Client(const Area :TRect): PGroup;
    begin
     New_Client:=New(PGroup,Init(Area))
    end;

   function TWindow.New_Corner;
    begin
     New_Corner:=New(PCorner,Init(Area,cm_WinGrow,of_Border+of_AutoHide))
    end;

   function TWindow.New_Desktop(const Area :TRect): PGroup;
    begin
     New_Desktop:=New(PGroup,Init(Area))
    end;

   function TWindow.New_Drager(Mode: word): PDrager;
     var Desk: TRect;
    begin
     Parent^.Area_Free(Desk);
     New_Drager:=New(PDrager,Init(@Self,Desk,Mode))
    end;

   function TWindow.New_Frame;
     var P :TPoint;
    begin
     P.X:=Metric_Box.X div 5;
     P.Y:=Metric_Box.Y div 5;
     New_Frame:=New(PFrame,Init(Area,cm_WinMove,P))
    end;

   function TWindow.New_HelpBar;
    begin
     New_HelpBar:=nil
    end;

   function TWindow.New_HelpKey;
    begin
     New_HelpKey:=nil
    end;

   function TWindow.New_KeyMax;
    begin
     New_KeyMax:=New(PKey,Init(Area,Symbol[6],cm_WinMax,of_AutoHide))
    end;

   function TWindow.New_KeyMin;
    begin
     New_KeyMin:=New(PKey,Init(Area,Symbol[7],cm_WinMin,of_AutoHide))
    end;

   function TWindow.New_KeyZoom;
    begin
     New_KeyZoom:=New(PKey,Init(Area,Symbol[11],cm_WinZoom,0))
    end;

   function TWindow.New_MenuBar;
    begin
     New_MenuBar:=nil
    end;

   function TWindow.New_MenuSys;
     var Menu: PMenuItem;
    begin
     Menu:=nil;
     if Options and of_NoClose = 0 then
      Menu:=New_Line(New_Item('Закрыть','Alt+F3',cm_WinClose, kb_Alt+kb_F3,Menu));
     if Options and of_NoNext = 0 then begin
      Menu:=New_Item('Следующий','F6',cm_WinNext, kb_F6,Menu);
      Menu:=New_Item('Предыдущий','Shift+F6',cm_WinPrev, kb_Shift+kb_F6,Menu);
     end;
     if Options and (of_NoGrow+of_NoMove) = 0 then
      Menu:=New_Item('Образмерить','Ctrl+F5',cm_WinDrag, kb_Ctrl+kb_F5,Menu)
     else if Options and of_NoGrow = 0 then
     Menu:=New_Item('Образмерить','Ctrl+F5',cm_WinGrow, kb_Ctrl+kb_F5,Menu)
     else if Options and of_NoMove = 0 then
     Menu:=New_Item('Перенести','Ctrl+F5',cm_WinMove, kb_Ctrl+kb_F5,Menu);
     if Options and of_NoGrow = 0 then
      Menu:=New_Item('Максимизировать','',cm_WinMax,kb_NoKey,
      New_Item('Минимизировать','',cm_WinMin, kb_NoKey,Menu));
     if Options and of_NoGrow = 0 then
     Menu:=New_Item('Востановить','F5',cm_WinZoom, kb_F5,Menu);
     New_MenuSys:=New(PMenuSys,Init(Area,0,'& ',New_Tree(Menu)))
    end;

   function TWindow.New_Title;
    begin
     New_Title:=New(PTitle,Init(Area,cm_WinMove,Name))
    end;

{Методы для установки (On) Состояний}

   procedure TWindow.On_Maximize;
    begin
     Comm_Enable(cm_WinMax, not On);
    end;

   procedure TWindow.On_Minimize;
    begin
     Comm_Enable(cm_WinMin, not On);
     if On then Dec(Options,of_Shadow) else Inc(Options,of_Shadow)
    end;

   procedure TWindow.On_Modal;
    begin
     inherited On_Modal(On);
     Comm_Enable(cm_WinNext,not On);
     Comm_Enable(cm_WinPrev,not On);
    end;

   procedure TWindow.On_Present;
    begin
     inherited On_Present(On);
     if not On then Exit;
     Area_Get(Zoom);
     Area_Check
    end;

{Методы определения Стиля (Style) окна}

   function TWindow.Style_Palette: PPalette;
    begin
     Style_Palette:=pointer(@Palette_Window);
    end;

{Реализация типа TWinClock}
{--------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TWinClock.Init(Area: TRect);
    begin
     inherited Init(Area,'Часы',0)
    end;

{Методы создания (New) вспомагательных объектов}

   function TWinClock.New_Panel(const Area: TRect): PView;
    begin
     New_Panel:=New(PDial,Init(Area))
    end;


{Реализация типа TWinGraph}
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TWinGraph.Init(Area: TRect; const Name,ATitle:string; N,M: integer);
   begin
    inherited Init(Area,ATitle,0);
    with Desktop^ do begin
     Area_Free(Area);
     Child_Ins(New(PGraph,Init(Area,Name,N,M,0)));
    end
   end;

{Методы создания (New) вспомагательных объектов}

   function TWinGraph.New_Panel(const Area: TRect): PView;
    begin
     New_Panel:=nil
    end;


{Реализация типа TWinFile}
{---------------------------------------------------------------------------}
  const

   AnyName='*.*';

{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TWinFile.Init(Name: string; Mask: PChar; APath: Pstring);
    var Area: TRect;
   begin
    inherited Init(Area.UOpen(0,0,93,60)^,Name,of_NoNext);
    GetDir(0,Dir_Curr);
    GrowMode:=GrowMode or gm_CenterX+gm_CenterY;
    with Desktop^ do begin
     Child_Ins(New(PButton,InitDef(Area.UOpen(69,12,18,5)^,'&Ок',cm_Ok)));
     Child_Ins(New(PButton,Init(Area.UOpen(69,19,18,5)^,'Отмена',cm_Cancel)));
      Child_Ins(New_Label(Area.UOpen(3,3,30,2)^,'&Файл:'));
      EditFile:=pointer(Child_Ins(New_EditFile(Area.UOpen(3,6,30,4)^)));
      ListFile:=pointer(Child_Ins(New_ListFile(Area.UOpen(3,12,30,28)^)));
      ListFile^.GrowMode:=gm_GrowHiY;
     Child_Ins(New_Label(Area.UOpen(3,42,30,2)^,'&Тип:'))^.GrowMode:=gm_GrowHiY+gm_GrowLoY;
     CombMask:=pointer(Child_Ins(New_CombMask(Area.UOpen(3,45,30,4)^,Mask)));
     CombMask^.GrowMode:=gm_GrowHiY+gm_GrowLoY;
      RemarkDir:=pointer(Child_Ins((New_RemarkDir(Area.UOpen(36,6,51,4)^))));
      Child_Ins(New_Label(Area.UOpen(36,3,30,2)^,'&Каталог:'));
      ListDir:=pointer(Child_Ins(New_ListDir(Area.UOpen(36,12,30,28)^)));
      ListDir^.GrowMode:=gm_GrowHiY;
     Child_Ins(New_Label(Area.UOpen(36,42,30,2)^,'&Диск:'))^.GrowMode:=gm_GrowHiY+gm_GrowLoY;
     CombDrv:=pointer(Child_Ins(New_CombDrv(Area.UOpen(36,45,30,4)^)));
     CombDrv^.GrowMode:=gm_GrowHiY+gm_GrowLoY;
    end;
    StrRes:=APath;
    GetDir(0,Name);
    if not LowMemory then DoLoad(Name);
    if APath^ <> '' then with EditFile^ do begin
     Text_Set(APath^);
     Select
    end else DoFocus
   end;

  destructor TWinFile.Done;
   begin
    inherited Done;
    ChDir(Dir_Curr)
   end;

{Методы работы с Областью (Area) отображения}

  procedure TWinFile.Area_Limit(var Limit: TRect);
   begin
    inherited Area_Limit(Limit);
    with Limit do begin
     A.X:=Size.X;
     with ListFile^ do A.Y:=Self.Size.Y-(Size.Y-Item_Size*3)+4;
     B.X:=Size.X;
    end
   end;

{Личные методы}

  procedure TWinFile.DoFocus;
   begin
    with ListFile^ do if List^.Count <> 0 then Focus else CombMask^.Focus
   end;

  procedure TWinFile.DoOk;
    var E: TEvent;
   begin
    E.What:=ev_Command;
    E.Command:=cm_Ok;
    E.InfoPtr:=@Self;
    Event_Put(E)
   end;

  procedure TWinFile.DoLoad;
    function DosCheck: boolean;
     begin
      DosCheck:=True;
      if DosError in [err_None,err_NoMoreFiles] then Exit;
      MessageBox('Ошибка',#3+Application^.Msg_Text(DosError),mb_Ok+mb_Red);
      DosError:=0;
      DosCheck:=False
     end;
   begin
    ChDir(FExpand(Path));
    GetDir(0,Path);
    RemarkDir^.Text_Set(Path);
    with ListDir^, PStringCollection(List)^ do begin
     FreeAll;
     Load_Dir(AnyName,Directory);
     List_Set(List)
    end;
    with ListFile^, PStringCollection(List)^ do begin
     FreeAll;
     if DosCheck then Load_Dir(CombMask^.Text,AnyFile-Directory);
     List_Set(List);
    end;
    CombDrv^.Text_Set(Copy(RemarkDir^.Text^,1,2));
    if LowMemory then MessageBox('Ошибка',#3'Слищком много файлов !',mb_Red+mb_Ok)
   end;

{Методы для Оработки (Do) событий) }

  procedure TWinFile.Do_ItemChg(var E: TEvent);
   begin
    if E.InfoPtr <> ListFile then Exit;
    with ListFile^ do EditFile^.Text_Set(Item_Get(Item_Curr));
    Event_Clr(E)
   end;

  procedure TWinFile.Do_ItemEnt(var E: TEvent);
   begin
    if E.InfoPtr = ListFile then DoOk else
    if E.InfoPtr = ListDir then with ListDir^ do DoLoad(Item_Get(Item_Curr))
    else Exit;
    Event_Clr(E);
   end;

  procedure TWinFile.Do_TextEnt(var E: TEvent);
    var Path: string;
   begin
    if E.InfoPtr = CombMask then begin
     DoLoad(RemarkDir^.Text^);
     DoFocus
    end else
    if E.InfoPtr = CombDrv then begin
     GetDir(byte(Succ(CombDrv^.Text[1]))-byte('A'),Path);
     DoLoad(Path);
     with ListDir^ do if List^.Count <> 0 then Focus else DoFocus
    end else Exit;
    Event_Clr(E)
   end;

{Методы создания (New) вспомагательных объектов}

  function TWinFile.New_CombDrv(const Area: TRect): PComboBox;
    var List: PStringCollection;
   begin
    New(List,Init(10,10));
    with PComboBox(New(PComboBox,Init(Area,^T#2,of_Border+of_ReadOnly,List)))^ do
    begin
     New_CombDrv:=pointer(Ptr);
     List^.Load_Drv;
     List_Set(List)
    end
   end;

  function TWinFile.New_CombMask;
    var List: PStringCollection;
   begin
    List:=New(PStringCollection,Init(10,10));
    List^.Load_Memo(Mask,';');
    New_CombMask:=New(PComboBox,Init(Area,^T#80,of_Border+of_ReadOnly, List));
   end;

  function TWinFile.New_ListDir(const Area: TRect): PListBox;
   begin
    New_ListDir:=New(PListBox,Init(Area,
    New(PStringCollection,Init(10,10)),of_Border));
   end;

  function TWinFile.New_RemarkDir(const Area: TRect): PRemark;
   begin
    New_RemarkDir:=New(PRemark,Init(Area,'',of_VCenter));
   end;

  function TWinFile.New_EditFile(const Area: TRect): PEdit;
   begin
    New_EditFile:=New(PEdit,Init(Area,^T#80,of_Border));
   end;

  function TWinFile.New_ListFile(const Area: TRect): PListBox;
   begin
    New_ListFile:=New(PListBox,Init(Area,
    New(PStringCollection,Init(10,10)), of_Border));
   end;

  function TWinFile.New_Label(const Area: TRect;const Text: string): PLabel;
   begin
    New_Label:=New(PLabel,Init(Area,Text));
   end;

{Методы Проверки (Valid) команд}

  function TWinFile.Valid_Ok;
   var
    Path: string;
    Dir: DirStr;
    Name: String[12];
    Ext: ExtStr;
   begin
    Path:=EditFile^.Text;
    for Path[0]:=Path[0] downto #0 do if Path[length(Path)] <> #32 then Break;
    if (Path <> '') and (Pos('*',Path) = 0) and (Pos('?',Path) = 0) then begin
     Valid_Ok:=True;
     StrRes^:=FExpand(Path);
    end else begin
     Valid_Ok:=False;
     FSplit(FExpand(Path),Dir,Name,Ext);
     Name:=Name+Ext;
     if Name <> '' then CombMask^.Text_Set(Name);
     DoLoad(Dir);
     DoFocus
    end;
   end;


{Реализация типа TWinPassport}
{--------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TWinPassword.Init(Name: string; Lng: byte; var Res: string);
    var Area1, Area2: TRect;
   begin
    inherited Init(Area1.UOpen(0,0,70,36)^,Name,of_NoGrow+of_NoNext);
    GrowMode:=gm_CenterX+gm_CenterY;
    with Desktop^ do  begin
     Child_Ins(New_Label(Area1.UOpen(3,4,10,4)^,'О&ригинал:'));
     EditOriginal:=New_Edit(Area2.UOpen(22,4,42,4)^,Lng);
     EditOriginal^.Data_Ptr:=@Res;
     Child_Ins(EditOriginal);
     Child_Ins(New_Label(Area1.UMove(0,8)^,'&Копия:'));
     EditDuplicate:=New_Edit(Area2.UMove(0,8)^,Lng);
     Child_Ins(EditDuplicate);
     Child_Ins(New(PButton,InitDef(Area1.UOpen(11,20,20,5)^,'&Ок',cm_Ok)));
     Child_Ins(New(PButton,Init(Area1.UMove(25,0)^,'О&тмена',cm_Cancel)));
    end;
    EditOriginal^.Select
   end;

{Методы создания (New) вспомагательных объектов}

  function TWinPassword.New_Edit;
   begin
    with PEdit(New(PEdit,Init(Area,^T+Char(Lng),of_Border)))^ do begin
     New_Edit:=pointer(Ptr);
     Password:='*'
    end
   end;

  function TWinPassword.New_Label;
   begin
    New_Label:=New(PLabel,InitPack(Area,Text));
   end;

{Методы Проверки (Valid) команд}

  function TWinPassword.Valid_Ok:boolean;
    var P: TPoint;
   begin
    if EditOriginal^.Text = EditDuplicate^.Text then Valid_Ok:=True else
    begin
     EditDuplicate^.Select;
     longint(P):=0;
     EditDuplicate^.Point_Global(P,P);
     MessageErr(P,#3'Копия не соответствует Оригиналу ! ',Palette_ReplRed);
     Valid_Ok:=False;
    end
   end;

{Реализация типа TWinMouse}
{--------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TWinMouse.Init(Name: string);
    var Area: TRect;
   begin
    inherited Init(Area.UOpen(0,0,71,42)^,Name,of_NoGrow+of_NoNext);
    GrowMode:=gm_CenterX+gm_CenterY;
    with Desktop^, Area do  begin
     Child_Ins(New_Group(UOpen(3,03,41,10)^));
     Child_Ins(New_Group(UOpen(3,16,41,16)^));
     Child_Ins(New_Label(UOpen(5,4,37,4)^,'&Скорость движения'));
     SliderSpeed:=New_Slider(UMove(0,3)^);
     Child_Ins(SliderSpeed);
     Child_Ins(New_Label(UMove(0,10)^,'&Двойное нажатие'));
     SliderClick:=New_Slider(UMove(0,3)^);
     Child_Ins(SliderClick);
     Child_Ins(New(PButton,InitDef(UOpen(48,3,17,5)^,'&Ок',cm_Ok)));
     Child_Ins(New(PButton,Init(UMove(0,8)^,'О&тмена',cm_Cancel)));
     CheckLeft:=New_CheckBox(UMove(0,16)^,'&Левша');
     Child_Ins(CheckLeft);
     ViewTest:=Child_Ins(New(PView,Init(UOpen(5,26,37,4)^)));
     Inc(ViewTest^.Options,of_NoSelect);
    end;
    Left:=Mouse_Reverse;
    Double:=Mouse_Double;
    SliderClick^.Scroll_Param(1,16,1,4,Double);
    SliderSpeed^.Scroll_Param(1,16,1,4,8);
    Speed:=SliderSpeed^.Value;
    CheckLeft^.State_Set(sf_Check, Left);
    SliderSpeed^.Select
   end;

{Методы создания (New) вспомагательных объектов}

  function TWinMouse.New_CheckBox;
   begin
    New_CheckBox:=New(PCheckBox,Init(Area,Text))
   end;

  function TWinMouse.New_Label;
   begin
    New_Label:=New(PLabel,InitPack(Area,Text));
   end;

  function TWinMouse.New_Group;
   begin
    with PPanel(New(PPanel,Init(Area,Style_Canyon)))^ do begin
     Options:=Options or of_Glass;
     New_Group:=Ptr;
    end;
   end;

  function TWinMouse.New_Slider;
   begin
    New_Slider:=New(PSliderBar,Init(Area,of_Border))
   end;

{Методы для Оработки (Do) событий) }

  procedure TWinMouse.Do_Cancel(var E: TEvent);
   begin
    inherited Do_Cancel(E);
    Mouse_Reverse:=Left;
    Mouse_Double:=Double;
    Speed_Set(Speed);
   end;

  procedure TWinMouse.Do_Check(var E: TEvent);
   begin
    if E.InfoPtr <> CheckLeft then Exit;
    Mouse_Reverse:=sf_Check in CheckLeft^.State;
    Event_Clr(E)
   end;

  procedure TWinMouse.Do_ChildPaint(var E: TEvent);
   var
    Area: TRect;
    C: Pointer;
   begin
    if E.InfoPtr <> ViewTest then Exit;
    if not Flag then C:=@Palette_ClickTest[1] else C:=@Palette_ClickTest[4];
    with ViewTest^ do begin
     Area_Local(Area);
     S3D_Body(Area,-1,C^);
     SetColor(Byte(Palette_ClickTest[7]));
     SetTextJustify(CenterText,CenterText);
     OutTextXY(Size.X div 2,Size.Y div 2, 'Тест');
    end;
    Event_Clr(E)
   end;

  procedure TWinMouse.Do_MouseDown(var E: TEvent);
   begin
    inherited Do_MouseDown(E);
    if (Application^.Indicator = ViewTest) and E.Double then begin
     Flag:=not Flag;
     ViewTest^.Draw;
     Event_Clr(E)
    end
   end;

  procedure TWinMouse.Do_ScrollChg(var E: TEvent);
   begin
    if E.InfoPtr = SliderClick then Mouse_Double:=SliderClick^.Value else
    if E.InfoPtr = SliderSpeed then Speed_Set(17-SliderSpeed^.Value) else Exit;
    Event_Clr(E)
   end;

{Методы для настройки Скорости (Speed) }

  procedure TWinMouse.Speed_Set(ASpeed: integer); assembler;
   asm
        MOV   AX,   0FH
        MOV   CX,   ASpeed;
        MOV   DX,   CX
        INT   33H
   end;

{Реализация объекта Приложения (Application) }
{-----------------------------------------------------------------------}
{Методы для Оработки (Do) событий) }

   procedure TApplication.Do_WinNext;
    begin
     Child_Select(True);
     Event_Clr(E)
    end;

   procedure TApplication.Do_WinPrev;
    begin
     Child_Curr^.Level_Over(Panel);
     Child_Select(False);
     Event_Clr(E)
    end;

{Методы вывода Сообщений (Message)}

  function TApplication.Msg_Box(const Title,Msg: string; mb_XXXX: word): word;
   var
    Area: TRect;
    Dialog: PWindow;
    Count: word;
   procedure DoMove(View: PView); far;
    begin
     with View^ do if View <> Parent^.Child_First then Inc(Origin.X,Count)
    end;
   begin
    Area.UOpen(0,0,85,36);
    Dialog:=New(PWindow,Init(Area,Title,of_NoGrow+of_NoNext));
    Dialog^.GrowMode:=gm_CenterX+gm_CenterY;
    Count:=0;
    Area.UOpen(-20,21,16,5);
    with Dialog^.Desktop^, Area do begin
     if mb_XXXX and mb_Ok     <> 0 then Child_Ins(New(PButton,Init(UMove(20,0)^,'&Ok',cm_Ok)));
     if mb_XXXX and mb_Yes    <> 0 then Child_Ins(New(PButton,Init(UMove(20,0)^,'&Да',cm_Yes)));
     if mb_XXXX and mb_No     <> 0 then Child_Ins(New(PButton,Init(UMove(20,0)^,'&Нет',cm_No)));
     if mb_XXXX and mb_Cancel <> 0 then Child_Ins(New(PButton,Init(UMove(20,0)^,'О&тмена',cm_Cancel)));
     with Child_Last^ do Count:=Origin.X+Size.X;
     Count:=(Size.X-Count) div 2;
     Child_For(@DoMove);
     if mb_XXXX and $F0 <> 0 then
     with Child_Ins(New(PSignal,Init(UOpen(3,3,5,15)^,of_Border+of_Glass)))^ do begin
      State_Set(sf_Green, mb_XXXX and mb_Green <> 0);
      State_Set(sf_Red,   mb_XXXX and mb_Red <> 0);
      State_Set(sf_Yellow,mb_XXXX and mb_Yellow <> 0);
      UOpen(11,3,69,15)
     end else UOpen(3,3,78,15);
     Child_Ins(New(PRemark,Init(Area,Msg,of_VCenter+of_Glass)));
     Child_Select(True)
    end;
    Count:=LowMemSize;
    LowMemSize:=0;
    Msg_Box:=Child_Exec(Dialog);
    LowMemSize:=Count
   end;

  procedure TApplication.Msg_Err(Pos: TPoint; const Text,Color: string);
    var Save: word;
   begin
    Save:=LowMemSize;
    LowMemSize:=0;
    Child_Exec(New(PPhrase,Init(Pos,Text,Color)));
    LowMemSize:=Save
   end;

  procedure TApplication.Msg_OutMem;
   begin
    Msg_Box('Ошибка',Msg_Text(err_HeapOverflow)+' Если возможно закройте несколько Окон',mb_Ok+mb_Red)
   end;

  function TApplication.Msg_Text;
   const
    TextReal = ' при работе с вещественным числом.';
   begin
    case err_XXXX of
     err_FileNotFound         : Msg_Text:='Файл не найден.';
     err_PathNotFound         : Msg_Text:='Путь не найден.';
     err_ManyOpenFiles        : Msg_Text:='Слишком много открытых файлов';
     err_DiskRead             : Msg_Text:='Ошибка чтения с диска.';
     err_DiskWrite            : Msg_Text:='Ошибка записи на диск.';
     err_InvalidNumericFormat : Msg_Text:='Синтаксическая ошибка.';
     err_DiskWriteProtected   : Msg_Text:='Диск защищен от записи.';
     err_BadDrvRequestStruct  : Msg_Text:='Неизвестное устройство.';
     err_DriveNotReady        : Msg_Text:='Устройство не готово.';
     err_PrinterOutOfPaper    : Msg_Text:='Конец бумаги на принтере.';
     err_DivisionByZero       : Msg_Text:='Деление на ноль.';
     err_StackOverflow        : Msg_Text:='Переполнение стека.';
     err_HeapOverflow         : Msg_Text:='Переполнение динамически распределяемой памяти.';
     err_FloatPointOverflow   : Msg_Text:='Переполнение'+TextReal;
     err_FloatPointUnderflow  : Msg_Text:='Исчезновение порядка'+TextReal;
     err_InvalidFloatPoint    : Msg_Text:='Недопустимая операция'+TextReal;
     else                       Msg_Text:='Неизвестная ошибка';
    end
   end;

{--------------------------------------------------------------------------}

  function InputBox(const Title,Text: string; Form: TForm; var Res: String): word;
   var
    Area: TRect;
    Window: PWindow;
    View: PView;
   begin
    Window:=New(PWindow,Init(Area.UOpen(0,0,70,40)^,Title,of_NoGrow+of_NoNext));
    Window^.GrowMode:=gm_CenterX+gm_CenterY;
    Window^.Data_Ptr:=@Res;
    with Window^.Desktop^, Area do  begin
     View:=New(PLabel,InitPack(UOpen(3,8,61,4)^,Text));
     Inc(View^.GrowMode,gm_CenterX);
     Child_Ins(View);
     View:=New(PEdit,Init(UMove(0,5)^,Form,of_Border));
     Inc(View^.GrowMode,gm_CenterX);
     Child_Ins(View);
     Child_Ins(New(PButton,InitDef(UOpen(12,25,20,5)^,'&Ок',cm_Ok)));
     Child_Ins(New(PButton,Init(UMove(25,0)^,'О&тмена',cm_Cancel)))^.Parent^.Child_Select(False);
    end;
    InputBox:=Application^.Child_Exec(Window)
   end;

  end.

