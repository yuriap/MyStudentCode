 program Test;
  uses

   UObject,Graph, UGraph, UEvent, UView, UMenu, UDialog, UWindow;

  const

   hc_System = 0;
   cm_NewWindow = 1000;

  type

   PApp = ^TApp;
   TApp = object(TProgram)
    function Comm_Valid(Comm: word): boolean; virtual;
   end;
   PPlanshet = ^TPlanshet;
   TPlanshet = object(TViewer)
     procedure Proc_Point;virtual;
     end;

   PMyWindow = ^TMyWindow;
   TMyWindow = object(TWindow)
    Indicator :PHIndicator;
    constructor Init(Area: TRect; AOption :word; const Name: string);
    function New_Desktop(const Area :TRect) :PView; virtual;
    function New_MenuBar(const Area :TRect) :PView; virtual;
    procedure Proc_Event(var E: TEvent); virtual;
    procedure NewWindow;
   end;
   procedure TPlanshet.Proc_Point;
   begin
     SetColor(2);
     Circle(50,50,30);
   end;
   constructor TMyWindow.Init(Area: TRect; AOption :word; const Name: string);
   begin
    Inherited Init(Area,AOption,Name);
   end;

   procedure TMyWindow.NewWindow;
   var Area,Box,R:TRect;
       W:PWindow;
   begin
    R.A.X:=Random(Metric_Scr.X div 2);
    R.A.Y:=Random(Metric_Scr.Y div 2);
    R.B.X:=R.A.X+Random(Metric_Scr.X div 2 -200)+200;
    R.B.Y:=R.A.Y+Random(Metric_Scr.Y div 2 -200)+200;
    W:=New(PMyWindow,Init(R,0,'Приложение'));
    R.A.X:=Random(Metric_Scr.X div 2);
    R.A.Y:=Random(Metric_Scr.Y div 2);
    R.B.X:=R.A.X+Random(Metric_Scr.X div 2 -200)+200;
    R.B.Y:=R.A.Y+Random(Metric_Scr.Y div 2 -200)+200;
     Area:=R;
     Box.Open(0,0,600,400);
    W^.Insert(New(PPlanshet,Init(Area,Box,of_Glass)));
    Insert(W);
   end;

   function TMyWindow.New_Desktop(const Area :TRect) :PView;
     var Box :TRect;
    begin
     Box.Open(0,0,600,400);
     New_Desktop:=New(PViewer,Init(Area,Box,of_Border))
    end;{PViewer,Init(Area,Box,of_Border)}

   procedure TMyWindow.Proc_Event;
    begin
     inherited Proc_Event(E);
     if (E.What = ev_FreeTime) and (Indicator <> nil) then with Indicator^ do
     Progress_To((Value+1) mod (Max-Min));
     If E.What = ev_Command Then begin
       case E.Command of
         cm_NewWindow : NewWindow;
         else
         exit;
         end;
         Event_Clr(E);
         end;
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
      New_List('&Окна', hc_System, New_Tree(
       New_Item('&Hовое окно', '', kb_NoKey, cm_NewWindow, 100,
       nil)),
      nil)))));
    end;


  function TApp.Comm_Valid;
   begin
    if Comm = cm_Quit then
    Comm_Valid:=(MsgBox(#13#13#3'Вы, хотите закончить сеанс работы ?',
    mf_Confirmation+mf_YesNo) in [cm_Ok,cm_Yes])
    and inherited Comm_Valid(Comm)
   end;
var
   R :TRect;
   App :PProgram;
   W :PMyWindow;
   M :longint;


  function BaseWindow(R:TRect) :PWindow;
   const
    Tt :char = '0';
   var
    Area,R1 :Trect;
    D: PGroup;
   begin
   Inc(Tt);
   W:=New(PMyWindow,Init(R,0,'Окно N '+Tt));
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
   for I:=1 to 1 do begin
    R.A.X:=0;
    R.A.Y:=0;
    R.B.X:=GetMaxX;
    R.B.Y:=GetMaxY;
    App^.Insert(BaseWindow(R))
   end;
{   Area.Open(530,0,100,100);
   App^.Child_Ins(New(PClock,Init(Area)));}
   App^.Dlg_Exec;
   App^.Free;
   Writeln('Баланс ресурсов :',M,' ',MaxAvail);
 end.
