program TvrProf;
uses Views,Menus,Objects,TvrComm,Drivers,App,Dialogs,StrmErr,TVRUnit
     ,Validate,ColorSel;
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
     NewItem('Сохранить как...','',0,cmSaveAsObj,hcSaveAsObj,
     NewLine(
     NewItem('Сменить директорию...','',0,cmChDir,hcChDir,
     NewItem('Выход','Alt-X',kbAltX,cmQuit,hcQuit,
     nil)))))))),
    NewSubMenu('Буфер',hcBuffer,NewMenu(
        NewItem('Диспетчер... ','',0,cmServiceBuffer,hcNoContext,
     nil)),
    NewSubMenu('Просмотр',hcVievBuffer,NewMenu(
        NewItem('Параметры графики...','',0,cmGraphParam,hcGraphParam,
        NewItem('Настройка цветов...','',0,cmChColor,hcChColor,
        NewItem('Просмотр графический','',0,cmViewBufferGraph,hcViewBGraph,
     nil)))),
     nil))))));
End;
function MakeStatusLine:PStatusLine;
Var R : TRect;
Begin
    R.Assign(0,24,80,25);
    MakeStatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FFFF,
      NewStatusKey('~F1~ Помощь ',kbF1,cmHelp,
        NewStatusKey('~Alt-X~ Выход',kbAltX,cmQuit,
          NewStatusKey('~F10~ Меню',kbF10,cmMenu,
              StdStatusKeys(
        nil)))),nil)));
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
    View:=New(PInpLineNE,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));
    Insert(View);
    R.Assign(1,2,18,3);
    Insert(New(PLabel,Init(R,'~A~.Мaсштаб пo X:',View)));

    R.Assign(19,3,26,4);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));
    Insert(View);
    R.Assign(1,3,18,4);
    Insert(New(PLabel,Init(R,'~B~.Масштаб пo Y:',View)));
{*******************************************}
    R.Assign(19,4,26,5);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));
    Insert(View);
    R.Assign(1,4,18,5);
    Insert(New(PLabel,Init(R,'~C~.Шаг cетки по X:',View)));

    R.Assign(19,5,26,6);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));
    Insert(View);
    R.Assign(1,5,18,6);
    Insert(New(PLabel,Init(R,'~D~.Шаг сетки пo Y:',View)));
{*******************************************}
    R.Assign(19,6,26,7);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,600));
    Insert(View);
    R.Assign(1,6,18,7);
    Insert(New(PLabel,Init(R,'~E~.Расположение X:',View)));

    R.Assign(19,7,26,8);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,450));
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
    Insert(New(PButton,Init(R,'Дисп~e~тчер',cmServiceBuffer,bfNormal)));
    R.Assign(27,8,39,10);
    Insert(New(PButton,Init(R,'П~p~осмотр',cmViewBufferGraph,bfNormal)));
{**************************************************}
    SelectNext(false);
  end;
  MakeBufGraphParamDlg:=D;
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
   R.Done;
   Writeln('Ok!!!');
end.