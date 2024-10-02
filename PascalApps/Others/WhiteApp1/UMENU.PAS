 {      ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
        ≥                                           ≥
        ≥      W h i t e  A p p l i c a t o r       ≥
        ≥                                           ≥
        ≥              U M e n u    2.0             ≥
        ≥                                           ≥
        ≥       Copyright (c)  S.Novak  1995        ≥
        ≥             (054) 33-35-94                ≥
        ≥                                           ≥
        ≥               (interface)                 ≥
        ≥                                           ≥
        ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ      }

 {$I UMENU.INC}

 implementation

  uses

   Graph, UGraph;

   function New_Item(const AName,AParam: string; AKeyCode,ACommand,AHelpCtx: word;
    ANext: PMenuItem): PMenuItem;
    var
     Item: PMenuItem;
    begin
     if (AName <> '') and (ACommand <> 0) then begin
      New(Item);
      with Item^ do begin
       Command:=ACommand;
       HelpCtx:=AHelpCtx;
       KeyCode:=AKeyCode;
       Name:=Str_New(AName);
       New_Item:=Item;
       Next:=ANext;
       Param:=Str_New(AParam);
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
       Command:=cm_NoComm;
       HelpCtx:=AHelpCtx;
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
       Str_Del(Name);
       if State and mn_Command <> mn_Not then Str_Del(Param) else List^.Free
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
         XOR     AX, AX
         CMP     AX, ES:[DI].TMenuItem.Command
         JNE     @1
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
         XOR     BX, BX
         CMP     BX, ES:[DI].TMenuItem.Command
         JNE     @1
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

{ê•†´®ß†Ê®Ô Æ°Í•™‚† å•≠Ó (Menu) }
{--------------------------------------------------------------------------}

{å•‚Æ§Î CÆß§†≠®Ô (Init) ® PÆß‡„Ë•≠®Ô(Done) Æ™≠†}

   constructor TMenu.Init(const Area: TRect);
    begin
     inherited Init(Area);
     Event_Mask:=ev_FreeTime+ev_Valid;
     Menu_Next:=@Self
    end;

   destructor TMenu.Done;
    begin
     inherited Done;
     Menu_Sub^.Free;
     if Menu_Sup <> nil then Menu_Sup^.Menu_Sub:=nil else Item_List^.Free
    end;

{å•‚Æ§Î äÆ≠‚•™·‚† èÆ¨ÆÈ® (HelpCtx)}

   function TMenu.HelpCtx_Get: word;
     var Res: word;
    begin
     Res:=hc_NoContext;
     if Menu_Sub <> nil then Res:=Menu_Sub^.HelpCtx_Get;
     if (Res = hc_NoContext) and (Item_Curr <> nil)
     then Res:=Item_Curr^.HelpCtx;
     HelpCtx_Get:=Res
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


