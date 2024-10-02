Unit Approxim;
interface
const Dim = 45;
type
   TArray = array [1..Dim] of real;
   TTablica = array [1..4] of TArray;
   PArray = ^TArray;
type
    PArrayFunc = ^TArrayFunc;
    TArrayFunc = object
       x1,x2:real;
       Dimens:integer;{сколько элементов массива использовать}
       ArrayPtr:PArray;
       constructor Init(Xbegin,Xend:real;NewDimens:integer);
       Destructor Done;virtual;
       procedure GetArray(NewArray:PArray);
       function GetFunc(x:real):real;virtual;
       procedure Error;virtual;
       end;
var
    Func:PArrayFunc;

implementation
constructor TArrayFunc.Init(Xbegin,Xend:real;NewDimens:integer);
begin
  x1:=Xbegin;
  x2:=Xend;
  Dimens:=NewDimens;
end;
procedure TArrayFunc.GetArray(NewArray:PArray);
begin
  ArrayPtr:=NewArray;
end;
destructor TArrayFunc.Done;
begin
end;
function TArrayFunc.GetFunc(x:real):Real;
var W,dx,xi :real;
    i:word;
begin
  dx:=(x2-x1)/(dimens-1);
  If (x < x1) or (x > x2+dx/2) then begin Error;Exit;end;
  For i:=1 to dimens do begin
  xi:=x1+dx*(i-1);
  if Abs(xi-x) <= 1e-10 then begin W:=ArrayPtr^[i];GetFunc:=W;exit;end;
  if (xi < x) and (xi+dx > x) then begin
       W:=ArrayPtr^[i]+(ArrayPtr^[i+1]-ArrayPtr^[i])*(x-xi)/dx;
       GetFunc:=W;exit;end;
  If Abs(xi+dx-x) <= 1e-10 then begin W:=ArrayPtr^[i+1];GetFunc:=W;exit;end;
  end;
end;
procedure TArrayFunc.Error;
begin
 Writeln('Error!');
end;
begin
end.