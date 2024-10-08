program PumpDebug;
uses Crt;
const
   FileMod = 'pumpmod.old';
   FileNat = 'pumpnat.dat';
function Step(X,N:real):real;
begin
  if X > 0 then Step:=exp(N*Ln(X))
    else Step:=0;
end;
var
  FMod,FNat:text;
  D2M,D1M,b2M,BM,d0M,RoM,RoN,Lam:real;
  nM,nN,QM,QN,HM,HN,NMod,NNat,KPD:real;
begin
  Writeln;
  Writeln('������ �ࠪ���⨪ ᢮��������ॢ��� ����');
  Writeln('C㬃� ��. ��-13 �����祭�� �.');
  Writeln;
  Assign(FMod,FileMod);
  Assign(FNat,FileNat);
  Reset(FMod);
  ReWrite(FNat);
  Readln(FMod,D2M);
  Readln(FMod,D1M);
  Readln(FMod,b2M);
  Readln(FMod,BM);
  Readln(FMod,d0M);
  Readln(FMod,nM);
  Readln(FMod,HM);
  Readln(FMod,RoM);
  Write('������ ����� ��饭�� ���� ����୮�� ����, ��/���: ');
  Readln(nN);
  Write('������ ����� ����୮�� ���� � ��⨬��쭮� ०���, �: ');
  Readln(HN);
  Write('������ ���⭮��� ������� ��� ����୮�� ����, ��/�^3: ');
  Readln(RoN);
  Lam:=Sqrt((HN*Sqr(nM))/(HM*Sqr(nN)));
  Writeln(FNat,'��ࠬ���� ����୮�� ����');
  Writeln(FNat,D2M*Lam:7:4,' - ������� D2, �');
  Writeln(FNat,D1M*Lam:7:4,' - ������� D1, �');
  Writeln(FNat,b2M*Lam:7:4,' - �ਭ� b2, �');
  Writeln(FNat,BM*Lam:7:4,' - �ਭ� B, �');
  Writeln(FNat,d0M*Lam:7:4,' - ������� d0, �');
  Writeln(FNat,nN:5:1,' - ���� ��饭�� n, ��/���');
  Writeln(FNat,HN:5:1,' - ����� H, �');
  Writeln(FNat,RoN:5:1,' - ���⭮��� ��४�稢����� ������� Ro, ��/�^3');
  Writeln(FNat,'------------------------------------------');
  Writeln(FNat,'|Q,�^3/�  |H,�      |N,��      |���,%    |');
  Writeln(FNat,'------------------------------------------');
  Readln(FMod);
  while not(EoF(FMod)) do begin
  Readln(FMod,QM,HM,NMod,KPD);
  QN:=QM;
  HN:=HM*1.6;
  NNat:=NMod;
  Writeln(FNat,'  ',QN:7:5,'  ',HN:7:3,'   ',NNat:9:3,'  ',KPD:4:1,'      ');
  end;
  Writeln(FNat,'------------------------------------------');
  Close(FMod);
  Close(FNat);
  Writeln('���᫥��� ����祭�. ������ 䠩� ',FileNat);
  Writeln('������ ���� �������...');
  ReadKey;
end.



