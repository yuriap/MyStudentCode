Unit BGraphDl;
Interface
Uses App,Objects,Views, Dialogs,MsgBox,BGraphic,Drivers,BBoundT,BDinamic,
     Crt,ColorSel;
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
   {Выбор вставляемого вектора }
   POptionCollect = ^TOptionCollect;
   TOptionCollect = object(TCollection)
      constructor Init;
      end;

   POptionList = ^TOptionList;
   TOptionList = object(TListBox)
      OptionCollect:POptionCollect;
      constructor Init(var Bounds: TRect; ANumCols: Word; AScrollBar:
                       PScrollBar);
      function GetText(Item: Integer; MaxLen: Integer): String; virtual;
      end;
   PNewVecBox = ^TNewVecBox;
   TNewVecBox = object(TDialog)
      CS:PColorSelector;
      LB:POptionList;
      constructor Init;
      procedure GetData(var Data);virtual;
      procedure SetData(var Data);virtual;
      end;
   PEditVec = ^TEditVec;
   TEditVec = object(TDialog)
      constructor Init;
      end;
   PViewDec = ^TViewDec;{просмотр вектора в числах и его редактирование}
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
   TVecRec = record
    Option : TListRec;
    Number : string[5];
    Name : string[5];
    Visible : word;
    Color :word;
    end;
Var
  ListRec:TListRec;
  ListOption:TListRec;
  VecRec:TVecRec;
{*******************************************************}
Implementation
Function TList.GetText(Item: Integer; MaxLen: Integer): String;
var S : string[10];
begin
  If Graphic^.Collect^.At(Item) <> nil Then begin
  If PZVector(Graphic^.Collect^.At(Item))^.Visible
   Then S := '  видимый' Else S := 'невидимый';
  GetText:=PZVector(Graphic^.Collect^.At(Item))^.Labels+' '+S;end;
end;
{********************************************************}

constructor TVecList.Init;
Var
  D:PDialog;
  R:TRect;
  SB:PScrollBar;
begin
 R.Assign(5,3,75,20);
    inherited Init(R,'Управление');
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
    Insert(New(PLabel,Init(R,'Список векторов',Lb)));
      R.Assign(38,3,52,5);
      Insert(New(PButton,Init(R,'~H~овый',cmNewVec,bfNormal)));

      R.Assign(38,5,52,7);
      Insert(New(PButton,Init(R,'P~e~дакт.',cmEditVec,bfNormal)));
      R.Assign(38,7,52,9);
      Insert(New(PButton,Init(R,'П~p~oсмотр',cmViewDecVec,bfNormal)));
      R.Assign(38,9,52,11);
      Insert(New(PButton,Init(R,'Уд~a~лить',cmDelVec,bfNormal)));
      R.Assign(38,11,52,13);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(38,13,52,15);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));
      R.Assign(54,3,69,5);
      Insert(New(PButton,Init(R,'Удалить все',cmDelVecAll,bfNormal)));
      R.Assign(54,5,69,7);
      Insert(New(PButton,Init(R,'Графика',cmViewVec,bfNormal)));
      R.Assign(54,7,69,9);
      Insert(New(PButton,Init(R,'Параметры',cmGrParam,bfNormal)));

    SelectNext(False);
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
         cmDelVecAll : EndModal(cmDelVecAll);
         cmViewVec : EndModal(cmViewVec);
         cmGrParam : EndModal(cmGrParam);
         else exit;
         end;
    ClearEvent(Event);
    end;
end;
constructor TOptionCollect.Init;
begin
  inherited Init(10,2);
    Insert(NewStr('Толщина пограничного слоя'));
    Insert(NewStr('Hормаль основной сетки'));
    Insert(NewStr('Hормаль вспомогательной сетки'));
    Insert(NewStr('Касательные напряжения'));
    Insert(NewStr('Коэфф. кас. напряжений'));
    Insert(NewStr('Окно'));
end;
constructor TOptionlist.Init(var Bounds: TRect; ANumCols: Word;
                             AScrollBar:PScrollBar);
begin
  inherited Init(Bounds,ANumCols,AScrollBar);
  OptionCollect:=New(POptionCollect,Init);
end;

