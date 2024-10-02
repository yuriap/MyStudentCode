unit tvStatus;
interface
uses App,Dialogs,Views,Drivers,Objects,Crt,ProfComm;
type
  PSome = ^TSome;
  PStatusWindow = ^TStatusWindow;
  TStatusWindow = object(TDialog)
     Par1,Par2:PStaticText;
     constructor Init;
     procedure HandleEvent(var Event:TEvent);virtual;
     procedure ChangeStatus(Obj:PSome);virtual;
     end;


  TSome = object
    N:Integer;
    K:integer;
    Status:PStatusWindow;
    constructor Init;
    procedure Execute;
    destructor Done;
    end;
    PWaitWin = ^TWaitWin;
    TWaitWin = object(TWindow)
       constructor Init;
       procedure Draw;virtual;
       end;

var
  Some:PSome;
const
  cmStart = 10001;
  cmChangeStatus = 10002;
  cmBegin = 10003;
  cmWait = 10004;
  cmParametr = 10005;
  RealType = $0001;
  IntegerType = $0002;
procedure InputDialogBox(aLabel:string;aType:word;var Parametr);
implementation
procedure Music;
begin
  Sound(2000);
  Delay(50);
  NoSound;
end;
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
   Music;
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
   R.Assign(15,2,25,3);
   Par1:=New(PStaticText,init(R,'Yes'));
   Insert(Par1);
   R.Assign(2,3,12,4);
   Insert(New(PStaticText,init(R,'Параметр K')));
   R.Assign(15,3,25,4);
   Par2:=New(PStaticText,init(R,'Yes'));
   Insert(Par2);
   R.Assign(2,5,12,7);
   Insert(New(PButton,Init(R,'~C~тарт',cmStart,bfDefault)));
   SelectNext(false);
end;
procedure TStatusWindow.HandleEvent(var Event:TEvent);
var R:real;
begin
  inherited HandleEvent(Event);
  If (Event.What = evCommand) or (Event.What = evBroadCast) then begin
  Case Event.Command of
      cmStart : Some^.Execute;
      cmChangeStatus : ChangeStatus(PSome(Event.InfoPtr));
      else
      Exit;
      end;
  ClearEvent(Event);
  end;
End;
procedure TStatusWindow.ChangeStatus;
var T:string;
    z:integer;
begin
  DisposeStr(Par1^.Text);
  Str(Obj^.K,T);
  Par1^.Text:=NewStr(T);
  Par1^.DrawView;
  DisposeStr(Par2^.Text);
  Str(Obj^.N,T);
  Par2^.Text:=NewStr(T);
  Par2^.DrawView;
  Application^.Idle;
end;
constructor TWaitWin.Init;
var R:TRect;
begin
  R.Assign(30,10,50,15);
  Inherited init(R,'',wnNoNumber);
  Palette:=wpCyanWindow;
end;
procedure TWaitWin.Draw;
begin
   inherited Draw;
   WriteStr(3,2,'Подождите...',$02);
end;
procedure InputDialogBox(aLabel:string;aType:word;var Parametr);
var
  D:PDialog;
  V:PView;
  R:TRect;
  S:string[7];
begin
  R.Assign(20,8,60,15);
  D:=New(PDialog,Init(R,'Ввод параметра'));
  with D^ do begin
    R.Assign(29,2,38,3);
    V:=New(PInputLine,Init(R,7));
    R.Assign(1,2,29,3);
    Insert(New(PLabel,Init(R,aLabel,V)));
    Insert(V);
    R.Assign(7,4,17,6);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(23,4,33,6);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    SelectNext(False);
    end;
  If (aType and RealType) = RealType then S:=RealToStr(real(Parametr));
  If (aType and IntegerType) = IntegerType then
      S:=IntToStr(Integer(Parametr));
  Application^.ExecuteDialog(D,@S);
  If (aType and RealType) = RealType then real(Parametr):=StrToReal(S);
  If (aType and IntegerType) = IntegerType then
      Integer(Parametr):=StrToInteger(S);
end;

end.