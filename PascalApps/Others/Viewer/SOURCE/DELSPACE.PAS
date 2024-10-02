program DelSpace;
uses Dos;
var F,TMP:text;
    S:string;
    FileName:string;
    i:integer;
    D: DirStr;
    N: NameStr;
    E: ExtStr;
const
    TMPFile='~delspa~.tmp';
begin
 if ParamStr(1) <> '' then FileName:=Paramstr(1)
  else
  begin
  Writeln('Программа убирает пробелы в заголовках');
  Writeln('первого и второго уровня файлов *.str.');
  Writeln('Используется перед компиляцией файла *.str в *.stf');
  Exit;
  end;
 Assign(F,FileName);
 ReSet(F);
 Assign(TMP,TMPFile);
 ReWrite(TMP);
 repeat
 Readln(F,S);
 if (S[1] = '@') or (S[1] = '#') then
  begin
  for i:=2 to byte(S[0]) do
   begin
   if S[i] <> ' ' then
    break;
   end;
  Delete(S,2,i-2);
  end;
 Writeln(TMP,S);
 until EoF(F);
 Close(F);
 Close(TMP);
 FSplit(FExpand(FileName), D, N, E);
 Rename(F,N+'.old');
 Rename(TMP,FileName);
end.
