{      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³                                           ³
       ³       W h i t e  A p p l i c a t o r      ³
       ³                                           ³
       ³            U S t r e e m  2.0             ³
       ³                                           ³
       ³       Copyright (c)  S.Novak  1995        ³
       ³                                           ³
       ³           (implementation)                ³
       ³                                           ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      }

 {$I USTREAM.INC}

 implementation

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

   procedure TStream.Clear;
    begin
     Pos_Set(0);
     Truncate
    end;

   function TStream.Pos_Get: longint;
    begin
     Abstract
    end;

   procedure TStream.Buf_Del(Count :longint);
     var Source :longint;
    begin
     Source:=Pos_Get;
     Buf_Move(Source+Count,Source,Size-Source-Count);
     Pos_Set(Size-Count);
     Truncate;
     Pos_Set(Source)
    end;

   procedure TStream.Buf_Move(Source,Dest,Count :longint);
    var
     Power :word;
     Buffer :array[1..1024] of byte;

    procedure DoMoveBuffer;
     begin
      Pos_Set(Source);
      Buf_Get(Buffer,Power);
      Pos_Set(Dest);
      Buf_Put(Buffer,Power)
     end;

    begin
     Power:=SizeOf(Buffer);
     if Source < Dest then begin
      Inc(Source,Count);
      Inc(Dest,Count);
      while Count > 0 do begin
       if Count < Power then Power:=Count;
       Dec(Source,Power);
       Dec(Dest,Power);
       DoMoveBuffer;
       Dec(Count,Power)
      end
     end else while Count > 0 do begin
      if Count < Power then Power:=Count;
      DoMoveBuffer;
      Inc(Source,Power);
      Inc(Dest,Power);
      Dec(Count,Power)
     end
    end;

   procedure TStream.Buf_Ins(const Buf; Count :word);
     var Source :longint;
    begin
     Source:=Pos_Get;
     Buf_Move(Source,Source+Count,Size-Source);
     Pos_Set(Source);
     Buf_Put(Buf,Count)
    end;

   procedure TStream.Pos_Set(Pos: longint);
    begin
     Abstract
    end;

   procedure TStream.Truncate;
    begin
     Abstract
    end;

   constructor TDosStream.Init(const FileName: TNameStr; AMode: word); assembler;
     var NameBuf: array[0..79] of Char;
    asm
        XOR     AX,AX
        PUSH    AX
        LES     DI,Self
        PUSH    ES
        PUSH    DI
        CALL    TStream.Init
{$IFDEF Windows}
	LEA	DI,NameBuf
	PUSH	SS
	PUSH	DI
	LES	DI,FileName
	PUSH	ES
	PUSH	DI
	MOV	AX,79
	PUSH	AX
	CALL	StrLCopy
	PUSH	DX
	PUSH	AX
	PUSH	DX
	PUSH	AX
	CALL	AnsiToOem
	PUSH	DS
	LEA	DX,NameBuf
{$ELSE}
        PUSH    DS
        LDS     SI,FileName
        LEA     DI,NameBuf
        MOV     DX,DI
        PUSH    SS
        POP     ES
        CLD
        LODSB
        CMP     AL,79
        JB      @@1
        MOV     AL,79
    @@1:CBW
        XCHG    AX,CX
        REP     MOVSB
        XCHG    AX,CX
        STOSB
{$ENDIF}
        PUSH    SS
        POP     DS
        XOR     CX, CX
        MOV     AX, AMode
        INT     21H
        POP     DS
        JNC     @@2
        LES     DI,Self
        MOV     DX,st_InitError
        CALL    DoChannelError
        MOV     AX,-1
    @@2:LES     DI,Self
        MOV     ES:[DI].TDosStream.Handle,AX
        MOV     AX, AMode
        MOV     ES:[DI].Mode, AX
        LES     DI,FileName
        PUSH    ES
        PUSH    DI
        CALL    Str_New
        LES     DI, Self
        MOV     WORD PTR ES:[DI].Name[0], AX
        MOV     WORD PTR ES:[DI].Name[2], DX
    end;

   constructor TDosStream.Load(Channel :PChannel);
    var
     S :TNameStr;
     Pos :longint;
    begin
     with Channel^ do begin
      Buf_Get(S,1);
      Buf_Get(S[1],byte(S[0]));
      Buf_Get(Mode,SizeOf(Mode));
      if Mode = sm_Create then Mode:=sm_Open;
      Buf_Get(Pos,SizeOf(Pos));
      Self.Init(S,Mode);
      Pos_Set(Pos)
     end
    end;

   destructor TDosStream.Done; assembler;
    asm
        LES     DI, Self
        LES     Di, ES:[DI].Name;
        PUSH    ES
        PUSH    DI
        CALL    Str_Del
        LES     DI, Self
        MOV     BX,ES:[DI].TDosStream.Handle
        CMP     BX,-1
        JE      @@1
        MOV     AH,3EH
        INT     21H
    @@1:XOR     AX,AX
        PUSH    AX
        PUSH    ES
        PUSH    DI
        CALL    TStream.Done
    end;

   function TDosStream.Name_Get :TNameStr;
    begin
     Name_Get:=Name^
    end;

   function TDosStream.Pos_Get: longint; assembler;
    asm
        LES     DI,Self
        XOR     DX,DX
        CMP     DX,ES:[DI].TDosStream.Status
        JNE     @@1
        MOV     CX,DX
        MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AX,4201H
        INT     21H
        JNC     @@2
        MOV     DX,st_Error
        CALL    DoChannelError
    @@1:MOV     AX,-1
        CWD
    @@2:
    end;

   function TDosStream.Size: longint; assembler;
    asm
        LES     DI,Self
        XOR     DX,DX
        CMP     DX,ES:[DI].TDosStream.Status
        JNE     @@1
        MOV     CX,DX
        MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AX,4201H
        INT     21H
        PUSH    DX
        PUSH    AX
        XOR     DX,DX
        MOV     CX,DX
        MOV     AX,4202H
        INT     21H
        POP     SI
        POP     CX
        PUSH    DX
        PUSH    AX
        MOV     DX,SI
        MOV     AX,4200H
        INT     21H
        POP     AX
        POP     DX
        JNC     @@2
        MOV     DX,st_Error
        CALL    DoChannelError
    @@1:MOV     AX,-1
        CWD
    @@2:
    end;

   procedure TDosStream.Buf_Get(var Buf; Count: word); assembler;
    asm
        LES     DI,Self
        CMP     ES:[DI].TDosStream.Status,0
        JNE     @@2
        PUSH    DS
        LDS     DX,Buf
        MOV     CX,Count
        MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AH,3FH
        INT     21H
        POP     DS
        MOV     DX,st_Error
        JC      @@1
        CMP     AX,CX
        JE      @@3
        XOR     AX,AX
        MOV     DX,st_ReadError
    @@1:CALL    DoChannelError
    @@2:LES     DI,Buf
        MOV     CX,Count
        XOR     AL,AL
        CLD
        REP     STOSB
    @@3:
    end;

   procedure TDosStream.Pos_Set(Pos: longint); assembler;
    asm
        LES     DI,Self
        CMP     ES:[DI].TDosStream.Status,0
        JNE     @@2
        MOV     DX,Pos.WORD[0]
        MOV     CX,Pos.WORD[2]
        OR      CX,CX
        JNS     @@1
        XOR     DX,DX
        XOR     CX,CX
    @@1:MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AX,4200H
        INT     21H
        JNC     @@2
        MOV     DX,st_Error
        CALL    DoChannelError
    @@2:
    end;

   procedure TDosStream.Store(Channel :PChannel);
     var Pos :longint;
    begin
     with Channel^ do begin
      Pos:=Pos_Get;
      Buf_Put(Name^,byte(Name^[0])+1);
      Buf_Put(Mode,SizeOf(Mode));
      Buf_Put(Pos,SizeOf(Pos))
     end
    end;

   procedure TDosStream.Truncate; assembler;
    asm
        LES     DI,Self
        XOR     CX,CX
        CMP     CX,ES:[DI].TDosStream.Status
        JNE     @@1
        MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AH,40H
        INT     21H
        JNC     @@1
        MOV     DX,st_Error
        CALL    DoChannelError
    @@1:
    end;

   procedure TDosStream.Buf_Put(const Buf; Count: word); assembler;
    asm
        LES     DI,Self
        CMP     ES:[DI].TDosStream.Status,0
        JNE     @@2
        PUSH    DS
        LDS     DX,Buf
        MOV     CX,Count
        MOV     BX,ES:[DI].TDosStream.Handle
        MOV     AH,40H
        INT     21H
        POP     DS
        MOV     DX,st_Error
        JC      @@1
        CMP     AX,CX
        JE      @@2
        XOR     AX,AX
        MOV     DX,st_WriteError
    @@1:CALL    DoChannelError
    @@2:
    end;

   procedure FlushBuffer; near; assembler;
    {In  AL    = Flush mode (0=Buf_Put, 1=Buf_Get, 2=Both)
     ES:DI     = TBufStream pointer
     Out ZF    = Status test }
    asm
        MOV     CX,ES:[DI].TBufStream.BufPtr
        SUB     CX,ES:[DI].TBufStream.BufEnd
        JE      @@3
        MOV     BX,ES:[DI].TDosStream.Handle
        JA      @@1
        CMP     AL,1
        JE      @@4
        MOV     DX,CX
        MOV     CX,-1
        MOV     AX,4201H
        INT     21H
        JMP     @@3
    @@1:CMP     AL,0
        JE      @@4
        PUSH    DS
        LDS     DX,ES:[DI].TBufStream.Buffer
        MOV     AH,40H
        INT     21H
        POP     DS
        MOV     DX,st_Error
        JC      @@2
        CMP     AX,CX
        JE      @@3
        XOR     AX,AX
        MOV     DX,st_WriteError
    @@2:CALL    DoChannelError
    @@3:XOR     AX,AX
        MOV     ES:[DI].TBufStream.BufPtr,AX
        MOV     ES:[DI].TBufStream.BufEnd,AX
        CMP     AX,ES:[DI].TStream.Status
    @@4:
    end;

   constructor TBufStream.Init(const FileName: TNameStr; AMode, ASize: word);
    begin
     TDosStream.Init(FileName, AMode);
     BufSize:=ASize;
     if ASize = 0 then Error(st_InitError, 0) else GetMem(Buffer, ASize)
    end;

   constructor TBufStream.Load(Channel :PChannel);
    begin
     inherited Load(Channel);
     Channel^.Buf_Get(BufSize,SizeOf(BufSize));
     GetMem(Buffer,BufSize)
    end;

   destructor TBufStream.Done;
    begin
     Flush;
     TDosStream.Done;
     FreeMem(Buffer, BufSize)
    end;

   procedure TBufStream.Flush; assembler;
    asm
        LES     DI,Self
        CMP     ES:[DI].TBufStream.Status,0
        JNE     @@1
        MOV     AL,2
        CALL    FlushBuffer
    @@1:
    end;

   function TBufStream.Pos_Get: longint; assembler;
    asm
        LES     DI,Self
        PUSH    ES
        PUSH    DI
        CALL    TDosStream.Pos_Get
        OR      DX,DX
        JS      @@1
        LES     DI,Self
        SUB     AX,ES:[DI].TBufStream.BufEnd
        SBB     DX,0
        ADD     AX,ES:[DI].TBufStream.BufPtr
        ADC     DX,0
      @@1:
    end;

   function TBufStream.Size: longint; assembler;
    asm
        LES     DI,Self
        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        CALL    TBufStream.Flush
        CALL    TDosStream.Size
    end;

   procedure TBufStream.Buf_Get(var Buf; Count: word); assembler;
    asm
        LES     DI,Self
        CMP     ES:[DI].TBufStream.Status,0
        JNE     @@6
        MOV     AL,1
        CALL    FlushBuffer
        JNE     @@6
        XOR     BX,BX
    @@1:MOV     CX,Count
        SUB     CX,BX
        JE      @@7
        LES     DI,Self
        MOV     AX,ES:[DI].TBufStream.BufEnd
        SUB     AX,ES:[DI].TBufStream.BufPtr
        JA      @@2
        PUSH    DS
        PUSH    CX
        PUSH    BX
        LDS     DX,ES:[DI].TBufStream.Buffer
        MOV     CX,ES:[DI].TBufStream.BufSize
        MOV     BX,ES:[DI].TBufStream.Handle
        MOV     AH,3FH
        INT     21H
        POP     BX
        POP     CX
        POP     DS
        MOV     DX,st_Error
        JC      @@5
        MOV     ES:[DI].TBufStream.BufPtr,0
        MOV     ES:[DI].TBufStream.BufEnd,AX
        OR      AX,AX
        JE      @@4
    @@2:CMP     CX,AX
        JB      @@3
        MOV     CX,AX
    @@3:PUSH    DS
        LDS     SI,ES:[DI].TBufStream.Buffer
        ADD     SI,ES:[DI].TBufStream.BufPtr
        ADD     ES:[DI].TBufStream.BufPtr,CX
        LES     DI,Buf
        ADD     DI,BX
        ADD     BX,CX
        CLD
        REP     MOVSB
        POP     DS
        JMP     @@1
    @@4:MOV     DX,st_ReadError
    @@5:CALL    DoChannelError
    @@6:LES     DI,Buf
        MOV     CX,Count
        XOR     AL,AL
        CLD
        REP     STOSB
    @@7:
    end;

   procedure TBufStream.Pos_Set(Pos: longint); assembler;
    asm
        LES     DI,Self
        PUSH    ES
        PUSH    DI
        CALL    TDosStream.Pos_Get
        OR      DX,DX
        JS      @@2
        LES     DI,Self
        SUB     AX,Pos.WORD[0]
        SBB     DX,Pos.WORD[2]
        JNE     @@1
        OR      AX,AX
        JE      @@1
        MOV     DX,ES:[DI].TBufStream.BufEnd
        SUB     DX,AX
        JB      @@1
        MOV     ES:[DI].TBufStream.BufPtr,DX
        JMP     @@2
    @@1:PUSH    Pos.WORD[2]
        PUSH    Pos.WORD[0]
        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        CALL    TBufStream.Flush
        CALL    TDosStream.Pos_Set
    @@2:
    end;

   procedure TBufStream.Store(Channel :PChannel);
    begin
     inherited Store(Channel);
     Channel^.Buf_Put(BufSize,SizeOf(BufSize))
    end;

   procedure TBufStream.Truncate; assembler;
    asm
        LES     DI, Self
        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        MOV     DI, ES:[DI]
        CALL    DWORD PTR ES:[DI].TChannel_Flush
        CALL    TDosStream.Truncate
    end;

   procedure TBufStream.Buf_Put(const Buf; Count: word); assembler;
    asm
        LES     DI,Self
        CMP     ES:[DI].TBufStream.Status,0
        JNE     @@4
        MOV     AL,0
        CALL    FlushBuffer
        JNE     @@4
        XOR     DX,DX
    @@1:MOV     CX,Count
        SUB     CX,DX
        JE      @@4
        LES     DI,Self
        MOV     AX,ES:[DI].TBufStream.BufSize
        SUB     AX,ES:[DI].TBufStream.BufPtr
        JA      @@2
        PUSH    CX
        PUSH    DX
        MOV     AL,1
        CALL    FlushBuffer
        POP     DX
        POP     CX
        JNE     @@4
        MOV     AX,ES:[DI].TBufStream.BufSize
    @@2:CMP     CX,AX
        JB      @@3
        MOV     CX,AX
    @@3:PUSH    DS
        MOV     AX,ES:[DI].TBufStream.BufPtr
        ADD     ES:[DI].TBufStream.BufPtr,CX
        LES     DI,ES:[DI].TBufStream.Buffer
        ADD     DI,AX
        LDS     SI,Buf
        ADD     SI,DX
        ADD     DX,CX
        CLD
        REP     MOVSB
        POP     DS
        JMP     @@1
    @@4:
    end;

   const

    EmsCurHandle: word = $FFFF;
    EmsCurPage: word = $FFFF;
    EmsPageSize = $4000;

   var

    EmsBaseSeg: word;
    EmsVersion: Byte;

   procedure EmsSelectPage; near; assembler;
    asm
        MOV     AX,ES:[DI].TEmsStream.Position.WORD[0]
        MOV     DX,ES:[DI].TEmsStream.Position.WORD[2]
        MOV     CX,EmsPageSize
        DIV     CX
        SUB     CX,DX
        MOV     SI,DX
        MOV     DX,ES:[DI].TEmsStream.Handle
        CMP     DX,EmsCurHandle
        JNE     @@1
        CMP     AX,EmsCurPage
        JE      @@3
    @@1:MOV     BX,AX
        MOV     AX,4400H
        INT     67H
        MOV     AL,AH
        AND     AX,0FFH
        JE      @@2
        MOV     DX,st_Error
        JMP     @@3
    @@2:MOV     EmsCurHandle,DX
        MOV     EmsCurPage,BX
    @@3:
    end;

   procedure EmsSetPages; near; assembler;
    asm
        CMP     EmsVersion,40H
        JAE     @@1
        MOV     AX,84H
        JMP     @@2
    @@1:MOV     DX,ES:[DI].TEmsStream.Handle
        MOV     BX,AX
        MOV     AH,51H
        INT     67H
        MOV     AL,AH
        AND     AX,0FFH
        JNE     @@2
        MOV     ES:[DI].TEmsStream.PageCount,BX
    @@2:
    end;

   constructor TEmsStream.Init(AMinSize, AMaxSize: longint); assembler;
    const
     EmsDeviceLen = 8;
     EmsDeviceStr: array[1..EmsDeviceLen] of Char = 'EMMXXXX0';
    asm
        XOR     AX,AX
        PUSH    AX
        LES     DI,Self
        PUSH    ES
        PUSH    DI
        CALL    TStream.Init
        MOV     AX,3567H
        INT     21H
        MOV     CX,EmsDeviceLen
        MOV     SI,OFFSET EmsDeviceStr
        MOV     DI,0AH
        CLD
        REP     CMPSB
        LES     DI,Self
        MOV     AX,-1
        JNE     @@3
        MOV     AH,41H
        INT     67H
        MOV     EmsBaseSeg,BX
        MOV     AH,46H
        INT     67H
        MOV     EmsVersion,AL
        MOV     CX,EmsPageSize
        MOV     AX,AMinSize.WORD[0]
        MOV     DX,AMinSize.WORD[2]
        ADD     AX,EmsPageSize-1
        ADC     DX,0
        DIV     CX
        MOV     BX,AX
        CMP     EmsVersion,40H
        JAE     @@2
        PUSH    AX
        MOV     AX,AMaxSize.WORD[0]
        MOV     DX,AMaxSize.WORD[2]
        ADD     AX,EmsPageSize-1
        ADC     DX,0
        DIV     CX
        MOV     CX,AX
        MOV     AH,42H
        INT     67H
        POP     AX
        CMP     BX,CX
        JB      @@1
        MOV     BX,CX
    @@1:CMP     BX,AX
        JA      @@2
        MOV     BX,AX
    @@2:MOV     AH,43H
        INT     67H
        MOV     AL,AH
        AND     AX,0FFH
        JE      @@4
    @@3:MOV     DX,st_InitError
        CALL    DoChannelError
        MOV     DX,-1
        XOR     BX,BX
    @@4:MOV     ES:[DI].TEmsStream.Handle,DX
        MOV     ES:[DI].TEmsStream.PageCount,BX
	XOR	AX,AX
	ADD	DI,OFFSET TEmsStream.EmsSize
	MOV	CX,4
	REP	STOSW
    end;

   constructor TEmsStream.Load(Channel :PChannel);
     var APos,ASize :longint;
    begin
     with Channel^  do begin
      Buf_Get(PageCount,SizeOf(PageCount));
      Buf_Get(ASize,SizeOf(ASize));
      Buf_Get(APos,SizeOf(APos));
     end;
     Position:=PageCount*EmsPageSize;
     Init(ASize,Position);
     Copy(Channel^,ASize);
     Pos_Set(APos)
    end;

   destructor TEmsStream.Done; assembler;
    asm
        LES     DI,Self
        MOV     DX,ES:[DI].TEmsStream.Handle
        CMP     DX,-1
        JE      @@1
        MOV     AH,45H
        INT     67H
    @@1:XOR     AX,AX
        PUSH    AX
        PUSH    ES
        PUSH    DI
        CALL    TStream.Done
    end;

   function TEmsStream.Pos_Get: longint; assembler;
    asm
        LES     DI,Self
        CMP     ES:[DI].TEmsStream.Status,0
        JNE     @@1
        MOV     AX,ES:[DI].TEmsStream.Position.WORD[0]
        MOV     DX,ES:[DI].TEmsStream.Position.WORD[2]
        JMP     @@2
    @@1:MOV     AX,-1
        CWD
    @@2:
    end;

   function TEmsStream.Size: longint; assembler;
    asm
        LES     DI,Self
        CMP     ES:[DI].TEmsStream.Status,0
        JNE     @@1
        MOV     AX,ES:[DI].TEmsStream.EmsSize.WORD[0]
        MOV     DX,ES:[DI].TEmsStream.EmsSize.WORD[2]
        JMP     @@2
    @@1:MOV     AX,-1
        CWD
    @@2:
    end;

   procedure TEmsStream.Store(Channel :PChannel);
     var APos :longint;
    begin
     APos:=Position;
     with Channel^ do begin
      Buf_Put(PageCount,SizeOf(PageCount));
      Buf_Put(EmsSize,SizeOf(EmsSize));
      Buf_Put(Position,SizeOf(Position));
      Copy(Self,EmsSize)
     end;
     Pos_Set(APos)
    end;

   procedure TEmsStream.Buf_Get(var Buf; Count: word); assembler;
    asm
        LES     DI,Self
        XOR     BX,BX
        CMP     BX,ES:[DI].TEmsStream.Status
        JNE     @@3
        MOV     AX,ES:[DI].TEmsStream.Position.WORD[0]
        MOV     DX,ES:[DI].TEmsStream.Position.WORD[2]
        ADD     AX,Count
        ADC     DX,BX
        CMP     DX,ES:[DI].TEmsStream.EmsSize.WORD[2]
        JA      @@1
        JB      @@7
        CMP     AX,ES:[DI].TEmsStream.EmsSize.WORD[0]
        JBE     @@7
    @@1:XOR     AX,AX
        MOV     DX,st_ReadError
    @@2:CALL    DoChannelError
    @@3:LES     DI,Buf
        MOV     CX,Count
        XOR     AL,AL
        CLD
        REP     STOSB
        JMP     @@8
    @@5:PUSH    BX
        CALL    EmsSelectPage
        POP     BX
        JNE     @@2
        MOV     AX,Count
        SUB     AX,BX
        CMP     CX,AX
        JB      @@6
        MOV     CX,AX
    @@6:ADD     ES:[DI].TEmsStream.Position.WORD[0],CX
        ADC     ES:[DI].TEmsStream.Position.WORD[2],0
        PUSH    ES
        PUSH    DS
        PUSH    DI
        LES     DI,Buf
        ADD     DI,BX
        ADD     BX,CX
        MOV     DS,EmsBaseSeg
        CLD
        REP     MOVSB
        POP     DI
        POP     DS
        POP     ES
    @@7:CMP     BX,Count
        JB      @@5
    @@8:
    end;

   procedure TEmsStream.Pos_Set(Pos: longint); assembler;
    asm
        LES     DI,Self
        MOV     AX,Pos.WORD[0]
        MOV     DX,Pos.WORD[2]
        OR      DX,DX
        JNS     @@1
        XOR     AX,AX
        CWD
    @@1:MOV     ES:[DI].TEmsStream.Position.WORD[0],AX
        MOV     ES:[DI].TEmsStream.Position.WORD[2],DX
    end;

   procedure TEmsStream.Truncate; assembler;
    asm
        LES     DI,Self
        XOR     BX,BX
        CMP     ES:[DI].TEmsStream.Status,BX
        JNE     @@2
        CMP     EmsVersion,40H
        JB      @@1
        MOV     AX,ES:[DI].TEmsStream.Position.WORD[0]
        MOV     DX,ES:[DI].TEmsStream.Position.WORD[2]
        ADD     AX,EmsPageSize-1
        ADC     DX,BX
        MOV     CX,EmsPageSize
        DIV     CX
        CALL    EmsSetPages
        JE      @@1
        MOV     DX,st_Error
        CALL    DoChannelError
        JMP     @@2
    @@1:MOV     AX,ES:[DI].TEmsStream.Position.WORD[0]
        MOV     DX,ES:[DI].TEmsStream.Position.WORD[2]
        MOV     ES:[DI].TEmsStream.EmsSize.WORD[0],AX
        MOV     ES:[DI].TEmsStream.EmsSize.WORD[2],DX
    @@2:
    end;

   procedure TEmsStream.Buf_Put(const Buf; Count: word); assembler;
    asm
        LES     DI,Self
        XOR     BX,BX
        CMP     BX,ES:[DI].TEmsStream.Status
        JNE     @@7
        MOV     AX,ES:[DI].TEmsStream.Position.WORD[0]
        MOV     DX,ES:[DI].TEmsStream.Position.WORD[2]
        ADD     AX,Count
        ADC     DX,BX
        ADD     AX,EmsPageSize-1
        ADC     DX,BX
        MOV     CX,EmsPageSize
        DIV     CX
        CMP     AX,ES:[DI].TEmsStream.PageCount
        JBE     @@4
        PUSH    BX
        CALL    EmsSetPages
        POP     BX
        JE      @@4
    @@1:MOV     DX,st_WriteError
        CALL    DoChannelError
        JMP     @@7
    @@2:PUSH    BX
        CALL    EmsSelectPage
        POP     BX
        JNE     @@1
        MOV     AX,Count
        SUB     AX,BX
        CMP     CX,AX
        JB      @@3
        MOV     CX,AX
    @@3:ADD     ES:[DI].TEmsStream.Position.WORD[0],CX
        ADC     ES:[DI].TEmsStream.Position.WORD[2],0
        PUSH    ES
        PUSH    DS
        PUSH    DI
        MOV     DI,SI
        MOV     ES,EmsBaseSeg
        LDS     SI,Buf
        ADD     SI,BX
        ADD     BX,CX
        CLD
        REP     MOVSB
        POP     DI
        POP     DS
        POP     ES
    @@4:CMP     BX,Count
        JB      @@2
    @@5:MOV     AX,ES:[DI].TEmsStream.Position.WORD[0]
        MOV     DX,ES:[DI].TEmsStream.Position.WORD[2]
        CMP     DX,ES:[DI].TEmsStream.EmsSize.WORD[2]
        JB      @@7
        JA      @@6
        CMP     AX,ES:[DI].TEmsStream.EmsSize.WORD[0]
        JBE     @@7
    @@6:MOV     ES:[DI].TEmsStream.EmsSize.WORD[0],AX
        MOV     ES:[DI].TEmsStream.EmsSize.WORD[2],DX
    @@7:
    end;

   constructor TDosVector.Build(AStream :PStream; AHeadSize,ADataSize :word);
    begin
     if AStream = nil then Fail;
     inherited Init;
     Stream:=AStream;
     DataSize:=ADataSize;
     HeadSize:=AHeadSize
    end;

   constructor TDosVector.Load(Channel :PChannel);
    begin
     inherited Init;
     with Channel^ do begin
      Buf_Get(DataSize,SizeOf(DataSize));
      Buf_Get(HeadSize,SizeOf(HeadSize));
      Stream:=Obj_Get
     end
    end;

   destructor TDosVector.Done;
    begin
     Stream^.Free
    end;

   function TDosVector.Power :longint;
    begin
     Power:=(Stream^.Size-HeadSize) div DataSize
    end;

   procedure TDosVector.Clear;
    begin
     Stream^.Clear
    end;

   procedure TDosVector.Del(Addr :longint);
    begin
     with Stream^ do begin
      Pos_Set(HeadSize+Addr*DataSize);
      Buf_Del(DataSize)
     end
    end;

   procedure TDosVector.Flush;
    begin
     Stream^.Flush
    end;

   procedure TDosVector.Get(Addr :longint; var Data);
    begin
     with Stream^ do begin
      Pos_Set(HeadSize+Addr*DataSize);
      Buf_Get(Data,DataSize);
     end
    end;

   procedure TDosVector.Ins(Addr :longint; const Data);
    begin
     with Stream^ do begin
      Pos_Set(HeadSize+Addr*DataSize);
      Buf_Ins(Data,DataSize)
     end
    end;

   procedure TDosVector.Move(Source,Dest :longint);
     var Buff :pointer;
    begin
     if Source = Dest then Exit;
     GetMem(Buff,DataSize);
     Source:=HeadSize+Source*DataSize;
     Dest:=HeadSize+Dest*DataSize;
     with Stream^ do begin
      Pos_Set(Source);
      Buf_Get(Buff^,DataSize);
      if Source < Dest then Buf_Move(Source+DataSize,Source,Dest-Source)
      else Buf_Move(Dest,Dest+DataSize,Source-Dest);
      Pos_Set(Dest);
      Buf_Put(Buff^,DataSize)
     end;
     FreeMem(Buff,DataSize)
    end;

   procedure TDosVector.Put(Addr :longint; const Data);
    begin
     with Stream^ do begin
      Pos_Set(HeadSize+Addr*DataSize);
      Buf_Put(Data,DataSize);
     end
    end;

   procedure TDosVector.Store(Channel :PChannel);
    begin
     with Channel^ do begin
      Buf_Put(DataSize,SizeOf(DataSize));
      Buf_Put(HeadSize,SizeOf(HeadSize));
      Obj_Put(Stream)
     end
    end;

  type

   PPage = ^TPage;
   TPage = object(TFantom)
    Home :longint;
    Buffer :PData;
    Master :PBufVector;
    First,Last :word;
    Left,Right :PPage;
    constructor Init(AMaster :PBufVector; AHome :longint);
    destructor Done; virtual;
    function  RPtr(Addr :word) :pointer;
    function  WPtr(Addr :word) :pointer;
    procedure Delete;
    procedure Flush;
    procedure Insert;
    procedure Get(Addr :word; var Data);
    procedure Put(Addr :word; const Data);
   end;

  const

    TBufVector_Max :longint = $7FFFFFFF;

   constructor TPage.Init(AMaster :PBufVector; AHome :longint);
    begin
     inherited Init;
     Master:=AMaster;
     Home:=AHome;
     Insert;
     with Master^ do begin
      Last:=PageSize*DataSize;
      GetMem(Buffer,Last);
      with Stream^ do begin
       Pos_Set(Home*DataSize+HeadSize);
       Buf_Get(Buffer^,Last);
       if Status = st_ReadError then Status:=st_Ok
      end;
      First:=PageSize
     end;
     Last:=0
    end;

   destructor TPage.Done;
    begin
     Flush;
     with Master^ do FreeMem(Buffer,PageSize*DataSize);
     Delete;
     inherited Done
    end;

   function TPage.RPtr(Addr :word) :pointer; assembler;
    asm
        LES  DI, Self
        MOV  AX, Addr
        LES  DI, ES:[DI].Master
        MUL  ES:[DI].TBufVector.DataSize
        LES  DI, Self
        LES  DI, ES:[DI].Buffer
        ADD  AX, DI
        MOV  DX, ES
    end;

   function TPage.WPtr(Addr :word) :pointer; assembler;
    asm
        LES     DI, Self
        MOV     AX, Addr
        CMP     AX, ES:[DI].First
        JGE     @@1
        MOV     ES:[DI].First, AX
    @@1:CMP     AX, ES:[DI].Last
        JLE     @@2
        MOV     ES:[DI].Last, AX
    @@2:LES     DI, ES:[DI].Master
        MUL     ES:[DI].TBufVector.DataSize
        LES     DI, Self
        LES     DI, ES:[DI].Buffer
        ADD     AX, DI
        MOV     DX, ES
    end;

   procedure TPage.Flush;
    begin
     if First > Last then Exit;
     Inc(Last);
     with Master^ do begin
      First:=First*DataSize;
      Last:=Last*DataSize;
      with Stream^ do  begin
       Pos_Set((Home*DataSize)+First+HeadSize);
       Buf_Put(Buffer^[First],Last-First)
      end;
      First:=PageSize
     end;
     Last:=0
    end;

   procedure TPage.Delete;
    begin
     with Master^ do begin
      if Left = nil then Pages:=Right else Left^.Right:=Right;
      if Right <> nil then Right^.Left:=Left
     end
    end;

   procedure TPage.Insert;
    begin
     with Master^ do begin
      if Pages = nil then Right:=nil else begin
       Right:=Pages;
       Right^.Left:=@Self
      end;
      Pages:=@Self
     end;
     Left:=nil
    end;

   procedure TPage.Get(Addr :word; var Data); assembler;
    asm
        LES     DI, Self
        LES     DI, ES:[DI].Master
        MOV     AX, ES:[DI].TDosVector.DataSize
        MOV     BX, AX
        MUL     Addr
        LES     DI, Self
        LES     DI, ES:[DI].Buffer
        ADD     DI, AX
        PUSH    ES
        PUSH    DI
        PUSH    WORD PTR Data[2]
        PUSH    WORD PTR Data[0]
        PUSH    BX
        CALL    Buf_Copy
    end;

   procedure TPage.Put(Addr :word; const Data); assembler;
    asm
        LES     DI, Self
        MOV     AX, Addr
        CMP     AX, ES:[DI].First
        JGE     @@1
        MOV     ES:[DI].First, AX
    @@1:CMP     AX, ES:[DI].Last
        JLE     @@2
        MOV     ES:[DI].Last, AX
    @@2:LES     DI, ES:[DI].Master
        MOV     AX, ES:[DI].TDosvector.DataSize
        MOV     BX, AX
        MUL     Addr
        LES     DI, Self
        LES     DI, ES:[DI].Buffer
        ADD     DI, AX
        PUSH    WORD PTR Data[2]
        PUSH    WORD PTR Data[0]
        PUSH    ES
        PUSH    DI
        PUSH    BX
        CALL    Buf_Copy
    end;

   constructor TBufVector.Build(AStream :PStream; AHeadSize,ADataSize,APageSize :word);
    begin
     if not inherited Build(AStream,AHeadSize,ADataSize) then Fail;
     PageSize:=APageSize div DataSize
    end;

   constructor TBufVector.Load(Channel :PChannel);
    begin
     inherited Load(Channel);
     Channel^.Buf_Get(PageSize,SizeOf(PageSize))
    end;

   destructor TBufVector.Done;
    begin
     FreeBuffer;
     inherited Done
    end;

   function TBufVector.DoFind(Addr :longint) :pointer; assembler;
    asm
        MOV     AX, WORD PTR Addr[2]
        MOV     DX, WORD PTR Addr[0]
        LES     DI, Self
        LES     DI, ES:[DI].TBufVector.Pages
    @@1:MOV     BX, ES
        OR      BX, DI
        JE      @@3
        CMP     AX, WORD PTR ES:[DI].TPage.Home[2]
        JNE     @@2
        CMP     DX, WORD PTR ES:[DI].TPage.Home[0]
        JE      @@3
    @@2:LES     DI, ES:[DI].TPage.Right
        JMP     @@1
    @@3:MOV     AX, DI
        MOV     DX, ES
    end;

   function TBufVector.DoPage(Addr :longint) :pointer;
     var Res :PPage;
    begin
     Res:=DoFind(Addr);
     if Res <> nil then Res^.GotoHit else New(Res,Init(@Self,Addr));
     DoPage:=Res
    end;

   function TBufVector.Power :longint; assembler;
    asm
        LES     DI, Self
        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        CALL    TBufVector.Flush
        CALL    TDosVector.Power
    end;

   function TBufVector.RPtr(Addr :longint) :pointer;
     var SubAddr :word;
    begin
     SubAddr:=Addr mod PageSize;
     RPtr:=TPage(DoPage(Addr-SubAddr)^).RPtr(SubAddr)
    end;

   function TBufVector.WPtr(Addr :longint) :pointer;
     var SubAddr :word;
    begin
     SubAddr:=Addr mod PageSize;
     WPtr:=TPage(DoPage(Addr-SubAddr)^).WPtr(SubAddr)
    end;

   procedure TBufVector.Clear; assembler;
    asm
        LES     DI, Self
        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        CALL    TBufVector.FreeBuffer
        CALL    TDosVector.Clear
    end;

   procedure TBufVector.Del(Addr :longint); assembler;
    asm
        LES     DI, Self;
        MOV     AX, WORD PTR Addr[2]
        MOV     BX, WORD PTR Addr[0]
        PUSH    AX
        PUSH    BX
        PUSH    ES
        PUSH    DI
        PUSH    AX
        PUSH    BX
        PUSH    WORD PTR TBufVector_Max[2]
        PUSH    WORD PTR TBufVector_Max[0]
        PUSH    ES
        PUSH    DI
        CALL    DoFree
        CALL    TDosVector.Del
    end;

   procedure TBufVector.DoFree(Source,Dest :longint);
     var Curr : PPage;
    begin
     if Pages = nil then Exit;
     Source:=Source-Source mod PageSize;
     Dest:=Dest-Dest mod PageSize;
     Curr:=Pages;
     while Curr <> nil do with Curr^ do begin
      Curr:=Curr^.Right;
      if (Home >= Source) and (Home <= Dest) then Free
     end
    end;

   procedure TBufVector.FreeBuffer; assembler;
    asm
         LES     DI, Self
         LES     DI, ES:[DI].TBufVector.Pages
     @@1:MOV     AX, ES
         OR      AX, DI
         JE      @@2
         PUSH    WORD PTR ES:[DI].TPage.Right[2]
         PUSH    WORD PTR ES:[DI].TPage.Right[0]
         PUSH    ES
         PUSH    DI
         CALL    TPage.Free
         POP     DI
         POP     ES
         JMP     @@1
     @@2:
    end;

   procedure TBufVector.Get(Addr :longint; var Data);
     var SubAddr :word;
    begin
     SubAddr:=Addr mod PageSize;
     TPage(DoPage(Addr-SubAddr)^).Get(SubAddr,Data)
    end;

   procedure TBufVector.Ins(Addr :longint; const Data); assembler;
    asm
        LES     DI, Self;
        MOV     AX, WORD PTR Addr[2]
        MOV     BX, WORD PTR Addr[0]
        PUSH    AX
        PUSH    BX
        PUSH    WORD PTR Data[2]
        PUSH    WORD PTR Data[0]
        PUSH    ES
        PUSH    DI
        PUSH    AX
        PUSH    BX
        PUSH    WORD PTR TBufVector_Max[2]
        PUSH    WORD PTR TBufVector_Max[0]
        PUSH    ES
        PUSH    DI
        CALL    DoFree
        CALL    TDosVector.Ins
    end;

   procedure TBufVector.Flush; assembler;
    asm
         LES     DI, Self
         LES     DI, ES:[DI].TBufVector.Pages
     @@1:MOV     AX, ES
         OR      AX, DI
         JE      @@2
         PUSH    WORD PTR ES:[DI].TPage.Right[2]
         PUSH    WORD PTR ES:[DI].TPage.Right[0]
         PUSH    ES
         PUSH    DI
         CALL    TPage.Flush
         POP     DI
         POP     ES
         JMP     @@1
     @@2:
    end;

   procedure TBufVector.Move(Source,Dest :longint);
    begin
     if Source < Dest then DoFree(Source,Dest)
     else DoFree(Dest,Source);
     inherited Move(Source,Dest)
    end;

   procedure TBufVector.Put(Addr :longint; const Data);
     var SubAddr :word;
    begin
     SubAddr:=Addr mod PageSize;
     TPage(DoPage(Addr-SubAddr)^).Put(SubAddr,Data)
    end;

   procedure TBufVector.Store(Channel :PChannel);
    begin
     inherited Store(Channel);
     Channel^.Buf_Put(PageSize,SizeOf(PageSize))
    end;

   procedure Register_BufStream;
    begin
     Register_Type(IDT_BufStream,Ofs(TypeOf(TBufStream)^),
     @TBufStream.Load,@TBufStream.Store)
    end;

   procedure Register_BufVector;
    begin
     Register_Type(IDT_BufVector,Ofs(TypeOf(TBufVector)^),
     @TBufVector.Load,@TBufVector.Store)
    end;

   procedure Register_DosStream;
    begin
     Register_Type(IDT_DosStream,Ofs(TypeOf(TDosStream)^),
     @TDosStream.Load,@TDosStream.Store)
    end;

   procedure Register_DosVector;
    begin
     Register_Type(IDT_DosVector,Ofs(TypeOf(TDosVector)^),
     @TDosVector.Load,@TDosVector.Store)
    end;

   procedure Register_EmsStream;
    begin
     Register_Type(IDT_EmsStream,Ofs(TypeOf(TEmsStream)^),
     @TEmsStream.Load,@TEmsStream.Store)
    end;

  end.

