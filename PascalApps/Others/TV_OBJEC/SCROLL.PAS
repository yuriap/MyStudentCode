Unit Scroll;
Interface
Uses Views,Objects,Drivers,Interior;
Type
    DialogData = record
       CheckBoxData : Word;
       RadioButtonsData : Word;
       InputLineData : String[128];
       end;

    PDemoWindow =^TDemoWindow;
    TDemoWindow = object(TWindow)
       constructor Init(Bounds:TRect;WinTitle:string;WindowNo:Word);
       procedure MakeInterior(Bounds:TRect);
    end;
    PInterior = ^TInterior;
    TInterior = object(TScroller)
       constructor Init(var Bounds:TRect;AHScrollBar,AVScrollBar: PScrollBar);
       procedure Draw;virtual;
       end;
    PInteriors = ^TInteriors;
    TInteriors = object(TView)
       constructor Init(var Bounds:TRect);
       procedure Draw;virtual;
       end;
Const MaxLines = 100;
Var   Lines : array[0..MaxLines] of PString;
      LineCount : integer;
      DData : DialogData;
procedure ReadFile;
procedure DoneFile;
Implementation
constructor TInterior.Init(var Bounds:TRect;AHScrollBar,AVScrollBar:PScrollBar);
Begin

   inherited Init(Bounds,AHScrollBar,AVScrollBar);
   GrowMode:=gfGrowHiX+gfGrowHiY;
   SetLimit(128,LineCount);

end;
procedure TInterior.Draw;
Var
   Color:Byte;
   I,Y:Integer;
   B:TDrawBuffer;
Begin

   Color:=GetColor(1);
   For Y:=1 to Size.Y-1 do begin
      MoveChar(B,' ',Color,Size.X);
      i:=Delta.Y+Y;
      If (I<LineCount)and(Lines[I]<>nil) then
        MoveStr(B,Copy(Lines[I]^,Delta.X+1,Size.X),color);
        WriteLine(0,Y,Size.X,1,B);
   end;
{   For I := 1 To Size.Y-1 do
   begin
      WriteStr(0,I,Lines[I]^,$01);
   end;}

End;
constructor TDemoWindow.Init(Bounds:TRect;WinTitle:string;WindowNo:Word);
Var
   S:String;
begin
   Str(WindowNo,S);
   TWindow.Init(Bounds,WinTitle+' '+s,wnNoNumber);
   GetExtent(Bounds);
   Bounds.Grow(-1,-1);
   MakeInterior(Bounds);
end;
procedure TDemoWindow.MakeInterior(Bounds:TRect);
Var
   HScrollBar,VScrollBar:PScrollBar;
   Interior:PInterior;
   R:TRect;
begin
   VScrollBar:=StandardScrollBar(sbVertical+sbHandleKeyboard);
   HScrollBar:=StandardScrollBar(sbHorizontal+sbHandleKeyboard);
   Interior:=New(PInterior,Init(Bounds,HScrollBar,VScrollBar));
                   {,HScrollBar,VScrollBar}
   Insert(Interior);
end;
constructor TInteriors.Init(var Bounds:TRect);
begin
   inherited Init(Bounds);
   GrowMode:=gfGrowHiX+gfGrowHiY;
end;
procedure TInteriors.Draw;
Var
   Color:Byte;
   I,Y:Integer;
   B:TDrawBuffer;
Begin
{   Color:=GetColor(1);
   For Y:=1 to Size.Y-1 do begin
      MoveChar(B,' ',Color,Size.X);
      i:=Delta.Y+Y;
      If (I<LineCount)and(Lines[1]<>nil) then
        MoveStr(B,Copy(Lines[I]^,Delta.X+1,Size.X),color);
        WriteLine(0,Y,Size.X,1,B);
   end;}
End;

procedure ReadFile;
Var
   F:Text;
   S:string;
begin
 LineCount:= 0;
 Assign(F,DData.InputLineData);
 Reset(F);
 While (not Eof(F)) And (LineCount < MaxLines) do
 begin
  readln(F,S);
  Lines[LineCount]:=NewStr(S);
  Inc(LineCount);
 end;
 Close(F);
end;
Procedure DoneFile;
Var
   I:integer;
begin
   For I:= 1 to LineCount-1 do
   If Lines[I] <> nil Then DisposeStr(Lines[I]);
end;

begin
end.
