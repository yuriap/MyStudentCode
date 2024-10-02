program TvrProf;
uses Views,Menus,Objects,TvrComm,Drivers,App,Dialogs,StrmErr,TVRUnit
     ,Validate,ColorSel,ProfComm;
var S:PMsgStream;
    R:TResourceFile;
function MakeMenus:PMenuBar;
Var R : TRect;
Begin
  R.Assign(0,0,80,1);
  MakeMenus:=New(PMenuBar,Init(R,NewMenu(
    NewSubMenu('Файл',hcFile,NewMenu(
     NewItem('Создать...','',0,cmCreateObj,hcCreateObj,
     NewItem('Открыть...','F3',kbF3,cmOpenObj,hcOpenObj,
     NewItem('Сохранить','F2',kbF2,cmSaveObj,hcSaveObj,
     NewItem('Удалить','',0,cmDoneMain,hcDoneMain,
     NewLine(
     NewItem('Выход','Alt-X',kbAltX,cmQuit,hcQuit,
     nil))))))),
    NewSubMenu('Параметры',hcParametr,NewMenu(
        NewSubMenu('Параметры ветроколеса ',hcNoContext,NewMenu(
           NewItem('Шаг по времени...','',0,cmDT,hcDT,
           NewItem('Частота вращения...','',0,cmOmega,hcOmega,
           NewItem('Ux...','',0,cmUX,hcUX,
           NewItem('Uy...','',0,cmUY,hcUY,
           NewItem('Колличество времени...','',0,cmMaxTime,hcMaxTime,nil)))))),
        NewSubMenu('Параметры лопасти ',hcNoContext,NewMenu(
           NewItem('Колличество свободных вихрей...','',0,cmNFree,hcNFree,nil)),
        NewSubMenu('Параметры пограничного слоя',hcNoContext,NewMenu(
           NewItem('Psi...','',0,cmPsi,hcPsi,
           NewItem('Параметр усреднения...','',0,cmS,hcS,
           NewItem('Итерации по толщине ПС...','',0,cmMaxIter,hcMaxIter,
           NewItem('Точность...','',0,cmParNevazka,hcParNevazka,
           NewItem('Итерации по невязке...','',0,cmMaxNevazka,hcMaxNevazka,
           NewItem('Точность эпюры...','',0,cmPrec,hcPrec,
           NewItem('Колличество слоев...','',0,cmSloy,hcSloy,nil)))))))),
     nil)))),

    NewSubMenu('Расчет',hcCalculate,NewMenu(
        NewItem('Выполнение... ','',0,cmBegining,hcNoContext,
     nil)),
    NewSubMenu('Резултаты расчета',hcResults,NewMenu(
        NewSubMenu('Графики, эпюры... ',hcGraphics,NewMenu(
          NewItem('Диспетчер...','',0,cmManager,hcManager,
          NewItem('Параметры графики...','',0,cmGraphParam,hcGraphParam,
          NewItem('Настройка цветов...','',0,cmChColor,hcChColor,
          NewItem('Просмотр графический','',0,cmViewBufferGraph,hcViewBGraph,
          nil))))),
        NewSubMenu('Ветроколесо ',hcWindType,NewMenu(
          NewItem('Параметры графики...','',0,cmGParam,hcGParam,
          NewItem('Настройка цветов...','',0,cmCColor,hcCColor,
          NewItem('Просмотр графический','',0,cmViewGraph,hcViewGraph,
          nil)))),
        NewItem('Числовые результаты...','',0,cmDigitResults,hcDigitResults,
        nil)))),
     nil)))))));
End;
function MakeStatusLine:PStatusLine;
Var R : TRect;
Begin
    R.Assign(0,24,80,25);
    MakeStatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FF00,
      NewStatusKey('~F1~ Помощь ',kbF1,cmHelp,
        NewStatusKey('~Alt-X~ Выход',kbAltX,cmQuit,
          NewStatusKey('~F10~ Меню',kbF10,cmMenu,
              StdStatusKeys(
        nil)))),
      NewStatusDef($FF01,$FFFF,
      NewStatusKey('~Alt-S~ Остановка вычислений ',kbAltS,cmStop,nil),nil))));
