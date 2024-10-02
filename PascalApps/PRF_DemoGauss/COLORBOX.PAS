program ColorBox;
Uses Objects,Views,Dialogs,Drivers,App,Menus,ColorSel,Memory,MsgBox;
Const
  cmColorSelect = 2000;
  cmCS = 2001;
  cmViewColor = 2002;
Type
   PColor = ^TColor;
   TColor = array [0..5] of byte;

   TListRec = record
     List : PCollection;
     Selection : word;
     end;

   PColorApp = ^TColorApp;
   TColorApp = object(TApplication)
      procedure HandleEvent( var Event:TEvent);virtual;
      procedure InitMenuBar;virtual;
      procedure InitStatusLine;virtual;
      procedure ColorDlg;
      procedure ColorDlg1;
      end;
   POption = ^TOption;
   TOption = object(TCollection)
      constructor Init(Options:string);
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
      Data:PColor;
      constructor Init(Option:string);
      procedure HandleEvent( var Event:TEvent );virtual;
      procedure SetData(var D);virtual;
      procedure GetData(var D);virtual;
      end;
var ListRec:TListRec;
constructor TOption.Init(Options:string);
var
   i,j,Coun:byte;
   Opt:string;
   len:byte absolute Options;
begin
  Coun:=0;
  For i:=1 to len do if Options[i] = '.' then Coun:=Coun+1;
  inherited Init(len,0);
  Opt:='';
  For i:=1 to len do begin
    If Options[i] <> '.' then Opt:=Opt+Options[i]
      else begin
      Insert(NewStr(Opt));
      Opt:='';
      end;
  end;
end;{init}
function TList.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetText:=string(List^.At(Item)^);
end;
procedure TList.HandleEvent;
begin
  inherited HandleEvent(Event);
  If Last <> Focused Then begin
      PCDlg(Owner)^.Data^[Last]:=PCDlg(Owner)^.CS^.Color;
      Event.What:=evBroadCast;
      Event.Command:=cmViewColor;
      PutEvent(Event);
      Last:=Focused;
      end;
end;
procedure TCDlg.SetData(var D);
begin
  Data:=@TColor(D);
  CS^.Color:=TColor(Data^)[0];
end;
procedure TCDlg.GetData(var D);
begin
  TColor(D):=Data^;
end;
procedure TCDlg.HandleEvent;
begin
  Inherited HandleEvent(Event);
  If Event.What = evBroadCast then begin
  case Event.Command of
    cmViewColor:begin
                CS^.Color:=Data^[Lb^.Focused];
                Cs^.DrawView;
                end;
    else Exit;
    end;{case}
    ClearEvent(Event);
    end;

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
constructor TCDlg.Init;
var
  R:TRect;
  SB:PScrollBar;
begin
  R.Assign(20,7,60,18);
  inherited Init(R,'Настройка цветов');

    R.Assign(22,3,23,7);
    SB:=New(PScrollBar,Init(R));
    Insert(SB);
    R.Assign(2,3,22,7);
    LB:=New(PList,Init(R,1,SB));
    LB^.NewList(New(POption,Init(Option)));
    LB^.Options:=LB^.Options or ofFramed;
    Insert(LB);
    R.Assign(2,1,22,2);
    Insert(New(PLabel,Init(R,'Элементы',LB)));

    R.Assign(25,3,38,7);
    CS:=New(PColorSelector,Init(R,TColorSel(0)));
    Insert(CS);
    R.Assign(25,1,38,2);
    Insert(New(PLabel,Init(R,'Цвет',CS)));

    R.Assign(6,8,16,10);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(24,8,34,10);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    SelectNext(False);
end;
procedure TColorApp.ColorDlg1;
var Col:TColor;
    D:PCDlg;
begin
  Col[0]:=1;
  Col[1]:=2;
  Col[2]:=3;
  Col[3]:=4;
  D:=New(PCDlg,Init('Фон.Сетка.Выноски.Метки.'));
  D^.SetData(Col);
  If ExecView(D) <> cmCancel Then begin
  D^.GetData(Col);
  end;
  Dispose(D,Done);
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