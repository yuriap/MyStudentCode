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
    NewSubMenu('����',hcFile,NewMenu(
     NewItem('�������...','',0,cmCreateObj,hcCreateObj,
     NewItem('������...','F3',kbF3,cmOpenObj,hcOpenObj,
     NewItem('���࠭���','F2',kbF2,cmSaveObj,hcSaveObj,
     NewItem('���࠭��� ���...','',0,cmSaveAsObj,hcSaveAsObj,
     NewLine(
     NewItem('������� ��४���...','',0,cmChDir,hcChDir,
     NewItem('��室','Alt-X',kbAltX,cmQuit,hcQuit,
     nil)))))))),
    NewSubMenu('����',hcBuffer,NewMenu(
        NewItem('��ᯥ���... ','',0,cmServiceBuffer,hcNoContext,
     nil)),
    NewSubMenu('��ᬮ��',hcVievBuffer,NewMenu(
        NewItem('��ࠬ���� ��䨪�...','',0,cmGraphParam,hcGraphParam,
        NewItem('����ன�� 梥⮢...','',0,cmChColor,hcChColor,
        NewItem('��ᬮ�� ����᪨�','',0,cmViewBufferGraph,hcViewBGraph,
     nil)))),
     nil))))));
End;
function MakeStatusLine:PStatusLine;
Var R : TRect;
Begin
    R.Assign(0,24,80,25);
    MakeStatusLine:=New(PStatusLine,Init(R,
      NewStatusDef(0,$FFFF,
      NewStatusKey('~F1~ ������ ',kbF1,cmHelp,
        NewStatusKey('~Alt-X~ ��室',kbAltX,cmQuit,
          NewStatusKey('~F10~ ����',kbF10,cmMenu,
              StdStatusKeys(
        nil)))),nil)));
end;
function MakeBufGraphParamDlg:PDialog;
var R:TRect;
    D:PDialog;
    View:PView;
begin
  R.Assign(19,4,61,20);
  D:=New(PSpecialDlg,Init(R,'��ࠬ���� ����᪮�� ��ᬮ��'));
  With D^ do begin
    R.Assign(19,2,26,3);
    View:=New(PInpLineNE,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));
    Insert(View);
    R.Assign(1,2,18,3);
    Insert(New(PLabel,Init(R,'~A~.�a��⠡ �o X:',View)));

    R.Assign(19,3,26,4);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));
    Insert(View);
    R.Assign(1,3,18,4);
    Insert(New(PLabel,Init(R,'~B~.����⠡ �o Y:',View)));
{*******************************************}
    R.Assign(19,4,26,5);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));
    Insert(View);
    R.Assign(1,4,18,5);
    Insert(New(PLabel,Init(R,'~C~.��� c�⪨ �� X:',View)));

    R.Assign(19,5,26,6);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PFilterValidator,Init(['0'..'9','.']));
    Insert(View);
    R.Assign(1,5,18,6);
    Insert(New(PLabel,Init(R,'~D~.��� �⪨ �o Y:',View)));
{*******************************************}
    R.Assign(19,6,26,7);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,600));
    Insert(View);
    R.Assign(1,6,18,7);
    Insert(New(PLabel,Init(R,'~E~.��ᯮ������� X:',View)));

    R.Assign(19,7,26,8);
    View:=New(PInpLineNe,Init(R,7));
    View^.Options:=View^.Options or ofValidate;
    PInputLine(View)^.Validator:=New(PRangeValidator,Init(10,450));
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
    Insert(New(PButton,Init(R,'���~e~���',cmServiceBuffer,bfNormal)));
    R.Assign(27,8,39,10);
    Insert(New(PButton,Init(R,'�~p~�ᬮ��',cmViewBufferGraph,bfNormal)));
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