 {      ┌───────────────────────────────────────────┐
        │                                           │
        │     W h i t e   A p p l i c a t o r       │
        │                                           │
        │              U V i e w    2.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1995        │
        │             (054) 33-35-94                │
        │                                           │
        │             (implementation)              │
        │                                           │
        └───────────────────────────────────────────┘      }

  {$I UVIEW.INC}

  implementation

   var

    Scr_Actual: TRect;
    Scr_Invalid: TRect;
    Scr_Visual: TRect;
    Scr_Origin: TPoint;

   const

    Scr_Count: word = 0;
    Scr_Flag: boolean = False;

    Dlg_View: PView = nil;
    Dlg_Result: word  = cm_NoComm;


{Реализация объекта Видиоконтекста (VideoCtx) }
{--------------------------------------------------------------------------}

  procedure SetScrPort(Scr :TRect; var Win :TRect);
   begin
    Scr.Intersect(Win);
    with Scr do begin
     SetViewPort(A.X, A.Y, B.X, B.Y, ClipOn);
     SetViewOrg(Win.A.X-A.X, Win.A.Y-A.Y)
    end
   end;

  procedure TView.Canvas_Init;
    var E: TEvent;
   function DoMes(View: PView): boolean; far;
    begin
     View^.Proc_Event(E);
     DoMes:=False
    end;
   begin
    if (State and sf_Visual <> sf_Visual) or Upper_Clip(Area)
    then Scr_Visual.Assign(1,1,-1,-1) else begin
     Space_Max(Scr_Visual);
     Area:=Scr_Visual;
     Application^.Mouse^.Cursor_Hide;
     SetScrPort(Scr_Actual,Scr_Visual);
     E.What:=ev_Notify;
     E.Command:=cm_CnvInit;
     E.InfoPtr:=@Self;
     Upper_Case(@DoMes);
     Scr_Visual:=Area;
    end;
    SetScrPort(Scr_Actual,Scr_Visual);
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

{Реализация объекта Вида (View) }
{--------------------------------------------------------------------------}

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TView.Init(const Area: TRect);
    begin
     inherited Init;
     TView.Proc_Area(Area);
     State:=sf_Visible;
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
      if GrowMode and gm_GrowLoX <> 0 then Move(Delta.X, 0);
      if GrowMode and gm_GrowHiX <> 0 then Inc(B.X, Delta.X);
      if GrowMode and gm_GrowLoY <> 0 then Move(0, Delta.Y);
      if GrowMode and gm_GrowHiY <> 0 then Inc(B.Y, Delta.Y)
     end;
     Proc_Area(Area)
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

   procedure TView.Area_Global(var Area: TRect); assembler;
    asm
         LES     DI,Self
         XOR     BX,BX
         MOV     DX,BX
     @@1:ADD     BX,ES:[DI].TView.Origin.X
         ADD     DX,ES:[DI].TView.Origin.Y
         LES     DI,ES:[DI].TView.Parent
         MOV     SI,ES
         OR      SI,DI
         JNE     @@1
         MOV     CX,2
         LES     DI, Area
         ADD     ES:[DI].TRect.A.X,BX
         ADD     ES:[DI].TRect.B.X,BX
         ADD     ES:[DI].TRect.A.Y,DX
         ADD     ES:[DI].TRect.B.Y,DX
         ADD     AX,BX
    end;

   procedure TView.Area_Limit(var Limit: TRect); assembler;
    asm
         LES     DI, Limit
         MOV     AX, $8888
         STOSW
         STOSW
         MOV     AX,Metric_Scr.X
         STOSW
         MOV     AX,Metric_Scr.Y
         STOSW
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
     FillChar(Area,SizeOf(Area),0)
    end;

   procedure TView.Area_Set(const Area: TRect);
    var
     Ex,Un: TRect;
     Lock: boolean;
    begin
     Area_Get(Ex);
     if Area.Equals(Ex) then Exit;
     if State and sf_Visual <> sf_Visual then Proc_Area(Area)
     else begin
      Un:=Ex;
      Un.Union(Area);
      with Area do
      Lock:=Long_Mul(Un.B.X-Un.A.X,Un.B.Y-Un.A.Y) <
      Long_Mul(B.X-A.X,B.Y-A.Y)+Long_Mul(Size.X,Size.Y);
      if Lock then Scr_Lock;
      Wnd_Hide;
      Proc_Area(Area);
      Wnd_Show;
      if Lock then Scr_UnLock
     end;
     Message(Parent,ev_Notify,cm_Locate,@Self)
    end;

   procedure TView.Canvas_Area(var Area: TRect);
    begin
     Area:=Scr_Actual;
     with Scr_Origin do Area.Move(-Origin.X-X,-Origin.Y-Y)
    end;

   function TView.Child_Is(View: PView): boolean;
    begin
     Child_Is:=View = @Self
    end;

