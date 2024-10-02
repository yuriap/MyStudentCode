program Pump;
uses Crt,Din,Graphics,Common,Graph;
const
   FileMod = 'pumpmod.dat';
   FileNat = 'pumpnat.dat';
   Count = 14;
var
  G:PGraphic;
  B,HC,NC,KC:PBuffer;
  GR:TGrRec;
  j:integer;
  cycl:boolean;
  title:string[7];
  TitleFull:String[40];
function Step(X,N:real):real;
begin
  if X > 0 then Step:=exp(N*Ln(X))
    else Step:=0;
end;
procedure PutBuffer(i:integer;Q,H,N,K:real);
begin
 HC^.PutX(i,Q);
 NC^.PutX(i,Q);
 KC^.PutX(i,Q);
 HC^.PutY(i,H);
 NC^.PutY(i,N);
 KC^.PutY(i,K);
end;
procedure MakeGraphRec(var aGRec:TGrRec);
begin
with aGRec do begin
     MasX:='100';
     MasY:='100';
     StepX:='0.2';
     StepY:='0.2';
     X:='50';
     Y:='50';
     XName:='';
     YName:='Func';
      Color[2]:=4;
      Color[3]:=5;
      Color[1]:=14;
      Color[0]:=7;
      OptionMas:=0;{Автоматическое масштабирование}
      Title:='';
     end;
end;{MakeGraphRec}

var
  FMod,FNat:text;
  D2M,D1M,b2M,BM,d0M,RoM,RoN,Lam:real;
  nM,nN,QM,QN,HM,HN,NMod,NNat,KPD:real;
begin
  StartGraph;
  Writeln;
  Writeln('Пересчет характеристик свободновихревого насоса');
  Writeln('CумГУ гр. ГМ-13 Кабанченко В.');
  Writeln;
  MakeGraphRec(GR);
  G:=New(PGraphic,Init(GR));
  HC:=New(PBuffer,init(Count));
  NC:=New(PBuffer,init(Count));
  KC:=New(PBuffer,init(Count));
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
  j:=1;
  while not(EoF(FMod)) do begin
  Readln(FMod,QM,HM,NMod,KPD);
  QN:=QM*nN*Step(Lam,3)/nM;
  HN:=HM*Step(nN/nM,2)*Step(Lam,2);
  NNat:=NMod*(RoN/RoM)*Step(nN/nM,3)*Step(Lam,5);
  PutBuffer(j,QN,HN,NNat,KPD);
  Inc(j);
  Writeln(FNat,'| ',QN:7:5,' |',HN:7:3,'  |',NNat:9:3,' |',KPD:4:1,'     |');
  end;
  Writeln(FNat,'------------------------------------------');
  Close(FMod);
  Close(FNat);
  Writeln('Вычисления окончены. Смотрите файл ',FileNat);
  SoundTrac;
  Writeln('Нажмите любую кдавишу...');
  ReadKey;
  cycl:=false;
  repeat
  Writeln('Просмотр: 1-напор; 2-мощность; 3-КПД; Q-Выход');
  case UpCase(ReadKey) of
    '1':begin B:=HC;title:='H';TitleFull:='Hапорная характеристика'end;
    '2':begin B:=NC;title:='N';TitleFull:='Мощностная характеристика'end;
    '3':begin B:=KC;title:='КПД';TitleFull:='КПД насоса'end;
    else
    cycl:=true;
    end;
  if not(cycl) then begin
  B^.Color:=4;
  B^.Labels:=title;
  G^.YName:=title;
  G^.Title:=TitleFull;
  G^.InsertBuffer(B);
  SetGraphMode(grMode);
  G^.Execute;
  RestoreCrtMode;
  G^.Collect^.AtDelete(0);
  end;
  until cycl;
  DoneGraph;
  Dispose(G,Done);
  Dispose(HC,Done);
  Dispose(NC,Done);
  Dispose(KC,Done);
end.



