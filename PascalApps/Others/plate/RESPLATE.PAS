program ResPlate;
{Создание ресурсов для TV_Plate.pas}
uses Objects,Views,Dialogs,Menus,StdDlg,App;
var S:PBufStream;
    Res:TResourceFile;
    View: PView;
    R:TRect;
    M:LongInt;

    Col : PCollection;

procedure Registers;
begin
    RegisterViews;
    RegisterDialogs;
    RegisterMenus;
    RegisterStdDlg;
    RegisterApp;
end;
function Dial:PDialog;
var D:PDialog;
begin
   R.Assign(10,3,70,18);
   D:=New(PDialog,Init(R,'Окно ввода данных'));
   With D^ do  begin

      R.Assign(40,3,55,4);
      View:=New(PInputLine,Init(R,10));
      Insert(View);
      R.Assign(3,3,39,4);
      Insert(New(PLabel,Init(R,'Колличество участков разбиения',View)));

      R.Assign(40,5,55,6);
      View:=New(PInputLine,Init(R,10));
      View^.HelpCtx:=hcNoContext;
      Insert(View);
      R.Assign(3,5,39,6);
      Insert(New(PLabel,Init(R,'Кол-во сохраняемых свободных вихрей',View)));

      R.Assign(40,7,55,8);
      View:=New(PInputLine,Init(R,10));
      View^.HelpCtx:=hcNoContext;
      Insert(View);
      R.Assign(3,7,39,8);
      Insert(New(PLabel,Init(R,'Угол установки пластины [грд]',View)));

      R.Assign(40,9,55,10);
      View:=New(PInputLine,Init(R,10));
      View^.HelpCtx:=hcNoContext;
      Insert(View);
      R.Assign(3,9,39,10);
      Insert(New(PLabel,Init(R,'Безразмерный шаг по времени',View)));

      R.Assign(15,12,25,14);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(35,12,45,14);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);
      end;
    Dial:=D;
end;
{**********************}
function GrphPrm:PDialog;
Var
   D : PDialog;
Begin
   R.Assign(10,3,70,18);
   D:=New(PDialog,Init(R,'Окно ввода данных'));
   With D^ do
      begin
      R.Assign(40,3,55,4);
      View:=New(PInputLine,Init(R,10));
      Insert(View);
      R.Assign(3,3,39,4);
      Insert(New(PLabel,Init(R,'Масштаб по горизонтали',View)));

      R.Assign(40,5,55,6);
      View:=New(PInputLine,Init(R,10));
      View^.HelpCtx:=hcNoContext;
      Insert(View);
      R.Assign(3,5,39,6);
      Insert(New(PLabel,Init(R,'Масштаб по вертикали',View)));

      R.Assign(40,7,55,8);
      View:=New(PInputLine,Init(R,10));
      View^.HelpCtx:=hcNoContext;
      Insert(View);
      R.Assign(3,7,39,8);
      Insert(New(PLabel,Init(R,'Смещение т.(0,0) по горизонтали',View)));

      R.Assign(40,9,55,10);
      View:=New(PInputLine,Init(R,10));
      View^.HelpCtx:=hcNoContext;
      Insert(View);
      R.Assign(3,9,39,10);
      Insert(New(PLabel,Init(R,'Смещение т.(0,0) по вертикали',View)));

      R.Assign(15,12,25,14);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(35,12,45,14);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);
      end;
    GrphPrm:=D;
end;

{**********************}

Begin
    M:=MemAvail;
    Registers;
    {******************}
    Col:=New(PCollection,Init(10,2));
    Col^.Insert(Dial);
    Col^.InSert(GrphPrm);
    {******************}
    S:=New(PBufStream,Init('tv_plate.stm',stCreate,1024));
    Res.Init(S);
    Res.Put(PDialog(Col^.At(0)),'Dlg_Plate');
    Res.Put(PDialog(Col^.At(1)),'Dlg_Graph');
    Res.Done;
    Dispose(Col,Done);
    {******************}
    Writeln('Баланс кучи: ',M,':',MemAvail);
    readln;
end.