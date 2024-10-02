{      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³                                           ³
       ³      W h i t e   A p p l i c a t o r      ³
       ³                                           ³
       ³             U G r a p h  2.0              ³
       ³                                           ³
       ³       Copyright (c)  S.Novak  1995        ³
       ³                                           ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      }

 unit UGraph;

 {$S-,B-,V-,R-,I-,T-,X+}

 interface

  uses

  Graph, UObject;

  procedure Arc (X,Y: integer; StAngle, EndAngle, Radius: word);
  procedure Bar(X1,Y1,X2,Y2: integer);
  procedure Bar3D(X1,Y1,X2,Y2: integer; Depth: word; Top: Boolean);
  procedure Circle(X,Y: integer; Radius: word);
  procedure DrawPoly(NumPoints: word; var PolyPoints);
  procedure Ellipse(X,Y: integer; StAngle, EndAngle: word; XRadius, YRadius: word);
  procedure FillEllipse(X, Y: integer; XRadius, YRadius: word);
  procedure FillPoly(NumPoints: word; var PolyPoints);
  procedure FloodFill(X,Y: integer; Border: word);
  procedure GetArcCoords(var ArcCoords: ArcCoordsType);
  procedure GetImage(X1,Y1,X2,Y2: integer; var BitMap);
  function  GetPixel(X,Y: integer): word;
  function  GetX: integer;
  function  GetY: integer;
  procedure Line(X1,Y1,X2,Y2: integer);
  procedure LineTo(X,Y: integer);
  procedure MoveTo(X,Y: integer);
  procedure PieSlice(X,Y: integer; StAngle, EndAngle, Radius: word);
  procedure PutImage(X, Y: integer; var BitMap; BitBlt: word);
  procedure PutPixel(X,Y: integer; Pixel: word);
  procedure Rectangle(X1,Y1,X2,Y2: integer);
  procedure Sector(X,Y: integer; StAngle,EndAngle, XRadius, YRadius: word);
  procedure SetViewOrg(X,Y: integer);
  procedure OutTextXY(X,Y: integer; TextString: string);

  procedure S3D_Body(const R: TRect; Height: integer; const Color);
  procedure S3D_Rect(const R: TRect; Height: integer; const Color);
  procedure S3D_Text(X,Y: integer; const S: string; const Color);

  function  Font_Lng(N: byte): integer;
  procedure Font_Style(Font: word; Dir: integer);
  function  TextHeight(const S:string): word;

  function  Text_Ch(const S: string): char;
  function  Text_Lng(const S: string): integer;
  function  Text_Width(const S:string) :integer;
  procedure Text_Out(X,Y :integer; S :string);
  procedure Text_3D(X,Y :integer; S :string; const Color);

  const

   Org :TPoint = (X:0;Y:0);

  var

   VESA16 : Integer;

 implementation

{$IFDEF DPMI}

  uses

   WinApi;

