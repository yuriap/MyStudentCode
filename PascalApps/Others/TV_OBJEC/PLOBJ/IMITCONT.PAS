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
    hcData: Hint := 'Это меню "Ввод данных"';
    hcInput: Hint := 'Ввод имени Вашего файла';
    hcEditor : Hint := 'Редактирование данных';
    hcGraphica: Hint := 'Просмотр картинки';
    hcInfo : Hint := 'Информация о программе';
    hcRaschet : Hint :='Выполнение расчета';
    hcStart : Hint :='Запуск расчета';
    hcRezult : Hint :='Ознакомление с результатом';
    hcViewer : Hint :='Просмотр результата';
    hcPrint : Hint :='Печать результата';
    hcUseProgHelp : Hint :='Использование программы';
    hcSomeSing : Hint :='Что-нибуть';
    hcSpravca : Hint := 'Справочник';
  else
    Hint := '';
  end;
end;
Begin
End.