{Методы Проверки (Vaild) Комманд (Comm) и Процессов (Proc)}

   procedure TView.Comm_Enable(Comm: word;On: boolean);
    begin
     if Parent <> nil then Parent^.Comm_Enable(Comm,On)
    end;

   function TView.Comm_Valid(Comm: word): boolean;
    begin
     Comm_Valid:=True
    end;

{Методы для обмена Данных (Data)}

   procedure TView.Data_Get(var Data);
    begin
    end;

   procedure TView.Data_Set(const Data);
    begin
    end;

   function TView.Data_Size: word;
    begin
     Data_Size:=0
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
     Space_Max(Scr_Visual);
     Scr_Invalid:=Scr_Visual;
     Scr_Invalid.Intersect(Scr_Actual);
     if Scr_Invalid.Empty or (Upper_Case(@DoClip) <> nil) then Exit;
     SetScrPort(Scr_Invalid,Scr_Visual);
     Proc_Paint
    end;

   procedure TView.DoHide;
    begin
     Area_Full(Scr_Visual);
     if Upper_Clip(Scr_Visual) then Exit;
     Scr_Actual.Move(-Scr_Origin.X,-Scr_Origin.Y);
     Parent^.Draw_Rect(Scr_Actual);
    end;

   procedure TView.DoMark(const Area :TRect);
    begin
     SetWriteMode(XorPut);
     SetLineStyle(UserBitLn,$AAAA,NormWidth);
     SetColor(7);
     with Area do Rectangle(A.X,A.Y,B.X,B.Y);
     SetWriteMode(CopyPut)
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

{Методы управления Диалогово (Dlg) режима}

   function TView.Dlg_Exec: Word;
    var
     E: TEvent;
     SaveResult: word;
     SaveModal: PView;
    begin
     SaveResult:=Dlg_Result;
     SaveModal:=Dlg_View;
     State_Set(sf_Modal,True);
     Dlg_View:=@Self;
     repeat
      Dlg_Result:=cm_NoComm;
      repeat
       Event_Get(Event_Mask,E);
       Proc_Event(E);
       if E.What <> ev_Nothing then Event_Err(E)
      until (Dlg_Result <> 0)
     until Comm_Valid(Dlg_Result);
     Dlg_Exec:=Dlg_Result;
     State_Set(sf_Modal,False);
     Dlg_View:=SaveModal;
     Dlg_Result:=SaveResult
    end;

   procedure TView.Dlg_Stop(Comm: word);
    begin
     Parent_Get^.Dlg_Stop(Comm)
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
         CALL  TView.Area_Local
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
     if (State and sf_Visual <> sf_Visual) or Upper_Clip(Area) then Exit;
     if Scr_Count > 0 then begin
      if Scr_Flag then Scr_Invalid.Union(Scr_Actual) else begin
       Scr_Invalid.Copy(Scr_Actual);
       Scr_Flag:=True
      end;
      Exit
     end;
     Space_Max(Scr_Visual);
     SetScrPort(Scr_Actual,Scr_Visual);
     with Application^.Mouse^ do begin
      Cursor_Hide;
      Proc_Paint;
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

   procedure TView.Event_Err(var E: TEvent);
    begin
     Parent_Get^.Event_Err(E);
    end;

   procedure TView.Event_Get(Mask: word; var E: TEvent);
    begin
     Parent_Get^.Event_Get(Mask,E)
    end;

   procedure TView.Event_Put(const E: TEvent);
    begin
     Parent_Get^.Event_Put(E)
    end;

   procedure TView.Event_Set(Mask: word; On: boolean);
    begin
     if On then Event_Mask:=Event_Mask or Mask
     else Event_Mask:=Event_Mask and not Mask
    end;

   function TView.HelpCtx_Get: word;
    begin
     HelpCtx_Get:=hc_NoContext
    end;

{Методы измененния Уровня (Level) Окна}

   procedure TView.Level_Top;
    begin
     if (Parent = nil) or (Parent^.Child_Last = @Self) then Exit;
     with Parent^ do begin
      DoDelete(@Self);
      DoInsert(Child_Last,@Self)
     end;
     DoShow
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

