program Coder;
uses Crt,Dos,Alpha;
type
 TSetOfChar = set of char;
const
  co_Copy = $0001;
  cp_Move = $0002;
  CoderExtName = '.cod';
  DeCoderExtName = '.dcd';
var
  P:string;
  FName:string;
  Fil:File;
  DD:Char;
  TC:TTypeCoder;
  D:DirStr;N:NameStr;E:ExtStr;
function ReadBlock(var Fil:file;var Size:word;var NR:word):string;
var C:Char;
    i:integer;
    S:String;
begin
  S:='';
  For i:=1 to Size do begin
   BlockRead(Fil,C,1,NR);
   S:=S+C;
   end;
  ReadBlock:=S;
end;
procedure WriteBlock(S:String;var Fil:File;var Size:word;var WR:word);
var
    i:integer;
begin
  For i:=1 to Size do
    BlockWrite(Fil,S[i],1,WR);
end;
procedure Password(Pass:String;var TypeCoder:TTypeCoder);
begin
  TypeCoder.LenghtWord:=3;
  TypeCoder.AlphabeticPar:=1;
  TypeCoder.MovingPar:=1;
  TypeCoder.AllCycl:=1;
end;
procedure DoCoder(var F:File;TypeCoder:TTypeCoder;Options:word);
var FilOut:file;
    PW:string;
    i,Num,NumWrite:word;
 procedure Doing(var P:string;TP:TTypeCoder);
 begin
  Codeing(P,TP);
 end;
begin
   Assign(FilOut,N+CoderExtName);
   ReWrite(FilOut,1);
   ReSet(F,1);
   while not(Num = 0) or not(NumWrite <> Num) do begin
     PW:=ReadBlock(F,TypeCoder.LenghtWord,Num);
{     for i:=1 to TypeCoder.AllCycl do Doing(PW,TypeCoder);}
     WriteBlock(PW,FilOut,TypeCoder.LenghtWord,NumWrite);
   end;
   Close(F);
   Close(FilOut);
end;
procedure DoDeCoder(var F:File;TypeCoder:TTypeCoder;Options:word);
var FilOut:file;
    PW:string;
    i,Num,NumWrite:word;
 procedure Doing(var P:string;TP:TTypeCoder);
 begin
  DeCodeing(P,TP);
 end;
begin
   Assign(FilOut,N+DeCoderExtName);
   ReWrite(FilOut,1);
   ReSet(F,1);
   repeat
     PW:=ReadBlock(F,TypeCoder.LenghtWord,Num);
     for i:=1 to TypeCoder.AllCycl do Doing(PW,TypeCoder);
     WriteBlock(PW,FilOut,Num,NumWrite);
   until (Num = 0) and (NumWrite <> Num);
   Close(F);
   Close(FilOut);
end;
begin
 Write('Password? ');Readln(P);
 Write('File?     ');Readln(FName);
 Write('Coder or DeCoder (C/D?)');Readln(DD);
 FSplit(FName,D,N,E);
 Assign(Fil,FName);
 Password(P,TC);
 case UpCase(DD) of
  'C': DoCoder(Fil,TC,co_Copy);
  'D': DoDeCoder(Fil,TC,co_Copy);
   end;
 Writeln('Ok process');
 ReadKey;
end.