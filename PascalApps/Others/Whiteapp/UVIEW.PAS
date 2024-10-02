 {      ┌───────────────────────────────────────────┐
        │                                           │
        │            E a s t   S t u d i o          │
        │                                           │
        │              U V i e w    4.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1996        │
        │             (054) 33-35-94                │
        │                                           │
        │             (implementation)              │
        │                                           │
        └───────────────────────────────────────────┘      }

  {$I INC\UVIEW.INC}

  implementation

   const

    sm_Exposed = 1 shl sf_Exposed;
    sm_Visible = 1 shl sf_Visible;

    Modal_View: PView = nil;
    Modal_Result: word  = cm_Idle;

    Scr_Count: word = 0;
    Scr_Flag: boolean = False;

   var

    Scr_Actual: TRect;
    Scr_Invalid: TRect;
    Scr_Visual: TRect;
    Scr_Origin: TPoint;
    Scr_Canvas: TRect;

   procedure Scr_SetPort(const Scr,Win :TRect);
    begin
     Scr_Canvas:=Scr;
     Scr_Canvas.Intersect(Win);
     with Scr_Canvas do begin
      SetViewPort(A.X, A.Y, B.X, B.Y, ClipOn);
      SetViewOrg(Win.A.X-A.X, Win.A.Y-A.Y)
     end
    end;

   procedure Scr_Lock;
    begin
     Inc(Scr_Count)
    end;

   procedure Scr_UnLock;
    begin
     if Scr_Count > 0 then Dec(Scr_Count);
     if (Scr_Count <> 0) or not Scr_Flag then Exit;
     Scr_Flag:=False;
     Application^.Draw_Rect(Scr_Invalid)
    end;

   procedure Event_Perform(View: PView; var E: TEvent; Index: word); assembler;
     asm
         MOV    AX, Index
         LES    BX, View
         CALL   Find_Proc
         OR     AX, AX
         JE     @Exit
      @Run:
         LES    BX,  E
         PUSH   ES
         PUSH   BX
         LES    BX,  View;
         PUSH   ES
         PUSH   BX
         CALL   DWORD PTR [DI]
      @Exit:
    end;

   function Valid_Perform(View: PView; Index: word): boolean; assembler;
     asm
         MOV    AX, Index
         LES    BX, View
         CALL   Find_Proc
         XOR    AX,1
         JNZ    @Exit
      @Run:
         LES    BX,  View;
         PUSH   ES
         PUSH   BX
         CALL   DWORD PTR [DI]
      @Exit:
    end;

   procedure State_Perform(View: PView; Index: word; On: boolean); assembler;
     asm
         MOV    AX, Index
         LES    BX, View
         CALL   Find_Proc
         OR     AX,AX
         JE     @Exit
      @Run:
         LES    BX,  View;
         PUSH   WORD PTR ON
         PUSH   ES
         PUSH   BX
         CALL   DWORD PTR [DI]
      @Exit:
    end;

{Реализация объекта Вида (View) }
{--------------------------------------------------------------------------}

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TView.Init(const Area: TRect);
    begin
     inherited Init;
     TView.Area_Proc(Area);
     State:=[sf_Visible];
    end;

   destructor TView.Done;
    begin
     if Parent <> nil then Parent^.Child_Del(@Self)
    end;

{Методы работы с Областью (Area) отображения}

   procedure TView.Area_Calc(Delta: TPoint);
     var Area: TRect;
    begin
     Area_Get(Area);
     with Area do begin
      if GrowMode and gm_GrowLoX <> 0 then Inc(A.X, Delta.X);
      if GrowMode and gm_GrowHiX <> 0 then Inc(B.X, Delta.X);
      if GrowMode and gm_GrowLoY <> 0 then Inc(A.Y, Delta.Y);
      if GrowMode and gm_GrowHiY <> 0 then Inc(B.Y, Delta.Y)
     end;
     Area_Proc(Area)
    end;

   procedure TView.Area_Clip(var Area: TRect); assembler;
    asm
        PUSH    DS
        LES     DI, Self
        CLD
     @0:MOV     AX, ES
        OR      AX, DI
        JE      @5
        XOR     BX, BX
        MOV     CX, ES:[DI].TView.Size.X
        MOV     DX, ES:[DI].TView.Size.Y
        MOV     DS, ES:[DI].TView.Origin.X
        MOV     SI, ES:[DI].TView.Origin.Y
        MOV     AL, BYTE PTR ES:[DI].TView.Options[1]
        MOV     AH, 1 shl 3
        TEST    AL, AH
        JZ      @BY
        DEC     DX
   @BY: SHR     AH, 1
        TEST    AL, AH
        JZ      @BX
        DEC     CX
   @BX: SHR     AH, 1
        TEST    AL, AH
        JZ      @AY
        INC     BX
   @AY: SHR     AH, 1
        AND     AL, AH
        XOR     AH, AH
        PUSH    ES
        PUSH    DI
        LES     DI, Area
        CMP     ES:[DI].TRect.A.X, AX
        JG      @1
        MOV     ES:[DI].TRect.A.X, AX
     @1:MOV     AX, DS
        ADD     ES:[DI].TRect.A.X, AX
        CMP     ES:[DI].TRect.A.Y, BX
        JG      @2
        MOV     ES:[DI].TRect.A.Y, BX
     @2:ADD     ES:[DI].TRect.A.Y, SI
        CMP     ES:[DI].TRect.B.X, CX
        JL      @3
        MOV     ES:[DI].TRect.B.X, CX
     @3:ADD     ES:[DI].TRect.B.X, AX
        CMP     ES:[DI].TRect.B.Y, DX
        JL      @4
        MOV     ES:[DI].TRect.B.Y, DX
     @4:ADD     ES:[DI].TRect.B.Y, SI
        POP     DI
        POP     ES
        LES     DI, ES:[DI].TView.Parent
        JMP     @0
     @5:POP     DS
    end;

   procedure TView.Area_Free(var Area: TRect); assembler;
    asm
         LES     DI, Self
         MOV     CX, ES:[DI].Size.X
         MOV     DX, ES:[DI].Size.Y
         MOV     BL, BYTE PTR ES:[DI].Options[1]
         MOV     BH, 1
         XOR     AX, AX
         MOV     SI, AX
         TEST    BL, BH
         JZ      @1
         INC     AX
    @1:  SHL     BH, 1
         TEST    BL, BH
         JZ      @2
         INC     SI
    @2:  SHL     BH, 1
         TEST    BL, BH
         JZ      @3
         DEC     CX
    @3:  SHL     BH, 1
         TEST    BL, BH
         JZ      @4
         DEC     DX
    @4:  CLD
         LES     DI, Area
         STOSW
         MOV     AX, SI
         STOSW
         MOV     AX, CX
         STOSW
         MOV     AX, DX
         STOSW
    end;

   procedure TView.Area_Full(var Area: TRect); assembler;
    asm
         LES     DI, Self
         MOV     CX, ES:[DI].Size.X
         MOV     DX, ES:[DI].Size.Y
         XOR     AX, AX
         TEST    ES:[DI].Options, of_Shadow
         JZ      @1
         ADD     CX, Metric_Shadow.X
         ADd     DX, Metric_Shadow.Y
     @1: CLD
         LES     DI, Area
         STOSW
         STOSW
         MOV     AX, CX
         STOSW
         MOV     AX, DX
         STOSW
     end;

   procedure TView.Area_Get(var Area: TRect); assembler;
    asm
         MOV     DX,DS
         LES     DI,Area
         LDS     SI,Self
         MOV     AX,[SI].Origin.X
         MOV     ES:[DI].TRect.A.X,AX
         ADD     AX,[SI].Size.X
         MOV     ES:[DI].TRect.B.X,AX
         MOV     AX,[SI].Origin.Y
         MOV     ES:[DI].TRect.A.Y,AX
         ADD     AX,[SI].Size.Y
         MOV     ES:[DI].TRect.B.Y,AX
         MOV     DS,DX
    end;

   procedure TView.Area_Limit(var Limit: TRect);
    begin
     with Limit do begin
      Longint(A):=$88888888;
      B.X:=Metric_Scr.X;
      B.Y:=Metric_Scr.Y
     end
    end;

   procedure TView.Area_Local(var Area: TRect); assembler;
    asm
         MOV     DX,DS
         CLD
         LES     DI,Area
         LDS     SI,Self
         XOR     AX,AX
         STOSW
         STOSW
         MOV     AX,[SI].TView.Size.X
         STOSW
         MOV     AX,[SI].TView.Size.Y
         STOSW
         MOV     DS,DX
    end;

   procedure TView.Area_Mark(var Area: TRect);
    begin
     longint(Area.A):=0;
     longint(Area.B):=$FFFFFFFF;
    end;

   procedure TView.Area_Max(var Area: TRect); assembler;
    asm
         LES     DI, Self
         MOV     AX, ES:[DI].Origin.X
         MOV     BX, ES:[DI].Origin.Y
         MOV     CX, ES:[DI].Size.X
         MOV     DX, ES:[DI].Size.Y
         TEST    ES:[DI].Options, of_Shadow
         JZ      @1
         ADD     CX, Metric_Shadow.X
         ADD     DX, Metric_Shadow.Y
     @1: CLD
         LES     DI, Area
         ADD     AX, Scr_Origin.X
         ADD     CX, AX
         STOSW
         MOV     AX, BX
         ADD     AX, Scr_Origin.Y
         ADD     DX, AX
         STOSW
         MOV     AX, CX
         STOSW
         MOV     AX, DX
         STOSW
     end;

   procedure TView.Area_Min(var Area: TRect); assembler;
    asm
         LES     DI, Self
         MOV     SI, ES:[DI].Origin.X
         MOV     BX, ES:[DI].Origin.Y
         MOV     CX, ES:[DI].Size.X
         MOV     DX, ES:[DI].Size.Y
         MOV     AL, BYTE PTR ES:[DI].Options[1]
         MOV     AH, 1 shl 3
         TEST    AL, AH
         JZ      @BY
         DEC     DX
         DEC     DX
     @BY:SHR     AH, 1
         TEST    AL, AH
         JZ      @BX
         DEC     CX
         DEC     CX
     @BX:SHR     AH, 1
         TEST    AL, AH
         JZ      @AY
         INC     BX
     @AY:SHR     AH, 1
         AND     AL, AH
         XOR     AH, AH
         ADD     AX, SI
         LES     DI, Area
         ADD     AX, Scr_Origin.X
         ADD     CX, AX
         STOSW
         MOV     AX, BX
         ADD     AX, Scr_Origin.Y
         ADD     DX, AX
         STOSW
         MOV     AX, CX
         STOSW
         MOV     AX, DX
         STOSW
     end;

   procedure TView.Area_Proc(const Area: TRect); assembler;
     asm
         PUSH    DS
         LES     DI,Self
         LDS     SI,Area
         MOV     AX,[SI].TRect.A.X
      @1:MOV     ES:[DI].Origin.X,AX
         MOV     AX,[SI].TRect.A.Y
      @2:MOV     ES:[DI].Origin.Y,AX
         MOV     AX,[SI].TRect.B.X
         SUB     AX,[SI].TRect.A.X
         MOV     ES:[DI].Size.X,AX
         MOV     AX,[SI].TRect.B.Y
         SUB     AX,[SI].TRect.A.Y
         MOV     ES:[DI].Size.Y,AX
         POP     DS
    end;

   procedure TView.Area_Set(const Area: TRect);
    var
     Ex,Un: TRect;
     Lock: boolean;
    begin
     Area_Get(Ex);
     if Area.Equals(Ex) then Exit;
     if sf_Visual * State <> sf_Visual then Area_Proc(Area)
     else begin
      Un:=Ex;
      Un.Union(Area);
      with Area do
      Lock:=LongMul(Un.B.X-Un.A.X,Un.B.Y-Un.A.Y) <
      LongMul(B.X-A.X,B.Y-A.Y)+LongMul(Size.X,Size.Y);
      if Lock then Scr_Lock;
      State_Set(sf_Visible,False);
      Area_Proc(Area);
      State_Set(sf_Visible,True);
      if Lock then Scr_UnLock
     end;
     Event_Send(Parent,ev_Notify,cm_ChildLocate,@Self)
    end;