end;
function MakeBufGraphParamDlg:PDialog;
var R:TRect;
    D:PDialog;
    View:PView;
begin
  R.Assign(19,4,61,20);
  D:=New(PSpecialDlg,Init(R,'Параметры графического просмотра'));
  With D^ do begin
    R.Assign(19,2,26,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,18,3);
    Insert(New(PLabel,Init(R,'~A~.Мaсштаб пo X:',View)));

    R.Assign(19,3,26,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,18,4);
    Insert(New(PLabel,Init(R,'~B~.Масштаб пo Y:',View)));
{*******************************************}
    R.Assign(19,4,26,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,18,5);
    Insert(New(PLabel,Init(R,'~C~.Шаг cетки по X:',View)));

    R.Assign(19,5,26,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,18,6);
    Insert(New(PLabel,Init(R,'~D~.Шаг сетки пo Y:',View)));
{*******************************************}
    R.Assign(19,6,26,7);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,600));}
    Insert(View);
    R.Assign(1,6,18,7);
    Insert(New(PLabel,Init(R,'~E~.Расположение X:',View)));

    R.Assign(19,7,26,8);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,450));}
    Insert(View);
    R.Assign(1,7,18,8);
    Insert(New(PLabel,Init(R,'~F~.Расположение Y:',View)));
{*******************************************}
    R.Assign(19,8,26,9);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(1,8,18,9);
    Insert(New(PLabel,Init(R,'~K~.Имя оси X:',View)));

    R.Assign(19,9,26,10);
    View:=New(PInputLine,Init(R,7));

    Insert(View);
    R.Assign(1,9,18,10);
    Insert(New(PLabel,Init(R,'~L~.Имя оси Y:',View)));

    R.Assign(2,11,39,12);
    View:=New(PRadioButtons,Init(R,
       NewSItem('Автo',
       NewSItem('~M~асштаб пользователя',nil))));
    View^.Options:=View^.Options or ofFramed;
    Insert(View);

    R.Assign(2,14,39,15);
    View:=New(PInputLine,Init(R,37));
    Insert(View);
    R.Assign(2,13,38,14);
    Insert(New(PLabel,Init(R,'~N~.Подрисуночная подпись',View)));

{*******************************************}
    R.Assign(27,2,39,4);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(27,4,39,6);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    R.Assign(27,6,39,8);
    Insert(New(PButton,Init(R,'Дисп~e~тчер',cmManager,bfNormal)));
    R.Assign(27,8,39,10);
    Insert(New(PButton,Init(R,'П~p~осмотр',cmViewBufferGraph,bfNormal)));
{**************************************************}
    SelectNext(false);
  end;
  MakeBufGraphParamDlg:=D;
end;
function MakeMainParamDlg:PSpecialDlg;
var R:TRect;
    D:PSpecialDlg;
    View:PView;
