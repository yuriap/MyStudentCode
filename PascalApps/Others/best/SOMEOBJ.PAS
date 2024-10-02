unit Someobj;
interface
uses Objects,Graph;
Type
    PTry = ^TTry;
    TTry = object(TObject)
     x,y:integer;
     constructor Init;
     procedure Show;
     constructor Load(Var S : TStream);
     procedure Store(Var S : TStream);virtual;
     destructor Done;virtual;
     end;
Var
   Try : PTry;
Const
   RTRy : TStreamRec = (
      ObjType : 111;
      VmtLink: Ofs(TypeOf(TTry)^);
      Load: @TTry.Load;
      Store: @TTry.Store);

implementation
constructor TTry.Init;
begin
  inherited Init;
  X:= 200;
  Y:= 250;
end;
procedure TTry.Show;
begin
  SetColor(4);
  Circle(X,Y,100);
end;
destructor TTry.Done;
begin
 inherited Done;
end;
constructor TTry.Load(var S : TStream);
begin
  S.Read(X, SizeOf(X));
  S.Read(Y, SizeOf(Y));
end;
procedure TTry.Store(var S : TStream);
begin
  S.Write(X,SizeOf(X));
  S.Write(Y,SizeOf(Y));
end;
begin
end.