{å•‚Æ§Î ‡†°Æ‚Î · êÆ§®‚•´Ï·™®¨ (Parent) Æ™≠Æ¨}

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
      Dlg_Stop(cm_Cancel);
      with Menu^ do begin
       DoCommand(cm_MenuNext);
       with Item_List^ do if Forw then Item_Def:=Item_First
       else Item_Def:=Item_Prev(nil);
       Proc_State(sf_AutoOpen,(Self.State and sf_AutoOpen <> 0)
       and (Options and of_AutoOpen <> 0));
      end
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
     if Item = nil then Dlg_Stop(cm_Cancel)
     else begin
      Item_Select(Item);
      with Item_Curr^ do case State and (mn_Command + mn_SubMenu) of
       mn_SubMenu:
        begin
         if Menu_Sub = nil then DoSubMenu;
         with Menu_Sub^ do Item_Select(Item_List^.Item_Def)
        end;
       mn_Command:  Dlg_Stop(Command)
      end
     end
    end;

   procedure TMenu.DoSubMenu;
    var
     Area: TRect;
     Point: TPoint;
    begin
     if Item_Curr = nil then Exit;
     longint(Point):=0;
     Point_Global(Point,Point);
     Item_Area(Item_Curr,Area);
     Area.A.Y:=Area.B.Y;
     Area.Move(Point.X,Point.Y);
     Menu_Sub:=New_Menu(Area,Item_Curr^.List);
     Menu_Sub^.Menu_Sup:=@Self;
     Application^.Child_Ins(Menu_Sub);
     State_Set(sf_AutoOpen,Options and of_AutoOpen <> 0)
    end;

   procedure TMenu.Proc_Event(var E: TEvent);

    function FindHotKey: PMenuItem;
      var Ch: char;

     function DoFind(MenuItem: PMenuItem): boolean; far;
       var NameCh: char;
      begin
       with MenuItem^,E do if State and mn_Disabled = 0 then begin
        NameCh:=Text_Ch(Name^);
        DoFind:=(Char_Mask and kf_Char <> 0) and (Ch = NameCh)
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
       Dlg_Stop(cm_Cancel);
       Menu^.DoCommand(cm_MenuExec);
       Event_Put(E)
      end;
      MouseInMenu:=True;
     end;

    procedure DoCheck;
      var Res: boolean;

     procedure DoCheck(Item: PMenuItem); far;
      begin
       with Item^ do if (State and mn_Command = 0) or (E.Command <> Command)
       or (E.InfoBool = (State and mn_Disabled = 0)) then Exit;
       Res:=Res or (State and mn_Visible <> 0);
       with Item^,E do if InfoBool then Inc(State,mn_Disabled)
       else Dec(State,mn_Disabled)
      end;

     begin
      Res:=False;
      Item_List^.Tree_For(@DoCheck);
      if Res then Draw
     end;

    procedure DoExecute(Item: PMenuItem);
      var Result: word;
     begin
      Item_Select(Item);
      Result:=Dlg_Exec;
      if Result <> cm_Cancel then DoCommand(Result);
      Event_Clr(E)
     end;

    procedure DoLinkMenu;
     begin
      if (State and sf_Active <> 0) and (E.InfoPtr <> @Self) then
      with PMenu(E.InfoPtr)^ do begin
       Self.Menu_Next:=Menu_Next;
       Menu_Next:=@Self
      end
     end;

    procedure DoLinkSelf;
     begin
      Menu_Next:=@Self;
      Message(Dialog,ev_Broadcast,cm_MenuLink,@Self);
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
     inherited Proc_Event(E);
     if Menu_Sub <> nil then Menu_Sub^.Proc_Event(E);
     if (State and sf_Modal = 0) and (Menu_Sup = nil) then
     case E.What of
      ev_Command:
       case E.Command of
        cm_Menu: DoMenu;
        cm_MenuNext: if E.InfoPtr = @Self then DoExecute(Item_List^.Item_Def);
        cm_MenuExec: if E.InfoPtr = @Self then DoExecute(nil);
       end;
      ev_Broadcast:
       if E.Command = cm_MenuLink then DoLinkMenu;
      ev_KeyDown: DoKeyDown;
      ev_MouseDown: DoMouseDown;
      ev_Valid: DoCheck;
     end else begin
      if (E.What and (ev_MouseDown+ev_MouseUp) <> 0) and (Menu_Sup <> nil)
      and (Application^.Indicator <> @Self) then Exit;
      case E.What of
       ev_FreeTime:
        begin
         if (State and sf_AutoOpen <> 0)
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
        not MouseInMenu then Dlg_Stop(cm_Cancel)
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
          then Menu_Sub^.Free else Dlg_Stop(cm_Cancel);
         else if not KeyInMenu then Exit
        end;
       else Exit
      end;
      Event_Clr(E)
     end
    end;

   procedure TMenu.Proc_State(AState: word; On: boolean);

    procedure DoVisible(Item: PMenuItem); far;
     begin
      with Item^ do if On then Inc(State,mn_Visible) else Dec(State,mn_Visible)
     end;

    begin
     inherited Proc_State(Astate,On);
     case AState of
      sf_Exposed: Item_List^.Item_For(@DoVisible);
      sf_Modal:
       if not On then begin
        Item_Select(nil);
        State_Set(sf_AutoOpen, False)
       end;
      sf_Active:
       Event_Set(ev_Mouse+ev_Focused+ev_Broadcast,On)
     end
    end;

   constructor TMenuBar.Init(const Area: TRect; AOptions: word; AList: PMenuTree);
    begin
     if AList = nil then Fail;
     inherited Init(Area);
     Char_Mask:=kf_Alt;
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
      then Inc(Area.B.X,Text_Width(Name^)+Metric_Menu.X+1)
     end;
    begin
     Area_Free(Area);
     Area.B.X:=Area.A.X;
     Style_Font;
     Item_List^.Item_Case(@DoItem_Area)
    end;

   procedure TMenuBar.Proc_Paint;
    var
     CNormal,CDisabl,CSelect: pointer;
     W: integer;
     Area: TRect;
     Marge: integer;

    procedure DoProc_Paint(Item: PmenuItem); far;
      var C :pointer;
     begin
      with Item^,Style_Palette^ do if Name <> nil then begin
       Area.B.X:=Area.A.X+Text_Width(Name^)+Metric_Menu.X;
       if (Item = Item_Curr) then begin
        S3D_Body(Area,1,Color[6]);
        C:=@Color[11]
       end else C:=@Color[9];
       if (State and mn_Disabled <> 0)  then C:=@Color[11];
       Text_3D(Area.A.X+Marge,W,Name^,C^);
       Area.A.X:=Area.B.X+1
      end
     end;

    begin
     Marge:=Metric_Menu.X div 2;
     Area_Free(Area);
     with Style_Palette^ do S3D_Body(Area,1,Color[3]);
     Area.Grow(-1,-1);
     Style_Font;
     W:=(TextHeight('W')+Size.Y) div 2;
     Item_List^.Item_For(@DoProc_Paint);
     inherited Proc_Paint;
    end;

   procedure TMenuBar.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     if (State and sf_Modal = 0) and (Menu_Sup = nil)
     or (E.What <> ev_KeyDown) then Exit;
     case E.AbsKey.Code of
      kb_Left: DoSelect(False);
      kb_Right :  DoSelect(True);
      kb_Down :  DoStart(Item_Curr)
      else Exit
     end;
     Event_Clr(E)
    end;

