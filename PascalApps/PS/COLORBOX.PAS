program ColorBox;
Uses Objects,Views,Dialogs,Drivers,App,Menus,ColorSel,Memory,MsgBox;
Const
  cmColorSelect = 2000;
  cmCS = 2001;
  cmViewColor = 2002;
Type
   TListRec = record
     List : PCollection;
     Selection : word;
     end;
   PObj = ^TObj;
   TObj = object(TObject)
     Color:byte;
     Name:string[10];
     constructor Init(AColor:byte;AName:String);
     end;

   PColorApp = ^TColorApp;
   TColorApp = object(TApplication)
      procedure HandleEvent( var Event:TEvent);virtual;
      procedure InitMenuBar;virtual;
      procedure InitStatusLine;virtual;
      procedure ColorDlg;
      procedure ColorDlg1;
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
      procedure HandleEvent( var Event:TEvent );virtual;
      end;
var ListRec:TListRec;
constructor TObj.Init(AColor:byte;AName:String);
begin
  Color:=AColor;
  Name:=AName;
end;
function TList.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetText:=PObj(List^.At(Item))^.Name;
end;
procedure TList.HandleEvent;
begin
  inherited HandleEvent(Event);
  If Last <> Focused Then begin
      PObj(List^.At(Last))^.Color:=PCDlg(Owner)^.CS^.Color;
      Message(Owner,evBroadCast,cmViewColor,@Self);
      Last:=Focused;
      end;
end;
function BuildList:PCollection;
var
  List:PCollection;
begin
  List:=New(PCollection,Init(10,2));
  with List^ do begin
  Insert(New(PObj,Init(0,'Первый')));
  Insert(New(PObj,Init(1,'Второй')));
  Insert(New(PObj,Init(2,'Третий')));
  end;
  BuildList:=List;
end;
procedure TCDlg.HandleEvent;
begin
  If Event.What = evBroadCast then begin
  case Event.Command of
    cmViewColor:begin
                CS^.Color:=PObj(LB^.List^.At(Lb^.Focused))^.Color;
                Cs^.DrawView;
                end;
    else Exit;
    end;{case}
    ClearEvent(Event);
    end;
  Inherited HandleEvent(Event);
end;
procedure TColorApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y+1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~C~olor', 0, NewMenu(
      NewItem('~B~ox of color', '', kbNoKey, cmColorSelect, 0,
      NewItem('~M~y Box of color','',0,cmCS,0,
      nil))),nil))));
end;

procedure TColorApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('', kbF10, cmMenu,
      nil)),
    nil)));
end;
procedure TColorApp.ColorDlg1;
var
  R:TRect;
  D:PCDlg;
  CStr:String[12];
  SB:PScrollBar;
  Rec : record
   color:byte;
   end;

begin
  R.Assign(5,3,75,19);
  D:=New(PCDlg,Init(R,'Color'));
  with D^ do begin
  R.Assign(5,3,18,7);
  CS:=New(PColorSelector,Init(R,TColorSel(0)));
  Insert(CS);

    R.Assign(40,3,41,7);
    SB:=New(PScrollBar,Init(R));
    Insert(SB);
    R.Assign(20,3,40,7);
    LB:=New(PList,Init(R,1,SB));
    ListRec.List:=BuildList;
    ListRec.Selection:=0;
    LB^.SetData(ListRec);
    LB^.Options:=LB^.Options or ofFramed;
    Insert(LB);
    R.Assign(20,1,40,2);
    Insert(New(PLabel,Init(R,'Выбор для просмотра',LB)));

  R.Assign(5,11,15,13);
  Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
  end;

  If ExecView(D) <> cmCancel Then begin
  Case D^.CS^.Color of
    0:CStr:='Black';
    1:CStr:='Blue';
    2:CStr:='Green';
    3:CStr:='Red';
    4:CStr:='Magenta';
    5:CStr:='Gray';
    6:CStr:='LihtGray';
    end;end;
  Dispose(D,Done);
  MessageBox('Выбранный цвет:'
             +^M^C+CStr,nil,mfInformation or mfOkButton);

end;
procedure TColorApp.ColorDlg;
var
  D: PColorDialog;
begin
  D := New(PColorDialog, Init('',
    ColorGroup('Desktop',       DesktopColorItems(nil),
    ColorGroup('Menus',         MenuColorItems(nil),
    ColorGroup('Dialogs/Calc',  DialogColorItems(dpGrayDialog, nil),
    ColorGroup('Editor/Puzzle', WindowColorItems(wpBlueWindow, nil),
    ColorGroup('Ascii table',   WindowColorItems(wpGrayWindow, nil),
    ColorGroup('Calendar',
      WindowColorItems(wpCyanWindow,
      ColorItem('Current day',       22, nil)),
      nil))))))));


  if ExecuteDialog(D, Application^.GetPalette) <> cmCancel then
  begin
    DoneMemory;    { Dispose all group buffers }
    ReDraw;        { Redraw application with new palette }
  end;
end;

procedure TColorApp.HandleEvent;
begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmColorSelect: ColorDlg;
          cmCS : ColorDlg1;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;

Var
  ColorApp:PColorApp;
begin
  ColorApp:=New(PColorApp,Init);
  ColorApp^.Run;
  Dispose(ColorApp,Done);
end.