{Методы управления Холстом (Canvas)}

   procedure TView.Canvas_Area(var Area: TRect);
    begin
     Area:=Scr_Canvas;
     with Scr_Origin do Area.Move(-Origin.X-X,-Origin.Y-Y)
    end;

   procedure TView.Canvas_Init;
    function DoCanvasFree(View: PView): boolean; far;
     begin
      View^.Canvas_Free;
      DoCanvasFree:=False
     end;
    begin
     if (State * sf_Visual <> sf_Visual) or Upper_Clip(Area)
     then Scr_Visual.Assign(1,1,-1,-1) else begin
      Area_Max(Scr_Visual);
      Area:=Scr_Visual;
      Application^.Mouse^.Cursor_Hide;
      Scr_SetPort(Scr_Actual,Scr_Visual);
      Upper_Case(@DoCanvasFree);
      Scr_Visual:=Area;
     end;
     Scr_SetPort(Scr_Actual,Scr_Visual);
    end;

   procedure TView.Canvas_Done;
    function DoDrawHood(View: PView): boolean; far; assembler;
     asm
         LES   DI, View;
         PUSH  ES
         PUSH  DI
         CALL  TView.DoDraw
         XOR   AX, AX
     end;
    begin
     if not Scr_Visual.Empty then Upper_Case(@DoDrawHood);
     Application^.Mouse^.Cursor_Show
    end;

   procedure TView.Canvas_Free;
    begin
    end;

   procedure TView.Canvas_Frame;
     var Area: TRect;
    begin
     SetFillStyle(SolidFill,Palette_Shadow);
     Area.A.X:=Succ(Size.X);
     Area.A.Y:=Succ(Size.Y);
     if Options and of_Shadow <> 0 then with Area, Metric_Shadow do begin
      Bar(A.X,Y,A.X+X,A.Y+Y);
      Bar(X,A.Y,A.X,A.Y+Y)
     end;
     if Options and of_Border <> 0 then with Style_Palette^ do begin
      SetLineStyle(SolidLn,0,NormWidth);
      SetColor(Color[1]);
      if Options and of_Top  <> 0 then Line(0,0,Size.X,0);
      if Options and of_Left <> 0 then Line(0,0,0,Size.Y);
      SetColor(Color[2]);
      if Options and of_Right <> 0 then Line(Size.X,0,Size.X,Size.Y);
      if Options and of_Bottom <> 0 then Line(0,Size.Y,Size.X,Size.Y)
     end;
     SetTextStyle(SysFont_Style,HorizDir,SysFont_Size);
     SetTextJustify(LeftText,BottomText);
    end;

   procedure TView.Canvas_Paint;
    begin
     Event_Send(Parent,ev_Notify,cm_ChildPaint,@Self)
    end;

{Методы работы с дочерными (Child) окнами}

   function TView.Child_Find(Point: TPoint): PView;
    begin
     Child_Find:=@Self
    end;

   function TView.Child_Is(View: PView): boolean;
    begin
     Child_Is:=View = @Self
    end;

{Методы управления Командами (Comm)}

   procedure TView.Comm_Audit(cm_XXXX: word;On: boolean);
    begin
    end;

   procedure TView.Comm_Enable(cm_XXXX: word;On: boolean);
    begin
     Comm_Audit(cm_XXXX,On)
    end;

   function TView.Comm_Valid(cm_XXXX: word): boolean;
    function DoValid(View: PView): boolean; far;
     begin
      DoValid:=not View^.Comm_Valid(cm_XXXX)
     end;
    begin
     Comm_Valid:=Valid_Perform(@Self,Validate+cm_XXXX)
     and not (Group and (PGroup(@Self)^.Child_Case(@DoValid) <> nil))
    end;

{Методы для обмена Данных (Data)}

   function TView.Data_Proc;
    begin
     Data_Proc:=0;
    end;

   procedure TView.Data_Swap;
     var Save: TState;
    procedure DoImport(View: PView); far;
     begin
      View^.Data_Swap(ds_XXXX)
     end;
    begin
     if Group then PGroup(@Self)^.Child_For(@DoImport);
     if Data_Ptr <> nil then begin
      Data_Proc(Data_Ptr^,ds_XXXX);
      if ds_XXXX = ds_Export then begin
       Save:=State;
       State:=State+[sf_Disabled];
       UView.Data_Show(Data_Ptr^);
       State:=Save;
      end
     end
    end;

