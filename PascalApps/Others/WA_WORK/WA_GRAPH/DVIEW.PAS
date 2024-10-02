 program Test;
  uses

   UObject,Graph, UGraph, UEvent, UView, UMenu, UDialog, UWindow,
   BGraphic;

  const

   hc_System = 0;
   cm_NewWindow = 1000;
var
  Graphic:PZGraphic;
  type

   PApp = ^TApp;
   TApp = object(TProgram)
    function Comm_Valid(Comm: word): boolean; virtual;
   end;
   PPlanshet = ^TPlanshet;
   TPlanshet = object(TViewer)
     procedure Proc_Paint;virtual;
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
   procedure TPlanshet.Proc_Paint;
   begin
    Graphic^.Execute;
{     Circle(20,20,20);}
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
     Area.Assign(1,1,599,399);
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
     if (E.What = ev_FreeTime) and (Indicator <> nil)
     then with Indicator^ do
     Progress_To((Value+1) mod (Max-Min));

     If E.What = ev_Command Then begin
     if Child_Is(E.InfoPtr) Then begin
       case E.Command of
         cm_NewWindow : NewWindow;
         else
         exit;
         end;
         Event_Clr(E);
         end;end;
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

     Vec:PZVector;
     F:Text;
     Volum:real;

begin
   M:=MaxAvail;
     With GrRec Do begin
     masx:='400';
     masy:='150';
     x:='70'; y:='50';
     stepx:='0.1';stepy:='0.2';
     step_arg:='0.01';
     x1:='0';x2:='1';
     XName:='Etta';
     YName:='Func';
     LineColor:=1;LabelsColor:=2;{чтобы получить номер цвета прибавить единицу}
     ColSetka:=0;ColGraphic:=4;
     ColDesk:=0;
     end;
    Assign(F,'fi&fiblz.dat');
    Reset(F);
    Graphic:=New(PZGraphic,Init);
    Vec:=New(PZVector,Init(27));
    For i:=0 to 26 do begin
      Readln(F,Volum);
      Vec^.Put(i,Volum);
      end;
    Close(F);
    Graphic^.InsertVector(Vec);

   Randomize;

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
   Dispose(Graphic,Done);
   Writeln('Баланс ресурсов :',M,' ',MaxAvail);

 end.
