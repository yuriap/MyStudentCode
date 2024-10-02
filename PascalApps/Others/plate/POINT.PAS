unit Point;
interface
uses AbsPoint,PlCommon,Graph,Objects;

type
    PConPoint = ^TConPoint;
    TConPoint = object(TAbsPoint)   {объект - контрольная точка}
       constructor Init(NewLocation:TAPoint;NewDTime:real;StrMove:boolean);
       procedure Show;virtual;
       procedure Hide;virtual;
       end;

    PRotAdd = ^TRotAdd;
    TRotAdd = object(TAbsPoint)   {объект - присоединенный вихрь}
        Cyclon : real;
        constructor Init(NewLocation:TAPoint;NewDTime:real;StrMove:boolean);
        procedure Show;virtual;
        procedure Hide;virtual;
        constructor Load(var S:TStream);
        procedure Store(var S:TStream);
        end;

    PRotFree = ^TRotFree;
    TRotFree = object(TAbsPoint)  {объект - свободный вихрь}
        Cyclon : real;
        constructor Init(NewLocation:TAPoint;NewDTime:real;StrMove:boolean;
                     Col:word);
        procedure Show;virtual;
        procedure Hide;virtual;
        constructor Load(var S:TStream);
        procedure Store(var S:TStream);
        end;
Const
   RConPoint : TStreamRec = (
      ObjType : 1005;
      VmtLink: Ofs(TypeOf(TConPoint)^);
      Load:@TConPoint.Load;
      Store:@TConPoint.Store);
   RRotAdd : TStreamRec = (
      ObjType : 1006;
      VmtLink: Ofs(TypeOf(TRotAdd)^);
      Load:@TRotAdd.Load;
      Store:@TRotAdd.Store);
   RRotFree : TStreamRec = (
      ObjType : 1007;
      VmtLink: Ofs(TypeOf(TRotFree)^);
      Load:@TRotFree.Load;
      Store:@TRotFree.Store);


implementation

constructor TConPoint.Init(NewLocation:TAPoint;NewDTime:real;StrMove:boolean);
begin
   Inherited Init(NewLocation,NewDTime,StrMove);
   Color:=coConPoint;
end;
procedure TConPoint.Show;
const P : real = 0.05;
begin
   Inherited Show;
   Bar(ScrX+Trunc(P*Screen.MasX),ScrY+Trunc(P*Screen.MasY)
     ,ScrX-Trunc(P*Screen.MasX),ScrY-Trunc(P*Screen.MasY));
end;
procedure TConPoint.Hide;
const P : real = 0.05;
begin
   Inherited Hide;
   Bar(ScrX+Trunc(P*Screen.MasX),ScrY+Trunc(P*Screen.MasY)
     ,ScrX-Trunc(P*Screen.MasX),ScrY-Trunc(P*Screen.MasY));
end;
{********************************************************}
constructor TRotAdd.Init(NewLocation:TAPoint;NewDTime:real;StrMove:boolean);
begin
   inherited Init(NewLocation,NewDTime,StrMove);
   Cyclon:=0.0;
   Color:=coRotAdd;
end;
Procedure TRotAdd.Show;
const p :real = 0.05;
begin
   inherited Show;
   Circle(ScrX,ScrY,Trunc(p*(Screen.MasX+Screen.MasY)/2));
end;
Procedure TRotAdd.Hide;
const p :real = 0.05;
begin
   inherited Hide;
   Circle(ScrX,ScrY,Trunc(p*(Screen.MasX+Screen.MasY)/2));
end;
constructor TRotAdd.Load(var S :TStream);
begin
  inherited Load(S);
  S.Read(Cyclon,SizeOf(real));
end;
procedure TRotAdd.Store(var S :TStream);
begin
  inherited Store(S);
  S.Write(Cyclon,SizeOf(real));
end;

{*******************************************************}
constructor TRotFree.Init(NewLocation:TAPoint;NewDTime:real;StrMove:boolean;
                     Col:word);
begin
   inherited Init(NewLocation,NewDTime,StrMove);
   Cyclon:=0.0;
   Color:=Col
end;
procedure TRotFree.Show;
const p : real = 0.1;
begin
   inherited Show;
   Circle(ScrX,ScrY,Trunc(p*(Screen.MasX+Screen.MasY)/2));
end;
procedure TRotFree.Hide;
const p : real = 0.1;
var s :real;
begin
   inherited Hide;
   Circle(ScrX,ScrY,Trunc(p*(Screen.MasX+Screen.MasY)/2));
end;
constructor TRotFree.Load(var S :TStream);
begin
  inherited Load(S);
  S.Read(Cyclon,SizeOf(real));
end;
procedure TRotFree.Store(var S :TStream);
begin
  inherited Store(S);
  S.Write(Cyclon,SizeOf(real));
end;

begin
end.