{Методы управления Диалогово (Dlg) режима}

   function TView.Dlg_Exec: Word;
    var
     E: TEvent;
     SaveResult: word;
     SaveModal: PView;
    begin
     SaveResult:=Modal_Result;
     SaveModal:=Modal_View;
     State_Set(sf_Modal,True);
     E.What:=ev_Nothing;
     while Modal_View <> nil do  begin
     if E.What <> ev_Nothing then Event_Err(E);
      Event_Get(Event_Mask,E);
      Event_Diler(E)
     end;
     Dlg_Exec:=Modal_Result;
     Modal_View:=SaveModal;
     Modal_Result:=SaveResult
    end;

   procedure TView.Dlg_Stop(cm_XXXX: word);
    begin
     Modal_View^.State_Set(sf_Modal,False);
     Modal_Result:=cm_XXXX
    end;

{Вспомагательные методы }

   procedure TView.DoDraw;
     var Area: TRect;
    function DoClip(View: PView): boolean; far;
     begin
      with View^ do if Options and of_Glass = 0 then begin
       Area_Get(Area);
       with Scr_Origin do Area.Move(X,Y);
       DoClip:=Scr_Invalid.Clip(Area)
      end else DoClip:=False
     end;
    begin
     Area_Max(Scr_Visual);
     Scr_Invalid:=Scr_Visual;
     Scr_Invalid.Intersect(Scr_Actual);
     if Scr_Invalid.Empty or (Upper_Case(@DoClip) <> nil) then Exit;
     Scr_SetPort(Scr_Invalid,Scr_Visual);
     Canvas_Paint;
     if sf_Focus in State then DoMark
    end;

   procedure TView.DoHide;
    begin
     Area_Full(Scr_Visual);
     if Upper_Clip(Scr_Visual) then Exit;
     Scr_Actual.Move(-Scr_Origin.X,-Scr_Origin.Y);
     Parent^.Draw_Rect(Scr_Actual);
    end;

   procedure TView.DoMark;
     var Area :TRect;
    begin
     Area_Mark(Area);
     if Area.Empty then Exit;
     SetWriteMode(XorPut);
     SetLineStyle(UserBitLn,$AAAA,NormWidth);
     SetColor(7);
     with Area do Rectangle(A.X,A.Y,B.X,B.Y);
     SetWriteMode(CopyPut)
    end;

   procedure TView.DoMouseCursor;
    begin
     Application^.Mouse^.Cursor_Set(Style_Cursor)
    end;

   procedure TView.DoShow; assembler;
    asm
         MOV   SI, OFFSET Scr_Visual
         LES   DI, Self
         PUSH  DS
         PUSH  SI
         PUSH  ES
         PUSH  DI
         PUSH  DS
         PUSH  SI
         PUSH  ES
         PUSH  DI
         CALL  TView.Area_Full
         CALL  TView.Draw_Rect
     end;

{Методы для Обработки (Do) событий) }

   procedure TView.Do_DataFind(var E: TEvent);
    begin
     if Data_Ptr = E.InfoPtr then Event_Clr(E);
    end;

   procedure TView.Do_DataShow(var E: TEvent);
    begin
     if Data_Ptr = E.InfoPtr then Data_Proc(Data_Ptr^,True);
    end;

   procedure TView.Do_DataRead(var E: TEvent);
    begin
     if Data_Ptr = E.InfoPtr then Data_Proc(Data_Ptr^,False);
    end;

   procedure TView.Do_MouseDown;
     var Mask: word;
    begin
     Mask:=Event_Mask;
     if not (sf_Focus in State) and (Options and of_NoSelect = 0)
     and Focus and (Mask and ev_MouseMove = 0)
     then E.What:=ev_MouseMove;
    end;

{Методы обновления Изображения (Draw)}

   procedure TView.Draw; assembler;
    asm
         MOV   SI, OFFSET Scr_Visual
         LES   DI, Self
         PUSH  DS
         PUSH  SI
         PUSH  ES
         PUSH  DI
         PUSH  DS
         PUSH  SI
         PUSH  ES
         PUSH  DI
         CALL  TView.Area_Free
         CALL  TView.Draw_Rect
     end;

   procedure TView.Draw_Rect(const Area: TRect);
    function DoDrawHood(View: PView): boolean; far; assembler;
     asm
         LES   DI, View;
         PUSH  ES
         PUSH  DI
         CALL  TView.DoDraw
         XOR   AX, AX
     end;
    begin
     if ((State * sf_Visual) <> sf_Visual) or Upper_Clip(Area) then Exit;
     if Scr_Count > 0 then begin
      if Scr_Flag then Scr_Invalid.Union(Scr_Actual) else begin
       Scr_Invalid.Copy(Scr_Actual);
       Scr_Flag:=True
      end;
      Exit
     end;
     Area_Max(Scr_Visual);
     Scr_SetPort(Scr_Actual,Scr_Visual);
     if Scr_Actual.Empty then Exit;
     with Application^.Mouse^ do begin
      Cursor_Hide;
      Canvas_Paint;
      if sf_Focus in State then DoMark;
      Upper_Case(@DoDrawHood);
      Cursor_Show
     end
    end;

{Методы для управления Событиями (Event)}

   procedure TView.Event_Clr(var E: TEvent);
    begin
     E.What:=ev_Nothing;
     E.InfoPtr:=@Self
    end;

   procedure TView.Event_Diler(var E: TEvent);
    procedure DoBottomUp;
     begin
      if Parent <> nil then
      with Parent^ do if (Event_Mask and E.What <> 0)
      and not (sf_Disabled in State) then Event_Diler(E)
     end;
    begin
     if (E.What and ev_Mouse <> 0) and (Application^.Indicator = @Self) then DoMouseCursor;
     if E.What and $FF = 0 then Event_Perform(@Self,E, E.What+E.Command)
     else Event_Perform(@Self,E, E.What);
     if E.What and ev_BottomUp <> 0 then DoBottomUp;
    end;

   procedure TView.Event_Err(var E: TEvent);
    begin
     Parent_Get^.Event_Err(E);
    end;

   procedure TView.Event_Get(ev_XXXX: word; var E: TEvent);
    begin
     Parent_Get^.Event_Get(ev_XXXX,E)
    end;

   function TView.Event_Mask;
    begin
     Event_Mask:=0;
    end;

   procedure TView.Event_Put(const E: TEvent);
    begin
     Parent_Get^.Event_Put(E)
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TView.HelpCtx_Get: word;
    begin
     HelpCtx_Get:=hc_None
    end;

{Методы измененния Уровня (Level) Окна}

   procedure TView.Level_Top;
    var
     V: PView;
     R,S: TRect;
    begin
     if (Parent = nil) or (Parent^.Child_Last = @Self) then Exit;
     with Parent^ do if Self.State * sf_Visual = [] then begin
      DoDelete(@Self);
      DoInsert(Child_Last,@Self)
     end else begin
      S.Open(0,0,-1,-1);
      V:=Self.Sibling_Upper;
      while V <> nil do with V^ do begin
       Area_Full(R);
       R.Move(Origin.X,Origin.Y);
       if S.Empty then S:=R else S.Union(R);
       V:=Sibling_Upper;
      end;
      DoDelete(@Self);
      DoInsert(Child_Last,@Self);
      with Self do begin
       Area_Full(R);
       R.Move(Origin.X,Origin.Y);
      end;
      S.Intersect(R);
      Draw_Rect(S);
     end
    end;

   procedure TView.Level_Over;
     var Area: TRect;
    begin
     if (View = nil) or (View^.Sibling_Next = @Self) then Exit;
     Area_Full(Area);
     with Origin do Area.Move(X,Y);
     with Parent^ do begin
      DoDelete(@Self);
      DoInsert(View,@Self);
      Draw_Rect(Area)
     end
    end;

