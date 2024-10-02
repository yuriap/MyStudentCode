unit ProGraph;
interface
uses Graph,Drivers,ProfDin,Objects,ProfComm;
Const IsItGr:boolean=false;
function sign1(x:real):integer;
function Lg(X:real):real;
function XInN(x,n:real):real;
function RealStr(x:real):string;
function RealToStr(I:Real):String;
function IntToStr(I: Longint): String;
function StartGraph:string;
procedure DoneGraph;
var
 grDriver: Integer;
 grMode: Integer;
 ErrCode: Integer;
Type
   TGrRec = record
     MasX,MasY,
     StepX,StepY,
     X,Y,
     XName,YName:String[7];
     OptionMas:word;
     Title:string[37];
     Color:TColor;
     end;
{0 - фон
 1 - сетка
 2 - выноски
 3 - метки}
Var
   GraphicRec:TGrRec;

type
   PBufferCollection = ^TBufferCollection;
   TBufferCollection = object(TCollection)
      procedure AtDelete(Index:integer);
      end;

   PGraphic = ^TGraphic;
   TGraphic = object
      masx,masy:real;
      x,y:integer;
      stepx,stepy:real;
      OptionMas:word;
      MaximumX,MinimumX:real;
      MaximumY,MinimumY:real;
      Yakor:integer;
      LineColor,LabelsColor,ColSetka,ColDesk:word;
      Collect:PBufferCollection;
      NumVector:byte;
      IsInsert:boolean;
      XName,YName:string[5];
      Title:string[37];
      YTitle:integer;
      constructor Init(GrRec:TGrRec);
      procedure NewParam(aGrRec:TGrRec);
      procedure StoreParam(var GrRec:TGrRec);
      destructor Done;virtual;
      procedure InsertBuffer(NewBuffer:PBuffer);
      function MaxX:real;virtual;
      function MinX:real;virtual;
      function MaxY:real;virtual;
      function MinY:real;virtual;
      procedure PredProcess;
      procedure GetAutoMasshtab;
      function GetYakor:integer;
      procedure Show;
      procedure Hide;
      procedure DrawSetka;virtual;
      procedure DrawGraphic(Buf:PBuffer);virtual;
      procedure DrawAllGraphic;virtual;
      procedure DrawTitle;virtual;
      procedure Resize(NewMasX,NewMasY:real);
      procedure Move(NewX,NewY:integer);
      procedure NewStep(NewStX,NewStY:real);
      procedure HandleEvent;
      function Execute:word;
      end;
implementation
procedure TBufferCollection.AtDelete(Index:integer);
var Buf:PBuffer;
begin
  Buf:=PBuffer(At(Index));
  inherited AtDelete(Index);
  Dispose(Buf,Done);
end;
{************************************}
constructor TGraphic.Init(GrRec:TGrRec);
var z:integer;
begin
  NumVector:=1;
  {******************************************}
  NewParam(GrRec);
{  Val(GrRec.MasX,MasX,z);
  Val(GrRec.MasY,MasY,z);
  Val(GrRec.X,X,z);
  Val(GrRec.Y,Y,z);
  Val(GrRec.StepX,StepX,z);
  Val(GrRec.StepY,StepY,z);
  Val(GrRec.OptionMas,OptionMas,z);
  XName:=GrRec.XName;
  YName:=GrRec.YName;
  LineColor:=GrRec.Color[2];
  LabelsColor:=GrRec.Color[3];
  ColSetka:=GrRec.Color[1];
  ColDesk:=GrRec.Color[0];}

  Collect:=New(PBufferCollection,Init(5,2));
  IsInsert:=False;
