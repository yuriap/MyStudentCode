 {      ┌───────────────────────────────────────────┐
        │                                           │
        │           E a s t   S t u d i o           │
        │                                           │
        │              U M e n u    2.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1996        │
        │             (054) 33-35-94                │
        │                                           │
        │               (interface)                 │
        │                                           │
        └───────────────────────────────────────────┘      }

 {$I INC\UMENU.INC}

 implementation

  uses

   Graph, UGraph;

   function New_Item(const AName, AParam: string; ACommand,AKeyCode: word;
    ANext: PMenuItem): PMenuItem;
    var
     Item: PMenuItem;
    begin
     if (AName <> '') and (ACommand <> 0) then begin
      New(Item);
      with Item^ do begin
       Command:=ACommand;
       KeyCode:=AKeyCode;
       Param:=Str_New(AParam);
       Name:=Str_New(AName);
       New_Item:=Item;
       Next:=ANext;
       State:=mn_Command
      end
     end else New_Item:=ANext
    end;

   function New_Line(ANext: PMenuItem): PMenuItem;
    begin
     if ANext <> nil then Inc(ANext^.State,mn_Line);
     New_Line:=ANext
    end;

   function New_List(const AName: string; AHelpCtx: word; ASubMenu: PMenuTree;
    ANext: PMenuItem): PMenuItem;
     var Item: PMenuItem;
    begin
     if (AName <> '') and (ASubMenu <> nil) then begin
      New(Item);
      with Item^ do begin
       Command:=AHelpCtx;
       Name:=Str_New(AName);
       New_List:=Item;
       Next:=ANext;
       List:=ASubMenu;
       State:=mn_SubMenu
      end
     end else New_List:=ANext
    end;

   function New_Tree(AItem: PMenuItem): PMenuTree;
    begin
     New_Tree:=New(PMenuTree,Init(AItem));
    end;

   function New_Ctx;
    begin
     New_Ctx:=New(PCtxItem,Init(Ctx,Text,Next))
    end;

   constructor TMenuTree.Init(AItem: PMenuItem);
    begin
     inherited Init;
     Item_First:=AItem;
     Item_Def:=AItem;
    end;

   destructor TMenuTree.Done;
    procedure DoDone(Item: PMenuItem); far;
     begin
      with Item^ do begin
       Str_Dsp(Name);
       if State and mn_Command <> mn_Not then Str_Dsp(Param) else List^.Free
      end;
      Dispose(Item)
     end;
    begin
     Item_For(@DoDone);
    end;

   function TMenuTree.Item_Prev(MenuItem: PMenuItem): PMenuItem;
    function DoLast(Curr: PMenuItem): boolean; far;
     begin
      DoLast:=Curr^.Next = MenuItem
     end;
    begin
     Item_Prev:=Item_Case(@DoLast)
    end;

   function TMenuTree.Item_Case(Method: pointer): PMenuItem; assembler;
    asm
         LES     DI,Self
         MOV     AX,ES
         OR      AX,DI
         JE      @3
         LES     DI,ES:[DI].TMenuTree.Item_First
     @1: MOV     AX,ES
         OR      AX,DI
         JE      @3
         PUSH    ES
         PUSH    DI
         PUSH    ES
         PUSH    DI
         PUSH    WORD PTR [BP]
         CALL    Method
         POP     DI
         POP     ES
         OR      AL,AL
         JNE     @3
         LES     DI,ES:[DI].TMenuItem.Next
         JMP     @1
     @3: MOV     AX,DI
         MOV     DX,ES
    end;

   function TMenuTree.Tree_Case(Method: Pointer): PMenuItem; assembler;
    asm
         LES     DI, Self
         CALL    @Sub
         JMP     @End
      @Item:
         MOV     AX, ES
         OR      AX, DI
         JE      @2
         PUSH    ES
         PUSH    DI
         PUSH    ES
         PUSH    DI
         PUSH    WORD PTR [BP]
         CALL    Method
         POP     DI
         POP     ES
         CALL    @TestStop
         MOV     AL, mn_Command
         AND     AL, ES:[DI].TMenuItem.State
         JNZ     @1
         PUSH    ES
         PUSH    DI
         LES     DI, ES:[DI].TMenuItem.List
         CALL    @Sub
         POP     DI
         POP     ES
         CALL    @TestStop
      @1:LES     DI, ES:[DI].TMenuItem.Next
         JMP     @Item
      @2:RETN
      @Sub:
         MOV     AX, ES
         OR      AX, DI
         JE      @3
         LES     DI, ES:[DI].TMenuTree.Item_First
         CALL    @Item
      @3:RETN
      @TestStop:
         OR      AL, AL
         JE      @4
         MOV     AX,DI
         MOV     DX,ES
         MOV     SP, BP
         POP     BP
         RETF    8
      @4:RETN
      @End:
         XOR     AX,AX
         XOR     DX,DX
    end;

   procedure TMenuTree.Item_For(Method: Pointer); assembler;
    asm
         LES     DI,Self
         MOV     AX,ES
         OR      AX,DI
         JE      @2
         LES     DI,ES:[DI].TMenuTree.Item_First
     @1: MOV     AX,ES
         OR      AX,DI
         JE      @2
         PUSH    WORD PTR ES:[DI].TMenuItem.Next[2]
         PUSH    WORD PTR ES:[DI].TMenuItem.Next[0]
         PUSH    ES
         PUSH    DI
         PUSH    WORD PTR [BP]
         CALL    Method
         POP     DI
         POP     ES
         JMP     @1
     @2:
    end;

   procedure TMenuTree.Tree_For(Method: Pointer); assembler;
    asm
         LES     DI, Self
         CALL    @Sub
         JMP     @End
      @Item:
         MOV     BX, ES
         OR      BX, DI
         JE      @2
         PUSH    ES
         PUSH    DI
         PUSH    ES
         PUSH    DI
         PUSH    WORD PTR [BP]
         CALL    Method
         POP     DI
         POP     ES
         MOV     BL, mn_Command
         AND     BL, ES:[DI].TMenuItem.State
         JNZ     @1
         PUSH    ES
         PUSH    DI
         LES     DI, ES:[DI].TMenuItem.List
         CALL    @Sub
         POP     DI
         POP     ES
      @1:LES     DI, ES:[DI].TMenuItem.Next
         JMP     @Item
      @2:RETN
      @Sub:
         MOV     BX, ES
         OR      BX, DI
         JE      @3
         LES     DI, ES:[DI].TMenuTree.Item_First
         CALL    @Item
      @3:RETN
      @End:
    end;

