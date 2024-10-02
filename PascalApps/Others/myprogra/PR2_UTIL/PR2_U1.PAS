program PR2_U1;
{Программа приготовления текста для печати в две колонки
посредством утилиты pr2.exe.
Удаляет из текста ненужные управляющие символы}
uses Crt,Dos;
type
  TEnableChar = set of char;
const EChar:TEnableChar=
     ['0'..'9','A'..'Z','a'..'z','!'..'@','А'..'Я',
     'а'..'я','['..'''','|'];
      FileTMP = 'pr2_u1.tmp';
var
  FName:PathStr;
  F,FTmp:Text;
  D:DirStr;
  N:NameStr;
  E:ExtStr;
  C:Char;
function IfInSet(AChar:Char;EC:TEnableChar):boolean;
begin
  IfInSet:=(AChar in EC);
end;
begin
  FName:=ParamStr(1);
  FSplit(FName,D,N,E);
  If not((E = '.txt') or (E = '.doc') or (E = '.dos')) then begin
    Writeln('Ошибка! Параметром данной программы должно');
    Writeln('быть имя текстового файла с расширением *.txt,*.doc.');
    Halt(0);
    end;
  Assign(F,FName);
  Assign(FTmp,FileTmp);
  Reset(F);
  ReWrite(FTmp);
  while not(EoF(F)) do begin
  while not(EoLn(F)) do begin
    Read(F,C);
    If not(IfInSet(C,EChar)) then C:=' ';
    Write(FTmp,C);
    end;
   ReadLn(F);
   Writeln(FTmp);
   end;
  Close(F);
  Close(FTmp);
  Rename(F,N+'.bak');
  Rename(FTmp,FName);
  Writeln('Процесс завершен!');
end.