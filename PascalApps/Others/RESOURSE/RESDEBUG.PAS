{Программа демонстрации использования файла ресурса
со сложными объектами}
program ResDebug;
Uses Figure,Objects,Crt,Graph;
var
   S: PBufStream;
   Res:TResourceFile;
   Collect:PFGroup;{см. модуль Figure}

   grDriver: Integer;
   grMode: Integer;
   ErrCode: Integer;

   Memory:LongInt;
begin
 Memory:=MemAvail;{Сохраняет размер кучи}
 {Регистрация объектов}
 RegisterType(RFigure);
 RegisterType(RBar);
 RegisterType(RCFigure);
 RegisterType(RFGroup);
 {Запуск графики}
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin  { Do graphics }
    Writeln('Graphics error:', GraphErrorMsg(ErrCode));
 end;
    SetTextStyle(0,0,2);
    OutTextXY(100,400,'Запись в ресурс');
    {Инициализация потока}
    S:=New(PBufStream,Init('object.rss',stCreate,1024));
    {Инициализация ресурса}
    Res.Init(S);
      {Инициализация прикладного объекта}
      Collect:=New(PFGroup,Init(5));
      {Запись объекта в ресурс с ключом "а"}
      Res.Put(Collect,'a');
      {Удаление прикладного объекта}
      Dispose(Collect,Done);
      {*******************}
      Collect:=New(PFGroup,Init(2));
      Res.Put(Collect,'b');
      Dispose(Collect,Done);
      {*******************}
      Collect:=New(PFGroup,Init(8));
      Res.Put(Collect,'c');
      Dispose(Collect,Done);
      {Удаление ресурса}
    Res.Done;

    OutTextXY(100,315,'Считывание из ресурса');

    {Инициализация потока}
    S:=New(PBufStream,Init('object.rss',stOpenRead,1024));
    {Инициализация ресурса}
    Res.Init(S);

      {Загрузка прикладного объекта из потока}
      Collect:=PFGroup(Res.Get('a'));
      {Прорисовка прикладного объекта}
      Collect^.Draw;
      {Удаление прикладного объекта}
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
      {Удаление ресурса}
    Res.Done;

    ReadKey;
  {Выгрузка графического драйвера}
  CloseGraph;
  {Сравнение размера кучи до и после манипуляций с динамическими объектами}
  Write('Баланс памяти: ',Memory,':',MemAvail);
  readkey;

end.