{Методы работы с Родительским (Parent) окном}

   function TView.Parent_Get: PView;
    begin
     if Parent = nil then RunError(err_ParentNil) else Parent_Get:=Parent
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

   function TView.Parent_Server: PGroup;
     var Res: PGroup;
    begin
     Res:=Parent;
     if Parent <> nil then with Parent^ do
     if (Parent <> nil) and (Parent^.Child_Client = Self.Parent)
     then Res:=Parent_Server;
     if Res = nil then Parent_Server:=Parent else Parent_Server:=Res
    end;

   procedure TView.Parent_Set(Group :PGroup);
    begin
     if Parent = Group then Exit;
     if Parent <> nil then Parent^.Child_Del(@Self);
     if Group <> nil then Group^.Child_Ins(@Self)
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

{Методы Обработки (Proc)}

   procedure TView.Proc_Area(const Area: TRect); assembler;
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

   procedure TView.Proc_Event(var E: TEvent);
    begin
     if E.What and ev_Mouse = 0 then Exit;
     if (State and (sf_Modal+sf_Focused) = 0)
     and (E.What = ev_MouseDown) and (Options and of_Selectable <> 0) then
     if not Wnd_Focus or (Options and of_NoFirstClick <> 0) then Event_Clr(E);
     if not Wnd_Group then Application^.Mouse^.Cursor_Set(Style_Cursor)
    end;

   procedure TView.Proc_Paint;
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
     if State and sf_Focused = sf_Not then Exit;
     Area_Mark(Area);
     if not Area.Empty then DoMark(ARea)
    end;

   procedure TView.Proc_State(AState: word; On: boolean);
    begin
     if On then State:=State or AState else State:=State and not AState;
     case AState of
      sf_Disabled:
       begin
        Message(Parent,ev_Notify,cm_Disable,@Self);
        if Options and of_AutoHide <> of_Not then Proc_State(sf_Visible,not On);
       end;
      sf_Modal:
       State_Set(sf_Focused,(State and sf_Actual = sf_Actual) or On);
      sf_Active,sf_Selected:
       State_Set(sf_Focused,State and sf_Actual = sf_Actual);
      sf_Visible:
       Message(Parent, ev_Notify, cm_Visual,@Self);
     end
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

{Методы работы с видимым Пространством (Space) екрана}

   procedure TView.Space_Clip(var Area: TRect); assembler;
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

   procedure TView.Space_Max(var Area: TRect); assembler;
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

   procedure TView.Space_Min(var Area: TRect); assembler;
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

{Методы управления Флагами Состояня (State) }

   function TView.State_Get(AState: word): boolean;
    begin
     State_Get:=State and AState = AState
    end;

   procedure TView.State_Set(AState: word; On: boolean);
     var Area: TRect;
    begin
     if (@Self = nil) or ((State and AState = AState) = On) then Exit;
     if AState = sf_Selected then with Parent^ do if On then begin
      Child_Curr^.State_Set(sf_Selected,False);
      if Self.Options and of_TopSelect <> of_Not then Self.Level_Top;
      Child_Curr:=@Self;
      Message(Parent,ev_Notify,cm_Select,@Self);
     end else Child_Curr:=nil;
     Proc_State(AState,On);
     if State and sf_Visual or AState = sf_Visual then
     if On then DoShow else DoHide;
     if (AState and sf_Focused = 0) or (State and sf_Visual <> sf_Visual)
     then Exit;
     Area_Mark(Area);
     if Area.Empty then Exit;
     Canvas_Init(Area);
     DoMark(Area);
     Canvas_Done
    end;

{Методы определения Стиля (Style) окна}

   function TView.Style_Cursor: PMouseCursor;
    begin
     Style_Cursor:=Parent_Get^.Style_Cursor
    end;

   procedure TView.Style_Font;
    begin
     SetTextStyle(Lo(Font_Program),HorizDir,Hi(Font_Program));
     SetTextJustify(LeftText, BottomText);
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
      Space_Clip(Scr_Actual);
      if Scr_Actual.Empty then Exit;
      Point_Global(Scr_Origin,Scr_Origin)
     end;
     Upper_Clip:=Upper_Case(@DoClip) <> nil
    end;

   function TView.Child_Find(Point: TPoint): PView;
    begin
     Child_Find:=@Self
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
         AND  AX, sf_Visual
         CMP  AX, sf_Visual
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

   function TView.Wnd_Focus: boolean;
    begin
     if (Parent = nil) or (State and sf_Focused <> 0) then Wnd_Focus:=True
     else Wnd_Focus:=Wnd_Select and Parent^.Wnd_Focus
    end;

   function TView.Wnd_Group: boolean;
    begin
     Wnd_Group:=False
    end;

   procedure TView.Wnd_Hide;
    begin
     State_Set(sf_Visible,False)
    end;

   function TView.Wnd_Select: boolean;
    begin
     Wnd_Select:=False;
     if (Options and of_Selectable = of_Not)
     or (State and sf_Disabled <> sf_Not) then Exit;
     with Parent^ do if (Child_Curr <> nil)
     and not Child_Curr^.Comm_Valid(cm_UnSelect) then Exit;
     State_Set(sf_Selected,True);
     Wnd_Select:=True
    end;

   procedure TView.Wnd_Show;
    begin
     State_Set(sf_Visible,True)
    end;


