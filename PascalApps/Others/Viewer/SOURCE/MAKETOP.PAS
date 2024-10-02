program MakeTop;
uses Crt,Dos;
const
    C1='#';C2='@';
    InFile:string='book3.txt';
    OutFile:string='bookres.txt';
    NHeader='Header';
    NTopic='Topics';
    NoContext='NoContext';
    top='.topic';
    LSTFile='maketop.lst';
type
  PTopic = ^TTopic;
  TTopic = object
    Topic:string;
    Number:word;
    Rang:byte;
    Next:PTopic;
    TextExist:boolean;
    Header:word;
    NameTopic:string;
    CountStr:word;
    constructor Init(ATopic:string;ANumber:word;ARang:byte);
    destructor Done;virtual;
    end;

    PListTopic = ^TListTopic;
    TListTopic = object
      FileIn:string[12];
      FileOut:string[12];
      ListTopic:PTopic;
      CountTopic:word;
      constructor Init(AFileIn,AFileOut:string);
      destructor Done;virtual;
      function GetTopic(Number:word):PTopic;
      function GetTopicForTopic(ATopic:string):PTopic;
      procedure MakeTopic;
      procedure MakeHeader;
      procedure MakeListingFile(LstFileName:string);
      end;

function IntToStr(I:integer):string;
var Result:string;
begin
   Str(I,Result);
   IntToStr:=Result;
end;

constructor TTopic.Init(ATopic:string;ANumber:word;ARang:byte);
begin
  Topic:=ATopic;
  Rang:=ARang;
  Number:=ANumber;
  NameTopic:='';
  Next:=nil;
  CountStr:=0;
end;
destructor TTopic.Done;
begin
  If Next <> Nil then Dispose(Next,Done);
end;
constructor TListTopic.Init(AFileIn,AFileOut:string);
var F:text;
    S:string;
    Num,CoStr:word;
    aRang:byte;
    CurHeader:PTopic;
    NewTopic,CurTopic:PTopic;
begin
 FileIn:=AFileIn;
 FileOut:=AFileOut;
 Assign(F,FileIn);
 Reset(F);
 Num:=1;
 CoStr:=0;
 CurTopic:=nil;
 NewTopic:=nil;
 repeat
  Readln(F,S);
  If (S[1] = C1) or (S[1] = C2) then
   begin
    If S[1] = C1 then
     begin
     aRang:=1;
     CurTopic^.CountStr:=CoStr;
     CoStr:=0;
     end;
    If S[1] = C2 then
     begin
     aRang:=0;
     end;
    S[1]:=' ';
    NewTopic:=New(PTopic,Init(S,Num,aRang));
    If NewTopic^.Rang = 0 then
     begin
     CurHeader:=NewTopic;
     CurHeader^.Header:=0;
     NewTopic^.NameTopic:=NHeader+IntToStr(Num);
     end
     else
     NewTopic^.NameTopic:=NTopic+IntToStr(Num);
    if Num = 1 then
     begin
     ListTopic:=NewTopic;
     CurTopic:=NewTopic;
     end
     else
     begin
      CurTopic^.Next:=NewTopic;
      CurTopic:=NewTopic;
      CurTopic^.Header:=CurHeader^.Number;
     end;
    Inc(Num);
    end
    else
     Inc(CoStr);
 until EoF(F);
 CurTopic^.CountStr:=CoStr;
 CountTopic:=Num-1;
 Close(F);
end;
destructor TListTopic.Done;
begin
  Dispose(ListTopic,Done);
end;
function TListTopic.GetTopic(Number:word):PTopic;
var CT:PTopic;
begin
  CT:=ListTopic;
  while CT^.Number <> Number do CT:=CT^.Next;
  GetTopic:=CT;
end;
function TListTopic.GetTopicForTopic(ATopic:string):PTopic;
var
  i:word;
  Topic:PTopic;
begin
  for i:=1 to CountTopic do
   begin
   Topic:=GetTopic(i);
   if Topic^.Topic = ATopic then
    begin
    GetTopicForTopic:=Topic;
    Exit;
    end
    else GetTopicForTopic:=nil;
   end;
end;
procedure TListTopic.MakeHeader;
var OFile:text;
    i,j,k,l:word;
    Topic:PTopic;
    CurHeader:PTopic;
    After:boolean;
