 {      ┌───────────────────────────────────────────┐
        │                                           │
        │     W h i t e   A p p l i c a t o r       │
        │                                           │
        │           U D i a l o g   2.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1995        │
        │             (054) 33-35-94                │
        │                                           │
        │            (implementation)               │
        │                                           │
        └───────────────────────────────────────────┘      }

 {$I UDIALOG.INC}

 implementation

  uses

   UGraph, Dos;

{Реализация класса Прeссора (Pressor) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TPressor.Init;
    begin
     inherited Init(Area);
     Text:=Str_New(AText);
     Event_Mask:=ev_MouseDown + ev_MouseMove;
    end;

   destructor TPressor.Done;
    begin
     inherited Done;
     Str_Del(Text)
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TPressor.HelpCtx_Get: word;
    begin
     HelpCtx_Get:=HelpCtx
    end;

{Действие по нажаитю (Pressed)}

   procedure TPressor.Pressed;
    begin
    end;

{Методы Обработки (Proc)}

   procedure TPressor.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     if E.What <> ev_MouseDown then Exit;
     repeat
      if Application^.Indicator = @Self then begin
       State_Set(sf_Down,True);
       if (Options and of_AutoPress <> 0) then Pressed
      end else State_Set(sf_Down,False);
      Event_Get(ev_MouseAuto+ev_MouseUp,E)
     until (E.Buttons = 0) or (State and sf_Disabled <> 0);
     Event_Clr(E);
     if State and sf_Down = 0 then Exit;
     State_Set(sf_Down,False);
     if Options and of_AutoPress = 0 then Pressed
    end;

   procedure TPressor.Proc_State(AState: word; On: boolean);
     var Area: TRect;
    begin
     inherited Proc_State(AState,On);
     if AState and (sf_Down or sf_Disabled) <> 0 then Draw
    end;

{Методы определения Стиля (Style) окна}

   function TPressor.Style_Cursor: PMouseCursor;
    begin
     Style_Cursor:=@Cursor_Hand
    end;


{Реализация класса Клавиш (Key) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TKey.Init;
    begin
     inherited Init(Area,AText);
     Command:=Comm;
     Event_Mask:=Event_Mask or ev_Valid;
    end;

   constructor TKey.InitAuto;
    begin
     Init(Area,AText,Comm);
     Options:=of_AutoPress
    end;

{Действие по нажаитю (Pressed)}

   procedure TKey.Pressed;
     var E: TEvent;
    begin
     if Options and of_AutoPress = of_Not then begin
      E.What:=ev_Command;
      E.Command:=Command;
      E.InfoPtr:=@Self;
      Event_Put(E)
     end else Message(Parent,ev_BroadCast,Command,@Self)
    end;

{Методы Обработки (Proc)}

   procedure TKey.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     if (E.What = ev_Valid) and (E.Command = Command)
     then State_Set(sf_Disabled,not E.InfoBool)
    end;

   procedure TKey.Proc_Paint;
    var
     TextColor,H,C: integer;
     D: TPoint;
     Area: TRect;
    begin
     Area_Free(Area);
     D.X:=Size.X div 2;
     D.Y:=size.Y div 2;
     H:=Metric_Key;
     if State and sf_Down <> 0 then begin
      Inc(longint(D),$00010001);
      if H > 1 then Dec(H) else H:=-1
     end;
     if State and sf_Disabled = 0 then C:=6 else C:=8;
     Style_Font;
     with Style_Palette^ do begin;
      S3D_Body(Area,H,Color[3]);
      S3D_Text(D.X,D.Y,Text^,Color[C])
     end;
     inherited Proc_Paint
    end;

{Методы определения Стиля (Style) окна}

   procedure TKey.Style_Font;
     var Dir: integer;
    begin
     if Options and of_VertDir <> 0 then Dir:=VertDir else Dir:=HorizDir;
     Font_Style(Font_Key,Dir);
     SetTextJustify(CenterText,CenterText)
    end;

   function TKey.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Key
    end;


{Реализация класса Кнопок (Button) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TButton.Init;
    begin
     inherited Init(Area,AText,Comm);
     Options:=of_Selectable+of_Border;
     Event_Mask:=Event_Mask or ev_KeyDown or ev_Broadcast;
     Char_Mask:=Char_DefMask
    end;

   constructor TButton.InitDef;
    begin
     Init(Area,AText,Comm);
     Options:=Options or of_Default;
     Event_Mask:=Event_Mask or ev_Notify
    end;

{Методы Обработки (Proc)}

   procedure TButton.Proc_Event(var E: TEvent);
     var Ch :char;
    begin
     inherited Proc_Event(E);
     case E.What of
      ev_KeyDown:
       begin
        Ch:=Text_Ch(Text^);
        with E,AbsKey,SysKey do
        if (Char_Mask and kf_Char <> 0) and (UpCase(Char) in ([Ch]-[#0]))
        or (State and sf_Focused <> 0) and (Code = kb_Space)
        or (State and (sf_Default + sf_Focused) <> 0) and (Code = kb_Enter)
        or (Flag and Char_Mask <> 0) and (Scan = Char_Scan(Ch))
        then Pressed else Exit
       end;
      ev_Notify:
       if (E.Command = cm_Select) and (Options and of_Default <> 0) then
       State_Set(sf_Default,Message(E.InfoPtr,ev_Broadcast,cm_IsButton,@Self) = nil)
       else Exit;
      ev_Command:
       if (E.Command = cm_Default) and (State and sf_Default <> sf_Not)
       then Pressed else Exit;
      ev_Broadcast: if (E.Command <> cm_IsButton) then Exit;
      else Exit
     end;
     Event_Clr(E)
    end;

   procedure TButton.Proc_Paint;
    var
     TextColor,Dir,H,C: integer;
     D: TPoint;
     Area: TRect;
    begin
     Area_Free(Area);
     D.X:=(Size.X-Text_Width(Text^)) div 2;
     D.Y:=(Size.Y+TextHeight(Text^)) div 2;
     H:=Metric_Button;
     if State and sf_Down <> 0 then begin
      Inc(longint(D),$00010001);
      if H > 1 then Dec(H) else H:=-1
     end;
     if State and sf_Disabled = 0 then C:=6 else C:=8;
     Style_Font;
     with Style_Palette^ do begin;
     if State and sf_Default <> 0 then begin
       S3D_Rect(Area,1,Color[1]);
       Area.Grow(-1,-1)
      end;
      S3D_Body(Area,H,Color[3]);
      Text_3D(D.X,D.Y,Text^,Color[C])
     end;
     TView.Proc_Paint
    end;

   procedure TButton.Proc_State(AState: word; On: boolean);
    begin
     inherited Proc_State(AState,On);
     case AState of
      sf_Disabled: if On then State_Set(sf_Default,False);
      sf_Default: Draw;
     end
    end;

{Методы определения Стиля (Style) окна}

   procedure TButton.Style_Font;
    begin
     Font_Style(Font_Button,HorizDir);
     SetTextJustify(LeftText,BottomText)
    end;

   procedure TButton.Area_Mark;
    begin
     Style_Font;
     Area_Free(Area);
     Area.Grow(-Metric_Button,-Metric_Button)
    end;

   function TButton.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Button
    end;

{Реализация класса Кнопок с независимой фиксацией (CheckBox) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TCheckBox.Init(const Area: TRect; const AText: string);
    begin
     inherited Init(Area,AText);
     Options:=of_Selectable + of_Glass;
     Event_Mask:=Event_Mask or ev_KeyDown or ev_Broadcast;
     Char_Mask:=Char_DefMask
    end;

   constructor TCheckBox.InitOn(const Area: TRect; const AText: string);
    begin
     Init(Area,Atext);
     Pressed
    end;

{Методы обработки "Галочки" (Check)}

   procedure TCheckBox.Area_Check(var Area: TRect);
    begin
     Area_Local(Area);
     Area.B.X:=Metric_Box.X;
    end;

   function TCheckBox.Check_Get: byte;
    begin
     Check_Get:=byte(State and sf_Check <> 0);
    end;

{Методы для обмена Данных (Data) }

   procedure TCheckBox.Data_Get(var Data);
    begin
     boolean(Data):=State and sf_Check <> 0
    end;

   procedure TCheckBox.Data_Set(const Data);
    begin
     if boolean(Data) = (State and sf_Check = 0) then Pressed
    end;

   function  TCheckBox.Data_Size: word;
    begin
     Data_Size:=SizeOf(boolean)
    end;

{Методы Обработки (Proc)}

   procedure TCheckBox.Proc_Event(var E: TEvent);
     var Ch: char;
    begin
     inherited Proc_Event(E);
     if E.What <> ev_KeyDown then Exit;
     Ch:=Text_Ch(Text^);
     with E,AbsKey,SysKey do
     if (Char_Mask and kf_Char <> 0) and (UpCase(Char) = Ch)
     or (State and sf_Focused <> 0) and (Code = kb_Space)
     or (Flag and Char_Mask <> 0) and (Scan = Char_Scan(Ch))
     then Pressed else Exit;
     Event_Clr(E)
    end;

   procedure TCheckBox.Proc_Paint;
    var
     TextColor,Dir,H,C: integer;
     D: TPoint;
     Area: TRect;
    begin
     Area_Free(Area);
     D.Y:=(Size.Y+TextHeight(Text^)) div 2;
     if State and sf_Down <> 0 then begin
      Inc(longint(D),$00010001);
      H:=-1
     end else H:=0;
     if State and sf_Disabled = 0 then C:=6 else C:=8;
     Style_Font;
     with Style_Palette^ do begin;
      S3D_Body(Area,H,Color[3]);
      Text_3D(TextWidth('   '),D.Y,Text^,Color[C]);
      if State and sf_Check <> 0 then C:=10 else C:=12;
      Text_3D(0,D.Y,' '+Style_Symbol,Color[C])
     end;
     TView.Proc_Paint
    end;

   procedure TCheckBox.Proc_State(AState: word; On: boolean);
     var Area: TRect;
    begin
     inherited Proc_State(AState,On);
     case AState of
      sf_Check: begin
       Area_Check(Area);
       Draw_Rect(Area)
      end;
     end
    end;

{Действие по нажаитю (Pressed)}

   procedure TCheckBox.Pressed;
    begin
     State_Set(sf_Check, State and sf_Check = 0)
    end;

   procedure TCheckBox.Area_Mark;
     var H,W: integer;
    begin
     Style_Font;
     H:=TextHeight(Text^)+4;
     W:=Text_Width(Text^);
     Area.Open(Font_Lng(3),(Size.Y-H) div 2,W,H)
    end;

   function TCheckBox.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_CheckBox
    end;

   function TCheckBox.Style_Symbol: char;
    begin
     Style_Symbol:=UView.Symbol[8]
    end;

{Методы определения Стиля (Style) окна}

   procedure TCheckBox.Style_Font;
    begin
     Font_Style(Font_CheckBox,HorizDir);
     SetTextJustify(LeftText,BottomText)
    end;


{Реализация класса Кнопок с зависимой фиксацией (RadioBox) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TRadioBox.Init(const Area: TRect; const AText: string);
    begin
     inherited Init(Area,AText);
     Event_Mask:=Event_Mask or ev_Notify;
     Options:=Options or of_Glass
    end;

   constructor TRadioBox.InitOn(const Area: TRect; const AText: string);
    begin
     Init(Area,AText);
     Pressed
    end;

   constructor TRadioBox.InitAuto(const Area: TRect; const AText: string);
    begin
     Init(Area,AText);
     Options:=Options or of_AutoCheck or of_NoFirstClick
    end;

   procedure TRadioBox.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     if (E.What <> ev_Notify) or (E.Command <> cm_OffCheck)
     or (State and sf_Check = 0) then Exit;
     Event_Clr(E);
     Pressed
    end;

   procedure TRadioBox.Proc_State(AState: word; On: boolean);
    begin
     if On and (AState = sf_Check) then
     Message(Parent,ev_Notify,cm_OffCheck,@Self);
     inherited Proc_State(AState,On);
     if On and (Options and of_AutoCheck <> 0) then
     case AState of
      sf_Check: Wnd_Select;
      sf_Selected: if State and sf_Check = 0 then Pressed
     end
    end;

{Методы определения Стиля (Style) окна}

   function TRadioBox.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_RadioBox
    end;

   function TRadioBox.Style_Symbol: char;
    begin
     if State and sf_Check = 0 then Style_Symbol:=Symbol[11]
     else Style_Symbol:=Symbol[12]
    end;

   procedure TRadioBox.Style_Font;
    begin
     Font_Style(Font_RadioBox,HorizDir);
     SetTextJustify(LeftText,BottomText)
    end;


{Реализация класса Сенсоров (Sensor) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TSensor.Init(const Area: TRect);
    begin
     inherited Init(Area);
     Event_Mask:=Event_Mask or (ev_Mouse+ev_Valid)
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TSensor.HelpCtx_Get: word;
    begin
     HelpCtx_Get:=HelpCtx
    end;

{Действие по нажаитю (Pressed)}

   procedure TSensor.Pressed;
     var E: TEvent;
    begin
     E.What:=ev_Command;
     E.Command:=Command;
     E.InfoPtr:=@Self;
     Event_Put(E)
    end;

{Методы Обработки (Proc)}

   procedure TSensor.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     case E.What of
      ev_MouseDown:
       begin
        if((Options and of_DoublePress = 0) and E.Double) then Exit;
        Event_Clr(E);
        Pressed
       end;
      ev_Valid:
       if (E.Command = Command) then State_Set(sf_Disabled,not E.InfoBool)
      end
    end;


{Реализация класса "Уголок" (Corner) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TCorner.Init;
    begin
     inherited Init(Area);
     Command:=cm_MouseGrow;
     Options:=of_AutoHide
    end;

   procedure TCorner.Proc_Paint;
     var Area: TRect;
    begin
     if Options and of_Glass = 0 then with Style_Palette^ do begin
      Area_Free(Area);
      SetFillStyle(9,Color[3]);
      with Area do Bar(A.X,A.Y,B.X,B.Y);
     end;
     inherited Proc_Paint
    end;

{Методы определения Стиля (Style) окна}

   function TCorner.Style_Cursor: PMouseCursor;
    begin
     Style_Cursor:=@Cursor_SizeNS
    end;

   function  TCorner.Style_Palette;
    begin
     Style_Palette:=@Palette_Corner
    end;


{Реализация класса Заглавие (TitleBar) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TTitleBar.Init;
    begin
     inherited Init(Area);
     Command:=cm_MouseMove;
     Text:=Str_New(AText);
    end;

   destructor TTitleBar.Done;
    begin
     inherited Done;
     Str_Del(Text)
    end;

{Методы работы с Областью (Area) отображения}

   procedure TTitleBar.Area_Limit(var Limit: TRect);
    begin
     inherited Area_Limit(Limit);
     Limit.A:=Metric_TitleBar;
     Limit.A.X:=Limit.A.X * 4
    end;

{Методы Обработки (Proc)}

   procedure TTitleBar.Proc_Paint;
    var
     D: integer;
     Pos: TPoint;
     Area: TRect;
     S: integer;
    begin
     Style_Font;
     if State and sf_Active <> 0 then D:=0 else D:=4;
     Pos.X:=(Size.X-TextWidth(Text^)) div 2;
     if Pos.X < 2 then Pos.X:=2;
     Pos.Y:=(Size.Y+TextHeight(Text^)) div 2;
     Area_Free(Area);
     with Style_Palette^ do begin
      S3D_Body(Area,1,Color[3+D]);
      SetColor(Color[6+D]);
      if Text <> nil then OutTextXY(Pos.X,Pos.Y,Text^);
     end;
     inherited Proc_Paint
    end;

   procedure TTitleBar.Proc_State(AState: word; On: boolean);
    begin
     inherited Proc_State(AState,On);
     if AState = sf_Active then Draw
    end;

{Методы определения Стиля (Style) окна}

   function TTitleBar.Style_Cursor: PMouseCursor;
    begin
     Style_Cursor:=@Cursor_Size
    end;

   procedure TTitleBar.Style_Font;
     var Dir: integer;
    begin
     Font_Style(Font_TitleBar,HorizDir);
     SetTextJustify(LeftText,BottomText)
    end;

   function TTitleBar.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_TitleBar
    end;


{Реализация класса "Рамки" (Frame) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TFrame.Init;
    begin
     inherited Init(Area);
     Command:=cm_MouseMove;
     Options:=Options or of_Border;
     Thick:=AThick
    end;

{Методы Обработки (Proc)}

   procedure TFrame.Proc_Paint;
    var
     Area: TRect;
     Delta: TPoint;
    begin
     if longint(Thick) = 0 then Exit;
     Area_Free(Area);
     Delta:=Thick;
     if Options and of_Border <> 0 then Dec(longint(Delta),$00010001);
     with Style_Palette^ ,Area do begin
      SetFillStyle(SolidFill,Color[3]);
      Bar(A.X, A.Y, B.X, A.Y+Delta.Y);
      Bar(A.X, A.Y, A.X+Delta.X, B.Y);
      Bar(A.X, B.Y-Delta.Y, B.X, B.Y);
      Bar(B.X-Delta.X, A.Y, B.X, B.Y);
      if Options and of_Border = of_Not then Exit;
      with Delta do Area.Grow(-X,-Y);
      S3D_Rect(Area,-1,Color[1]);
     end;
     inherited Proc_Paint
    end;

{Методы определения Стиля (Style) окна}

   function TFrame.Style_Cursor: PMouseCursor;
    begin
     if State and sf_Active = sf_Not
     then Style_Cursor:=inherited Style_Cursor
     else Style_Cursor:=@Cursor_Size
    end;

   function TFrame.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Frame
    end;


{Реализация класса Mетка (Order) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TLabel.Init;
    begin
     inherited Init(Area);
     Event_Mask:=Event_Mask or (ev_Broadcast+ev_KeyDown+ev_Mouse);
     Char_Mask:=Char_DefMask;
     Text:=Str_New(AText);
     Master:=AMaster;
    end;

   constructor TLabel.InitPack;
    begin
     Init(Area,AText,AMaster);
     Options:=of_PackSize
    end;

   destructor TLabel.Done;
    begin
     inherited Done;
     Str_Del(Text)
    end;

{Методы Обработки (Proc)}

   procedure TLabel.Proc_Event(var E: TEvent);
     var Ch: char;
    begin
     inherited Proc_Event(E);
     case E.What of
      ev_Notify:
       if (E.Command = cm_Disable) and (E.InfoPtr = Master)
       then State_Set(sf_Disabled,Master^.State and sf_Disabled <> 0);
      ev_MouseDown:
       if Master <> nil then if not Master^.Wnd_Focus then Exit;
      ev_KeyDown :
       begin;
        Ch:=Text_Ch(Text^);
        with E,AbsKey,SysKey do
        if (Char_Mask and kf_Char <> 0) and (UpCase(Char) = Ch)
        or (Flag and Char_Mask <> 0) and (Scan = Char_Scan(Ch))
        and (Master <> nil) and Master^.Wnd_Focus then else Exit;
       end
      else Exit
     end;
     Event_Clr(E)
    end;

   procedure TLabel.Proc_Paint;
    var
     Area: TRect;
     C:  integer;
    begin
     Area_Free(Area);
     with Style_Palette^ do begin
      if Options and of_Glass = 0 then  begin
       SetFillStyle(SolidFill,Color[3]);
       with Area do Bar(A.X,A.Y,B.X,B.Y)
      end;
      if State and sf_Disabled = 0 then C:=4 else C:=6;
      Style_Font;
      Text_3D(0,TextHeight(Text^),Text^,Color[C])
     end;
     inherited Proc_Paint
    end;

   procedure TLabel.Proc_State(AState: word; On: boolean);
    procedure PackSize;
     begin
      Style_Font;
      Size.X:=Text_Width(Text^);
      Size.Y:=TextHeight(Text^)
     end;
    begin
     inherited Proc_State(AState, On);
     case AState of
      sf_Disabled:  Draw;
      sf_Exposed :  if On and (Options and of_PackSize <> 0) then PackSize
     end
    end;


   procedure TLabel.Style_Font;
    begin
     Font_Style(Font_Label,HorizDir);
     SetTextJustify(LeftText,BottomText)
    end;

   function TLabel.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Label
    end;



{Реализация класса Линейка Текста (TextBox) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TTextBox.Init;
    begin
     inherited Init(Area);
     Text:=Str_New(AText);
     Options:=OPtions or of_Glass;
     Position:=Pos
    end;

{Методы Обработки (Proc)}

   destructor TTextBox.Done;
    begin
     inherited Done;
     Str_Del(Text)
    end;

   procedure TTextBox.Proc_Paint;
    var
     Center: Boolean;
     First,Last,Long,Pos,MaxCh,PosY,PosX,DY: Integer;
     WStr: PString;
     S: string;
    begin
     Style_Font;
     S:=Text^;
     Long:=Length(S);
     Pos:=1;
     MaxCh:=Size.X div 8;
     PosY:=Position.Y;
     Center:=False;
     DY:=TextHeight('W')*2;
     while Pos < Long do with Style_Palette^ do begin
      if S[Pos] = #3 then begin
       Center:=True;
       Inc(Pos)
      end;
      First:=Pos-1;
      repeat
       Last:=Pos;
       while (Pos <= Long) and (S[Pos] = #32) do Inc(Pos);
       while (Pos <= Long) and (S[Pos] <> #32)
       and (S[Pos] <> #13) do Inc(Pos)
      until (Pos > Long) or (Pos >= First+MaxCh) or (S[Pos] = #13);
      if (Pos >= First+MaxCh) then begin
       if Last = First+1 then Inc(Last,MaxCh);
       Pos:=Last
      end else Last:=Pos-1;
      WStr:=@S[First];
      byte(WStr^[0]):=Last-First;
      if Center then PosX:=(Size.X-TextWidth(WStr^)) div 2
      else PosX:=Position.X;
      S3D_Text(PosX,PosY,WStr^,Color[4]);
      Inc(PosY,DY);
      while (Pos <= Long) and (S[Pos] = #32) do Inc(Pos);
      if (Pos <= Long) and (S[Pos] = #13) then begin
       Center:=False;
       Inc(Pos)
      end
     end;
     inherited Proc_Paint;
    end;

{Методы определения Стиля (Style) окна}

   procedure TTextBox.Style_Font;
    begin
     Font_Style(Font_TextBox,HorizDir);
     SetTextJustify(LeftText,BottomText)
    end;

   function TTextBox.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_TextBox
    end;


{Реализация класса Строки Ввода (InputBar) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TInputBar.Init(Area: TRect; AMaxLen: byte);
    begin
     inherited Init(Area);
     Options:=of_Selectable + of_Border;
     Event_Mask:=ev_MouseDown;
     GetMem(Text,AMaxLen+1);
     MaxLen:=AMaxLen;
     Text^:=''
    end;

   destructor TInputBar.Done;
    begin
     inherited Done;
     FreeMem(Text,MaxLen+1)
    end;

{Проверка (Valid) Аитибута (Attr)}

   procedure TInputBar.Attr_Valid(var A:TAttr; var S: string);
     var VisLn: integer;
    begin
     VisLn:=Text_Vis;
     if A.Curr < 0 then A.Curr:=0 else
     if A.Curr > byte(S[0]) then A.Curr:=byte(S[0]);
     if A.Curr > A.Pos + VisLn then A.Pos:=A.Curr-VisLn;
     if A.Curr < A.Pos then A.Pos:=A.Curr;
     if A.Home < 0 then A.Home:=0;
     if A.Home > byte(S[0]) then A.Home:=byte(S[0]);
     State_Set(sf_NoForw,A.Pos = 0);
     State_Set(sf_NoBack,A.Pos >= byte(S[0])-VisLn)
    end;

{Методы работы с Областью (Area) отображения}

   procedure TInputBar.Area_Limit(var Limit: TRect);
    begin
     inherited Area_Limit(Limit);
     Limit.A:=Metric_Edit
    end;

{Методы для обмена Данных (Data) }

   procedure TInputBar.Data_Get(var Rec);
    begin
     string(Rec):=Text^
    end;

   function TInputBar.Data_Size: Word;
    begin
     Data_Size:=MaxLen+1
    end;

   procedure TInputBar.Data_Set(const Rec);
    begin
     Text_Set(string(Rec));
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TInputBar.HelpCtx_Get: word;
    begin
     HelpCtx_Get:=HelpCtx
    end;


{Методы Обработки (Proc)}

   procedure TInputBar.Proc_Event(var E: TEvent);

    procedure Mouse_Track;
     var
      Org: TPoint;
      H: integer;
     begin
      longint(Org):=0;
      Point_Global(Org,Org);
      H:=TextWidth(' ');
      Text_Cursor((E.Where.X-Org.X) div H + Attr.Pos);
      with Attr do repeat
       Text_Select(Home,(E.Where.X-Org.X) div H + Pos);
       Event_Get(ev_MouseMove+ev_MouseUp,E)
      until E.Buttons = 0
     end;

    procedure Param_Set(var SAttr: TAttr; var  SText: string);
     begin
      if not Text_Valid(SAttr,SText) then Exit;
      Attr_Valid(SAttr,SText);
      Attr:=SAttr;
      Text^:=SText;
      Draw
     end;

    procedure Block_Delete(var SAttr: TAttr; var SText: string);
      var D: integer;
     begin
      with SAttr do begin
       D:=Home-Curr;
       if D < 0 then Curr:=Home else Home:=Curr;
       Delete(SText,Curr+1,Abs(D))
      end;
     end;

    procedure Char_InputBar;
     var
      SText: string;
      SAttr :TAttr;
     begin
      SAttr:=Attr;
      SText:=Text^;
      with SAttr,E,AbsKey,SysKey do begin
       if Curr <> Home then Block_Delete(SAttr,SText);
       Inc(Curr);
       Inc(Home);
       if Application^.KeyBoard^.Status^ and ks_InsertOn <> 0
       then Delete(SText,Curr,1);
       Insert(Char,SText,Curr);
      end;
      Param_Set(SAttr,SText)
     end;

    procedure Char_Delete;
     var
      SAttr: TAttr;
      SText: string;
     begin
      SText:=Text^;
      SAttr:=Attr;
      with SAttr,E.AbsKey do begin
       if Curr = Home then if Code = kb_Back then Dec(Curr) else Inc(Home);
       Block_Delete(SAttr,SText)
      end;
      Param_Set(SAttr,SText)
     end;

    begin
     inherited Proc_Event(E);
     case E.What of
      ev_MouseDown:
       if E.Double then Text_Select(byte(Text^[0]),0)
       else Mouse_Track;
      ev_Broadcast:
       case E.Command of
        cm_Forw: Text_Scroll(Attr.Pos-1);
        cm_Back: Text_Scroll(Attr.Pos+1);
        else Exit
       end;
      ev_KeyDown:
       with Attr do case E.AbsKey.Code of
        kb_Ins: Draw;
        kb_Home: Text_Cursor(0);
        kb_End: Text_Cursor(byte(Text^[0]));
        kb_Left: Text_Cursor(Curr-1);
        kb_Right: Text_Cursor(Curr+1);
        kb_Home+kf_Shift: Text_Select(Home,0);
        kb_End+kf_Shift: Text_Select(Home,byte(Text^[0]));
        kb_Left+kf_Shift: Text_Select(Home,Curr-1);
        kb_Right+kf_Shift: Text_Select(Home,Curr+1);
        kb_Del,kb_Back: Char_Delete;
        else case E.SysKey.Char of
         ' '..#255 : Char_InputBar;
         ^Y : Text_Set('');
         else Exit
        end
       end;
      else Exit
     end;
     Event_Clr(E);
    end;

   procedure TInputBar.Proc_Paint;
    var
     W,H,O,E: Integer;
     Area: TRect;

    procedure Cursor(AX,AY: integer);
      var H: byte;
     begin
      if Application^.KeyBoard^.Status^ and ks_InsertOn = 0
      then H:=0 else H:=1;
      SetFillStyle(1,Style_Palette^.Color[5]);
      Bar(AX,AY,AX+W,AY+H)
     end;

    begin
     with Style_Palette^ do begin
      Area_Free(Area);
      SetFillStyle(SolidFill,Color[3]);
      with Area do Bar(A.X,A.Y,B.X,B.Y);
      W:=TextWidth(' ');
      H:=(Size.Y+TextHeight('W')) div 2;
      Area.Grow(-1,-1);
      if State and sf_Focused <> 0 then with Area,Attr do begin
       O:=A.X+(Home-Pos)*W;
       E:=A.X+(Curr-Pos)*W;
       if Home < Curr then begin
        if A.X < O then A.X:=O;
        if B.X > E then B.X:=E
       end else begin
        if A.X < E then A.X:=E;
        if B.X > O then B.X:=O
       end;
       SetFillStyle(SolidFill,Color[4]);
       with Area do Bar(A.X,A.Y,B.X,B.Y)
      end;
      Style_Font;
      SetColor(Color[5]);
      if State and sf_Focused <> 0
      then Cursor(E,H);
      OutTextXY(3,H,Copy(Text^,Attr.Pos+1,MaxLen))
     end;
     inherited Proc_Paint
    end;

   procedure TInputBar.Proc_State(AState: word; On: boolean);
    begin
     inherited Proc_State(AState, On);
     case AState of
      sf_Present:
       Attr_Valid(Attr,Text^);
      sf_Focused:
       begin
        Text_Select(byte(Text^[0]),0);
        Event_Set(ev_KeyDown,On);
        Draw;
       end;
       sf_NoForw: Comm_Enable(cm_Forw,not On);
       sf_NoBack: Comm_Enable(cm_Back,not On)
     end
    end;

{Методы определения Стиля (Style) окна}

   procedure TInputBar.Style_Font;
    begin
     Font_Style(Font_InputBar,HorizDir);
     SetTextJustify(LeftText,BottomText)
    end;

   function TInputBar.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_InputBar
    end;

{Методы управления Текстом (Text)}

   procedure TInputBar.Text_Cursor(C: integer);
     var Save: TAttr;
    begin
     Save:=Attr;
     Attr.Curr:=C;
     Attr.Home:=C;
     Attr_Valid(Attr,Text^);
     if not Buf_Equals(Save,Attr,SizeOf(Attr)) then Draw
    end;

   procedure TInputBar.Text_Scroll(P: integer);
     var VisLn: integer;
    begin
     VisLn:=Text_Vis;
     if byte(Text^[0]) <= VisLn+P then P:=byte(Text^[0])-VisLn;
     State_Set(sf_NoForw,P = 0);
     State_Set(sf_NoBack,P >= byte(Text^[0])-VisLn);
     if P < 0 then P:=0;
     if Attr.Pos = P then Exit;
     Attr.Pos:=P;
     Draw
    end;

   procedure TInputBar.Text_Select(H,C: integer);
     var Save: TAttr;
    begin
     Save:=Attr;
     Attr.Curr:=C;
     Attr.Home:=H;
     Attr_Valid(Attr,Text^);
     if not Buf_Equals(Save,Attr,SizeOf(Attr)) then Draw
    end;

   procedure TInputBar.Text_Set(S: string);
     var SAttr: TAttr;
    begin
     SAttr:=Attr;
     if not Text_Valid(SAttr,S) then Exit;
     Attr_Valid(SAttr,S);
     if(Text^= S) or Buf_Equals(SAttr,Attr,SizeOf(Attr)) then Exit;
     Text^:=S;
     Draw
    end;

   function  TInputBar.Text_Valid(var A: TAttr; var S :string): boolean;
    begin
     Text_Valid:=byte(S[0]) <= MaxLen
    end;

   function TInputBar.Text_Vis: byte;
    begin
     Style_Font;
     Text_Vis:=Size.X div TextWidth(' ')-1
    end;


{Реализация класса Редактора Строки (EditBar) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TEditBar.Init;
    var
     B,S: TRect;
     View: PView;
    begin
     inherited Init(R);
     Event_Mask:=ev_Mouse+ev_KeyDown;;
     Options:=of_Selectable or AOptions;
     Area_Free(R);
     B:=R;
     B.B.X:=B.A.X+Metric_Edit.X;
     View:=(Child_Ins(New_KeyForw(B)));
     if View <> nil then View^.GrowMode:=gm_GrowHiY;
     R.A.X:=Succ(B.B.X);
     B.B:=R.B;
     B.A.X:=B.B.X-Metric_Edit.X;
     View:=(Child_Ins(New_KeyBack(B)));
     if View <> nil then View^.GrowMode:=gm_GrowHiY+gm_GrowLoX;
     R.B.X:=Pred(B.A.X);
     with PView(Child_Ins(New_InputBar(R,AMaxLen)))^ do begin
      Event_Mask:=Event_Mask or ev_Valid or ev_Broadcast;
      GrowMode:=gm_GrowHiY+gm_GrowHiX;
      Child_Last:=Sibling_Prev
     end
    end;

{Методы создания (New) вспомагательных объектов}

   function TEditBar.New_KeyForw(const Area: TRect): PView;
    begin
     with PView(New(PKey,InitAuto(Area,Symbol[4],cm_Forw)))^ do begin
      Options:=OPtions or of_VertDir;
      New_KeyForw:=Self_Ptr
     end
    end;

   function TEditBar.New_KeyBack(const Area: TRect): PView;
    begin
     with PView(New(PKey,InitAuto(Area,Symbol[5],cm_Back)))^ do begin
      Options:=Options or of_VertDir;
      New_KeyBack:=Self_Ptr
     end
    end;

   function TEditBar.New_InputBar(const Area: TRect; AMaxLen: byte): PView;
    begin
     New_InputBar:=New(PInputBar,Init(Area,AMaxLen))
    end;

   function TPanel.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Panel
    end;

   constructor TDial.Init(Area: TRect);
    begin
     inherited Init(Area);
     Event_Mask:=ev_FreeTime;
     Options:=Options or of_Border
    end;

   procedure TDial.Arrow_Hour;
    var
     C,P: TPoint;
     R: integer;
    begin
     SetWriteMode(XorPut);
     C.X:=Size.X div 2;
     C.Y:=Size.Y div 2;
     if C.Y > C.X then R:=C.X else R:=C.Y;
     R:=R div 2;
     P.X:=Round(R*Sin(3.1415/30*Hour));
     P.Y:=-Round(R*Cos(3.1415/30*Hour));
     SetLineStyle(SolidLn,0,ThickWidth);
     with Style_Palette^ do SetColor(Color[5]);
     Line(C.X - P.X div 4, C.Y-P.Y div 4, C.X+P.X, C.Y+P.Y);
     SetWriteMode(CopyPut)
    end;

   procedure TDial.Arrow_Minute;
    var
     C,P: TPoint;
     R: integer;
    begin
     SetWriteMode(XorPut);
     C.X:=Size.X div 2;
     C.Y:=Size.Y div 2;
     if C.Y > C.X then R:=C.X else R:=C.Y;
     R:=R * 8 div 10;
     P.X:=Round(R*Sin(3.1415/30*Minute));
     P.Y:=-Round(R*Cos(3.1415/30*Minute));
     SetLineStyle(SolidLn,0,ThickWidth);
     with Style_Palette^ do SetColor(Color[6]);
     Line(C.X - P.X div 4, C.Y-P.Y div 4, C.X+P.X, C.Y+P.Y);
     SetWriteMode(CopyPut)
    end;

   procedure TDial.Arrow_Second;
    var
     C,P: TPoint;
     R: integer;
    begin
     SetWriteMode(XorPut);
     C.X:=Size.X div 2;
     C.Y:=Size.Y div 2;
     if C.Y > C.X then R:=C.X else R:=C.Y;
     P.X:=Round(R*Sin(3.1415/30*Second));
     P.Y:=-Round(R*Cos(3.1415/30*Second));
     SetLineStyle(SolidLn,0,NormWidth);
     with Style_Palette^ do SetColor(Color[7]);
     Line(C.X - P.X div 4, C.Y-P.Y div 4, C.X+P.X, C.Y+P.Y);
     SetWriteMode(CopyPut)
    end;

   procedure TDial.Proc_Event(var E: TEvent);
    var
     AHour, AMinute, ASecond, Sec100: Word;
     Area: TRect;
    begin
     inherited Proc_Event(E);
     if E.What <> ev_FreeTime then Exit;
     GetTime(AHour,AMinute,ASecond,Sec100);
     AHour:=((AHour * 60) + AMinute) div 12;
     if ASecond = Second then Exit;
     Area_Local(Area);
      Canvas_Init(Area);
      if AHour <> Hour then begin
      Arrow_Hour;
      Hour:=AHour;
      Arrow_Hour
     end;
     if AMinute <> Minute then begin
      Arrow_Minute;
      Minute:=AMinute;
      Arrow_Minute
     end;
     if ASecond <> Second then begin
      Arrow_Second;
      Second:=ASecond;
      Arrow_Second
     end;
     Canvas_Done
    end;

   procedure TDial.Proc_Paint;
    var
     I,R,D:integer;
     P,C: TPoint;
    begin
     inherited Proc_Paint;
     C.X:=Size.X div 2;
     C.Y:=Size.Y div 2;
     if C.Y > C.X then R:=C.X else R:=C.Y;
     Dec(R,2);
     SetLineStyle(SolidLn,0,NormWidth);
     SetColor(Style_Palette^.Color[4]);
     for I:=0 to 11 do begin
      P.Y:=Round(R*Sin(3.1415/6*I));
      P.X:=Round(R*Cos(3.1415/6*I));
      if I mod 3 = 0 then D:=8 else D:=9;
      MoveTo(C.X+P.X,C.Y+P.Y);
      P.X:=P.X * D div 10;
      P.Y:=P.Y * D div 10;
      LineTo(C.X+P.X,C.Y+P.Y);
     end;
     Arrow_Hour;
     Arrow_Minute;
     Arrow_Second
    end;

   function TDial.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Dial
    end;

{Реализация класса Горизонтального Индикатора (Indecator) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor THIndicator.Init(const Area :TRect; AColor: byte);
   begin
    inherited Init(Area);
    Options:=Options or of_Border;
    Color:=AColor;
   end;

  {Методы настройки Уровня прогресса (Progress)}

   procedure THIndicator.Progress_By(Step: longint);
    begin
     Progress_Param(Min,Max,Value+Step);
    end;

   procedure THIndicator.Progress_Param(AMin,AMax,AValue: longint);
     var Area :TRect;
     var Ex,P :longint;
    begin
     Area_Free(Area);
     if (Min < Max) then Ex:=Value * (Area.B.X-Area.A.X) div (Max-Min) else Ex:=Min;
     Value:=AValue;
     Min:=AMin;
     Max:=AMax;
     if (Min < Max) then P:=Value* (Area.B.X-Area.A.X) div (Max-Min) else P:=Min;
     if Ex = P then Exit;
     State_Set(sf_Disabled,P = Min);
     with Area,A do if Ex < P then begin
      B.X:=X+P;
      Inc(X,Ex)
     end else begin
      B.X:=X+Ex;
      Inc(X,P)
     end;
     Draw_Rect(Area)
    end;

   procedure THIndicator.Progress_Range(AMin,AMax:longint);
    begin
     Progress_Param(AMin,AMax,Value)
    end;

   procedure THIndicator.Progress_To(AValue:longint);
    begin
     Progress_Param(Min,Max,AValue)
    end;

   procedure THIndicator.Proc_Paint;
    var
     Area: TRect;
     P: longint;
    begin
     Area_Free(Area);
     if Min < Max then P:= Value*(Area.B.X-Area.A.X) div (Max-Min) else P:=Min;
     with Area, A do begin
      if P > 0 then begin
       SetFillStyle(SolidFill,Color);
       Bar(X,Y,X+Pred(P),B.Y);
      end;
      SetFillStyle(SolidFill,Style_Palette^.Color[3]);
      Bar(X+P,Y,B.X,B.Y)
     end;
     inherited Proc_Paint;
    end;

   function THIndicator.Style_Palette;
    begin
     Style_Palette:=@Palette_Indicator
    end;

{Реализация класса Вертикального Индикатора (VIndecator) }
{---------------------------------------------------------------------------}

   procedure TVIndicator.Progress_Param(AMin,AMax,AValue: longint);
     var Area :TRect;
     var Ex,P :longint;
    begin
     Area_Free(Area);
     if (Min < Max) then Ex:=Value * (Area.B.Y-Area.A.Y) div (Max-Min) else Ex:=Min;
     Value:=AValue;
     Min:=AMin;
     Max:=AMax;
     if (Min < Max) then P:=Value* (Area.B.Y-Area.A.Y) div (Max-Min) else P:=Min;
     if Ex = P then Exit;
     State_Set(sf_Disabled,P = Min);
     with Area,B do if Ex < P then begin
      A.Y:=Y-P;
      Dec(Y,Ex)
     end else begin
      A.Y:=Y-Ex;
      Dec(Y,P)
     end;
     Draw_Rect(Area)
    end;

   procedure TVIndicator.Proc_Paint;
    var
     Area: TRect;
     P: longint;
    begin
     Area_Free(Area);
     if Min < Max then P:= Value*(Area.B.Y-Area.A.Y) div (Max-Min) else P:=Min;
     with Area, B do begin
      if P > 0 then begin
       SetFillStyle(SolidFill,Color);
       Bar(A.X,B.Y-Pred(P),X,Y);
      end;
      SetFillStyle(SolidFill,Style_Palette^.Color[3]);
      Bar(A.X,A.Y,X,Y-P)
     end;
     TView.Proc_Paint;
    end;

{Реализация класса Линейка Страниц (PageBar) }
{---------------------------------------------------------------------------}

{Методы Обработки (Proc)}

   procedure TPageBar.Proc_Paint;
     var Area: TRect;
    begin
     Area_Free(Area);
     SetFillPattern(Pattern_PageBar,Style_Palette^.Color[3]);
     SetFillStyle(USerFill,0);
     with Area do Bar(A.X,A.Y,B.X,B.Y);
     TView.Proc_Paint
    end;

{Методы определения Стиля (Style) окна}

   function TPageBar.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_PageBar
    end;

{Реализация класса Горизонтального Рельса (Rils) Ползунка(PageBar) }
{---------------------------------------------------------------------------}
{Методы Обработки (Proc)}

   procedure THRail.Proc_Paint;
     var Area: TRect;
    begin
     Area_Free(Area);
     inherited Proc_Paint;
     with Style_Palette^, Area do begin
      SetFillPattern(Pattern_HRail,Color[3]);
      SetFillStyle(UserFill,Color[3]);
      A.Y:=(B.Y+A.Y) div 2-1;
      Bar(A.X,A.Y+4,B.X,B.Y);
      B.Y:=A.Y+2;
      S3D_Body(Area,-1,Color[5])
     end;
    end;

{Методы определения Стиля (Style) окна}

   function THRail.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Rail
    end;

{Реализация класса Вертикального Рельса (Rils) Ползунка(PageBar) }
{---------------------------------------------------------------------------}
{Методы Обработки (Proc)}

   procedure TVRail.Proc_Paint;
     var Area: TRect;
    begin
     inherited Proc_Paint;
     Area_Free(Area);
     with Style_Palette^, Area do begin
      SetFillPattern(Pattern_VRail,Color[3]);
      SetFillStyle(UserFill,Color[3]);
      A.X:=(B.X+A.X) div 2-1;
      Bar(A.X+4,A.Y,B.X,B.Y);
      B.X:=A.X+2;
      S3D_Body(Area,-1,Color[5])
     end;
    end;

{Методы определения Стиля (Style) окна}

   function TVRail.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Rail
    end;

{Реализация класса Ползунка (Lever) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TLever.Init;
    begin
     inherited Init(Area);
     Event_Mask:=ev_MouseDown
    end;

{Методы создания (New) вспомагательных объектов}

   function TLever.New_Drager;
     var Area,Poligon,Limit: TRect;
    begin
     Area_Get(Area);
     Sibling_Prev^.Area_Get(Poligon);
     longint(Limit.A):=0;
     Limit.B:=Size;
     New_Drager:=New(PDrager,
     Init(Area,Poligon,Limit,dm_DragMove+dm_DragMouse+dm_LimitAll+dm_AutoEsc))
    end;

{Методы Обработки (Proc)}

   procedure TLever.Proc_Event(var E:TEvent);
    function DoDrag: word;
     var
      Area: TRect;
      Drager: PDrager;
     begin
      Drager:=New_Drager;
      if Parent^.Child_Exec(Drager) = cm_Ok then begin
       Drager^.Area_Get(Area);
       Area_Set(Area);
      end;
      Drager^.Free;
      Event_Clr(E)
     end;
    begin
     inherited Proc_Event(E);
     if E.What = ev_MouseDown then DoDrag
    end;

   procedure TLever.Proc_Paint;
     var Area: TRect;
    begin
     Area_Free(Area);
     with Style_Palette^ do
     S3D_Body(Area,Metric_Lever+byte(State and sf_Active <> 0) ,Color[3]);
     inherited Proc_Paint
    end;

   procedure TLever.Proc_State;
    begin
     inherited Proc_State(AState,On);
     if AState = sf_Active then Draw;
    end;

{Методы определения Стиля (Style) окна}

   function TLever.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Lever
    end;


{Реализация класса Ползунка (Slider) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TSlider.Init;
    begin
     inherited Init(Area);
     Options:=of_AutoHide or AOptions;
     Event_Mask:=Event_Mask or (ev_Mouse+ev_KeyDown)
    end;

{Методы создания (New) вспомагательных объектов}


   function TSlider.New_Lever(const Area: TRect):PView;
    begin
     New_Lever:=New(PLever,Init(Area))
    end;

{Методы Обработки (Proc)}

   procedure TSlider.Proc_Area(const Area: TRect);
     var Rect: TRect;
    begin
     inherited Proc_Area(Area);
     Lever_Area(Rect);
     Lever_Locate(Rect)
    end;

   procedure TSlider.Proc_Event(var E:TEvent);
     var Step: integer;
    begin
     inherited Proc_Event(E);
     if State and sf_Active <> sf_Not then case E.What of
      ev_Broadcast:
       case E.Command of
        cm_Forw: Power_By(AtStep);
        cm_Back: Power_By(-AtStep);
        else Exit
       end;
      ev_Notify:
       if (E.Command = cm_Locate) and (E.InfoPtr = Child_Last) then begin
        Value:=Power_Value;
        Lever_Check
       end else Exit;
      ev_MouseDown:
       begin
        Child_Last^.Point_Local(E.Where,E.Where);
        with E.Where do if (X < 0) or (Y < 0) then Step:=-PgStep
        else Step:=PgStep;
        repeat
         with Application^.Indicator^ do if (Child_Last = Self_Ptr)
         or (PView(Self_Ptr)^.Sibling_Next = Child_Last) then Power_By(Step);
         Event_Get(ev_MouseAuto+ev_MouseUp,E)
        until E.Buttons = 0
       end;
      else Exit
     end;
     Event_Clr(E)
    end;

   procedure TSlider.Proc_State(AState: word; On: boolean);
    begin
     inherited Proc_State(AState,On);
     case AState of
      sf_Focused:
       Event_Set(ev_KeyDown,On);
      sf_Active:
       begin
        Event_Set(ev_MouseDown+ev_KeyDown,On);
        if Options and of_AutoHide <> of_Not then
        State_Set(sf_Visible, On and (Min < Max))
       end;
      sf_Present: Lever_Check;
      sf_NoBack: Comm_Enable(cm_Back,not On);
      sf_NoForw: Comm_Enable(cm_Forw,not On)
     end
    end;

{Методы настройки Прокрутки (Scroll)}

   procedure TSlider.Power_By(Step: longint);
    begin
     Power_To(Value+Step);
    end;

   procedure TSlider.Lever_Check;
    begin
     State_Set(sf_NoBack,Value <= Min);
     State_Set(sf_NoForw,Value >= Max);
     if Options and of_AutoHide <> of_Not then
     State_Set(sf_Visible, (Min < Max) and (State and sf_Active <> sf_Not));
     Message(Parent,ev_Broadcast,cm_Scroll,@Self);
    end;

   procedure TSlider.Power_Param(AMin,AMax,AValue,APgStep,AAtStep: longint);
    begin
     PgStep:=APgStep;
     AtStep:=AAtStep;
     if (Min = AMin) and (Max = AMax) and (Value = AValue)
     and (PgStep = APgStep) then Exit;
     Min:=AMin;
     Max:=AMax;
     Power_To(Value)
    end;

   procedure TSlider.Power_Range(AMin,AMax:longint);
    begin
     Power_Param(AMin,AMax,Value,PgStep,AtStep)
    end;

   procedure TSlider.Power_Step(APgStep,AAtStep:integer);
    begin
     Power_Param(Min,Max,Value,APgStep,AAtStep)
    end;

   procedure TSlider.Power_To(AValue:longint);
     var Area: TRect;
    begin
     if AValue < Min then AValue:=Min;
     if AValue > Max then AValue:=Max;
     Value:=AValue;
     Lever_Area(Area);
     Lever_Locate(Area);
     Lever_Check
    end;

{Методы управления Ползунком (Lever)}

   procedure TSlider.Lever_Area;
    begin
     RunError(err_Abstract)
    end;

   procedure TSlider.Lever_Locate;
     var Save_Mask: word;
    begin
     Save_Mask:=Event_Mask;
     Event_Mask:=0;
     Child_Last^.Area_Set(Area);
     Event_Mask:=Save_Mask;
    end;

   function TSlider.Power_Value: longint;
    begin
     RunError(err_Abstract)
    end;

{Методы определения Стиля (Style) окна}

   function TSlider.Style_Palette;
    begin
     Style_Palette:=@Palette_Slider
    end;


{Реализация класса Горизонтальной Ползунка (НSlider) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor THSlider.Init;
    begin
     TSlider.Init(Area,AOPtions);
     Area_Free(Area);
     if Child_Ins(New_Rail(Area)) <> nil then
     Child_Last^.GrowMode:=gm_GrowHiX+gm_GrowHiY;
     Area.B.X:=Area.A.X+Size.Y div 2;
     if Child_Ins(New_Lever(Area)) <> nil then
     Child_Last^.GrowMode:=gm_GrowHiY;
     Options:=OPtions or of_Selectable
    end;

{Методы создания (New) вспомагательных объектов}

   function  THSlider.New_Rail(const Area: TRect):PView;
    begin
     New_Rail:=New(PHRail,Init(Area))
    end;

{Методы Обработки (Proc)}

   procedure THSlider.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     if (State and sf_Active = sf_Not) or (E.What <> ev_KeyDown) then Exit;
     case E.AbsKey.Code of
      kb_Left :  Power_By(-AtStep);
      kb_Right:  Power_By(AtStep);
      kb_Home :  if Min < Value then Power_By(Min-Value);
      kb_End  :  if Max > Value then Power_By(Max-Value);
      kf_Ctrl+kb_Left :  Power_By(-PgStep);
      kf_Ctrl+kb_Right:  Power_By(PgStep);
      else Exit
     end;
     Event_Clr(E)
    end;

{Методы управления Ползунком (Lever)}

   procedure THSlider.Lever_Area(var Area: TRect);
    begin
     with Child_Last^,Size,Sibling_Prev^,Area do begin
      Area_Get(Area);
      if Max > Min then A.X:=Origin.X+(Size.X-X)*(Value-Min) div (Max-Min);
      B.X:=A.X+X
     end
    end;

   function THSlider.Power_Value: longint;
    begin
     with Child_Last^.Sibling_Prev^ do if Size.X <= Child_Last^.Size.X then Power_Value:=0 else
     Power_Value:=(Child_Last^.Origin.X-Origin.X)*(Max-Min) div (Size.X-Child_Last^.Size.X)+Min
    end;

{Реализация класса Вертикальной Ползунка (HSlider) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TVSlider.Init;
    begin
     inherited Init(Area,AStyle);
     Area_Free(Area);
     if Child_Ins(New_Rail(Area)) <> nil then
     Child_Last^.GrowMode:=gm_GrowHiX+gm_GrowHiY;
     Area.B.Y:=Area.A.Y+Size.X div 2;
     if Child_Ins(New_Lever(Area)) <> nil then
     Child_Last^.GrowMode:=gm_GrowHiY;
     Options:=of_Selectable
    end;

{Методы создания (New) вспомагательных объектов}

   function TVSlider.New_Rail(const Area: TRect):PView;
    begin
     New_Rail:=New(PVRail,Init(Area))
    end;

{Методы Обработки (Proc)}

   procedure TVSlider.Proc_Event(var E: TEvent);
    begin
     inherited Proc_Event(E);
     if (State and sf_Active = sf_Not) or (E.What <> ev_KeyDown) then Exit;
     case E.AbsKey.Code of
      kb_Up  :  Power_By(-AtStep);
      kb_Down:  Power_By(AtStep);
      kb_PgUp:  Power_By(-PgStep);
      kb_PgDn:  Power_By(PgStep);
      kf_Ctrl+kb_PgUp:  Power_By(Min-Value);
      kf_Ctrl+kb_PgDn:  Power_By(Max-Value);
      else Exit
     end;
     Event_Clr(E)
    end;

{Методы управления Ползунком (Lever)}

   procedure TVSlider.Lever_Area;
    begin
     with Child_Last^,Size, Sibling_Prev^ ,Area do begin
      Area_Get(Area);
      if Max > Min then A.Y:=Origin.Y+(Size.Y-Y)*(Value-Min) div (Max-Min);
      B.Y:=A.Y+Y
     end
    end;

   function TVSlider.Power_Value: longint;
    begin
     with Child_Last^.Sibling_Prev^ do if Size.Y <=Child_Last^.Size.Y then Power_Value:=0 else
     Power_Value:=(Child_Last^.Origin.Y-Origin.Y)*(Max-Min) div (Size.Y-Child_Last^.Size.Y)+Min
    end;

{Реализация класса Горизонтальной Линейка Прокрутки (НScrollBar) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor THScrollBar.Init;
     var
      Rect: TRect;
    begin
     TSlider.Init(Area,AOptions);
     State:=State or sf_NoCorner;
     Area_Free(Area);
     Rect:=Area;
     with Rect do begin
      A.X:=B.X;
      Inc(B.X,Metric_ScrollBar.X+1)
     end;
     if Child_Ins(New_Corner(Rect)) <> nil then
     Child_Last^.GrowMode:=gm_GrowLoX+gm_GrowHiY;
     Rect:=Area;
     with Rect do A.X:=B.X-Child_Last^.Size.X;
     if Child_Ins(New_KeyForw(Rect)) <> nil then
     with Child_Last^ do  begin
      GrowMode:=gm_GrowLoX+gm_GrowHiY;
      Dec(Area.B.X,Succ(Size.X));
     end;
     Rect:=Area;
     with Rect do B.X:=A.X+Metric_ScrollBar.X;
     if Child_Ins(New_KeyBack(Rect)) <> nil then
     Inc(Area.A.X,Succ(Child_Last^.Size.X));
     if Child_Ins(New_Rail(Area)) <> nil then
     Child_Last^.GrowMode:=gm_GrowHiX+gm_GrowHiY;
     Area.B.X:=Area.A.X+Metric_ScrollBar.X;
     if Child_Ins(New_Lever(Area)) <> nil then
     Child_Last^.GrowMode:=gm_GrowHiY
    end;

{Методы работы с Областью (Area) отображения}

   procedure THScrollBar.Area_Limit(var Limit: TRect);
    begin
     inherited Area_Limit(Limit);
     if (State and sf_NoCorner <> sf_Not) and (Child_Ind(Child_Last) = 5)
     then Inc(Limit.A.X,Child_First^.Size.X)
    end;

{Методы управления Ползунком (Lever)}

   procedure THScrollBar.Lever_Area;
    begin
     with Child_Last^.Sibling_Prev^,Area do begin
      Area_Get(Area);
      B.X:=Max-Min+PgStep;
      if B.X > 0 then B.X:=PgStep * Size.X div B.X
      else B.X:=Metric_ScrollBar.X;
      if B.X < Metric_ScrollBar.X then B.X:=Metric_ScrollBar.X;
      if B.X > Size.X then B.X:=Size.X;
      if Max > Min then Inc(A.X,(Size.X-B.X)*(Value-Min) div (Max-Min));
      Inc(B.X,A.X)
     end
    end;

{Методы создания (New) вспомагательных объектов}

   function THScrollBar.New_KeyBack(const Area: TRect):PView;
    begin
     with PView(New(PKey,InitAuto(Area,Symbol[4],cm_Back)))^ do begin
      Options:=Options or of_VertDir;
      New_KeyBack:=Self_Ptr
     end
    end;

   function THScrollBar.New_KeyForw(const Area: TRect):PView;
    begin
     with PView(New(PKey,InitAuto(Area,Symbol[5],cm_Forw)))^ do begin
      Options:=Options or of_VertDir;
      New_KeyForw:=Self_Ptr
     end
    end;

   function THScrollBar.New_Corner(const Area: TRect):PView;
    begin
     New_Corner:=New(PPanel,Init(Area))
    end;

   function THScrollBar.New_Rail(const Area: TRect):PView;
    begin
     New_Rail:=New(PPageBar,Init(Area))
    end;

{Методы Обработки (Proc)}

   procedure THScrollBar.Proc_State(AState: word; On: boolean);
     var Delta :TPoint;
    procedure DoCorner(View: PView); far;
     begin
      View^.Area_Calc(Delta)
     end;
    begin
     inherited Proc_State(AState,On);
     if AState = sf_NoCorner then with Delta do begin
      Scr_Lock;
      Y:=0;
      X:=-Child_Last^.Sibling_Next^.Size.X;
      if On then X:=-X;
      Child_For(@DoCorner);
      Power_To(Value);
      Draw;
      Scr_UnLock
     end
    end;

{Методы определения Стиля (Style) окна}

   function THScrollBar.Style_Palette;
    begin
     Style_Palette:=@Palette_ScrollBar
    end;


{Реализация класса Вертикальной Линейка Прокрутки (VScrollBar) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TVScrollBar.Init;
    var
     Rect: TRect;
     D: integer;
    begin
     TSlider.Init(Area,AOptions);
     State:=State or sf_NoCorner;
     Area_Free(Area);
     Rect:=Area;
     with Rect do begin
      A.Y:=B.Y;
      Inc(B.Y,Metric_ScrollBar.Y+1)
     end;
     if Child_Ins(New_Corner(Rect)) <> nil then
     Child_Last^.GrowMode:=gm_GrowLoY+gm_GrowHiX;
     Rect:=Area;
     with Rect do A.Y:=B.Y-Metric_ScrollBar.Y;
     if Child_Ins(New_KeyForw(Rect)) <> nil then
     with Child_Last^ do begin
      GrowMode:=gm_GrowLoY+gm_GrowHiX;
      Dec(Area.B.Y,Succ(Size.Y))
     end;
     Rect:=Area;
     with Rect do B.Y:=A.Y+Metric_ScrollBar.Y;
     if Child_Ins(New_KeyBack(Rect)) <> nil then
     Inc(Area.A.Y,Succ(Child_Last^.Size.Y));
     if Child_Ins(New_Rail(Area)) <> nil then
     Child_Last^.GrowMode:=gm_GrowHiX+gm_GrowHiY;
     Area.B.Y:=Area.A.Y+Metric_ScrollBar.Y;
     if Child_Ins(New_Lever(Area)) <> nil then
     Child_Last^.GrowMode:=gm_GrowHiX
    end;

{Методы работы с Областью (Area) отображения}

   procedure TVScrollBar.Area_Limit(var Limit: TRect);
    begin
     inherited Area_Limit(Limit);
     if (State and sf_NoCorner <> sf_Not) and (Child_Ind(Child_Last) = 5)
     then Inc(Limit.A.Y,Child_First^.Size.Y)
    end;

{Методы управления Ползунком (Lever)}

   procedure TVScrollBar.Lever_Area;
    begin
     with Child_Last^.Sibling_Prev^,Area do begin
      Area_Get(Area);
      B.Y:=Max-Min+PgStep;
      if B.Y > 0 then B.Y:=PgStep * Size.Y div B.Y
      else B.Y:=Metric_ScrollBar.Y;
      if B.Y < Metric_ScrollBar.Y then B.Y:=Metric_ScrollBar.Y;
      if B.Y > Size.Y then B.Y:=Size.Y;
      if Max > Min then Inc(A.Y,(Size.Y-B.Y)*(Value-Min) div (Max-Min));
      Inc(B.Y,A.Y)
     end
    end;

{Методы создания (New) вспомагательных объектов}

   function TVScrollBar.New_Corner(const Area: TRect):PView;
    begin
     New_Corner:=New(PPanel,Init(Area))
    end;

   function TVScrollBar.New_KeyBack(const Area: TRect):PView;
    begin
     New_KeyBack:=New(PKey,InitAuto(Area,Symbol[4],cm_Back))
    end;

   function TVScrollBar.New_KeyForw(const Area: TRect):PView;
    begin
     New_KeyForw:=New(PKey,InitAuto(Area,Symbol[5],cm_Forw))
    end;

   function TVScrollBar.New_Rail(const Area: TRect):PView;
    begin
     New_Rail:=New(PPageBar,Init(Area))
    end;

{Методы Обработки (Proc)}

   procedure TVScrollBar.Proc_State(AState: word; On: boolean);
    var
     Area :TRect;
    procedure DoCorner(View: PView); far;
     begin
      View^.Area_Calc(Area.A)
     end;
    begin
     inherited Proc_State(AState,On);
     if AState = sf_NoCorner then with Area.A do begin
      X:=0;
      Y:=-Child_Last^.Sibling_Next^.Size.Y;
      if On then Y:=-Y;
      Scr_Lock;
      Child_For(@DoCorner);
      Power_To(Value);
      Scr_UnLock
     end
    end;

{Методы определения Стиля (Style) окна}

   function TVScrollBar.Style_Palette;
    begin
     Style_Palette:=@Palette_ScrollBar
    end;


   var

     ProcInit: procedure;

   procedure InitMetrics; far;
     var X,Y: word;
    begin
     ProcInit;
     GetAspectRatio(X,Y);
     Font_Style(Font_TitleBar,HorizDir);
     Metric_TitleBar.Y:=TextWidth('T')*2;
     Metric_TitleBar.X:=Round(X * Metric_TitleBar.Y div Y);
     Metric_Edit:=Metric_Box;
     Metric_Frame.X:=Metric_Box.X div 5;
     Metric_Frame.Y:=Metric_Box.Y div 5;
     Metric_ScrollBar:=Metric_Box;
     Metric_Button:=2;
     Metric_Key:=1;
     Metric_Lever:=1;
    end;

  begin
   ProcInit:=Metric_Init;
   Metric_Init:=InitMetrics
  end.