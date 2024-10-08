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
      OptionMas:=0;{��⮬���᪮� ����⠡�஢����}
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
  Writeln('������ �ࠪ���⨪ ᢮��������ॢ��� ����');
  Writeln('C㬃� ��. ��-13 �����祭�� �.');
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
  Writeln('���᫥��� ����祭�. ������ 䠩� ',FileNat);
  SoundTrac;
  Writeln('������ ���� �������...');
  ReadKey;
  cycl:=false;
  repeat
  Writeln('��ᬮ��: 1-�����; 2-��魮���; 3-���; Q-��室');
  case UpCase(ReadKey) of
    '1':begin B:=HC;title:='H';TitleFull:='H���ୠ� �ࠪ���⨪�'end;
    '2':begin B:=NC;title:='N';TitleFull:='��魮�⭠� �ࠪ���⨪�'end;
    '3':begin B:=KC;title:='���';TitleFull:='��� ����'end;
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