{Реализация объекта Фона (Client)}
{---------------------------------------------------------------------------}

   procedure TBackground.Proc_Paint;
     var Area: TRect;
    begin
     if (Options and of_Glass = 0) then begin
      Area_Free(Area);
      SetFillStyle(SolidFill,Style_Palette^.Color[3]);
      with Area do Bar(A.X,A.Y,B.X,B.Y)
     end;
     inherited Proc_Paint
    end;

   function TBackground.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Client
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
   procedure TGroup.Area_Desktop(var Area: TRect);
    begin
     Child_Client^.Area_Local(Area)
    end;

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

{Методы работы с дочерными (Child) окнами}

   function TGroup.Child_Client: PGroup;
    begin
     Child_Client:=nil;
    end;

   function TGroup.Child_Del(View: PView): pointer;
    begin
     Child_Del:=View;
     if View <> nil then with View^ do begin
      State_Set(sf_Exposed,False);
      if Child_Curr = View then Child_Select(False);
      State_Set(sf_Selected,False);
      State_Set(sf_Active,False);
      State_Set(sf_Present,False);
      DoDelete(View);
      Message(@Self,ev_Notify,cm_Delete,View)
     end
    end;

   function TGroup.Child_Exec(View: PView): word;
     var Curr :PView;
    begin
     if View <> nil then begin
      Curr:=Child_Curr;
      Child_Ins(View);
      Child_Exec:=View^.Dlg_Exec;
      Child_Del(View);
      Curr^.State_Set(sf_Selected,True);
     end else Child_Exec:=cm_Cancel
    end;

   function TGroup.Child_Find(Point: TPoint): PView;
     var
      Result: PView;
      Area: TRect;
     procedure DoTest(View: PView); far;
      begin
       if View^.State and sf_Visual <> sf_Visual then Exit;
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

   function TGroup.Child_Ins(View: PView): pointer;
    begin
     Child_Ins:=View;
     with Size do while View <> nil do with View^ do begin
      if Parent <> nil then Parent^.Child_Del(View);
      View:=Sibling_Next;
      Sibling_Next:=nil;
      DoInsert(Child_Last,Self_Ptr);
      if GrowMode and gm_CenterX <> 0 then Origin.X:=(X-Size.X) div 2;
      if GrowMode and gm_CenterY <> 0 then Origin.Y:=(Y-Size.Y) div 2;
      State_Set(sf_Present,Self.State and sf_Present <> sf_Not);
      State_Set(sf_Active, Self.State and sf_Focused <> sf_Not);
      State_Set(sf_Selected, Options and of_Selectable <> of_Not);
      State_Set(sf_Exposed, Self.State and sf_Visual = sf_Visual);
      Message(@Self,ev_Notify,cm_Insert,Self_Ptr)
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

   procedure TGroup.Child_Select(Forw: Boolean);
     var View: PView;
    begin
     if Child_Last = nil then Exit;
     if Child_Curr <> nil then View:=Child_Curr else
     if Forw then View:=Child_Last else View:=Child_First;
     with View^ do repeat
      if Forw then View:=View^.Sibling_Next else View:=View^.Sibling_Prev
     until (Self_Ptr = View) or View^.Wnd_Select
    end;

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

{Методы Проверки (Valid) Команд (Comm)}

   procedure TGroup.Comm_Enable(Comm: word;On: boolean);
     var E: TEvent;
    begin
     if Event_Mask and ev_Valid <> 0 then Parent_Get^.Comm_Enable(Comm,On)
     else begin
      E.What:=ev_Valid;
      E.Command:=Comm;
      E.InfoBool:=On;
      Proc_Event(E)
     end
    end;

   function TGroup.Comm_Valid(Comm: word): boolean;
    function DoValid(View: PView): boolean; far;
     begin
      DoValid:=not View^.Comm_Valid(Comm)
     end;
    begin
     Comm_Valid:=Child_Case(@DoValid) = nil
    end;

