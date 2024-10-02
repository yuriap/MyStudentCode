unit BGraphic;
interface
uses Graph,Crt,Views,Drivers,Dialogs,BFuncObj,BDinamic,Objects,App;
Const IsItGr:boolean=false;
function sign1(x:real):integer;
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
     X1,X2,
     Step_Arg,
     XName,YName:String[7];
      LineColor,LabelsColor,
      ColSetka,ColGraphic,
      ColDesk:word;
     end;
Var
   GrRec:TGrRec;
const{Ошибки рисования egXXXX}
     egOk = 0;{Все замечательно}
     egOutOfRange = 1;{MaxFunc или MinFunc выдает слишком большое
                       (малое) число}
     egDontInsert = 2;{график не установлен}

type
   PVectorCollection = ^TVectorCollection;
   TVectorCollection = object(TCollection)
      procedure AtDelete(Index:integer);
      end;
   PGraphic = ^TGraphic;
   TGraphic = object
      masx,masy:real;
      x,y:integer;
      stepx,stepy:real;
      step_arg:real;
      x1,x2:real;
      Maximum,Minimum:real;
      Yakor:integer;
      LineColor,LabelsColor,ColSetka,ColGraphic,ColDesk:word;
      Func:PFunc;
      Collect:PVectorCollection;
      NumVector:byte;
      IsInsert:boolean;
      XName,YName:string[5];
      constructor Init;
      destructor Done;virtual;
      procedure InsertVector(NewVector:PVector);
      function Fi(z:real):real;virtual;
      function MaxFunc:real;virtual;
      function MinFunc:real;virtual;
      procedure PredProcess;
      procedure Instal(Num:byte);virtual;
      function GetYakor:integer;
      procedure Show;
      procedure Hide;
      procedure DrawSetka;virtual;
      procedure DrawGraphic;virtual;
      procedure DrawAllGraphic;virtual;
      procedure Resize(NewMasX,NewMasY:real);
      procedure Move(NewX,NewY:integer);
      procedure NewStep(NewStX,NewStY:real);
      procedure HandleEvent;
      function Execute:word;{код выхода}
      procedure Error(ErrorCode:word);virtual;
      end;
   PZVector = ^TZVector;
   TZVector = object(TZeroVector)
      Color:word;
      Visible:boolean;
      end;
   PZGraphic = ^TZGraphic;
   TZGraphic = object(TGraphic)
      ZFunc:PZFunc;
      constructor Init;
      destructor Done;virtual;
      procedure NewParam;
      procedure StoreParam;
      procedure InsertVector(NewVector:PZVector);
      procedure DelLastVector;
      function MaxFunc:real;virtual;
      function MinFunc:real;virtual;
      function Fi(z:real):real;virtual;
      procedure Instal(Num:byte);virtual;
      procedure DrawGraphic;virtual;
      procedure DrawAllGraphic;virtual;
      end;
var
      Graphic:PZGraphic;

implementation
procedure TVectorCollection.AtDelete(Index:integer);
var Vec:PZVector;
 procedure SetVec( P:PZVector);far;
  begin
   P^.Number:=IndexOf(P)+1;
  end;
begin
  Vec:=PZVector(At(Index));
  inherited AtDelete(Index);
  Dispose(Vec,Done);
  ForEach(@SetVec);
end;
constructor TGraphic.Init;
begin
  masx:=300;masy:=100;
  x:=100;y:=100;
  stepx:=0.1;
  step_arg:=0.01;
  x1:=0;x2:=1;
  XName:='Etta';
  YName:='Func';
  Func:=New(PFunc,Init(x1,x2));
  Collect:=New(PVectorCollection,Init(5,2));
  ColSetka:=3;ColGraphic:=14;
  ColDesk:=1;
  LabelsColor:=2;
  LineColor:=4;
  IsInsert:=False;
  InitEvents;

end;
procedure TGraphic.InsertVector(NewVector:PVector);
begin
   Collect^.Insert(NewVector);
   NewVector^.Number:=Collect^.Count;
   IsInsert:=true;
