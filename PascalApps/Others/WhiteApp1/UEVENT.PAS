 {      ┌───────────────────────────────────────────┐
        │                                           │
        │     W h i t e   A p p l i c a t o r       │
        │                                           │
        │              U E v e n t   2.0            │
        │                                           │
        │       Copyright (c)  S.Novak  1995        │
        │                                           │
        │            (implementation)               │
        │                                           │
        └───────────────────────────────────────────┘      }

 {$I UEVENT.INC}

 implementation

  uses

   Dos;

{-------------------------------------------------------------------------}

  const

   TGenerator_EventPut   = TObject_Top + 12;
   TGenerator_Hit       :  PGenerator = nil;

  constructor TGenerator.Init;
   function DoLast(Generator: PGenerator): boolean; far;
    begin
     DoLast:=Generator^.Next = nil
    end;
   begin
    inherited Init;
    if TGenerator_Hit = nil then TGenerator_Hit:=@Self
    else TGenerator_Hit^.Testor(@DoLast)^.Next:=@Self;
    Event_Clr
   end;

  destructor TGenerator.Done;
   function DoPrev(Generator: PGenerator): boolean; far;
    begin
     DoPrev:=Generator^.Next = @Self
    end;
   begin
    if TGenerator_Hit = @Self then TGenerator_Hit:=Next
    else TGenerator_Hit^.Testor(@DoPrev)^.Next:=Next
   end;

  function TGenerator.Testor(Method: pointer): PGenerator; assembler;
   asm
         LES     DI,Self
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
         LES     DI,ES:[DI].TGenerator.Next
         JMP     @1
     @3: MOV     AX,DI
         MOV     DX,ES
   end;

  procedure TGenerator.Event_Clr;
   begin
    Abstract
   end;

  procedure TGenerator.Event_Get(var E: TEvent);
   begin
    Abstract
   end;

  procedure TGenerator.Event_Put(const E: TEvent);
   begin
    Abstract
   end;

{--------------------------------------------------------------------------}

  constructor TCommander.Init(ARange: byte);
   begin
    inherited Init;
    Queue.Init(ARange,SizeOf(TEvent))
   end;

  destructor TCommander.Done;
   begin
    Queue.Done;
    inherited Done
   end;

  procedure TCommander.Event_Clr;
   begin
    Queue.Clear
   end;

  procedure TCommander.Event_Get(var E: TEvent);
   begin
    with Queue do if Power_Get = 0 then E.What:=ev_Nothing else Rec_Get(E)
   end;

  procedure TCommander.Event_Put(const E: TEvent);
   begin
    Queue.Rec_Put(E)
   end;

{--------------------------------------------------------------------------}
{Утилиты для объекта Мыши (Mouse)}

const

 EventQSize = 16;

var

 MouseIntFlag: byte;
 MouseButtons: byte;
 MouseWhere: TPoint;
 MouseCursor: pointer;
 LastButtons: byte;
 DownButtons: byte;
 LastDouble: boolean;
 LastWhere: TPoint;
 DownWhere: TPoint;
 DownTicks: word;
 AutoTicks: word;
 AutoDelay: word;
 EventCount: word;
 EventQHead: word;
 EventQTail: word;
 EventQueue: array[0..EventQSize - 1] of TEvent;
 EventQLast: record end;
 Ticks: word absolute $40:$6C;

procedure DetectMouse; near; assembler;
   asm
	MOV	AX,3533H
	INT	21H
	MOV	AX,ES
	OR	AX,BX
	JE	@@1
	XOR	AX,AX
	INT	33H
	OR	AX,AX
	JE	@@1
	PUSH	BX
	MOV	AX,4
	XOR	CX,CX
	XOR	DX,DX
	INT	33H
	POP	AX
    @@1:MOV	Mouse_Buttons,AL
end;

procedure StoreEvent; near; assembler;
  asm
	MOV	DI,SP
	LES	DI,SS:[DI+8]
	CLD
	STOSW
	XCHG	AX,BX
	STOSW
	XCHG	AX,CX
	STOSW
	XCHG	AX,DX
	STOSW
end;

