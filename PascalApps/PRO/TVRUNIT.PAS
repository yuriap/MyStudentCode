unit TVRUnit;
interface
uses Objects,Views,Dialogs,Drivers,TvrComm,Validate,ColorSel,ProfComm;
type

    PSpecialDlg = ^TSpecialDlg;
    TSpecialDlg = object(TDialog)
        procedure HandleEvent(var Event:TEvent);virtual;
        end;
    PInpLineNe = ^TInpLineNe;
    TInpLineNe = object(TInputLine)
       function Valid(Command:word):boolean;virtual;
       end;
   POption = ^TOption;
   TOption = object(TCollection)
      constructor Init(Options:string);
      end;
   PList = ^TList;
   TList = object(TListBox)
      Last:integer;
      function GetText(Item: Integer; MaxLen: Integer): String; virtual;
      procedure HandleEvent( var Event:TEvent);virtual;
      end;

   PCDlg = ^TCDlg;
   TCDlg = object(TDialog)
      CS:PColorSelector;
      LB:PList;
      Data:PColor;
      constructor Init;
      constructor Load(var S:TStream);
      procedure Store(var S:TStream);
      procedure PutOption(S:String);
      procedure HandleEvent( var Event:TEvent );virtual;
      procedure SetData(var D);virtual;
      procedure GetData(var D);virtual;
      end;

const
   RSpecialDlg : TStreamRec = (
      ObjType : idSpecialDlg;
      VmtLink: Ofs(TypeOf(TSpecialDlg)^);
      Load:@TSpecialDlg.Load;
      Store:@TSpecialDlg.Store);
   RInpLineNe : TStreamRec = (
      ObjType : idInpLineNe;
      VmtLink: Ofs(TypeOf(TInpLineNe)^);
      Load:@TInpLineNe.Load;
      Store:@TInpLineNe.Store);

   ROption : TStreamRec = (
      ObjType : idOption;
      VmtLink: Ofs(TypeOf(TOption)^);
      Load:@TOption.Load;
      Store:@TOption.Store);
   RList : TStreamRec = (
      ObjType : idList;
      VmtLink: Ofs(TypeOf(TList)^);
      Load:@TList.Load;
      Store:@TList.Store);
   RCDlg : TStreamRec = (
      ObjType : idCDlg;
      VmtLink: Ofs(TypeOf(TCDlg)^);
      Load:@TCDlg.Load;
      Store:@TCDlg.Store);
procedure RegisterColorDlg;
implementation
procedure TSpecialDlg.HandleEvent(var Event:TEvent);
begin
  inherited HandleEvent(Event);
  If Event.What = evCommand
    then EndModal(Event.Command)
    else exit;
    ClearEvent(Event);
end;
function TInpLineNe.Valid;
begin
  If(Not(Command In [cmValid, cmCancel])) and
    (Data^ = '') then
    begin
      Select;
      Beep;
      Valid:=False;
    end
    Else
      Valid:=inherited Valid(Command);
end;
constructor TOption.Init(Options:string);
var
   i,j,Coun:byte;
   Opt:string;
   len:byte absolute Options;
begin
  Coun:=0;
  For i:=1 to len do if Options[i] = '.' then Coun:=Coun+1;
  inherited Init(len,0);
  Opt:='';
  For i:=1 to len do begin
    If Options[i] <> '.' then Opt:=Opt+Options[i]
      else begin
      Insert(NewStr(Opt));
      Opt:='';
      end;
  end;
end;{init}
function TList.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetText:=string(List^.At(Item)^);
end;
procedure TList.HandleEvent;
begin
  inherited HandleEvent(Event);
  If Last <> Focused Then begin
      PCDlg(Owner)^.Data^[Last]:=PCDlg(Owner)^.CS^.Color;
      Event.What:=evBroadCast;
      Event.Command:=cmViewColor;
      PutEvent(Event);
      Last:=Focused;
      end;
end;
procedure TCDlg.SetData(var D);
begin
  Data:=@TColor(D);
  CS^.Color:=TColor(Data^)[0];
end;
procedure TCDlg.GetData(var D);
begin
  TColor(D):=Data^;
end;
procedure TCDlg.HandleEvent;
begin
  If (Event.What = evCommand) and (Event.Command = cmOk) then
     begin
      Data^[LB^.Focused]:=CS^.Color;
      ClearEvent(Event);
      EndModal(cmOk);
      Exit;
     end;
  Inherited HandleEvent(Event);
  If Event.What = evBroadCast then begin
  case Event.Command of
    cmViewColor:begin
                CS^.Color:=Data^[Lb^.Focused];
                Cs^.DrawView;
                end;
    else Exit;
    end;{case}
    ClearEvent(Event);
    end;

end;
procedure TCDlg.PutOption(S:String);
begin
   LB^.NewList(New(POption,Init(S)));
end;
constructor TCDlg.Init;
var
  R:TRect;
  SB:PScrollBar;
begin
  R.Assign(20,7,60,18);
  inherited Init(R,'Настройка цветов');

    R.Assign(22,3,23,7);
    SB:=New(PScrollBar,Init(R));
    Insert(SB);
    R.Assign(2,3,22,7);
    LB:=New(PList,Init(R,1,SB));

    LB^.Options:=LB^.Options or ofFramed;
    Insert(LB);
    R.Assign(2,1,22,2);
    Insert(New(PLabel,Init(R,'Элементы',LB)));

    R.Assign(25,3,38,7);
    CS:=New(PColorSelector,Init(R,TColorSel(0)));
    Insert(CS);
    R.Assign(25,1,38,2);
    Insert(New(PLabel,Init(R,'Цвет',CS)));

    R.Assign(6,8,16,10);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(24,8,34,10);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    SelectNext(False);
end;
constructor TCDlg.Load(var S:TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S,CS);
  GetSubViewPtr(S,LB);
end;
procedure TCDLG.Store(var S:TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S,CS);
  PutSubViewPtr(S,LB);
end;
procedure RegisterColorDlg;
begin
  RegisterType(ROption);
  RegisterType(RList);
  RegisterType(RCDlg);
end;
begin
end.