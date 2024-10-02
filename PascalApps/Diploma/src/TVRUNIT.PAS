unit TVRUnit;
interface
uses Objects,Views,Dialogs,Drivers,App,TvrComm,Validate,ColorSel,ProfComm,
      ProfMain,Profile,ProBound,ProfDin,Dos;
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
  PStatusWindow = ^TStatusWindow;
  TStatusWindow = object(TDialog)
     Fasa,
     Time,
     NumProfile,
     Normal,
     Iteration:PStaticText;
     constructor Init;
     procedure HandleEvent(var Event:TEvent);virtual;
     procedure ChangeBoundStatus(E:TEvent);virtual;
     procedure ChangeFasa(E:TEvent);virtual;
     Procedure UpGrade(M:PMain);
     end;
var StatusWindow:PStatusWindow;
type
    PWaitWin = ^TWaitWin;
    TWaitWin = object(TWindow)
       constructor Init;
       procedure Draw;virtual;
       end;
   TMainR = record
      CountProfile,
      b,
      R,
      dt,
      PotokProX,
      PotokProY,
      Omega,
      Betta0,
      Nu,
      MaxTime:string[7];
      Option:word;
      FileMapContur:FNameStr;
      end;
   TProfR = record
      CountCP,
      NFree,
      Tang,
      Norm,
      CornerSys:string[7];
      end;
   TBoundR = record
      Psi,{малое положительное число для dU/dy при y=delta <= Psi}
      S,{параметр усреднения}
      MaxIter,{максимальное число итераций}
      parNevazka,{величина невязки, %}
      MaxNevazka,
      Prec,
      Sloy:string[7];
      Option:word;{толщина ПС не корректируется word}
      end;
   {Список Графиков}
   PListPictures = ^TListPictures;
   TListPictures = object(TListBox)
      function GetText(Item: Integer; MaxLen: Integer): String; virtual;
      end;
   PManagerDlg = ^TManagerDlg;
   TManagerDlg = object(TSpecialDlg)
      LB:PListPictures;
      constructor Init;
      end;
   {Выбор вставляемого вектора }
   POptionCollect = ^TOptionCollect;
   TOptionCollect = object(TCollection)
      constructor Init;
      end;

   POptionList = ^TOptionList;
   TOptionList = object(TListBox)
      OptionCollect:POptionCollect;
      constructor Init(var Bounds: TRect; ANumCols: Word; AScrollBar:
                       PScrollBar);
      function GetText(Item: Integer; MaxLen: Integer): String; virtual;
      end;
   PNewVecBox = ^TNewVecBox;
   TNewVecBox = object(TDialog)
      CS:PColorSelector;
      LB:POptionList;
      constructor Init;
      procedure GetData(var Data);virtual;
      procedure SetData(var Data);virtual;
      end;
   PEditBuffer = ^TEditBuffer;
   TEditBuffer = object(TDialog)
      CS:PColorSelector;
      constructor Init;
      procedure GetData(var Data);virtual;
      procedure SetData(var Data);virtual;
      end;
   TEditRec = record
     Labels:string[7];
     Color:word;
     end;
   TListRec = record
     List : PCollection;
     Selection : word;
     end;
   TVecRec = record
    Option : TListRec;
    Number1,
    Number2 : string[5];
    Name : string[7];
    Color :word;
    end;
Var
  ListRec:TListRec;
  ListOption:TListRec;
  BufferRec:TVecRec;
  ManagerRec:TListRec;
  MRec:TMainR;
  PRec:TProfR;
  BRec:TBoundR;
const
  mdAutoBreak = $0001;
  mdNotFreeCycl = $0002;
  mdIdealFluid = $0004;
  pdCorrectDelta = $0001;
  RealType = $0001;
  IntegerType = $0002;
function InitMainRec:PMainRec;
procedure PutMain(MR:TMainR;aMRec:PMainRec);
procedure PutProf(PR:TProfR;aPRec:PProfileRec);
procedure PutBound(BR:TBoundR;aBRec:PBRec);

function InputDialogBox(aLabel:string;aType:word;var Parametr):word;
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
   RStatusWindow : TStreamRec = (
      ObjType : idStatusWindow;
      VmtLink: Ofs(TypeOf(TStatusWindow)^);
      Load:@TStatusWindow.Load;
      Store:@TStatusWindow.Store);
procedure RegisterColorDlg;
procedure RegisterStatusWindow;
implementation

function InitMainRec:PMainRec;
{иниц. записи для TMain.Init}
var
    aMRec:PMainRec;
begin
 aMRec:=New(PMainRec);
 aMRec^.ProfRecPtr:=New(PProfileRec);
 aMRec^.BoundRec:=New(PBRec);
   With aMRec^.ProfRecPtr^ do begin
      MainPtr:=aMRec;
      end;
 InitMainRec:=aMRec;
