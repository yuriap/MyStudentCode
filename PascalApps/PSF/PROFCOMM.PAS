unit ProfComm;
Interface
Uses Objects,Crt;
Type
   PColor = ^TColor;
   TColor = array [0..5] of byte;

    PPoints = ^TPoints;
    TPoints = record
      X,Y:Real;
      end;
    PSpeed = ^TSpeed;
    TSpeed = record
      U,V:Real;
      end;
    PVecValue = ^TVecValue;
    TVecValue = record{Вектор математический}
      ProX,ProY:real;{проекции вектора}
      end;
    PCorner = ^TCorner;
    TCorner = record
      CX,CY:Real;
      end;
procedure ConvGrd(var C:TCorner);
procedure ConvRad(var C:TCorner);
procedure Beep;
Const
   idBasePoint = 9999;
   idProfile = 10000;
   idBreakPoint = 10001;
   idCyclon = 10002;
   idControlPoint = 10003;
   idCyclonAdd = 10004;
   idViewer = 10005;
   idVector = 10006;
   idMatrix = 10007;
   idMapProf = 10008;
   idMain = 10009;
   idOptMassiv = 10010;
   idMainSetka = 10011;
   idCompSetka = 10012;
   idBuffer = 10014;
   idFunction = 10015;
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
procedure Beep;
begin
  Sound(1000);
  Delay(150);
  NoSound;
end;
begin
end.