{Методы для обмена Данных (Data) }

   procedure TGroup.Data_Get(var Data);
    type
     Bytes = array[0..65534] of byte;
    var
     Sum: word;
    procedure DoData_Get(View: PView); far;
     begin
      View^.Data_Get(Bytes(Data)[Sum]);
      Inc(Sum, View^.Data_Size)
     end;
    begin
     Sum:=0;
     Child_For(@DoData_Get)
    end;

   function TGroup.Data_Size: word;
     var Sum:word;
    procedure DoData_Size(View: PView); far;
     begin
      Inc(Sum,View^.Data_Size)
     end;
    begin
     Sum:=0;
     Child_For(@DoData_Size);
     Data_Size:=Sum
    end;

   procedure TGroup.Data_Set(const Data);
    type
     Bytes = array[0..65534] of byte;
    var
     Sum: word;
    procedure DoData_Get(View: PView); far;
     begin
      View^.Data_Set(Bytes(Data)[Sum]);
      Inc(Sum, View^.Data_Size)
     end;
    begin
     Sum:=0;
     Child_For(@DoData_Get)
    end;

{Методы Добавления(Insert) Удаления (Delete)}

   function TGroup.Delete;
    begin
     if Child_Client <> nil then Delete:=Child_Client^.Delete(View)
     else Delete:=Child_Del(View)
    end;

   function TGroup.Insert;
    begin
     if Child_Client <> nil then Insert:=Child_Client^.Insert(View)
     else Insert:=Child_Ins(View)
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TGroup.HelpCtx_Get: word;
    begin
     if Child_Curr <> nil then HelpCtx_Get:=Child_Curr^.HelpCtx_Get
     else HelpCtx_Get:=inherited HelpCtx_Get
    end;

{Методы Обработки (Proc) событий}

   procedure TGroup.Proc_Area(const Area: TRect);
     var Delta: TPoint;

    procedure DoAreaCalc(View: PView); far;
     begin
      View^.Area_Calc(Delta);
     end;
    begin
     Delta.X:=Area.B.X-Area.A.X-Size.X;
     Delta.Y:=Area.B.Y-Area.A.Y-Size.Y;
     inherited Proc_Area(Area);
     if longint(Delta) <> 0 then Child_For(@DoAreaCalc)
    end;

   procedure TGroup.Proc_Event(var E: TEvent);

    function DoPublic(View: PView): boolean; far;
     begin
      with View^ do if E.What and Event_Mask <> 0 then Proc_Event(E);
      DoPublic:=E.What = ev_Nothing
     end;

    function DoCurr(View: PView): boolean;
     begin
      DoCurr:=(View^.State and sf_Disabled = 0) and DoPublic(View)
     end;

    function DoActive(View: PView): boolean; far;
     begin
      DoActive:=(View <> Child_Curr) and DoCurr(View)
     end;

    function DoPosition(View: PView): boolean; far;
     begin
      DoPosition:=False;
      with View^ do if not Application^.Indicator^.Parent_Is(View) or
      (State and sf_Disabled <> sf_Not) or (Event_Mask and E.What = 0) then Exit
      else Proc_Event(E);
      DoPosition:=True
     end;

    begin
     inherited Proc_Event(E);
     if (E.What and ev_Position <> 0) and (Child_Case(@DoPosition) = nil)
     then Application^.Mouse^.Cursor_Set(Style_Cursor) else
     if E.What and ev_Public <> 0 then Child_Case(@DoPublic) else
     if E.What and ev_Focused <> 0 then if (Child_Curr = nil)
     or not DoCurr(Child_Curr) then Child_Case(@DoActive)
    end;
                                     
   procedure TGroup.Proc_Paint;
    var
     SaveOrigin: TPoint;
     SaveActual,Area: TRect;
    procedure DoProc_Paint(View: PView); far; assembler;
     asm
         LES   DI, View
         MOV   AX, ES:[DI].TView.State
         MOV   BX, sf_Visual
         AND   AX, BX
         CMP   AX, BX
         JNE   @@1
         PUSH  ES
         PUSH  DI
         CALL  TView.DoDraw
      @@1:
     end;
    begin
     inherited Proc_Paint;
     SaveOrigin:=Scr_Origin;
     SaveActual:=Scr_Actual;
     Space_Min(Area);
     Scr_Origin:=Scr_Visual.A;
     Scr_Actual.Intersect(Area);
     Child_For(@DoProc_Paint);
     Scr_Origin:=SaveOrigin;
     Scr_Actual:=SaveActual
    end;

   procedure TGroup.Proc_State(AState: word; On: boolean);
    procedure DoState(State: word);
     procedure DoItem(View: PView); far;
      begin
       View^.Proc_State(State,On)
      end;
     begin
      Child_For(@DoItem)
     end;
    begin
     inherited Proc_State(AState,On);
     case AState of
      sf_Exposed,sf_Visible :
       if (State and sf_Visual or AState = sf_Visual) then DoState(sf_Exposed);
      sf_Focused : DoState(sf_Active);
      sf_Present: DoState(sf_Present);
     end
    end;

