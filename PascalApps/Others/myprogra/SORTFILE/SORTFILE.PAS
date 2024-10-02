program SortFile;
uses Dos, Strings, Windows, Crt;
type

    PFileList = ^TFileList;
    TFileList = object
       FileName:string;
       Path:string;
       FullPath:string;
       Size:longint;
       Index:word;
       Disk:word;
       Next:PFileList;
       constructor Init(AFullPath:string);
       destructor Done;virtual;
       function GetFileName:string;
       function GetFullPath:string;
       function GetNext:PFileList;
       procedure SetIndex(AIndex,ADisk:word);
       procedure GetIndex(var AIndex, ADisk:word);
       end;

    PManeger = ^TManeger;
    TManeger = object
       WorkDir:string;
       DestSort:string;
       BatchFile:string;
       Disks:integer;
       Files:word;
       FileList:PFileList;
       constructor Init(AWorkDir,ADestSort,ABatchFile:string);
       destructor Done;
       procedure BuildFileList;
       procedure SortFiles;
       procedure CreateBatchFiles;
       function GetFile(Index:word):PFileList;
       end;
var
    SizeDisk:longInt;
    Delta:longint;
    BatchPath:string[20];

function IntToStr(I:longint):string;
var Result:string;
begin
   Str(I,Result);
   IntToStr:=Result;
end;
constructor TFileList.Init(AFullPath:string);
var
    P: PathStr;
    D: DirStr;
    N: NameStr;
    E: ExtStr;
    F: File of byte;
begin
  FullPath:=AFullPath;
  FSplit(FullPath,D,N,E);
  FileName:=N+E;
  Assign(F,FullPath);
  Reset(F);
  Size:=FileSize(F);
  Close(F);
  Index:=0;
  Disk:=0;
  Next:=nil;
end;
destructor TFileList.Done;
begin
  If Next <> Nil then Next^.Done;
end;
function TFileList.GetFileName:string;
begin
   GetFileName:=FileName;
end;
function TFileList.GetFullPath:string;
begin
  GetFullPath:=FullPath;
end;
function TFileList.GetNext:PFileList;
begin
  GetNext:=Next;
end;
procedure TFileList.SetIndex(AIndex,ADisk:word);
begin
  Index:=AIndex;
  Disk:=ADisk;
end;
procedure TFileList.GetIndex(var AIndex, ADisk:word);
begin
  AIndex:=Index;
  ADisk:=Disk;
end;

constructor TManeger.Init(AWorkDir,ADestSort,ABatchFile:string);
begin
  WorkDir:=AWorkDir;
  DestSort:=ADestSort;
  BatchFile:=ABatchFile;
  Disks:=0;
  FileList:=nil;
  BuildFileList;
end;
destructor TManeger.Done;
begin
  If FileList <> nil then FileList^.Done;
end;
procedure TManeger.BuildFileList;
var CurrentFile,NewFile:PFileList;
    Search:SearchRec;
    FileIndex:word;
