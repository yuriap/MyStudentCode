program TvrPower;
uses Views,Menus,Objects,TvrComm,Drivers,App,Dialogs,StrmErr,TVRUnit
     ,Validate,ColorSel,ProfComm;
var S:PMsgStream;
    R:TResourceFile;
function MakeMenus:PMenuBar;
Var R : TRect;
Begin
  R.Assign(0,0,80,1);
  MakeMenus:=New(PMenuBar,Init(R,NewMenu(
    NewSubMenu('�~a~��',hcFile,NewMenu(
     NewItem('�������...','',0,cmCreateObj,hcCreateObj,
     NewItem('������...','F3',kbF3,cmOpenObj,hcOpenObj,
     NewItem('���࠭���','F2',kbF2,cmSaveObj,hcSaveObj,
     NewItem('�������','',0,cmDoneMain,hcDoneMain,
     NewLine(
     NewItem('��室','Alt-X',kbAltX,cmQuit,hcQuit,
     nil))))))),
    NewSubMenu('��~p~������',hcParametr,NewMenu(
           NewItem('����','F5',kbF5,cmListing,hcListing,
           NewItem('��樨','',0,cmMainOptions,hcMainOptions,
        NewSubMenu('��ࠬ���� ���ப���� ',hcNoContext,NewMenu(
           NewItem('��� �� �६���...','',0,cmDT,hcDT,
           NewItem('����� ��饭��...','',0,cmOmega,hcOmega,
           NewItem('Ux...','',0,cmUX,hcUX,
           NewItem('Uy...','',0,cmUY,hcUY,
           NewItem('������⢮ �६���...','',0,cmMaxTime,hcMaxTime,nil)))))),
{        NewSubMenu('��ࠬ���� ������ ',hcNoContext,NewMenu(
           NewItem('�������⢮ ᢮������ ���३...','',0,cmNFree,hcNFree,nil)),}
        NewSubMenu('��ࠬ���� ���࠭�筮�� ᫮�',hcNoContext,NewMenu(
           NewItem('Psi...','',0,cmPsi,hcPsi,
           NewItem('��ࠬ��� ��।�����...','',0,cmS,hcS,
           NewItem('���樨 �� ⮫騭� ��...','',0,cmMaxIter,hcMaxIter,
           NewItem('��筮���...','',0,cmParNevazka,hcParNevazka,
           NewItem('���樨 �� ���離�...','',0,cmMaxNevazka,hcMaxNevazka,
           NewItem('��筮��� �����...','',0,cmPrec,hcPrec,
           NewItem('������⢮ ᫮��...','',0,cmSloy,hcSloy,nil)))))))),
     nil))))),

    NewSubMenu('��~c~��',hcCalculate,NewMenu(
        NewItem('�믮������... ','',0,cmBegining,hcNoContext,
     nil)),
    NewSubMenu('�~e~������ ����',hcResults,NewMenu(
        NewSubMenu('��䨪�, �����... ',hcGraphics,NewMenu(
          NewItem('��ᯥ���...','',0,cmManager,hcManager,
          NewItem('��ࠬ���� ��䨪�...','',0,cmGraphParam,hcGraphParam,
          NewItem('����ன�� 梥⮢...','',0,cmChColor,hcChColor,
          NewItem('��ᬮ�� ����᪨�','',0,cmViewBufferGraph,hcViewBGraph,
          NewItem('���࠭��� ᯨ᮪ ��䨪��','',0,cmSLGraph,hcSLGraph,
          NewItem('����㧨�� ᯨ᮪ ��䨪��','',0,cmLLGraph,hcLLGraph,
          nil))))))),
        NewSubMenu('����o����� ',hcWindType,NewMenu(
          NewItem('��ࠬ���� ��䨪�...','',0,cmGParam,hcGParam,
          NewItem('����ன�� 梥⮢...','',0,cmCColor,hcCColor,
          NewItem('��ᬮ�� ����᪨�','',0,cmViewGraph,hcViewGraph,
          nil)))),
         NewItem('��᫮�� १�����...','',0,cmDigitResults,hcDigitResults,
        nil)))),
    NewSubMenu('�~o~����',hcHelp,NewMenu(
        NewItem('� �����','',0,cmHelp,hcHelp,
        NewItem('� �ணࠬ��','',0,cmAbout,hcNoContext,
        nil))),
     nil))))))));
End;
function MakeStatusLine:PStatusLine;
Var R : TRect;
Begin
    R.Assign(0,24,80,25);
    MakeStatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FF00,
      NewStatusKey('~F1~ ������ ',kbF1,cmHelp,
        NewStatusKey('~Alt-X~ ��室',kbAltX,cmQuit,
          NewStatusKey('~F10~ ����',kbF10,cmMenu,
              StdStatusKeys(
        nil)))),
      NewStatusDef($FF01,$FFFF,
      NewStatusKey('~Alt-S~ ��⠭���� ���᫥��� ',kbAltS,cmStop,nil),nil))));