{Методы управления Окном (Wnd)}

   function TGroup.Wnd_Group: boolean;
    begin
     Wnd_Group:=True
    end;

{Личные (Private) методы объекта}

   procedure TGroup.DoDelete(View: PView);
     var Save: PView;
    begin
     Save:=View^.Sibling_Prev;
     if Child_Last = View then Child_Last:=Save;
     if Child_Last = View then Child_Last:=nil;
     with View^ do begin
      Save^.Sibling_Next:=Sibling_Next;
      Sibling_Next:=nil;
      Parent:=nil
     end
    end;

   procedure TGroup.DoInsert(Prev,View: PView);
    begin
     while View <> nil do with View^ do begin
      View:=Sibling_Next;
      if Child_Last = nil then Sibling_Next:=Self_Ptr else begin
       Sibling_Next:=Prev^.Sibling_Next;
       Prev^.Sibling_Next:=Self_Ptr
      end;
      Parent:=@Self;
      Child_Last:=Self_Ptr
     end
    end;


{-----------------------------------------------------------------------}

   constructor TClient.Init(const Area: TRect);
    begin
     inherited Init(Area);
     Event_Mask:=ev_AnyEvent;
     Options:=of_Selectable;
     GrowMode:=gm_GrowHiX+gm_GrowHiY
    end;

   procedure TClient.Area_Limit(var Limit: TRect); assembler;
    asm
         LES     DI, Limit
         MOV     AX, $FFFF
         STOSW
         STOSW
         MOV     AX,Metric_Scr.X
         STOSW
         MOV     AX,Metric_Scr.Y
         STOSW
    end;

   procedure TClient.Proc_Event(var E: TEvent);
    begin
     if (Size.X > 0) and (Size.Y > 0) then inherited Proc_Event(E)
    end;

   function TClient.Child_Client :PGroup;
    begin
     if (Desktop <> nil) and Desktop^.Wnd_Group then
     Child_Client:=PGroup(Desktop) else Child_Client:=nil
    end;


{-----------------------------------------------------------------------}

  const

   TProgram_Self: PProgram = nil;

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TProgram.Init; 
     var Area: TRect;
    begin
     Video_Init;
     Palette_Init;
     Metric_Init;
     longint(Area.A):=0;
     Area.B:=Metric_Scr;
     inherited Init(Area);
     TProgram_Self:=@Self;
     Event_Mask:=ev_AnyEvent-ev_Valid;
     Commander:=New_Commander;
     Mouse:=New_Mouse(Area);
     KeyBoard:=New_KeyBoard;
     Client:=Child_Ins(New_Client(Area))
    end;

   destructor TProgram.Done;
    begin
     inherited Done;
     Commander^.Free;
     KeyBoard^.Free;
     Mouse^.Free;
     Palette_Done;
     Video_Done;
     TProgram_Self:=nil;
    end;

{Методы работы с дочерными (Child) окнами}

   function TProgram.Child_Client :PGroup;
    begin
     Child_Client:=Client
    end;

{Методы управления Диалогово (Dlg) режима}

   procedure TProgram.Dlg_Stop(Comm: word);
    begin
     Dlg_Result:=Comm
    end;

{Методы для управления Событиями (Event)}

   procedure TProgram.Event_Err(var E: TEvent);
    begin
     Event_Clr(E);
    end;

   procedure TProgram.Event_Get(Mask: word; var E: TEvent);
    begin
     repeat
      Event_Find(E);
      if E.What and ev_Position <> 0 then Indicator:=Child_Find(E.Where);
      if E.What and ev_Modal = 0 then Proc_Event(E) else
      if E.What and Mask <> 0 then Exit else Event_Err(E)
     until False
    end;

   procedure TProgram.Event_Put(const E: TEvent);
    begin
     Commander^.Event_Put(E)
    end;

{Методы создания (New) вспомагательных объектов}

   function TProgram.New_Commander;
    begin
     New_Commander:=New(PCommander,Init(16));
    end;

   function TProgram.New_Client;
     var Group: PClient;
    begin
     Group:=New(PClient,InIt(Area));
     Group^.Area_Local(Area);
     Group^.Insert(New(PBackground,Init(Area)));
     New_Client:=Group
    end;

   function TProgram.New_Keyboard;
    begin
     New_KeyBoard:=New(PKeyBoard,Init);
    end;

   function TProgram.New_Mouse;
    begin
     New_Mouse:=New(PMouse,Init(Area))
    end;

