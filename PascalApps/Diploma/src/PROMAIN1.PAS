unit ProMain1;
interface
uses ProfMain,ProfDin,Objects,ProfComm,Profile,ProGraph;
var
  StateOfMain:word;
const
  stIsNotInitializ = $0001;
  stAfterCreate = $0002;
  stAfterCalculate = $0004;
  stAfterSave = $0008;
procedure SetState(aState:word);
procedure OnFlag(aState:word);
procedure OffFlag(aState:word);
function WhatIsState(aState:word):boolean;
type
  PMain1 = ^TMain1;
  TMain1 = object(TMain)
    State:word;
    constructor Init(aMainRec:TMainRec);
    constructor Load(var S:TStream);
    procedure Store(var S:TStream);
    procedure PutState(aState:word);
    function GetState:word;
    procedure Execute;virtual;
    destructor Done;virtual;
    function Get_W_S(NumProfil:integer):PBuffer;
    function Get_W_X(NumProfil:integer):PBuffer;
    function Get_P_S(NumProfil:integer):PBuffer;
    function Get_P_X(NumProfil:integer):PBuffer;
    function Get_T_S(NumProfil:integer):PBuffer;
    function Get_T_X(NumProfil:integer):PBuffer;
    function Get_Delta_S(NumProfil:integer):PBuffer;
    function Get_Delta_X(NumProfil:integer):PBuffer;
    function Get_MainNorm(NumProfil,NumNormal:integer):PBuffer;
    function Get_MainGor(NumProfil,NumGor:integer):PBuffer;
    function Get_CompNorm(NumProfil,NumNorm:integer):PBuffer;
    function Get_CompGor(NumProfil,NumGor:integer):PBuffer;
    function GetMoment_Corner:PFunction;
    function GetCp_Corner:PFunction;
    function GetMoment_Time:PFunction;
    function GetCp_Time:PFunction;
    function GetMiddleCp:real;
    function GetMiddleMoment:real;
    function GetCz_Corner:PFunction;
    function GetCx_Corner:PFunction;
    function GetCz_Time:PFunction;
    function GetCx_Time:PFunction;
    function GetMiddleCz:real;
    function GetMiddleCx:real;
    function GetCr_Corner:PFunction;
    function GetCq_Corner:PFunction;
    function GetCr_Time:PFunction;
    function GetCq_Time:PFunction;
    function GetContur:PBuffer;
    end;
const
   RMain1 : TStreamRec = (
      ObjType : idMain1;
      VmtLink: Ofs(TypeOf(TMain1)^);
      Load:@TMain1.Load;
      Store:@TMain1.Store);
procedure RegisterMain1;
implementation
procedure SetState(aState:word);
begin
  StateOfMain:=aState;
end;
function WhatIsState(aState:word):boolean;
begin
  WhatIsState:=((StateOfMain and aState) = aState);
end;
procedure OnFlag(aState:word);
begin
  StateOfMain:=StateOfMain or aState;
end;
procedure OffFlag(aState:word);
begin
  StateOfMain:=StateOfMain and not aState;
end;
procedure RegisterMain1;
begin
  RegisterMain;
  RegisterType(RMain1);
  RegisterType(RBufferCollection);
end;
constructor TMain1.Init(aMainRec:TMainRec);
begin
  inherited Init(aMainRec);
  PutState(stAfterCreate);
  SetState(stAfterCreate);
end;
constructor TMain1.Load(var S:TStream);
begin
  inherited Load(S);
  S.Read(State,SizeOf(State));
  SetState(State);
  OnFlag(stAfterSave);
end;
procedure TMain1.Store(var S:TStream);
begin
  OnFlag(stAfterSave);
  inherited Store(S);
  S.Write(State,SizeOf(State));
end;
procedure TMain1.PutState(aState:word);
begin
  State:=aState;
end;
function TMain1.GetState:word;
begin
  GetState:=State;
end;
procedure TMain1.Execute;
begin
  PutState(stAfterCalculate);
  SetState(stAfterCalculate);
  OffFlag(stAfterSave);
  inherited Execute;
end;
destructor TMain1.Done;
begin
  PutState(stIsNotInitializ);
  SetState(stIsNotInitializ);
  inherited Done;
end;

function TMain1.Get_W_S(NumProfil:integer):PBuffer;
var Buf:PBuffer;
begin
   if WhatIsState(stAfterCalculate) then
      Get_W_S:=GetProfile(NumProfil)^.GetW
   else
      Get_W_S:=nil;
