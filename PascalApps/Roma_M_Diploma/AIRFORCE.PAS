program AirForce;
{�ணࠬ�� ���� ��த������᪨� ᨫ ��������� �� ������}
{���ப���� ��⮣��������� ⨯�}
{�㬃� ��-12 ��᫮� �.�.}
uses Crt,Din,Graphics,Common,Graph;
const
   CtCrFile = 'Ct_Cr.dat';{䠩� ������}
   FileRez = 'Ft_Fr.dat';{䠩� १���⮢}
   N = 36;{�������⢮ ������ �祪}
var
  {��६���� ��� ���ᮢ�� ��䨪��}
  G:PGraphic;
  B,CT_B,CR_B,FT_B,FR_B,V_B:PBuffer;
  GR:TGrRec;
  j:integer;
  cycl:boolean;
  title:string[7];
  TitleFull:String[40];
procedure MakeGraphRec(var aGRec:TGrRec);
{��ࠬ���� ���樠����樨 ��ꥪ� TGraphic}
begin
with aGRec do begin
     MasX:='100';
     MasY:='100';
     StepX:='0.2';
     StepY:='0.2';
     X:='50';
     Y:='50';
     XName:='����';
     YName:='';
      Color[2]:=5;
      Color[3]:=4;
      Color[1]:=14;
      Color[0]:=7;
      OptionMas:=0;{��⮬���᪮� ����⠡�஢����}
      Title:='';
     end;
end;{MakeGraphRec}
var
  FDat,FRez:text;{��६���� 䠩��� ������ � १����}
  Betta,Ct,Cr,V,S,V0,l,H,Ro,Tetta,U0:real;
  i:integer;
begin
  Writeln(StartGraph);{���樠������ ��䨪�}
  Writeln('����� ��த������᪨� ᨫ,��������� �� ������ ���ப����');
  Writeln('C㬃� ��. ��-12');
  Writeln('CopyRight (c) ��᫮� �.�.');
  Writeln;
  {���樠������ ��ꥪ� TGraphic}
  MakeGraphRec(GR);
  G:=New(PGraphic,Init(GR));
  {���樠������ ���ᨢ�� ��� �࠭����
  ��।������ ᨫ �� ��㣮��� ����}
  CT_B:=New(PBuffer,init(N));
  CR_B:=New(PBuffer,init(N));
  FT_B:=New(PBuffer,init(N));
  FR_B:=New(PBuffer,init(N));
  V_B:=New(PBuffer,init(N));{�⭮�⥫쭠� ᪮����}
  {���뢠��� �� 䠩�� ���祭�� Ct � Cr}
  Assign(FDat,CtCrFile);
  Reset(FDat);
  Readln(FDat);
  For i:=1 to N do begin
    ReadLn(FDat,Betta,Ct,Cr);
    CT_B^.PutX(i,Betta);
    CR_B^.PutX(i,Betta);
    CT_B^.PutY(i,Ct);
    CR_B^.PutY(i,Cr);
    end;
  Close(FDat);
  {���� ��室��� ������}
  Write('������ ᪮���� �������饭���� ��⮪�, �/�: ');
  Readln(U0);
  Write('������ ��� ������, �: ');
  Readln(l);
  Write('������ �����  ������, �: ');
  Readln(H);
  Write('������ �����室����� ��: ');
  Readln(Tetta);
  Write('������ ���⭮��� ������, ��/�^3: ');
  Readln(Ro);
  V0:=Tetta*U0;{���㦭�� ᪮���� ������}
  S:=l*H;{���頤� ������}
  For i:=1 to N do begin
    Betta:=CT_B^.GetX(i);
    V_B^.PutX(i,Betta);
    FT_B^.PutX(i,Betta);
    FR_B^.PutX(i,Betta);
    {������� ��⮪� �⭮�⥫쭮 ������}
    V_B^.PutY(i,Sqrt(Sqr(U0)+Sqr(V0)-
		2*U0*V0*cos(pi-Betta*pi/180)));
    {����� ᨫ�}
    FT_B^.PutY(i,CT_B^.GetY(i)*S*Ro*Sqr(V_B^.GetY(i))/2);
    {������쭠� ᨫ�}
    FR_B^.PutY(i,CR_B^.GetY(i)*S*Ro*Sqr(V_B^.GetY(i))/2);
    end;
  {������ १���⮢ � 䠩�}
  Assign(FRez,FileRez);
  ReWrite(FRez);
  Writeln(FRez,'��ࠬ����');
  Writeln(FRez,U0:6:3,' - ᪮���� �������饭���� ��⮪�, �/�: ');
  Writeln(FRez,l:6:3,' - �ठ ������, �: ');
  Writeln(FRez,H:6:3,' - ����  ������, �: ');
  Writeln(FRez,Ro:8:3,' - ���⭮��� ������, ��/�^3: ');
  Writeln(FRez,S:7:4,' - ���頤� ������, �^2');
  Writeln(FRez,V0:7:4,' - o��㦭�� ᪮���� ������, �/�');
  Writeln(FRez,Tetta:5:3,' - �����室����� ��');
  Writeln(FREz,'------------------------------------------------------------');
  Writeln(FRez,'|����,�ࠤ.    |�⭮�⥫쭠� |����,H	                    |');
  Writeln(FRez,'|	       |᪮����,�/�  |�����       |������쭠�    |');
  Writeln(FRez,'-------------------------------------------------------------');
  For i:=1 to N do
  Writeln(FRez,'| ',V_B^.GetX(i):8:2,'     | ',V_B^.GetY(i):8:4,'     | ',
		 FT_B^.GetY(i):8:4,'     | ',FR_B^.getY(i):8:4,'     |');
  Writeln(FRez,'------------------------------------------------------------');
  Close(FRez);
  Writeln('���᫥��� ����祭�. ������ 䠩� ',FileRez);
  SoundTrac;
  Writeln('������ ���� �������...');
  ReadKey;
  {��ᮢ���� ��䨪��}
  cycl:=false;
  repeat
  Writeln('��ᬮ��:1-Ct;2-Cr;3-Ft;4-Fr;5-�������; Q-��室');
  case UpCase(ReadKey) of
    '1':begin B:=CT_B;title:='Ct';
	TitleFull:='�����樥�� ���饩 ᨫ�'end;
    '2':begin B:=CR_B;title:='Cr';
	TitleFull:='�����樥�� ࠤ���쭮� ᨫ�'end;
    '3':begin B:=FT_B;title:='Ft';
	TitleFull:='T���� ᨫ�'end;
    '4':begin B:=FR_B;title:='Fr';
	TitleFull:='������쭠� ᨫ�'end;
    '5':begin B:=V_B;title:='V';
	TitleFull:='�⭮�⥫쭠� ᪮����'end;
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
  DoneGraph;  {���㧪� ��䨪�}
  {�������� �� ����� �������᪨� ��ꥪ⮢}
  Dispose(G,Done);
  Dispose(V_B,Done);
  Dispose(CT_B,Done);
  Dispose(CR_B,Done);
  Dispose(FT_B,Done);
  Dispose(FR_B,Done);
end.
    S  S      �A *.FRM��  A  *.FRM� �" �    h  *.mac   >     M � �"] � d*.MACk � o 0�   s     �ffff&    A *.FRM �������������������� 