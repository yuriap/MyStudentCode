 {      ┌───────────────────────────────────────────┐
        │                                           │
        │          E a s t   S t u d i o            │
        │                                           │
        │           U D i a l o g   4.0             │
        │                                           │
        │       Copyright (c)  S.Novak  1996        │
        │             (054) 33-35-94                │
        │                                           │
        │            (implementation)               │
        │                                           │
        └───────────────────────────────────────────┘      }

 {$I INC\UCONTROL.INC}

 implementation

  uses

   UGraph, Dos, Strings;

{Реализация класса Прeссора (Pressor) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TPressor.Init;
    begin
     inherited Init(Area);
     Text:=Str_New(AText);
    end;

   destructor TPressor.Done;
    begin
     inherited Done;
     Str_Dsp(Text)
    end;

 {Методы для Оработки (Do) событий) }

   procedure TPressor.Do_MouseDown(var E: TEvent);
    begin
     repeat
      if Application^.Indicator = @Self then begin
       State_Set(sf_Down,True);
       if (Options and of_AutoPress <> of_None) then Pressed
      end else State_Set(sf_Down,False);
      Event_Get(ev_MouseAuto+ev_MouseUp,E)
     until (E.Buttons = 0) or (sf_Disabled in State);
     Event_Clr(E);
     if not (sf_Down in State) then Exit;
     State_Set(sf_Down,False);
     if Options and of_AutoPress = of_None then Pressed
    end;

{Методы для управления Событиями (Event)}

   function  TPressor.Event_Mask: word;
    begin
     Event_Mask:=ev_MouseDown + ev_MouseMove;
    end;

{Методы для установки (On) Состояний}

  procedure TPressor.On_Disabled(On: boolean);
   begin
    inherited On_Disabled(On);
    Draw
   end;

  procedure TPressor.On_Down(On: boolean);
   begin
    Draw
   end;

{Действие по нажаитю (Pressed)}

   procedure TPressor.Pressed;
    begin
     Event_Send(Parent,ev_Notify,cm_Pressed,@Self)
    end;

{Методы определения Стиля (Style) окна}

   function TPressor.Style_Cursor: PMouseCursor;
    begin
     if not (sf_Disabled in State) then Style_Cursor:=@Cursor_Hand
     else Style_Cursor:=inherited Style_Cursor
    end;

{Методы управления Текстом (Text)}

   procedure TPressor.Text_Set(const AText: string);
    begin
     Str_Dsp(Text);
     Text:=Str_New(AText);
     Draw
    end;

{Реализация класса Клавиш (Key) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init)}

   constructor TKey.Init;
    begin
     inherited Init(Area,AText);
     Options:=Options or of_XXXX;
     Command:=cm_XXXX;
    end;

{Методы управления Холстом (Canvas)}

   procedure TKey.Canvas_Paint;
    var
     TextColor,H,C: integer;
     D: TPoint;
     Area: TRect;
    begin
     Canvas_Frame;
     if Options and of_VertDir <> 0 then
     SetTextStyle(SysFont_Style,VertDir,SysFont_Size);
     SetTextJustify(CenterText,CenterText);
     Area_Free(Area);
     D.X:=Size.X div 2;
     D.Y:=size.Y div 2;
     H:=1;
     if sf_Down in State then begin
      Inc(longint(D),$00010001);
      Dec(H)
     end;
     if sf_Disabled in State then C:=8 else C:=6;
     with Style_Palette^ do begin;
      S3D_Body(Area,H,Color[3]);
      S3D_Str(D.X,D.Y,Text^,Color[C])
     end
    end;

{Методы для контроля над Командами (Comm) }

   procedure TKey.Comm_Audit;
    begin
     if cm_XXXX = Command then State_Set(sf_Disabled,not On)
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TKey.HelpCtx_Get: word;
    begin
     HelpCtx_Get:=Command
    end;

{Действие по нажаитю (Pressed)}

   procedure TKey.Pressed;
     var E: TEvent;
    begin
     if Options and of_AutoPress = of_None then begin
      E.What:=ev_Command;
      E.Command:=Command;
      E.InfoPtr:=@Self;
      Event_Put(E)
     end else Event_Send(Parent,ev_Notify,Command,@Self)
    end;

{Методы определения Стиля (Style) окна}

   function TKey.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Key
    end;


{Реализация класса Кнопок (Button) }
{---------------------------------------------------------------------------}
   const

    Button_Def : PButton = nil;