{Методы для установки (On) Состояний}

   procedure TView.On_Disabled(On: boolean);
    begin
     if On and (sf_Selected in State) then Parent^.Child_Select(True);
     if Options and of_AutoHide <> of_None then State_Set(sf_Visible,not On);
    end;

   procedure TView.On_Focus;
     var Area: TRect;
    begin
     Area_Mark(Area);
     Canvas_Init(Area);
     DoMark;
     Canvas_Done
    end;

   procedure TView.On_Modal(On: boolean);
    begin
     if On then Modal_View:=@Self else Modal_View:=nil
    end;

   procedure TView.On_Visible(On: boolean);
    begin
     if (sf_Exposed in State) then if On then DoShow else DoHide;
     if On then Event_Send(Parent,ev_Notify,cm_ChildShow,@Self)
     else Event_Send(Parent,ev_Notify,cm_ChildHide,@Self)
    end;

   procedure TView.On_Selected(On: boolean);
    begin
     if On then begin
      Parent^.Child_Curr^.State_Set(sf_Selected,False);
      Parent^.Child_Curr:=@Self;
      if Options and of_PopUp <> of_None then Level_Top;
      Event_Send(Parent,ev_Notify,cm_ChildSelect,@Self)
     end else Parent^.Child_Curr:=nil;
    end;

{Методы работы с Родительским (Parent) окном}

   function TView.Parent_Case(Method: pointer): PGroup; assembler;
    asm
         LES     DI,Self
     @@1:LES     DI,ES:[DI].TView.Parent
         MOV     AX,ES
         OR      AX,DI
         JE      @@2
         PUSH    ES
         PUSH    DI
         PUSH    ES
         PUSH    DI
         PUSH    WORD PTR [BP]
         CALL    Method
         POP     DI
         POP     ES
         OR      AL,AL
         JNE     @@2
     @@2:MOV     AX,DI
         MOV     DX,ES
    end;

   function TView.Parent_Get: PView;
    begin
     if Parent = nil then RunError(204) else Parent_Get:=Parent
    end;

   function TView.Parent_Is(View: PView): boolean; assembler;
    asm
         XOR  AL, AL
         LES  DI, Self
    @@1: CMP  DI, View.WORD[0]
         JNE  @@2
         MOV  SI, ES
         CMP  SI, View.WORD[2]
         JE   @@3
    @@2: MOV  SI, ES
         OR   SI, DI
         JE   @@4
         LES  DI, ES:[DI].TView.Parent
         JMP  @@1
     @@3:MOV  AL, 1
     @@4:
    end;

   procedure TView.Parent_For(Method: pointer); assembler;
    asm
         LES     DI,Self
     @@1:LES     DI,ES:[DI].TView.Parent
         MOV     AX,ES
         OR      AX,DI
         JE      @@2
         PUSH    ES
         PUSH    DI
         PUSH    ES
         PUSH    DI
         PUSH    WORD PTR [BP]
         CALL    Method
         POP     DI
         POP     ES
         JMP     @@1
     @@2:
    end;

   procedure TView.Parent_Set(Owner :PGroup);
    begin
     if Parent = Owner then Exit;
     if Parent <> nil then Parent^.Child_Del(@Self);
     if Owner <> nil then Owner^.Child_Ins(@Self)
    end;

{Методы Преобразования координат Точки (Point)}

   procedure TView.Point_Global(Point: TPoint; var Result: TPoint); assembler;
    asm
         LES     DI,Self
         XOR     AX,AX
         MOV     DX,AX
     @@1:ADD     AX,ES:[DI].TView.Origin.X
         ADD     DX,ES:[DI].TView.Origin.Y
         LES     DI,ES:[DI].TView.Parent
         MOV     SI,ES
         OR      SI,DI
         JNE     @@1
         ADD     AX,Point.X
         ADD     DX,Point.Y
         LES     DI,Result
         CLD
         STOSW
         XCHG    AX,DX
         STOSW
    end;

   function TView.Point_In(Point: TPoint): boolean;
    begin
     with Point do Point_In:=(0<=X) and (X<=Size.X) and (0<=Y) and (Y<=Size.Y)
    end;

   procedure TView.Point_Local(Point: TPoint; var Result: TPoint); assembler;
    asm
         LES     DI,Self
         XOR     AX,AX
         MOV     DX,AX
     @@1:ADD     AX,ES:[DI].TView.Origin.X
         ADD     DX,ES:[DI].TView.Origin.Y
         LES     DI,ES:[DI].TView.Parent
         MOV     SI,ES
         OR      SI,DI
         JNE     @@1
         NEG     AX
         NEG     DX
         ADD     AX,Point.X
         ADD     DX,Point.Y
         LES     DI,Result
         CLD
         STOSW
         XCHG    AX,DX
         STOSW
    end;

{Методы работы с окнами Сестрами (Sibling)}

   function TView.Sibling_Prev: PView; assembler;
    asm
         LES     DI,Self
         MOV     CX,DI
         MOV     BX,ES
     @@1:MOV     AX,DI
         MOV     DX,ES
         LES     DI,ES:[DI].TView.Sibling_Next
         CMP     DI,CX
         JNE     @@1
         MOV     SI,ES
         CMP     SI,BX
         JNE     @@1
    end;

   function TView.Sibling_Under: PView;
    begin
     if (Parent = nil) or (@Self = Parent^.Child_First)
     then Sibling_Under:=nil else Sibling_Under:=Sibling_Prev
    end;

   function TView.Sibling_Upper: PView;
    begin
     if (Parent = nil) or (@Self = Parent^.Child_Last)
     then Sibling_Upper:=nil else Sibling_Upper:=Sibling_Next
    end;


{Методы управления Флагами Состояня (State) }

   function TView.State_Get(AState: TState): boolean;
    begin
     State_Get:=State * AState = AState
    end;

   function TView.State_Set(sf_XXXX: byte; On: boolean): boolean;
    begin
     State_Set:=False;
     if (@Self = nil) or ((sf_XXXX in State) = On) then Exit;
     if On then Include(State,sf_XXXX) else Exclude(State,sf_XXXX);
     State_Perform(@Self,UView.State+sf_XXXX,On);
     if (sf_XXXX in [sf_Active,sf_Selected,sf_Modal]) and
     State_Set(sf_Focus,State_Get([sf_Active,sf_Selected]) or (sf_Modal in State)) then ;
     State_Set:=True
    end;

{Методы определения Стиля (Style) окна}

   function TView.Style_Cursor: PMouseCursor;
    begin
     Style_Cursor:=Parent_Get^.Style_Cursor
    end;

   function TView.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_View
    end;

{Личные методы объекта TView}

   function TView.Upper_Clip(const Area: TRect): boolean;
    function DoClip(View: PView): boolean; far;
     begin
      with View^ do if Options and of_Glass = 0 then begin
       Area_Get(Scr_Visual);
       with Scr_Origin do Scr_Visual.Move(X,Y);
       DoClip:=Scr_Actual.Clip(Scr_Visual)
      end else DoClip:=False
     end;
    begin
     Scr_Actual:=Area;
     Scr_Actual.Move(Origin.X,Origin.Y);
     longint(Scr_Origin):=0;
     if Parent <> nil then with Parent^ do begin
      Area_Clip(Scr_Actual);
      if Scr_Actual.Empty then Exit;
      Point_Global(Scr_Origin,Scr_Origin)
     end;
     Upper_Clip:=Upper_Case(@DoClip) <> nil
    end;

   function TView.Upper_UnClip(var Area: TRect): boolean;
    function DoClip(View: PView): boolean; far;
     begin
      with View^ do if Options and of_Glass = 0 then begin
       Area_Get(Scr_Visual);
       with Scr_Origin do Scr_Visual.Move(X,Y);
       Area:=Scr_Actual;
       Scr_Actual.Intersect(Scr_Visual);
       Scr_Actual.Union(Area);
       DoClip:=Scr_Actual.Clip(Scr_Visual)
      end else DoClip:=False
     end;
    begin
     Scr_Actual:=Area;
     Scr_Actual.Move(Origin.X,Origin.Y);
     longint(Scr_Origin):=0;
     if Parent <> nil then with Parent^ do begin
      Area_Clip(Scr_Actual);
      if Scr_Actual.Empty then Exit;
      Point_Global(Scr_Origin,Scr_Origin)
     end;
     Upper_UnClip:=Upper_Case(@DoClip) <> nil
    end;

   function TView.Upper_Case(Method: pointer): PView; assembler;
     var View: PView;
    asm
         PUSH Scr_Origin.X
         PUSH Scr_Origin.Y
         LES  DI, Self
    @@1: MOV  CX, ES
         MOV  DX, DI
         LES  DI, ES:[DI].TView.Parent
         MOV  SI, ES
         OR   SI, DI
         JE   @@4
         LES  DI, ES:[DI].TGroup.Child_Last
         LES  DI, ES:[DI].TView.Sibling_Next
         MOV  View.WORD[0], DI
         MOV  View.WORD[2], ES
         MOV  DI, DX
         MOV  ES, CX
    @@2: LES  DI, ES:[DI].TView.Sibling_Next
         CMP  DI, View.WORD[0]
         JNE  @@3
         MOV  SI, ES
         CMP  SI, View.WORD[2]
         JNE  @@3
         LES  DI, ES:[DI].TView.Parent
         MOV  AX, ES:[DI].TView.Origin.X
         MOV  BX, ES:[DI].TView.Origin.Y
         SUB  Scr_Origin.X, AX
         SUB  Scr_Origin.Y, BX
         JMP  @@1
    @@3: MOV  AX, ES:[DI].TView.State
         AND  AX, sm_Visible+sm_Exposed
         CMP  AX, sm_Visible+sm_Exposed
         JNE  @@2
         PUSH ES
         PUSH DI
         PUSH ES
         PUSH DI
         PUSH WORD PTR [BP]
         CALL Method
         POP  DI
         POP  ES
         OR   AL, AL
         JE   @@2
    @@4: MOV  DX, ES
         MOV  AX, DI
         POP  Scr_Origin.Y
         POP  Scr_Origin.X
    end;

