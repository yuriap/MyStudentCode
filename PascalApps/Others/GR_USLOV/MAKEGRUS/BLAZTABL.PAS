program BlazTabl;
uses Dos,Approxim;
var
   Etta,Fi,FiStrih,Fi2Strih:TArray;
   Tablica:TTablica;
const
   FileName:PathStr='BlazTabl.dat';
var
   Files:text;
   i:byte;
   Delta:real;
   Quant:integer;
   A,B,C,D:real;
   X,dX:real;
   FFi,FFiStrih:PArrayFunc;
begin
  Assign(Files,FileName);
  Reset(Files);
  Readln(Files);Readln(Files);Readln(Files);
  For i:=1 to Dim do begin
    Read(Files,Etta[i]);
    Read(Files,Fi[i]);
    Read(Files,FiStrih[i]);
    Readln(Files,Fi2Strih[i]);
    end;
    Close(Files);
  Write('Введите имя файла результата: ');
  Readln(FileName);
  Write('Введите толщину ПС из таблицы ("Etta"): ');
  ReadLn(Delta);
  Write('Введите колличество узлов по нормали считая с 0-м: ');
  Readln(Quant);
  For i:=1 to Dim do
    If Etta[i] = Delta Then Break;
  FFi:=New(PArrayFunc,Init(0,Delta,i));
  FFi^.GetArray(@Fi);
  FFiStrih:=New(PArrayFunc,Init(0,Delta,i));
  FFiStrih^.GetArray(@FiStrih);
  Assign(Files,FileName);
  ReWrite(Files);
  dX:=Delta/(Quant-1);
  For i:=0 to Quant-1 Do begin
     X:=dX*i;
     A:=FFi^.GetFunc(X);
     B:=FFiStrih^.GetFunc(X);
     C:=X*B-A;
     Writeln(Files,B:8:5,'   ',C:8:5);
     end;
  Writeln(Files);
  Writeln(Files,'  В первой колонке безразмерная продольная скорость U');
  Writeln(Files,'  Во второй колонке безразмерная поперечная скорость V');
  Writeln(Files,'  рассчит. по ф-ле [etta*FiStrih-Fi] в обозн.табл стр.');
  Writeln(Files,'  335 у Емцева');
  Close(Files);
  Dispose(FFi,Done);
  Dispose(FFiStrih,Done);
end.