end;
procedure TGraphic.NewParam(aGrRec:TGrRec);
var z:integer;
begin
     Val(aGrRec.MasX,MasX,z);
     Val(aGrRec.MasY,MasY,z);
     Val(aGrRec.X,X,z);
     Val(aGrRec.Y,Y,z);
     Val(aGrRec.StepX,StepX,z);
     Val(aGrRec.StepY,StepY,z);
     OptionMas:=aGrRec.OptionMas;
     XName:=aGrRec.XName;
     YName:=aGrRec.YName;
     LineColor:=aGrRec.Color[2];
     LabelsColor:=aGrRec.Color[3];
     ColSetka:=aGrRec.Color[1];
     ColDesk:=aGrRec.Color[0];
     Title:=aGrRec.Title;
end;
procedure TGraphic.StoreParam(var GrRec:TGrRec);
var z : integer;
begin
     GrRec.MasX:=RealStr(MasX);
     GrRec.MasY:=RealStr(MasY);
     GrRec.X:=IntToStr(X);
     GrRec.Y:=IntToStr(Y);
     GrRec.StepX:=RealStr(StepX);
     GrRec.StepY:=RealStr(StepY);
end;
procedure TGraphic.InsertBuffer(NewBuffer:PBuffer);
begin
   Collect^.Insert(NewBuffer);
   IsInsert:=true;
end;
procedure TGraphic.PredProcess;
begin
  MaximumX:=MaxX;
  MinimumX:=MinX;
  MaximumY:=MaxY;
  MinimumY:=MinY;
end;
procedure TGraphic.GetAutoMasshtab;
var por:real;
function MR(x:real):Real;
begin
  If (x > -0.5) and (x < 0) Then MR:=-1
                            else MR:=Round(x);
end;
begin
   MasX:=500/(MaximumX-MinimumX);
   MasY:=260/(MaximumY-MinimumY);
   StepX:=35/MasX;
   StepY:=30/MasY;
   por:=XInN(10,MR(Lg(StepX)));
   StepX:=Round(StepX/por)*por;
   por:=XInN(10,MR(Lg(StepY)));
   StepY:=Round(StepY/por)*por;
end;
function TGraphic.MaxX:real;
var MaxF:real;
   procedure Max(P:PBuffer);far;
   var i:word;
       a,b:real;
   begin
      a:=P^.GetX(1);
      For i:=2 to P^.M do begin
        b:=P^.GetX(i);
        if a < b then a:=b;
        end;
      if MaxF < a Then MaxF:=a;
   end;
begin
  MaxF:=PBuffer(Collect^.At(0))^.GetX(1);
  Collect^.ForEach(@Max);
  MaxX:=MaxF;
end;
function TGraphic.MinX:real;
var MinF:real;
   procedure Min(P:PBuffer);far;
   var i:word;
       a,b:real;
   begin
      a:=P^.GetX(1);
      For i:=2 to P^.M do begin
        b:=P^.GetX(i);
        if a > b then a:=b;
        end;
        if MinF > a Then MinF:=a;
   end;
begin
  MinF:=PBuffer(Collect^.At(0))^.GetX(1);
  Collect^.ForEach(@Min);
  MinX:=MinF;
end;
function TGraphic.MaxY:real;
var MaxF:real;
   procedure Max(P:PBuffer);far;
   var i:word;
       a,b:real;
   begin
      a:=P^.GetY(1);
      For i:=2 to P^.M do begin
        b:=P^.GetY(i);
        if a < b then a:=b;
        end;
      if MaxF < a Then MaxF:=a;
   end;
begin
  MaxF:=PBuffer(Collect^.At(0))^.GetY(1);
  Collect^.ForEach(@Max);
  MaxY:=MaxF;
end;
function TGraphic.MinY:real;
var MinF:real;
   procedure Min(P:PBuffer);far;
   var i:word;
       a,b:real;
   begin
      a:=P^.GetY(1);
      For i:=2 to P^.M do begin
        b:=P^.GetY(i);
        if a > b then a:=b;
        end;
        if MinF > a Then MinF:=a;
   end;
begin
  MinF:=PBuffer(Collect^.At(0))^.GetY(1);
  Collect^.ForEach(@Min);
  MinY:=MinF;
end;