{Методы Управления Окном (Wnd) }


   function TView.Focus: boolean;
    begin
     if @Self = nil then Focus:=False
     else if (Parent = nil) or (sf_Focus in State)
     then Focus:=True else Focus:=Select and Parent^.Focus
    end;

   function TView.Group: boolean;
    begin
     Group:=False
    end;

   procedure TView.Hide;
    begin
     State_Set(sf_Visible,False);
    end;

   function TView.Ptr: PView;
    begin
     Ptr:=@Self
    end;

   function TView.Select: boolean;
    begin
     Select:=False;
     if @Self = nil then Exit;
     if (Parent = nil) or (Options and of_NoSelect <> of_None)
     or (sf_Disabled in State) then Exit;
     State_Set(sf_Selected,True);
     Select:=True
    end;

   procedure TView.Show;
    begin
     State_Set(sf_Visible,True);
    end;



{Реализация объекта Фона (Background)}
{---------------------------------------------------------------------------}

   constructor TPanel.Init(const Area: TRect; APainter: TPainter);
    begin
     inherited Init(Area);
     Options:=Options or of_NoSelect;
     Style_Paint:=APainter
    end;

{Методы управления Холстом (Canvas)}

   procedure TPanel.Canvas_Paint;
    begin
     Style_Paint(@Self)
    end;

{Методы определения Стиля (Style) окна}

   function TPanel.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Panel
    end;


{Реализация объекта Протяжки (Drager)}
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TDrager.Init;
     var Area :TRect;
    begin
     AView^.Area_Get(Area);
     inherited Init(Area);
     Application^.Mouse^.Cursor_Pos(MousePos);
     State:=State - [sf_Visible];
     AView^.Area_Limit(View_Size);
     View_Desk:=Desk;
     Step:=8;
     Step_Max:=Metric_Unit.X;
     Step_Min:=1;
     Mode:=dm_XXXX;
     Options:=Options or of_Glass or of_NoSelect;
     View_Zoom:=Area;
     View:=AView;
    end;

{Методы работы с Областью (Area) отображения}

   procedure TDrager.Area_Set(const Area: TRect);
     var Ex: TRect;
    begin
     Area_Get(Ex);
     if Area.Equals(Ex) then Exit;
     if State * sf_Visual <> sf_Visual then Area_Proc(Area) else begin
      Hide;
      if Mode and dm_DragView <> 0 then View^.Area_Set(Area);
      Area_Proc(Area);
      Show;
     end
    end;

{Методы управления Холстом (Canvas)}

   procedure TDrager.Canvas_Free;
    var
     P :TPoint;
    begin
     P:=Scr_Origin;
     DoDraw;
     Scr_Origin:=P
    end;

   procedure TDrager.Canvas_Paint;
    begin
     SetWriteMode(XorPut);
     SetColor(Style_Palette^.Color[1]);
     SetLineStyle(SolidLn,0,NormWidth);
     Rectangle(0,0,Size.X,Size.Y);
     SetWriteMode(CopyPut)
    end;

{Методы для Оработки (Do) событий) }

   procedure TDrager.Do_KeyDown;

    procedure Change(DX, DY: integer);
      var P: TPoint;
     begin
      if (E.AbsKey.Flag and kb_Shift <> 0) and (Mode and dm_DragGrow <> 0)
      then begin
       P.X:=DX+Size.X;
       P.Y:=DY+Size.Y;
       DoGrow(Origin,P)
      end else begin
       P.X:=DX+Origin.X;
       P.Y:=DY+Origin.Y;
       DoGrow(P,Size)
      end
     end;

    procedure Update(X, Y: integer);
      var P: TPoint;
     begin
      if Mode and dm_DragMove <> 0 then begin
       P.X:=X;
       P.Y:=Y;
       DoGrow(P,Size)
      end
     end;

    begin
     case E.AbsKey.Code and not kb_Shift of
      kb_GrayPlus: if Step < Step_Max then Inc(Step);
      kb_GrayMinus: if Step > Step_Min then Dec(Step);
      kb_Left: Change(-Step,0);
      kb_Right: Change(Step,0);
      kb_Up: Change(0,-Step);
      kb_Down: Change(0,Step);
      kb_Home: Update(View_Desk.A.X, Origin.Y);
      kb_End: Update(View_Desk.B.X-Size.X, Origin.Y);
      kb_PgUp: Update(Origin.X,View_Desk.A.Y);
      kb_PgDn: Update(Origin.X,View_Desk.B.Y-Size.Y);
      kb_Enter: Dlg_Stop(cm_Idle);
      kb_Esc: begin
      Area_Set(View_Zoom);
       Dlg_Stop(cm_Idle)
      end
      end;
      Event_Clr(E)
     end;

   procedure TDrager.Do_MouseMove;
    begin
     if Mode and dm_DragMove <> 0 then
     if (Mode and dm_DragEsc <> 0)
     and not Application^.Indicator^.Parent_Is(Parent) then Area_Set(View_Zoom)
     else begin
      Inc(longint(E.Where),longint(View_Zoom.A)-longint(MousePos));
      DoGrow(E.Where,Size)
     end else with View_Zoom do begin
      Inc(longint(E.Where),longint(B)-longint(A)-longint(MousePos));
      DoGrow(Origin,E.Where)
     end;
    end;

   procedure TDrager.Do_MouseUp;
    begin
     Event_Clr(E);
     Dlg_Stop(cm_Idle)
    end;

{Личные (Private) методы объекта}

   procedure TDrager.DoHide;
     var Save: TState;
    begin
     Save:=State;
     State:=State + sf_Visual;
     Draw;
     State:=Save
    end;

   procedure TDrager.DoGrow(P, S: TPoint);
     var Area: TRect;
    function Min(I, J: integer): integer;
     begin
      if I < J then Min:=I else Min:=J
     end;
    function Max(I, J: integer): integer;
     begin
      if I > J then Max:=I else Max:=J
     end;
    begin
     S.X:=Min(Max(S.X, View_Size.A.X), View_Size.B.X);
     S.Y:=Min(Max(S.Y, View_Size.A.Y), View_Size.B.Y);
     P.X:=Min(Max(P.X, View_Desk.A.X-S.X + 1), View_Desk.B.X-1);
     P.Y:=Min(Max(P.Y, View_Desk.A.Y-S.Y + 1), View_Desk.B.Y-1);
     if Mode and dm_LimitLoX <> 0 then P.X:=Max(P.X, View_Desk.A.X);
     if Mode and dm_LimitLoY <> 0 then P.Y:=Max(P.Y, View_Desk.A.Y);
     if Mode and dm_LimitHiX <> 0 then P.X:=Min(P.X, View_Desk.B.X-S.X);
     if Mode and dm_LimitHiY <> 0 then P.Y:=Min(P.Y, View_Desk.B.Y-S.Y);
     Area.Assign(P.X,P.Y,P.X+S.X,P.Y+S.Y);
     Area_Set(Area)
    end;

{Методы для управления Событиями (Event)}

   function TDrager.Event_Mask: word;
    begin
     if Mode and dm_DragMouse <> 0 then Event_Mask:=ev_Mouse
     else Event_Mask:=ev_KeyBoard
    end;

