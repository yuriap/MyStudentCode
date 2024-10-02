  Unit Windows;
  Interface
  Procedure MakeWindow(x,y,width,height,bc,tc  : word);
  Procedure WriteXY( x, y :  byte; str : string);
  Procedure BoxWindow(x, y, width, height, bc, tc : Word);
  Procedure DoubleBoxWindow(x, y, width, height, bc, tc : Word);
  Procedure ShadowBoxWindow(x, y, width, height, bc, tc : Word);
  Procedure ShadowDoubleBoxWindow(x, y, width, height, bc, tc : Word);
  Implementation
  uses Crt;
  Procedure MakeWindow(x,y,width,height,bc,tc  : word);

  Begin
	Window(X,Y,X+Width,Y+Height);
	TextBackground(Bc);
	TextColor(Tc);
	ClrScr;
  End; { MakeWindow }
   Procedure WriteXY( x, y :  byte; str : string);

   Begin
	 GoToXY(x,y);
	 Write(str);
   End; { WriteXY }
     Procedure BoxWindow(x, y, width, height, bc, tc : Word);

   Var  i   :  Integer ;

	Begin
	   MakeWindow(x, y, width, height, bc, tc);
		for i:=2 to width do WriteXY(i,1,Chr(196));
		 for i:=2 to height+1 do WriteXY(2,i,Chr(179));
		  for i:=2 to height+1 do WriteXY(width,i,Chr(179));
		   for i:=2 to width do WriteXY(i,height+1,Chr(196));
		WriteXY(2,1,Chr(218));
		 WriteXY(width,1,Chr(191));
		  WriteXY(2,height+1,Chr(192));
		   WriteXY(width,height+1,Chr(217));
	End; { BoxWindow }


  Procedure DoubleBoxWindow(x, y, width, height, bc, tc : Word);

   Var  i   :  Integer ;

	Begin
	   MakeWindow(x, y, width, height, bc, tc);
		for i:=2 to width do WriteXY(i,1,Chr(205));
		 for i:=2 to height+1 do WriteXY(2,i,Chr(186));
		  for i:=2 to height+1 do WriteXY(width,i,Chr(186));
		   for i:=2 to width do WriteXY(i,height+1,Chr(205));
		WriteXY(2,1,Chr(201));
		 WriteXY(width,1,Chr(187));
		  WriteXY(2,height+1,Chr(200));
		   WriteXY(width,height+1,Chr(188));
	End; { DoubleBoxWindow }

  Procedure ShadowBoxWindow(x, y, width, height, bc, tc : Word);

   Var  i   :  Integer ;

	Begin
	   MakeWindow(x+2, y+1, width, height, 0, tc);
	   BoxWindow(x, y, width, height, bc, tc);
	End; { ShadowBoxWindow }

  Procedure ShadowDoubleBoxWindow(x, y, width, height, bc, tc : Word);

   Var  i   :  Integer ;

	Begin
	  MakeWindow(x+2,y+1,width,height,0,15);
	  DoubleBoxWindow(x, y, width, height, bc, tc);
	End; { ShadowDoubleBoxWindow }
  Begin
  End.