Unit MyContext;{���⥪�⭠� ���᪠���}
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
    hcFile: Hint := '�� ���� File';
    hcOpen: Hint := '���뢠�� ���� 䠩�';
    hcClose : Hint := '����뢠�� ����';
    hcNewWin: Hint := '���뢠�� ����� ����';
    hcWindow : Hint := '�� ����';
  else
    Hint := '';
  end;
end;
Begin
End.
