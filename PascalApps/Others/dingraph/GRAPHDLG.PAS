Unit GraphDlg;
Interface
Uses App,Objects,Views, Dialogs,MsgBox,Graphics,Drivers,Bound_1,Dinamics,Crt;
Const
  cmNewVec = 1100;
  cmEditVec = 1101;
  cmDelVec = 1102;
  cmViewDecVec = 1103;
  cmViewVec = 1104;
  cmDelVecAll = 1105;
  cmGrParam = 1106;

  {***********}
  cmFwd = 1104;
  cmBack = 1105;
  cmEnter = 1106;
Type
   PList = ^TList;
   TList = object(TListBox)
      function GetText(Item: Integer; MaxLen: Integer): String; virtual;
      end;
   PVecList = ^TVecList;
   TVecList = object(TDialog)
      LB:PList;
      constructor Init;
      procedure HandleEvent(var Event:TEvent);virtual;
      end;
   PGrDlgBox = ^TGrDlgBox;
   TGrDlgBox = object(TDialog)
      constructor Init;
      end;
   PNewVecBox = ^TNewVecBox;
   TNewVecBox = object(TDialog)
      constructor Init;
      end;
   PEditVec = ^TEditVec;
   TEditVec = object(TDialog)
      constructor Init;
      end;
   PViewDec = ^TViewDec;{��ᬮ�� ����� � �᫠� � ��� ।���஢����}
   TViewDec = object(TDialog)
      Num : string[5];
      Vector : PZVector;
      SText:PStaticText;
      ILine:PInputLine;
      constructor Init(Vec:PZVector);
      procedure HandleEvent( var Event:TEvent);virtual;
      end;
   TListRec = record
     List : PCollection;
     Selection : word;
     end;

function BuildList:PCollection;
Var
  ListRec:TListRec;
{  LB:PList;}
{*******************************************************}
Implementation
Function TList.GetText(Item: Integer; MaxLen: Integer): String;
var S : string[10];
begin
  If Graphic^.Collect^.At(Item) <> nil Then begin
  If PZVector(Graphic^.Collect^.At(Item))^.Visible
   Then S := '  ������' Else S := '��������';
  GetText:=PZVector(Graphic^.Collect^.At(Item))^.Labels+' '+S;end;
end;
function BuildList:PCollection;
var
  List:PCollection;
Begin
  List:=New(PCollection,Init(10,2));
  With List^ do begin
    Insert(NewStr('First item'));
    Insert(NewStr('Second item'));
    Insert(NewStr('Third item'));
    end;
  BuildList:=List;
end;
{********************************************************}

constructor TVecList.Init;
Var
  D:PDialog;
  R:TRect;
  SB:PScrollBar;
begin
 R.Assign(5,3,75,20);
    inherited Init(R,'��ࠢ�����');
    R.Assign(36,3,37,14);
    SB:=New(PScrollBar,Init(R));
    Insert(SB);
    R.Assign(5,3,35,14);
    LB:=New(PList,Init(R,1,SB));
    ListRec.List:=Graphic^.Collect;
    ListRec.Selection:=0;
    LB^.SetData(ListRec);
    LB^.Options:=LB^.Options or ofFramed;
    Insert(LB);
    Palette:=dpCyanDialog;
    R.Assign(5,1,35,2);
    Insert(New(PLabel,Init(R,'���᮪ ����஢',Lb)));
      R.Assign(50,3,65,5);
      Insert(New(PButton,Init(R,'~H~���',cmNewVec,bfNormal)));

      R.Assign(50,5,65,7);
      Insert(New(PButton,Init(R,'P~e~����.',cmEditVec,bfNormal)));
      R.Assign(50,7,65,9);
      Insert(New(PButton,Init(R,'�~p~oᬮ��',cmViewDecVec,bfNormal)));
      R.Assign(50,9,65,11);
      Insert(New(PButton,Init(R,'��~a~����',cmDelVec,bfNormal)));
      R.Assign(50,11,65,13);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(50,13,65,15);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
    SelectNext(False);
    {EventMask:=$FFFF;}
end;
procedure TVecList.HandleEvent(var Event:TEvent);
var A:boolean;
begin
   inherited HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
         cmNewVec : EndModal(cmNewVec);
         cmEditVec : EndModal(cmEditVec);
         cmDelVec : EndModal(cmDelVec);
         cmViewDecVec : EndModal(cmViewDecVec);
         else exit;
         end;
    ClearEvent(Event);
    end;
end;
{function TVecList.GetPalette:PPalette;
const P:string[Length(CVecList)] = CVecList;
begin
 GetPalette:=@P;
end;}
constructor TNewVecBox.Init;
var
   View: PView;
   Button : PRadioButtons;
   R:TRect;