end;
function MakeBufGraphParamDlg:PDialog;
var R:TRect;
    D:PDialog;
    View:PView;
begin
  R.Assign(19,4,60,20);
  D:=New(PSpecialDlg,Init(R,'��ࠬ���� ����᪮�� ��ᬮ��'));
  With D^ do begin
    R.Assign(19,2,26,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,18,3);
    Insert(New(PLabel,Init(R,'~A~.�a��⠡ �o X:',View)));

    R.Assign(19,3,26,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,18,4);
    Insert(New(PLabel,Init(R,'~B~.����⠡ �o Y:',View)));
{*******************************************}
    R.Assign(19,4,26,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,18,5);
    Insert(New(PLabel,Init(R,'~C~.��� c�⪨ �� X:',View)));

    R.Assign(19,5,26,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,18,6);
    Insert(New(PLabel,Init(R,'~D~.��� �⪨ �o Y:',View)));
{*******************************************}
    R.Assign(19,6,26,7);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,600));}
    Insert(View);
    R.Assign(1,6,18,7);
    Insert(New(PLabel,Init(R,'~E~.��ᯮ������� X:',View)));

    R.Assign(19,7,26,8);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,450));}
    Insert(View);
    R.Assign(1,7,18,8);
    Insert(New(PLabel,Init(R,'~F~.��ᯮ������� Y:',View)));
{*******************************************}
    R.Assign(19,8,26,9);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(1,8,18,9);
    Insert(New(PLabel,Init(R,'~K~.��� �� X:',View)));

    R.Assign(19,9,26,10);
    View:=New(PInputLine,Init(R,7));

    Insert(View);
    R.Assign(1,9,18,10);
    Insert(New(PLabel,Init(R,'~L~.��� �� Y:',View)));

    R.Assign(2,11,39,12);
    View:=New(PRadioButtons,Init(R,
       NewSItem('���o',
       NewSItem('~M~���⠡ ���짮��⥫�',nil))));
    View^.Options:=View^.Options or ofFramed;
    Insert(View);

    R.Assign(2,14,39,15);
    View:=New(PInputLine,Init(R,37));
    Insert(View);
    R.Assign(2,13,38,14);
    Insert(New(PLabel,Init(R,'~N~.�����㭮筠� �������',View)));