{Реализация объекта Меню (Menu) }
{--------------------------------------------------------------------------}

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TMenu.Init(const Area: TRect);
    begin
     inherited Init(Area);
     Menu_Next:=@Self;
     Options:=Options or of_NoSelect
    end;

   destructor TMenu.Done;
    begin
     inherited Done;
     Menu_Sub^.Free;
     if Menu_Sup <> nil then Menu_Sup^.Menu_Sub:=nil else Item_List^.Free
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TMenu.HelpCtx_Get: word;
     var Res: word;
    begin
     Res:=hc_None;
     if Menu_Sub <> nil then Res:=Menu_Sub^.HelpCtx_Get;
     if (Res = hc_None) and (Item_Curr <> nil)
     then Res:=Item_Curr^.Command;
     HelpCtx_Get:=Res
    end;

{Методы для управления Событиями (Event)}

   function  TMenu.Event_Mask: word;
    begin
     if State * [sf_Active+sf_Modal] = [] then Event_Mask:=ev_Command
     else Event_Mask:=ev_Mouse+ev_Idle+ev_Command+ev_KeyDown;
    end;

   procedure TMenu.Item_Area(Item: PMenuItem; var Area: TRect);
    begin
     Abstract
    end;

   procedure TMenu.Item_Select(Item: PMenuItem);
    var
     Area: TRect;
     Buff: PMenuItem;
    begin
     if (Item_Curr = Item) then Exit;
     Buff:=Item_Curr;
     Item_Curr:=Item;
     Menu_Sub^.Free;
     if Buff <> nil then begin
      Item_Area(Buff,Area);
      Draw_Rect(Area)
     end;
     if Item_Curr = nil then Exit;
     Item_List^.Item_Def:=Item_Curr;
     Item_Area(Item_Curr,Area);
     Draw_Rect(Area)
    end;


