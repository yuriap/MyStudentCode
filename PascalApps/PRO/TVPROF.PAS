program TVProf;
Uses app,objects,menus,drivers,views,dialogs,MsgBox,Memory,ColorSel,
     Gadgets,StrmErr,TvrComm,TvrUnit,ProGraph,Validate,ProfDin,
     Graph,ProfComm;
var
  Graphic:PGraphic;
Type

    PApp = ^TApp;
    TApp = object(TApplication)
           Heap:PHeapView;
           Clock:PClockView;
           constructor init;
           procedure initStatusLine;virtual;
           procedure InitMenuBar;virtual;
           Procedure HandleEvent(var Event:TEvent);virtual;
{           function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;}
           destructor Done;virtual;
           procedure Idle;virtual;
           procedure GraphParam;
           procedure ChangeColor;
{           procedure ServiseBuffer;}
           procedure ViewBufferGraph;
           end;
var
  MyApp:PApp;
  Res:TResourceFile;
  Stream:PBufStream;
constructor TApp.Init;
var R:Trect;
    What:string;
begin
   What:=StartGraph;
   RegisterObjects;
   RegisterViews;
   RegisterMenus;
   RegisterDialogs;
   RegisterType(RSpecialDlg);
   RegisterValidate;
   RegisterType(RInpLineNe);
   RegisterColorSel;
   RegisterColorDlg;

     Stream:=New(PMsgStream,Init(TvrFile,stOpenRead,1024));
     Res.Init(Stream);
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
{***********************}
with GraphicRec do begin
     MasX:='100';
     MasY:='100';
     StepX:='0.2';
     StepY:='0.2';
     X:='50';
     Y:='50';
     XName:='Arg';
     YName:='Func';
      Color[2]:=1;
      Color[3]:=5;
      Color[1]:=4;
      Color[0]:=7;
     OptionMas:=0;
     Title:='Рис.1. Тест.'
     end;
  Graphic:=New(PGraphic,Init(GraphicRec));
  If What <> '' then MessageBox(What,nil,mfWarning or mfOkButton);
end;
Procedure TApp.InitStatusLine;
Begin
   StatusLine:=PStatusLine(Res.Get(StatusLineId));
End;
Procedure TApp.InitMenuBar;
Begin
  MenuBar:=PMenuBar(Res.Get(MenusId));
End;
procedure TApp.GraphParam;
var
  S:PDialog;
  Comm:word;
  E:TEvent;
begin
  S:=PDialog(Res.Get(BufferGraphParamID));
  S^.SetData(GraphicRec);
  E.Command:=ExecView(S);
  If E.Command <> cmCancel Then begin
    S^.GetData(GraphicRec);
    Graphic^.NewParam(GraphicRec);
    end;
  E.What:=evCommand;
  PutEvent(E);
end;
procedure TApp.ChangeColor;
var
   C:TColor;
   CD:PCDlg;
begin
  Cd:=PCDlg(Res.Get(ColorDlgId));
  Cd^.PutOption('Фон.Сетка.Выноски.Метки.');
  Cd^.SetData(GraphicRec.Color);
  If ExecView(Cd) <> cmCancel Then Cd^.GetData(GraphicRec.Color);
  Graphic^.NewParam(GraphicRec);
  Dispose(Cd,Done);
end;
procedure TApp.ViewBufferGraph;
var
  B:PBuffer;
  f:text;
  x,y:real;
  i:integer;
begin
 B:=New(PBuffer,Init(31));
 B^.Labels:='Firstis';
 B^.Color:=14;
 Assign(f,'prof2.mpc');
 Reset(f);
 For i:=1 to 31 do begin
   Readln(f,x,y);
   B^.PutX(i,x);
   B^.PutY(i,y);
   end;
 Close(f);
 Graphic^.InsertBuffer(B);
 {********************}
 SetGraphMode(grMode);
 Graphic^.Execute;
 {********************}
 RestoreCrtMode;
 DoneMemory;
 Redraw;
 ShowMouse;
 Graphic^.StoreParam(GraphicRec);
end;
Procedure TApp.HandleEvent(var Event:TEvent);

Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
      cmGraphParam : GraphParam;
      cmChColor : ChangeColor;
{      cmServiseBuffer : ServiseBuffer;}
      cmViewBufferGraph : ViewBufferGraph;
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
  Dispose(Graphic,Done);
  Res.Done;
  If IsItGr Then DoneGraph;
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