{*******************************************}
    R.Assign(27,2,39,4);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(27,4,39,6);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    R.Assign(27,6,39,8);
    Insert(New(PButton,Init(R,'���~e~���',cmManager,bfNormal)));
    R.Assign(27,8,39,10);
    Insert(New(PButton,Init(R,'�~p~�ᬮ��',cmViewBufferGraph,bfNormal)));
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
  R.Assign(19,3,60,21);
  D:=New(PSpecialDlg,Init(R,'�᭮��� ��ࠬ���� ���ப����'));
  With D^ do begin
    R.Assign(19,2,26,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,18,3);
    Insert(New(PLabel,Init(R,'~A~.���. �����⥩',View)));

    R.Assign(19,3,26,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,18,4);
    Insert(New(PLabel,Init(R,'~B~.��ठ',View)));
{*******************************************}
    R.Assign(19,4,26,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,18,5);
    Insert(New(PLabel,Init(R,'~C~.������ ��',View)));

    R.Assign(19,5,26,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,18,6);
    Insert(New(PLabel,Init(R,'~D~.��� �� �६���',View)));
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
    Insert(New(PLabel,Init(R,'~L~.�離����',View)));

    R.Assign(19,11,26,12);
    View:=New(PInpLineNe,Init(R,7));
    Insert(View);
    R.Assign(1,11,18,12);
    Insert(New(PLabel,Init(R,'~M~.Max Time',View)));

    R.Assign(2,13,39,16);
    View:=New(PCheckBoxes,Init(R,
       NewSItem('���o ࠧ����� ������',
       NewSItem('��� ᢮������ ���३',
       NewSItem('�����쭠� ��������',nil)))));
    View^.Options:=View^.Options or ofFramed;
    Insert(View);

{    R.Assign(2,14,39,15);
    View:=New(PInputLine,Init(R,37));
    Insert(View);
    R.Assign(2,13,38,14);
    Insert(New(PLabel,Init(R,'~N~.�����㭮筠� �������',View)));

{*******************************************}
    R.Assign(27,2,39,4);
    Insert(New(PButton,Init(R,'�������',cmOk,bfDefault)));
    R.Assign(27,4,39,6);
    Insert(New(PButton,Init(R,'Cancel',cmCancel,bfNormal)));
    R.Assign(27,6,39,8);
    Insert(New(PButton,Init(R,'��~o~䨫�..',cmProfParam,bfNormal)));
    R.Assign(27,8,39,10);
    Insert(New(PButton,Init(R,'�.~c~���...',cmBoundParam,bfNormal)));
    R.Assign(27,10,39,12);
    Insert(New(PButton,Init(R,'������',cmHelp,bfNormal)));
 {   R.Assign(27,8,39,10);
    Insert(New(PButton,Init(R,'�~p~�ᬮ��',cmViewBufferGraph,bfNormal)));
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
  R.Assign(10,7,70,16);
  D:=New(PSpecialDlg,Init(R,'��ࠬ���� ������'));
  With D^ do begin
    R.Assign(40,2,48,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,39,3);
    Insert(New(PLabel,Init(R,'~A~.������⢮ ����஫��� �祪 ',View)));

    R.Assign(40,3,48,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,39,4);
    Insert(New(PLabel,Init(R,
    '~B~.���-�� ��࠭塞�� ᢮������ ���३',View)));
{*******************************************}
    R.Assign(40,4,48,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,39,5);
    Insert(New(PLabel,Init(R,'~C~.������⢮ ��ଠ��� � �⪥',View)));

    R.Assign(40,5,48,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,39,6);
    Insert(New(PLabel,Init(R,'~D~.������⢮ ᫮�� � �⪥',View)));
{*******************************************}
    R.Assign(40,6,48,7);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,600));}
    Insert(View);
    R.Assign(1,6,39,7);
    Insert(New(PLabel,Init(R,'~E~.���� ��⠭����',View)));
{*******************************************}
    R.Assign(49,2,59,4);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(49,4,59,6);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    R.Assign(49,6,59,8);
    Insert(New(PButton,Init(R,'������',cmHelp,bfNormal)));
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
  R.Assign(15,5,65,20);
  D:=New(PSpecialDlg,Init(R,'��ࠬ���� ���࠭�筮�� ᫮�'));
  With D^ do begin
    R.Assign(41,2,48,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,40,3);
    Insert(New(PLabel,Init(R,'~A~.��筮��� ��।������ dU/dy',View)));

    R.Assign(41,3,48,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,40,4);
    Insert(New(PLabel,Init(R,'~B~.��ࠬ��� ��।�����',View)));
{*******************************************}
    R.Assign(41,4,48,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,40,5);
    Insert(New(PLabel,Init(R,'~C~.���-�� ���権 �� ⮫騭� ��',View)));

    R.Assign(41,5,48,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,40,6);
    Insert(New(PLabel,Init(R,'~D~.����稭� ���離�, %',View)));
{*******************************************}
    R.Assign(41,6,48,7);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,600));}
    Insert(View);
    R.Assign(1,6,40,7);
    Insert(New(PLabel,Init(R,'~E~.�o�-�� ���権 �� ���離�',View)));

    R.Assign(41,7,48,8);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,450));}
    Insert(View);
    R.Assign(1,7,40,8);
    Insert(New(PLabel,Init(R,'~F~. Prec',View)));
{*******************************************}
    R.Assign(41,8,48,9);
    View:=New(PInpLineNE,Init(R,7));
    Insert(View);
    R.Assign(1,8,40,9);
    Insert(New(PLabel,Init(R,'~K~.Sloy',View)));

    R.Assign(2,10,48,11);
    View:=New(PCheckBoxes,Init(R,
       NewSItem('���४�� ⮫騭� ��',nil)));
    View^.Options:=View^.Options or ofFramed;
    Insert(View);
{*******************************************}
    R.Assign(10,12,20,14);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(30,12,40,14);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
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
  D:=New(PSpecialDlg,Init(R,'��ࠬ���� ��ᬮ��'));
  With D^ do begin
    R.Assign(22,2,31,3);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,2,21,3);
    Insert(New(PLabel,Init(R,'~A~.����⠡ �� X:',View)));

    R.Assign(22,3,31,4);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,3,21,4);
    Insert(New(PLabel,Init(R,'~B~.����⠡ �� Y:',View)));
{*******************************************}
    R.Assign(22,4,31,5);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,4,21,5);
    Insert(New(PLabel,Init(R,'~C~.C��饭�� �� X:',View)));

    R.Assign(22,5,31,6);
    View:=New(PInpLineNe,Init(R,7));
{    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));}
    Insert(View);
    R.Assign(1,5,21,6);
    Insert(New(PLabel,Init(R,'~D~.C��饭�� �� Y:',View)));
{*******************************************}
    R.Assign(2,7,12,9);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(15,7,25,9);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    R.Assign(28,7,38,9);
    Insert(New(PButton,Init(R,'����',cmCColor,bfNormal)));
{**************************************************}
    SelectNext(false);
  end;
  MakeViewerDialog:=D;
