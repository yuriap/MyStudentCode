{      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³                                           ³
       ³          E a s t   S t u d i o            ³
       ³                                           ³
       ³             U G r a p h  1.0              ³
       ³                                           ³
       ³       Copyright (c)  S.Novak  1996        ³
       ³                                           ³
       ³               (interface)                 ³
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
  procedure OutTextRect(const R: TRect; S: string; Color: byte);

  procedure Font_Style(Font: word; Dir: integer);

  function  HotStr_Ch(const S: string): char;
  function  HotStr_Lng(const S: string): integer;
  function  HotStr_Width(const S:string) :integer;
  procedure HotStr_Out(X,Y :integer; S :string);

  procedure S3D_Body(const R: TRect; Height: integer; const Color);
  procedure S3D_Rect(const R: TRect; Height: integer; const Color);
  procedure S3D_Str(X,Y: integer; const S: string; const Color);
  procedure S3D_HotStr(X,Y :integer; S :string; const Color);

  const

   Org :TPoint = (X:0;Y:0);

  var

   VESA16 : Integer;

{End Interface}