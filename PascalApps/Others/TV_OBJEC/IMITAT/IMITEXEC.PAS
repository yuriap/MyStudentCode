Unit ImitExec;
Interface
Type
    TPumpData = record
      Q : String[10];
      n : String[10];
      H : String[10];
      Ns : String[10];
      end;

    PPump = ^TPump;
    TPump = object
      H : real;
      Q : real;
      n : real;
      Ns : real;
      constructor Init(PumpData:TPumpData);
      procedure GetNs(var PumpData:TPumpData);
      procedure WriteParam;
      end;
Implementation
Function Sign(x:real):real;{знак числа}

 Begin
    If x<>0.0
       then
       begin
       If x>0.0
          then
          sign:=1.0
          else
          begin
          sign:=-1.0;
          end;
       end
    else
    sign:=1.0;
 End;

Function Conc(x:real):string;
Var    a:string[3];
       b:string[6];
       c:string[1];
       v:real;
       i:byte;
Begin
   b:='';
   Str(Trunc(abs(x)),a);
   v:=abs(Frac(x));
   for i:=1 to 7 do begin
     v:=v*10;
     str(trunc(v),c);
     b:=Concat(b,c);
     v:=Frac(v);
     end;
   if sign(x)= -1.0 then c:='-' else c:='';
   Conc:=Concat(c,a,'.',b);
End;

constructor TPump.Init(PumpData:TPumpData);
Var code : integer;
begin
  Val(PumpData.H,H,code);
  Val(PumpData.Q,Q,code);
  Val(PumpData.n,n,code);
end;
procedure TPump.GetNs(var PumpData:TPumpData);
begin
  Ns:=3.65*n*Sqrt(Q)/(exp(0.75*ln(H)));
  PumpData.Ns:=conc(Ns);
end;
procedure TPump.WriteParam;
begin
  Write('Напор____________',H);
  Write('Подача___________',Q);
  Write('Обороты__________',n);
  Write('Быстроходность___',Ns);
end;
Begin
End.