end;
function TMain1.Get_W_X(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
begin
   if WhatIsState(stAfterCalculate) then begin
     Buf:=GetProfile(NumProfil)^.GetW;
     for i:=Buf^.BeginH to Buf^.EndH do
     Buf^.PutX(i,Map^.Get_X_S(Buf^.GetX(i)));
     Get_W_X:=Buf;end
   else
      Get_W_X:=nil;
end;
function TMain1.Get_P_S(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    P:PProfile;
begin
   if WhatIsState(stAfterCalculate) then begin
   P:=GetProfile(NumProfil);
     Buf:=New(PBuffer,Init(P^.N+2));
     for i:=Buf^.BeginH+1 to Buf^.EndH-1 do begin
       Buf^.PutX(i,P^.GetCA(i-1)^.S);
       Buf^.PutY(i,P^.GetCA(i-1)^.Pressure);
       end;
       Buf^.PutX(1,0);
       Buf^.PutX(Buf^.EndH,Map^.GetMaxS);
       Buf^.PutY(1,(Buf^.GetY(2)+Buf^.GetY(Buf^.EndH-1))/2);
       Buf^.PutY(Buf^.EndH,Buf^.GetY(1));
       Get_P_S:=Buf;end
   else
      Get_P_S:=nil;
end;
function TMain1.Get_P_X(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
begin
   if WhatIsState(stAfterCalculate) then begin
     Buf:=Get_P_S(NumProfil);
     for i:=Buf^.BeginH to Buf^.EndH do begin
        Buf^.PutX(i,Map^.Get_X_S(Buf^.GetX(i)));
        end;
     Get_P_X:=Buf;end
   else
      Get_P_X:=nil;
end;
function TMain1.Get_T_S(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    P:PProfile;
begin
   if WhatIsState(stAfterCalculate) then begin
     P:=GetProfile(NumProfil);
     Buf:=New(PBuffer,Init(P^.Main^.EndH+1));
     for i:=Buf^.BeginH to Buf^.EndH do begin
        Buf^.PutY(i,P^.Main^.Get_Tay(i-1));
        Buf^.PutX(i,P^.Main^.Get_S(i-1));
        end;
     Get_T_S:=Buf;end
   else
      Get_T_S:=nil;
end;
function TMain1.Get_T_X(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
begin
   if WhatIsState(stAfterCalculate) then begin
     Buf:=Get_T_S(Numprofil);
     for i:=Buf^.BeginH to Buf^.EndH do
       Buf^.PutX(i,Map^.Get_X_S(Buf^.GetX(i)));
     Get_T_X:=Buf;end
   else
      Get_T_X:=nil;
end;
function TMain1.Get_Delta_S(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    P:PProfile;
begin
   if WhatIsState(stAfterCalculate) then begin
     P:=GetProfile(NumProfil);
     Buf:=New(PBuffer,Init(P^.Main^.EndH+1));
     for i:=Buf^.BeginH to Buf^.EndH do begin
       Buf^.PutY(i,P^.Main^.Get(P^.Main^.EndV,i-1));
       Buf^.PutX(i,P^.Main^.Get_S(i-1));
       end;
     Get_Delta_S:=Buf;end
   else
      Get_Delta_S:=nil;
end;
function TMain1.Get_Delta_X(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
begin
   if WhatIsState(stAfterCalculate) then begin
     Buf:=Get_Delta_S(NumProfil);
     for i:=Buf^.BeginH to Buf^.EndH do
       Buf^.PutX(i,Map^.Get_X_S(Buf^.GetX(i)));
     Get_Delta_X:=Buf;end
   else
      Get_Delta_X:=nil;
end;
function TMain1.Get_MainNorm(NumProfil,NumNormal:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    dx:real;
    P:PProfile;
begin
   if WhatIsState(stAfterCalculate) then begin
     P:=GetProfile(NumProfil);
     Buf:=New(PBuffer,Init(P^.Main^.EndV));
     dx:=1/(P^.Main^.EndV-1);
     for i:=Buf^.BeginH to Buf^.EndH do begin
       Buf^.PutX(i,dx*(i-1));
       Buf^.PutY(i,P^.Main^.Get(i-1,NumNormal));
       end;
     Get_MainNorm:=Buf;end
   else
      Get_MainNorm:=nil;
end;
function TMain1.Get_MainGor(NumProfil,NumGor:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    dx:real;
    P:PProfile;
begin
   if WhatIsState(stAfterCalculate) then begin
     P:=GetProfile(NumProfil);
     Buf:=New(PBuffer,Init(P^.Main^.EndH+1));
     dx:=1/P^.Main^.EndH;
     for i:=Buf^.BeginH to Buf^.EndH do begin
       Buf^.PutX(i,dx*(i-1));
       Buf^.PutY(i,P^.Main^.Get(NumGor,i-1));
       end;
     Get_MainGor:=Buf;end
   else
      Get_MainGor:=nil;
end;
function TMain1.Get_CompNorm(NumProfil,NumNorm:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    dx:real;
    P:PProfile;
begin
   if WhatIsState(stAfterCalculate) then begin
     P:=GetProfile(NumProfil);
     Buf:=New(PBuffer,Init(P^.Main^.EndV));
     dx:=1/(P^.Main^.EndV-1);
     for i:=Buf^.BeginH to Buf^.EndH do begin
       Buf^.PutX(i,dx*(i-1));
       Buf^.PutY(i,P^.Comp^.Get(i-1,NumNorm));
       end;
     Get_CompNorm:=Buf;end
   else
      Get_CompNorm:=nil;
end;
function TMain1.Get_CompGor(NumProfil,NumGor:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    dx:real;
    P:PProfile;
begin
   if WhatIsState(stAfterCalculate) then begin
     P:=GetProfile(NumProfil);
     Buf:=New(PBuffer,Init(P^.Main^.EndH+1));
     dx:=1/P^.Main^.EndH;
     for i:=Buf^.BeginH to Buf^.EndH do begin
       Buf^.PutX(i,dx*(i-1));
       Buf^.PutY(i,P^.Comp^.Get(NumGor,i-1));
       end;
     Get_CompGor:=Buf;end
   else
      Get_CompGor:=nil;
end;
function TMain1.GetMoment_Corner:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetMoment_Corner:=CharCollect^.GetMoment_Corner
   else
      GetMoment_Corner:=nil;
end;
function TMain1.GetMoment_Time:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetMoment_Time:=CharCollect^.GetMoment_Time
   else
      GetMoment_Time:=nil;
end;
function TMain1.GetCp_Corner:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetCp_Corner:=CharCollect^.GetCp_Corner
   else
      GetCp_Corner:=nil;
end;
function TMain1.GetCp_Time:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetCp_Time:=CharCollect^.GetCp_Time
   else
      GetCp_Time:=nil;
end;
function TMain1.GetMiddleCp:real;
begin
  if WhatIsState(stAfterCalculate) then
     GetMiddleCp:=CharCollect^.GetMiddleCp
   else
      GetMiddleCp:=0.0;
end;
function TMain1.GetMiddleMoment:real;
begin
  if WhatIsState(stAfterCalculate) then
    GetMiddleMoment:=CharCollect^.GetMiddleMoment
   else
      GetMiddleMoment:=0.0;
end;
function TMain1.GetCz_Corner:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetCz_Corner:=CharCollect^.GetCz_Corner
   else
      GetCz_Corner:=nil;
end;
function TMain1.GetCz_Time:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetCz_Time:=CharCollect^.GetCz_Time
   else
      GetCz_Time:=nil;
end;
function TMain1.GetCx_Corner:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetCx_Corner:=CharCollect^.GetCx_Corner
   else
      GetCx_Corner:=nil;
end;
function TMain1.GetCx_Time:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetCx_Time:=CharCollect^.GetCx_Time
   else
      GetCx_Time:=nil;
end;
function TMain1.GetMiddleCz:real;
begin
  if WhatIsState(stAfterCalculate) then
    GetMiddleCz:=CharCollect^.GetMiddleCz
   else
      GetMiddleCz:=0.0;
end;
function TMain1.GetMiddleCx:real;
begin
  if WhatIsState(stAfterCalculate) then
     GetMiddleCx:=CharCollect^.GetMiddleCx
   else
      GetMiddleCx:=0.0;
end;
function TMain1.GetCr_Corner:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetCr_Corner:=CharCollect^.GetCr_Corner
   else
      GetCr_Corner:=nil;
end;
function TMain1.GetCr_Time:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
    GetCr_Time:=CharCollect^.GetCr_Time
   else
      GetCr_Time:=nil;
end;
function TMain1.GetCq_Corner:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
     GetCq_Corner:=CharCollect^.GetCq_Corner
   else
      GetCq_Corner:=nil;
end;
function TMain1.GetCq_Time:PFunction;
begin
  if WhatIsState(stAfterCalculate) then
     GetCq_Time:=CharCollect^.GetCq_Time
   else
      GetCq_Time:=nil;
end;
function TMain1.GetContur:PBuffer;
var i,N:integer;
    Buf:PBuffer;
begin
  N:=Map^.EndH;
  Buf:=New(PBuffer,Init(N));
  for i:=1 to N do begin
    Buf^.PutX(i,Map^.GetX(i));
    Buf^.PutY(i,Map^.GetY(i));
    end;
  GetContur:=Buf;
end;
begin
end.