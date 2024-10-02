unit Someobj;
interface
uses Objects,Graph,Dialogs,Views;
const
     stNew = $0001;
     stSaveDisk = $0002;
     stLoadDisk = $0004;
Type
    TCircle =record
     dx,dy,dr:string[10];
     end;
    PTry = ^TTry;
    TTry = object(TObject)
     x,y:integer;
     r:integer;
     status:word;
     constructor Init(Circle:TCircle);
     procedure Draw;
     constructor Load(Var S : TStream);
     procedure Store(Var S : TStream);virtual;
     destructor Done;virtual;
     end;

    PDlgCircle = ^TDlgCircle;
    TDlgCircle =object(TDialog)
      constructor Init;
      end;
Var
   Try : PTry;
   DCircle:TCircle;
{function RealStr(x:real):string;}
function IntToStr(I: Longint): String;
Const
   RTRy : TStreamRec = (
      ObjType : 111;
      VmtLink: Ofs(TypeOf(TTry)^);
      Load: @TTry.Load;
      Store: @TTry.Store);

implementation
constructor TTry.Init(Circle:TCircle);
var i : integer;
begin
  inherited Init;
  With DCircle do begin
  Val(dX,X,i);
  Val(dY,Y,i);
  Val(dR,R,i);
  end;
  Status:=stNew;
end;
procedure TTry.Draw;
var d:string[10];
begin
  SetColor(4);
  Circle(X,Y,100);
  SetColor(14);
  Str(x,d);
  OutTextXY(x,y-20,'X= '+d);
  Str(y,d);
  OutTextXY(x,y,'Y= '+d);
  Str(r,d);
  OutTextXY(x,y+20,'Y= '+d);
end;
destructor TTry.Done;
begin
 inherited Done;
end;
constructor TTry.Load(var S : TStream);
begin
  S.Read(X, SizeOf(X));
  S.Read(Y, SizeOf(Y));
  S.Read(R, SizeOf(R));
  status:=stLoadDisk;
end;
procedure TTry.Store(var S : TStream);
begin
  S.Write(X,SizeOf(X));
  S.Write(Y,SizeOf(Y));
  S.Write(R,SizeOf(R));
  status:=stSaveDisk;
end;
function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

{function RealStr(x:real):string;
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
End;}
constructor TDlgCircle.Init;
Var
   CR: PView;
   Button : PButton;
   R:TRect;
Begin
   R.Assign(10,3,70,18);
   inherited Init(R,'Окно ввода данных');

      R.Assign(40,3,55,4);
      CR:=New(PInputLine,Init(R,10));
      Insert(CR);
      R.Assign(3,3,39,4);
      Insert(New(PLabel,Init(R,'Координата X:',CR)));

      R.Assign(40,5,55,6);
      CR:=New(PInputLine,Init(R,10));
      Insert(CR);
      R.Assign(3,5,39,6);
      Insert(New(PLabel,Init(R,'Координата Y:',CR)));

      R.Assign(40,7,55,8);
      CR:=New(PInputLine,Init(R,10));
      Insert(CR);
      R.Assign(3,7,39,8);
      Insert(New(PLabel,Init(R,'Радиус:',CR)));

      R.Assign(15,12,25,14);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(35,12,45,14);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);
end;

begin
end.