end;
function MakeOptionWindow:PDialog;
var D:PDialog;
    R:TRect;
    View:PView;
begin
   R.Assign(20,7,60,16);
   D:=New(PDialog,Init(R,'��樨'));
   With D^ do begin
     R.Assign(5,2,35,5);
     View:=New(PCheckBoxes,Init(R,
        NewSItem('���ᨯ. �������樮����',
        NewSItem('���ᨯ. �� �६���',
        NewSItem('�����. �����饭��',nil)))));
     View^.Options:=View^.Options or ofFramed;
     Insert(View);
     R.Assign(6,6,16,8);
     Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
     R.Assign(24,6,34,8);
     Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
     SelectNext(False);
   end;
   MakeOptionWindow:=D;
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
   S:=New(PMsgStream,Init(WPowerResource,stCreate,2048));
   R.Init(S);
   R.Put(MakeMenus,MenusId);
   R.Put(MakeStatusLine,StatusLineId);
   R.Put(MakeBufGraphParamDlg,BufferGraphParamID);
   R.Put(New(PCDlg,Init),ColorDlgID);
   R.Put(MakeMainParamDlg,MainParamID);
   R.Put(MakeProfParamDlg,ProfParamID);
   R.Put(MakeBoundParamDlg,BoundParamID);
   R.Put(MakeViewerDialog,ViewerDialogID);
   R.Put(MakeOptionWindow,OptionWindowId);
   R.Done;
   SoundTrac;
   Writeln('Ok!!!');
end.