{$ENDIF}

  procedure S3D_Body; assembler;
   asm
        LES   DI, Color
        MOV   DX, WORD PTR ES:[DI+2]
        MOV   CX, Height
        OR    CX, CX
        JNS   @@0
        NEG   CX
    @@0:LES   DI, R
        MOV   AX, ES:[DI].TRect.A.X
        MOV   BX, ES:[DI].TRect.B.X
        MOV   SI, ES:[DI].TRect.B.Y
        MOV   DI, ES:[DI].TRect.A.Y
        {Grow(-CX,-CX)}
        ADD   AX, CX
        SUB   BX, CX
        ADD   DI, CX
        SUB   SI, CX
        {Bar}
        PUSH  AX
        PUSH  DI
        PUSH  BX
        PUSH  SI
        {SetFillStyle}
        MOV   BX, SolidFill
        PUSH  BX
        PUSH  DX
        CALL  SetFillStyle
        CALL  Bar
        JMP   FAR PTR S3D_Rect+3
   end;

  procedure S3D_Rect; assembler;
   asm
        LES   DI, Color
        MOV   DX, WORD PTR ES:[DI]
        MOV   CX, Height
        OR    CX, CX
        JCXZ  @@3
        JNS   @@0
        XCHG  DL, DH
        NEG   CX
    @@0:
        LES   DI, R
        MOV   AX, ES:[DI].TRect.A.X
        MOV   BX, ES:[DI].TRect.B.X
        MOV   SI, ES:[DI].TRect.B.Y
        MOV   DI, ES:[DI].TRect.A.Y
        {Move(OX,OY)}
        ADD   AX, Org.X
        ADD   BX, Org.X
        ADD   SI, Org.Y
        ADD   DI, Org.Y
        MOV   ES, CX
   @@1: {LineTo}
        PUSH  AX
        PUSH  SI
        {LineTo}
        PUSH  BX
        PUSH  SI
        {SetColor}
        XCHG  DL, DH
        PUSH  DX
        {LineTo}
        PUSH  BX
        PUSH  DI
        {LineTo}
        PUSH  AX
        PUSH  DI
        {MoveTo}
        PUSH  AX
        PUSH  SI
        {SetColor}
        XCHG  DL, DH
        PUSH  DX
        {Grow(-1 -1)}
        INC   AX
        INC   DI
        DEC   BX
        DEC   SI
        REPZ  LOOP @@1
        PUSH  ES
        PUSH  CX
        PUSH  CX
        PUSH  CX
        CALL  SetLineStyle
        POP   CX
   @@2: MOV   Height,CX
        CALL  SetColor
        CALL  Graph.MoveTo
        CALL  Graph.LineTo
        CALL  Graph.LineTo
        CALL  SetColor
        CALL  Graph.LineTo
        CALL  Graph.LineTo
        MOV   CX,Height
        REPZ  LOOP @@2
   @@3:
   end;

  procedure S3D_Text;assembler;
   asm
        MOV  DX, DS
        MOV  AX, Org.X
        ADD  X,  AX
        MOV  AX, Org.Y
        ADD  Y,  AX
        LES  DI, Color
        LDS  SI, S
        PUSH X
        PUSH Y
        PUSH DS
        PUSH SI
        PUSH WORD PTR ES:[DI]
        INC  X
        INC  Y
        PUSH X
        PUSH Y
        PUSH DS
        PUSH SI
        PUSH WORD PTR ES:[DI+1]
        MOV  DS, DX
        CALL SetColor
        CALL Graph.OutTextXY
        CALL SetColor
        CALL Graph.OutTextXY
   end;

  function  Font_Lng(N: byte): integer;
   begin
    Font_Lng:=TextWidth(' ')*N
   end;

  procedure Font_Style(Font: word; Dir: integer); assembler;
   asm
        MOV AX, Font
        MOV BX, AX
        XOR AH, AH
        XOR BL, BL
        XCHG BL, BH
        PUSH AX
        PUSH Dir
        PUSH BX
        CALL SetTextStyle
   end;

  procedure Board(X1,Y1,X2,Y2,Heigth: integer; Color: word); assembler;
   asm
        MOV   AX, Org.X
        ADD   X1, AX
        ADD   X2, AX
        MOV   AX, Org.Y
        ADD   Y1, AX
        ADD   Y2, AX
        XOR   AX, AX
        PUSH  AX
        PUSH  AX
        PUSH  AX
        CALL  SetLineStyle;
        MOV   AX, Color
        MOV   CX, Heigth
        OR    CX, CX
        JCXZ  @@2
        JNS   @@1
        XCHG  AL, AH
        NEG   CX
    @@1:PUSH  CX
        PUSH  AX
        PUSH  X1
        PUSH  Y2
        PUSH  X2
        PUSH  Y2
        PUSH  AX
        PUSH  X2
        PUSH  Y1
        PUSH  X1
        PUSH  Y1
        PUSH  X1
        PUSH  Y2
        XCHG  AL, AH
        PUSH  AX
        INC   X1
        INC   Y1
        DEC   X2
        DEC   Y2
        CALL  SetColor
        CALL  Graph.MoveTo
        CALL  Graph.LineTo
        CALL  Graph.LineTo
        CALL  SetColor
        CALL  Graph.LineTo
        CALL  Graph.LineTo
        POP   AX
        POP   CX
        REPZ  LOOP @@1
    @@2:
   end;

  function Text_Lng(const S: String): integer; assembler;
   asm
        LES   DI, S
	MOV   CL, ES:[DI]
	INC   DI
	XOR   CH, CH
        MOV   BX, CX
        MOV   AL, '&'
        CLD
        REPNE SCASB
        OR    CX, CX
        JE    @@1
        DEC   BX
    @@1:MOV   AX, BX
    end;

  function Text_Ch(const S: String): char; assembler;
   asm
        LES   DI, S
	MOV   CL, ES:[DI]
	INC   DI
	XOR   CH, CH
        MOV   BX, CX
        MOV   AL, '&'
        CLD
        REPNE SCASB
        OR    CX, CX
        JE    @@1
        MOV   AX, ES:[DI]
        JMP   @@2
    @@1:XOR   AX, AX
    @@2:
   end;

  function Text_Width(const S:string) :integer;
   begin
    Text_Width:=Text_Lng(S)*TextWidth(' ')
   end;

  function PressStr(var S: string): byte; assembler;
    asm
        MOV   DX, DS
        LES   DI, S
        LDS   SI, S
	MOV   CL, ES:[DI]
	INC   DI
	XOR   CH, CH
        MOV   BX, CX
        MOV   AL,'&'
        CLD
        REPNE SCASB
        OR    CX, CX
        JE    @@2
        MOV   AX, BX
        SUB   AX, CX
        DEC   BX
        MOV   DS:[SI], BL
        MOV   SI, DI
        DEC   DI
        MOV   BX, ES
        MOV   DS, BX
        MOV   BX, CX
        JNP   @@1
        MOVSB
    @@1:REPZ  MOVSW
        JMP   @@3
    @@2:XOR   AX, AX
    @@3:MOV   DS, DX
    end;

  procedure Text_Out(X,Y :integer; S :string);
    var O,W: integer;
   begin
    O:=PressStr(S);
    SetTextJustify(LeftText,BottomText);
    Inc(X,Org.X);
    Inc(Y,Org.Y);
    Graph.OutTextXY(X,Y,S);
    if O = 0 then Exit;
    W:=TextWidth(' ');
    Inc(X,(O-1)*W);
    Graph.Line(X,Y,X+W,Y)
   end;

  procedure Text_3D(X,Y :integer; S :string; const Color);
    var O,W: integer;
   begin
    O:=PressStr(S);
    SetTextJustify(LeftText,BottomText);
    S3D_Text(X,Y,S,Color);
    if O = 0 then Exit;
    W:=TextWidth(' ');
    Inc(X,(O-1)*W);
    Line(X,Y,X+W,Y)
   end;

  procedure Line(X1,Y1,X2,Y2: integer);  assembler;
   asm
        MOV AX, Org.X
        ADD X1, AX
        ADD X2, AX
        MOV AX, Org.Y
        ADD Y1, AX
        ADD Y2, AX
        JMP FAR PTR Graph.Line+3
   end;

  procedure LineTo(X,Y: integer);  assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.LineTo+3
    end;

  function GetPixel(X,Y: integer): word;  assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.GetPixel+3
   end;

  procedure PutPixel(X,Y: integer; Pixel: word);  assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.PutPixel+3
   end;

  function GetX: integer;  assembler;
   asm
        CALL FAR PTR Graph.GetX;
        SUB AX, Org.X
   end;

  function GetY: integer;  assembler;
   asm
        CALL FAR PTR Graph.GetY;
        SUB AX, Org.Y
   end;

  procedure MoveTo(X,Y: integer);  assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.MoveTo+3
   end;

  procedure Bar(X1,Y1,X2,Y2: integer);  assembler;
   asm
        MOV AX, Org.X
        ADD X1, AX
        ADD X2, AX
        MOV AX, Org.Y
        ADD Y1, AX
        ADD Y2, AX
        JMP FAR PTR Graph.Bar+3
   end;

  procedure Bar3D(X1,Y1,X2,Y2: integer; Depth: word; Top: Boolean); assembler;
   asm
        MOV AX, Org.X
        ADD X1, AX
        ADD X2, AX
        MOV AX, Org.Y
        ADD Y1, AX
        ADD Y2, AX
        JMP FAR PTR Graph.Bar3D+3
   end;

  procedure FloodFill(X,Y: integer; Border: word);  assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.FloodFill+3
    end;

  procedure Rectangle(X1,Y1,X2,Y2: integer);  assembler;
    asm
        MOV AX, Org.X
        ADD X1, AX
        ADD X2, AX
        MOV AX, Org.Y
        ADD Y1, AX
        ADD Y2, AX
        JMP FAR PTR Graph.Rectangle+3
    end;

  procedure Arc (X,Y: integer; StAngle, EndAngle, Radius: word); assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.Arc+3
   end;

  procedure Circle(X,Y: integer; Radius: word); assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.Circle+3
   end;

  procedure Ellipse(X,Y: integer; StAngle, EndAngle: word; XRadius, YRadius: word);  assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.Ellipse+3
   end;

  procedure FillEllipse(X, Y: integer; XRadius, YRadius: word);  assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.FillEllipse+3
   end;

  procedure PieSlice(X,Y: integer; StAngle, EndAngle, Radius: word); assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.PieSlice+3
   end;

  procedure Sector(X,Y: integer; StAngle,EndAngle, XRadius, YRadius: word); assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.Sector+3
   end;

  procedure OutTextXY(X,Y: integer; TextString: string);   assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.OutTextXY+3
    end;

  procedure GetImage(X1,Y1,X2,Y2: integer; var BitMap); assembler;
   asm
        MOV AX, Org.X
        ADD X1, AX
        ADD X2, AX
        MOV AX, Org.Y
        ADD Y1, AX
        ADD Y2, AX
        JMP FAR PTR Graph.GetImage+3
   end;

  procedure PutImage(X, Y: integer; var BitMap; BitBlt: word);  assembler;
   asm
        MOV AX, Org.X
        ADD X,  AX
        MOV AX, Org.Y
        ADD Y,  AX
        JMP FAR PTR Graph.PutImage+3
    end;

  procedure DrawPoly(NumPoints: word; var PolyPoints);  assembler;
   asm
        LES   DI, PolyPoints
        MOV   CX, NumPoints;
        PUSH  CX
        PUSH  ES
        PUSH  DI
        MOV   AX, Org.X
        MOV   DX, Org.Y
        CLD
    @@1:ADD   ES:[DI+BX],AX
        SHL   BX, 1
        ADD   ES:[DI+BX],DX
        SHL   BX, 1
        REPZ  LOOP @@1
        CALL  Graph.DrawPoly
        LES   DI, PolyPoints
        MOV   CX, NumPoints;
        MOV   AX, Org.X
        MOV   DX, Org.Y
        CLD
    @@2:SUB   ES:[DI+BX],AX
        SHL   BX, 1
        SUB   ES:[DI+BX],DX
        SHL   BX, 1
        REPZ  LOOP @@2
   end;

  procedure FillPoly(NumPoints: word; var PolyPoints);  assembler;
   asm
        LES   DI, PolyPoints
        MOV   CX, NumPoints;
        PUSH  CX
        PUSH  ES
        PUSH  DI
        MOV   AX, Org.X
        MOV   DX, Org.Y
        CLD
    @@1:ADD   ES:[DI+BX],AX
        SHL   BX, 1
        ADD   ES:[DI+BX],DX
        SHL   BX, 1
        REPZ  LOOP @@1
        CALL  Graph.FillPoly
        LES   DI, PolyPoints
        MOV   CX, NumPoints;
        MOV   AX, Org.X
        MOV   DX, Org.Y
        CLD
    @@2:SUB   ES:[DI+BX],AX
        SHL   BX, 1
        SUB   ES:[DI+BX],DX
        SHL   BX, 1
        REPZ  LOOP @@2
   end;

  procedure GetArcCoords(var ArcCoords: ArcCoordsType);  assembler;
   asm
        PUSH  word PTR ArcCoords[2]
        PUSH  WORD PTR ArcCoords[0]
        CALL  Graph.GetArcCoords
        LES   DI, ArcCoords
        MOV   CX, 6;
        MOV   AX, Org.X
        MOV   DX, Org.Y
        CLD
    @@1:SUB   ES:[DI+BX],AX
        SHL   BX, 1
        SUB   ES:[DI+BX],DX
        SHL   BX, 1
        REPZ  LOOP @@1
   end;

  procedure SetViewOrg(X,Y: integer); assembler;
   asm
        MOV   AX, X
        MOV   Org.X, AX
        MOV   AX, Y
        MOV   Org.Y, AX
   end;

  type

   VgaInfoBlock = record
    VESASignature: array[0..3] of Byte;
    VESAVersion: Word;
    OEMStringPtr: Pointer;
    Capabilities: array[0..3] of Byte;
    VideoModePtr: Pointer;
   end;

  const

   VESA16Modes: array[0..2] of Word = ($0102,$0104,$0106);

  function GetHighestCap(Table: Pointer; Modes: Word; Size: Integer): Integer;
    near; assembler;
   asm
        XOR     AX,AX
        LES     DI, Table
    @@1:MOV     SI, Modes
        ADD     SI, Size
        ADD     SI, Size
        MOV     BX, ES:[DI]
        CMP     BX, 0FFFFH
        JE      @@4
        INC     DI
        INC     DI
        MOV     CX,Size
    @@2:CMP     BX,[SI]
        JZ      @@3
        DEC     SI
        DEC     SI
        LOOP    @@2
    @@3:CMP     AX,CX
        JA      @@1
        MOV     AX,CX
        JMP     @@1
    @@4:
   end;

