program fifi;
uses Dos,Approxim;
var
   Fi,FiStrih:TArray;
   Tablica:TTablica;
const
   FileName:PathStr='fi&fi.dat';
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
  For i:=1 to Dim do
    Read(Files,Fi[i]);
    Readln(Files);
  For i:=1 to Dim do
    Read(Files,FiStrih[i]);
    Close(Files);
  Write('������ ��� 䠩�� १����: ');
  Readln(FileName);
  Write('������ �������⢮ 㧫�� �� ��ଠ�� ���� � 0-�: ');
  Readln(Quant);
  FFi:=New(PArrayFunc,Init(0,1,Dim));
  FFi^.GetArray(@Fi);
  FFiStrih:=New(PArrayFunc,Init(0,1,Dim));
  FFiStrih^.GetArray(@FiStrih);
  Assign(Files,FileName);
  ReWrite(Files);
  dX:=1/(Quant-1);
  For i:=0 to Quant-1 Do begin
     X:=dX*i;
     A:=FFi^.GetFunc(X);
     B:=FFiStrih^.GetFunc(X);
     Writeln(Files,A:8:5,'  ',B:8:5);
     end;
  Close(Files);
  Dispose(FFi,Done);
  Dispose(FFiStrih,Done);
end.