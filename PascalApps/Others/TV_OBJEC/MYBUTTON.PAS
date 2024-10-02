Unit MyButton;
Interface
Uses Dialogs;
Type
  PButtonDialog = ^TButtonDialog;
  TButtonDialog = object(TDialog)
    constructor Init;
  end;
Implementation
Uses Objects,Views;
constructor TButtonDialog.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 27, 8);
  inherited Init(R, 'Press a button');
  Options := Options or ofCentered;
  R.Assign(2, 2, 12, 4);
  Insert(New(PButton, Init(R, 'O~k~', cmOK, bfDefault)));
  R.Assign(2, 5, 12, 7);
  Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  R.Assign(15, 2, 25, 4);
  Insert(New(PButton, Init(R, '~Y~es', cmYes, bfNormal)));
  R.Assign(15, 5, 25, 7);
  Insert(New(PButton, Init(R, '~N~o', cmNo, bfNormal)));
  SelectNext(False);
end;
Begin
End.