unit ProMain1;
interface
uses ProfMain,ProfDin,Objects,ProfComm,Profile;
type
  PMain1 = ^TMain1;
  TMain1 = object(TMain)
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
    function GetMiddleCp:real;
    function GetMiddleMoment:real;
    function GetCz_Corner:PFunction;
    function GetCx_Corner:PFunction;
    function GetMiddleCz:real;
    function GetMiddleCx:real;
    function GetCr_Corner:PFunction;
    function GetCq_Corner:PFunction;
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
procedure RegisterMain1;
begin
  RegisterMain;
  RegisterType(RMain1);
end;
function TMain1.Get_W_S(NumProfil:integer):PBuffer;
var Buf:PBuffer;
begin
   Get_W_S:=GetProfile(NumProfil)^.GetW;
end;
function TMain1.Get_W_X(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
begin
   Buf:=GetProfile(NumProfil)^.GetW;
   for i:=Buf^.BeginH to Buf^.EndH do
   Buf^.PutX(i,Map^.Get_X_S(Buf^.GetX(i)));
   Get_W_X:=Buf;
end;
function TMain1.Get_P_S(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
begin
   Buf:=GetProfile(NumProfil)^.GetW;
   for i:=Buf^.BeginH to Buf^.EndH do
     Buf^.PutY(i,(1-Sqr(Buf^.GetY(i))));
   Get_P_S:=Buf;
end;
function TMain1.Get_P_X(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
begin
   Buf:=GetProfile(NumProfil)^.GetW;
   for i:=Buf^.BeginH to Buf^.EndH do begin
     Buf^.PutY(i,(1-Sqr(Buf^.GetY(i))));
     Buf^.PutX(i,Map^.Get_X_S(Buf^.GetX(i)));
     end;
   Get_P_X:=Buf;
end;
function TMain1.Get_T_S(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    P:PProfile;
begin
   P:=GetProfile(NumProfil);
   Buf:=New(PBuffer,Init(P^.Main^.EndH+1));
   for i:=Buf^.BeginH to Buf^.EndH do begin
     Buf^.PutY(i,P^.Main^.Get_Tay(i-1));
     Buf^.PutX(i,P^.Main^.Get_S(i-1));
     end;
   Get_T_S:=Buf;
end;
function TMain1.Get_T_X(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
begin
   Buf:=Get_T_S(Numprofil);
   for i:=Buf^.BeginH to Buf^.EndH do
     Buf^.PutX(i,Map^.Get_X_S(Buf^.GetX(i)));
   Get_T_X:=Buf;
end;
function TMain1.Get_Delta_S(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    P:PProfile;
begin
   P:=GetProfile(NumProfil);
   Buf:=New(PBuffer,Init(P^.Main^.EndH+1));
   for i:=Buf^.BeginH to Buf^.EndH do begin
     Buf^.PutY(i,P^.Main^.Get(P^.Main^.EndV,i-1));
     Buf^.PutX(i,P^.Main^.Get_S(i-1));
     end;
   Get_Delta_S:=Buf;
end;
function TMain1.Get_Delta_X(NumProfil:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
begin
   Buf:=Get_Delta_S(NumProfil);
   for i:=Buf^.BeginH to Buf^.EndH do
     Buf^.PutX(i,Map^.Get_X_S(Buf^.GetX(i)));
   Get_Delta_X:=Buf;
end;
function TMain1.Get_MainNorm(NumProfil,NumNormal:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    dx:real;
    P:PProfile;
begin
   P:=GetProfile(NumProfil);
   Buf:=New(PBuffer,Init(P^.Main^.EndV));
   dx:=1/P^.Main^.EndV-1;
   for i:=Buf^.BeginH to Buf^.EndH do begin
     Buf^.PutX(i,dx*(i-1));
     Buf^.PutY(i,P^.Main^.Get(i-1,NumNormal));
     end;
   Get_MainNorm:=Buf;
end;
function TMain1.Get_MainGor(NumProfil,NumGor:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    dx:real;
    P:PProfile;
begin
   P:=GetProfile(NumProfil);
   Buf:=New(PBuffer,Init(P^.Main^.EndH+1));
   dx:=1/P^.Main^.EndH;
   for i:=Buf^.BeginH to Buf^.EndH do begin
     Buf^.PutX(i,dx*(i-1));
     Buf^.PutY(i,P^.Main^.Get(NumGor,i-1));
     end;
   Get_MainGor:=Buf;
end;
function TMain1.Get_CompNorm(NumProfil,NumNorm:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    dx:real;
    P:PProfile;
begin
   P:=GetProfile(NumProfil);
   Buf:=New(PBuffer,Init(P^.Main^.EndV));
   dx:=1/P^.Main^.EndV-1;
   for i:=Buf^.BeginH to Buf^.EndH do begin
     Buf^.PutX(i,dx*(i-1));
     Buf^.PutY(i,P^.Comp^.Get(i-1,NumNorm));
     end;
   Get_CompNorm:=Buf;
end;
function TMain1.Get_CompGor(NumProfil,NumGor:integer):PBuffer;
var Buf:PBuffer;
    i:integer;
    dx:real;
    P:PProfile;
begin
   P:=GetProfile(NumProfil);
   Buf:=New(PBuffer,Init(P^.Main^.EndH+1));
   dx:=1/P^.Main^.EndH;
   for i:=Buf^.BeginH to Buf^.EndH do begin
     Buf^.PutX(i,dx*(i-1));
     Buf^.PutY(i,P^.Comp^.Get(NumGor,i-1));
     end;
   Get_CompGor:=Buf;
end;
function TMain1.GetMoment_Corner:PFunction;
begin
  GetMoment_Corner:=CharCollect^.GetMoment_Corner;
end;
function TMain1.GetCp_Corner:PFunction;
begin
  GetCp_Corner:=CharCollect^.GetCp_Corner;
end;
function TMain1.GetMiddleCp:real;
begin
  GetMiddleCp:=CharCollect^.GetMiddleCp;
end;
function TMain1.GetMiddleMoment:real;
begin
  GetMiddleMoment:=CharCollect^.GetMiddleMoment;
end;
function TMain1.GetCz_Corner:PFunction;
begin
  GetCz_Corner:=CharCollect^.GetCz_Corner;
end;
function TMain1.GetCx_Corner:PFunction;
begin
  GetCx_Corner:=CharCollect^.GetCx_Corner;
end;
function TMain1.GetMiddleCz:real;
begin
  GetMiddleCz:=CharCollect^.GetMiddleCz;
end;
function TMain1.GetMiddleCx:real;
begin
  GetMiddleCx:=CharCollect^.GetMiddleCx;
end;
function TMain1.GetCr_Corner:PFunction;
begin
  GetCr_Corner:=CharCollect^.GetCr_Corner;
end;
function TMain1.GetCq_Corner:PFunction;
begin
  GetCq_Corner:=CharCollect^.GetCq_Corner;
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