program Evolution;
uses Graph, Crt;
Const N=100;
      T=10;
      X0=130;
      Y0=50;
      Size=400;
      SizeCletka=4;
      poLive=0;
      poDeath=1;
      poStabile=2;
type
  TBacterium=record
     Last:boolean;
     New:boolean;
     Death:boolean;
     end;
  TPole=array [1..N,1..N] of TBacterium;
var
  Bacterium:TBacterium;
  Pole:TPole;
  grDriver: Integer;
  grMode: Integer;
  ErrCode: Integer;
  Population:array [1..T] of integer;
  Result:integer;

function ShowCountBacterium(var P:TPole):integer;
var D,i,j:integer;
    s:string[5];
begin
  OutTextXY(200,20,'Живые бактерии: ');
  SetFillStyle(1,0);
  Bar(330,10,360,30);
  D:=0;
  for i:=1 to N do
   for j:=1 to N do
    if P[i,j].Last = true then d:=d+1;
  Str(D,S);
  OutTextXY(330,20,S);
  ShowCountBacterium:=D;
end;

procedure DrawBacterium(var P:TPole);
var i,j:integer;
begin
   SetFillStyle(1,14);
   for i:=1 to N do
    for j:=1 to N do
     begin
      if P[i,j].Last then
       Bar(X0+SizeCletka*(i-1)+1,Y0+SizeCletka*(j-1)+1,
           X0+SizeCletka*i-1,Y0+SizeCletka*j-1);
     end;
   SetFillStyle(1,0);
   for i:=1 to N do
    for j:=1 to N do
     begin
      if not(P[i,j].Last) then
       Bar(X0+SizeCletka*(i-1)+1,Y0+SizeCletka*(j-1)+1,
           X0+SizeCletka*i-1,Y0+SizeCletka*j-1);
     end;
end;

procedure InitBacterium(var P:TPole);
var i,j:integer;
    F:text;
    X,Y:integer;
    Key:Char;
    NoKey:integer;
begin
   {Очищение массива}
   for i:=1 to N do
   begin
     for j:=1 to N do
     begin
      P[i,j].Last:=false;
      P[i,j].New:=false;
      P[i,j].Death:=false;
     end;
   end;
   for i:=1 to T do Population[i]:=0;
   {Прорисовка сетки}
   SetColor(7);
   for i:=0 to N do
     begin
     Line(X0,Y0+SizeCletka*i,X0+Size,Y0+SizeCletka*i);
     end;
   for i:=0 to N do
     begin
     Line(X0+SizeCletka*i,Y0,X0+SizeCletka*i,Y0+Size);
     end;
   SetColor(Cyan);
   OutTextXY(135,453,'Исп. клавиши со стрелками для перемещения курсора.');
   i:=N div 2;
   j:=N div 2;
   repeat
    SetFillStyle(1,12);
    Bar(X0+SizeCletka*(i-1)+1,Y0+SizeCletka*(j-1)+1,
       X0+SizeCletka*i-1,Y0+SizeCletka*j-1);
    Key:=ReadKey;
    NoKey:=Ord(Key);
    if (NoKey <> 27) and (NoKey <> 105) and (NoKey <> 100) then NoKey:=Ord(ReadKey);
    if (NoKey <> 105) and (NoKey <> 100) then
      begin
       DrawBacterium(P);
       ShowCountBacterium(P);
       end;
    case NoKey of
     72 : j:=j-1;
     80 : j:=j+1;
     75 : i:=i-1;
     77 : i:=i+1;
     105: P[i,j].Last:=true;
     100: P[i,j].Last:=false;
     end;
   until NoKey = 27;
end;
procedure RedrawPole(var P:TPole);
var i,j:integer;
begin
   SetColor(7);
   for i:=0 to N do
     begin
     Line(X0,Y0+SizeCletka*i,X0+Size,Y0+SizeCletka*i);
     end;
   for i:=0 to N do
     begin
     Line(X0+SizeCletka*i,Y0,X0+SizeCletka*i,Y0+Size);
     end;
   DrawBacterium(P);
