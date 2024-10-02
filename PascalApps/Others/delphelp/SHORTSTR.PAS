program ShortStr;
const MaxLenght=75;
var S,SBuff:string;
    FIn,FOut:text;
    EndPar:boolean;
    NumStr:integer;
function ExtractString(Whom:string;var Dest:string;
                       Lenght:integer; var Number:integer):boolean;
var BufLenght:integer;
function CalcBufLenght(InStr:string;Long,Num:integer):integer;
var Result:integer;
begin
 Result:=0;
 while Instr[Num+Result+Long] <> ' ' do
  begin
   Dec(Result);
  end;
 CalcBufLenght:=Result;
end;
begin
 if byte(Whom[0]) < Number+1 then
  begin
   ExtractString:=true;
   Dest:='';
  end
  else
  begin
   ExtractString:=false;
   BufLenght:=CalcBufLenght(Whom,Lenght,Number);
   if Number+1+Lenght+BufLenght <= byte(Whom[0])
    then Dest:=Copy(Whom,Number+1,Lenght+BufLenght)
    else Dest:=Copy(Whom,Number+1,byte(Whom[0])-Number);
   Number:=Number+Lenght+BufLenght;
  end
end;
begin
 Assign(FIn,'dhtabler.txt');
 Reset(FIn);
 Assign(FOut,'dht.txt');
 Rewrite(FOut);
 repeat
  Readln(FIn,S);
  if Byte(S[0]) < MaxLenght then
    begin
    Writeln(FOut,S);
    end
   else
    begin
    NumStr:=0;
    while not(ExtractString(S,SBuff,MaxLenght,NumStr)) do
     begin
     Writeln(FOut,SBuff);
     end;
    end;
 until Eof(FIn);
 Close(FIn);
 Close(FOut);
end.