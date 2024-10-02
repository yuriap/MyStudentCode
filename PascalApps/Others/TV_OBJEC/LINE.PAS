Unit line;
Interface
Uses views,objects,dialogs;
Type
   PLineDialog = ^TLineDialog;
   TLineDialog = object(TDialog)
     Constructor Init;
     end;
Implementation
constructor TLineDialog.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 28, 10);
  inherited Init(R, 'Строка ввода');
  Options := Options or ofCentered;
  R.Assign(16, 5, 26, 7);
  Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  R.Assign(2, 5, 12, 7);
  Insert(New(PButton, Init(R, 'O~k~', cmOK, bfDefault)));

  R.Assign(4, 2, 24, 3);
  Insert(New(PInputLine, Init(R, 20)));

end;
begin
End.