procedure GetMouseState; near; assembler;
 asm
	CLI
	CMP	EventCount,0
	JNE	@@1
	MOV	BL,MouseButtons
	MOV	CX,MouseWhere.word[0]
	MOV	DX,MouseWhere.word[2]
	MOV	ES,Seg0040
	MOV	DI,ES:Ticks
	JMP	@@3
  @@1:	MOV	SI,EventQHead
	CLD
	LODSW
	XCHG	AX,DI
	LODSW
	XCHG	AX,BX
	LODSW
	XCHG	AX,CX
	LODSW
	XCHG	AX,DX
	CMP	SI,OFFSET EventQLast
	JNE	@@2
	MOV	SI,OFFSET EventQueue
   @@2:	MOV	EventQHead,SI
	DEC	EventCount
   @@3:	STI
	CMP	Mouse_Reverse,0
	JE	@@4
	MOV	BH,BL
	AND	BH,3
	JE	@@4
	CMP	BH,3
	JE	@@4
	XOR	BL,3
   @@4:
end;

procedure Mouse_Int; far; assembler;
asm
	MOV	SI,SEG @DATA
	MOV	DS,SI
	MOV	SI,CX
	MOV	MouseButtons,BL
	MOV	MouseWhere.X,SI
	MOV	MouseWhere.Y,DX
	TEST	AX,11110B
	JE	@@2
	CMP	EventCount,EventQSize
	JE	@@2
	MOV	ES,Seg0040
	MOV	AX,ES:Ticks
	MOV	DI,EventQTail
	PUSH	DS
	POP	ES
	CLD
        STOSW
	XCHG	AX,BX
	STOSW
	XCHG	AX,SI
	STOSW
	XCHG	AX,DX
	STOSW
	CMP	DI,OFFSET EventQLast
	JNE	@@1
	MOV	DI,OFFSET EventQueue
@@1:	MOV	EventQTail,DI
	INC	EventCount
@@2:	MOV	MouseIntFlag,1
end;

procedure Mouse_Done; assembler;
asm
	CMP	Mouse_Buttons,0
	JE	@@1
	CMP	Mouse_Events,0
	JE	@@1
	MOV	Mouse_Events,0
        MOV     AX,2
        INT     33H
	MOV	AX,12
	XOR	CX,CX
	MOV	DX,CX
	MOV	ES,CX
	INT	33H
@@1:
end;

procedure Mouse_Event_Get(var Event: TEvent); far; assembler;
asm
	CMP	Mouse_Events,0
	JE	@@2
	CALL	GetMouseState
	MOV	BH,LastDouble
	MOV	AL,LastButtons
	CMP	AL,BL
	JE	@@1
	OR	AL,AL
	JE	@@3
	OR	BL,BL
	JE	@@5
	MOV	BL,AL
@@1:	CMP	CX,LastWhere.X
	JNE	@@6
	CMP	DX,LastWhere.Y
	JNE	@@6
	OR	BL,BL
	JE	@@2
	MOV	AX,DI
	SUB	AX,AutoTicks
	CMP	AX,AutoDelay
	JAE	@@7
@@2:	XOR	AX,AX
	MOV	BX,AX
	MOV	CX,AX
	MOV	DX,AX
	JMP	@@9
@@3:	MOV	BH,0
	CMP	BL,DownButtons
	JNE	@@4
	CMP	CX,DownWhere.X
	JNE	@@4
	CMP	DX,DownWhere.Y
	JNE	@@4
	MOV	AX,DI
	SUB	AX,DownTicks
	CMP	AX,Mouse_Double
	JAE	@@4
	MOV	BH,1
@@4:	MOV	DownButtons,BL
	MOV	DownWhere.X,CX
	MOV	DownWhere.Y,DX
	MOV	DownTicks,DI
	MOV	AutoTicks,DI
	MOV	AX,Mouse_Repeat
	MOV	AutoDelay,AX
	MOV	AX,ev_MouseDown
	JMP	@@8
@@5:	MOV	AX,ev_MouseUp
	JMP	@@8
@@6:	MOV	AX,ev_MouseMove
	JMP	@@8
@@7:	MOV	AutoTicks,DI
	MOV	AutoDelay,1
	MOV	AX,ev_MouseAuto
@@8:    MOV	LastButtons,BL
	MOV	LastDouble,BH
	MOV	LastWhere.X,CX
	MOV	LastWhere.Y,DX
@@9:	CALL	StoreEvent
end;