function TGraphic.GetYakor:integer;
var
   a:integer;
begin
  if MaximumY > 0.0 then a:=Trunc(masy*stepy*(2+int(MaximumY/stepy)));
  if MaximumY <= 0.0 then a:=Trunc(masy*stepy*(2+int(MaximumY/stepy)));
  GetYakor:=a;
end;
procedure TGraphic.DrawSetka;
var a,b,i:integer;
    z:real;
    s:string[6];
begin
 SetTextStyle(DefaultFont,HorizDir,1);
 Yakor:=GetYakor;
 a:=Trunc((Abs(MaximumX-MinimumX)+2*stepx)/stepx);
 b:=Trunc((Abs(MaximumY-MinimumY)+3*stepy)/stepy);
 SetTextJustify(1,1);
 for i:=0 to a do begin
  s:=RealStr(MinimumX+(i-1)*stepx);
  if i = a Then s:=XName;
  line(x+Trunc(i*stepx*Masx),y,Trunc(x+i*stepx*Masx),Trunc(y+b*stepy*masy));
  OutTextXY(Trunc(x+i*stepx*Masx),TextHeight('1')+Trunc(y+b*stepy*masy),
  s);
  end;
 YTitle:=TextHeight('1')+Trunc(y+b*stepy*masy);
 SetTextJustify(2,0);
  z:=(2+int(MaximumY/stepy))*stepy;
 for i:=0 to b do begin
  s:=RealStr(z-i*stepy);
  if i = 0 Then s:=YName;
  line(x,Trunc(y+i*stepy*masy),x+Trunc(a*stepx*Masx),Trunc(y+i*stepy*masy));
  OutTextXY(x-TextWidth('1'),Trunc(y+i*stepy*masy),s);
end;end;
procedure TGraphic.DrawGraphic(Buf:PBuffer);
var a:real;
    ax,by,i,ii:integer;
    xl,yl:integer;
    z:real;
    Num:integer;
begin
  SetTextStyle(DefaultFont,HorizDir,1);
  MoveTo(Trunc(x+stepx*masx),Trunc(y+Yakor-masy*Buf^.GetY(1)));
  Num:=Collect^.IndexOf(Buf);
  ii:=2*(1+Num);
  For i:=2 to Buf^.M do begin
   aX:=Trunc(x+(Buf^.GetX(i)-MinimumX+stepx)*masx);
   bY:=Trunc(y+Yakor-masy*Buf^.GetY(i));
   If i =ii  then begin xl:=ax;yl:=by; end;
   LineTo(aX,bY);
   Circle(aX,bY,1);
   end;
  if GetColor <> ColDesk then SetColor(LineColor);
  MoveTo(xl,yl);
  LineTo(x+60*(Num),y-10);
  LineTo(x+60*(Num)+50,y-10);
  moveTo(x+60*(Num)+25,y-12);
  SetTextJustify(1,0);
  if GetColor <> ColDesk then SetColor(LabelsColor);
  OutText(Buf^.Labels);
end;
procedure TGraphic.DrawAllGraphic;
var i:byte;
    B:PBuffer;
    Color:word;
begin
   For i:=0 to Collect^.Count-1 do begin
   B:=PBuffer(Collect^.At(i));
   Color:=B^.Color;
   if GetColor <> ColDesk then SetColor(Color);
   DrawGraphic(B);
   end;
end;
procedure TGraphic.DrawTitle;
var xt,yt:integer;
    A:TextSettingsType;
begin
  xt:=GetMaxX div 2;
  SetTextJustify(CenterText,TopText);
  SetTextStyle(DefaultFont,HorizDir,1);
  yt:=YTitle+TextHeight('1')*2;
  OutTextXY(xt,yt,Title);
end;
destructor TGraphic.Done;
begin
  Dispose(Collect,Done);
end;
procedure TGraphic.Show;
begin
  SetColor(ColSetka);
  SetBkColor(ColDesk);
  DrawSetka;
  DrawTitle;
  DrawAllGraphic;