{Методы Установки (On) состояния}

   procedure TDrager.On_Present(On: boolean);
     var Area: TRect;
    begin
     State_Set(sf_Visible,On);
     if On then Exit;
     if Mode and dm_DragView = 0 then begin
      Area_Get(Area);
      View^.Area_Set(Area)
     end
    end;

{Методы определения Стиля (Style) окна}

   function TDrager.Style_Cursor;
    begin
     if Mode and dm_DragMove <> 0 then Style_Cursor:=@Cursor_Size
     else Style_Cursor:=@Cursor_SizeNS
    end;

   function TDrager.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Drager
    end;


{Реализация объекта Группы (Group)}
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   destructor TGroup.Done;
    begin
     inherited Done;
     while Child_Last <> nil do Child_Last^.Free
    end;

{Методы работы с Областью (Area) отображения}

   procedure TGroup.Area_Limit(var Limit: TRect);
    procedure DoLimit(View: PView); far;
     var
      D: integer;
      SubLimit: TRect;
      Max,Min: TPoint;
     begin
      with View^ do if GrowMode and (gm_GrowHiY+gm_GrowHiX) <> 0 then begin
       Area_Limit(SubLimit);
       if GrowMode and gm_GrowHiX <> 0 then begin
        D:=Self.Size.X-Origin.X-Size.X;
        Max.X:=Origin.X+SubLimit.B.X+D;
        Min.X:=Origin.X+SubLimit.A.X+D;
        if Limit.B.X > Max.X then Limit.B.X:=Max.X;
        if Limit.A.X < Min.X then Limit.A.X:=Min.X
       end;
       if GrowMode and gm_GrowHiY <> 0 then begin
        D:=Self.Size.Y-Origin.Y-Size.Y;
        Max.Y:=Origin.Y+SubLimit.B.Y+D;
        Min.Y:=Origin.Y+SubLimit.A.Y+D;
        if Limit.B.Y > Max.Y then Limit.B.Y:=Max.Y;
        if Limit.A.Y < Min.Y then Limit.A.Y:=Min.Y
       end
      end
     end;
    begin
     inherited Area_Limit(Limit);
     Child_For(@DoLimit)
    end;

   procedure TGroup.Area_Proc(const Area: TRect);
     var Delta: TPoint;
    procedure DoAreaCalc(View: PView); far;
     begin
      View^.Area_Calc(Delta);
     end;
    begin
     Delta.X:=Area.B.X-Area.A.X-Size.X;
     Delta.Y:=Area.B.Y-Area.A.Y-Size.Y;
     inherited Area_Proc(Area);
     if longint(Delta) <> 0 then Child_For(@DoAreaCalc);
     State_Set(sf_Disabled, not ((Size.X > 0) and (Size.Y > 0)))
    end;

{Методы управления Холстом (Canvas)}

   procedure TGroup.Canvas_Paint;
    var
     SaveOrigin: TPoint;
     SaveActual,Area: TRect;
    procedure DoPaint(View: PView); far; assembler;
     asm
         LES   DI, View
         MOV   AX, ES:[DI].TView.State
         MOV   BX, sm_Visible+sm_Exposed
         AND   AX, BX
         CMP   AX, BX
         JNE   @@1
         PUSH  ES
         PUSH  DI
         CALL  TView.DoDraw
      @@1:
     end;
    begin
     Canvas_Frame;
     SaveOrigin:=Scr_Origin;
     SaveActual:=Scr_Actual;
     Area_Min(Area);
     Scr_Origin:=Scr_Visual.A;
     Scr_Actual.Intersect(Area);
     Child_For(@DoPaint);
     Scr_Origin:=SaveOrigin;
     Scr_Actual:=SaveActual
    end;

{Методы работы с дочерными (Child) окнами}

   function TGroup.Child_Case(Method: pointer): PView; assembler;
     var View: PView;
    asm
         LES     DI,Self
         LES     DI,ES:[DI].TGroup.Child_Last
         MOV     AX,ES
         OR      AX,DI
         JE      @@2
         MOV     WORD PTR View[2],ES
         MOV     WORD PTR View[0],DI
     @@1:LES     DI,ES:[DI].TView.Sibling_Next
         PUSH    ES
         PUSH    DI
         PUSH    ES
         PUSH    DI
         PUSH    WORD PTR [BP]
         CALL    Method
         POP     DI
         POP     ES
         OR      AL,AL
         JNE     @@2
         CMP     DI,WORD PTR View[0]
         JNE     @@1
         MOV     AX,ES
         CMP     AX,WORD PTR View[2]
         JNE     @@1
         XOR     DI,DI
         MOV     ES,DI
     @@2:MOV     AX,DI
         MOV     DX,ES
    end;

   function TGroup.Child_Del(View: PView): PView;
     var Flag: boolean;
    begin
     Child_Del:=View;
     if View <> nil then with View^ do begin
      State_Set(sf_Present,False);
      if State_Set(sf_Visible,False) then State:=State + [sf_Visible];
      State_Set(sf_Exposed,False);
      State_Set(sf_Active,False);
      Flag:=State_Set(sf_Selected,False);
      DoDelete(View);
      if Flag then Child_Select(False);
      State_Set(sf_Modal,False);
     end
    end;

   function TGroup.Child_Exec(View: PView): word;
    var
     Curr :PView;
     Owner :PGroup;
    begin
     Child_Exec:=cm_Idle;
     if View <> nil then begin
      Owner:=View^.Parent;
      Curr:=Child_Curr;
      if Owner = nil then if Child_Ins(View) = nil then Exit;
      Child_Exec:=View^.Dlg_Exec;
      if Owner = nil then Dispose(View,Done);
      Curr^.State_Set(sf_Selected,True);
     end
    end;

   function TGroup.Child_Find(Point: TPoint): PView;
     var
      Result: PView;
      Area: TRect;
     procedure DoTest(View: PView); far;
      begin
       if View^.State * sf_Visual <> sf_Visual then Exit;
       View^.Area_Get(Area);
       if Area.Contains(Point) then Result:=View
      end;
    begin
     Result:=@Self;
     Child_For(@DoTest);
     if Result <> @Self then with Result^ do begin
      Dec(Point.X,Origin.X);
      Dec(Point.Y,Origin.Y);
      Result:=Child_Find(Point)
     end;
     Child_Find:=Result
    end;

   function TGroup.Child_First: PView;
    begin
     if Child_Last = nil then Child_First:=nil else Child_First:=Child_Last^.Sibling_Next
    end;

   procedure TGroup.Child_For(Method: pointer); assembler;
     var View: Pointer;
    asm
         LES     DI, Self
         LES     DI, ES:[DI].TGroup.Child_Last
         MOV     AX, ES
         OR      AX, DI
         JE      @@4
         LES     DI,ES:[DI].TView.Sibling_Next
         MOV     WORD PTR View[2],ES
         MOV     WORD PTR View[0],DI
     @@2:PUSH    WORD PTR ES:[DI].TView.Sibling_Next[2]
         PUSH    WORD PTR ES:[DI].TView.Sibling_Next[0]
         PUSH    ES
         PUSH    DI
         PUSH    WORD PTR [BP]
         CALL    Method
         POP     DI
         POP     ES
     @@1:CMP     DI, WORD PTR View[0]
         JNE     @@2
         MOV     AX,ES
         CMP     AX, WORD PTR View[2]
         JNE     @@2
     @@4:
    end;

   function TGroup.Child_Ind(View: PView): word; assembler;
    asm
         XOR     AX, AX
         LES     DI, Self
         LES     DI, ES:[DI].TGroup.Child_Last
         MOV     CX, ES
         MOV     BX, DI
         OR      CX, DI
         JE      @@3
     @@1:LES     DI, ES:[DI].TView.Sibling_Next
         INC     AX
         MOV     DX, ES
         CMP     DX, WORD PTR View[2]
         JNE     @@2
         CMP     DI, WORD PTR View[0]
         JE      @@3
     @@2:CMP     DX, CX
         JNE     @@1
         CMP     DI, BX
         JNE     @@1
         XOR     AX, AX
     @@3:
    end;

   function TGroup.Child_Ins(View: PView): PView;
    begin
     if (sf_Present in State) and LowMemory then begin
      Child_Ins:=nil;
      with Size do while View <> nil do with View^ do begin
       View:=Sibling_Next;
       Free
      end;
      Application^.Msg_OutMem;
     end else begin
      Child_Ins:=View;
      with Size do while View <> nil do with View^ do begin
       if Parent <> nil then Parent^.Child_Del(View);
       View:=Sibling_Next;
       Sibling_Next:=nil;
       DoInsert(Child_Last,Ptr);
       if GrowMode and gm_CenterX <> 0 then Origin.X:=(X-Size.X) div 2;
       if GrowMode and gm_CenterY <> 0 then Origin.Y:=(Y-Size.Y) div 2;
       State_Set(sf_Present, sf_Present in Self.State);
       State_Set(sf_Active, sf_Focus in Self.State);
       State_Set(sf_Selected, Options and of_NoSelect = of_None);
       State_Set(sf_Exposed, Self.State * sf_Visual = sf_Visual);
       if sf_Visible in State then On_Visible(True)
      end
     end
    end;

   function TGroup.Child_Is(View: PView): boolean;
    function DoChild_Is(P: PView): boolean; far;
     begin
      DoChild_Is:=P^.Child_Is(View);
     end;
    begin
     Child_Is:=(View = @Self) or (Child_Case(@DoChild_Is) <> nil)
    end;

   function TGroup.Child_Ptr(Ind: word): PView; assembler;
    asm
         XOR     AX, Ind
         LES     DI, Self
         LES     DI, ES:[DI].TGroup.Child_Last
         MOV     CX, ES
         MOV     BX, DI
         OR      CX, DI
         JE      @@3
     @@1:LES     DI, ES:[DI].TView.Sibling_Next
         DEC     AX
         JZ      @@3
         MOV     DX, ES
     @@2:CMP     DX, CX
         JNE     @@1
         CMP     DI, BX
         JNE     @@1
         XOR     AX, AX
         XOR     DX, DX
     @@3:
    end;

   function TGroup.Child_Select(Forw: Boolean): boolean;
    var
     View: PView;
     Curr: PView;
    begin
     Curr:= Child_Curr;
     if Child_Last = nil then Exit;
     if Child_Curr <> nil then View:=Child_Curr else
     if Forw then View:=Child_Last else View:=Child_First;
     with View^ do repeat
      if Forw then View:=View^.Sibling_Next else View:=View^.Sibling_Prev
     until (Ptr = View) or View^.Select;
     Child_Select:=Child_Curr <> Curr
    end;

  procedure TGroup.Child_State(AState: word; On: boolean);
   procedure DoItem(View: PView); far;
    begin
     View^.State_Set(AState,On)
    end;
   begin
    Child_For(@DoItem)
   end;

