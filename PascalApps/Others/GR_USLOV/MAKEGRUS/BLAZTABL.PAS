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
  Write('������ ��� 䠩�� १����: ');
  Readln(FileName);
  Write('������ ⮫騭� �� �� ⠡���� ("Etta"): ');
  ReadLn(Delta);
  Write('������ �������⢮ 㧫�� �� ��ଠ�� ���� � 0-�: ');
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
  Writeln(Files,'  � ��ࢮ� ������� ���ࠧ��ୠ� �த��쭠� ᪮���� U');
  Writeln(Files,'  �� ��ன ������� ���ࠧ��ୠ� �����筠� ᪮���� V');
  Writeln(Files,'  �����. �� �-�� [etta*FiStrih-Fi] � �����.⠡� ���.');
  Writeln(Files,'  335 � ��楢�');
  Close(Files);
  Dispose(FFi,Done);
  Dispose(FFiStrih,Done);
end.