end;
procedure TGraphic.Hide;
begin
  SetColor(ColDesk);
  DrawSetka;
  DrawTitle;
  DrawAllGraphic;
end;
procedure TGraphic.Resize(NewMasX,NewMasY:real);
begin
  Hide;
  masx:=NewMasx;
  masy:=NewMasy;
  Show;
end;
procedure TGraphic.Move(NewX,NewY:integer);
begin
  Hide;
  x:=Newx;
  y:=Newy;
  Show;
end;
procedure TGraphic.NewStep(NewStX,NewStY:real);
begin
  Hide;
  stepx:=NewStX;
  stepy:=NewStY;
  Show;
end;
procedure TGraphic.HandleEvent;
const Ldone:boolean=false;
var
    Event:TEvent;
begin
 repeat
 GetKeyEvent(Event);

 case Event.KeyCode of
   kbAltS:Show;
   kbAltH:Hide;
   kbCtrlEnd:Resize(masx+masx*0.05,masy);
   kbCtrlHome :Resize(masx-masx*0.05,masy);
   kbCtrlPgUp:Resize(masx,masy-masy*0.05);
   kbCtrlPgDn:Resize(masx,masy+masy*0.05);
   kbRight:Move(x+20,y);
   kbLeft:Move(x-20,y);
   kbUp:Move(x,y-20);
   kbDown:Move(x,y+20);
   kbHome:NewStep(stepx*0.5,stepy);
   kbEnd:NewStep(stepx*2,stepy);
   kbPgUp:NewStep(stepx,stepy*0.5);
   kbPgDn:NewStep(stepx,stepy*2);
   kbAltX:Ldone:=true;
   end;
 GetMouseEvent(Event);
 If Event.What = evMouseDown then LDone:=True;
 until Ldone;
 Ldone:=false;
end;
function TGraphic.Execute:word;{код выхода}
begin
  If not(IsInsert) Then exit;
  PredProcess;
  If OptionMas = 0 then
             GetAutoMasshtab;
  If (Abs(MaximumX) > MaxInt) or (Abs(MinimumX) > MaxInt )or
     (Abs(MaximumY) > MaxInt) or (Abs(MinimumY) > MaxInt )Then exit;
  Show;
  HandleEvent;
  Hide;
  Execute:=0;
end;
function sign1(x:real):integer;
begin
   If x = 0.0 Then Sign1:=0
    else sign1:=Trunc(x/Abs(x));
End;
function Lg(X:real):real;
begin
  If X > 0 then Lg:=Ln(x)/Ln(10)
           else Lg:=0;
end;
function XInN(x,n:real):real;
begin
  if X > 0 then XInN:=Exp(n*ln(x))
           else XInN:=0;
end;
function RealStr(x:real):string;
label 1;
Var
       d:string[6];
       i:byte;
       Point:boolean;
Begin
   Str(x:7:5,d);
   Point:=false;
   for i:=1 to Length(d) do
    If d[i] = '.' then Point:=true;
   If not(Point) Then begin RealStr:=d;Exit;end;
1: If (Copy(d,Length(d),1) = '0')
    then begin delete(d,Length(d),1);Goto 1; end;
   If (Copy(d,Length(d),1) = '.')
    then delete(d,Length(d),1);
    RealStr:=d;
End;
function RealToStr(I:Real):String;
var S:string[7];
begin
  Str(I:7:5,S);
  RealToStr:=S;
end;
function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string[7];
begin
 Str(I, S);
 IntToStr := S;
end;
function StartGraph:string;
begin
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin  { Do graphics }
  StartGraph:=^C'Ошибка графики:'+^M^C+GraphErrorMsg(ErrCode);
 end
 else begin
  SetBkColor(0);
  IsItGr := true;
  RestoreCrtMode;
  StartGraph:='';
  end;
end;

procedure DoneGraph;
begin
  CloseGraph;
  IsItGr:=False;
end;

begin
end.
