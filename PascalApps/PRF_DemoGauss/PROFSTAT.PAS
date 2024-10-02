unit ProfStat;
interface
uses Dialogs,Views,Drivers,Objects,Crt;
type
  PSome = ^TSome;
  TSome = object
    N:Integer;
    K:integer;
    Status:PView;
    constructor Init;
    procedure Execute;
    destructor Done;
    end;

  PStatusWindow = ^TStatusWindow;
  TStatusWindow = object(TDialog)
     constructor Init;
     procedure HandleEvent(var Event:TEvent);virtual;
     end;
const
  cmStart = 10001;
  cmChangeStatus = 10002;
implementation
constructor TSome.Init;
begin
  N:=1;
  K:=1;
end;
procedure TSome.Execute;
var i,j:integer;
begin
  For i:=1 to 10 do begin
   For j:=1 to 10 do begin
     N:=i+j;
     K:=i-j;
     Message(Status,evBroadCast,cmChangeStatus,@Self);
     Delay(100);
     end;
     end;
end;
destructor TSome.Done;
begin
end;
constructor TStatusWindow.Init;
var R:TRect;
begin
   R.Assign(10,5,70,19);
   inherited Init(R,'Окно Статуса');
   R.Assign(2,2,12,3);
   Insert(New(PStaticText,init(R,'Параметр N')));
   R.Assign(2,3,12,4);
   Insert(New(PStaticText,init(R,'Параметр K')));
   R.Assign(2,5,12,7);
   Insert(New(PButton,Init(R,'~C~тарт',cmStart,bfDefault)));
   SelectNext(false);
end;
procedure TStatusWindow.HandleEvent(var Event:TEvent);
begin
  inherited HandleEvent(Event);
end;
end.