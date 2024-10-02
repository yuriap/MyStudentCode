      PMyDialog = ^TMyDialog;
      TMyDialog = object(TDialog)
        procedure HandleEvent(var Event : TEvent);virtual;
        procedure DialogInfo;
        end;
Procedure TMyApp.NewDialog;
Var
   MyDialog : PMyDialog;
   CheckRadio : PView;
   R:TRect;
   Control:Word;
Begin
   R.Assign(20,6,60,19);
   MyDialog:=New(PMyDialog,Init(R,'Диалоговое окно'));
   With MyDialog^ do
      begin

      R.Assign(15,10,25,12);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(28,10,38,12);
      Insert(New(PButton,Init(R,'~H~elp',cmFirst,bfNormal)));
      R.Assign(3,3,18,6);
      CheckRadio:=New(PCheckBoxes,Init(R,
               NewSItem('~F~irst',
               NewSItem('~S~econd',
               NewSItem('~T~hird',
               nil)))));
      Insert(CheckRadio);
      R.Assign(3,2,11,3);
      Insert(New(PLabel,Init(R,'~N~umber',CheckRadio)));
      R.Assign(21,3,37,6);
      CheckRadio:=New(PRadioButtons,Init(R,
               NewSItem('~R~ed',
               NewSItem('~G~reen',
               NewSItem('~B~lue',
               nil)))));
      Insert(CheckRadio);
      R.Assign(21,2,33,3);
      Insert(New(PLabel,Init(R,'~C~olor',CheckRadio)));
      R.Assign(3,8,37,9);
      CheckRadio:=New(PInputLine,Init(R,128));
      Insert(CheckRadio);
      R.Assign(2,7,24,8);
      Insert(New(PLabel,Init(R,'~I~nstruction',CheckRadio)));
      end;
   MyDialog^.SetData(DData);
   Control:=DeskTop^.ExecView(MyDialog);
   If Control <> cmCancel Then MyDialog^.GetData(DData);
end;
procedure TMyDialog.HandleEvent(var Event:TEvent);
begin
   inherited HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
         cmFirst : DialogInfo;
         else exit;
         end;
    ClearEvent(Event);
    end;
end;
