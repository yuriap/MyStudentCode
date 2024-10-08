unit PlCommon;
interface
uses Graph,MsgBox;
type
    TDataOfPlate = record
      count : String[10];
      preserve : String[10];
      alfa : String[10];
      dtime : String[10];
      end;

    TDataGraph = record
      MasX,MasY,DeltaX,DeltaY:string[10];
      end;

    PDataPlate = ^TDataPlate;
    TDataPlate = record
      SumCount:byte;{�������⢮ ���⮢ ࠧ������}
      Preserve:byte;{�������⢮ ��࠭塞�� ᢮������ ���३}
      Alfa:real;{㣮� ��⠭���� ����⨭� [ࠤ]}
      DTime :real{蠣 �� �६���}
      end;

    PAPoint = ^TAPoint;
    TAPoint = record
       X,Y:real;
       end;


    DrawAttr = word;

    ScreenType = record
       MasX,MasY,DeltaX,DeltaY:integer;
       end;
const
     coConPoint : DrawAttr = $000F;
     coRotAdd : DrawAttr = $0003;
     coRotFreeA : DrawAttr = $0001;
     coRotFreeB : DrawAttr = $0002;


var ADataPlate:PDataPlate;
    Screen : ScreenType ;
    DataPlate : TDataOfPlate;
    DataGraph : TDataGraph;

        grDriver: Integer;
        grMode: Integer;
        ErrCode: Integer;
procedure GraphInit;
Const
   IsItGraph:boolean = False;
implementation
procedure GraphInit;
begin
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin
  Writeln('Graphics error:', GraphErrorMsg(ErrCode));
 end
 else begin
  SetBkColor(0);
  IsItGraph := true;
  RestoreCrtMode;
  end;
end;
begin
end.