{å•‚Æ§Î ÆØ‡•§•´•≠®Ô ë‚®´Ô (Style) Æ™≠†}

   function TMenuBar.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_MenuBar
    end;

   constructor TMenuSys.Init;
    begin
     if AList = nil then Fail;
     inherited Init(Area);
     Item_List:=New_Tree(New_List(Title,hc_MenuSys,AList,nil));
     Options:=Options or of_AutoOpen or AOptions;
     Char_Mask:=kf_Alt
    end;

   procedure TMenuSys.Item_Area;
    begin
     Area_Local(Area)
    end;

   procedure TMenuSys.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     if (State and sf_Modal = 0) and (Menu_Sup = nil)
     or (E.What <> ev_KeyDown) then Exit;
     case E.AbsKey.Code of
      kb_Left: DoSelect(False);
      kb_Right :  DoSelect(True);
      kb_Down :  DoStart(Item_Curr)
      else Exit
     end;
     Event_Clr(E)
    end;

   procedure TMenuSys.Proc_Paint;
    var
     C: byte;
     Area: TRect;
    begin
     Style_Font;
     with Style_Palette^ do begin
      if Item_Curr = nil then C:=0 else C:=5;
      Area_Free(Area);
      S3D_Body(Area,1,Color[3+C]);
      with Item_List^.Item_First^ do
      Text_3D((Size.X-Text_Width(Name^)) div 2,
      (Size.Y+TextHeight(Name^)) div 2,Name^,Color[6+C])
     end;
     inherited Proc_Paint
    end;

{å•‚Æ§Î ÆØ‡•§•´•≠®Ô ë‚®´Ô (Style) Æ™≠†}

   function TMenuSys.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_MenuSys
    end;

   constructor TMenuBox.Init(const Area: TRect; AOptions: word; AList: PMenuTree);
    begin
     inherited Init(Area);
     Char_Mask:=kf_Char;
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
      L:=Text_Width(P^.Name^) + 2*Metric_Menu.X;
      if P^.Command = 0 then Inc(L,Metric_Menu.X+Marge) else
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

   procedure TMenuBox.Proc_Paint;
    var
     Area: TRect;
     Marge: TPoint;
     D,W,L: integer;

    procedure DoProc_Paint(Item: PMenuItem); far;
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
       Text_3D(Metric_Menu.X,W+D,Name^,C^);
       if Command = 0 then
       Text_3D(Size.X-Metric_Menu.X-L,W+D,Symbol[1],C^)
       else if Param <> nil then
       Text_3D(Size.X-Metric_Menu.X-TextWidth(Param^),W+D,Param^,C^);
       Inc(W,Metric_Menu.Y)
      end
     end;

    begin
     Area_Free(Area);
     Style_Font;
     with Style_Palette^ do S3D_Body(Area,1,Color[3]);
     Marge.X:=Metric_Menu.X div 2;
     Marge.Y:=Metric_Menu.Y div 4;
     L:=TextHeight(' ');
     D:=(Metric_Menu.Y+L) div 2;
     W:=Marge.X;
     Item_List^.Item_For(@DoProc_Paint);
     inherited Proc_Paint
    end;

   procedure TMenuBox.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     if (State and sf_Modal = 0) and (Menu_Sup = nil)
     or (E.What <> ev_KeyDown) then Exit;
     case E.AbsKey.Code of
      kb_Up: DoSelect(False);
      kb_Down:  DoSelect(True)
      else Exit
     end;
     Event_Clr(E)
    end;

   procedure TMenuBox.Proc_State;
    begin
     inherited Proc_State(AState,on);
     if (AState = sf_Exposed) and On then Area_Check
    end;

{å•‚Æ§Î ÆØ‡•§•´•≠®Ô ë‚®´Ô (Style) Æ™≠†}

   function TMenuBox.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_MenuBox
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
