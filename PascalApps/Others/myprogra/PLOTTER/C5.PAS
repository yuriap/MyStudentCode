uses dos,crt;
 label v;
 var Reg:registers;
    c:char;
    i:integer;
 Begin
  Clrscr;
 Reg.dx:=$01;
   Reg.ah:=$04;
    intr($14,Reg);
     if(Reg.ax<>6484)or(Reg.bh<>5)then
      begin
       writeln('�஢���� ���⠫��� �ࠩ��� FOSSIL !',#7);
        writeln('Reg.ax:=',Reg.ax);
        writeln('Reg.bh:=',Reg.bh);
        writeln('Reg.bl:=',Reg.bl);
       c:=readkey;
       HALT;
      end
    else writeln('���⠫��� ��諠 �ᯥ譮 !',#7);

 Reg.dx:=$01;
   Reg.ah:=$0;
    Reg.al:=$0A7;
  intr($14,Reg);
{ Reg.dx:=$01;
   Reg.ah:=$09;
	intr($14,Reg);}
  writeln('����� �㤥� ��।��');
   readln;
   i:=1;
   repeat
     Reg.dx:=$01;
      Reg.ah:=$01;
      {��।�� 楯�窨 ᨬ�����}
       Reg.al:=$00;
	  intr($14,Reg);
{	Reg.ah:=$08;
	   intr($14,Reg);}
       Inc(i);
   until i >=100;
	  writeln('Reg.dx:=',Reg.dx);
	  writeln('Reg.ah:=',Reg.ah);
	  writeln('Reg.al:=',Reg.al);
	  readln;
	   End.

