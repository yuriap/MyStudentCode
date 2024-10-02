unit FuncObj;
interface
uses Dinamics;
type
    PFunc = ^TFunc;
    TFunc =object
       Vector:PVector;
       Dimens:word;
       x1,x2:real;
       constructor Init(Xbegin,Xend:real);
       Destructor Done;virtual;
       procedure GetVector(NewVector:PVector);
       function GetFunc(x:real):real;virtual;
       procedure Error;virtual;
       end;
    PZFunc = ^TZFunc;
    TZFunc = object(TFunc)
       ZVector:PZeroVector;
       procedure GetVector(NewVector:PZeroVector);
       function GetFunc(x:real):real;virtual;
       end;
implementation
constructor TFunc.Init(Xbegin,Xend:real);
begin
  x1:=Xbegin;
  x2:=Xend;
end;
procedure TFunc.GetVector(NewVector:PVector);
begin
  Vector:=NewVector;
  Dimens:=Vector^.N-1;
end;
destructor TFunc.Done;
begin
end;
function TFunc.GetFunc(x:real):Real;
var W,dx,xi :real;
    i:word;
begin
  dx:=(x2-x1)/dimens;
  For i:=1 to dimens+1 do begin
  If (x < x1) or (x > x2+dx/2) then begin Error;Exit;end;
  xi:=x1+dx*(i-1);
  if Abs(xi-x) <= 1e-10 then begin W:=Vector^.Get(i);GetFunc:=W;exit;end;
  if (xi < x) and (xi+dx > x) then begin
       W:=Vector^.Get(i)+(Vector^.Get(i+1)-Vector^.Get(i))*(x-xi)/dx;
       GetFunc:=W;exit;end;
  If Abs(xi+dx-x) <= 1e-10 then begin W:=Vector^.Get(i+1);GetFunc:=W;exit;end;
  end;
end;
procedure TFunc.Error;
begin
 Writeln('Error!');
end;
{********************************}
procedure TZFunc.GetVector(NewVector:PZeroVector);
begin
  ZVector:=NewVector;
  Dimens:=ZVector^.N-1;
end;
function TZFunc.GetFunc(x:real):Real;
var W,dx,xi :real;
    i:word;
begin
  dx:=(x2-x1)/dimens;
  If (x < x1) or (x > x2+dx/2) then begin Error;Exit;end;
  For i:=0 to dimens do begin
  xi:=x1+dx*i;
  if Abs(xi-x) <= 1e-10 then begin W:=ZVector^.Get(i);GetFunc:=W;exit;end;
  if (xi < x) and (xi+dx > x) then begin
       W:=ZVector^.Get(i)+(ZVector^.Get(i+1)-ZVector^.Get(i))*(x-xi)/dx;
       GetFunc:=W;exit;end;
  If Abs(xi+dx-x) <= 1e-10 then begin W:=ZVector^.Get(i+1);GetFunc:=W;exit;end;
  end;
end;

begin
end.