function TOptionList.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetTExt:=string(OptionCollect^.At(Item)^);
end;
constructor TNewVecBox.Init;
var
   View: PView;
   Button : PRadioButtons;
   R:TRect;
   SB:PScrollBar;
begin
   R.Assign(5,3,75,20);
   inherited Init(R,'Присоединение вектора');
    R.Assign(39,3,40,9);
    SB:=New(PScrollBar,Init(R));
    Insert(SB);
    R.Assign(3,3,39,9);
    LB:=New(POptionList,Init(R,1,SB));
    VecRec.Option.List:=LB^.OptionCollect;
    VecRec.Option.Selection:=0;
    LB^.Options:=LB^.Options or ofFramed;
    Insert(LB);
    R.Assign(3,1,31,2);
    Insert(New(PLabel,Init(R,'Выбор вектора для просмотра',LB)));

      R.Assign(35,11,42,12);
      View:=New(PInputLine,Init(R,5));
      Insert(View);
      R.Assign(3,11,33,12);
      Insert(New(PLabel,Init(R,'Hомер нормали или горизонтали',View)));
      R.Assign(35,12,42,13);
      View:=New(PInputLine,Init(R,5));
      Insert(View);
      R.Assign(3,12,33,13);
      Insert(New(PLabel,Init(R,'Метка вектора',View)));

    R.Assign(44,3,57,7);
    CS:=New(PColorSelector,Init(R,TColorSel(0)));
    Insert(CS);
    R.Assign(44,1,58,2);
    Insert(New(PLabel,Init(R,'Цвет',CS)));

    R.Assign(44,1,58,2);
    Insert(New(PLabel,Init(R,'Цвет',Button)));
    R.Assign(44,13,58,15);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('Видимый ',
     NewSItem('Нет',
     nil))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(44,11,58,12);
    Insert(New(PLabel,Init(R,'Видимость',Button)));

      R.Assign(10,14,20,16);
      Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
      R.Assign(25,14,35,16);
      Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

      SelectNext(false);

end;
procedure TNewVecBox.GetData(var Data);
begin
 inherited GetData(Data);
 VecRec.Color:=CS^.Color;
end;
procedure TNewVecBox.SetData(var Data);
begin
 inherited SetData(Data);
 CS^.Color:=VecRec.Color;
end;

{************************************************************}
constructor TEditVec.Init;
var
   View: PView;
   Button : PRadioButtons;
   R:TRect;

