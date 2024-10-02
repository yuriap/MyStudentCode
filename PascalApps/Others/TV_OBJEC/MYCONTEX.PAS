Unit MyContext;{Контекстная подсказка}
Interface
Uses Menus;
const
  hcFile = 1001; hcNewWin = 1002; hcOpen = 1003;
  hcClose = 1004;hcWindow = 1005;
Type
  PHintStatusLine = ^THintStatusLine;
  THintStatusLine = object(TStatusLine)
    function Hint(AHelpCtx: Word): String; virtual;
  end;
Implementation
function THintStatusLine.Hint(AHelpCtx: Word): String;
begin
  case AHelpCtx of
    hcFile: Hint := 'Это меню File';
    hcOpen: Hint := 'Открывает новый файл';
    hcClose : Hint := 'Закрывает окно';
    hcNewWin: Hint := 'Открывает новое окно';
    hcWindow : Hint := 'Это окно';
  else
    Hint := '';
  end;
end;
Begin
End.