end;
procedure BernBacterium(var P:TPole);
var i,j:integer;
    Bacteria:integer;
begin
   for i:=2 to N-1 do
    for j:=2 to N-1 do
     begin
      if not(P[i,j].Last) then
       begin
        Bacteria:=0;
        if P[i-1,j-1].Last then Inc(Bacteria);
        if P[i-1,j].Last then Inc(Bacteria);
        if P[i-1,j+1].Last then Inc(Bacteria);
        if P[i,j-1].Last then Inc(Bacteria);
        if P[i,j+1].Last then Inc(Bacteria);
        if P[i+1,j-1].Last then Inc(Bacteria);
        if P[i+1,j].Last then Inc(Bacteria);
        if P[i+1,j+1].Last then Inc(Bacteria);
        If Bacteria = 3 then P[i,j].New:=true;
       end;
     end;
end;
procedure DeathBacterium(var P:TPole);
var i,j:integer;
    Bacteria:integer;
begin
   for i:=2 to N-1 do
    for j:=2 to N-1 do
     begin
      if P[i,j].Last then
       begin
        Bacteria:=0;
        if P[i-1,j-1].Last then Inc(Bacteria);
        if P[i-1,j].Last then Inc(Bacteria);
        if P[i-1,j+1].Last then Inc(Bacteria);
        if P[i,j-1].Last then Inc(Bacteria);
        if P[i,j+1].Last then Inc(Bacteria);
        if P[i+1,j-1].Last then Inc(Bacteria);
        if P[i+1,j].Last then Inc(Bacteria);
        if P[i+1,j+1].Last then Inc(Bacteria);
        If not((Bacteria = 3) or (Bacteria = 2)) then
           P[i,j].Death:=true;
       end;
     end;
end;
procedure NewInLast(var P:TPole);
var i,j:integer;
begin
   for i:=1 to N do
    for j:=1 to N do
     if P[i,j].New then
       begin
        P[i,j].Last:=true;
        P[i,j].New:=false;
       end;
   for i:=1 to N do
    for j:=1 to N do
     if P[i,j].Death then
       begin
        P[i,j].Last:=false;
        P[i,j].Death:=false;
       end;
end;
function WhatPopulation(M:integer):integer;
var Z,i:integer;
begin
   for i:=T downto 2 do Population[i]:=Population[i-1];
   Population[1]:=M;
   if Population[1] = 0 then
    begin
     Whatpopulation:=poDeath;
     Exit;
    end;
   Z:=Population[1];
   for i:=2 to T do
    if Z <> Population[i] then
     begin
      WhatPopulation:=poLive;
      Exit;
     end;
    WhatPopulation:=poStabile;
end;
function IfLiveBacterium(var P:TPole):boolean;
var i,j:integer;
begin
   for i:=1 to N do
    for j:=1 to N do
     if P[i,j].Last then
      begin
      IfLiveBacterium:=false;
      Exit;
      end;
   IfLiveBacterium:=true;
end;
begin
 grDriver := Detect;
 InitGraph(grDriver, grMode,' ');
 ErrCode := GraphResult;
 if ErrCode <> grOk then
 begin
    Halt;
 end;
   InitBacterium(Pole);
   repeat
   RedrawPole(Pole);
   BernBacterium(Pole);
   DeathBacterium(Pole);
   NewInLast(Pole);
   Delay(100);
   Result:=WhatPopulation(ShowCountBacterium(Pole));
   until (Result = poStabile) or (Result = poDeath) or KeyPressed;
   CloseGraph;
   case Result of
    poStabile: writeln ('Популяция устойчива. Конец работы.');
    poDeath: writeln ('Популяция вымерла. Конец работы.');
    Else writeln ('Прервано пользователем. Конец работы.');
    end;
   Writeln('Нажмите <Enter> для окончания работы программы.');
   Readln;
end.