begin
 R.Assign(17,5,63,19);
   inherited Init(R,'Редактирование атрибут вектора');
      R.Assign(37,3,44,4);
      View:=New(PInputLine,Init(R,5));
      Insert(View);
      R.Assign(22,3,36,4);
      Insert(New(PLabel,Init(R,'Метка вектора',View)));

    R.Assign(3,3,18,10);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('Синий ',
     NewSItem('Зеленый',
     NewSItem('Голубой',
     NewSItem('Красный',
     NewSItem('Бордо',
     NewSItem('Коричн.',
     NewSItem('Серый',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(3,1,18,2);
    Insert(New(PLabel,Init(R,'Цвет',Button)));
    R.Assign(26,6,41,8);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('Видимый ',
     NewSItem('Нет',
     nil))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(26,4,41,5);
    Insert(New(PLabel,Init(R,'Видимость',Button)));


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
begin

  R.Assign(15,5,65,18);
  inherited Init(R,'Просмотр вектора');
    Vector:=Vec;
    R.Assign(25,6,40,7);
    View:=New(PInputLine,Init(R,13));
    ILine:=PInputLine(View);
    Insert(View);
    R.Assign(3,6,17,7);
    Insert(New(PLabel,Init(R,'Эл~e~мент номер',View)));
    R.Assign(19,6,24,7);
    SText:=New(PStaticText,Init(R,'0'));
    Insert(SText);
    R.Assign(15,2,40,3);
    Insert(New(PStaticText,Init(R,'Метка вектора: '+Vector^.Labels)));
    R.Assign(15,3,40,4);
    Insert(New(PStaticText,Init(R,'Размерность вектора')));
    R.Assign(15,4,40,5);
    Insert(New(PStaticText,Init(R,'от 0 до '+IntToStr(Vector^.N-1))));
    R.Assign(26,8,36,10);
    Insert(New(PButton,Init(R,'~B~перед',cmFwd,bfNormal)));
    R.Assign(38,8,48,10);
    Insert(New(PButton,Init(R,'~H~азад',cmBack,bfNormal)));
    R.Assign(40,6,48,8);
    Insert(New(PButton,Init(R,'E~n~ter',cmEnter,bfNormal)));

    R.Assign(2,8,12,10);
    Insert(New(PButton,Init(R,'~O~k',cmOk,bfDefault)));
    R.Assign(14,8,24,10);
    Insert(New(PButton,Init(R,'~C~ancel',cmCancel,bfNormal)));

    Data:=RealStr(Vec^.Get(0));
  SelectNext(False);
  SetData(Data);
end;
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
   Inherited Init(R,'Графики');

    R.Assign(25,3,32,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,3,23,4);
    Insert(New(PLabel,Init(R,'~A~.Мaсштаб пo X:',View)));

    R.Assign(45,3,52,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(35,3,43,4);
    Insert(New(PLabel,Init(R,'~B~.пo Y:',View)));
{*******************************************}
    R.Assign(25,4,32,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,4,23,5);
    Insert(New(PLabel,Init(R,'~C~.Шаг cетки по X:',View)));

    R.Assign(45,4,52,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(35,4,42,5);
    Insert(New(PLabel,Init(R,'~D~.пo Y:',View)));
{*******************************************}
    R.Assign(25,5,32,6);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(3,5,23,6);
    Insert(New(PLabel,Init(R,'~E~.Якоpь графика X:',View)));

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
    Insert(New(PLabel,Init(R,'~G~.Область опред. X1:',View)));

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
    Insert(New(PLabel,Init(R,'~J~.Шаг аргумента:',View)));
{*******************************************}
    R.Assign(68,3,75,4);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(53,3,66,4);
    Insert(New(PLabel,Init(R,'~K~.Имя оси X:',View)));

    R.Assign(68,4,75,5);
    View:=New(PInputLine,Init(R,7));
    Insert(View);
    R.Assign(53,4,66,5);
    Insert(New(PLabel,Init(R,'~L~.Имя оси Y:',View)));
{**************************************************}
    R.Assign(3,11,15,18);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('Синий ',
     NewSItem('Зеленый',
     NewSItem('Голубой',
     NewSItem('Красный',
     NewSItem('Бордо',
     NewSItem('Коричн.',
     NewSItem('Серый',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(3,9,15,10);
    Insert(New(PLabel,Init(R,'~M~.Выноски',Button)));
{**************************************************}
    R.Assign(17,11,29,18);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('Синий ',
     NewSItem('Зеленый',
     NewSItem('Голубой',
     NewSItem('Красный',
     NewSItem('Бордо',
     NewSItem('Коричн.',
     NewSItem('Серый',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(17,9,29,10);
    Insert(New(PLabel,Init(R,'~N~.Метки',Button)));
{**************************************************}
    R.Assign(31,11,46,18);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('Синий ',
     NewSItem('Зеленый',
     NewSItem('Голубой',
     NewSItem('Красный',
     NewSItem('Бордо',
     NewSItem('Коричн.',
     NewSItem('Серый',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(31,9,46,10);
    Insert(New(PLabel,Init(R,'~O~.Сетка',Button)));
{**************************************************}
    R.Assign(48,11,63,18);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('Синий ',
     NewSItem('Зеленый',
     NewSItem('Голубой',
     NewSItem('Красный',
     NewSItem('Бордо',
     NewSItem('Коричн.',
     NewSItem('Серый',nil)))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(48,9,63,10);
    Insert(New(PLabel,Init(R,'~P~.График',Button)));
{**************************************************}
    R.Assign(65,11,77,19);
    Button:=New(PRadioButtons,Init(R,
     NewSItem('Черный',
     NewSItem('Синий ',
     NewSItem('Зеленый',
     NewSItem('Голубой',
     NewSItem('Красный',
     NewSItem('Бордо',
     NewSItem('Коричн.',
     NewSItem('Серый',nil))))))))));
     Button^.Options:=Button^.Options or ofFramed;
     Insert(Button);
    R.Assign(65,9,77,10);
    Insert(New(PLabel,Init(R,'~Q~.Фон',Button)));

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