{$IFDEF DPMI}

  type

   TRealRegs = record
    RealEDI: Longint;
    RealESI: Longint;
    RealEBP: Longint;
    Reserved: Longint;
    RealEBX: Longint;
    RealEDX: Longint;
    RealECX: Longint;
    RealEAX: Longint;
    RealFlags: Word;
    RealES: Word;
    RealDS: Word;
    RealFS: Word;
    RealGS: Word;
    RealIP: Word;
    RealCS: Word;
    RealSP: Word;
    RealSS: Word;
   end;

  function DetectVesa16: Integer; far; assembler;
    var Segment, Selector, VesaCap: Word;
   asm
{$IFOPT G+}
        PUSH    0000H
        PUSH    0100H
{$ELSE}
        XOR     AX,AX
        PUSH    AX
        INC     AH
        PUSH    AX
{$ENDIF}
        CALL    GlobalDosAlloc
        MOV     Segment,DX
        MOV     Selector,AX
        MOV     DI,OFFSET RealModeRegs
        MOV     WORD PTR [DI].TRealRegs.RealSP, 0
        MOV     WORD PTR [DI].TRealRegs.RealSS, 0
        MOV     WORD PTR [DI].TRealRegs.RealEAX, 4F00H
        MOV     WORD PTR [DI].TRealRegs.RealES, DX
        MOV     WORD PTR [DI].TRealRegs.RealEDI, 0
        MOV     AX,DS
        MOV     ES,AX
        MOV     AX,0300H
        MOV     BX,0010H
        XOR     CX,CX
        INT     31H
        MOV     DI,OFFSET RealModeRegs
        MOV     AX,grError
        PUSH    AX
        CMP     WORD PTR [DI].TRealRegs.RealEAX,004FH
        JNZ     @@Exit
        POP     AX
        MOV     ES,Selector
        XOR     DI,DI
        CMP     ES:[DI].VgaInfoBlock.VESASignature.Word[0], 'EV'
        JNZ     @@Exit
        CMP     ES:[DI].VgaInfoBlock.VESASignature.Word[2], 'AS'
        JNZ     @@Exit
        MOV     AX,0000
        MOV     CX,1
        INT     31H
        MOV     VesaCap,AX
        MOV     DX,ES:[DI].VgaInfoBlock.VideoModePtr.Word[2]
        MOV     CX,4
        XOR     AX,AX
     @@Convert:
        SHL     DX,1
        RCL     AX,1
        LOOP    @@Convert
        ADD     DX,ES:[DI].VgaInfoBlock.VideoModePtr.Word[0]
        ADC     AX,0
        MOV     CX,AX
        MOV     BX,VesaCap
        MOV     AX,0007H
        INT     31H
        INC     AX
        XOR     CX,CX
        MOV     DX,0FFFFH
        INT     31H
        MOV     ES,BX
        PUSH    ES
        PUSH    DI
{$IFOPT G+}
        PUSH    OFFSET Vesa16Modes
        PUSH    0003H
{$ELSE}
        MOV     SI, OFFSET Vesa16Modes
        PUSH    SI
        MOV     AX, 5
        PUSH    AX
{$ENDIF}
        CALL    GetHighestCap
        PUSH    AX
        MOV     BX,VesaCap
        MOV     AX,0001H
        INT     31H
@@Exit:
        PUSH    Selector
        CALL    GlobalDosFree
        POP     AX
   end;

{$ELSE}

  function DetectVesa16: Integer; far; assembler;
    var VesaInfo: array[0..255] of Byte;
   asm
        MOV     AX,SS
        MOV     ES,AX
        LEA     DI,VesaInfo
        MOV     AX,4F00H
        INT     10H
        CMP     AX,004FH
        MOV     AX,grError
        JNZ     @@Exit
        CMP     ES:[DI].VgaInfoBlock.VESASignature.Word[0], 'EV'
        JNZ     @@Exit
        CMP     ES:[DI].VgaInfoBlock.VESASignature.Word[2], 'AS'
        JNZ     @@Exit
        LES     DI,ES:[DI].VgaInfoBlock.VideoModePtr
        PUSH    ES
        PUSH    DI
        MOV     AX, OFFSET Vesa16Modes
        PUSH    AX
        MOV     AX,3
        PUSH    AX
        CALL    GetHighestCap
    @@Exit:
   end;

{$ENDIF}

  function TextHeight(const S:string): word;
   begin
    TextHeight:=TextWidth('W')
   end;


  begin
{   VESA16 := InstallUserDriver('VESA16',@DetectVESA16)}
  end.

