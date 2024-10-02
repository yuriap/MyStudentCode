program Editor;
{$M 8192, 8192, 655360}
{$X+,S-}
Uses Dos,Objects,Drivers,Memory,Views,Menus,Dialogs,StdDlg,
     MsgBox,App,Editors,Printer,WinDos ;
Const
     HeapSize = 32*(1024 div 16);
     cmShowClip = 100;
     cmPrint = 1001;
{     cmPrnAttr = 1002;}
Type
    PEdit = ^TEdit;
    TEdit = object(TApplication)
      constructor Init;
      procedure HandleEvent( var Event : TEvent);virtual;
      procedure InitMenuBar;virtual;
      procedure InitStatusLine;virtual;
{      procedure PrnAttr;}
      end;
{    TData = record
      FntSize  : word;
      second : word;
      end;}
var
  ClipWindow: PEditWindow;
  FileWork:FNameStr;
{  Data : TData;}
function OpenEditor(FileName: FNameStr; Visible:Boolean):PEditWindow;
var
   P:PWindow;
   R:TRect;
begin
 DeskTop^.GetExtent(R);
 P:= New(PEditWindow,Init(R,FileName,wnNoNumber));
 OpenEditor:= PEditWindow(Application^.InsertWindow(p));
end;
constructor TEdit.Init;
begin
  MaxHeapSize:=HeapSize;
  inherited Init;
  EditorDialog:=StdEditorDialog;
  ClipWindow:=OpenEditor('',false);
  If ClipWindow <> nil then begin
    ClipBoard:=ClipWindow^.Editor;
    ClipBoard^.CanUndo:=False;
    end;
{  With Data do begin
    FntSize:=0;
    second:=1;
    end;}
end;
procedure TEdit.HandleEvent( var Event : TEvent);
 procedure FileOpen;
 var
    FileName : FNameStr;
 begin
 FileName:='*.*';
 If ExecuteDialog(New(PFileDialog,init('*.*','Open file','~N~ame',
                   fdOpenButton,100)),@FileName) <> cmCancel then
                   OpenEditor(FileName,True);
 FileWork:=FileName;
 end;
 procedure FileNew;
 begin
   Openeditor('',true);
 end;
 procedure ChangeDir;
 begin
   ExecuteDialog(New(PChDirDialog,Init(cdNormal,0)),nil);
 end;
 procedure ShowClip;
 begin
   ClipWindow^.Select;
   ClipWindow^.Show;
 end;
 procedure Print;
  var S:string;
      C:char;
      F:text;
 begin
   Assign(F,FileWork);
   Reset(F);
   repeat
   S:='';
   repeat
   read(F,C);
   S:=S+C;
   until Eoln(F);

   {Case Data.FntSize of
    0: begin Writeln(Lst,S);end;
    1: begin Write(lst,#16);  Writeln(Lst,S);end;
    2: begin Write(lst,#14);  Writeln(Lst,S);end;
    end;}
   Write(Lst,#13);
   Write(Lst,#16+S)
   until Eof(F);
   close(F);
 end;
begin
  inherited HandleEvent(Event);
  case Event.What of
   evCommand :
    case Event.Command of
     cmOpen : FileOpen;
     cmNew  : FileNew;
     cmChangeDir : ChangeDir;
     cmShowClip  : ShowClip;
     cmPrint : Print;
{     cmPrnAttr : PrnAttr;}
    else
     Exit;
    end;
  else
   Exit;
  end;
  ClearEvent(Event);
end;
procedure TEdit.InitMenuBar;
var
   R:TRect;
begin
 GetExtent(R);
 R.B.Y:=R.A.Y+1;
 MenuBar:=New(PMenuBar,Init(R,NewMenu(
   NewSubMenu('~F~ile',hcNoContext,NewMenu(
   StdFileMenuItems(nil)),
   NewSubMenu('~E~dit',hcNoContext,NewMenu(
   StdEditMenuItems(nil)),
   NewSubMenu('~W~indows',hcNoContext,NewMenu(
   StdWindowMenuItems(nil)),
   NewSubMenu('~P~rinter',hcNoContext,NewMenu(
    NewItem('P~r~int file in current window','',0,cmPrint,hcNoContext,
{    NewItem('~A~ttribute of print','',0,cmPrnAttr,hcNoContext,} nil)),
     nil)))))));
end;
procedure TEdit.InitStatusLine;
var
   R:TRect;
begin
  GetExtent(R);
  R.A.Y:=R.B.Y-1;
  New(StatusLine,Init(R,
   NewStatusDef(0,$FFFF,
    NewStatusKey('~F2~ Save',kbF2,cmSave,
    NewStatusKey('~F3~ Open',kbF3,cmOpen,
    NewStatusKey('~Alt-F3~ Close',kbAltF3,cmClose,
    NewStatusKey('~Alt-C~ Show Clipboard',kbAltC,cmShowClip,nil)))),nil)));
end;
{Procedure TEdit.PrnAttr;
Var
   Dlg : PDialog;
   CR : PView;
   R:TRect;
   Control:Word;
Begin
   R.Assign(20,6,60,19);
   Dlg:=New(PDialog,Init(R,'Диалоговое окно'));
   With Dlg^ do
      begin

      R.Assign(15,10,25,12);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
{      R.Assign(28,10,38,12);
      Insert(New(PButton,Init(R,'~H~elp',cmFirst,bfNormal)));
      R.Assign(3,3,18,6);
      CR:=New(PCheckBoxes,Init(R,
               NewSItem('~F~irst',
               NewSItem('~S~econd',
               NewSItem('~T~hird',
               nil)))));
      Insert(CR);
      R.Assign(3,2,11,3);
      Insert(New(PLabel,Init(R,'~N~umber',CR)));}
 {     R.Assign(21,3,37,6);
      CR:=New(PRadioButtons,Init(R,
               NewSItem('Normal',
               NewSItem('Smoll',
               NewSItem('Lahge',
               nil)))));
      Insert(CR);
      R.Assign(21,2,37,3);
      Insert(New(PLabel,Init(R,'~S~ize of font',CR)));
{      R.Assign(3,8,37,9);
      CR:=New(PInputLine,Init(R,128));
      Insert(CR);
      R.Assign(2,7,24,8);
      Insert(New(PLabel,Init(R,'~I~nstruction',CR)));
      end;}
  { Dlg^.SetData(Data);
   Control:=DeskTop^.ExecView(Dlg);
   If Control <> cmCancel Then Dlg^.GetData(Data);
end;
end;}
var
   Edit : TEdit;
begin
 Edit.Init;
 Edit.Run;
 Edit.Done;
end.
