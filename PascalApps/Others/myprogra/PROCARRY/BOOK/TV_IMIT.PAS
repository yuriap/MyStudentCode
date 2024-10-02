Program TV_Imit;
Uses app,objects,menus,HelpFile,Views,Drivers,MsgBox;
Const
      cmHelp=1010;
      IsHelp : boolean = false;

Type
    PMyApp = ^TMyApp;
    TMyApp = object(TApplication)
           constructor init;
           procedure initStatusLine;virtual;
           function GetPalette:PPalette;virtual;
           procedure GetEvent(var Event:TEvent);virtual;
           end;

constructor TMyApp.Init;
var
   Event:TEvent;
begin
     TApplication.Init;
     RegisterHelpFile;
          Event.What:=evCommand;
     Event.Command:=cmHelp;
     PutEvent(Event);

end;
Procedure TMyApp.InitStatusLine;
Var R : TRect;
Begin
     GetExtent(R);
     R.A.Y:=R.B.Y-1;
     StatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FFFF,
      NewStatusKey('~F1~ Вернуться в книгу ',kbF1,cmHelp,
        NewStatusKey('~Esc, Alt-X~ Выход',kbAltX,cmQuit,
          NewStatusKey(' ~Tab~ Перемещение по книге',kbF5,cmZoom,
        nil))),nil)));
End;

Function TMyApp.GetPalette;
Const MyColor : TPalette =CAppColor+CHelpColor;
begin
 GetPalette:=@MyColor;
end;
procedure TMyApp.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
const
  HelpInUse: Boolean = False;
begin
  inherited GetEvent(Event);
  case Event.What of
    evCommand:
      if (Event.Command = cmHelp) and not HelpInUse then
      begin
        HelpInUse := True;
        HelpStrm := New(PDosStream, Init('tpbook1.hlp', stOpenRead));
        HFile := New(PHelpFile, Init(HelpStrm));
        if HelpStrm^.Status <> stOk then
        begin
          MessageBox('Could not open help file.', nil, mfError + mfOkButton);
          Dispose(HFile, Done);
        end
        else
        begin
          W := New(PHelpWindow,Init(HFile, GetHelpCtx));
          if ValidView(W) <> nil then
          begin
            ExecView(W);
            Dispose(W, Done);
          end;
          ClearEvent(Event);
        end;
        HelpInUse := False;
      end;
    evMouseDown:
      if Event.Buttons <> 1 then Event.What := evNothing;
  end;
end;
Var
   MyApp : PMyApp;
   Rurk:Pointer;
begin
     MyApp:=New(PMyApp,Init);
     MyApp^.Run;
     Dispose(MyApp,Done);
end.