begin
  CurrentFile:=nil;
  FileIndex:=1;
  FindFirst(WorkDir+'\*.*',Archive,Search);
  while DosError = 0 do
   begin
   NewFile:=New(PFileList,Init(WorkDir+'\'+Search.Name));
   NewFile^.SetIndex(FileIndex,0);
   Inc(FileIndex);
   If FileList = nil then
     begin
     FileList:=NewFile;
     CurrentFile:=NewFile;
     end
    else
     begin
     CurrentFile^.Next:=NewFile;
     CurrentFile:=NewFile;
     end;
   FindNext(Search);
   end;
   Files:=FileIndex-1;
end;
function TManeger.GetFile(Index:word):PFileList;
var Curr:PFileList;
begin
  If (Index > Files) or (Index < 1) then
   begin
   GetFile:=nil;
   Exit;
   end;
  Curr:=FileList;
  while Curr^.Index <> Index do Curr:=Curr^.Next;
  GetFile:=Curr;
end;
procedure TManeger.SortFiles;
var F:PFileList;
    CurSize:longInt;
    RepVar,Exists:boolean;
    i:integer;
    Progress:longint;
    Message,Message1,Message2:string;
    CountUnSorted:word;
begin
  Disks:=1;
  CurSize:=0;
  Progress:=0;
  repeat
   Exists:=true;
   RepVar:=true;
   CountUnSorted:=0;
   for i:=1 to Files do
    begin
    {Цикл перебора}
    {*************}
     F:=GetFile(i);
     if F^.Disk = 0 then
      begin
       CurSize:=CurSize+F^.Size;
       If CurSize < SizeDisk+Delta then
        begin
        F^.Disk:=Disks;
        RepVar:=False;
        end
        else CurSize:=CurSize-F^.Size;
      end;
     If ((CurSize <= SizeDisk+Delta)and(CurSize > SizeDisk)) then
      begin
       Inc(Disks);
       CurSize:=0;
      end;
     if (i = Files) and RepVar then
      begin
       Inc(Disks);
       CurSize:=0;
      end;
     {*************}
     {Цикл перебора}
     if F^.Disk = 0 then
      begin
        Exists:=false;
        Inc(CountUnSorted);
      end;
     {***********}
    Inc(Progress);
    Message:='Files: '+IntToStr(i);
    Message1:='Progress: '+IntToStr(Progress);
    WriteXY(2,25,Message);
    WriteXY(15,25,Message1);
    If KeyPressed then halt(0);
    end;{for}
    Message2:='Unsorted: '+IntToStr(CountUnSorted);
    WriteXY(40,25,Message2);
  until Exists;
end;
procedure TManeger.CreateBatchFiles;
var Summ:word;
    F:text;
    i,j:integer;
    FN:string;
    FF:PFileList;
    S:longint;
    Count:word;
begin
   {Создает осн. пакетный файл}
   Assign(F,BatchPath+BatchFile);
   ReWrite(F);
   Writeln(F,'@echo off');
   for i:=1 to Disks do
    begin
     Writeln(F,'echo Insert disk ',i);
     Writeln(F,'pause');
     Writeln(F,'call disk',i,'.bat>nul');
    end;
   S:=0;
   For i:=1 to Files do S:=S+GetFile(i)^.Size;
   Writeln(F,'REM Total ',Files,' files with ',S,' bytes');
   Close(F);
   {Создает вспомогательные пакетные файлы}
   for i:=1 to Disks do
    begin
    S:=0;
    Count:=0;
    FN:=BatchPath+'disk'+IntToStr(i)+'.bat';
    Assign(F,FN);
    Rewrite(F);
    for j:=1 to Files do
     begin
     FF:=GetFile(j);
     if FF^.Disk = i then
      begin
       Writeln(F,'copy '+FF^.FullPath+' '+DestSort+FF^.FileName+'>NUL');
       S:=S+FF^.Size;
       Inc(Count);
      end;
     end;
    Writeln(F,'REM Total files ',Count,' with lenght ',S,' bytes');
    Close(F);
    end;{Создает вспомогательные пакетные файлы}
end;

var M:PManeger;
    i:integer;
    WD,DF,BF:string[20];
    F:text;
begin
  Writeln('Программа сортировки файлов по дискетам');
  Writeln('Подождите идет сортировка...');
  Writeln('Для остановки нажмите любую клавишу!');
  Writeln;
  Assign(F,'sortfile.ini');
  ReSet(F);
   Readln(F,WD);
   Readln(F,DF);
   Readln(F,BF);
   Readln(F,SizeDisk);
   Readln(F,Delta);
   Readln(F,BatchPath);
  Close(F);
  M:=New(PManeger,Init(wd,df,bf));
  M^.SortFiles;
  M^.CreateBatchFiles;
  Dispose(M,Done);
  WriteXY(2,25,'Сортировка завершена...                            ');
  Delay(500);
end.