 program Test;
  uses

   UObject, UGraph, UEvent, UView, UMenu, UDialog, UWindow;

  const

   hc_System = 0;

  type

   PApp = ^TApp;
   TApp = object(TProgram)
    function Comm_Valid(Comm: word): boolean; virtual;
   end;

   PMyWindow = ^TMyWindow;
   TMyWindow = object(TWindow)
    Indicator :PHIndicator;
    function New_Desktop(const Area :TRect) :PView; virtual;
    function New_MenuBar(const Area :TRect) :PView; virtual;
    procedure Proc_Event(var E: TEvent); virtual;
   end;

   function TMyWindow.New_Desktop(const Area :TRect) :PView;
     var Box :TRect;
    begin
     Box.Open(0,0,600,400);
     New_Desktop:=New(PViewer,Init(Area,Box,of_Border))
    end;

   procedure TMyWindow.Proc_Event;
    begin
     inherited Proc_Event(E);
     if (E.What = ev_FreeTime) and (Indicator <> nil) then with Indicator^ do
     Progress_To((Value+1) mod (Max-Min))
    end;

   function TMyWindow.New_MenuBar(const Area :TRect) :PView;
    begin
     New_MenuBar:=New(PMenuBar,Init(Area,0,New_Tree(
      New_List('&Файл', hc_System, New_Tree(
       New_Item('&Открыть ...', '', 0, 100, 0,
       New_Item('&Сохранить', 'F2', kb_F2, 100, 0,
       New_Item('Сохранить &как ...', '', 0, 100, 0,
       New_Line(
       New_Item('&Оболочка Dos ', '', 0, 100, 0,
       New_Item('&Выход', 'Alt + X', kf_Alt+Char_Code('X'), cm_Quit, 100,
      nil))))))),
      New_List('&Инструмент', hc_System, New_Tree(
       New_Item('&Авторы', '', kb_NoKey, 100, 100,
       New_Item('И&гры', '', kb_NoKey, cm_Menu, 100,
       New_Item('Ка&лендарь', 'F5', kb_NoKey, 100, 100,
       New_Item('ASCII &таблица', 'Ctrl F3', kb_NoKey, 100, 100,
       New_Item('&Калькулятор', '', kb_NoKey, 100, 100,
       New_List('&Search', 0, New_Tree(
        New_Item('&Find...', '', 0, 100, 100,
        New_Item('&Replace...', '', 0, 100, 0,
        New_Item('&Search again', '', 0, 100, 0,
       nil)))),
      nil))))))),
      New_List('&Options', 0, New_Tree(
       New_Item('&Mouse...', '', 0, 100, 0,
       New_Item('&Colors...', '', kb_NoKey, 100, 0,
       New_Line(New_Item('&Save Desktop', '', kb_NoKey, 100, 0,
       New_Item('&Retrieve Desktop', '', kb_NoKey, 0, 100,
       New_Item('&Size/Move', 'Ctrl+F5', kf_Ctrl+kb_F5, cm_Drag, hc_Drag,
      nil))))))),
     nil))))));
    end;

  var
   R :TRect;
   App :PProgram;
   W :PMyWindow;
   M :longint;

  function TApp.Comm_Valid;
   begin
    if Comm = cm_Quit then
    Comm_Valid:=(MsgBox(#13#13#3'Вы, хотите закончить сеанс работы ?',
    mf_Confirmation+mf_YesNo) in [cm_Ok,cm_Yes])
    and inherited Comm_Valid(Comm)
   end;

  function BaseWindow(R:TRect) :PWindow;
   const
    Tt :char = '0';
   var
    Area,R1 :Trect;
    D: PGroup;
   begin
   Inc(Tt);
   W:=New(PMyWindow,Init(R,0,'Окно N '+Tt));
   with W^ do begin
    Area.Open(300,40,310, 120);
    D:=New(PGroupBox,Init(Area,of_Border));
    with D^ do begin
     R.Open(90+Metric_Edit.X, Metric_Edit.Y, 180, Metric_Edit.Y);
     Insert(New(PInputBar,Init(R,100)));
     R1.Open(Metric_Box.X, Metric_Box.Y+5, 100, Metric_Box.Y);
     Insert(New(PLabel,InitPack(R1,'InputLn &1:',D)));
     R.Move(0,Metric_Edit.Y*2);
     Insert(New(PInputBar,Init(R,100)));
     R1.Move(0,Metric_Box.Y*2);
     Insert(New(PLabel,InitPack(R1,' EditLn &2:',D)));
     R.Move(0,Metric_Edit.Y*2);
     Insert(New(PEditBar,Init(R,100,of_Border)));
     R1.Move(0,Metric_Box.Y*2);
     Insert(New(PLabel,InitPack(R1,' EditLn &3:',D)));
    end;
    Insert(D);
    Area.Move(Metric_Box.X,-3);
    Insert(New(PLabel,InitPack(Area,'Group &Edit line',D)));
    Area.Open(Metric_Box.X,40,300-Metric_Box.X*2,120);
    D:=New(PGroupBox,Init(Area,of_Border));
    with D^ do begin
     R.Open(80, Metric_Box.Y, 100, Metric_Box.Y);
     Insert(New(PButton,InitDef(R,'Ме&ню',cm_Menu)));
     R.Move(0,Metric_Box.Y*2);
     Insert(New(PButton,Init(R,'&Максимиз.',cm_Maximize)));
     R.Move(0,Metric_Box.Y*2);
     Insert(New(PButton,Init(R,'Ми&нимиз.',cm_Minimize)));
    end;
    Insert(D);
    Area.Move(Metric_Box.X,-3);
    Insert(New(PLabel,InitPack(Area,'Group &Button',D)));
    Area.Open(Metric_Box.X, 160+Metric_Box.Y, 310, 80);
    D:=New(PGroupBox,Init(Area,of_Border));
    with D^ do begin
     R.Open(Metric_Box.X, Metric_Box.Y, 120, Metric_Box.Y);
     Insert(New(PRadioBox,InitAuto(R,'Radio box &1')));
     R.Move(0,Metric_Box.Y+1);
     Insert(New(PRadioBox,InitAuto(R,'Radio box &2')));
     R.Move(0,Metric_Box.Y+1);
     Insert(New(PRadioBox,InitAuto(R,'Radio box &3')));
     R.Move(110+Metric_Box.X,0);
     Insert(New(PRadioBox,InitAuto(R,'Radio box &6')));
     R.Move(0,-Metric_Box.Y-1);
     Insert(New(PRadioBox,InitAuto(R,'Radio box &5')));
     R.Move(0,-Metric_Box.Y-1);
     Insert(New(PRadioBox,InitAuto(R,'Radio box &4')));
    end;
    Insert(D);
    Area.Move(Metric_Box.X,-3);
    Insert(New(PLabel,InitPack(Area,'Group Auto &Radio box',D)));
    Area.Open(Metric_Box.X*2+310, 160+Metric_Box.Y, 150,  80);
    D:=New(PGroupBox,Init(Area,of_Border));
    with D^ do begin
     R.Open(Metric_Box.X, Metric_Box.Y, 120, Metric_Box.Y);
     Insert(New(PRadioBox,InitOn(R,'Radio box &1')));
     R.Move(0,Metric_Box.Y+1);
     Insert(New(PRadioBox,Init(R,'Radio box &2')));
     R.Move(0,Metric_Box.Y+1);
     Insert(New(PRadioBox,Init(R,'Radio box &3')));
    end;
    Insert(D);
    Area.Move(Metric_Box.X,-3);
    Insert(New(PLabel,InitPack(Area,'Group &Radio box',D)));
    Area.Open(Metric_Box.X,270,310,80);
    D:=New(PGroupBox,Init(Area,of_Border));
    with D^ do begin
     R.Open(Metric_Box.X, Metric_Box.Y, 120, Metric_Box.Y);
     Insert(New(PCheckBox,InitOn(R,'Check box &1')));
     R.Move(0,Metric_Box.Y+1);
     Insert(New(PCheckBox,InitOn(R,'Check box &2')));
     R.Move(0,Metric_Box.Y+1);
     Insert(New(PCheckBox,InitOn(R,'Check box &3')));
     R.Move(110+Metric_Box.X,0);
     Insert(New(PCheckBox,InitOn(R,'Check box &6')));
     R.Move(0,-Metric_Box.Y-1);
     Insert(New(PCheckBox,InitOn(R,'Check box &5')));
     R.Move(0,-Metric_Box.Y-1);
     Insert(New(PCheckBox,InitOn(R,'Check box &4')));
    end;
    Insert(D);
    Area.Move(Metric_Box.X,-3);
    Insert(New(PLabel,InitPack
    (Area,'Group &Chec box',D)));
    R.Open(350,320,200,60);
    Insert(New(PTextBox,Init(R,Metric_Box,
    'Демонстрационная панель. Она показывает основные диалоговые элементы')));
    if Tt = '3' then begin 
     Area.Open(17,10,200,10);
     Indicator:=pointer(Insert(New(PHIndicator,Init(Area,1))));
     Indicator^.Progress_Range(0,1000)
    end; 
    Area.Open(300,10,250,16);
    PSlider(Insert(New(PHSlider,Init(Area,of_Border))))^.Power_Param(0,1000,10,100,10);
   end;
   BaseWindow:=W
  end;

  var
   p :pointer;
   I :integer;
   Area: TRect;
 begin
   Randomize;
   M:=MaxAvail;
   App:=New(PApp,Init);
   for I:=1 to 3 do begin
    R.A.X:=Random(Metric_Scr.X div 2);
    R.A.Y:=Random(Metric_Scr.Y div 2);
    R.B.X:=R.A.X+Random(Metric_Scr.X div 2 -200)+200;
    R.B.Y:=R.A.Y+Random(Metric_Scr.Y div 2 -200)+200;
    PGroup(App^.Insert(BaseWindow(R)))^.Insert(BaseWindow(R))
   end;
   Area.Open(530,0,100,100);
   App^.Child_Ins(New(PClock,Init(Area)));
   App^.Dlg_Exec;
   App^.Free;
   Writeln('Баланс ресурсов :',M,' ',MaxAvail);
 end.
