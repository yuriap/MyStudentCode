Unit ImitCont;
interface
Uses Menus;
const
  hcData = 1001;
  hcInput = 1002;
  hcEditor = 1003;
  hcGraphica = 1004;
  hcInfo = 1005;
  hcRaschet = 1006;
  hcStart = 1007;
  hcRezult =1008;
  hcPrint =1009;
  hcViewer =1010;
  hcUseProgHelp = 1011;
  hcSomeSing = 1012;
  hcSpravca = 1014;
Type
  PHintStatusLine = ^THintStatusLine;
  THintStatusLine = object(TStatusLine)
    function Hint(AHelpCtx: Word): String; virtual;
  end;
Implementation
function THintStatusLine.Hint(AHelpCtx: Word): String;
begin
  case AHelpCtx of
    hcData: Hint := '�� ���� "���� ������"';
    hcInput: Hint := '���� ����� ��襣� 䠩��';
    hcEditor : Hint := '������஢���� ������';
    hcGraphica: Hint := '��ᬮ�� ���⨭��';
    hcInfo : Hint := '���ଠ�� � �ணࠬ��';
    hcRaschet : Hint :='�믮������ ����';
    hcStart : Hint :='����� ����';
    hcRezult : Hint :='������������ � १���⮬';
    hcViewer : Hint :='��ᬮ�� १����';
    hcPrint : Hint :='����� १����';
    hcUseProgHelp : Hint :='�ᯮ�짮����� �ணࠬ��';
    hcSomeSing : Hint :='��-������';
    hcSpravca : Hint := '��ࠢ�筨�';
  else
    Hint := '';
  end;
end;
Begin
End.