{Методы Проверки (Valid) Команд (Comm)}

   procedure TGroup.Comm_Audit(cm_XXXX: word;On: boolean);
    procedure  DoAudit(View: PView); far;
     begin
      View^.Comm_Audit(cm_XXXX,On)
     end;
    begin
     Child_For(@DoAudit)
    end;

{Методы для обмена Данных (Data) }

   function TGroup.Data_Proc;
    var
     Bytes :array[0..$EFFF] of byte absolute Data;
     I:word;
    procedure DoSwap(View: PView); far;
     begin
      Inc(I,View^.Data_Proc(Bytes[I],ds_XXXX));
     end;
    begin
     I:=0;
     Child_For(@DoSwap);
     Data_Proc:=I
    end;

{Личные (Private) методы объекта}

   procedure TGroup.DoDelete(View: PView);
    begin
     with View^ do begin
      if Child_Last = View then Child_Last:=Sibling_Under;
      Sibling_Prev^.Sibling_Next:=Sibling_Next;
      Sibling_Next:=nil;
      Parent:=nil
     end
    end;

   procedure TGroup.DoInsert(Prev,View: PView);
    begin
     if Child_Last = Prev then Child_Last:=View;
     if Prev = nil then Prev:=Child_Last;
     with View^ do begin
      Sibling_Next:=Prev^.Sibling_Next;
      Prev^.Sibling_Next:=Ptr;
      Parent:=@Self
     end
    end;

{Методы для управления Событиями (Event)}

   procedure TGroup.Event_Diler(var E: TEvent);

    function DoCurr: boolean;
     begin
      if nil <> Child_Curr then with Child_Curr^ do
      if not (sf_Disabled in State) and (E.What and Event_Mask <> 0)
      then Event_Diler(E);
      DoCurr:=E.What = ev_Nothing
     end;

    function DoChild(Child: PView): boolean; far;
     begin
      if Child <> Child_Curr then with Child^ do
      if not (sf_Disabled in State) and (E.What and Event_Mask <> 0)
      then Event_Diler(E);
      DoChild:=E.What = ev_Nothing
     end;

    function DoPosition(View: PView): boolean; far;
      var Res: boolean;
     begin
      with Application^ do begin
       Res:=Indicator^.Parent_Is(View);
       if Res then with View^ do
       if (Event_Mask and E.What <> 0) and (not (sf_Disabled in State))
       then Event_Diler(E) else Self.DoMouseCursor
      end;
      DoPosition:=Res
     end;
    begin
     inherited Event_Diler(E);
     if (E.What and ev_Position <> 0) then
     if Child_Case(@DoPosition) <> nil then Exit else DoMouseCursor else
     if (E.What and ev_TopDown <> 0) and not DoCurr then Child_Case(@DoChild);
    end;

   function TGroup.Event_Mask: word;
    begin
     Event_Mask:=ev_AnyEvent
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TGroup.HelpCtx_Get: word;
    begin
     if Modal_View^.Parent = @Self then HelpCtx_Get:=Modal_View^.HelpCtx_Get
     else if Child_Curr <> nil then HelpCtx_Get:=Child_Curr^.HelpCtx_Get
     else HelpCtx_Get:=inherited HelpCtx_Get
    end;

{Методы Установки (On) состояния}

  procedure TGroup.On_Exposed(On: boolean);
   begin
    if sf_Visible in State then Child_State(sf_Exposed,On);
   end;

  procedure TGroup.On_Focus;
   begin
    Child_State(sf_Active,On)
   end;

  procedure TGroup.On_Present(On: boolean);
   begin
    Child_State(sf_Present,On);
   end;

  procedure TGroup.On_Visible(On: boolean);
   begin
    if sf_Exposed in State then Child_State(sf_Exposed,On);
    inherited On_Visible(On)
   end;

{Методы управления Окном (Wnd)}

   function TGroup.Group: boolean;
    begin
     Group:=True
    end;


{Реализация объекта Программы (Program) }
{-----------------------------------------------------------------------}

  const

   TProgram_Self: PProgram = nil;

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TProgram.Init;
     var Area: TRect;
    begin
     Init_Video;
     Init_Palette;
     Metric_Init;
     longint(Area.A):=0;
     Area.B:=Metric_Scr;
     inherited Init(Area);
     State:=[sf_Exposed];
     TProgram_Self:=@Self;
     Panel:=New_Panel;
     Child_Ins(Panel);
     Commander:=New_Commander;
     Mouse:=New_Mouse(Area);
     KeyBoard:=New_KeyBoard;
    end;

   destructor TProgram.Done;
    begin
     inherited Done;
     Commander^.Free;
     KeyBoard^.Free;
     Mouse^.Free;
     Done_Palette;
     Done_Video;
     TProgram_Self:=nil;
    end;

{Методы Подключения драйверов}

   procedure TProgram.Init_Palette;
    begin
     SetRGBPalette(5,49,49,50);
     SetRGBPalette(7,32,32,34);
     SetRGBPalette(2,0,20,4);
    end;

   procedure TProgram.Init_Video;
    var
     grDriver: integer;
     grMode: integer;
     ErrCode: integer;
    begin
     grDriver:=VESA16;
     grMode:=0;
     InitGraph(grDriver,grMode,' ');
     if GraphResult = grOk then Exit;
     grDriver:=Detect;
     InitGraph(grDriver,grMode,' ');
     ErrCode := GraphResult;
     if ErrCode <> grOk then Writeln( GraphErrorMsg(ErrCode));
    end;

{Методы Отключения драйверов}

   procedure TProgram.Done_Palette;
    begin
    end;

   procedure TProgram.Done_Video;
    begin
     CloseGraph
    end;