begin
  R.Assign(19,4,61,20);
  D:=New(PSpecialDlg,Init(R,'Основные параметры ветроколеса'));
  With D^ do begin
    R.Assign(19,2,26,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,18,3);
    Insert(New(PLabel,Init(R,'~A~.Колл. лопастей',View)));

    R.Assign(19,3,26,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,18,4);
    Insert(New(PLabel,Init(R,'~B~.Хорда',View)));
{*******************************************}
    R.Assign(19,4,26,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,18,5);
    Insert(New(PLabel,Init(R,'~C~.Радиус ВК',View)));

    R.Assign(19,5,26,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,18,6);
    Insert(New(PLabel,Init(R,'~D~.Шаг по времени',View)));
{*******************************************}
    R.Assign(19,6,26,7);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,600));}
    Insert(View);
    R.Assign(1,6,18,7);
    Insert(New(PLabel,Init(R,'~E~. Ux',View)));

    R.Assign(19,7,26,8);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,450));}
    Insert(View);
    R.Assign(1,7,18,8);
    Insert(New(PLabel,Init(R,'~F~. Uy',View)));
{*******************************************}
    R.Assign(19,8,26,9);
    View:=New(PInpLineNE,Init(R,7));
    Insert(View);
    R.Assign(1,8,18,9);
    Insert(New(PLabel,Init(R,'~K~.Omega',View)));

    R.Assign(19,9,26,10);
    View:=New(PInpLineNE,Init(R,7));
    Insert(View);
    R.Assign(1,9,18,10);
    Insert(New(PLabel,Init(R,'~L~.Betta0',View)));


    R.Assign(19,10,26,11);
    View:=New(PInpLineNe,Init(R,7));
    Insert(View);
    R.Assign(1,10,18,11);
    Insert(New(PLabel,Init(R,'~L~.Вязкость',View)));

    R.Assign(19,11,26,12);
    View:=New(PInpLineNe,Init(R,7));
    Insert(View);
    R.Assign(1,11,18,12);
    Insert(New(PLabel,Init(R,'~M~.Max Time',View)));

    R.Assign(2,13,39,14);
    View:=New(PCheckBoxes,Init(R,
       NewSItem('Автo разбивка контура',nil)));
    View^.Options:=View^.Options or ofFramed;
    Insert(View);

{    R.Assign(2,14,39,15);
    View:=New(PInputLine,Init(R,37));
    Insert(View);
    R.Assign(2,13,38,14);
    Insert(New(PLabel,Init(R,'~N~.Подрисуночная подпись',View)));

{*******************************************}
    R.Assign(27,2,39,4);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(27,4,39,6);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    R.Assign(27,6,39,8);
    Insert(New(PButton,Init(R,'Помощь',cmHelp,bfNormal)));
    R.Assign(27,8,39,10);
    Insert(New(PButton,Init(R,'Пофиль...',cmProfParam,bfNormal)));
    R.Assign(27,10,39,12);
    Insert(New(PButton,Init(R,'П.слой...',cmBoundParam,bfNormal)));
 {   R.Assign(27,8,39,10);
    Insert(New(PButton,Init(R,'П~p~осмотр',cmViewBufferGraph,bfNormal)));
{**************************************************}
    SelectNext(false);
  end;
  MakeMainParamDlg:=D;
end;
function MakeProfParamDlg:PSpecialDlg;
var R:TRect;
    D:PSpecialDlg;
    View:PView;
begin
  R.Assign(19,4,61,20);
  D:=New(PSpecialDlg,Init(R,'Параметры лопасти'));
  With D^ do begin
    R.Assign(19,2,26,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,18,3);
    Insert(New(PLabel,Init(R,'~A~.Колл. к.т. ',View)));

    R.Assign(19,3,26,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,18,4);
    Insert(New(PLabel,Init(R,'~B~.Колл. св.в.',View)));
{*******************************************}
    R.Assign(19,4,26,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,18,5);
    Insert(New(PLabel,Init(R,'~C~.Колл. норм.',View)));

    R.Assign(19,5,26,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,18,6);
    Insert(New(PLabel,Init(R,'~D~.Колл. слоев',View)));
{*******************************************}
    R.Assign(19,6,26,7);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,600));}
    Insert(View);
    R.Assign(1,6,18,7);
    Insert(New(PLabel,Init(R,'~E~.Угол установки',View)));
{*******************************************}
    R.Assign(27,2,39,4);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(27,4,39,6);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    R.Assign(27,6,39,8);
    Insert(New(PButton,Init(R,'Помощь',cmHelp,bfNormal)));
{**************************************************}
    SelectNext(false);
  end;
  MakeProfParamDlg:=D;
end;
function MakeBoundParamDlg:PSpecialDlg;
var R:TRect;
    D:PSpecialDlg;
    View:PView;
