unit Common;
Interface
Uses Objects,Crt,Graph;
Type
   PColor = ^TColor;
   TColor = array [0..5] of byte;
var
 grDriver: Integer;
 grMode: Integer;
 ErrCode: Integer;
function sign1(x:real):integer;
function Lg(X:real):real;
function XInN(x,n:real):real;
function RealStr(x:real):string;
function RealToStr(I:Real):String;
function IntToStr(I: Longint): String;
function StartGraph:string;
procedure DoneGraph;
procedure Beep;
procedure SoundTrac;
