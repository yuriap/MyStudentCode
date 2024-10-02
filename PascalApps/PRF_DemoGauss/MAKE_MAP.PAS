program Make_Map;
uses Objects,ProfComm,ProfDin,Profile,Dos,strmerr;
var
 P: PathStr;
 D: DirStr;
 N: NameStr;
 E: ExtStr;
  i:integer;
  Len:integer;
  Lit:string[2];
  lit1:string[4];
  x,y,S:real;
  M:PMapProf;
  SS:PMsgStream;
  R:TResourceFile;
  f:text;
begin
RegisterDinamic;
  If ParamStr(1) <> '' then P:=ParamStr(1) else
    begin
      Writeln('Укажите имя файла как параметр');
      Exit;
    end;
  Assign(f,P);
  {$I-}
  Reset(f);
  Len:=0;
  while not(EoF(F)) do begin
  Readln(f,Lit,x,y,lit1);
  If IOResult <> 0 Then begin Beep; Halt(0);end;
  Inc(Len);
  end;
  Reset(f);
  If IOResult <> 0 Then begin Beep; Halt(0);end;
  M:=New(PMapProf,Init(Len));
  S:=0;
  For i:=1 to Len do begin
    Readln(f,Lit,x,y,lit1);
  If IOResult <> 0 Then begin Beep; Halt(0);end;
    M^.PutX(i,x);
    M^.PutY(i,y);
    If i <> 1 then S:=S+Sqrt(Sqr(M^.GetX(i)-M^.GetX(i-1))+
                               Sqr(M^.GetY(i)-M^.GetY(i-1)))
              Else S:=0.0;
    M^.PutS(i,S);
    M^.Options^.Put(i,moNoOption);
    if Lit = 'cp' then M^.PutFlag(i,moCPoint);
    if Lit = 'ca' then M^.PutFlag(i,moCAdd);
    if Lit1 = ' bb' then begin M^.PutFlag(i,moBackBound);beep;end;
    end;
  {$I+}
  MakeCos(M);
  Close(f);
 FSplit(P, D, N, E);
 SS:=New(PMsgStream,Init(N+'.map',stCreate,2048));
 SS^.Put(M);
 Dispose(SS,Done);
 Dispose(M,Done);
 SoundTrac;
 WriteLn('Ok Created Map Of Profile')
end.