{Методы иницизации (Init) Палитры (Palette)}

    procedure TProgram.Palette_Init;
     begin
      SetRGBPalette(5,48,48,49);
      SetRGBPalette(7,32,32,33);
      SetRGBPalette(2,0,20,4);
     end;

    procedure TProgram.Palette_Done;
     begin
     end;

{Методы Обработки (Proc) событий}

   procedure TProgram.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     case E.What of
      ev_Command:
       if E.Command = cm_Quit then begin
        Dlg_Stop(cm_Quit);
        Event_Clr(E)
       end;
      ev_KeyDown:
       if E.AbsKey.Code = kf_Alt+Char_Code('X') then begin
        E.What:=ev_Command;
        E.Command:=cm_Quit;
        E.InfoPtr:=@Self;
        Event_Put(E);
        Event_Clr(E)
       end
     end
    end;

   procedure TProgram.Proc_State(AState: word; On: boolean);
    begin
     inherited Proc_State(AState,On);
     case AState of
      sf_Modal : State_Set(sf_Present,On);
      sf_Present : State_Set(sf_Exposed,On)
     end
    end;

{Методы определени Стиля (Style) окна}

   function TProgram.Style_Cursor: PMouseCursor;
    begin
     Style_Cursor:=@Cursor_Arrow
    end;

{Методы иницизации (Init) Видимого режима}

   procedure TProgram.Video_Init;
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
     if ErrCode <> grOk then Writeln( GraphErrorMsg(ErrCode))
    end;

   procedure TProgram.Video_Done;
    begin
     CloseGraph
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


{Реализация объекта Протяжки (Drager)}
{---------------------------------------------------------------------------}

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TDrager.Build(AView: PView; ADragMode: word);
     var Area,APoligon,ALimit: TRect;
    begin
     if AView = nil then Fail;
     AView^.Area_Get(Area);
     AView^.Area_Limit(ALimit);
     AView^.Parent_Get^.Area_Local(APoligon);
     Init(Area,APoligon,ALimit,ADragMode);
     View:=AView;
    end;

   constructor TDrager.Init(const Area,APoligon,ALimit: TRect; ADragMode: word);
    begin
     inherited Init(Area);
     Poligon:=APoligon;
     Limit:=ALimit;
     Zoom:=Area;
     DragMode:=ADragMode;
     Options:=of_Glass;
     if DragMode and dm_DragMouse <> 0 then Event_Mask:=ev_Mouse
     else Event_Mask:=ev_KeyBoard;
     Inc(Event_Mask,ev_FreeTime);
     Style_Ln:= $FFFF;
     MinStep:=1;
     MaxStep:=24;
     State:=0;
     Step:=8
    end;

{Методы работы с Областью (Area) отображения}

   procedure TDrager.Area_Set(const Area: TRect);
     var Ex: TRect;
    begin
     Area_Get(Ex);
     if Area.Equals(Ex) then Exit;
     if State and sf_Visual <> sf_Visual then Proc_Area(Area) else begin
      Wnd_Hide;
      if View <> nil then View^.Area_Set(Area);
      Proc_Area(Area);
      Wnd_Show;
     end
    end;