{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TButton.Init;
    begin
     inherited Init(Area,AText,cm_XXXX,of_Border);
     Char_Mask:=Char_DefMask
    end;

   constructor TButton.InitDef;
    begin
     Init(Area,AText,cm_XXXX);
     Options:=Options or of_Default;
    end;

{Методы управления Холстом (Canvas)}

   procedure TButton.Canvas_Paint;
    var
     TextColor,Dir,H,C: integer;
     D: TPoint;
     Area: TRect;
    begin
     Canvas_Frame;
     Area_Free(Area);
     D.X:=(Size.X-HotStr_Width(Text^)) div 2;
     D.Y:=(Size.Y+TextHeight(Text^)) div 2;
     H:=2;
     if sf_Down in State then begin
      Inc(longint(D),$00010001);
      if H > 1 then Dec(H) else H:=-1
     end;
     if sf_Disabled in State then C:=8 else C:=6;
     with Style_Palette^ do begin
      if State_Get([sf_Default]) then begin
       S3D_Rect(Area,1,Color[1]);
       Area.Grow(-1,-1)
      end;
      S3D_Body(Area,H,Color[3]);
      S3D_HotStr(D.X,D.Y,Text^,Color[C])
     end;
    end;

{Методы для Оработки (Do) событий) }

   procedure TButton.Do_KeyDown(var E: TEvent);
     var Ch :char;
    begin
     Ch:=HotStr_Ch(Text^);
     with E,AbsKey,SysKey do
     if (Char_Mask and kb_Char <> 0)
     and (UpCase(Char) in ([Ch]-[#0]))
     or State_Get([sf_Default]) and ((Code = kb_Space) or (Code = kb_Enter))
     or (Flag and Char_Mask <> 0) and (Scan = Char_Scan(Ch))
     then Pressed else Exit;
     Event_Clr(E)
    end;

   procedure TButton.Do_Idle;
    begin
     if (Options and of_Default = 0) or not (sf_Active in State)
     or (Button_Def <> nil) or (sf_Disabled in State) then Exit;
     State_Set(sf_Default,True)
    end;

{Методы для управления Событиями (Event)}

   function  TButton.Event_Mask: word;
     var Mask:word;
    begin
     Mask:=ev_MouseDown+ev_MouseMove+ev_KeyDown+ev_Idle;
     Event_Mask:=Mask
    end;

{Методы для установки (On) Состояний}

   procedure TButton.On_Default(On: boolean);
    begin
     if On then begin
      Button_Def^.State_Set(sf_Default,False);
      Button_Def:=@Self
     end else Button_Def:=nil;
     Draw
    end;

   procedure TButton.On_Disabled(On: boolean);
    begin
     inherited On_Disabled(On);
     if On then State_Set(sf_Default, False)
    end;

   procedure TButton.On_Focus(On: boolean);
    begin
     State_Set(sf_Default,On);
    end;

   procedure TButton.On_Active(On: boolean);
    begin
     if (sf_Disabled in State) or (Options and of_Default = 0 ) then Exit;
     State_Set(sf_Default,On);
    end;

{Методы определения Стиля (Style) окна}

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
     Options:=of_Glass;
     Char_Mask:=Char_DefMask;
     Command:=cm_Check
    end;

   constructor TCheckBox.InitOn(const Area: TRect; const AText: string);
    begin
     Init(Area,Atext);
     Pressed
    end;

{Методы работы с Областью (Area) отображения}

   procedure TCheckBox.Area_Check(var Area: TRect);
    begin
     Area_Local(Area);
     Area.B.X:=Metric_Box.X;
    end;

   procedure TCheckBox.Area_Mark;
     var H,W: integer;
    begin
     Canvas_Frame;
     H:=TextHeight(Text^)+4;
     W:=HotStr_Width(Text^);
     Area.Open(TextWidth('W')*3,(Size.Y-H) div 2,W,H)
    end;

{Методы управления Холстом (Canvas)}

   procedure TCheckBox.Canvas_Paint;
    var
     TextColor,Dir,H,C: integer;
     D: TPoint;
     Area: TRect;
    begin
     Canvas_Frame;
     Area_Free(Area);
     D.Y:=(Size.Y+TextHeight(Text^)) div 2;
     if sf_Down in State then begin
      Inc(longint(D),$00010001);
      H:=-1
     end else H:=0;
     if sf_Disabled in State then C:=8 else C:=6;
     with Style_Palette^ do begin;
      S3D_Body(Area,H,Color[3]);
      S3D_HotStr(TextWidth('   '),D.Y,Text^,Color[C]);
      if sf_Check in State then C:=10 else C:=12;
      S3D_HotStr(0,D.Y,' '+Style_Symbol,Color[C])
     end;
    end;

{Методы обработки "Галочки" (Check)}

   function TCheckBox.Check_Get: byte;
    begin
     Check_Get:=byte(sf_Check in State);
    end;

{Методы для обмена Данных (Data) }

   function TCheckBox.Data_Proc;
    begin
     if ds_XXXX then boolean(Data):=sf_Check in State else
     State_Set(sf_Check,boolean(Data));
     Data_Proc:=SizeOf(boolean)
    end;

{Методы для Оработки (Do) событий) }

   procedure TCheckBox.Do_KeyDown(var E: TEvent);
     var Ch: char;
    begin
     Ch:=HotStr_Ch(Text^);
     with E,AbsKey,SysKey do
     if (Char_Mask and kb_Char <> 0) and (UpCase(Char) = Ch)
     or (sf_Focus in State) and (Code = kb_Space)
     or (Flag and Char_Mask <> 0) and (Scan = Char_Scan(Ch))
     then Pressed else Exit;
     Event_Clr(E)
    end;

{Методы для управления Событиями (Event)}

   function  TCheckBox.Event_Mask: word;
    begin
     Event_Mask:=ev_MouseDown+ev_MouseMove+ev_KeyDown
    end;

{Методы для установки (On) Состояний}

   procedure TCheckBox.On_Check;
     var Area: TRect;
    begin
     Area_Check(Area);
     Draw_Rect(Area)
    end;

{Действие по нажаитю (Pressed)}

   procedure TCheckBox.Pressed;
     var E: TEvent;
    begin
     State_Set(sf_Check, not (sf_Check in State));
     if (Command = 0) or not (sf_Check in State) then Exit;
     E.What:=ev_Command;
     E.Command:=Command;
     E.InfoBool:=True;
     Event_Put(E)
    end;

{Методы определения Стиля (Style) окна}

   function TCheckBox.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_CheckBox
    end;

   function TCheckBox.Style_Symbol: char;
    begin
     Style_Symbol:=UView.Symbol[8]
    end;


{Реализация класса Кнопок с зависимой фиксацией (RadioBox) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TRadioBox.Init;
    begin
     inherited Init(Area,AText);
     Master:=AMaster;
     Options:=Options or of_Glass
    end;

   constructor TRadioBox.InitOn;
    begin
     Init(Area,AText,AMaster);
     Pressed
    end;

   constructor TRadioBox.InitAuto;
    begin
     Init(Area,AText,AMaster);
     Options:=Options or of_AutoCheck
    end;

{Методы для Оработки (Do) событий) }

   procedure TRadioBox.Do_RadioOff(var E: TEvent);
    begin
     if not (sf_Check in State) or (E.InfoPtr <> Master) then Exit;
     Event_Clr(E);
     Pressed
    end;

{Методы для управления Событиями (Event)}

   function  TRadioBox.Event_Mask: word;
     var Mask: word;
    begin
     Mask:=ev_MouseDown+ev_KeyDown+ev_Command;
     if (Options and of_AutoCheck = 0) or (sf_Focus in State)
     then Mask:=Mask or ev_Mouse;
     Event_Mask:=Mask
    end;

{Методы для установки (On) Состояний}

   procedure TRadioBox.On_Selected(On: boolean);
    begin
     inherited On_Selected(On);
     if not (sf_Check in State) then Pressed
    end;

{Действие по нажаитю (Pressed)}

   procedure TRadioBox.Pressed;
    begin
     if not (sf_Check in State)
     then Event_Send(Parent,ev_Command,cm_RadioOff,Master);
     inherited Pressed
    end;

{Методы определения Стиля (Style) окна}

   function TRadioBox.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_RadioBox
    end;

   function TRadioBox.Style_Symbol: char;
    begin
     if sf_Check in State then Style_Symbol:=Symbol[12]
     else Style_Symbol:=Symbol[11]
    end;


{Реализация класса Сенсоров (Sensor) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TSensor.Init(const Area: TRect);
    begin
     inherited Init(Area);
     Options:=Options or of_NoSelect
    end;

{Методы для контроля над Командами (Comm) }

   procedure TSensor.Comm_Audit(cm_XXXX: word; On: boolean);
    begin
     if cm_XXXX = Command then State_Set(sf_Disabled,not On)
    end;

{Методы для Оработки (Do) событий) }

   procedure TSensor.Do_MouseDown(var E: TEvent);
    begin
     if (Options and of_DoublePress = 0) and E.Double then Exit;
     Event_Clr(E);
     Pressed
    end;

{Методы для управления Событиями (Event)}

   function  TSensor.Event_Mask: word;
    begin
     Event_Mask:=ev_MouseDown+ev_MouseMove
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TSensor.HelpCtx_Get: word;
    begin
     HelpCtx_Get:=Command
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


{Реализация класса "Уголок" (Corner) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TCorner.Init;
    begin
     inherited Init(Area);
     Command:=cm_XXXX;
     Options:=Options or of_XXXX
    end;

{Методы управления Холстом (Canvas)}

   procedure TCorner.Canvas_Paint;
     var Area: TRect;
    begin
     if Options and of_Glass = 0 then with Style_Palette^ do begin
      Area_Free(Area);
      SetFillStyle(9,Color[3]);
      with Area do Bar(A.X,A.Y,B.X,B.Y);
     end;
     Canvas_Frame
    end;

{Методы определения Стиля (Style) окна}

   function TCorner.Style_Cursor: PMouseCursor;
    begin
     if sf_Disabled in State then Style_Cursor:=inherited Style_Cursor
     else Style_Cursor:=@Cursor_SizeNS
    end;

   function  TCorner.Style_Palette;
    begin
     Style_Palette:=@Palette_Corner
    end;


{Реализация класса Заглавие (TitleBar) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TTitle.Init;
    begin
     inherited Init(Area);
     Command:=cm_XXXX;
     Text:=Str_New(AText);
    end;

   destructor TTitle.Done;
    begin
     inherited Done;
     Str_Dsp(Text)
    end;

{Методы управления Холстом (Canvas)}

   procedure TTitle.Canvas_Paint;
    var
     D: integer;
     Pos: TPoint;
     Area: TRect;
     S: integer;
    begin
     Canvas_Frame;
     if sf_Active in State then D:=0 else D:=4;
     Pos.X:=(Size.X-TextWidth(Text^)) div 2;
     if Pos.X < 2 then Pos.X:=2;
     Pos.Y:=(Size.Y+TextHeight(Text^)) div 2;
     Area_Free(Area);
     with Style_Palette^ do begin
      S3D_Body(Area,1,Color[3+D]);
      SetColor(Color[6+D]);
      if Text <> nil then OutTextXY(Pos.X,Pos.Y,Text^);
     end
    end;

{Методы для установки (On) Состояний}

   procedure TTitle.On_Active;
    begin
     Draw
    end;

{Методы определения Стиля (Style) окна}

   function TTitle.Style_Cursor: PMouseCursor;
    begin
     if sf_Disabled in State then Style_Cursor:=inherited Style_Cursor
     else Style_Cursor:=@Cursor_Size
    end;

   function TTitle.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_TitleBar
    end;

{Методы управления Текстом (Text)}

   procedure TTitle.Text_Set(const AText: string);
    begin
     Str_Dsp(Text);
     Text:=Str_New(AText);
     Draw
    end;

{Реализация класса "Рамки" (Frame) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TFrame.Init;
    begin
     inherited Init(Area);
     Command:=cm_XXXX;
     Options:=Options or of_Border;
     Thick:=AThick
    end;

{Методы управления Холстом (Canvas)}

   procedure TFrame.Canvas_Paint;
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
      if Options and of_Border = of_None then Exit;
      with Delta do Area.Grow(-X,-Y);
      S3D_Rect(Area,-1,Color[4]);
     end;
     Canvas_Frame
    end;

{Методы определения Стиля (Style) окна}

   function TFrame.Style_Cursor: PMouseCursor;
    begin
     if sf_Disabled in State then Style_Cursor:=inherited Style_Cursor
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
     Char_Mask:=Char_DefMask;
     Text:=Str_New(AText);
     Options:=Options or of_NoSelect
    end;

   constructor TLabel.InitPack;
    begin
     Init(Area,AText);
     Size.X:=HotStr_Width(Text^);
     Size.Y:=Metric_Box.Y div 2;
    end;

   destructor TLabel.Done;
    begin
     inherited Done;
     Str_Dsp(Text)
    end;

{Методы управления Холстом (Canvas)}

   procedure TLabel.Canvas_Paint;
     var Area: TRect;
    begin
     Canvas_Frame;
     with Style_Palette^ do begin
      if Options and of_Glass = 0 then  begin
       Area_Free(Area);
       SetFillStyle(SolidFill,Color[3]);
       with Area do Bar(A.X,A.Y,B.X,B.Y)
      end;
      S3D_HotStr(0,TextHeight(Text^),Text^,Color[4])
     end
    end;

{Методы для Оработки (Do) событий) }

   procedure TLabel.Do_MouseDown(var E: TEvent);
    begin
     if Master^.Focus then Event_Clr(E)
    end;

   procedure TLabel.Do_KeyDown(var E: TEvent);
     var Ch: Char;
    begin
     Ch:=HotStr_Ch(Text^);
     if Ch = #0 then Exit;
     with E,AbsKey,SysKey do
     if ((Char_Mask and kb_Char <> 0) and (UpCase(Char) = Ch))
     or ((Flag and Char_Mask <> 0) and (Scan = Char_Scan(Ch))) then
     if Master^.Focus then Event_Clr(E);
    end;

{Методы для управления Событиями (Event)}

   function  TLabel.Event_Mask: word;
    begin
     Event_Mask:=ev_MouseDown+ev_KeyDown
    end;

   function TLabel.Master: PView;
    begin
     Master:=Sibling_Next
    end;

{Методы определения Стиля (Style) окна}

   function TLabel.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Label
    end;

{Методы управления Текстом (Text)}

   procedure TLabel.Text_Set(const AText: string);
    begin
     Str_Dsp(Text);
     Text:=Str_New(AText);
     Draw
    end;

{Реализация класса Индикатора (Indecator) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TIndicator.Init(const Area :TRect; AColor: byte);
   begin
    inherited Init(Area);
    Options:=Options or of_Border or of_NoSelect;
    Color:=AColor;
   end;

{Методы управления Холстом (Canvas)}

  procedure TIndicator.Canvas_Paint;
   begin
    if Size.X < Size.Y then  VPaint else HPaint;
    Canvas_Frame
   end;

{Методы для обмена Данных (Data) }

  function TIndicator.Data_Proc(var Data; ds_XXXX :boolean): word;
   begin
    if ds_XXXX then Value_Set(single(Data)) else single(Data):=Value;
    Data_Proc:=SizeOf(Value)
   end;

  {Методы для управления Событиями (Event)}

   function  TIndicator.Event_Mask: word;
    begin
     if Data_Ptr <> nil then Event_Mask:=ev_Command else Event_Mask:=0
    end;

{Методы установки знаачения(Value)}

   procedure TIndicator.Value_Set(AValue: single);
    begin
     if Size.X <  Size.Y then VValue_Set(AValue) else HValue_Set(AValue)
    end;

{Личные методы}

   procedure TIndicator.HValue_Set;
    var
     Area :TRect;
     Ex,P :longint;
    begin
     Area_Free(Area);
     Ex:=Round(Value*(Area.B.X-Area.A.X));
     Value:=AValue;
     if Value < 0 then Value:=0 else if Value > 1 then Value:=1;
     P:=Round(Value*(Area.B.X-Area.A.X));
     if Ex = P then Exit;
     with Area,A do if Ex < P then begin
      B.X:=X+P;
      Inc(X,Ex)
     end else begin
      B.X:=X+Ex;
      Inc(X,P)
     end;
     Draw_Rect(Area)
    end;

   procedure TIndicator.VValue_Set;
    var
     Area :TRect;
     Ex,P :longint;
    begin
     Area_Free(Area);
     Ex:=Round(Value*(Area.B.Y-Area.A.Y));
     Value:=AValue;
     if Value < 0 then Value:=0 else if Value > 1 then Value:=1;
     P:=Round(Value* (Area.B.Y-Area.A.Y));
     if Ex = P then Exit;
     with Area,B do if Ex < P then begin
      A.Y:=Y-P;
      Dec(Y,Ex)
     end else begin
      A.Y:=Y-Ex;
      Dec(Y,P)
     end;
     Draw_Rect(Area)
    end;

   procedure TIndicator.HPaint;
    var
     Area: TRect;
     P: longint;
    begin
     Area_Free(Area);
     P:= Round(Value*(Area.B.X-Area.A.X));
     with Area, A do begin
      if P > 0 then begin
       SetFillStyle(SolidFill,Color);
       Bar(X,Y,X+P,B.Y);
      end;
      SetFillStyle(SolidFill,Style_Palette^.Color[3]);
      Bar(X+P,Y,B.X,B.Y)
     end;
    end;

   procedure TIndicator.VPaint;
    var
     Area: TRect;
     P: longint;
    begin
     Area_Free(Area);
     P:= Round(Value*(Area.B.Y-Area.A.Y));
     with Area, B do begin
      if P > 0 then begin
       SetFillStyle(SolidFill,Color);
       Bar(A.X,B.Y-Pred(P),X,Y);
      end;
      SetFillStyle(SolidFill,Style_Palette^.Color[3]);
      Bar(A.X,A.Y,X,Y-P)
     end;
    end;

{Методы определения Стиля (Style) окна}

   function TIndicator.Style_Palette;
    begin
     Style_Palette:=@Palette_Indicator
    end;


{Реализация класса  (TRemark) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TRemark.Init;
    begin
     inherited Init(Area);
     Options:=Options or of_NoSelect or of_XXXX;
     Text:=Str_New(AText);
     Grid_Calc
    end;

   destructor TRemark.Done;
    begin
     inherited Done;
     Str_Dsp(Text)
    end;

{Методы работы с Областью (Area) отображения}

   procedure TRemark.Area_Proc(const Area: TRect);
    begin
     inherited Area_Proc(Area);
     Grid_Calc
    end;

{Методы управления Холстом (Canvas)}

   procedure TRemark.Canvas_Paint;
     var Area: TRect;
    begin
     Canvas_Frame;
     with Style_Palette^, Area do begin
      Area_Free(Area);
      SetFillStyle(SolidFill,Color[3]);
      Bar(A.X,A.Y,B.X,B.Y);
      if Options and of_VCenter <> 0 then
      Inc(A.Y,Round((B.Y-A.Y-(Grid.Y+1/3)*TextHeight(Text^)* 3/2)/2));
      OutTextRect(Grow(0,-TextHeight(Text^) div 2)^,Text^,Color[4]);
     end;
    end;

   procedure TRemark.Grid_Calc;
     var I,B,E: integer;
    begin
     Grid.X:=Size.X;
     if Options and of_Left <> 0 then Dec(Grid.X);
     if Options and of_Right <> 0 then Dec(Grid.X);
     Grid.X:=Grid.X div TextWidth('W');
     Grid.Y:=0;
     B:=1;
     while B < byte(Text^[0]) do begin
      if Text^[B] = #3 then Inc(B);
      E:=B;
      I:=B;
      while (I <= byte(Text^[0])) and (Text^[I] <> #13) and (I-B <= Grid.X) do begin
       if Text^[I] = #32 then E:=I;
       Inc(I);
      end;
      if (Text^[I] = #13) or (E = B) or (I > byte(Text^[0])) then E:=I;
      if Text^[E] in [#32,#13] then B:=E+1 else B:=E;
      Inc(Grid.Y)
     end;
    end;

{Методы определения Стиля (Style) окна}

   function TRemark.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Remark
    end;

{Методы управления Текстом (Text)}

   procedure TRemark.Text_Set(const AText: string);
     var Area:TRect;
    begin
     if Text^ = AText then Exit;
     Str_Dsp(Text);
     Text:=Str_New(AText);
     Grid_Calc;
     Draw
    end;


{Реализация объекта Реплики (Phrase)}
{--------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TPhrase.Init(APos: TPoint; const AText,AColor: string);
    var Area: TRect;
   begin
    with Area do begin
     longint(A):=0;
     B.X:=Round(byte(AText[0])/Sqrt(byte(Atext[0])))*2;
     if B.X < 10 then B.X:=10;
     B.X:=B.X*Metric_Box.X+4;
     inherited Init(Area,AText,of_VCenter);
     Size.Y:=Grid.Y*Metric_Box.Y * 3 div 4+4;
    end;
    Origin.X:=APos.X-Size.X+Metric_Box.X;
    if Origin.X < 0 then Origin.X:=APos.X-Metric_Box.X;
    Origin.Y:= APos.Y-Size.Y;
    if Origin.Y < 0 then Origin.Y:=APos.Y;
    Options:=Options or of_NoSelect+of_Shadow+of_Border;
    Color:=Str_New(AColor);
   end;

  destructor TPhrase.Done;
   begin
    inherited Done;
    Str_Dsp(Color)
   end;

{Методы для Оработки (Do) событий) }

  procedure TPhrase.Do_KeyDown(var E: TEvent);
   begin
    Dlg_Stop(cm_Idle);
    Event_Put(E);
    Event_Clr(E)
   end;

  procedure TPhrase.Do_MouseDown(var E: TEvent);
   begin
    Dlg_Stop(cm_Idle);
    Event_Put(E);
    Event_Clr(E)
   end;

{Методы для управления Событиями (Event)}

  function TPhrase.Event_Mask: word;
   begin
    Event_Mask:=ev_KeyDown+ev_MouseDown
   end;

{Методы определения Стиля (Style) окна}

  function  TPhrase.Style_Palette: PPalette;
   begin
    Style_Palette:=pointer(Color)
   end;


{Реализация класса Строки Ввода (InputBar) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TEdit.Init(Area: TRect; AForm: TForm; of_XXXX: word);
    begin
     inherited Init(Area);
     Options:=Options or of_XXXX;
     Area_Free(Area);
     with Child_Ins(New(PView,Init(Area)))^ do Options:=Options or of_Border+of_NoSelect;
     Form:=AForm;
     MaxLen:=Form_Lng;
     Text:=''
    end;

{Проверка Аитибута (Attr)}

   procedure TEdit.Attr_Valid(var A:TAttr; var S: string);
     var VisLn: integer;
    begin
     VisLn:=Text_Vis;
     if A.Curr < 0 then A.Curr:=0 else
     if A.Curr > byte(S[0]) then A.Curr:=byte(S[0]);
     if A.Curr > A.Pos + VisLn then A.Pos:=A.Curr-VisLn;
     if A.Curr < A.Pos then A.Pos:=A.Curr;
     if A.Home < 0 then A.Home:=0;
     if A.Home > byte(S[0]) then A.Home:=byte(S[0]);
    end;

   procedure TEdit.Attr_Set(var SAttr: TAttr; var  SText: string);
    begin
    if not Text_Valid(SAttr,SText) then Exit;
     Attr_Valid(SAttr,SText);
     Attr:=SAttr;
     Text:=SText;
     Child_First^.Draw
    end;

{Методы для обмена Данных (Data) }

   function TEdit.Data_Proc(var Data; ds_XXXX :boolean): word;
    var
     Code,Pos,Lng: integer;
     Buff: string;
    begin
     if ds_XXXX then Lng:=Form_Do(Buff,Data,Code)
     else Lng:=Form_UnDo(Buff,Pos,Code);
     if Code <> 0 then Err_Proc(Pos,Code) else begin
      if not ds_XXXX then begin
       Move(Buff,Data,Lng);
       Form_Do(Buff,Data,Code);
      end;
      Text_Set(Buff)
     end;
     Data_Proc:=Lng
    end;

{Методы для Оработки (Do) событий) }


   procedure TEdit.Do_KeyDown(var E: TEvent);

    procedure Char_Edit;
     var
      SText: string;
      SAttr :TAttr;
     begin
      SAttr:=Attr;
      SText:=Text;
      with SAttr,E,AbsKey,SysKey do begin
       if Curr <> Home then Text_Delete(SAttr,SText);
       Inc(Curr);
       Inc(Home);
       if Application^.KeyBoard^.Status^ and ks_InsertOn <> 0
       then Delete(SText,Curr,1);
       Insert(Char,SText,Curr);
      end;
      Attr_Set(SAttr,SText)
     end;

    procedure Char_Delete;
     var
      SAttr: TAttr;
      SText: string;
     begin
      if Options and of_ReadOnly <> 0 then Exit;
      SText:=Text;
      SAttr:=Attr;
      with SAttr,E.AbsKey do begin
       if Curr = Home then if Code = kb_Back then Dec(Curr) else Inc(Home);
       Text_Delete(SAttr,SText)
      end;
      Attr_Set(SAttr,SText)
     end;

    begin
     with Attr do case E.AbsKey.Code of
      kb_Ins: Child_First^.Draw;
      kb_Home: Text_Cursor(-Curr);
      kb_End: Text_Cursor(byte(Text[0])-Curr);
      kb_Left: Text_Cursor(-1);
      kb_Right: Text_Cursor(+1);
      kb_Home+kb_Shift: Text_Select(Home,0);
      kb_End+kb_Shift: Text_Select(Home,byte(Text[0]));
      kb_Left+kb_Shift: Text_Select(Home,Curr-1);
      kb_Right+kb_Shift: Text_Select(Home,Curr+1);
      kb_Enter: if not Text_Entry then Exit;
      kb_Enter+kb_Ctrl: Text_Save;
      kb_Enter+kb_Shift: if Options and of_ReadOnly = 0 then Text_Ins(Clipboard);
      kb_Del,kb_Back: Char_Delete;
      else if Options and of_ReadOnly = 0 then
      case E.SysKey.Char of
       ' '..#255 : Char_Edit;
       ^Y : Text_Set('');
       else Exit
      end else Exit;
     end;
     Event_Clr(E);
    end;

   procedure TEdit.Do_MouseDown(var E: TEvent);
    var
     Org: TPoint;
     H: integer;
    begin
     inherited Do_MouseDown(E);
     if (Options and of_ReadOnly <> 0 )
     or (Application^.Indicator <> Child_First) then Exit;
     if E.Double then Text_Select(byte(Text[0]),0)
     else with Child_First^ do begin
      longint(Org):=0;
      Point_Global(Org,Org);
      H:=TextWidth(' ');
      Text_Cursor((E.Where.X-Org.X) div H + Attr.Pos-Attr.Curr);
      with Attr do repeat
       Text_Select(Home,(E.Where.X-Org.X) div H + Pos);
       Event_Get(ev_MouseMove+ev_MouseUp,E)
      until E.Buttons = 0
     end;
    end;

   procedure TEdit.Do_ChildPaint;
    var
     W,H,O,Z: Integer;
     Area: TRect;
     S: string;

    procedure Cursor(AX,AY: integer);
      var H: byte;
     begin
      if Application^.KeyBoard^.Status^ and ks_InsertOn = 0
      then H:=0 else H:=1;
      SetFillStyle(1,Style_Palette^.Color[5]);
      Bar(AX,AY,AX+W,AY+H)
     end;

    begin
     with Style_Palette^, Child_First^ do begin
      if Ptr <> E.InfoPtr then Exit;
      Canvas_Frame;
      Area_Free(Area);
      SetFillStyle(SolidFill,Color[3]);
      with Area do Bar(A.X,A.Y,B.X,B.Y);
      W:=TextWidth(' ');
      H:=(Size.Y+TextHeight('W')) div 2;
      Area.Grow(-1,-1);
      SetColor(Color[5]);
      if sf_Focus in Self.State then with Area,Attr do begin
       O:=A.X+(Home-Pos)*W;
       Z:=A.X+(Curr-Pos)*W;
       if Home < Curr then begin
        if A.X < O then A.X:=O;
        if B.X > Z then B.X:=Z
       end else begin
        if A.X < Z then A.X:=Z;
        if B.X > O then B.X:=O
       end;
       SetFillStyle(SolidFill,Color[4]);
       with Area do Bar(A.X,A.Y,B.X,B.Y);
       if Self.Options and of_ReadOnly = 0 then Cursor(Z,H);
      end;
      if Password = #0 then OutTextXY(3,H,Copy(Text,Attr.Pos+1,MaxLen))
      else begin
       byte(S[0]):=byte(Text[0])-Attr.Pos;
       FillChar(S[1],byte(S[0]),Password);
       OutTextXY(3,H,S)
      end;
     end;
     Event_Clr(E)
    end;

{Методы обработки Ошибок (Err)}

   function TEdit.Err_Text(Code: integer): string;
    begin
     Err_Text:=Application^.Msg_Text(Code)
    end;

   procedure TEdit.Err_Proc(Pos, Code: integer);
     var P: TPoint;
    begin
     Focus;
     Text_Cursor(Pos-Attr.Curr-1);
     longint(P):=$00010001;
     with Attr do begin
      Inc(P.X,(Curr-Pos-1)*TextWidth('W'));
      Point_Global(P,P);
      MessageErr(P,#3+Err_Text(Code),Palette_ReplRed)
     end
    end;

{Методы для управления Событиями (Event)}

   function  TEdit.Event_Mask: word;
     var Mask :word;
    begin
     Mask:=ev_MouseDown + ev_Notify + ev_Command;
     if sf_Focus in State then Inc(Mask,ev_KeyDown);
     Event_Mask:=Mask
    end;

{Методы для форматирования (Form) текста}

   function TEdit.Form_Do(var Buff: string; const Data; var Cod: integer): byte;
    procedure RealPut(R:extended; Data_Size: byte);
     begin
      Form_Do:=Data_Size;
      if Form[0] < #2 then Str(R,Buff) else
      if Form[0] < #3 then Str(R:byte(Form[2]),Buff)
      else Str(R:byte(Form[2]):byte(Form[3]),Buff);
     end;
    procedure IntPut(I:longint; Data_Size: byte);
     begin
      Form_Do:=Data_Size;
      if Form[0] < #2 then Str(I,Buff) else Str(I:byte(Form[2]),Buff);
     end;
    begin
     Form_Do:=0;
     Cod:=0;
     if (Form[0] <> #0) then case Form[1] of
      ^T: begin Form_Do:=MaxLen; Buff:=string(Data) end;
      ^T: begin Form_Do:=MaxLen; Buff:=StrPas(@Data) end;
      ^N: RealPut(single(Data),SizeOf(single));
      ^R: RealPut(real(Data),SizeOf(Real));
      ^E: RealPut(extended(Data),SizeOf(extended));
      ^D: RealPut(double(Data),SizeOf(double));
      ^C: RealPut(comp(Data),SizeOf(comp));
      ^I: IntPut(integer(Data),SizeOf(integer));
      ^L: IntPut(longint(Data),SizeOf(longint));
      ^B: IntPut(byte(Data),SizeOf(byte));
      ^S: IntPut(shortint(Data),SizeOf(shortint));
      ^W: IntPut(word(Data),SizeOf(word))
      else Cod:=-2
     end;
    end;

   function TEdit.Form_Lng: byte;
    begin
     if (Form[0] = #2) and (Form[1] in [^A,^T]) then
     Form_Lng:=byte(Form[2]) else Form_Lng:=255;
    end;

   function TEdit.Form_UnDo(var Buff; var Pos,Code: integer): byte;
    var
     Res: extended;
     Execp: TException;
    begin
     Form_UnDo:=0;
     Code:=0;
     if (Form[0] = #0) then Exit;
     case Form[1] of
      ^T :
       begin
        string(Buff):=Text;
        Form_UnDo:=MaxLen
       end;
      ^A :
       begin
        StrPCopy(@Buff,Text);
        Form_UnDo:=MaxLen
       end;
      else begin
       Calculator(Text,Res,Code,Pos);
       if Code <> 0 then Exit;
       Execp.Try;
       if ExitCode = 0 then case Form[1] of
        ^N: begin single(Buff):=Res; Form_UnDo:=SizeOf(single) end;
        ^R: begin real(Buff):=Res; Form_UnDo:=SizeOf(real) end;
        ^E: begin extended(Buff):=Res; Form_UnDo:=SizeOf(extended) end;
        ^D: begin double(Buff):=Res; Form_UnDo:=SizeOf(double) end;
        ^C: begin comp(Buff):=Res; Form_UnDo:=SizeOf(comp) end;
        ^I: begin integer(Buff):=Round(Res); Form_UnDo:=SizeOf(integer) end;
        ^L: begin longint(Buff):=Round(Res); Form_UnDo:=SizeOf(longint) end;
        ^B: begin byte(Buff):=Round(Res); Form_UnDo:=SizeOf(byte) end;
        ^W: begin word(Buff):=Round(Res); Form_UnDo:=SizeOf(word) end;
        ^S: begin shortint(Buff):=Round(Res); Form_UnDo:=SizeOf(shortint) end;
        else Code:=-2
       end else Code:=ExitCode;
       Execp.Fail
      end
     end
    end;

{Методы Контекста Помощи (HelpCtx)}

   function TEdit.HelpCtx_Get: word;
    begin
     HelpCtx_Get:=HelpCtx
    end;

{Методы Проверки (Valid) команд}

   function TEdit.Valid_Cancel :boolean;
    begin
     Valid_Cancel:=True
    end;

   function TEdit.Valid_Ok;
    var
     Buff: string;
     Code,Pos: integer;
    begin
     if Options and of_ReadOnly <> 0 then Code:=0 else Form_UnDo(Buff,Pos,Code);
     if Code <> 0 then Err_Proc(Pos,Code);
     Valid_Ok:= Code = 0
    end;

{Методы для установки (On) Состояний}

   procedure TEdit.On_Focus(On: boolean);
    begin
     inherited On_Focus(On);
     if On then Text_Select(byte(Text[0]),0);
     Child_First^.Draw
    end;

   procedure TEdit.On_Present(On: boolean);
    begin
     inherited On_Present(On);
      if On then Attr_Valid(Attr,Text);
    end;

{Методы определения Стиля (Style) окна}

   function TEdit.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Edit
    end;

{Методы управления Текстом (Text)}

   procedure TEdit.Text_Cursor(D: integer);
     var Save: TAttr;
    begin
     if Options and of_ReadOnly <> 0 then begin
      Text_Scroll(D);
      Exit
     end;
     Save:=Attr;
     Inc(Attr.Curr,D);
     Attr.Home:=Attr.Curr;
     Attr_Valid(Attr,Text);
     if longint(Save) <> longint(Attr) then Child_First^.Draw
    end;

   procedure TEdit.Text_Delete(var SAttr: TAttr; var SText: string);
     var D: integer;
    begin
     with SAttr do begin
      D:=Home-Curr;
      if D < 0 then Curr:=Home else Home:=Curr;
      Delete(SText,Curr+1,Abs(D));
      Attr_Set(SAttr,SText)
     end;
     Event_Send(Parent,ev_Notify,cm_TextChg,@Self)
    end;

   function TEdit.Text_Entry;
    begin
     Text_Entry:=Event_Send(Parent,ev_Notify,cm_TextEnt,@Self) <> nil
    end;

   procedure TEdit.Text_Ins;
    var
     SText: string;
     SAttr: TAttr;
     D: integer;
    begin
     SText:=Text;
     SAttr:=Attr;
     with SAttr do begin
      D:=Home-Curr;
      if D < 0 then Curr:=Home else Home:=Curr;
      Delete(SText,Curr+1,Abs(D));
      Insert(S,SText,Curr+1);
      Home:=Curr+byte(S[0]);
      Attr_Set(SAttr,SText)
     end;
     Event_Send(Parent,ev_Notify,cm_TextChg,@Self)
    end;

   procedure TEdit.Text_Save;
     var P: byte;
    begin
     with Attr do begin
      if Curr = Home then Exit;
      if Curr < Home then P:=Curr else P:=Home;
      Clipboard:=Copy(Text,P+1,Abs(Attr.Home-Attr.Curr));
     end
    end;

   procedure TEdit.Text_Scroll(D: integer);
     var VisLn: integer;
    begin
     Inc(D,Attr.Pos);
     VisLn:=Text_Vis;
     if byte(Text[0]) <= VisLn+D then D:=byte(Text[0])-VisLn;
     if D < 0 then D:=0;
     if Attr.Pos = D then Exit;
     Attr.Pos:=D;
     Child_First^.Draw
    end;

   procedure TEdit.Text_Select(H,C: integer);
     var Save: TAttr;
    begin
     if Options and of_ReadOnly <> 0 then Exit;
     Save:=Attr;
     Attr.Curr:=C;
     Attr.Home:=H;
     Attr_Valid(Attr,Text);
     if longint(Save) <> longint(Attr) then Child_First^.Draw
    end;

   procedure TEdit.Text_Set(S: string);
    begin
     if Text = S then Exit;
     with Attr do begin
      Curr:=0;
      Pos:=0;
      Home:=Byte(S[0]);
     end;
     if not Text_Valid(Attr,S) then Exit;
     Attr_Set(Attr,S);
     Event_Send(Parent,ev_Notify,cm_TextChg,@Self)
    end;

   function  TEdit.Text_Valid(var A: TAttr; var S :string): boolean;
    begin
     Text_Valid:=byte(S[0]) <= MaxLen
    end;

   function TEdit.Text_Vis: byte;
    begin
     Text_Vis:=Size.X div TextWidth(' ')-1
    end;


{Реализация класса Часы (Clock) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

   constructor TDial.Init(Area: TRect);
    begin
     inherited Init(Area);
     Options:=Options or of_Border
    end;

{Методы прорисовки Стрелок (Arrow)}

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

{Методы управления Холстом (Canvas)}

   procedure TDial.Canvas_Paint;
    var
     I,R,D:integer;
     P,C: TPoint;
     Area: TRect;
    begin
     Canvas_Frame;
     Area_Free(Area);
     SetFillStyle(SolidFill,Style_Palette^.Color[3]);
     with Area, A do Bar(X,Y,B.X,B.Y);
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

{Методы для Оработки (Do) событий) }

   procedure TDial.Do_Idle(var E: TEvent);
    var
     AHour, AMinute, ASecond, Sec100: Word;
     D: integer;
     Area: TRect;
    begin
     GetTime(AHour,AMinute,ASecond,Sec100);
     AHour:=((AHour * 60) + AMinute) div 12;
     if ASecond = Second then Exit;
     Area_Local(Area);
     with Area do begin
      D:=(B.X-B.Y) div 2;
      if D < 0 then begin
       Dec(A.Y,D);
       Inc(B.Y,D);
      end else begin
       Inc(A.X,D);
       Dec(B.X,D);
      end
     end;
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

{Методы для управления Событиями (Event)}

   function  TDial.Event_Mask: word;
    begin
     Event_Mask:=ev_Idle
    end;

{Методы определения Стиля (Style) окна}

   function TDial.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Dial
    end;


{Реализация класса Графика (Graph) }
{---------------------------------------------------------------------------}

   function Lg(X :real) :real;
    begin
     if X = 0 then Lg:=0 else Lg:=Ln(X)/Ln(10)
    end;

   function Pow  (X :real; Y :real) :real;
    begin
     Pow:=Exp(Y*Ln(Abs(X)));
    end;

{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TGraph.Init(Area: TRect;const ANames:string; NX,NY: integer; of_XXXX: word);
   begin
    inherited Init(Area);
    Font_Style(Font_Graph,HorizDir);
    GrowMode:=GrowMode or (gm_GrowHiX+gm_GrowHiY);
    Options:=Options or of_XXXX;
    Area_Free(Area);
    Inc(Area.A.Y,Metric_Box.Y);
    Dec(Area.B.Y,Metric_Box.Y+TextHeight('0'));
    Inc(Area.A.X,TextWidth('0') * (8));
    Dec(Area.B.X,Metric_Box.X div 2);
    with Child_Ins(New(PView,Init(Area)))^ do begin
     GrowMode:=GrowMode or gm_GrowHiY+gm_GrowHiX;
     Options:=Options or of_Glass;
    end;
    Name:=Str_New(ANames);
    Range.X:=NX;
    Range.Y:=NY
   end;

  destructor TGraph.Done;
   begin
    if Table <> nil then FreeMem(Table,Range.Y*Range.X*SizeOf(real));
    Str_Dsp(Name);
    inherited Done
   end;

{Методы работы с Областью (Area) отображения}

  procedure TGraph.Area_Proc(const Area: TRect);
    var D: real;
   begin
    inherited Area_Proc(Area);
    if Table = nil then Exit;
    Metric_Scale;
    Metric_Step
   end;

{Методы управления Холстом (Canvas)}

  procedure TGraph.Canvas_Paint;
    var
     Area: TRect;
     S,L: string;
     R,EX,EY: real;
     I,N,P: integer;
   begin
    Area_Free(Area);
    with Style_Palette^ do begin
     SetFillStyle(SolidFill, Color[3]);
     with Area, A do Bar(X,Y,B.X,B.Y);
     with Child_First^ do if Table <> nil then begin
      SetColor(Color[6]);
      SetTextStyle(SysFont_Style,HorizDir,SysFont_Size);
      N:=Pos(';',Name^);
      L:=Copy(Name^,1,N-1);
      SetTextJustify(RightText,BottomText);
      if (Options and of_NoHInd = 0) and  (EPow.X <> 0) then begin
       Str(-EPow.X,S);
       S:=S+'.';
       OutTextXY(Origin.X+Size.X-TextWidth(L+S),Self.Size.Y,'10');
       OutTextXY(Origin.X+Size.X-TextWidth(L),Self.Size.Y-4,S);
       S:='10'+S;
      end else S:='';
      OutTextXY(Origin.X+Size.X,Self.Size.Y,L);
      L:=Copy(Name^,N+1,25);
      SetTextJustify(LeftText,BottomText);
      if (Options and of_NoVInd = 0) and (EPow.Y <> 0) then begin
       Str(-EPow.Y,S);
       OutTextXY(Origin.X,Origin.Y-1,'10');
       S:=S+'.';
       OutTextXY(Origin.X+TextWidth('10'),Origin.Y-4,S);
       S:='10'+S
      end else S:='';
      OutTextXY(Origin.X+TextWidth(S),Origin.Y-1,L);
      Style_Font;
      if Options and of_NoHInd = 0 then begin
       SetTextJustify(LeftText,TopText);
       EX:=Pow(10,-EPow.X);
       for I:=Trunc(Table^[Min.X]/Step.X) to Trunc(Table^[Max.X]/Step.X) do begin
        R:=I*Step.X;
        P:=SX(R);
        R:=R*EX;
        Str(R:0:3,S);
        if (P >= 0) and (P+TextWidth(S) <= Size.X)
        then OutTextXY(Origin.X+P,Origin.Y+Size.Y+1,S);
       end;
      end;
      if Options and of_NoVInd = 0 then begin
       SetTextJustify(RightText,TopText);
       EY:=Pow(10,-EPow.Y);
       for I:=Trunc(Table^[Min.Y]/Step.Y) to Trunc(Table^[Max.Y]/Step.Y) do begin
        R:=I*Step.Y;
        P:=SY(R);
        R:=R*EY;
        Str(R:8:3,S);
        if (P <= Size.Y) and (P >= TextHeight(S))
        then OutTextXY(Origin.X-2,Origin.Y+P-10,S);
       end;
      end
     end
    end;
    inherited Canvas_Paint;
   end;

{Методы для обмена Данных (Data) }

  function TGraph.Data_Proc(var Data; ds_XXXX: boolean): word;
    var Count: word;
   begin
    Count:=Range.Y*Range.X*SizeOf(real);
    if ds_XXXX then begin
     if Table = nil then GetMem(Table,Count);
     Move(Data,Table^,Count);
     Metric_Limit;
     Metric_Scale;
     Metric_Step;
     Draw;
    end else Move(Table^,Data,Count);
    Data_Proc:=Count;
   end;

{Методы для Оработки (Do) событий) }

  procedure TGraph.Do_ChildPaint(var E: TEvent);
   var
    Area: TRect;
    I,J,N: integer;
   begin
    with Style_Palette^, Child_First^,Area, A do begin
     Area_Free(Area);
     SetColor(Color[5]);
     if Options and of_Glass = 0 then begin
      SetFillStyle(SolidFill,Color[3]);
      Bar(X,Y,B.X,B.Y);
     end;
     Rectangle(X,Y,B.X,B.Y);
     SetColor(Color[4]);
     if Table <> nil then for J:=1 to Range.Y-1 do begin
      SetColor(Color[4]);
      if Options and of_NoVGrid = 0 then
      for I:=Trunc(Table^[Min.X]/Step.X) to Trunc(Table^[Max.X]/Step.X) do begin
       N:=SX(I*Step.X);
       Line(N,0,N,Size.Y);
      end;
      if Options and of_NoHGrid = 0 then
      for I:=Trunc(Table^[Min.Y]/Step.Y) to Trunc(Table^[Max.Y]/Step.Y) do begin
       N:=SY(I*Step.Y);
       Line(0,N,Size.X,N);
      end;
      SetColor(Color[5]);
      Line(Axis.X,0,Axis.X,Size.Y);
      Line(0,Axis.Y,Size.X,Axis.Y);
      SetColor(Color[6+J]);
      MoveTo(SX(Table^[0]),SY(Table^[J]));
      for I:=0 to Range.X-1 do begin
       N:=I*Range.Y;
       LineTo(SX(Table^[N]),SY(Table^[N+J]))
      end
     end;
     Canvas_Frame
    end;
   end;

{Методы для управления Событиями (Event)}

  function TGraph.Event_Mask: word;
   begin
    Event_Mask:=ev_Command + ev_Notify;
   end;

{Методы определения Стиля (Style) окна}

  procedure TGraph.Style_Font;
   begin
    Font_Style(Font_Graph,HorizDir);
    SetTextJustify(LeftText,BottomText)
   end;

  function  TGraph.Style_Palette: PPalette;
   begin
    Style_Palette:=@Palette_Graph;
   end;

{Личные методы класса}

  procedure TGraph.Metric_Limit;
   var
    I,J,N,M: integer;
   begin
    Min.X:=0;
    Max.X:=0;
    Max.Y:=1;
    Min.Y:=1;
    for N:=0 to Range.X-1 do begin
     I:=N*Range.Y;
     if Table^[I] < Table^[Min.X] then Min.X:=I;
     if Table^[I] > Table^[Max.X] then Max.X:=I;
     for J:=1 to Range.Y-1 do begin
      M:=I+J;
      if Table^[M] < Table^[Min.Y] then Min.Y:=M;
      if Table^[M] > Table^[Max.Y] then Max.Y:=M;
     end
    end
   end;

  procedure TGraph.Metric_Scale;
   begin
    with Child_First^ do begin
     if Max.X = Min.X then begin
      Scale.X:= 1;
      Axis.X:=Size.X div 2
     end else  begin
      Scale.X:=Size.X/(Table^[Max.X]-Table^[Min.X]);
      Axis.X:=-Round(Table^[Min.X]*Scale.X);
     end;
     if Max.Y = Min.Y then begin
      Scale.Y:= -1;
      Axis.Y:=Size.Y div 2
     end else begin
      Scale.Y:=-Size.Y/(Table^[Max.Y]-Table^[Min.Y]);
      Axis.Y:=-Round(Table^[Max.Y]*Scale.Y)
     end
    end
   end;

  procedure TGraph.Metric_Step;
   const
    ZZ : array[1..12] of real = (0.1, 0.2, 0.25, 0.5, 1, 2, 2.5, 5, 10, 20, 25, 50);
   var
    I: integer;
    R: real;
   begin
    Style_Font;
    Step.X:=(Table^[Max.X]-Table^[Min.X]);
    if Step.X = 0 then Step.X:=Table^[Max.X];
    R:=Size.X/Child_First^.Origin.X;
    EPow.X:=Trunc(Lg(Step.X))-1;
    Step.X:=Step.X*Pow(10,-EPow.X);
    for I:=1 to 12 do if Step.X/ZZ[I] <= R then Break;
    Step.X:=ZZ[I]*Pow(10,EPow.X);
    Step.Y:=(Table^[Max.Y]-Table^[Min.Y]);
    if Step.Y = 0 then Step.Y:=Table^[Max.Y];
    with Child_First^ do  R:=Origin.Y+Size.Y;
    R:=Size.Y/(Size.Y-R);
    EPow.Y:=Trunc(Lg(Step.Y))-1;
    Step.Y:=Step.Y*Pow(10,-EPow.Y);
    for I:=1 to 12 do if Step.Y/ZZ[I] <= R then Break;
    Step.Y:=ZZ[I]*Pow(10,EPow.Y);
    EPow.Y:=Round((EPow.Y+1)/3)*3;
    EPow.X:=Round((EPow.X+1)/3)*3
   end;


  function TGraph.SX(X: real): integer;
   begin
    SX:=Round(X*Scale.X)+Axis.X
   end;

  function TGraph.SY(Y: real): integer;
   begin
    SY:=Round(Y*Scale.Y)+Axis.Y
   end;

{Реализация класса Ползунка (Lever) }
{---------------------------------------------------------------------------}
{Методы управления Холстом (Canvas)}

   procedure TSlider.Canvas_Paint;
     var Area: TRect;
    begin
     Area_Free(Area);
     with Style_Palette^ do
     S3D_Body(Area,1+byte(sf_Active in State) ,Color[3]);
     inherited Canvas_Frame
    end;

{Методы для Оработки (Do) событий) }

   procedure TSlider.Do_MouseDown(var E:TEvent);
    begin
     inherited Do_MouseDown(E);
     Parent^.Child_Exec(New_Drager);
     Event_Clr(E)
    end;

{Методы для управления Событиями (Event)}

   function  TSlider.Event_Mask: word;
    begin
     Event_Mask:=ev_MouseDown
    end;

{Методы создания (New) вспомагательных объектов}

   function TSlider.New_Drager;
     var Desk: TRect;
    begin
     Sibling_Prev^.Area_Get(Desk);
     New_Drager:=New(PDrager,Init(@Self,Desk,
     dm_DragMove+dm_DragMouse+dm_LimitAll+dm_DragEsc))
    end;

{Методы для установки (On) Состояний}

   procedure TSlider.On_Focus;
    begin
     Draw;
    end;

{Методы определения Стиля (Style) окна}

   function TSlider.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Slider
    end;

{Реализация класса Ползунка (Slider) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TSliderBar.Init(Area: TRect; of_XXXX: word);
   begin
    inherited Init(Area);
    Options:=Options or of_XXXX;
    if Size.Y > Size.X then Options:=Options or of_VertDir;
    Area_Free(Area);
    Child_Ins(New_Rail(Area))^.GrowMode:=gm_GrowHiX+gm_GrowHiY;
    if Options and of_VertDir <> 0  then Area.B.Y:=Area.A.Y+Size.X div 2
    else Area.B.X:=Area.A.X+Size.Y div 2;
    with Child_Ins(New_Slider(Area))^ do
    if Options and of_VertDir = 0 then GrowMode:=gm_GrowHiX
    else GrowMode:=gm_GrowHiY;
    with Child_Slider^ do Options:=Options or of_Border;
   end;

{Методы работы с Областью (Area) отображения}

  procedure TSliderBar.Area_Proc(const Area: TRect);
    var Rect: TRect;
   begin
    inherited Area_Proc(Area);
    Slider_Area(Rect);
    Slider_Locate(Rect)
   end;

{Методы работы с дочерными (Child) окнами}

  function  TSliderBar.Child_Rail: PView;
   begin
    Child_Rail:=Child_First
   end;

  function  TSliderBar.Child_Slider: PSlider;
   begin
    Child_Slider:=pointer(Child_Curr)
   end;

{Методы для обмена Данных (Data) }

  function  TSliderBar.Data_Proc(var Data; ds_XXXX :boolean): word;
   begin
    if ds_XXXX then Scroll_To(integer(Data)) else integer(Data):=Value;
    Data_Proc:=SizeOf(Value)
   end;

{Методы для управления Событиями (Event)}

  function  TSliderBar.Event_Mask: word;
    var Mask: word;
   begin
    Mask:=ev_Mouse+ev_Notify+ev_Command;
    if sf_Focus in State then Inc(mask,ev_KeyDown);
    Event_Mask:=Mask
   end;

{Методы Обработки (Proc)}

  procedure TSliderBar.Do_Back(var E: TEvent);
   begin
    Scroll_By(-Step_At);
    Event_Clr(E)
   end;

  procedure TSliderBar.Do_ChildLocate(var E: TEvent);
   begin
    if (E.InfoPtr <> Child_Slider) then Exit;
    Value:=Value_Calc;
    Scroll_Check;
    Event_Clr(E)
   end;

  procedure TSliderBar.Do_Forw(var E: TEvent);
   begin
    Scroll_By(+Step_At);
    Event_Clr(E)
   end;

  procedure TSliderBar.Do_KeyDown(var E:TEvent);
   begin
    if Options and of_VertDir = 0 then case E.AbsKey.Code of
     kb_Left : Scroll_By(-Step_At);
     kb_Right: Scroll_By(+Step_At);
     kb_Home : Scroll_To(Min);
     kb_End  : Scroll_To(Max);
     kb_Ctrl+kb_Left : Scroll_By(-Step_Pg);
     kb_Ctrl+kb_Right: Scroll_By(+Step_Pg);
     kb_Enter: Event_Send(Parent,ev_Command,cm_ScrollEnt,@Self);
     else Exit
    end else case E.AbsKey.Code of
     kb_Up  :  Scroll_By(-Step_At);
     kb_Down:  Scroll_By(+Step_At);
     kb_PgUp:  Scroll_By(-Step_Pg);
     kb_PgDn:  Scroll_By(+Step_Pg);
     kb_Ctrl+kb_PgUp: Scroll_To(Min);
     kb_Ctrl+kb_PgDn: Scroll_To(Max);
     kb_Enter: Event_Send(Parent,ev_Command,cm_ScrollEnt,@Self);
     else Exit
    end;
    Event_Clr(E)
   end;

  procedure TSliderBar.Do_MouseDown(var E:TEvent);
   var
    Step: integer;
    P: TPoint;
   begin
    inherited Do_MouseDown(E);
    if Application^.Indicator <> Child_Rail then Exit;
    Child_Slider^.Point_Local(E.Where,P);
    if (P.X < 0) or (P.Y < 0) then Step:=-Step_Pg else Step:=Step_Pg;
    repeat
     Point_Local(E.Where,P);
     if Point_In(P) then Scroll_By(Step);
     Event_Get(ev_MouseAuto+ev_MouseUp,E)
    until E.Buttons = 0;
    Event_Clr(E)
   end;

{Методы создания (New) вспомагательных объектов}

  function  TSliderBar.New_Slider(const Area: TRect): PSlider;
   begin
    New_Slider:=New(PSlider,Init(Area))
   end;

  function  TSliderBar.New_Rail(const Area: TRect): PView;
    var Panel: PPanel;
   begin
    Panel:=New(PPanel,Init(Area,nil));
    if Options and of_VertDir <> 0 then Panel^.Style_Paint:=Style_VRail
    else Panel^.Style_Paint:=Style_HRail;
    New_Rail:=Panel
   end;

{Meтоды скролингования (Scroll)}

  procedure TSliderBar.Scroll_By(Step: longint);
   begin
    Scroll_To(Value+Step);
   end;

  procedure TSliderBar.Scroll_Check;
   begin
    Comm_Enable(cm_Back, Value > Min);
    Comm_Enable(cm_Forw, Value < Max);
    Event_Send(Parent,ev_Notify,cm_ScrollChg,@Self);
    State_Set(sf_Disabled, Max <= Min)
   end;

  procedure TSliderBar.Scroll_Param;
   begin
    if (Min=AMin)and(Max=AMax)and(Value=AValue)and(Step_Pg=APg) then Exit;
    Min:=AMin;
    Max:=AMax;
    Step_Pg:=APg;
    Step_At:=AAt;
    Scroll_To(AValue)
   end;

  procedure TSliderBar.Scroll_Range(AMin,AMax: longint);
   begin
    if (Min = AMin) and (Max = AMax) then Exit;
    Min:=AMin;
    Max:=AMax;
    Scroll_To(Value)
   end;

  procedure TSliderBar.Scroll_Step(APg,AAt:integer);
   begin
    if (Step_Pg = APg) and (Step_At = AAt) then Exit;
    Step_Pg:=APg;
    Step_At:=AAt;
    Scroll_To(Value)
   end;

  procedure TSliderBar.Scroll_To(AValue: longint);
    var Area: TRect;
   begin
    if AValue < Min then AValue:=Min;
    if AValue > Max then AValue:=Max;
    Value:=AValue;
    Slider_Area(Area);
    Slider_Locate(Area);
    Scroll_Check
   end;

  procedure TSliderBar.Scroll_Value(AValue: longint);
    var Area: TRect;
   begin
    if AValue = Value then Exit;
    Scroll_To(AValue)
   end;

{Методы управления Ползунком (Slider)}

  procedure TSliderBar.Slider_Area(var Area: TRect);
   begin
    with Child_Slider^.Size,Child_Rail^,Area do begin
     Area_Get(Area);
     if Self.Options and of_VertDir = 0 then begin
      if Max > Min then A.X:=Origin.X+Round((Size.X-X)*(Value-Min)/(Max-Min));
      B.X:=A.X+X
     end else begin
      if Max > Min then A.Y:=Origin.Y+Round((Size.Y-Y)*(Value-Min)/(Max-Min));
      B.Y:=A.Y+Y
     end
    end
   end;

  procedure TSliderBar.Slider_Locate(const Area: TRect);
    var Save: TState;
   begin
    Save:=State;
    State:=State + [sf_Disabled];
    Child_Slider^.Area_Set(Area);
    State:=Save;
   end;

{Методы определения Стиля (Style) окна}

  function  TSliderBar.Style_Palette: PPalette;
   begin
    Style_Palette:=@Palette_SliderBar;
   end;

  function  TSliderBar.Value_Calc: longint;
    var Sld: PSlider;
   begin
    Sld:=Child_Slider;
    with Child_Rail^ do if Self.Options and of_VertDir = 0 then
    if Size.X <= Sld^.Size.X then Value_Calc:=0 else
    Value_Calc:=Round((Sld^.Origin.X-Origin.X)*(Max-Min)/(Size.X-Sld^.Size.X))+Min
    else if Size.Y <=Sld^.Size.Y then Value_Calc:=0 else
    Value_Calc:=Round((Sld^.Origin.Y-Origin.Y)*(Max-Min)/(Size.Y-Sld^.Size.Y))+Min
   end;


{Реализация Линейки Протяжки  (ScrollBar) }
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TScrollBar.Init(Area: TRect; of_XXXX: word);
    var D: integer;
   begin
    inherited Init(Area,of_XXXX);
    Area_Free(Area);
    with Area do if Options and of_VertDir = 0 then begin
     D:=Round(Size.Y*Metric_Box.X/Metric_Box.Y);
     if D > Metric_Box.X then D:=Metric_Box.X;
     B.X:=A.X+D;
     Child_Ins(New_KeyBack(Area))^.GrowMode:=gm_GrowHiY;
     Area_Free(Area);
     A.X:=B.X-D;
     Child_Ins(New_KeyForw(Area))^.GrowMode:=gm_GrowHiY+gm_GrowHiX+gm_GrowLoX;
     with Child_Rail^ do begin
      Inc(Origin.X,D);
      Dec(Size.X,2*D);
     end
    end else begin
     D:=Round(Size.X*Metric_Box.Y/Metric_Box.X);
     if D > Metric_Box.Y then D:=Metric_Box.Y;
     B.Y:=A.Y+D;
     Child_Ins(New_KeyBack(Area))^.GrowMode:=gm_GrowHiX;
     Area_Free(Area);
     A.Y:=B.Y-D;
     Child_Ins(New_KeyForw(Area))^.GrowMode:=gm_GrowHiX+gm_GrowHiY+gm_GrowLoY;
     with Child_Rail^ do begin
      Inc(Origin.Y,D);
      Dec(Size.Y,2*D);
     end
    end;
    with Child_Rail^ do Options:=Options or of_Border;
    with Child_Slider^ do Options:=Options or of_Border;
    Scroll_Param(1,1,1,1,1)
   end;

{Методы создания (New) вспомагательных объектов}

  function  TScrollBar.New_KeyBack(const Area: TRect):PView;
   begin
    New_KeyBack:=PView(New(PKey,Init(Area,Symbol[4],cm_Back,of_Border+
    of_AutoPress+of_NoSelect+(of_VertDir xor Options and of_VertDir))));
   end;

  function  TScrollBar.New_KeyForw(const Area: TRect):PView;
   begin
    New_KeyForw:=PView(New(PKey,Init(Area,Symbol[5],cm_Forw,of_Border+
    of_AutoPress+of_NoSelect+(of_VertDir xor Options and of_VertDir))));
   end;

  function  TScrollBar.New_Rail(const Area: TRect):PView;
   begin
    New_Rail:=New(PPanel,Init(Area,Style_Desk));
   end;

{Методы управления Ползунком (Slider)}

   procedure TScrollBar.Slider_Area(var Area: TRect);
     var S: integer;
    begin
     with Child_Rail^,Area do begin
      Area_Get(Area);
      if Max > Min then
      if Self.Options and of_VertDir = 0 then begin
       S:=Round(Step_Pg/(Max-Min+Step_Pg) * Size.X);
       if S < Size.Y then S:=Size.Y;
       if S > Size.X then S:=Size.X;
       A.X:=Origin.X+Round((Size.X-S)*(Value-Min)/(Max-Min));
       B.X:=A.X+S
      end else begin
       S:=Round(Step_Pg/(Max-Min+Step_Pg) * Size.Y);
       if S < Size.X then S:=Size.X;
       if S > Size.Y then S:=Size.Y;
       A.Y:=Origin.Y+Round((Size.Y-S)*(Value-Min)/(Max-Min));
       B.Y:=A.Y+S
      end
     end
    end;

{Методы определения Стиля (Style) окна}

  function  TScrollBar.Style_Palette: PPalette;
   begin
    Style_Palette:=@Palette_ScrollBar
   end;

{Реализация типа TListBox}
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TListBox.Init(const Area: TRect; AList: PCollection; of_XXXX: word);
   begin
    inherited Init(Area);
    Options:=Options or of_XXXX;
    Item_Size:=Metric_Box.Y * 7  div 8;
    with Child_Ins(New_View)^ do GrowMode:=gm_GrowHiY+gm_GrowHiX;
    ScrollBar:=New_ScrollBar;
    ScrollBar^.GrowMode:=gm_GrowHiY+gm_GrowLoX+gm_GrowHiX;
    Child_Ins(ScrollBar);
    List_Set(AList);
   end;

  destructor TListBox.Done;
   begin
    PObject(List)^.Free;
    inherited Done;
   end;

{Методы работы с Областью (Area) отображения}

  procedure TListBox.Area_Proc(const Area: TRect);
    var CountPg: integer;
   begin
    inherited Area_Proc(Area);
    CountPg:=(Size.Y div Item_Size);
    ScrollBar^.Scroll_Param(0,List^.Count-CountPg,1,CountPg,Item_Top)
   end;

{Методы для обмена Данных (Data) }

  function  TListBox.Data_Proc(var Data; ds_XXXX :boolean): word;
   begin
    with TListData(Data) do if ds_XXXX then begin
     List_Set(List);
     Item_Select(Item)
    end else begin
     List:=Self.List;
     Item:=Item_Curr
    end
   end;

{Методы для Оработки (Do) событий) }

  procedure TListBox.Do_ChildPaint;
   var
    Area,Rect: TRect;
    I: integer;
   begin
    with Style_Palette^ , Child_First^, Rect do begin
     if Ptr <> E.InfoPtr then Exit;
     Canvas_Area(Area);
     if Area.Empty then Exit;
     I:=Area.A.Y div Item_Size;
     Area_Free(Rect);
     Inc(A.Y,I*Item_Size);
     B.Y:=A.Y+Item_Size-1;
     Inc(I,Item_Top);
     SetColor(Color[3]);
     SetFillStyle(SolidFill,Color[4]);
     SetTextJustify(LeftText,CenterText);
     while A.Y < Area.B.Y do begin
      Item_Paint(Rect,I);
      Inc(A.Y,Item_Size);
      Inc(B.Y,Item_Size);
      Inc(I)
     end;
     Canvas_Frame;
    end
   end;

  procedure TListBox.Do_KeyDown(var E: TEvent);
   begin
    if List = nil then Exit;
    case E.AbsKey.Code of
     kb_Up: Item_Select(Item_Curr-1);
     kb_Down: Item_Select(Item_Curr+1);
     kb_PgUp: Item_Select(Item_Curr - Size.Y div Item_Size);
     kb_PgDn: Item_Select(Item_Curr + Size.Y div Item_Size);
     kb_Home: Item_Select(Item_Top);
     kb_End: Item_Select(Item_Bottom);
     kb_PgUp+kb_Ctrl: Item_Select(0);
     kb_PgDn+kb_Ctrl: Item_Select(List^.Count);
     kb_Enter:
      begin
       if sf_Modal in State then Dlg_Stop(cm_Ok);
       if not Item_Entry(Item_Curr) then Exit
      end
     else if sf_Modal in State then begin
      Dlg_Stop(cm_Cancel);
      Event_Put(E)
     end else Exit;
    end;
    Event_Clr(E)
   end;

  procedure TListBox.Do_MouseDown(var E: TEvent);

   procedure DoDouble;
    begin
     Child_First^.Point_Local(E.Where,E.Where);
     Item_Entry(Item_Top+E.Where.Y div (Item_Size))
    end;

   procedure DoDown;
    begin
     with Child_First^ do repeat
      Point_Local(E.Where,E.Where);
      with E.Where do begin
       if Y < 0 then Item_Select(Item_Curr - 1 + Y div Item_Size) else
       if Y > Size.Y then Item_Select(Item_Curr + 1 + (Y-Size.Y) div Item_Size)
       else Item_Select(Item_Top+Y div (Item_Size));
      end;
      Event_Get(ev_Mouse,E);
     until E.What = ev_MouseUp;
     Event_Put(E)
    end;

   begin
    inherited Do_MouseDown(E);
    if Application^.Indicator <> Child_First then Exit;
    if (E.What = ev_MouseDown) and (Application^.Indicator = Child_First)
    and (List <> nil) then if E.Double then DoDouble else DoDown;
    Event_Clr(E)
   end;

  procedure TListBox.Do_MouseUp(var E: TEvent);
   begin
    if not (sf_Modal in State) then Exit;
    if Application^.Indicator = Child_First
    then Dlg_Stop(cm_Ok) else Dlg_Stop(cm_Cancel);
    Event_Clr(E)
   end;

  procedure TListBox.Do_ScrollChg(var E: TEvent);
   begin
    Item_Scroll(ScrollBar^.Value-Item_Top)
   end;

{Методы для управления Событиями (Event)}

  function TListBox.Event_Mask: word;
    var Mask: word;
   begin
    Mask:=ev_Command+ev_MouseDown+ev_MouseMove+ev_Notify;
    if sf_Focus in State then Inc(Mask,ev_KeyDown);
    if sf_Modal in State then Inc(Mask,ev_MouseUp);
    Event_Mask:=Mask
   end;

{Управление i-тым елементом}

  function  TListBox.Item_Bottom: integer;
   begin
    Item_Bottom:=Size.Y div Item_Size + Item_Top - 1
   end;

  function TListBox.Item_Entry;
   begin
    Item_Select(Item);
    Item_Entry:=Event_Send(@Self,ev_Notify,cm_ItemEnt,@Self) <> nil;
   end;

  function  TListBox.Item_Get;
   begin
    if (List = nil) or (Item < 0) or (Item >= List^.Count) then Item_Get:=''
    else Item_Get:=PString(List^.At(Item))^
   end;

  procedure TListBox.Item_Scroll(Delta: integer);
   var
    Count: integer;
    Area: TRect;
   begin
    if List = nil then Exit;
    Count:=Size.Y div Item_Size;
    Inc(Delta,Item_Top);
    if Delta > List^.Count - Count then Delta:=list^.Count-Count;
    if Delta < 0 then Delta:=0;
    if Delta = Item_Top then Exit;
    Item_Top:=Delta;
    with Child_First^ do begin
     Area_Free(Area);
     Draw_Rect(Area)
    end;
    if ScrollBar^.Value <> Delta then ScrollBar^.Scroll_Value(Item_Top)
   end;

  procedure TListBox.Item_Select(Item: integer);
   var
    Area: TRect;
    Ex: integer;
    E: TEvent;
   begin
    if List = nil then Exit;
    if Item < 0 then Item:=0 else
    if Item >= List^.Count then Item:=List^.Count-1;
    if Item = Item_Curr then Exit;
    Ex:=Item_Curr;
    Item_Curr:=Item;
    if Item < Item_Top then Item_Scroll(Item-Item_Top) else
    if Item > Item_Bottom then Item_Scroll(Item-Item_Bottom)
    else begin
     Item_Draw(Ex);
     Item_Draw(Item_Curr);
    end;
    Event_Send(Parent,ev_Notify,cm_ItemChg,@Self);
   end;

  procedure TListBox.Item_Paint(const Area: TRect; Item: integer);
    var Flag: boolean;
   begin
    Flag:=(Item = Item_Curr) and ((sf_Focus in State));
    with Area, List^ do begin
     if Flag then with Style_Palette^ do begin
      SetColor(Color[5]);
      SetFillStyle(SolidFill,Color[6])
     end;
     Bar(A.X,A.Y,B.X,B.Y);
     if (List <> nil) and (Item < Count) then OutTextXY(3,(B.Y+A.Y) div 2,PString(At(Item))^);
     if Flag then with Style_Palette^ do begin
      SetColor(Color[3]);
      SetFillStyle(SolidFill,Color[4])
     end;
    end
   end;

  procedure TListBox.Item_Draw(Item: integer);
    var Rect: TRect;
   begin
    if (Item < 0) or (Item >= List^.Count) then Exit;
    with Child_First^, Rect do begin
     Area_Free(Rect);
     Inc(A.Y,(Item-Item_Top) * Item_Size);
     B.Y:=A.Y+Item_Size;
     Draw_Rect(Rect);
    end
   end;

  procedure TListBox.List_Set(AList: PCollection);
    var CountPg: integer;
   begin
    Item_Curr:=-2;
    Scr_Lock;
    if (List <> nil) and (List <> AList) then Dispose(List,Done);
    List:=AList;
    if (List = nil) or (List^.Count = 0) then Item_Select(1) else Item_Select(0);
    CountPg:=(Size.Y div Item_Size);
    ScrollBar^.Scroll_Param(0,List^.Count-CountPg,1,CountPg,Item_Curr);
    Child_First^.Draw;
    Scr_UnLock;
    Event_Send(Parent,ev_Notify,cm_ListChg,@Self)
   end;

{Методы создания (New) вспомагательных объектов}

  function  TListBox.New_ScrollBar: PScrollBar;
    var Area: TRect;
   begin
    Area_Free(Area);
    with Area do A.X:=B.X-Metric_Unit.X*3;
    New_ScrollBar:=New(PScrollBar,Init(Area,of_NoSelect+of_AutoHide));
   end;

  function  TListBox.New_View: PView;
    var Area:TRect;
   begin
    Area_Free(Area);
    with PView(New(PView,Init(Area)))^ do begin
     Options:=Options or of_Border;
     New_View:=Ptr
    end
   end;

{Методы для установки (On) Состояний}

  procedure TListBox.On_Focus(On: boolean);
   begin
    inherited On_Focus(On);
    Item_Draw(Item_Curr);
    Event_Send(Parent,ev_Notify,cm_ItemChg,@Self);
   end;

{Методы определения Стиля (Style) окна}

  function TListBox.Style_Palette: PPalette;
   begin
    Style_Palette:=@Palette_ListBox
   end;


{Реализация типа TComboBox}
{---------------------------------------------------------------------------}
{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TComboBox.Init(Area: TRect; AForm: TForm; of_XXXX: word; AList: PCollection);
    var D: integer;
   begin
    inherited Init(Area, AForm, of_XXXX);
    ListBox:=New_ListBox(Area.Open(0,0,Size.X,Size.X)^,nil);
    ListBox^.GrowMode:=gm_GrowHiX+gm_GrowHiY;
    if Size.Y < Metric_Box.Y * 2 then with Child_Last^, Area do begin
     D:=Metric_Box.X * 3 div 4;
     Area_Get(Area);
     Dec(Size.X,D);
     A.X:=B.X-D;
     Child_Ins(New_Key(Area))^.GrowMode:=gm_GrowHiX+gm_GrowHiY+gm_GrowLoX;
    end else with Child_Last^, Area do begin
     D:=Metric_Box.Y * 3 div 4;
     Area_Get(Area);
     Size.Y:=D;
     Inc(A.Y,D);
     ListBox^.Area_Set(Area);
     Child_Ins(ListBox);
    end;
    List_Set(AList)
   end;

  destructor TComboBox.Done;
   begin
    if ListBox^. Parent = nil then ListBox^.Free;
    inherited Done
   end;

{Методы для Оработки (Do) событий) }

  procedure TComboBox.Do_ItemChg(var E: TEvent);
   begin
    if E.InfoPtr <> ListBox then Exit;
    with ListBox^ do Text_Ins(Item_Get(Item_Curr));
    Event_Clr(E)
   end;

  procedure TComboBox.Do_ItemEnt(var E: TEvent);
   begin
    if E.InfoPtr <> ListBox then Exit;
    Event_Clr(E);
    Text_Entry
   end;

  procedure TComboBox.Do_KeyDown(var E: TEvent);
   begin
    inherited Do_KeyDown(E);
    with ListBox^ do if (E.AbsKey.Code <> kb_Down)
    or (Parent <> nil) or (List = nil) then Exit;
    Event_Clr(E);
    List_UnDrap
   end;

  procedure TComboBox.Do_UnDrap(var E: TEvent);
   begin
    if PView(E.InfoPtr)^.Parent <> @Self then Exit;
    Event_Clr(E);
    List_UnDrap
   end;

{Методы для управления Событиями (Event)}

  function  TComboBox.Event_Mask: word;
   begin
    Event_Mask:=inherited Event_Mask or ev_MouseMove;
   end;

{Методы для управления Списком (List)}

  procedure TComboBox.List_Set(AList: PCollection);
   begin
    with ListBox^ do begin
     List_Set(AList);
     Text_Set(Item_Get(Item_Curr))
    end;
    Comm_Enable(cm_UnDrap,(AList <> nil) and (AList^.Count <> 0));
   end;

  procedure TComboBox.List_UnDrap;
   var
    Area: TRect;
    Result: word;
   begin
    if ListBox^.Parent <> nil then Exit;
    Area_Free(Area);
    with ListBox^ do Area.B.Y:=List^.Count * Item_Size+2;
    if Area.B.Y > Size.X then Area.B.Y:=Size.X;
    if Area.B.Y < Size.Y then Area.B.Y:=Size.Y;
    Area.Move(0,Size.Y-2);
    Point_Global(Area.A,Area.A);
    Point_Global(Area.B,Area.B);
    with Area, Application^.Size do begin
     if B.X > X then Move(X-B.X, 0);
     if B.Y > Y then Move(0, Y-B.Y);
     if A.X < 0 then Move(-A.X, 0);
     if A.Y < 0 then Move(0,-A.Y);
    end;
    with ListBox^ do begin
     Options:=Options or of_NoSelect;
     Area_Set(Area);
     Application^.Child_Ins(ListBox);
     Result:=Dlg_Exec;
     Application^.Child_Del(ListBox);
     if Result <> cm_Ok then Exit;
     Text_Ins(Item_Get(Item_Curr));
     Text_Entry
    end
   end;

{Методы создания (New) вспомагательных объектов}

  function TComboBox.New_ListBox(const Area: TRect; AList: PCollection): PListBox;
   begin
    New_ListBox:=PListBox(New(PListBox,Init(Area,AList,of_Shadow)))
   end;

  function TComboBox.New_Key(const Area: TRect): PKey;
   begin
    New_Key:=PKey(New(PKey,Init(Area,Symbol[5],cm_UnDrap,of_NoSelect+of_Border)))
   end;


{Реализация объекта Светофора (Signal) }
{-----------------------------------------------------------------------}

{Методы Cоздания (Init) и Pозрушения(Done) окна}

  constructor TSignal.Init(const Area: TRect; of_XXXX: word);
   begin
    inherited Init(Area);
    Options:=Options or of_XXXX
   end;

{Методы управления Холстом (Canvas)}

  procedure TSignal.Canvas_Paint;
   var
    P: TPoint;
    H,R,I: integer;
    C: PPalette;
    Area: TRect;
   procedure DrawCircle(I: byte; On : boolean);
     var Bk: byte;
    begin
     with C^ do begin
      if On then Bk:=Color[4+I] else Bk:=Color[7];
      SetFillStyle(SolidFill,Bk);
      SetColor(Bk);
      PieSlice(P.X,P.Y,0,360,R);
      SetColor(Color[2]);
      Arc (P.X,P.Y,45,225,R);
      SetColor(Color[1]);
      Arc (P.X,P.Y,226,44,R);
      Inc(P.Y,H);
     end
    end;
   begin
    C:=Style_Palette;
    if Options and of_Glass = 0 then begin
     Area_Free(Area);
     SetFillStyle(SolidFill,C^.Color[2])
    end;
    P.X:=Size.X div 2;
    P.Y:=Size.Y div 6+1;
    H:=Size.Y div 3;
    R:=P.X - 2;
    SetLineStyle(Solidln,0,NormWidth);
    with C^ do for I:=0 to 2 do DrawCircle(I,sf_Red+I in State);
    Canvas_Frame
   end;

{Методы для установки (On) Состояний}

   procedure TSignal.On_Green(On: boolean);
    begin
     Draw
    end;

   procedure TSignal.On_Red(On: boolean);
    begin
     Draw
    end;

   procedure TSignal.On_Yellow(On: boolean);
    begin
     Draw
    end;

{Методы определения Стиля (Style) окна}

   function TSignal.Style_Palette: PPalette;
    begin
     Style_Palette:=@Palette_Signal
    end;


{-------------------------------------------------------------------------}

   procedure Style_Desk;
     var Area: TRect;
    begin
     with View^ do begin
      Area_Free(Area);
      SetFillPattern(Pattern_Desk,byte(Palette_Desk[3]));
      SetFillStyle(USerFill,0);
      with Area do Bar(A.X,A.Y,B.X,B.Y);
      Canvas_Frame
     end
    end;

   procedure Style_HRail;
     var Area: TRect;
    begin
     with View^ do begin
      Canvas_Frame;
      Area_Free(Area);
      with PPalette(@Palette_Rail)^, Area, A do begin
       SetFillStyle(SolidFill,Color[3]);
       Bar(X,Y,B.X,Size.Y div 2 + 2);
       SetFillPattern(Pattern_HRail,Color[3]);
       SetFillStyle(UserFill,Color[3]);
       A.Y:=(B.Y+A.Y) div 2-1;
       Bar(A.X,A.Y+4,B.X,B.Y);
       B.Y:=A.Y+2;
       S3D_Body(Area,-1,Color[5])
      end
     end
    end;

   procedure Style_VRail;
     var Area: TRect;
    begin
     with View^ do  begin
      Canvas_Frame;
      Area_Free(Area);
      with PPalette(@Palette_Rail)^ , Area, A do begin
       SetFillStyle(SolidFill,Color[3]);
       Bar(X,Y,B.X,B.Y);
       SetFillPattern(Pattern_VRail,Color[3]);
       SetFillStyle(UserFill,Color[3]);
       X:=(B.X+X) div 2-1;
       Bar(X+4,Y,B.X,B.Y);
       B.X:=X+2;
       S3D_Body(Area,-1,Color[5])
      end
     end
    end;

  end.