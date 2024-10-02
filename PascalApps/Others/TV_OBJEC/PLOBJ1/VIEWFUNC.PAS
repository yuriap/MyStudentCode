unit ViewFunc;
interface
uses Graph,Crt,Dialogs,Views,Objects;
function sign1(x:real):integer;
function RealStr(x:real):string;
var Ex:boolean;
type
   TDataViewFunc = record
      rmasx,rmasy:string[10];
      rx,ry:string[10];
      rstepx,rstepy:string[10];
      rstep_arg:string[10];
      rx1,rx2:string[10];
      rColSetka,rColGraphic,rColDesk:word;
      end;
   PGraphic = ^TGraphic;
   TGraphic = object
      masx,masy:integer;
      x,y:integer;
      stepx,stepy:real;
      step_arg:real;
      x1,x2:real;
      Maximum,Minimum:real;
      Yakor:integer;
      ColSetka,ColGraphic,ColDesk:word;
      constructor Init(DataView:TDataViewFunc);
      destructor Done;virtual;
      function Fi(z:real):real;virtual;
      function MaxFunc:real;
      function MinFunc:real;
      function GetYakor:integer;
      procedure Show;
      procedure Hide;
      procedure DrawSetka;
      procedure DrawGraphic;
      procedure Resize(NewMasX,NewMasY:integer);
      procedure Move(NewX,NewY:integer);
      procedure HandleEvent;
      procedure Run;
      end;

      PInpDlg = ^TInpDlg;
      TInpDlg = object(TDialog)
        constructor Init;
        end;
       PGr = ^TGr;
       TGr = object(TGraphic)
        function Fi(z:real):real;virtual;
        end;
implementation
function TGr.Fi(z:real):Real;
begin
 Fi:=sin(z)+2*sin(2*z)+3*sin(3*z);
end;
constructor TGraphic.Init(DataView:TDataViewFunc);
var i:integer;
begin
  with DataView do begin
  val(rmasx,masx,i);val(rmasy,masy,i);
  val(rx,x,i);val(ry,y,i);
  val(rstepx,stepx,i);val(rstepy,stepy,i);
  val(rstep_arg,step_arg,i);
  Val(rx1,x1,i);Val(rx2,x2,i);
  Maximum:=MaxFunc;
  Minimum:=MinFunc;
{  Val(rColSetka,ColSetka,i);Val(rColGraphic,ColGraphic,i);
  Val(rColDesk,ColDesk,i);}
  ColSetka:=rColSetka;
  ColGraphic:=rColGraphic;
  ColDesk:=rColDesk;
  end;
  SetBkColor(ColDesk);
end;
function TGraphic.Fi(z:real):real;
const
     A0:real=0.0;A1:real=-3.7747619088E+00;
     A2:real=9.7017777927E+01;A3:real=-7.7411666797E+02;
     A4:real=2.9977777826E+03;A5:real=-6.0166666749E+03;
     A6:real=6.0444444506E+03;A7:real=-2.4047619063E+03;
begin
  If (z-0.00001) > 0.0 then
  Fi:=A0+A1*exp(1*ln(z))+A2*exp(2*ln(z))+A3*exp(3*ln(z))
   +A4*exp(4*ln(z))+A5*exp(5*ln(z))+A6*exp(6*ln(z))+A7*exp(7*ln(z))
   else Fi:=0.0;
end;{Fi}

function TGraphic.MaxFunc:real;
 var c,d,z:real;
 begin
   z:=x1;
   d:=Fi(z);
   repeat
   z:=z+Step_arg;
   c:=Fi(z);
    if d < c then d := c;
   until z >= x2;
   MaxFunc:=d;
 end;
function TGraphic.MinFunc:real;
 var c,d,z:real;
 begin
   z:=x1;
   d:=Fi(z);
   repeat
   z:=z+Step_arg;
   c:=Fi(z);
    if d > c then d := c;
   until z >= x2;
   MinFunc:=d;
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
  line(x+Trunc(i*stepx*Masx),y,Trunc(x+i*stepx*Masx),Trunc(y+b*stepy*masy));
  OutTextXY(Trunc(x+i*stepx*Masx),TextHeight('1')+Trunc(y+b*stepy*masy),
  RealStr(x1+(i-1)*stepx));
  end;
 SetTextJustify(2,0);
  z:=(2+int(Maximum/stepy))*stepy;
 for i:=0 to b do begin
  s:=RealStr(z-i*stepy);
  line(x,Trunc(y+i*stepy*masy),x+Trunc(a*stepx*Masx),Trunc(y+i*stepy*masy));
  OutTextXY(x-TextWidth('1'),Trunc(y+i*stepy*masy),s);
end;end;
procedure TGraphic.DrawGraphic;
var a:real;
    ax,ay:INTEGER;
begin

  a:=x1;
  ax:=Trunc(x+(a-x1+stepx)*masx);
  ay:=Trunc(y+Yakor-masy*Fi(a));
  repeat
   Circle(ax,ay,1);
   a:=a+step_arg;
  ax:=Trunc(x+(a-x1+stepx)*masx);
  ay:=Trunc(y+Yakor-masy*Fi(a));
  LineTo(ax,ay);
  until a >= x2;
end;
destructor TGraphic.Done;
begin
end;
procedure TGraphic.Show;
begin
  SetColor(ColSetka);
  DrawSetka;
  SetColor(ColGraphic);
  DrawGraphic;
