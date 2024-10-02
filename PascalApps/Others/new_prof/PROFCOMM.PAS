unit ProfComm;
Interface
Uses Objects;
Type
    PPoints = ^TPoints;
    TPoints = record
      X,Y:Real;
      end;
    PSpeed = ^TSpeed;
    TSpeed = record
      U,V:Real;
      end;
    PCorner = ^TCorner;
    TCorner = record
      CX,CY:Real;
      end;
    PProfileRec = ^TProfileRec;
    TProfileRec = record
      b:real;
      t,dt:real;
      N,NFree:word;
      NBreak:byte;
      Plase:TPoints;
      FControlPoint,
      FCyclonAdd,
      FBreakPoint:FNameStr;
      end;

procedure ConvGrd(var C:TCorner);
procedure ConvRad(var C:TCorner);

Const
   idProfile = 10000;
   idBreakPoint = 10001;
   idCyclon = 10002;
   idControlPoint = 10003;
   idCyclonAdd = 10004;

implementation
procedure ConvGrd(var C:TCorner);
begin
  C.CX:=C.CX*180/Pi;
  C.CY:=C.CY*180/Pi;
end;

procedure ConvRad(var C:TCorner);
begin
  C.CX:=C.CX*pi/180;
  C.CY:=C.CY*pi/180;
end;
begin
end.