end;
procedure TGraphic.PredProcess;
begin
  Maximum:=MaxFunc;
  Minimum:=MinFunc;
  if Int(Maximum-Minimum) <= 10.0 Then stepy:=1.0 else Stepy:=10;
  if Int(Maximum-Minimum) <= 5.0 Then stepy:=0.5;
  if Int(Maximum-Minimum) <= 1.0 Then stepy:=0.1;
  if Int(Maximum-Minimum) <= 0.5 Then stepy:=0.05;
  if Int(Maximum-Minimum) <= 0.1 Then stepy:=0.01;
  if Int(Maximum-Minimum) <= 0.05 Then stepy:=0.005;
end;
procedure TGraphic.Instal(Num:byte);
begin
  Func^.GetVector(PVector(Collect^.At(Num)));
end;
function TGraphic.Fi(z:real):real;
begin
  Fi:=Func^.GetFunc(z);
end;

function TGraphic.MaxFunc:real;
var MaxF:real;
   procedure Max(P:PVector);far;
   var i:word;
       a,b:real;
   begin
      a:=P^.Get(1);
      For i:=2 to P^.N do begin
        b:=P^.Get(i);
        if a < b then a:=b;
        end;
      if MaxF < a Then MaxF:=a;
   end;
begin
  MaxF:=PVector(Collect^.At(0))^.Get(1);
  Collect^.ForEach(@Max);
  MaxFunc:=MaxF;
end;
function TGraphic.MinFunc:real;
var MinF:real;
   procedure Min(P:PVector);far;
   var i:word;
       a,b:real;
   begin
      a:=P^.Get(1);
      For i:=2 to P^.N do begin
        b:=P^.Get(i);
        if a > b then a:=b;
        end;
        if MinF > a Then MinF:=a;
   end;
begin
  MinF:=PVector(Collect^.At(0))^.Get(1);
  Collect^.ForEach(@Min);
  MinFunc:=MinF;
end;

function TGraphic.GetYakor:integer;
var
   a:integer;
begin
  if Maximum > 0.0 then a:=Trunc(masy*stepy*(2+int(Maximum/stepy)));
  if Maximum <= 0.0 then a:=Trunc(masy*stepy*(2+int(Maximum/stepy)));
  GetYakor:=a;
end;
procedure TGraphic.DrawSetka;
var a,b,i:integer;
    z:real;
    s:string[6];
begin
 Yakor:=GetYakor;
 a:=Trunc((Abs(x2-x1)+2*stepx)/stepx);
 b:=Trunc((Abs(Maximum-Minimum)+3*stepy)/stepy);
 SetTextJustify(1,1);
 for i:=0 to a do begin
  s:=RealStr(x1+(i-1)*stepx);
  if i = a Then s:=XName;
  line(x+Trunc(i*stepx*Masx),y,Trunc(x+i*stepx*Masx),Trunc(y+b*stepy*masy));
  OutTextXY(Trunc(x+i*stepx*Masx),TextHeight('1')+Trunc(y+b*stepy*masy),
  s);
  end;
 SetTextJustify(2,0);
  z:=(2+int(Maximum/stepy))*stepy;
 for i:=0 to b do begin
  s:=RealStr(z-i*stepy);
  if i = 0 Then s:=YName;
  line(x,Trunc(y+i*stepy*masy),x+Trunc(a*stepx*Masx),Trunc(y+i*stepy*masy));
  OutTextXY(x-TextWidth('1'),Trunc(y+i*stepy*masy),s);
end;end;
procedure TGraphic.DrawGraphic;
var a:real;
    ax,by,i,ii:integer;
    xl,yl:integer;
    z:real;
begin
  a:=x1;
  i:=1;
  z:=Fi(a);
  Circle(Trunc(x+(a-x1+stepx)*masx),Trunc(y+Yakor-masy*z),1);
  ii:=2*Func^.Vector^.Number;
  repeat
   aX:=Trunc(x+(a-x1+stepx)*masx);
   bY:=Trunc(y+Yakor-masy*Fi(a));
   If i =ii  then begin xl:=ax;yl:=by; end;
   LineTo(aX,bY);
   Circle(aX,bY,1);
   a:=a+step_arg;
   i:=i+1;
  until a > x2;
  if GetColor <> ColDesk then SetColor(LineColor);
  MoveTo(xl,yl);
  LineTo(x+50*(Func^.Vector^.Number-1),y-10);
  LineTo(x+50*(Func^.Vector^.Number-1)+36,y-10);
  moveTo(x+50*(Func^.Vector^.Number-1)+18,y-12);
  SetTextJustify(1,0);
  if GetColor <> ColDesk then SetColor(LabelsColor);
  OutText(Func^.Vector^.Labels);