end;
procedure TGraphic.Hide;
begin
  SetColor(ColDesk);
  DrawSetka;
  DrawGraphic;
end;
procedure TGraphic.Resize(NewMasX,NewMasY:integer);
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

procedure TGraphic.HandleEvent;
var z:char;
begin
 if keypressed then z:=UpCase(readkey) else exit;
 case z of
   'S':Show;
   'H':Hide;
   'B':Resize(masx+20,masy+20);
   'M':Resize(masx-20,masy-20);
   'L':Move(x+20,y);
   'R':Move(x-20,y);
   'U':Move(x,y-20);
   'D':Move(x,y+20);
   'Q':Ex:=true;
   end;
end;
procedure TGraphic.Run;

begin
 Ex:=false;
 Show;
 repeat
 HandleEvent;
 Until Ex;
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
Var    a:string[2];
       b:string[3];
       c:string[1];
       d:string[6];
       v:real;
       i:byte;
Begin
   b:='';
   Str(Trunc(abs(x)),a);
   v:=abs(Frac(x));
   for i:=1 to 7 do begin
     v:=v*10;
     str(trunc(v),c);
     b:=Concat(b,c);
     v:=Frac(v);
     end;
   If Sign1(x) < 0 then c:='-' else c:='';
   d:=Concat(c,a,'.',b);
1: If (Copy(d,Length(d),1) = '0') and (Copy(d,Length(d)-1,1) <> '.')
    then begin delete(d,Length(d),1);Goto 1; end
    else RealStr:=d;
End;
constructor TInpDlg.Init;
Var
   MyDialog : PDialog;
   CheckRadio : PView;
   Button : PButton;
   R:TRect;
Begin
   R.Assign(0,0,80,23);
   inherited Init(R,'Окно ввода данных');
      R.Assign(3,3,13,4);
      CheckRadio:=New(PInputLine,Init(R,10));
      Insert(CheckRadio);
      R.Assign(2,2,39,3);
      Insert(New(PLabel,Init(R,'~A~.Масштаб по горизонтали',CheckRadio)));

      R.Assign(3,5,13,6);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(2,4,39,5);
      Insert(New(PLabel,Init(R,'~B~.Масштаб по вертикали',CheckRadio)));

      R.Assign(3,7,13,8);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(2,6,39,7);
      Insert(New(PLabel,Init(R,'~C~.Смещение т.(0,0) по горизонтали',CheckRadio)));

      R.Assign(3,9,13,10);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(2,8,39,9);
      Insert(New(PLabel,Init(R,'~D~.Смещение т.(0,0) по вертикали',CheckRadio)));

      R.Assign(40,3,50,4);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(39,2,70,3);
      Insert(New(PLabel,Init(R,'~E~.Шаг сетки по X',CheckRadio)));

      R.Assign(40,5,50,6);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(39,4,70,5);
      Insert(New(PLabel,Init(R,'~F~.Шаг сетки по Y',CheckRadio)));

      R.Assign(3,11,13,12);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(2,10,39,11);
      Insert(New(PLabel,Init(R,'~G~.Шаг по аргументу',CheckRadio)));

      R.Assign(40,7,50,8);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(39,6,70,7);
      Insert(New(PLabel,Init(R,'~H~.Начало интервала',CheckRadio)));

      R.Assign(40,9,50,10);
      CheckRadio:=New(PInputLine,Init(R,10));
      CheckRadio^.HelpCtx:=hcNoContext;
      Insert(CheckRadio);
      R.Assign(39,8,70,9);
      Insert(New(PLabel,Init(R,'~J~.Конец интервала',CheckRadio)));

      R.Assign(3,14,30,18);
      CheckRadio:=New(PRadioButtons,Init(R,
               NewSItem('Black',
               NewSItem('Blue',
               NewSItem('Green',
               NewSItem('Cyan',
               NewSItem('Red',
               NewSItem('Magenta',
               NewSItem('Brown',
               NewSItem('LightGray',
               nil))))))))));
      Insert(CheckRadio);
      R.Assign(3,13,20,14);
      Insert(New(PLabel,Init(R,'~K~.Цвет сетки',CheckRadio)));

      R.Assign(33,14,60,18);
      CheckRadio:=New(PRadioButtons,Init(R,
               NewSItem('Black',
               NewSItem('Blue',
               NewSItem('Green',
               NewSItem('Cyan',
               NewSItem('Red',
               NewSItem('Magenta',
               NewSItem('Brown',
               NewSItem('LightGray',
               nil))))))))));
      Insert(CheckRadio);
      R.Assign(33,13,50,14);
      Insert(New(PLabel,Init(R,'~L~.Цвет графика',CheckRadio)));

      R.Assign(63,10,77,18);
      CheckRadio:=New(PRadioButtons,Init(R,
               NewSItem('Black',
               NewSItem('Blue',
               NewSItem('Green',
               NewSItem('Cyan',
               NewSItem('Red',
               NewSItem('Magenta',
               NewSItem('Brown',
               NewSItem('LightGray',
               nil))))))))));
      Insert(CheckRadio);
      R.Assign(63,9,77,10);
      Insert(New(PLabel,Init(R,'~M~.Цвет фона',CheckRadio)));

      R.Assign(25,19,35,21);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(45,19,55,21);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);
end;

begin
end.
