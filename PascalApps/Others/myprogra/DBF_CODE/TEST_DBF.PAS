program Test_DBF;
uses CodeDBF;
procedure Code_W_D(var S:string);
var i:integer;
begin
 for i:=1 to byte(S[0]) do S[i]:=Win_Dos(S[i]);
end;
procedure Code_D_W(var S:string);
var i:integer;
begin
 for i:=1 to byte(S[0]) do S[i]:=Dos_Win(S[i]);
end;
var CodeString:string;
begin
 Writeln('Input MS Dos String');
 Readln(CodeString);
 Code_D_W(CodeString);
 Writeln('This is a MS Windows String: ',CodeString);
 Code_W_D(CodeString);
 Writeln('This is MS DOS String: ',CodeString);
 Readln;
end.