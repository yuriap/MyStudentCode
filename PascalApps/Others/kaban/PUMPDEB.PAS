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
  Writeln('Пересчет характеристик свободновихревого насоса');
  Writeln('CумГУ гр. ГМ-13 Кабанченко В.');
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
  Write('Введите частоту вращения вала натурного насоса, об/мин: ');
  Readln(nN);
  Write('Введите напор натурного насоса в оптимальном режиме, м: ');
  Readln(HN);
  Write('Введите плотность жидкости для натурного насоса, кг/м^3: ');
  Readln(RoN);
  Lam:=Sqrt((HN*Sqr(nM))/(HM*Sqr(nN)));
  Writeln(FNat,'Параметры натурного насоса');
  Writeln(FNat,D2M*Lam:7:4,' - диаметр D2, м');
  Writeln(FNat,D1M*Lam:7:4,' - диаметр D1, м');
  Writeln(FNat,b2M*Lam:7:4,' - ширина b2, м');
  Writeln(FNat,BM*Lam:7:4,' - ширина B, м');
  Writeln(FNat,d0M*Lam:7:4,' - диаметр d0, м');
  Writeln(FNat,nN:5:1,' - частота вращения n, об/мин');
  Writeln(FNat,HN:5:1,' - напор H, м');
  Writeln(FNat,RoN:5:1,' - плотность перекачиваемой жидкости Ro, кг/м^3');
  Writeln(FNat,'------------------------------------------');
  Writeln(FNat,'|Q,м^3/ч  |H,м      |N,Вт      |КПД,%    |');
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
  Writeln('Вычисления окончены. Смотрите файл ',FileNat);
  Writeln('Нажмите любую кдавишу...');
  ReadKey;
end.