end;
procedure TGraphic.DrawAllGraphic;
var i:byte;
begin

   For i:=0 to Collect^.Count-1 do begin
   Instal(i);
   if GetColor <> ColDesk then SetColor(ColGraphic);
   DrawGraphic;
   end;
end;
destructor TGraphic.Done;
begin
  Dispose(Collect,Done);
  If Func <> nil then Dispose(Func,Done);
  DoneEvents;
end;
procedure TGraphic.Show;
begin
  SetColor(ColSetka);
  SetBkColor(ColDesk);
  DrawSetka;
  SetColor(ColGraphic);
  DrawAllGraphic;
end;
procedure TGraphic.Hide;
begin
  SetColor(ColDesk);
  DrawSetka;
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
  If not(IsInsert) Then begin
       Error(egDontInsert);
       Execute:=egDontInsert;
       exit;
       end;
  Maximum:=MaxFunc;
  Minimum:=MinFunc;
  If (Maximum > MaxInt) or (Abs(Minimum) > MaxInt )Then begin
       Error(egOutOfRange);
       Execute:=egOutOfRange;
       exit;
       end;

  Show;
  HandleEvent;
  Hide;
  Execute:=egOk;
end;
procedure TGraphic.Error(ErrorCode:word);
var S:string;
begin
{  RestoreCrtMode;
  DoneMemory;
  MyApp^.Redraw;end;
  case ErrorCode of
    egDontInsert : S:=^C+'График не установлен';
    egOutOfRange : S:=^C+'MaxFunc или MinFunc выдает'+^M^C+'слишком большое
                       (малое) число';
    end;
  MessageBox(S,nil,mfError or mfOkButton);}
end;
function sign1(x:real):integer;
begin
    if abs(x)-1e-10 < 0.0
    then sign1:=0
    else begin if x > 0.0 then sign1:=1 else sign1:= -1;
    end;
End;
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
  { Writeln('Graphics error:', GraphErrorMsg(ErrCode));
   Exit;}
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
{******************************************}
constructor TZGraphic.Init;
Var
  R : TRect;
  C : Word;
  z : integer;
begin
  NumVector:=1;
  {******************************************}
     Val(GrRec.MasX,MasX,z);
     Val(GrRec.MasY,MasY,z);
     Val(GrRec.X,X,z);
     Val(GrRec.Y,Y,z);
     Val(GrRec.StepX,StepX,z);
     Val(GrRec.StepY,StepY,z);
     Val(GrRec.Step_Arg,Step_Arg,z);
     Val(GrRec.X1,X1,z);
     Val(GrRec.X2,X2,z);
     XName:=GrRec.XName;
     YName:=GrRec.YName;
     LineColor:=GrRec.LineColor+1;
     LabelsColor:=GrRec.LabelsColor+1;{чтобы получить номер цвета прибавить единицу}
     ColSetka:=GrRec.ColSetka+1;
     ColGraphic:=GrRec.ColGraphic+1;
     ColDesk:=GrRec.ColDesk;

  ZFunc:=New(PZFunc,Init(x1,x2));
  Func:=nil;
  Collect:=New(PVectorCollection,Init(5,2));
{  ColSetka:=3;ColGraphic:=1;
  ColDesk:=0;
  LabelsColor:=2;
  LineColor:=4;}
  IsInsert:=False;
  InitEvents;
end;
procedure TZGraphic.NewParam;
var z:integer;
begin
     Val(GrRec.MasX,MasX,z);
     Val(GrRec.MasY,MasY,z);
     Val(GrRec.X,X,z);
     Val(GrRec.Y,Y,z);
     Val(GrRec.StepX,StepX,z);
     Val(GrRec.StepY,StepY,z);
     Val(GrRec.Step_Arg,Step_Arg,z);
     Val(GrRec.X1,X1,z);
     Val(GrRec.X2,X2,z);
     XName:=GrRec.XName;
     YName:=GrRec.YName;
     LineColor:=GrRec.LineColor+1;
     LabelsColor:=GrRec.LabelsColor+1;{чтобы получить номер цвета прибавить единицу}
     ColSetka:=GrRec.ColSetka+1;
     ColGraphic:=GrRec.ColGraphic+1;
     ColDesk:=GrRec.ColDesk;
     Dispose(ZFunc,Done);
     ZFunc:=New(PZFunc,Init(x1,x2));