begin
   R.Assign(5,3,75,20);
   inherited Init(R,'��ᮥ������� �����');
     R.Assign(3,3,40,9);
     Button:=New(PRadioButtons,Init(R,
     NewSItem('���騭� ���࠭�筮�� ᫮�',
     NewSItem('H�ଠ�� �᭮���� �⪨',
     NewSItem('H�ଠ�� �ᯮ����⥫쭮� �⪨',
     NewSItem('��ਧ��⠫� �᭮���� �⪨',
     NewSItem('��ਧ��⠫� �ᯮ����⥫쭮� �⪨',
     NewSItem('�᫮��� �� �࠭�� ��',nil))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(3,1,31,2);
    Insert(New(PLabel,Init(R,'�롮� ����� ��� ��ᬮ��',Button)));

      R.Assign(35,11,42,12);
      View:=New(PInputLine,Init(R,5));
      Insert(View);
      R.Assign(3,11,33,12);
      Insert(New(PLabel,Init(R,'H���� ��ଠ�� ��� ��ਧ��⠫�',View)));
      R.Assign(35,12,42,13);
      View:=New(PInputLine,Init(R,5));
      Insert(View);
      R.Assign(3,12,33,13);
      Insert(New(PLabel,Init(R,'��⪠ �����',View)));

    R.Assign(44,3,59,10);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('����� ',
     NewSItem('������',
     NewSItem('���㡮�',
     NewSItem('����',
     NewSItem('��म',
     NewSItem('����.',
     NewSItem('����',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(44,1,58,2);
    Insert(New(PLabel,Init(R,'����',Button)));
    R.Assign(44,13,58,15);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('������ ',
     NewSItem('���',
     nil))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(44,11,58,12);
    Insert(New(PLabel,Init(R,'���������',Button)));


      R.Assign(10,14,20,16);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(25,14,35,16);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);

end;
{************************************************************}
constructor TEditVec.Init;
var
   View: PView;
   Button : PRadioButtons;
   R:TRect;

begin
 R.Assign(17,5,63,19);
   inherited Init(R,'������஢���� ��ਡ�� �����');
      R.Assign(37,3,44,4);
      View:=New(PInputLine,Init(R,5));
      Insert(View);
      R.Assign(22,3,36,4);
      Insert(New(PLabel,Init(R,'��⪠ �����',View)));

    R.Assign(3,3,18,10);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('����� ',
     NewSItem('������',
     NewSItem('���㡮�',
     NewSItem('����',
     NewSItem('��म',
     NewSItem('����.',
     NewSItem('����',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(3,1,18,2);
    Insert(New(PLabel,Init(R,'����',Button)));
    R.Assign(26,6,41,8);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('������ ',
     NewSItem('���',
     nil))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(26,4,41,5);
    Insert(New(PLabel,Init(R,'���������',Button)));


      R.Assign(10,11,20,13);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(25,11,35,13);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);

end;
{************************************************************}
var
  Data : string[13];
constructor TViewDec.Init(Vec:PZVector);
var
   R:TRect;
   View:PView;
{   P:PCalculator;}
begin

  R.Assign(15,5,65,18);
  inherited Init(R,'��ᬮ�� �����');
    Vector:=Vec;
    R.Assign(25,6,40,7);
    View:=New(PInputLine,Init(R,13));
    ILine:=PInputLine(View);
    Insert(View);
    R.Assign(3,6,17,7);
    Insert(New(PLabel,Init(R,'��~e~���� �����',View)));
    R.Assign(19,6,24,7);
    SText:=New(PStaticText,Init(R,'0'));
    Insert(SText);
    R.Assign(15,2,40,3);
    Insert(New(PStaticText,Init(R,'��⪠ �����: '+Vector^.Labels)));
    R.Assign(15,3,40,4);
    Insert(New(PStaticText,Init(R,'�����୮��� �����')));
    R.Assign(15,4,40,5);
    Insert(New(PStaticText,Init(R,'�� 0 �� '+IntToStr(Vector^.N-1))));
    R.Assign(26,8,36,10);
    Insert(New(PButton,Init(R,'~B~��।',cmFwd,bfNormal)));
    R.Assign(38,8,48,10);
    Insert(New(PButton,Init(R,'~H~����',cmBack,bfNormal)));
    R.Assign(40,6,48,8);
    Insert(New(PButton,Init(R,'E~n~ter',cmEnter,bfNormal)));
{    R.Assign(49,1,73,16);
    P:=New(PCalculator,Init(R));
    Insert(P);}

    R.Assign(2,8,12,10);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(14,8,24,10);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

    Data:=RealStr(Vec^.Get(0));
  SelectNext(False);
  SetData(Data);
end;
{procedure TViewDec.Calculator;
var
   P:PCalculator;
begin
   P:=New(PCalculator,Init);
   Insert(P);
end;}
{function TViewDec.GetPalette:PPalette;
const P:string[Length(CViewDec)] = CViewDec;
begin
 GetPalette:=@P;
end;}

procedure TViewDec.HandleEvent( var Event:TEvent);
var S:String[5];
    Z,E:word;
    R:real;
begin
  inherited HandleEvent(Event);
  If Event.What = evCommand then begin
    Case Event.Command of
         cmFwd : begin
                 Val(SText^.Text^,Z,E);
                 DisposeStr(SText^.Text);
                 if Z < Vector^.N-1 Then Z:=Z+1 Else Z:=0;
                 SText^.Text:=NewStr(IntToStr(Z));
                 Data:=RealToStr(Vector^.Get(Z));
                 SetData(Data);
                 SText^.DrawView;
                 ILine^.DrawView;
                 end;
         cmBack : begin
                 Val(SText^.Text^,Z,E);
                 DisposeStr(SText^.Text);
                 if Z > 0 Then Z:=Z-1 Else Z:=Vector^.N-1;
                 SText^.Text:=NewStr(IntToStr(Z));
                 Data:=RealToStr(Vector^.Get(Z));
                 SetData(Data);
                 SText^.DrawView;
                 ILine^.DrawView;
                 end;
         cmEnter : begin
                 GetData(Data);
                 Val(SText^.Text^,Z,E);
                 Val(Data,R,E);
                 Vector^.Put(Z,R);
                 end;
         else exit;
         end;
    ClearEvent(Event);
    end;
end;

{************************************************************}
constructor TGrDlgBox.Init;
var
   R:TRect;
   View:PView;
   Button:PRadioButtons;
begin
   R.Assign(0,0,80,23);
   Inherited Init(R,'��䨪�');

    R.Assign(25,3,32,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,3,23,4);
    Insert(New(PLabel,Init(R,'~A~.�a��⠡ �o X:',View)));

    R.Assign(45,3,52,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(35,3,43,4);
    Insert(New(PLabel,Init(R,'~B~.�o Y:',View)));
{*******************************************}
    R.Assign(25,4,32,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,4,23,5);
    Insert(New(PLabel,Init(R,'~C~.��� c�⪨ �� X:',View)));

    R.Assign(45,4,52,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(35,4,42,5);
    Insert(New(PLabel,Init(R,'~D~.�o Y:',View)));
{*******************************************}
    R.Assign(25,5,32,6);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,5,23,6);
    Insert(New(PLabel,Init(R,'~E~.���p� ��䨪� X:',View)));

    R.Assign(45,5,52,6);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(35,5,43,6);
    Insert(New(PLabel,Init(R,'~F~.  Y:',View)));
{*******************************************}
    R.Assign(25,6,32,7);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,6,23,7);
    Insert(New(PLabel,Init(R,'~G~.������� ��।. X1:',View)));

    R.Assign(45,6,52,7);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(35,6,43,7);
    Insert(New(PLabel,Init(R,'~H~. X2:',View)));
{*******************************************}
    R.Assign(25,7,32,8);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,7,23,8);
    Insert(New(PLabel,Init(R,'~J~.��� ��㬥��:',View)));
{*******************************************}
    R.Assign(68,3,75,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(53,3,66,4);
    Insert(New(PLabel,Init(R,'~K~.��� �� X:',View)));

    R.Assign(68,4,75,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(53,4,66,5);
    Insert(New(PLabel,Init(R,'~L~.��� �� Y:',View)));
{**************************************************}
    R.Assign(3,11,15,18);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('����� ',
     NewSItem('������',
     NewSItem('���㡮�',
     NewSItem('����',
     NewSItem('��म',
     NewSItem('����.',
     NewSItem('����',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(3,9,15,10);
    Insert(New(PLabel,Init(R,'~M~.�뭮᪨',Button)));
{**************************************************}
    R.Assign(17,11,29,18);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('����� ',
     NewSItem('������',
     NewSItem('���㡮�',
     NewSItem('����',
     NewSItem('��म',
     NewSItem('����.',
     NewSItem('����',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(17,9,29,10);
    Insert(New(PLabel,Init(R,'~N~.��⪨',Button)));
{**************************************************}
    R.Assign(31,11,46,18);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('����� ',
     NewSItem('������',
     NewSItem('���㡮�',
     NewSItem('����',
     NewSItem('��म',
     NewSItem('����.',
     NewSItem('����',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(31,9,46,10);
    Insert(New(PLabel,Init(R,'~O~.��⪠',Button)));
{**************************************************}
    R.Assign(48,11,63,18);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('����� ',
     NewSItem('������',
     NewSItem('���㡮�',
     NewSItem('����',
     NewSItem('��म',
     NewSItem('����.',
     NewSItem('����',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(48,9,63,10);
    Insert(New(PLabel,Init(R,'~P~.��䨪',Button)));
{**************************************************}
    R.Assign(65,11,77,19);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('����',
     NewSItem('����� ',
     NewSItem('������',
     NewSItem('���㡮�',
     NewSItem('����',
     NewSItem('��म',
     NewSItem('����.',
     NewSItem('����',nil))))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(65,9,77,10);
    Insert(New(PLabel,Init(R,'~Q~.���',Button)));

      R.Assign(5,20,14,22);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(15,20,24,22);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

{**************************************************}
    SelectNext(false);
end;
{*******************************}
begin
end.