{------------------------------------------------------------------------}

  procedure TMouse.Area_Set(const Area: TRect); assembler;
   asm
        CMP     Mouse_Buttons,0
        JE      @@1
        LES     DI, Area
        MOV     CX, ES:[DI].TRect.A.X
        MOV     DX, ES:[DI].TRect.B.X
        MOV     AX, 0007H
        INT     33H
        LES     DI, Area
        MOV     CX, ES:[DI].TRect.A.Y
        MOV     DX, ES:[DI].TRect.B.Y
        MOV     AX, 0008H
        INT     33H
    @@1:
   end;

  constructor TMouse.Init(const Area: TRect);
   begin
    inherited Init;
    asm
	XOR	AX,AX
	CMP	AL,Mouse_Buttons
	JE	@@1
	MOV	DownButtons,AL
	MOV	LastDouble,AL
	MOV	EventCount,AX
	MOV	AX,OFFSET DS:EventQueue
	MOV	EventQHead,AX
	MOV	EventQTail,AX
	MOV	AX,3
	INT	33H
	XCHG	AX,CX
	MOV	MouseButtons,BL
	MOV	MouseWhere.X,AX
	MOV	MouseWhere.Y,DX
	MOV	LastButtons,BL
	MOV	LastWhere.X,AX
	MOV	LastWhere.Y,DX
	MOV	AX,12
	MOV	CX,0FFFFH
	MOV	DX,OFFSET CS:Mouse_Int
	PUSH	CS
	POP	ES
	INT	33H
        MOV     AX,1
        INT     33H
	MOV	Mouse_Events,1
     @@1:
    end;
    Area_Set(Area)
   end;

  destructor  TMouse.Done;
   begin
    Mouse_Done
   end;

  procedure TMouse.Cursor_Hide; assembler;
   asm
	CMP	Mouse_Buttons,0
	JE	@@1
	PUSH	AX
	MOV	AX,2
	INT	33H
	POP	AX
   @@1:
   end;

  procedure TMouse.Cursor_Pos(var Point: TPoint);
   begin
    Point:=MouseWhere
   end;

  function TMouse.Cursor_Set(const Cursor: PMouseCursor): pointer; assembler;
   asm
        CMP    Mouse_Buttons,0
        JE     @@2
        MOV    AX, word PTR Cursor[0]
        MOV    DX, word PTR Cursor[2]
        MOV    BX, AX
        OR     BX, DX
        JZ     @@2
        CMP    AX, word PTR MouseCursor[0]
        JNE    @@1
        CMP    DX, word PTR MouseCursor[2]
        JE     @@2
    @@1:LES    DI, Cursor
        MOV    AX, 0009H
        MOV    BX, ES:[DI].TMouseCursor.Center.X
        MOV    CX, ES:[DI].TMouseCursor.Center.Y
        MOV    DX, DI
        ADD    DX, 4
        INT    33H
        MOV    AX, word PTR Cursor[0]
        MOV    DX, word PTR Cursor[2]
        XCHG   AX, word PTR MouseCursor[0]
        XCHG   DX, word PTR MouseCursor[2]
    @@2:
    end;

  procedure TMouse.Cursor_Show; assembler;
   asm
	CMP	Mouse_Buttons,0
	JE	@@1
	PUSH	AX
	MOV	AX,1
	INT	33H
	POP	AX
    @@1:
   end;

  procedure TMouse.Event_Get(var E: TEvent);
   begin
    Mouse_Event_Get(E);
   end;

  procedure TMouse.Event_Clr;
   begin
   end;

{----------------------------------------------------------------------------}
{Утилиты объекта клавиатуры (KeyBoard)}

var

 KeysState: word absolute $0000:$0417;
 KeysCount: word;
 KeysQHead: word;
 KeysQTail: word;
 KeysQueue: array[0..EventQSize - 1] of TEvent;
 KeysQLast: record end;
 KeysInt: pointer;
 KeysExit: pointer;