end;{InitProfRec}
procedure PutMain(MR:TMainR;aMRec:PMainRec);
begin
   with aMRec^ do begin
      CountProfile:=StrToInteger(MR.CountProfile);
      b:=StrToReal(MR.b);
      dt:=StrToReal(MR.dt);
      R:=StrToReal(MR.R);
      Potok.ProX:=StrToReal(MR.PotokProX);
      Potok.ProY:=StrToReal(MR.PotokProY);
      Omega:=StrToReal(MR.Omega);
      Betta0:=pi*StrToReal(MR.Betta0)/180;
      Nu:=StrToReal(MR.Nu);
      MaxTime:=StrToInteger(MR.MaxTime);
      FileMapContur:=MR.FileMapContur;
      Option:=moNoOption;
      if (MR.Option and mdAutoBreak) = mdAutoBreak then
         Option:=Option or moAutoBreak;
      if (MR.Option and mdNotFreeCycl) = mdNotFreeCycl then
         Option:=Option or moNotFreeCyclon;
      if (MR.Option and mdIdealFluid) = mdIdealFluid then
         Option:=Option or moIdealFluid;
      Option:=Option or moDissipation or moDissipationTime or
              moDisposeMeddle;
       end;{with}
end;
procedure PutProf(PR:TProfR;aPRec:PProfileRec);
begin
  with aPRec^ do begin
      CountCP:=StrToInteger(PR.CountCP);
      CornerSys:=pi*StrToReal(PR.CornerSys)/180;
      NFree:=StrToInteger(PR.NFree);
      Tang:=StrToInteger(PR.Tang);
      Norm:=StrToInteger(PR.Norm);
      end;{with}
end;
procedure PutBound(BR:TBoundR;aBRec:PBRec);
begin
  with aBRec^ do begin
      {малое положительное число для dU/dy при y=delta <= Psi}
      Psi:=StrToReal(BR.Psi);
      S:=StrToReal(BR.S);{параметр усреднения}
      MaxIter:=StrToInteger(BR.MaxIter);{максимальное число итераций}
      parNevazka:=StrToInteger(BR.parNevazka);{величина невязки, %}
      MaxNevazka:=StrToInteger(BR.MaxNevazka);
      Prec:=StrToReal(BR.Prec);
      Sloy:=StrToReal(BR.Sloy);
      if (BR.Option and pdCorrectDelta) = pdCorrectDelta then
        Option:=psCorrectDelta
        else
        Option:=moNoOption;
      end;{with}
end;
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
procedure RegisterStatusWindow;
begin
  RegisterType(RStatusWindow);
end;
constructor TStatusWindow.Init;
var R:TRect;
begin
   R.Assign(18,6,62,18);
   inherited Init(R,'Статус вычислений');
   R.Assign(16,1,34,2);
   Insert(New(PStaticText,init(R,'Общий цикл')));
   R.Assign(2,2,20,3);
   Insert(New(PStaticText,init(R,'Фаза вычислений:')));
   R.Assign(21,2,43,3);
   Fasa:=New(PStaticText,init(R,''));
   Insert(Fasa);
   {***********}
   R.Assign(2,3,20,4);
   Insert(New(PStaticText,init(R,'Mомент времени:')));
   R.Assign(21,3,43,4);
   Time:=New(PStaticText,init(R,''));
   Insert(Time);
   {***********}
   R.Assign(13,4,31,5);
   Insert(New(PStaticText,init(R,'Пограничный слой')));
   {***********}
   R.Assign(2,5,20,6);
   Insert(New(PStaticText,init(R,'Hомер профиля:')));
   R.Assign(21,5,43,6);
   NumProfile:=New(PStaticText,init(R,'-'));
   Insert(NumProfile);
   {***********}
   R.Assign(2,6,20,7);
   Insert(New(PStaticText,init(R,'Hормаль:')));
   R.Assign(21,6,43,7);
   Normal:=New(PStaticText,init(R,'-'));
   Insert(Normal);
   {***********}
   R.Assign(2,7,20,8);
   Insert(New(PStaticText,init(R,'Итерация:')));
   R.Assign(21,7,43,8);
   Iteration:=New(PStaticText,init(R,'-'));
   Insert(Iteration);

   R.Assign(6,9,16,11);
   Insert(New(PButton,Init(R,'~C~тарт',cmStart,bfDefault)));
   R.Assign(28,9,38,11);
   Insert(New(PButton,Init(R,'Закрыть',cmCancel,bfNormal)));

   SelectNext(false);
