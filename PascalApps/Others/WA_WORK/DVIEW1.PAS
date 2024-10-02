 program Test;
  uses

   UObject, Graph, UGraph, UEvent, UView, UMenu, UDialog, UWindow;

  const

   hc_System = 0;

  type

   PApp = ^TApp;
   TApp = object(TProgram)
    function Comm_Valid(Comm: word): boolean; virtual;
   end;

   PPloter = ^TPloter;
   TPloter = object(TView)
    procedure Proc_Paint; virtual;
   end;

   PMyWin = ^TMyWin;
   TMyWin = object(TWindow)
    function New_DeskTop(const Area: Trect): PView; virtual;
   end;

  function TMyWin.New_DeskTop(const Area: Trect): PView;
     var Box :TRect;
    begin
     Box.Open(0,0,600,400);
     New_Desktop:=New(PViewer,Init(Area,Box,of_Border))
    end;

   procedure TPloter.Proc_Paint;
    begin
     SetFillStyle(2,1);
     Bar(0,0,Size.X,Size.Y);
     Circle(100,100,50);
    end;

  var
   R :TRect;
   App :PProgram;
   P :PPloter;
   W :PWindow;
   M :longint;

  function TApp.Comm_Valid;
   begin
    if Comm = cm_Quit then
    Comm_Valid:=(MsgBox(#13#13#3'Вы, хотите закончить сеанс работы ?',
    mf_Confirmation+mf_YesNo) in [cm_Ok,cm_Yes])
    and inherited Comm_Valid(Comm)
   end;

 begin
   App:=New(PApp,Init);
   R.Open(10,10,300,400);
{   W:=New(PMyWin,Init(R,of_Border,'Test'));}{New_DeskTop}
    W:=New(PMyWin,Init(R,of_Border,'Test'));
   R.Open(10,10,200,200);
   P:=New(PPloter,Init(R));
{   P^.GrowMode:=gm_GrowHiX+gm_GrowLoY;}
   W^.Insert(P);{Insert}
   App^.Insert(W);
{   R.A.X:=R.B.X-100;
   R.A.Y:=R.B.Y-100;
   App^.Child_Ins(New(PClock,Init(R)));}
   App^.Dlg_Exec;
   App^.Free;
   Writeln('Баланс ресурсов :',M,' ',MaxAvail);
 end.
