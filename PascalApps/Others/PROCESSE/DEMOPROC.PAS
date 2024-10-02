program Procing;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,
     Gadgets,Process;
Const
      cmOpenPBox = 1000;
      cmBegining = 1001;
      cmGoNext = 1002;
      cmInsertVector = 1003;
      cmServiseVector = 1004;
      cmViewVector =1007;
      cmGraphParam = 1006;
      cmEditVecAttr = 1005;
      cmDelVector = 1008;
      cmViewDecVector = 1009;
      cmDelAllVector = 1010;

      cmParFuncView = 1011;
      IsHelp : boolean = false;
Type

    PApp = ^TApp;
    TApp = object({tvdEBUG.}TApplication)
           Heap:PHeapView;
           Clock:PClockView;
           constructor init;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           procedure HandleEvent(var Event:TEvent);virtual;
           destructor Done;virtual;
           procedure Idle;virtual;
           procedure OpenPBox;
           end;
var
  MyApp:PApp;

constructor TApp.Init;
var R:Trect;
    ErrorMessage:string;
begin
     inherited Init;
     GetExtent(R);
     R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
     Clock := New(PClockView, Init(R));
     Insert(Clock);

     GetExtent(R);
     Dec(R.B.X);
     R.A.X:=R.B.X-9;R.A.Y:=R.B.Y-1;
     Heap:=New(PHeapView,Init(R));
     Insert(Heap);
end;
Procedure TApp.InitStatusLine;
Var R : TRect;
Begin
     GetExtent(R);
     R.A.Y:=R.B.Y-1;
     StatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FFFF,
      NewStatusKey('~F1~ Помощь ',kbF1,cmHelp,
        NewStatusKey('~Alt-X~ Выход',kbAltX,cmQuit,
          NewStatusKey('~F10~ Меню',kbF10,cmMenu,
              StdStatusKeys(
        nil)))),nil)));
End;
Procedure TApp.InitMenuBar;
Var R : TRect;
Begin
  GetExtent(R);
  R.B.Y:=R.A.Y+1;
  MenuBar:=New(PMenuBar,Init(R,NewMenu(
    NewSubMenu('Окно процесса ',hcNoContext,NewMenu(
     NewItem('Открыть...','F1',kbF1,cmOpenPBox,hcNoContext,
     NewItem('','',0,cmBegining,hcNoContext,
     NewItem('','',0,cmGoNext,hcNoContext,
     nil)))),
     nil))));
End;
procedure TApp.OpenPBox;
Var
   M : PProcessBox;
   C:Word;
Begin

     M:=New(PProcessBox,Init);
     DeskTop^.ExecView(M);
     Dispose(M,Done);
end;

Procedure TApp.HandleEvent(var Event:TEvent);
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
      cmOpenPBox : OpenPBox;
{      cmDelAllVector : DelAllVector;
      cmGraphParam : GraphParam;
      cmServiseVector : ServiseVector;
      cmViewVector : ViewVector;
      cmInsertVector : InsertVector;
      cmEditVecAttr : EditVecAttr;
      cmViewDecVector : ViewDecVector;
      cmBoundParam : BoundParam;
      cmBegining : Begining;
      cmGoNext : GoNext;}
      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
destructor TApp.Done;
begin
  inherited Done;
end;
procedure TApp.Idle;
begin
  inherited idle;
  Heap^.Update;
  Clock^.UpDate;
end;
begin
  MyApp:=New(PApp,Init);
  MyApp^.Run;
  Dispose(MyApp,Done);
end.
