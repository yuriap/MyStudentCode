unit Process;
interface
uses Objects,Views,Dialogs,Drivers;
const
   cmStart = 2001;
type
   PProcessBox = ^TProcessBox;
   TProcessBox = object(TWindow)
      Indicator:PScrollBar;
      StaticText,DinamicText:PStaticText;
      constructor Init;
      procedure HandleEvent(var Event:TEvent);virtual;
      end;
implementation
Uses Procing;
constructor TProcessBox.Init;
var R:TRect;
begin
  R.Assign(15,5,65,19);
  Inherited Init(R,'Процесс идет',1);
    R.Assign(10,4,40,5);
    Indicator:=New(PScrollBar,Init(R));
    Indicator^.SetParams(0,0,100,0,0);
    IndiCator^.EventMask:=evMessage;
    Insert(Indicator);
    R.Assign(10,2,25,3);
    StaticText:=New(PStaticText,Init(R,'Ранг процесса'));
    Insert(StaticText);
    R.Assign(10,6,12,40);
    Insert(New(PButton,Init(R,'Старт',cmStart,bfDefault)));
end;
procedure TProcessBox.HandleEvent;
begin
  inherited HandleEvent(Event);
  If Event.What = evMessage then begin
     Indicator^.Value:=Event.InfoLong;
     case Event.Command of
        cmStart : MyApp^.Processing;
        end;
     exit;
     end;
   ClearEvent(Event);
end;
end.