{Методы работы с Родительским (Parent) окном}

   function TMenu.Parent_Get: PView; assembler;
    asm
         LES  DI, Self
     @1: MOV  AX, DI
         MOV  DX, ES
         LES  DI,ES:[DI].TMenu.Menu_Sup
         MOV  SI,ES
         OR   SI,DI
         JNE  @1
    end;

   function TMenu.Menu_Prev: PMenu; assembler;
    asm
         LES     DI,Self
         MOV     CX,DI
         MOV     BX,ES
     @@1:MOV     AX,DI
         MOV     DX,ES
         LES     DI,ES:[DI].TMenu.Menu_Next
         CMP     DI,CX
         JNE     @@1
         MOV     SI,ES
         CMP     SI,BX
         JNE     @@1
    end;

   function TMenu.New_Menu(Area: TRect; AList: PMenuTree): PMenu;
    begin
     New_Menu:=New(PMenuBox,Init(Area,of_Border+of_Shadow,AList))
    end;

   procedure TMenu.DoCommand(Comm: word);
     var E: TEvent;
    begin
     E.What:=ev_Command;
     E.Command:=Comm;
     E.InfoPtr:=@Self;
     Event_Put(E)
    end;

   procedure TMenu.DoSelect(Forw: boolean);

    procedure ExecuteMenu(Menu: PMenu);
     begin
      with Menu^ do begin
       DoCommand(cm_MenuNext);
       with Item_List^ do if Forw then Item_Def:=Item_First
       else Item_Def:=Item_Prev(nil);
       State_Set(sf_AutoOpen, (sf_AutoOpen in Self.State)
       and (Options and of_AutoOpen <> 0));
      end;
      Dlg_Stop(cm_Idle);
     end;

    begin
     with Item_List^ do case Forw of
      False:
       if (Item_Curr = Item_First) then if (Menu_Next <> @Self)
       then ExecuteMenu(Menu_Prev) else Item_Select(Item_Prev(nil))
       else Item_Select(Item_Prev(Item_Curr));
      True:
       with Item_Curr^ do if (Next = nil) then if (Menu_Next <> @Self)
       then ExecuteMenu(Menu_Next) else Item_Select(Item_First)
       else Item_Select(Next);
     end
    end;

   procedure TMenu.DoStart(Item: PMenuItem);
    begin
     if Item = nil then Dlg_Stop(cm_Idle)
     else begin
      Item_Select(Item);
      with Item_Curr^ do case State and (mn_Command + mn_SubMenu) of
       mn_SubMenu:
        begin
         if Menu_Sub = nil then DoSubMenu;
         with Menu_Sub^ do Item_Select(Item_List^.Item_Def)
        end;
       mn_Command:
        if State and mn_Disabled = 0 then
        Dlg_Stop(Command) else Dlg_Stop(cm_Idle)
      end
     end
    end;

   procedure TMenu.DoSubMenu;
    var
     Area: TRect;
     Point: TPoint;
     Save: word;
    begin
     if Item_Curr = nil then Exit;
     longint(Point):=0;
     Point_Global(Point,Point);
     Item_Area(Item_Curr,Area);
     Area.A.Y:=Area.B.Y;
     Area.Move(Point.X,Point.Y);
     Menu_Sub:=New_Menu(Area,Item_Curr^.List);
     Menu_Sub^.Menu_Sup:=@Self;
     Save:=LowMemSize;
     LowMemSize:=0;
     Application^.Child_Ins(Menu_Sub);
     LowMemSize:=Save;
     State_Set(sf_AutoOpen,Options and of_AutoOpen <> 0)
    end;

   procedure TMenu.Comm_Audit;
      var Res: boolean;
     procedure DoCheck(Item: PMenuItem); far;
      begin
       with Item^ do begin
        if (State and mn_Command = 0) or (Comm <> Command)
        or (On = (State and mn_Disabled = 0)) then Exit;
        Res:=Res or (State and mn_Visible <> 0);
        if On then State:=State and not mn_Disabled
        else State:=State or mn_Disabled
       end
      end;
     begin
      Res:=False;
      Item_List^.Tree_For(@DoCheck);
      if Res then Draw
     end;

   procedure TMenu.Event_Diler(var E: TEvent);

    function FindHotKey: PMenuItem;
      var Ch: char;

     function DoFind(MenuItem: PMenuItem): boolean; far;
       var NameCh: char;
      begin
       with MenuItem^,E do if State and mn_Disabled = 0 then begin
        NameCh:=HotStr_Ch(Name^);
        DoFind:=(NameCh <> #0) and (Char_Mask and kb_Char <> 0) and (Ch = NameCh)
        or (Char_Mask and AbsKey.Flag <> 0) and (AbsKey.Scan = Char_Scan(NameCh))
       end else DoFind:=False
      end;

     begin
      Ch:=UpCase(E.SysKey.Char);
      FindHotKey:=Item_List^.Item_Case(@DoFind)
     end;

    function FindSpeedKey: PMenuItem;

     function DoFind(MenuItem: PMenuItem): boolean; far;
      begin
       with MenuItem^ do
       DoFind:=(State and (mn_Command+mn_Disabled) = mn_Command)
       and (KeyCode = E.AbsKey.Code)
      end;

     begin
      FindSpeedKey:=Item_List^.Tree_Case(@DoFind)
     end;

    function FindWhere: PMenuItem;
      var Point: TPoint;

     function DoFind(MenuItem: PMenuItem): boolean; far;
       var Area: TRect;
      begin
       Item_Area(MenuItem,Area);
       DoFind:=Area.Contains(Point)
      end;

     begin
      Point_Local(E.Where, Point);
      FindWhere:=Item_List^.Item_Case(@DoFind)
     end;

    function KeyInMenu: boolean;
      var Item: PMenuItem;
     begin
      Item:=FindHotKey;
      if Item <> nil then DoStart(Item)
      else if Menu_Sup = nil then begin
       Item:=FindSpeedKey;
       if Item <> nil then Dlg_Stop(Item^.Command);
      end;
      KeyInMenu:=Item <> nil
     end;

    procedure DoItem_Select(Item: PMenuItem);
     begin
      if Options and of_AutoOpen = 0 then Menu_Sub^.Free;
      Item_Select(Item);
      if (Item_Curr <> nil) and (Menu_Sub = nil) and (Options and of_AutoOpen <> 0)
      then DoSubMenu
     end;

    function MouseInMenu: boolean;
     var
      Menu: PMenu;
      View: pointer;
     begin
      MouseInMenu:=False;
      if E.Buttons = 0 then Exit;
      View:=Application^.Indicator;
      if View = @Self then DoItem_Select(FindWhere) else begin
       if Menu_Sub = nil then Item_Select(nil);
       if (Menu_Sup <> nil) or (Menu_Next = @Self) then Exit;
       Menu:=Menu_Next;
       while (Menu <> @Self) and (Menu <> View) do Menu:=Menu^.Menu_Next;
       if Menu = @Self then Exit;
       Dlg_Stop(cm_Idle);
       Menu^.DoCommand(cm_MenuExec);
       Event_Put(E)
      end;
      MouseInMenu:=True;
     end;


    procedure DoExecute(Item: PMenuItem);
      var Result: word;
     begin
      Item_Select(Item);
      Result:=Dlg_Exec;
      if Result <> cm_Idle then DoCommand(Result);
      Event_Clr(E)
     end;

    procedure DoLinkMenu;
     begin
      if (sf_Active in State) and (E.InfoPtr <> @Self) then
      with PMenu(E.InfoPtr)^ do begin
       Self.Menu_Next:=Menu_Next;
       Menu_Next:=@Self
      end
     end;

    procedure DoLinkSelf;
     begin
      Menu_Next:=@Self;
      Event_Send(Dialog,ev_Command,cm_MenuLink,@Self);
     end;

    procedure DoKeyDown;
      var Item: PMenuItem;
     begin
      Item:=FindHotKey;
      if Item <> nil then begin
       DoLinkSelf;
       DoExecute(Item)
      end else begin
       Item:=FindSpeedKey;
       if Item = nil then Exit;
       DoCommand(Item^.Command);
       Event_Clr(E)
      end
     end;

    procedure DoMenu;
     begin
      DoLinkSelf;
      DoExecute(Item_List^.Item_Def)
     end;

    procedure DoMouseDown;
     begin
      DoLinkSelf;
      Event_Put(E);
      DoExecute(nil)
     end;

    begin
     inherited Event_Diler(E);
     if Menu_Sub <> nil then Menu_Sub^.Event_Diler(E);
     if not (sf_Modal in State) and (Menu_Sup = nil) then
     case E.What of
      ev_Command:
       case E.Command of
        cm_Menu: DoMenu;
        cm_MenuNext: if E.InfoPtr = @Self then DoExecute(Item_List^.Item_Def);
        cm_MenuExec: if E.InfoPtr = @Self then DoExecute(nil);
        cm_MenuLink: DoLinkMenu;
       end;
      ev_KeyDown: DoKeyDown;
      ev_MouseDown: DoMouseDown;
     end else begin
      if (E.What and (ev_MouseDown+ev_MouseUp) <> 0) and (Menu_Sup <> nil)
      and (Application^.Indicator <> @Self) then Exit;
      case E.What of
       ev_Idle:
        if E.Count = 1 then begin
         if (sf_AutoOpen in State)
         and (Menu_Sub = nil) and (Item_Curr <> nil)
         and (Item_Curr^.State and mn_SubMenu <> 0)
         then DoStart(Item_Curr);
         Exit
        end;
       ev_Command:
        if (E.Command = cm_Menu) and (Menu_Sup = nil)
        then Menu_Sub^.Free else Exit;
       ev_MouseMove:
        if not MouseInMenu then Exit;
       ev_MouseUp:
        DoStart(FindWhere);
       ev_MouseDown:
        if (Application^.Indicator <> @Self) and
        not MouseInMenu then Dlg_Stop(cm_Idle)
        else DoItem_Select(FindWhere);
       ev_KeyDown:
        case E.AbsKey.Code of
         kb_Enter:
          DoStart(Item_Curr);
         kb_Home:
          if Item_List^.Item_First <> Item_Curr
          then Item_Select(Item_List^.Item_First);
         kb_End:
          if Item_Curr^.Next <> nil
          then Item_Select(Item_List^.Item_Prev(nil));
         kb_Esc:
          if (Menu_Sub = nil) and (Menu_Sup <> nil) then Exit
          else if (Menu_Sub <> nil) and (Options and of_AutoOpen = 0)
          then Menu_Sub^.Free else Dlg_Stop(cm_Idle);
         else if not KeyInMenu then Exit
        end;
       else Exit
      end;
      Event_Clr(E)
     end
    end;

   procedure TMenu.On_Exposed;
    procedure DoVisible(Item: PMenuItem); far;
     begin
      with Item^ do if On then Inc(State,mn_Visible) else Dec(State,mn_Visible)
     end;
    begin
     Item_List^.Item_For(@DoVisible);
    end;

   procedure TMenu.On_Modal;
    begin
     inherited On_Modal(On);
     if On then Exit;
     Item_Select(nil);
     State_Set(sf_AutoOpen, False)
    end;

   constructor TMenuBar.Init(const Area: TRect; AOptions: word; AList: PMenuTree);
    begin
     if AList = nil then Fail;
     inherited Init(Area);
     Char_Mask:=kb_Alt;
     Options:=Options or of_AutoOpen or AOptions;
     GrowMode:=gm_GrowHiX;
     Item_List:=AList
    end;

   procedure TMenuBar.Item_Area(Item: PMenuItem; var Area: TRect);
    function DoItem_Area(MenuItem: PMenuItem): boolean; far;
     begin
      DoItem_Area:=MenuItem = Item;
      Area.A.X:=Area.B.X;
      with MenuItem^ do if Name <> nil
      then Inc(Area.B.X,HotStr_Width(Name^)+Metric_Menu.X+1)
     end;
    begin
     Area_Free(Area);
     Area.B.X:=Area.A.X;
     Item_List^.Item_Case(@DoItem_Area)
    end;

   procedure TMenuBar.Canvas_Paint;
    var
     CNormal,CDisabl,CSelect: pointer;
     W: integer;
     Area: TRect;
     Marge: integer;

    procedure DoCanvas_Paint(Item: PmenuItem); far;
      var C :pointer;
     begin
      with Item^,Style_Palette^ do if Name <> nil then begin
       Area.B.X:=Area.A.X+HotStr_Width(Name^)+Metric_Menu.X;
       if (Item = Item_Curr) then begin
        S3D_Body(Area,1,Color[6]);
        C:=@Color[11]
       end else C:=@Color[9];
       if (State and mn_Disabled <> 0)  then C:=@Color[11];
       S3D_HotStr(Area.A.X+Marge,W,Name^,C^);
       Area.A.X:=Area.B.X+1
      end
     end;

    begin
     Canvas_Frame;
     Marge:=Metric_Menu.X div 2;
     Area_Free(Area);
     with Style_Palette^ do S3D_Body(Area,1,Color[3]);
     Area.Grow(-1,-1);
     W:=(TextHeight('W')+Size.Y) div 2;
     Item_List^.Item_For(@DoCanvas_Paint);
    end;

   procedure TMenuBar.Event_Diler(var E: TEvent);
    begin
     inherited Event_Diler(E);
     if not (sf_Modal in State) and (Menu_Sup = nil)
     or (E.What <> ev_KeyDown) then Exit;
     case E.AbsKey.Code of
      kb_Left: DoSelect(False);
      kb_Right :  DoSelect(True);
      kb_Down :  DoStart(Item_Curr)
      else Exit
     end;
     Event_Clr(E)
    end;

{Методы определения Стиля (Style) окна}

   function TMenuBar.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_MenuBar
    end;

{--------------------------------------------------------------------------}


   constructor TMenuSys.Init;
    begin
     if AList = nil then Fail;
     inherited Init(Area);
     Item_List:=New_Tree(New_List(Title,hc_MenuSys,AList,nil));
     Options:=Options or of_AutoOpen or AOptions;
     Char_Mask:=kb_Alt
    end;

   procedure TMenuSys.Item_Area;
    begin
     Area_Local(Area)
    end;

   procedure TMenuSys.Event_Diler(var E: TEvent);
    begin
     inherited Event_Diler(E);
     if not (sf_Modal in State) and (Menu_Sup = nil)
     or (E.What <> ev_KeyDown) then Exit;
     case E.AbsKey.Code of
      kb_Left: DoSelect(False);
      kb_Right :  DoSelect(True);
      kb_Down :  DoStart(Item_Curr)
      else Exit
     end;
     Event_Clr(E)
    end;

   procedure TMenuSys.Canvas_Paint;
    var
     C: byte;
     Area: TRect;
    begin
     Canvas_Frame;
     with Style_Palette^ do begin
      if Item_Curr = nil then C:=0 else C:=5;
      Area_Free(Area);
      S3D_Body(Area,1,Color[3+C]);
      with Item_List^.Item_First^ do
      S3D_HotStr((Size.X-HotStr_Width(Name^)) div 2,
      (Size.Y+TextHeight(Name^)) div 2,Name^,Color[6+C])
     end;
    end;

{Методы определения Стиля (Style) окна}

   function TMenuSys.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_MenuSys
    end;


{--------------------------------------------------------------------------}

   constructor TMenuBox.Init(const Area: TRect; AOptions: word; AList: PMenuTree);
    begin
     inherited Init(Area);
     Char_Mask:=kb_Char;
     if Origin.X < 0 then Origin.X:=0;
     if Origin.Y < 0 then Origin.Y:=0;
     Options:=Options or AOptions;
     Item_List:=AList
    end;

   procedure TMenuBox.Area_Check;
    var
     W,H,L,Marge: Integer;
     P: PMenuItem;
    begin
     W:=Metric_Menu.X;
     H:=Metric_Menu.Y;
     P:=Item_List^.Item_First;
     Marge:=Metric_Menu.X div 2;
     while P <> nil do begin
      L:=HotStr_Width(P^.Name^) + 2*Metric_Menu.X;
      if P^.State and mn_Command = 0 then Inc(L,Metric_Menu.X+Marge) else
      if P^.Param <> nil then Inc(L,TextWidth(P^.Param^)+Metric_Menu.X);
      if (P^.State and mn_Line <> 0) then Inc(H,Metric_Menu.Y div 2);
      if L > W then W:=L;
      Inc(H,Metric_Menu.Y);
      P:=P^.Next
     end;
     Size.X:=W;
     Size.Y:=H;
     if Origin.X+Size.X > Parent^.Size.X then Origin.X:=Parent^.Size.X-Size.X;
     if Origin.Y+Size.Y > Parent^.Size.Y then Origin.Y:=Parent^.Size.Y-Size.Y
    end;

   procedure TMenuBox.Item_Area(Item: PMenuItem; var Area: TRect);
     var Delta: integer;
    function DoItem_Area(MenuItem: PMenuItem): boolean; far;
     begin
      DoItem_Area:= MenuItem = Item;
      if (MenuItem^.State and mn_Line <> 0) then Inc(Area.B.Y,Delta);
      Inc(Area.B.Y,Metric_Menu.Y)
     end;
    begin
     Delta:=Metric_Menu.Y div 2;
     with Area do begin
      A.X:=Metric_Menu.X div 2;
      B.X:=Size.X-A.X;
      B.Y:=Delta;
      Item:=Item_List^.Item_Case(@DoItem_Area);
      A.Y:=Area.B.Y-Metric_Menu.Y
     end
    end;

   procedure TMenuBox.Canvas_Paint;
    var
     Area: TRect;
     Marge: TPoint;
     D,W,L: integer;

    procedure DoCanvas_Paint(Item: PMenuItem); far;
      var C: pointer;
     begin
      with Style_Palette^,Item^ do begin
       if State and mn_Line <> 0 then begin
        Area.Open(0,W+Marge.Y,Size.X,1);
        S3D_Rect(Area,1,Color[6]);
        Inc(W,Metric_Menu.Y div 2)
       end;
       if (Item = Item_Curr) then begin
        Area.Assign(Marge.X,W,Size.X-Marge.X,W+Metric_Menu.Y);
        S3D_Body(Area,1,Color[8]);
        if State and mn_Disabled = 0 then C:=@Color[11] else C:=@Color[13]
       end else if State and mn_Disabled = 0 then C:=@Color[15]
       else C:=@Color[17];
       S3D_HotStr(Metric_Menu.X,W+D,Name^,C^);
       if State and mn_Command = 0 then
       S3D_HotStr(Size.X-Metric_Menu.X-L,W+D,Symbol[1],C^)
       else if Param <> nil then
       S3D_HotStr(Size.X-Metric_Menu.X-TextWidth(Param^),W+D,Param^,C^);
       Inc(W,Metric_Menu.Y)
      end
     end;

    begin
     Canvas_Frame;
     Area_Free(Area);
     with Style_Palette^ do S3D_Body(Area,1,Color[3]);
     Marge.X:=Metric_Menu.X div 2;
     Marge.Y:=Metric_Menu.Y div 4;
     L:=TextHeight(' ');
     D:=(Metric_Menu.Y+L) div 2;
     W:=Marge.X;
     Item_List^.Item_For(@DoCanvas_Paint);
    end;

   procedure TMenuBox.Event_Diler(var E: TEvent);
    begin
     inherited Event_Diler(E);
     if not (sf_Modal in State) and (Menu_Sup = nil)
     or (E.What <> ev_KeyDown) then Exit;
     case E.AbsKey.Code of
      kb_Up: DoSelect(False);
      kb_Down:  DoSelect(True)
      else Exit
     end;
     Event_Clr(E)
    end;

   procedure TMenuBox.On_Exposed;
    begin
     if On then Area_Check;
     inherited On_Exposed(On)
    end;

{Методы определения Стиля (Style) окна}

   function TMenuBox.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_MenuBox
    end;

{------------------------------------------------------------------------}

   constructor TCtxItem.Init;
    begin
     Text:=Str_New(AText);
     Next:=ANext;
     Ctx:=ACtx;
    end;

   destructor TCtxItem.Done;
    begin
     if Parent <> nil then Parent^.Item_Del(@Self);
     Str_Dsp(Text);
    end;


{------------------------------------------------------------------------}

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor THelpBar.Init;
    begin
     inherited Init(Area);
     Options:=Options or AOptions;
     GrowMode:=gm_GrowHiX;
     Item_First:=List
    end;

   destructor THelpBar.Done;
    begin
     inherited Done;
     while Item_First <> nil do Dispose(Item_First,Done(@Self))
    end;

{Методы для управления Событиями (Event)}

    function  THelpBar.Event_Mask: word;
     begin
      Event_Mask:=ev_Idle;
     end;

{Методы управления Пунктами (Item) контекста}

   function THelpBar.Item_Last: PCtxItem;
     var Last: PCtxItem;
    begin
     Last:=Item_First;
     while (Last <> nil) and (Last^.Next <> nil) do Last:=Last^.Next;
     Item_Last:=Last
    end;

   function THelpBar.Item_Prev(Item: PCtxItem): PCtxItem;
     var Prev: PCtxItem;
    begin
     Prev:=Item_First;
     while (Prev <> nil) and (Prev^.Next <> Item) do Prev:=Prev^.Next;
     Item_Prev:=Prev
    end;

   function THelpBar.Item_Find(HelpCtx: word): PCtxItem;
     var Item: PCtxItem;
    begin
     Item:=Item_First;
     while (Item <> nil) and (Item^.Ctx <> HelpCtx) do Item:=Item^.Next;
     Item_Find:=Item
    end;

   procedure THelpBar.Item_Ins(Item: PCtxItem);
    begin
     if Item_First <> nil then Item_Last^.Next:=Item else Item_First:=Item
    end;

   procedure THelpBar.Item_Del(Item :PCtxItem);
    begin
     if Item_First <> Item then Item_Prev(Item)^.Next:=Item^.Next
     else Item_First:=Item^.Next
    end;

   procedure THelpBar.Item_Select(Item: PCtxItem);
    begin
     if Item_Curr = Item then Exit;
     Item_Curr:=Item;
     Draw
    end;

{Методы Обработки (Proc)}

   procedure THelpBar.Event_Diler(var E: TEvent);
     var Ctx: word;
    begin
     inherited Event_Diler(E);
     with E do if (What <> ev_Idle) and (E.Count <> 2) then Exit;
     Ctx:=Parent^.HelpCtx_Get;
     if (Item_Curr <> nil) and (Item_Curr^.Ctx = Ctx) then Exit;
     Item_Select(Item_Find(Ctx))
    end;

   procedure THelpBar.Canvas_Paint;
     var Area: TRect;
    begin
     Canvas_Frame;
     Area_Free(Area);
     SetFillStyle(SolidFill,Style_Palette^.Color[3]);
     with Area do Bar(A.X,A.Y,B.X,B.Y);
     if Item_Curr = nil then Exit;
     with Item_Curr^,Style_Palette^,Metric_Box do
     S3D_Str(X div 2,(Size.Y+TextHeight(Text^)) div 2,Text^,Color[4])
    end;

{Методы определения Стиля (Style) окна}

   function THelpBar.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_HelpBar;
    end;


{-------------------------------------------------------------------------}

   procedure THelpBox.Canvas_Paint;
     var Area: TRect;
    begin
     Canvas_Frame;
     Area_Free(Area);
     SetFillStyle(SolidFill,Style_Palette^.Color[3]);
     with Area do Bar(A.X,A.Y,B.X,B.Y);
     if Item_Curr = nil then Exit;
     with Item_Curr^ do OutTextRect(Area,Text^,Style_Palette^.Color[4])
    end;


{Методы определения Стиля (Style) окна}

   function THelpBox.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_HelpBox;
    end;


{--------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor THelpKey.Init(const Area: TRect;AOptions: word; List: PCtxItem);
    begin
     inherited Init(Area,AOptions,List);
     GrowMode:=0;
    end;

   function THelpKey.Event_Mask: word;
    begin
     Event_Mask:=ev_MouseDown
    end;

{Методы Обработки (Proc)}

   procedure THelpKey.Event_Diler(var E: TEvent);
     var Box: PView;
    begin
     inherited Event_Diler(E);
     if E.What <> ev_MouseDown then Exit;
     State_Set(sf_Down,True);
     Event_Get(ev_MouseUp,E);
     State_Set(sf_Down,False);
     with Application^.Indicator^ do if Parent_Is(Self.Parent) then begin
      Item_Curr:=Item_Find(Application^.Indicator^.HelpCtx_Get);
      if Item_Curr <> nil then Application^.Child_Exec(New(
       PPhrase,Init(E.Where,Item_Curr^.Text^,Palette_ReplBlue)
      ));
     end;
     Event_Clr(E);
    end;

   procedure THelpKey.Canvas_Paint;
    var
     TextColor,H,C: integer;
     D: TPoint;
     Area: TRect;
    begin
     Area_Free(Area);
     D.X:=Size.X div 2;
     D.Y:=size.Y div 2;
     H:=1;
     if sf_Down in State then begin
      Inc(longint(D),$00010001);
      if H > 1 then Dec(H) else H:=-1
     end;
     if sf_Disabled in State then C:=8 else C:=6;
     with Style_Palette^ do begin;
      S3D_Body(Area,H,Color[3]);
      S3D_Str(D.X,D.Y,Symbol[13],Color[C])
     end;
     Canvas_Frame
    end;

   procedure THelpKey.On_Down;
    begin
     Draw;
    end;

{Методы определения Стиля (Style) окна}

   function  THelpKey.Style_Palette: PPalette;
    begin
     Style_Palette:=pointer(@Palette_Key);
    end;

  var

   ProcInit: procedure;

   procedure DoInitMetrics; far;
    begin
     ProcInit;
     Metric_Menu:=Metric_Box
    end;

  begin
   ProcInit:=Metric_Init;
   Metric_Init:=DoInitMetrics
  end.
