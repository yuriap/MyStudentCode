{�ணࠬ�� ��������樨 �ᯮ�짮����� 䠩�� �����
� ᫮��묨 ��ꥪ⠬�}
program ResDebug;
Uses Figure,Objects,Crt,Graph;
var
   S: PBufStream;
   Res:TResourceFile;
   Collect:PFGroup;{�. ����� Figure}

   grDriver: Integer;
   grMode: Integer;
   ErrCode: Integer;

   Memory:LongInt;
begin
 Memory:=MemAvail;{���࠭�� ࠧ��� ���}
 {��������� ��ꥪ⮢}
 RegisterType(RFigure);
 RegisterType(RBar);
 RegisterType(RCFigure);
 RegisterType(RFGroup);
 {����� ��䨪�}
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin  { Do graphics }
    Writeln('Graphics error:', GraphErrorMsg(ErrCode));
 end;
    SetTextStyle(0,0,2);
    OutTextXY(100,400,'������ � �����');
    {���樠������ ��⮪�}
    S:=New(PBufStream,Init('object.rss',stCreate,1024));
    {���樠������ �����}
    Res.Init(S);
      {���樠������ �ਪ������� ��ꥪ�}
      Collect:=New(PFGroup,Init(5));
      {������ ��ꥪ� � ����� � ���箬 "�"}
      Res.Put(Collect,'a');
      {�������� �ਪ������� ��ꥪ�}
      Dispose(Collect,Done);
      {*******************}
      Collect:=New(PFGroup,Init(2));
      Res.Put(Collect,'b');
      Dispose(Collect,Done);
      {*******************}
      Collect:=New(PFGroup,Init(8));
      Res.Put(Collect,'c');
      Dispose(Collect,Done);
      {�������� �����}
    Res.Done;

    OutTextXY(100,315,'���뢠��� �� �����');

    {���樠������ ��⮪�}
    S:=New(PBufStream,Init('object.rss',stOpenRead,1024));
    {���樠������ �����}
    Res.Init(S);

      {����㧪� �ਪ������� ��ꥪ� �� ��⮪�}
      Collect:=PFGroup(Res.Get('a'));
      {���ᮢ�� �ਪ������� ��ꥪ�}
      Collect^.Draw;
      {�������� �ਪ������� ��ꥪ�}
      Dispose(Collect,Done);
      readkey;
      {*******************}
      Collect:=PFGroup(Res.Get('b'));
      Collect^.Draw;
      Dispose(Collect,Done);
      readkey;
      {*******************}
      Collect:=PFGroup(Res.Get('c'));
      Collect^.Draw;
      Dispose(Collect,Done);
      {�������� �����}
    Res.Done;

    ReadKey;
  {���㧪� ����᪮�� �ࠩ���}
  CloseGraph;
  {�ࠢ����� ࠧ��� ��� �� � ��᫥ �������権 � �������᪨�� ��ꥪ⠬�}
  Write('������ �����: ',Memory,':',MemAvail);
  readkey;

end.