end;
procedure TStatusWindow.HandleEvent(var Event:TEvent);
begin
  inherited HandleEvent(Event);
  If (Event.What = evCommand) or (Event.What = evBroadCast) then begin
  Case Event.Command of
      cmStart : Main^.Execute;
      cmChangeFasa : ChangeFasa(Event);
      cmChangeBoundStatus : ChangeBoundStatus(Event);
      else
      Exit;
      end;
  ClearEvent(Event);
  end;
End;
procedure TStatusWindow.ChangeFasa;
var T:string;
begin
  DisposeStr(Fasa^.Text);
  T:=PMain(E.InfoPtr)^.Fasa;
  Fasa^.Text:=NewStr(T);
  Fasa^.DrawView;
  DisposeStr(Time^.Text);
  T:=IntToStr(PMain(E.InfoPtr)^.Time);
  Time^.Text:=NewStr(T);
  Time^.DrawView;
  Application^.Idle;
end;
procedure TStatusWindow.ChangeBoundStatus;
var T:string;
begin
  DisposeStr(NumProfile^.Text);
  T:=IntToStr(PBoundLayer(E.InfoPtr)^.ProfilePtr^.Number);
  NumProfile^.Text:=NewStr(T);
  NumProfile^.DrawView;
  DisposeStr(Normal^.Text);
  T:=IntToStr(PBoundLayer(E.InfoPtr)^.CurrN);
  Normal^.Text:=NewStr(T);
  Normal^.DrawView;
  DisposeStr(Iteration^.Text);
  T:=IntToStr(PBoundLayer(E.InfoPtr)^.Iteration);
  Iteration^.Text:=NewStr(T);
  Iteration^.DrawView;
  Application^.Idle;
end;
procedure TStatusWindow.UpGrade(M:PMain);
var E:TEvent;
begin
  E.What:=evBroadCast;
  E.InfoPtr:=M;
  ChangeFasa(E);
end;
constructor TWaitWin.Init;
var R:TRect;
begin
  R.Assign(30,10,50,15);
  Inherited init(R,'',wnNoNumber);
  Palette:=wpGrayWindow;
end;
procedure TWaitWin.Draw;
begin
   inherited Draw;
   WriteStr(3,2,'Подождите...',$02);
end;
function InputDialogBox(aLabel:string;aType:word;var Parametr):word;
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
  InputDialogBox:=Application^.ExecuteDialog(D,@S);
  if (aType and RealType) = RealType then real(Parametr):=StrToReal(S);
  If (aType and IntegerType) = IntegerType then
      Integer(Parametr):=StrToInteger(S);
end;
{********************************************************}
{********************************************************}
{Диспетчер}
Function TListPictures.GetText(Item: Integer; MaxLen: Integer): String;
var S : string[10];
begin
  If Graphic^.Collect^.At(Item) <> nil Then begin
  GetText:=PBuffer(Graphic^.Collect^.At(Item))^.Labels;end;
end;
{********************************************************}

constructor TManagerDlg.Init;
Var
  D:PDialog;
  R:TRect;
  SB:PScrollBar;
begin
 R.Assign(5,5,75,19);
    inherited Init(R,'Диспетчер');
    R.Assign(36,3,37,11);
    SB:=New(PScrollBar,Init(R));
    Insert(SB);
    R.Assign(5,3,35,11);
    LB:=New(PListPictures,Init(R,1,SB));
    ListRec.List:=Graphic^.Collect;
    ListRec.Selection:=0;
    LB^.SetData(ListRec);
    LB^.Options:=LB^.Options or ofFramed;
    Insert(LB);
    Palette:=dpCyanDialog;
    R.Assign(5,1,35,2);
    Insert(New(PLabel,Init(R,'Список графиков',Lb)));
      R.Assign(38,3,52,5);
      Insert(New(PButton,Init(R,'~H~овый',cmNewPicture,bfNormal)));
      R.Assign(38,5,52,7);
      Insert(New(PButton,Init(R,'Прав~k~а',cmEditPicture,bfNormal)));
      R.Assign(38,7,52,9);
      Insert(New(PButton,Init(R,'Уд~a~лить',cmDelPicture,bfNormal)));
      R.Assign(38,9,52,11);
      Insert(New(PButton,Init(R,'Пp~o~cмотр',cmViewBufferGraph,bfNormal)));
      R.Assign(53,3,68,5);
      Insert(New(PButton,Init(R,'Цв~e~та',cmChColor,bfNormal)));
      R.Assign(53,5,68,7);
      Insert(New(PButton,Init(R,'Па~p~аметры',cmGraphParam,bfNormal)));
      R.Assign(53,7,68,9);
      Insert(New(PButton,Init(R,'Ok',cmOk,bfDefault)));
      R.Assign(53,9,68,11);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    SelectNext(False);
