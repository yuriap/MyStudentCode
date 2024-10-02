program TVProf;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,ColorSel,
     Gadgets,TvStatus,Crt,ProfComm;
Type

    PApp = ^TApp;
    TApp = object(TApplication)
           Heap:PHeapView;
           Clock:PClockView;
           constructor init;
           procedure initStatusLine;virtual;
           Procedure HandleEvent(var Event:TEvent);virtual;
           destructor Done;virtual;
           procedure Idle;virtual;
           procedure BeginOperation;
           procedure Wait;
           end;
var
  MyApp:PApp;
constructor TApp.Init;
var R:Trect;
    What:string;
begin
  inherited Init;
  Some:=New(PSome,Init);
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
procedure TApp.InitStatusLine;
Var R : TRect;
Begin
    R.Assign(0,24,80,25);
    StatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FFFF,
      NewStatusKey('~F1~ Начало Расчета ',kbF1,cmBegin,
      NewStatusKey('~F2~ Wait', kbF2,cmWait,
      NewStatusKey('~F3~ Parametr', kbF3,cmParametr,
              StdStatusKeys(
        nil)))),nil)));
end;
Procedure TApp.HandleEvent(var Event:TEvent);
var R:integer;
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
      cmBegin : BeginOperation;
      cmWait : Wait;
      cmParametr : begin
                   R:=150;
                   InputDialogBox('Parametr:',IntegerType,R);
                   MessageBox('Parametr: '+IntToStr(R),nil,mfInformation or
                   mfOkButton);
                   end;

      else
       Exit;
      end;
  ClearEvent(Event);
  end;
End;
destructor TApp.Done;
begin
  Dispose(Heap,Done);
  Dispose(Clock,Done);
  inherited Done;
end;
procedure TApp.Idle;
begin
  inherited idle;
  Heap^.Update;
  Clock^.UpDate;
end;
procedure TApp.BeginOperation;
begin
  Some^.Status:=New(PStatusWindow,Init);
  ExecuteDialog(Some^.Status,nil);
end;
procedure TApp.Wait;
var W:PWaitWin;
begin
  W:=New(PWaitWin,Init);
  DeskTop^.Insert(W);
  Delay(3000);
  Dispose(W,Done);
end;
begin
 MyApp:=New(PApp,Init);
 MyApp^.Run;
 Dispose(MyApp,Done);
end.