begin
  Assign(OFile,FileOut);
  Rewrite(OFile);
  {******************************}
  WriteLN(OFile,'.topic ',NoContext,'=0');
  Writeln(OFile);
  Writeln(OFile);
  {reate first main topic}
  for i:=1 to CountTopic do
   begin
   Topic:=GetTopic(i);
   if Topic^.Rang = 0 then
    begin
    Writeln(OFile,'          {',Topic^.Topic,':',Topic^.NameTopic,'}');
    end;
   end;
  Writeln(OFile);
  {Содержание главы}
  After:=false;
  for i:=1 to CountTopic do
   begin
   Topic:=GetTopic(i);
   if Topic^.Rang = 0 then
    begin
    if After then Writeln(OFile,'          { Возврат:',NoContext,'}');
    Writeln(OFile);
    Writeln(OFile,top,' ',Topic^.NameTopic);
    Writeln(OFile);
    Writeln(OFile);
    end
    else
    begin
    Writeln(OFile,'          {',Topic^.Topic,':',Topic^.NameTopic,'}');
    After:=true;
    end;
   end;
   if After then Writeln(OFile,'          { Возврат:',NoContext,'}');
   Writeln(OFile);
  {******************************}
  Close(OFile);
end;
procedure TListTopic.MakeTopic;
var F1,F2:text;
    S:string;
    Topic,T,T2:PTopic;
    After:boolean;
begin
 Assign(F1,FileIn);
 Reset(F1);
 Assign(F2,FileOut);
 Append(F2);
 Writeln(F2);
 After:=false;
 repeat
  Readln(F1,S);
  If (S[1] <> C1) and (S[1] <> C2) then
   begin
   Writeln(F2,S);
   if S <> '' then After:=true;
   end
   else
   begin
   S[1]:=' ';
   Topic:=GetTopicForTopic(S);
   if Topic^.Rang = 1 then
    begin
    if After then
     begin
     Writeln(F2,'{ Возврат:',GetTopic(T^.Header)^.NameTopic,'}');
     Writeln(F2);
     Writeln(F2,'{ Cледующий:',T^.Next^.NameTopic,'}');
     Writeln(F2,'{ Пpедыдущий:',GetTopic(T^.Number-1)^.NameTopic,'}');
     end;
    Writeln(F2);
    Writeln(F2,top,' ',Topic^.NameTopic);
    Writeln(F2);
    Writeln(F2,'                         ',S);
    T:=Topic;
    end;
   end;
 until EoF(F1);
 if After then
  begin
  Writeln(F2);
  Writeln(F2);
  Writeln(F2,'{ Возврат:',GetTopic(Topic^.Header)^.NameTopic,'}');
  Writeln(F2);
  if T^.Next <> nil then
   Writeln(F2,'{ Cледующий:',T^.Next^.NameTopic,'}')
   else
   Writeln(F2,'{ Cледующий:',NoContext,'}');
  Writeln(F2,'{ Пpедыдущий:',GetTopic(T^.Number-1)^.NameTopic,'}');
  end;
 Close(F1);
 Close(F2);
end;
procedure TListTopic.MakeListingFile(LstFileName:string);
var
   i:integer;
   F:text;
   T:PTopic;
begin
  Assign(F,LstFileName);
  Rewrite(F);
  For i:=1 to CountTopic do
   begin
    T:=GetTopic(i);
    Writeln(F,T^.NameTopic,'; ',T^.Topic);
    Writeln(F,'Number: ',T^.Number,'; ','Count string: ',T^.CountStr);
    Writeln(F,'Header: ',GetTopic(T^.Header)^.Topic,'; ',GetTopic(T^.Header)^.NameTopic);
    Writeln(F);
   end;
  Close(F);
end;

var LT:PListTopic;
    i:integer;
    P: PathStr;
    D: DirStr;
    N: NameStr;
    E: ExtStr;
    MemorySize:longInt;
begin{program}
  MemorySize:=MemAvail;
  if ParamStr(1) = '?' then
   Begin
   Writeln('       Эта программа готовит специально обработанный текст');
   Writeln('       для Turbo Vision help compiller TVHC.EXE.');
   Writeln('       Более подробно смотри в помощи к viewer.exe.');
   Writeln('       Командная строка:');
   Writeln('                       maketop.exe <filename.str>');
   Exit;
   end;
  if Paramstr(1) = '' then
   begin
   Writeln('Используй  maketop.exe ? для получения справки');
   Exit;
   end;
  InFile:=ParamStr(1);
  FSplit(FExpand(InFile), D, N, E);
  OutFile:=N+'.top';
  LT:=New(PListTopic,Init(InFile,OutFile));
  LT^.MakeHeader;
  LT^.MakeTopic;
  LT^.MakeListingFile(LSTFile);
  Dispose(LT,Done);
  Writeln('Баланс памяти: ',MemorySize,':',MemAvail);
end.