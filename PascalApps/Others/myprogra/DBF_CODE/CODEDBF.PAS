unit CodeDBF;
interface
{����⠭���� � dbf - 䠩�� ����� ᨬ����� ASCII ᨬ���� MS Windows}
function Dos_Win(DosChar:Char):Char;
{����⠭���� � dbf - 䠩�� ����� ᨬ����� MS Windows ᨬ���� ASCII}
function Win_Dos(WinChar:Char):Char;

implementation
type
   TTypeChar = (DosCh,WinCh);
   TTableChar = array[0..255,DosCh..WinCh] of Char;
var
   TableChar:TTableChar;
{����⠭���� � dbf - 䠩�� ����� ᨬ����� ASCII ᨬ���� MS Windows}
function Dos_Win(DosChar:Char):Char;
var i:integer;
begin
  for i:=0 to 255 do begin
    if TableChar[i,DosCh] = DosChar then begin
       Dos_Win:=TableChar[i,WinCh];
       Exit;
       end
    end;
  Dos_Win:='~';
end;
{����⠭���� � dbf - 䠩�� ����� ᨬ����� MS Windows ᨬ���� ASCII}
function Win_Dos(WinChar:Char):Char;
var i:integer;
begin
  for i:=0 to 255 do begin
    if TableChar[i,WinCh] = WinChar then begin
       Win_Dos:=TableChar[i,DosCh];
       Exit;
       end
    end;
  Win_Dos:='~';
end;
procedure InitTable;
var i:integer;
    f:text;
    DCh,WCh:Char;
begin
  for i:=0 to 255 do begin
   TableChar[i,DosCh]:=#0;
   TableChar[i,WinCh]:=#0;
   end;
  Assign(f,'doswinch.txt');
  ReSet(f);
  while not(EOF(f)) do begin
   Read(f,DCh);ReadLn(f,WCh);
   TableChar[Ord(DCh),DosCh]:=DCh;
   TableChar[Ord(DCh),WinCh]:=WCh;
   end;
  Close(f);
  TableChar[Ord(' '),DosCh]:=' ';
  TableChar[Ord(' '),WinCh]:=' ';
end;

begin
InitTable;
end.