begin
  R.Assign(19,4,61,20);
  D:=New(PSpecialDlg,Init(R,'Параметры пограничного слоя'));
  With D^ do begin
    R.Assign(19,2,26,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,18,3);
    Insert(New(PLabel,Init(R,'~A~.Psi',View)));

    R.Assign(19,3,26,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,18,4);
    Insert(New(PLabel,Init(R,'~B~.S',View)));
{*******************************************}
    R.Assign(19,4,26,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,18,5);
    Insert(New(PLabel,Init(R,'~C~.MaxIter',View)));

    R.Assign(19,5,26,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,18,6);
    Insert(New(PLabel,Init(R,'~D~.Hевязка, %',View)));
{*******************************************}
    R.Assign(19,6,26,7);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,600));}
    Insert(View);
    R.Assign(1,6,18,7);
    Insert(New(PLabel,Init(R,'~E~. MaxNevazka',View)));

    R.Assign(19,7,26,8);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,450));}
    Insert(View);
    R.Assign(1,7,18,8);
    Insert(New(PLabel,Init(R,'~F~. Prec',View)));
{*******************************************}
    R.Assign(19,8,26,9);
    View:=New(PInpLineNE,Init(R,7));
    Insert(View);
    R.Assign(1,8,18,9);
    Insert(New(PLabel,Init(R,'~K~.Sloy',View)));

    R.Assign(2,13,39,14);
    View:=New(PCheckBoxes,Init(R,
       NewSItem('Коррекция толщины ПС',nil)));
    View^.Options:=View^.Options or ofFramed;
    Insert(View);
{*******************************************}
    R.Assign(27,2,39,4);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(27,4,39,6);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    R.Assign(27,6,39,8);
{**************************************************}
    SelectNext(false);
  end;
  MakeBoundParamDlg:=D;
end;
function MakeViewerDialog:PSpecialDlg;
var R:TRect;
    D:PSpecialDlg;
    View:PView;
begin
  R.Assign(20,7,60,17);
  D:=New(PSpecialDlg,Init(R,'Параметры просмотра'));
  With D^ do begin
    R.Assign(22,2,31,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,21,3);
    Insert(New(PLabel,Init(R,'~A~.Масштаб по X:',View)));

    R.Assign(22,3,31,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,21,4);
    Insert(New(PLabel,Init(R,'~B~.Масштаб по Y:',View)));
{*******************************************}
    R.Assign(22,4,31,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,21,5);
    Insert(New(PLabel,Init(R,'~C~.Cмещение по X:',View)));

    R.Assign(22,5,31,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,21,6);
    Insert(New(PLabel,Init(R,'~D~.Cмещение по Y:',View)));
{*******************************************}
    R.Assign(2,6,12,8);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(15,6,25,8);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    R.Assign(28,6,38,8);
    Insert(New(PButton,Init(R,'Цвета',cmCColor,bfNormal)));
{**************************************************}
    SelectNext(false);
  end;
  MakeViewerDialog:=D;
end;

begin
   RegisterObjects;
   RegisterViews;
   RegisterMenus;
   RegisterDialogs;
   RegisterType(RSpecialDlg);
   RegisterValidate;
   RegisterType(RInpLineNe);
   RegisterColorSel;
   RegisterColorDlg;
   S:=New(PMsgStream,Init(TvrFile,stCreate,2048));
   R.Init(S);
   R.Put(MakeMenus,MenusId);
   R.Put(MakeStatusLine,StatusLineId);
   R.Put(MakeBufGraphParamDlg,BufferGraphParamID);
   R.Put(New(PCDlg,Init),ColorDlgID);
   R.Put(MakeMainParamDlg,MainParamID);
   R.Put(MakeProfParamDlg,ProfParamID);
   R.Put(MakeBoundParamDlg,BoundParamID);
   R.Put(MakeViewerDialog,ViewerDialogID);
   R.Done;
   SoundTrac;
   Writeln('Ok!!!');
end.