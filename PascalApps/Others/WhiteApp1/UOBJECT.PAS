{      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³                                           ³
       ³       W h i t e  A p p l i c a t o r      ³
       ³                                           ³
       ³            U O b j e c t  2.0             ³
       ³                                           ³
       ³       Copyright (c)  S.Novak  1995        ³
       ³                                           ³
       ³               (intefrace)                 ³
       ³                                           ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      }

 {$I UOBJECT.INC}

 implementation

  type

   PData = ^TData;
   TData = array [0..$FFF0] of byte;

   procedure TRect.Center(var Pos :TPoint); assembler;
    asm
        MOV     DX, DS
        CLD
        LDS     SI, Self
        LES     DI, Pos
        MOV     CX, 2
     @1:LODSW
        ADD     AX, [SI+2].WORD
        SHR     AX, 1
        STOSW
        LOOP    @1
        MOV     DS, DX
    end;

   function TRect.Contains(P: TPoint): Boolean; assembler;
    asm
        LES     DI,Self
        MOV     AL,0
        MOV     DX,P.X
        CMP     DX,ES:[DI].TRect.A.X
        JL      @@1
        CMP     DX,ES:[DI].TRect.B.X
        JGE     @@1
        MOV     DX,P.Y
        CMP     DX,ES:[DI].TRect.A.Y
        JL      @@1
        CMP     DX,ES:[DI].TRect.B.Y
        JGE     @@1
        INC     AX
     @@1:
    end;

   function TRect.Empty: boolean; assembler;
    asm
        LES     DI,Self
        MOV     AL,1
        MOV     DX,ES:[DI].TRect.A.X
        CMP     DX,ES:[DI].TRect.B.X
        JG      @@1
        MOV     DX,ES:[DI].TRect.A.Y
        CMP     DX,ES:[DI].TRect.B.Y
        JG      @@1
        DEC     AX
    @@1:
    end;

   function TRect.Equals(const R: TRect): Boolean; assembler;
    asm
        MOV     DX,DS
        LDS     SI,R
        LES     DI,Self
        MOV     CX,4
        CLD
        REP     CMPSW
        MOV     AL,0
        JNE     @@1
        INC     AX
    @@1:MOV     DS,DX
    end;

   procedure TRect.Assign(XA, YA, XB, YB: Integer); assembler;
    asm
        LES     DI,Self
        CLD
        MOV     AX,XA
        STOSW
        MOV     AX,YA
        STOSW
        MOV     AX,XB
        STOSW
        MOV     AX,YB
        STOSW
    end;

   procedure TRect.Open(X, Y, SX, SY: Integer); assembler;
    asm
        LES     DI, Self
        CLD
        MOV     AX, X
        MOV     BX, AX
        STOSW
        MOV     AX, Y
        MOV     DX, AX
        STOSW
        MOV     AX, SX
        ADD     AX, BX
        STOSW
        MOV     AX, SY
        ADD     AX, DX
        STOSW
    end;

   procedure TRect.Copy(const R: TRect); assembler;
    asm
        MOV     DX,DS
        LDS     SI,R
        LES     DI,Self
        CLD
        MOVSW
        MOVSW
        MOVSW
        MOVSW
        MOV     DS,DX
    end;

   procedure TRect.Grow(X, Y: Integer); assembler;
    asm
        LES     DI,Self
        MOV     AX,X
        SUB     ES:[DI].TRect.A.X,AX
        ADD     ES:[DI].TRect.B.X,AX
        MOV     AX,Y
        SUB     ES:[DI].TRect.A.Y,AX
        ADD     ES:[DI].TRect.B.Y,AX
    end;

   procedure TRect.Intersect(const R: TRect); assembler;
    asm
        MOV     DX,DS
        LDS     SI,R
        LES     DI,Self
        CLD
        LODSW
        SCASW
        JLE     @@1
        DEC     DI
        DEC     DI
        STOSW
    @@1:LODSW
        SCASW
        JLE     @@2
        DEC     DI
        DEC     DI
        STOSW
    @@2:LODSW
        SCASW
        JGE     @@3
        DEC     DI
        DEC     DI
        STOSW
    @@3:LODSW
        SCASW
        JGE     @@4
        DEC     DI
        DEC     DI
        STOSW
    @@4:MOV     DS,DX
    end;

   function TRect.Clip(const R: TRect): boolean; assembler;
    asm
        PUSH    DS
        LDS     SI, R
        LES     DI, Self
        MOV     CX, 1
        CMP     CL, 10000B
        JE      @@3
        MOV     AX, [SI].TRect.A.X
        MOV     BX, [SI].TRect.B.X
        MOV     DX, ES:[DI].TRect.A.X
        CMP     DX, AX
        JL      @@0
        CMP     DX, BX
        JG      @@0
        OR      CH, CL
  @@0:  SHL     CL, 1
        MOV     DX, ES:[DI].TRect.B.X
        CMP     DX, AX
        JL      @@1
        CMP     DX, BX
        JG      @@1
        OR      CH, CL
  @@1:  OR      CH, CH
        JE      @@7
        SHL     CL, 1
        MOV     AX, [SI].TRect.A.Y
        MOV     BX, [SI].TRect.B.Y
        MOV     DX, ES:[DI].TRect.A.Y
        CMP     DX, AX
        JL      @@2
        CMP     DX, BX
        JG      @@2
        OR      CH, CL
   @@2: SHL     CL, 1
        MOV     DX, ES:[DI].TRect.B.Y
        CMP     DX, AX
        JL      @@3
        CMP     DX, BX
        JG      @@3
        OR      CH, CL
        SHL     CL, 1
   @@3: CMP     CH, 1111B
        JE      @@8
        CMP     CH, 0111B
        JNE     @@4
        INC     BX
        MOV     ES:[DI].TRect.A.Y, BX
        JMP     @@7
   @@4: CMP     CH, 1011B
        JNE     @@5
        DEC     AX
        MOV     ES:[DI].TRect.B.Y, AX
        JMP     @@7
   @@5: CMP     CH, 1110B
        JNE     @@6
        MOV     AX, [SI].TRect.A.X
        DEC     AX
        MOV     ES:[DI].TRect.B.X, AX
        JMP     @@7
   @@6: CMP     CH, 1101B
        JNE     @@7
        MOV     AX, [SI].TRect.B.X
        INC     AX
        MOV     ES:[DI].TRect.A.X, AX
   @@7: XOR     AX, AX
        JMP     @@9
   @@8: MOV     AX, 1
   @@9: POP DS
  end;

   procedure TRect.Move(X, Y: Integer); assembler;
    asm
        LES     DI,Self
        MOV     AX,X
        ADD     ES:[DI].TRect.A.X,AX
        ADD     ES:[DI].TRect.B.X,AX
        MOV     AX,Y
        ADD     ES:[DI].TRect.A.Y,AX
        ADD     ES:[DI].TRect.B.Y,AX
    end;

   procedure TRect.Union(const R: TRect); assembler;
    asm
        PUSH    DS
        LDS     SI,R
        LES     DI,Self
        CLD
        LODSW
        SCASW
        JGE     @@1
        DEC     DI
        DEC     DI
        STOSW
    @@1:LODSW
        SCASW
        JGE     @@2
        DEC     DI
        DEC     DI
        STOSW
    @@2:LODSW
        SCASW
        JLE     @@3
        DEC     DI
        DEC     DI
        STOSW
    @@3:LODSW
        SCASW
        JLE     @@4
        DEC     DI
        DEC     DI
        STOSW
    @@4:POP     DS
    end;

   constructor TQueue.Init(ARange, ADataSize :word);
    begin
     Range:=ARange;
     Size:=ADataSize;
     {$R+} Last:=Range*Size; {$R-}
     GetMem(Queue,Last);
     Head:=Ofs(Queue^);
     Tail:=Head;
     Inc(Last,Head)
    end;

   destructor TQueue.Done;
    begin
     Dec(Last,Ofs(Queue^));
     FreeMem(Queue,Last)
    end;

   function TQueue.Power_Get :word;
    begin
     Power_Get:=Power
    end;

   function TQueue.Power_Max :word;
    begin
     Power_Max:=Range
    end;

   procedure TQueue.Clear;
    begin
     Head:=Tail
    end;

   procedure TQueue.Rec_Get(var Data); assembler;
    asm
        LES     DI, Self
	CMP	ES:[DI].Power, 0
	JNE	@@1
        MOV     AL, err_QueueEmpty
        PUSH    AX
        CALL    RunError
    @@1:MOV     AX, WORD PTR ES:[DI].Queue[2]
        MOV     BX, DS
        MOV     CX, ES:[DI].Size
        MOV     SI, ES:[DI].Head
        MOV     DS, AX
        LES     DI, Data
        CLD
    REP MOVSB
        LES     DI, Self
        CMP	SI, ES:[DI].Last
	JNE	@@2
	MOV	SI, WORD PTR ES:[DI].Queue[0]
    @@2:MOV	ES:[DI].Head, SI
  	DEC	ES:[DI].Power
        MOV     DS, BX
    end;

   procedure TQueue.Rec_Put(const Data); assembler;
    asm
        LES     DI, Self
	MOV	AL, ES:[DI].Range
        CMP     AL, ES:[DI].Power
        JNE	@@1
        MOV     AL, err_QueueFull
        PUSH    AX
        CALL    RunError
    @@1:MOV     AX, WORD PTR ES:[DI].Queue[2]
        MOV     BX, DS
        MOV     CX, WORD PTR ES:[DI].Size
        MOV     DI, ES:[DI].Tail
        MOV     ES, AX
        LDS     SI, Data
        CLD
    REP MOVSB
        XCHG    DI, SI
        LES     DI, Self
        CMP	SI, ES:[DI].Last
	JNE	@@2
	MOV	SI, WORD PTR ES:[DI].Queue[0]
    @@2:MOV	ES:[DI].Tail, SI
  	INC	ES:[DI].Power
        MOV     DS, BX
    end;

   const

    TFantom_Hit :PFantom = nil;
    TFantom_OldFunc :pointer = nil;

   function TFantom_Demon(Size :word) :integer; far; assembler;
    asm
        MOV     AX, Size
        OR      AX, AX
        JE      @@1
        LES     DI, TFantom_Hit
        LES     DI, ES:[DI].TFantom.Prev
        PUSH    ES
        PUSH    DI
        CALL    TFantom.Free
        MOV     AX, 2
        JMP     @@2
    @@1:PUSH    AX
        CALL    DWORD PTR TFantom_OldFunc
    @@2:
    end;

   constructor TFantom.Init;
    begin
     if TFantom_Hit = nil then begin
      TFantom_Hit:=@Self;
      Next:=@Self;
      Prev:=@Self;
      TFantom_OldFunc:=HeapError;
      HeapError:=@TFantom_Demon;
     end else DoIns;
     Protect_Count:=0;
    end;

   destructor TFantom.Done; assembler;
    asm
        LES     DI, Self
        CMP     DI, WORD PTR ES:[DI].Next[0];
        JNE     @@1
        MOV     AX, ES
        CMP     AX, WORD PTR ES:[DI].Next[2]
        JNE     @@1
        MOV     AX, DS
        MOV     ES, AX
        MOV     DI, OFFSET TFantom_Hit
        XOR     AX, AX
        CLD
        STOSW
        STOSW
        MOV     DI, OFFSET HeapError
        MOV     SI, OFFSET TFantom_OldFunc
        MOVSW
        MOVSW
        JMP     @@2
    @@1:PUSH    ES
        PUSH    DI
        CALL    DoDel
    @@2:
    end;

   procedure TFantom.DoDel;
    begin
     if TFantom_Hit = @Self then TFantom_Hit:=Prev;
     Prev^.Next:=Next;
     Next^.Prev:=Prev
    end;

   procedure TFantom.DoIns;
    begin
     Next:=TFantom_Hit;
     Prev:=Next^.Prev;
     Next^.Prev:=@Self;
     Prev^.Next:=@Self;
     TFantom_Hit:=@Self
    end;

   procedure TFantom.GoToHit; assembler;
    asm
        LES     DI, Self
        CMP     DI, WORD PTR TFantom_Hit[0]
        JNE     @@1
        MOV     AX, ES
        CMP     AX, WORD PTR TFantom_Hit[2]
        JE      @@2
    @@1:PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        CALL    TFantom.DoDel
        CALL    TFantom.DoIns
    @@2:
    end;

   procedure TFantom.Protect;
    begin
     Inc(Protect_Count);
     if Protect_Count > 1 then Exit;
     TFantom.Done;
     Next:=nil;
     Prev:=nil
    end;

   procedure TFantom.UnProtect;
    begin
     Dec(Protect_Count);
     if Protect_Count > 0 then Exit;
     TFantom.Init
    end;

  const

   TObject_List : word = 0;

  type

   TObjVmt = record
    Size :array[0..1] of longint;
    Done :pointer;
    Next :word;
    IDT  :word;
    Load :pointer;
    Store:pointer
   end;

   procedure ValidType; near; assembler;
    {IN    SI    VMT
     OUT   AX    IDT
     Uses  SI    AX }
    asm
        CLD
        ADD     SI, TObject_Load
        LODSW
        CMP     AX, OFFSET TObject.DoLoad
        JNE     @@1
        LODSW
        CMP     AX, SEG TObject.DoLoad
        JNE     @@1
        XOR     AX, AX
        JMP     @@2
    @@1:MOV     AX, 1
    @@2:
    end;

   constructor TObject.Init;
    type
     Image = record
      VMT: word;
      Data: record end;
     end;
    begin
     FillChar(Image(Self).Data, SizeOf(Self) - SizeOf(TObject), 0);
    end;

   destructor TObject.Done;
    begin
    end;

   function TObject.Self_IDT :word; assembler;
    asm
        LES     DI, Self
        MOV     DI, ES:[DI]
        MOV     SI, DI
        CALL    ValidType
        OR      AX, AX
        JE      @@1
        MOV     AX, DS:[DI].TObjVmt.IDT
     @@1:
    end;

   function TObject.Self_Ptr :pointer;
    begin
     Self_Ptr:=@Self
    end;

   procedure TObject.DoData;
    begin
    end;

   procedure TObject.DoLoad;
    begin
    end;

   procedure TObject.DoStore;
    begin
    end;

   procedure TObject.Free;
    begin
     if @Self <> nil then  Dispose(PObject(@Self), Done)
    end;

   procedure DoChannelError; near; assembler;
    {AX    = Error info
     DX    = Error code
     ES:DI = Stream object pointer
     Uses  AX,BX,CX,DX,SI  }
    asm
        PUSH    ES
        PUSH    DI
        PUSH    DX
        PUSH    AX
        PUSH    ES
        PUSH    DI
        MOV     DI, ES:[DI]
        CALL    DWORD PTR [DI].TChannel_Error
        POP     DI
        POP     ES
    end;

   procedure GetType; near; assembler;
    {IN    AX    IDT
     OUT   BX    VMT
     Uses  AX    BX }
    asm
        CLD
        MOV     BX,  TObject_List
    @@1:OR      BX,  BX
        JE      @@2
        CMP     AX,  [BX].TObjVmt.IDT
        JE      @@2
        MOV     BX,  [BX].TObjVmt.Next
        JMP     @@1
    @@2:
    end;

   function TChannel.Obj_Get :pointer; assembler;
    asm
        PUSH    AX
        MOV     AX, SP
        PUSH    SS
        PUSH    AX
        MOV     AX, 2
        PUSH    AX
        LES     DI, Self
        PUSH    ES
        PUSH    DI
        MOV     DI, ES:[DI]
        CALL    DWORD PTR [DI].TChannel_BufGet
        POP     AX
        OR      AX, AX
        JE      @@1
        CALL    GetType
        OR      BX, BX
        JNE     @@2
        LES     DI, Self
        MOV     DX, st_GetError
        CALL    DoChannelError
    @@1:XOR     AX, AX
        MOV     DX, AX
        JMP     @@3
    @@2:LES     DI, Self
        XOR     AX, AX
        PUSH    ES
        PUSH    DI
        PUSH    BX
        PUSH    AX
        PUSH    AX
        CALL    DWORD PTR DS:[BX].TObjVmt.Load
    @@3:
    end;

   function TChannel.Str_Get :PString;
    var
     Leng :byte;
     Res :PString;
    begin
     Buf_Get(Leng,SizeOf(Leng));
     if Size <> 0 then begin
      GetMem(Res,Leng+1);
      Res^[0]:=Char(Leng);
      Buf_Get(Res^[1],Leng);
      Str_Get:=Res
     end else Str_Get:=nil
    end;

   function TChannel.Size: longint;
    begin
     Abstract
    end;

   procedure TChannel.Clear;
    begin
    end;

   procedure TChannel.Copy(const Channel: TChannel; Count: longint);
    var
     Power :word;
     Buffer :array [1..1024] of byte;
    begin
     while Count > 0 do begin
      if Count > SizeOf(Buffer) then Power:=SizeOf(Buffer) else Power:=Count;
      Channel.Buf_Get(Buffer,Power);
      Buf_Put(Buffer,Power);
      Dec(Count,Power)
     end;
    end;

   procedure TChannel.Error(Code, Info: Integer);
    begin
     Status:=Code;
     ErrorInfo:=Info;
     if @TChannel_ErrorProc <> nil then TChannel_ErrorProc(Self)
    end;

   procedure TChannel.Flush;
    begin
    end;

   procedure TChannel.Obj_Put(Obj :PObject); assembler;
    asm
        LES     DI, Obj
        MOV     AX, ES
        OR      AX, DI
        JE      @@1
        MOV     DI, ES:[DI]
        MOV     SI, DI
        CALL    ValidType
        OR      AX, AX
        JNE     @@2
        MOV     AX, SI
        LES     DI, Self
        MOV     DX, st_PutError
        CALL    DoChannelError
    @@1:XOR     CX, CX
        JMP     @@3
    @@2:MOV     CX, [DI].TObjVmt.IDT
        PUSH    DI
    @@3:PUSH    CX
        MOV     AX, SP
        PUSH    SS
        PUSH    AX
        MOV     AX, 2
        PUSH    AX
        LES     DI, Self
        PUSH    ES
        PUSH    DI
        MOV     DI, ES:[DI]
        CALL    DWORD PTR [DI].TChannel_BufPut
        POP     CX
        JCXZ    @@4
        POP     SI
        LES     DI, Self
        PUSH    ES
        PUSH    DI
        PUSH    Obj.WORD[2]
        PUSH    Obj.WORD[0]
        CALL    DWORD PTR DS:[SI].TObjVmt.Store
    @@4:
    end;

   procedure TChannel.Str_Put(Str :PString);
     const NulStr : string[1] = '';
    begin
     if Str = nil then write(NulStr,1) else write(Str^,byte(Str^[0])+1)
    end;

   procedure TChannel.Buf_Get(var Data; Count: word);
    begin
     Abstract
    end;

   procedure TChannel.Buf_Put(const Data; Count: word);
    begin
     Abstract
    end;

   procedure TChannel.Reset;
    begin
     Status:=st_Ok;
     ErrorInfo:=0
    end;

   constructor TNul.Init;
    begin
     inherited Init
    end;

   constructor TNul.Load(Channel :PChannel);
    begin
     Channel^.Buf_Get(Position,SizeOf(Position))
    end;

   function TNul.Size: longint;
    begin
     Size:=Position
    end;

   procedure TNul.Clear;
    begin
     Position:=0
    end;

   procedure TNul.Buf_Get(var Data; Count: word);
    begin
     Error(st_ReadError,0)
    end;

   procedure TNul.Buf_Put(const Data; Count: word);
    begin
     Inc(Position,Count)
    end;

   procedure TNul.Store(Channel :PChannel);
    begin
     Channel^.Buf_Put(Position,SizeOf(Position))
    end;

   procedure TVector.Del(Addr :longint);
    begin
     Abstract
    end;

   procedure TVector.Get(Addr :longint; var Data);
    begin
     Abstract
    end;

   procedure TVector.Ins(Addr :longint; const Data);
    begin
     Abstract
    end;

   procedure TVector.Put(Addr :longint; const Data);
    begin
     Abstract
    end;

   function Buf_Equals(const Buf1,Buf2; Count :word) :boolean; assembler;
    asm
        CLD
        XOR AX,  AX
        MOV DX,  DS
        LES DI,  Buf1
        LDS SI,  Buf2
        MOV CX,  Count
   REPE CMPSB
        JNE @1
        MOV AX,1
    @1: MOV DS, DX
    end;

   function LocMem(Size :word) :pointer; assembler;
    procedure MemError;
     begin
      RunError(err_StackFull)
     end;
    asm
        POP     DI
        POP     BX
        POP     CX
        MOV     AX, SP
        MOV     DX, SS
        SUB     SP, Size
        JNC     @@1
        CALL    MemError
    @@1:PUSH    CX
        PUSH    BX
        PUSH    DI
    end;

   function Str_New(const Str :string) :PString;
     var Res :PString;
    begin
     if Str[0] = #0 then Str_New:=nil else begin
      GetMem(Res,byte(Str[0])+1);
      Res^:=Str;
      Str_New:=Res
     end;
    end;

   function Obj_Size(Obj :PObject) :longint;
     var Channel :TNul;
    begin
     with Channel do begin
      Init;
      Obj_Put(Obj);
      Obj_Size:=Size;
      Done
     end
    end;

   procedure Abstract;
    begin
     RunError(err_Abstract)
    end;

   procedure Buf_Copy(const Source; var Dest; Count :word); assembler;
    asm
        CLD
        MOV     DX,DS
        LES     DI,Dest
        LDS     SI,Source
        MOV     CX,Count
        SHR     CX,1
        JNC     @@1
        MOVSB
    @@1:REP     MOVSW
        MOV     DS,DX
    end;

   procedure Str_Del(Str :PString);
    begin
     if Str <> nil then FreeMem(Str,byte(Str^[0])+1)
    end;

   procedure FantomFree; assembler;
    asm
    @@1:LES     DI, TFantom_Hit
        MOV     SI, ES
        OR      SI, DI
        JE      @@2
        PUSH    ES
        PUSH    DI
        CALL    TFantom.Free
        JMP     @@1
    @@2:
    end;

   procedure Register_Nul;
    begin
     Register_Type(IDT_Nul,Ofs(TypeOf(TNul)^),@TNul.Load,@TNul.Store)
    end;

   procedure Register_Type(IDT, VMT :word; Load, Store :pointer); assembler;
    asm
        MOV     SI, Vmt
        CALL    ValidType
        OR      AX, AX
        JNE     @@2
        MOV     AX, IDT
        CALL    GetType
        OR      BX, BX
        JE      @@1
        MOV     AX, err_IdtDouble
        PUSH    AX
        CALL    RunError
    @@1:MOV     AX, TObject_List
        MOV     DI, VMT
        MOV     TObject_List, DI
        ADD     DI, TObject_Data
        STOSW
        MOV     AX, IDT
        STOSW
        MOV     AX, WORD PTR Load[0]
        STOSW
        MOV     AX, WORD PTR Load[2]
        STOSW
        MOV     AX, WORD PTR Store[0]
        STOSW
        MOV     AX, WORD PTR Store[2]
        STOSW
    @@2:
    end;

   procedure RunError(Code :byte);
    begin
     System.RunError(Code)
    end;

  end.