{Методы Обработки (Proc) событий}

   procedure TDrager.Proc_Event(var E: TEvent);

    procedure MoveGrow(P, S: TPoint);
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
      S.X:=Min(Max(S.X, Limit.A.X), Limit.B.X);
      S.Y:=Min(Max(S.Y, Limit.A.Y), Limit.B.Y);
      P.X:=Min(Max(P.X, Poligon.A.X-S.X + 1), Poligon.B.X-1);
      P.Y:=Min(Max(P.Y, Poligon.A.Y-S.Y + 1), Poligon.B.Y-1);
      if DragMode and dm_LimitLoX <> 0 then P.X:=Max(P.X, Poligon.A.X);
      if DragMode and dm_LimitLoY <> 0 then P.Y:=Max(P.Y, Poligon.A.Y);
      if DragMode and dm_LimitHiX <> 0 then P.X:=Min(P.X, Poligon.B.X-S.X);
      if DragMode and dm_LimitHiY <> 0 then P.Y:=Min(P.Y, Poligon.B.Y-S.Y);
      Area.Assign(P.X,P.Y,P.X+S.X,P.Y+S.Y);
      Area_Set(Area)
     end;

    procedure Change(DX, DY: integer);
      var P: TPoint;
     begin
      if (E.AbsKey.Flag and kf_Shift <> 0) and
      (DragMode and dm_DragGrow <> 0) then begin
       P.X:=DX+Size.X;
       P.Y:=DY+Size.Y;
       MoveGrow(Origin,P)
      end else begin
       P.X:=DX+Origin.X;
       P.Y:=DY+Origin.Y;
       MoveGrow(P,Size)
      end
     end;

    procedure Update(X, Y: integer);
      var P: TPoint;
     begin
      if DragMode and dm_DragMove <> 0 then begin
       P.X:=X;
       P.Y:=Y;
       MoveGrow(P,Size)
      end
     end;

      var P :TPoint;
    begin
     if (E.What = ev_Notify) and (E.Command = cm_CnvInit)
      then begin
       P:=Scr_Origin;
       DoDraw;
       Scr_Origin:=P
      end
     else
     if State and (sf_Modal+sf_Visual) <> (sf_Modal+sf_Visual) then Exit;
     case E.What of
      ev_MouseUp:  Dlg_Stop(cm_Ok);
      ev_MouseMove:
       if DragMode and dm_DragMove <> 0 then
       if (DragMode and dm_AutoEsc <> 0)
       and not Application^.Indicator^.Parent_Is(Parent) then Area_Set(Zoom)
       else begin
        Inc(longint(E.Where),longint(Zoom.A)-longint(MousePos));
        MoveGrow(E.Where,Size)
       end else with Zoom do begin
        Inc(longint(E.Where),longint(B)-longint(A)-longint(MousePos));
        MoveGrow(Origin,E.Where)
       end;
      ev_KeyDown:
       begin
        case E.AbsKey.Code and not kf_Shift of
         kb_GrayPlus: if Step < MaxStep then Inc(Step);
         kb_GrayMinus: if Step > MinStep then Dec(Step);
         kb_Left: Change(-Step,0);
         kb_Right: Change(Step,0);
         kb_Up: Change(0,-Step);
         kb_Down: Change(0,Step);
         kb_Home: Update(Poligon.A.X, Origin.Y);
         kb_End: Update(Poligon.B.X-Size.X, Origin.Y);
         kb_PgUp: Update(Origin.X,Poligon.A.Y);
         kb_PgDn: Update(Origin.X,Poligon.B.Y-Size.Y);
         kb_Enter: Dlg_Stop(cm_Ok);
         kb_Esc:
          begin
           Dlg_Stop(cm_Cancel);
           Area_Set(Zoom)
          end
         else Exit
        end
       end
      else Exit
     end;
     Event_Clr(E)
    end;

   procedure TDrager.Proc_Paint;
    begin
     SetWriteMode(XorPut);
     SetColor(Style_Palette^.Color[1]);
     SetLineStyle(UserBitLn,Style_Ln,NormWidth);
     Rectangle(0,0,Size.X,Size.Y);
     SetWriteMode(CopyPut)
    end;

   procedure TDrager.Proc_State(AState: word; On: boolean);
    begin
     inherited Proc_State(AState,On);
     if AState <> sf_Modal then Exit;
     Application^.Mouse^.Cursor_Pos(MousePos);
     State_Set(sf_Visible,On)
    end;

{Методы определения Стиля (Style) окна}

   function TDrager.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Drager
    end;

   procedure TDrager.DoHide;
     var Save: word;
    begin
     Save:=State;
     State:=State or sf_Visual;
     Draw;
     State:=Save
    end;

   function Application: PProgram;
    begin
     if TProgram_Self = nil then RunError(err_AppNil)
     else Application:=TProgram_Self
    end;

   function Message(Whom: PView; What, Comm: Word; Info: Pointer): Pointer;
     var Event: TEvent;
    begin
     Message:=nil;
     if Whom = nil then Exit;
     Event.What:=What;
     Event.Command:=Comm;
     Event.InfoPtr:=Info;
     Whom^.Proc_Event(Event);
     if Event.What = ev_Nothing then Message:=Event.InfoPtr
    end;

   function Dialog: PView;
    begin
     if Dlg_View = nil then RunError(err_ModalNil) else Dialog:=Dlg_View
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

   procedure DoInitMetrics; far;
     var X,Y: word;
    begin
     GetAspectRatio(X,Y);
     Metric_Scr.X:=GetMaxX;
     Metric_Scr.Y:=GetMaxY;
     Font_Style(Font_Program,HorizDir);
     Metric_Box.Y:=TextWidth('T')*2;
     Metric_Box.X:=Round(X * Metric_Box.Y div Y);
     Metric_Shadow.Y:=Metric_Box.X div 8;
     Metric_Shadow.X:=Metric_Box.Y div 8;
    end;

  begin
   Metric_Init:=DoInitMetrics;
  end.