end;
procedure TZGraphic.StoreParam;
var z : integer;
begin

     GrRec.MasX:=RealToStr(MasX);
     GrRec.MasY:=RealToStr(MasY);
     GrRec.X:=IntToStr(X);
     GrRec.Y:=IntToStr(Y);
     GrRec.StepX:=RealToStr(StepX);
     GrRec.StepY:=RealToStr(StepY);
     GrRec.Step_Arg:=RealToStr(Step_Arg);
     GrRec.X1:=RealToStr(X1);
     GrRec.X2:=RealToStr(X2);
end;
procedure TZGraphic.InsertVector(NewVector:PZVector);
begin
   Collect^.Insert(NewVector);
   NewVector^.Number:=Collect^.Count;
   IsInsert:=true;
end;
procedure TZGraphic.DelLastVector;
begin
   With Collect^ do begin
    AtDelete(Count-1);
   If Count > 0 Then IsInsert:=true Else IsInsert:=false;end;
end;
procedure TZGraphic.Instal(Num:byte);
begin
  ZFunc^.GetVector(PZeroVector(Collect^.At(Num)));
end;
function TZGraphic.MaxFunc:real;
var MaxF:real;
   procedure Max(P:PZVector);far;
   var i:word;
       a,b:real;
   begin
      a:=P^.Get(0);
      For i:=1 to P^.N-1 do begin
        b:=P^.Get(i);
        if a < b then a:=b;
        end;
      if MaxF < a Then MaxF:=a;
   end;
begin
  MaxF:=PZVector(Collect^.At(0))^.Get(0);
  Collect^.ForEach(@Max);
  MaxFunc:=MaxF;
end;
function TZGraphic.MinFunc:real;
var MinF:real;
   procedure Min(P:PZVector);far;
   var i:word;
       a,b:real;
   begin
      a:=P^.Get(0);
      For i:=1 to P^.N-1 do begin
        b:=P^.Get(i);
        if a > b then a:=b;
        end;
        if MinF > a Then MinF:=a;
   end;
begin
  MinF:=PZVector(Collect^.At(0))^.Get(0);
  Collect^.ForEach(@Min);
  MinFunc:=MinF;
end;
procedure TZGraphic.DrawGraphic;
var a:real;
    ax,by,i,ii:integer;
    xl,yl:integer;
    z:real;
begin
  a:=x1;
  i:=1;
  z:=Fi(a);
  Circle(Trunc(x+(a-x1+stepx)*masx),Trunc(y+Yakor-masy*z),1);
  ii:=Trunc((1/(step_arg*10))*ZFunc^.ZVector^.Number);
  repeat
   aX:=Trunc(x+(a-x1+stepx)*masx);
   bY:=Trunc(y+Yakor-masy*Fi(a));
   If i = ii then begin xl:=ax;yl:=by; end;
   LineTo(aX,bY);
   Circle(aX,bY,1);
   a:=a+step_arg;
   i:=i+1;
  until a > x2+step_arg/2;
  if GetColor <> ColDesk then SetColor(LineColor);
  MoveTo(xl,yl);
  LineTo(x+50*(ZFunc^.ZVector^.Number-1),y-10);
  LineTo(x+50*(ZFunc^.ZVector^.Number-1)+36,y-10);
  moveTo(x+50*(ZFunc^.ZVector^.Number-1)+18,y-12);
  SetTextJustify(1,0);
  if GetColor <> ColDesk then SetColor(LabelsColor);
  OutText(ZFunc^.ZVector^.Labels);
end;
function TZGraphic.Fi(z:real):real;
begin
  Fi:=ZFunc^.GetFunc(z);
end;
destructor TZGraphic.Done;
begin
  If ZFunc <> nil then Dispose(ZFunc,Done);
  inherited Done;
end;
procedure TZGraphic.DrawAllGraphic;
var i:byte;
begin
   For i:=0 to Collect^.Count-1 do begin
   If PZVector(Collect^.AT(i))^.Visible then begin
   Instal(i);
   if GetColor <> ColDesk then SetColor(PZVector(Collect^.AT(i))^.color);
   DrawGraphic;
   end;end;
end;

begin
end.