end;
constructor TOptionCollect.Init;
begin
  inherited Init(30,0);
    Insert(NewStr('Касательная скорость по S'));
    Insert(NewStr('Касательная скорость по X'));
    Insert(NewStr('Hормальные давления по S'));
    Insert(NewStr('Hормальные давления по X'));
    Insert(NewStr('Касательные напряжения по S'));
    Insert(NewStr('Касательные напряжения по X'));
    Insert(NewStr('Толщина ПС по S'));
    Insert(NewStr('Толщина ПС по X'));
    Insert(NewStr('Hормаль основной сетки'));
    Insert(NewStr('Горизонталь основной сетки'));
    Insert(NewStr('Hормаль вспомогательной сетки'));
    Insert(NewStr('Горизонталь вспомогательной сетки'));
    Insert(NewStr('Крутящий момент по углу'));
    Insert(NewStr('Cp по углу'));
    Insert(NewStr('Сy по углу'));
    Insert(NewStr('Cx по углу'));
    Insert(NewStr('Сr по углу'));
    Insert(NewStr('Сq по углу'));
    Insert(NewStr('Крутящий момент по времени'));
    Insert(NewStr('Cp по времени'));
    Insert(NewStr('Сy по времени'));
    Insert(NewStr('Cx по времени'));
    Insert(NewStr('Сr по времени'));
    Insert(NewStr('Сq по времени'));
    Insert(NewStr('Контур профиля'));
end;
constructor TOptionlist.Init(var Bounds: TRect; ANumCols: Word;
                             AScrollBar:PScrollBar);
begin
  inherited Init(Bounds,ANumCols,AScrollBar);
  OptionCollect:=New(POptionCollect,Init);
end;

function TOptionList.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetTExt:=string(OptionCollect^.At(Item)^);
end;
constructor TNewVecBox.Init;
var
   View: PView;
   Button : PRadioButtons;
   R:TRect;
   SB:PScrollBar;
begin
   R.Assign(13,4,67,20);
   inherited Init(R,'Выбор функции');
    R.Assign(36,3,37,8);
    SB:=New(PScrollBar,Init(R));
    Insert(SB);
    R.Assign(3,3,36,8);
    LB:=New(POptionList,Init(R,1,SB));
    BufferRec.Option.List:=LB^.OptionCollect;
    BufferRec.Option.Selection:=0;
    LB^.Options:=LB^.Options or ofFramed;
    Insert(LB);
    R.Assign(3,1,31,2);
    Insert(New(PLabel,Init(R,'~B~ыбор графика для просмотра',LB)));
      R.Assign(39,9,51,10);
      View:=New(PInputLine,Init(R,5));
      Insert(View);
      R.Assign(3,9,35,10);
      Insert(New(PLabel,Init(R,'~H~омер профиля',View)));

      R.Assign(39,10,51,11);
      View:=New(PInputLine,Init(R,5));
      Insert(View);
      R.Assign(3,10,35,11);
      Insert(New(PLabel,Init(R,'Hoме~p~ нормали или горизонтали',View)));
      R.Assign(39,11,51,12);
      View:=New(PInputLine,Init(R,7));
      Insert(View);
      R.Assign(3,11,35,12);
      Insert(New(PLabel,Init(R,'~M~етка вектора',View)));

    R.Assign(39,3,51,7);
    CS:=New(PColorSelector,Init(R,TColorSel(0)));
    Insert(CS);
    R.Assign(39,1,45,2);
    Insert(New(PLabel,Init(R,'Цв~e~т',CS)));
      R.Assign(11,13,21,15);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(33,13,43,15);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);

end;
procedure TNewVecBox.GetData(var Data);
begin
 inherited GetData(Data);
 TVecRec(Data).Color:=CS^.Color;
end;
procedure TNewVecBox.SetData(var Data);
begin
 inherited SetData(Data);
 CS^.Color:=TVecRec(Data).Color;
end;
constructor TEditBuffer.Init;
var
   View: PView;
   Button : PRadioButtons;
   R:TRect;

begin
 R.Assign(22,7,58,15);
   inherited Init(R,'Редактирование атрибут вектора');
      R.Assign(2,3,19,4);
      View:=New(PInputLine,Init(R,7));
      Insert(View);
      R.Assign(2,2,17,3);
      Insert(New(PLabel,Init(R,'Метка вектора',View)));

      R.Assign(21,2,33,6);
      CS:=New(PColorSelector,Init(R,TColorSel(0)));
      Insert(CS);
      R.Assign(21,1,27,2);
      Insert(New(PLabel,Init(R,'Цвет',CS)));
      R.Assign(1,5,8,7);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(9,5,18,7);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);
end;
procedure TEditBuffer.GetData(var Data);
begin
 inherited GetData(Data);
 TEditRec(Data).Color:=CS^.Color;
end;
procedure TEditBuffer.SetData(var Data);
begin
 inherited SetData(Data);
 CS^.Color:=TEditRec(Data).Color;
end;

end.