{Методы для Оработки (Do) событий) }

   procedure TProgram.Do_Quit;
    begin
     if not Comm_Valid(E.Command) then  Exit;
     Dlg_Stop(E.Command);
     Event_Clr(E)
    end;

{Дополнительные методы Прорисовки}

   procedure TProgram.DoHide;
    begin
     Mouse^.Cursor_Hide;
     ClearDevice;
     Mouse^.Cursor_Show;
    end;

   procedure TProgram.DoShow;
    begin
     Draw;
    end;

{Методы для управления Событиями (Event)}

   procedure TProgram.Event_Err(var E: TEvent);
    begin
     Event_Clr(E);
    end;

   procedure TProgram.Event_Get(ev_XXXX: word; var E: TEvent);
    begin
     repeat
      Event_Find(E);
      if E.What and ev_Position <> 0 then Indicator:=Child_Find(E.Where);
      if E.What and ev_Modal = 0 then Event_Diler(E) else
      if E.What and ev_XXXX <> 0 then Exit else Event_Err(E)
     until False
    end;

   procedure TProgram.Event_Put(const E: TEvent);
    begin
     Commander^.Event_Put(E)
    end;

{Методы вывода Сообщений (Message)}

   function TProgram.Msg_Box(const Title,Msg: string; mb_XXXX: word): word;
    begin
     Abstract;
    end;

   procedure TProgram.Msg_Err(Pos: TPoint; const Text,Color: string);
    begin
     Abstract;
    end;

   procedure TProgram.Msg_OutMem;
    begin
     Abstract;
    end;

   function TProgram.Msg_Text;
    begin
     Abstract;
    end;


{Методы создания (New) вспомагательных объектов}

   function TProgram.New_Panel;
     var Area: TRect;
    begin
     Area_Free(Area);
     New_Panel:=New(PPanel,Init(Area,Style_Fill));
    end;

   function TProgram.New_Commander;
    begin
     New_Commander:=New(PCommander,Init(16));
    end;

   function TProgram.New_Keyboard;
    begin
     New_KeyBoard:=New(PKeyBoard,Init);
    end;

   function TProgram.New_Mouse;
    begin
     New_Mouse:=New(PMouse,Init(Area))
    end;

{Методы Установки (On) состояния}

   procedure TProgram.On_Present;
     var E: TEvent;
    begin
     inherited On_Present(On);
     State_Set(sf_Visible,On);
    end;

   procedure TProgram.On_Modal(On: boolean);
    begin
     Scr_Lock;
     inherited On_Modal(On);
     State_Set(sf_Present,On);
     Scr_UnLock
    end;

{Методы определени Стиля (Style) окна}

   function TProgram.Style_Cursor: PMouseCursor;
    begin
     Style_Cursor:=@Cursor_Arrow
    end;


{--------------------------------------------------------------------------}

   function Application: PProgram;
    begin
     if TProgram_Self = nil then RunError(204)
     else Application:=TProgram_Self
    end;

   function Event_Send(Whom: PView; What, Comm: Word; Info: Pointer): Pointer;
     var Event: TEvent;
    begin
     Event_Send:=nil;
     if (Whom = nil) or (sf_Disabled in Whom^.State)
     or (Whom^.Event_Mask and What = 0) then Exit;
     Event.What:=What;
     Event.Command:=Comm;
     Event.InfoPtr:=Info;
     Whom^.Event_Diler(Event);
     if Event.What = ev_Nothing then Event_Send:=Event.InfoPtr
    end;

   function Dialog: PView;
    begin
     if Modal_View = nil then RunError(204) else Dialog:=Modal_View
    end;

   procedure Process(Clock: word);
    const
     Event_Clock: integer = 0;
    var
     E: TEvent;
    begin
     for Clock:=Clock downto 1 do with TProgram_self^ do begin
      Event_Find(E);
      if E.What and ev_Position <> 0 then Indicator:=Child_Find(E.Where);
      if E.What and ev_Modal = 0 then Event_Diler(E) else
      with Modal_View^ do if E.What and Event_Mask <> 0 then
      Event_Diler(E) else Event_Err(E)
     end
    end;

   function Data_Find(var Data): PView;
    begin
     Data_Find:=Event_Send(Application,ev_Command,cm_DataFind,@Data)
    end;

   procedure Data_Show(var Data);
    begin
     Event_Send(Application,ev_Command,cm_DataShow,@Data)
    end;

   procedure Data_Read(var Data);
    begin
     Event_Send(Application,ev_Command,cm_DataRead,@Data)
    end;

   function  MessageBox(const Title,Msg: string; Flag: word): word;
    begin
     MessageBox:=Application^.Msg_Box(Title,Msg,Flag);
    end;

   procedure MessageErr(Pos: TPoint;const Text,Color: string);
    begin
     Application^.Msg_Err(Pos,Text,Color);
    end;

   procedure Style_Body(View: PView; Palette: PPalette);
     var Area: TRect;
    begin
     with View^,Palette^, Area, A do begin
      Area_Free(Area);
      SetLineStyle(SolidLn,0,NormWidth);
      SetColor(Color[2]);
      Line(X,Y,B.X,Y);
      Line(X,Y,X,B.Y);
      SetColor(Color[1]);
      Line(B.X,Y,B.X,B.Y);
      Line(X,B.Y,B.X,B.Y);
      if Options and of_Glass <> 0 then Exit;
      SetFillStyle(SolidFill,Color[3]);
      Grow(-1,-1);
      Bar(X,Y,B.X,B.Y)
     end
    end;

   procedure Style_Frame(View: PView; Palette: PPalette);
     var Area: TRect;
    begin
     with View^,Palette^, Area, A do begin
      Area_Free(Area);
      SetLineStyle(SolidLn,0,NormWidth);
      SetColor(Color[2]);
      Line(X,Y,B.X,Y);
      Line(X,Y,X,B.Y);
      Line(X+1,B.Y-1,B.X-1,B.Y-1);
      Line(B.X-1,Y+1,B.X-1,B.Y-1);
      SetColor(Color[1]);
      Line(B.X,Y,B.X,B.Y);
      Line(X,B.Y,B.X,B.Y);
      Line(X+1,Y+1,X+1,B.Y-1);
      Line(X+1,Y+1,B.X-1,Y+1);
      if Options and of_Glass <> 0 then Exit;
      SetFillStyle(SolidFill,Color[3]);
      Grow(-2,-2);
      Bar(X,Y,B.X,B.Y)
     end
    end;

   procedure Style_Fill(View: PView);
     var Area: TRect;
    begin
     with View^ do  begin
      if Options and of_Glass = 0 then begin
       Area_Free(Area);
       SetFillStyle(SolidFill,Style_Palette^.Color[3]);
       with Area, A do Bar(X,Y,B.X,B.Y);
      end;
      View^.Canvas_Frame
     end
    end;

   procedure Style_Plato(View: PView);
    begin
     Style_Body(View,@Palette_Bavel)
    end;

   procedure Style_Valley(View: PView);
     var Palette: string[3];
    begin
     Palette:=Palette_Bavel;
     asm
      MOV  AX, WORD PTR Palette[1]
      XCHG AL, AH
      MOV  WORD PTR Palette[1], AX
     end;
     Style_Body(View,@Palette)
    end;

   procedure Style_Wall(View: PView);
    begin
     Style_Frame(View,@Palette_Bavel)
    end;

   procedure Style_Canyon(View: PView);
     var Palette: string[3];
    begin
     Palette:=Palette_Bavel;
     asm
      MOV  AX, WORD PTR Palette[1]
      XCHG AL, AH
      MOV  WORD PTR Palette[1], AX
     end;
     Style_Frame(View,@Palette)
    end;

   procedure DoInitMetrics; far;
     var X,Y: word;
    begin
     GetAspectRatio(X,Y);
     Metric_Scr.X:=GetMaxX;
     Metric_Scr.Y:=GetMaxY;
     SetTextStyle(SysFont_Style,HorizDir,SysFont_Size);
     Metric_Box.Y:=TextWidth('T') * 2;
     Metric_Box.X:=Round(X * Metric_Box.Y div Y);
     Metric_Unit.X:=Metric_Box.X div 4;
     Metric_Unit.Y:=Metric_Box.Y div 4;
     Metric_Shadow.Y:=Metric_Box.X div 8;
     Metric_Shadow.X:=Metric_Box.Y div 8;
    end;

  begin
   Metric_Init:=DoInitMetrics;
  end.