procedure KeyBoard_Int; interrupt; assembler;
 asm
        CLI
{Получение Номера клавиши из порта в CH}
        IN      AL, 60H
        MOV     CH, AL
        INT     60H
        MOV	AH, 1
        INT	16H
        JZ      @@2
{Получение кода клавиши в BX}
        MOV	AH, 0
 	INT	16H
        MOV     BX, AX
{Установка сегмента данных DS}
	MOV	SI,SEG @DATA
	MOV	DS,SI
{Проверка на переполнение}
	CMP	KeysCount,EventQSize
	JE	@@2
        XOR     DX, DX
        MOV     ES, DX
{Получение флагов состояния клавиатуры в DX и СL}
        MOV     AX, ES:KeysState
        MOV     CL, AL
        AND     CL, 00001111B
        TEST    CL, kf_Shift
        JZ      @@0
        OR      CL, kf_Shift
   @@0: MOV     DX, AX
{Загрузка AX, BX, CX, DX}
        MOV     AX, ev_KeyDown
	MOV	DI, KeysQTail
	PUSH	DS
        POP     ES
	CLD
        STOSW
	XCHG	AX,BX
	STOSW
	XCHG	AX,CX
	STOSW
	XCHG	AX,DX
	STOSW
	CMP	DI,OFFSET KeysQLast
	JNE	@@1
	MOV	DI,OFFSET KeysQueue
@@1:	MOV	KeysQTail,DI
	INC	KeysCount
@@2:    STI
end;

{----------------------------------------------------------------------------}

  function SetInt(Numb: byte; Addr: pointer):  pointer;
    var Res: pointer;
   begin
    GetIntVec(Numb,Res);
    SetInt:=Res;
    SetIntVec(Numb,Addr)
   end;

  constructor TKeyBoard.Init;
   begin
    inherited Init;
    KeysInt:=SetInt($60,SetInt($9,Addr(KeyBoard_Int)));
    KeysExit:=ExitProc;
    Event_Clr;
    asm
   	XOR	AX,AX
	MOV	KeysCount,AX
	MOV	AX,OFFSET DS:KeysQueue
	MOV	KeysQHead,AX
	MOV	KeysQTail,AX
    end
   end;

  destructor TKeyBoard.Done;
   begin
    ExitProc:=KeysExit;
    SetInt($9,SetInt($60,KeysInt));
    inherited Done;
   end;

  function TKeyBoard.Status: PWord;
   begin
    Status:=@KeysState
   end;

  procedure TKeyBoard.Click_Set(On: boolean); assembler;
   asm
        MOV     AL, On
        XOR     AH, AH
        INT     16H
   end;

  procedure TKeyBoard.Event_Clr; assembler;
   asm
      MOV     AX, 0CFFH
      INT     16H
   end;

  procedure TKeyBoard.Event_Get(var E: TEvent); assembler;
    asm
	CLI
	CMP	KeysCount,0
	JE	@@3
        LES     DI, E
  	MOV	SI,KeysQHead
	CLD
        MOV    CX, Type TEvent shr 1
   REPE MOVSW
	CMP	SI,OFFSET KeysQLast
	JNE	@@2
	MOV	SI,OFFSET KeysQueue
   @@2:	MOV	KeysQHead,SI
	DEC	KeysCount
   @@3:	STI
   end;

  procedure TKeyBoard.Speed_Set(D,S: byte); assembler;
   asm
       MOV     AX, 0305H
       MOV     BH, D
       MOV     BL, S
       INT     16H
   end;

{---------------------------------------------------------------------------}

  procedure Event_Find(var E: TEvent);
    const Time: word = 0;
   function DoFind(Generator: PGenerator): boolean; far;
    begin
     Generator^.Event_Get(E);
     DoFind:=E.What <> ev_Nothing
    end;
   begin
    E.What:=ev_Nothing;
    if (TGenerator_Hit = nil) or (TGenerator_Hit^.Testor(@DoFind) = nil)
    then begin
     E.What:=ev_FreeTime;
     E.FreeTime:=Time;
     Inc(Time)
    end else Time:=0
   end;

  function Char_Scan(Ch: char): byte;
   begin
    Char_Scan:=byte(kb_Scan[byte(Ch)])
   end;

  function Char_Code(Ch: char): word;
    var Res: TAbsKey;
   begin
    Res.Scan:=byte(kb_Scan[byte(Ch)]);
    Res.Flag:=0;
    Char_Code:=Res.Code
   end;

  function UpCase(Ch: char): char;
   begin
    if Ch < #128 then UpCase:=System.UpCase(Ch)
    else UpCase:=kb_Char[byte(Ch)-127]
   end;

  begin
   DetectMouse
  end.
