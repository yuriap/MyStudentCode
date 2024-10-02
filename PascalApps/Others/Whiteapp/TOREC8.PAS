program Test;
 {$N+}
 uses

  Crt, Dos, MatMetod, UObject, UEvent, UView, UControl, UDialog, UMenu;

 function P(P1,P2,R1,R2,R: extended) :extended;
  begin
   P:=Sqrt(P1*P1-(P1*P1-P2*P2)*Ln(R/R1)/Ln(R2/R1))
  end;

 var
  Progress: single;
  E1,E2: real;
  R1,Rk1,Rk2,R3,R2,Ru: extended;
  N,Z,W,Al,Bt,Lk,Vk,Wo: extended;
  P1,P2,P3,Pmin,F: extended;
  T,R,Mu: extended;
  X: extended;
  A1,A2,A3,KK,Fz,Fr: extended;
  PX: array [0..60] of record P1,X,Xk: real end;
  PM: array [0..60] of record P1,M3: real end;
  PXs: array [0..60] of record P1,Xs: real end;
  PK: array [0..60] of record P1,P2,PK,PS: real end;
 const

  E = 1e-6;
  MM: longint = 0;

 function dW1(dR: extended) :extended; far;
  begin
   dW1:=P(P1,P2,R3,Rk2,dR)*dR
  end;

 function dW3(dR: extended) :extended; far;
  begin
   dW3:=P(P2,P3,Rk1,R1,dR)*dR
  end;

  function MM1(X: extended): extended; far;
   begin
    Rk2:=X;
    A1:=ln(R3/Rk2);
    A3:=ln(Rk1/R1);
    Pmin:=Sqrt((A3*P1*P1+A1*P3*P3)/(A1+A3));
    P2:=(P1+Pmin)/2;
   MM1:=(P2*P2-P3*P3)/A3;    
{    if A1 = 0 then MM1:=0 else
    MM1:=-3*(P1-P2)/(2*(1/A1+1/A3)*P2+1)*((Rk2*Rk2-Rk1*Rk1)+(R3*R3-Rk2*Rk2)*(Pi-1)+(Rk1*Rk1-R1*R1))}
   end;

  function K(X: extended): extended; far;
    var S1,S2,S3: extended;
   begin
    Rk1:=X;
    Rk2:=MiniGold(MM1,R1,R3);
    S1:=R3*R3-Rk2*Rk2;
    S2:=Rk2*Rk2-Rk1*Rk1;
    S3:=Rk1*Rk1-R1*R1;
    Fr:=(P1*(Pi-1)+Pmin)*S1+Pmin*Pi*S2+(Pmin*(Pi-1)+P3)*S3;
    Fz:=(P1*(Pi-1)+P2)  *S1+P2*  Pi*S2+(P2  *(Pi-1)+P3)*S3;
    K:=KK-Fr/Fz;
   end;


 function Solve_P2(dX: extended) :extended; far;
   var W1,W2,Wk,Wr: extended;
  begin
   P2:=dX;
   Pmin:=Sqrt((P1*P1*ln(Rk1/R1)+P3*P3*ln(R3/Rk2))/(ln(Rk1/R1)+ln(R3/Rk2)));
{  W1:=2*Pi*IntegralE(dW1,Rk2,R3,E);
   W2:=2*Pi*IntegralE(dW3,R1,Rk1,E); }
   W1:=(R3*R3-Rk2*Rk2)*((Pi-1)*P1+P2);
   W2:=(Rk1*Rk1-R1*R1)*((Pi-1)*P2+P3);
   Wk:=Pi*(Rk2*Rk2 - Rk1*Rk1)*P2;
   Wr:=Pi*((Ru*Ru-R1*R1)*P3+(R3*R3-Ru*Ru)*P1)+F;
   Solve_P2:=W1+W2+Wk-Wr;
   Process(3);
  end;

 procedure Data_Def;
  begin
   R1:=0.1755/2;
   R3:=0.1978/2;
   Rk1:=0.182/2;
   Rk2:=0.189/2;
   Ru:=0.1784/2;
   N :=24;
   Z :=3;
   W :=2*Pi*3000/60;
   Lk:=0.013;
   Vk:=Pi*0.003*0.003/4*0.006*N;
   Al:=ArcTan(Lk/(Rk2+Rk1));
   Bt:=2*Pi/Z;
   P1:=30E5;
   P3:=1e5;
   R:=278;
   T:=300;
   Mu:=1.79e-5;
   Wo:=3000;
   F:=70;
  end;

 procedure Run;
  var
   I: integer;
   dP: real;
   S1,S2,S3: real;
  begin
   W:=Wo*2*Pi/60;
   Al:=2*ArcTan(Lk/(Rk2+Rk1));
   Bt:=2*Pi/Z;
   dP:=(P1-P3)/(High(PX)+1);
   A1:=Pi/(12*Mu*R*T*ln(R3/Rk2))*(Bt-Al)/W;
   A2:=2*Vk/(R*T);
   A3:=Pi/(12*Mu*R*T*ln(Rk1/R1))*(Bt)/W;
   S1:=Pi*(Rk1*Rk1-R1*R1);
   S3:=Pi*(R3*R3-Rk2*Rk2);
   S2:=Pi*(Rk2*Rk2-Rk1*Rk1);
   for I:=0 to High(PX) do begin
    Progress:=I/High(PX);
    Data_Show(Progress);
    P1:=P3+(I+1)*dP;
    P2:=Dich(P1,P3,P3*1e-8,Solve_P2);
    X:=Pow(A2*(P1-P2)/(A3*(P2*P2-P3*P3)-A1*(P1*P1-P2*P2)),1/3);
    PX[I].Xk:=Pow(24*Mu*ln(Rk1/R1)*P3*R1*Sqrt(1.4*R*T)/(P1*P1-P3*P3),1/2);
    if PX[I].Xk > 1e-5 then PX[I].Xk:=1e-5;
    PX[I].X:=X;
    PX[I].P1:=P1;
    PM[I].P1:=P1;
    PM[I].M3:=X*X*X*(P2*P2-P3*P3)*Pi/(12*Mu*R*T*ln(Rk1/R1))*R*T/P3*60*1000;
    PXs[I].P1:=P1;
    PXs[I].Xs:=3*A2*(P1-P2)/(2*Pow(X,4)*P2*(A1+A3)+A2*X)*((S1+S3)/2+S2);
    PK[I].P1:=P1;
    PK[I].PK:=Pmin;
    PK[I].P2:=P2;
    PK[I].PS:=(P1+Pmin)/2;
   end;
   for I:=75 to 100 do begin
    KK:=I*0.01;
    Rk1:=Dich(R1,R3,R3/1000000,K);
   end;
   Progress:=0;
   Data_Show(Progress);
   Data_Show(PX);
   Data_Show(PM);
   Data_Show(PXs);
   Data_Show(PK);
  end;

{---------------------------------------------------------------------------}

 const

  cm_X      = 300;
  cm_M      = 302;
  cm_Xs     = 303;
  cm_Open   = 304;
  cm_Save   = 305;
  cm_SaveAs = 306;
  cm_About  = 320;
  cm_PK     = 321;
  cm_Mouse  = 322;
  cm_PWord  = 323;

  hc_Comm   = 307;
  hc_Graph  = 308;
  hc_File   = 309;

 type

  PStend = ^TStend;
  TStend = object(TWindow)
   Path: string;
   constructor Init;
   function  New_MenuBar(const Area: TRect): PView; virtual;
   function  New_HelpBar(const Area: TRect): PView; virtual;
   function  Valid_Quit: boolean; virtual Validate + cm_Quit;
   procedure Do_About (var E: TEvent); virtual ev_Command + cm_About;
   procedure Do_Cancel(var E: TEvent); virtual ev_Command + cm_Cancel;
   procedure Do_WinClose(var E: TEvent); virtual ev_Command + cm_WinClose;
   procedure Do_Open(var E: TEvent); virtual ev_Command + cm_Open;
   procedure Do_SaveAs(var E: TEvent); virtual ev_Command + cm_SaveAs;
   procedure Do_Save(var E: TEvent); virtual ev_Command + cm_Save;
   procedure Do_Ok(var E: TEvent); virtual ev_Command + cm_Ok;
   procedure Do_Xs(var E: TEvent); virtual ev_Command + cm_Xs;
   procedure Do_M(var E: TEvent); virtual ev_Command + cm_M;
   procedure Do_X(var E: TEvent); virtual ev_Command + cm_X;
   procedure Do_PK(var E: TEvent); virtual ev_Command + cm_PK;
   procedure Do_Mouse(var E: TEvent); virtual ev_Command + cm_Mouse;
   procedure Do_PWord(var E: TEvent); virtual ev_Command + cm_PWord;
  end;

 var

  Area: TRect;

  function TStend.New_MenuBar(const Area: TRect): PView;
   begin
    New_MenuBar:=New(PMenuBar,Init(Area,0,New_Tree(
     New_List ('&Файл',                 hc_File,    New_Tree(
      New_Item('&Автор ...','',         cm_About,   kb_None,
      New_Item('&Открыть ...','F3',     cm_Open,    kb_F3,
      New_Item('&Сохранить','F2',       cm_Save,    kb_F2,
      New_Item('Сохранить &как ...','', cm_SaveAs,  kb_None,
      New_Item('&Выход...','Alt+F3',    cm_WinClose,kb_Alt+kb_F3,
     nil)))))),
     New_List ('&Команды',              hc_Comm,    New_Tree(
      New_Item('С&читать','',           cm_Ok,      kb_None,
      New_Item('&Востановить','',       cm_Cancel,  kb_None,
     nil))),
     New_List ('&Характеристики',       hc_Graph,   New_Tree(
      New_Item('&Расходная','F4',       cm_M,       kb_F4,
      New_Item('&Статическая','F5',     cm_X,       kb_F5,
      New_Item('&Жескость','F7',        cm_Xs,      kb_F7,
      New_Item('&Давления','F8',        cm_PK,      kb_F8,
     nil))))),
     New_List ('&Сервис',               0,          New_Tree(
      New_Item('&Настройка Мыши','',    cm_Mouse,   kb_None,
      New_Item('&Установка Пароля','',  cm_PWord,   kb_None,
     nil))),
   nil)))))))
  end;

  function TStend.New_HelpBar(const Area: TRect): PView;
   begin
    New_HelpBar:=New(PHelpBar,Init(Area,of_Border,
     New_Ctx(hc_Comm,    'Управление данными и расчетом',
     New_Ctx(hc_Graph,   'Комманды работы с графиками',
     New_Ctx(hc_File,    'Управление файлами: Открыть; Сохранить; и тп.',
     New_Ctx(cm_About,   'Информация о програме и ее авторе',
     New_Ctx(cm_X,       'График статической характеристики',
     New_Ctx(cm_M,       'График расходной характеристики',
     New_Ctx(cm_Xs,      'График жесткости',
     New_Ctx(cm_Open,    'Загрузить данные с файла в активное окно',
     New_Ctx(cm_Save,    'Сохранить данные с активного окна в файл',
     New_Ctx(cm_SaveAs,  'Сохранить данные с активного окна в новый файл',
     New_Ctx(cm_Cancel,  'Востановить данные в активном окне',
     New_Ctx(cm_WinClose,'Завершить работу с программой',
     New_Ctx(cm_Ok,      'Выполнить расчет',
     New_Ctx(hc_None,    'Строка ввода с калькулятьром напр. 2+2*(3+1) и т.п.',
   nil))))))))))))))));
  end;

  procedure TStend.Do_Ok;
   begin
    Event_Clr(E);
    if not Comm_Valid(cm_Ok) then Exit;
    Data_Swap(False);
    Comm_Enable(cm_Ok,False);
    Comm_Enable(cm_WinClose,False);
    Run;
    Comm_Enable(cm_Ok,True);
    Comm_Enable(cm_WinClose,True);
    Comm_Enable(cm_M,True);
    Comm_Enable(cm_X,True);
    Comm_Enable(cm_Xs,True);
    Do_M(E);
    Do_Xs(E);
    Do_X(E);
    Do_PK(E);
   end;

  procedure TStend.Do_Cancel(var E: TEvent);
   begin
    if not Comm_Valid(E.Command) then Exit;
    Data_Swap(True)
   end;

  procedure TStend.Do_PWord(var E: TEvent);
    var S: string;
   begin
    Application^.Child_Exec(New(PWinPassword,Init('Пароль',8,S)));
    Event_Clr(E)
   end;

  procedure TStend.Do_Mouse(var E: TEvent);
    var S: string;
   begin
    Application^.Child_Exec(New(PWinMouse,Init('Параметры Мышки')));
    Event_Clr(E)
   end;

  procedure TStend.Do_WinClose(var E: TEvent);
   begin
    E.Command:=cm_Quit;
    Event_Put(E);
    Event_Clr(E)
   end;

  procedure TStend.Do_Open(var E: TEvent);
    var F: File;
   begin
    Event_Clr(E);
    if Application^.Child_Exec(New(PWinFile,Init('Открыть','*.*;*.dat',@Path))) <> cm_Ok then Exit;
    Assign(F,Path);
    Reset(F,1);
    Close(F);
    Data_Swap(True)
   end;

  procedure TStend.Do_Save(var E: TEvent);
    var F: File;
   begin
    Event_Clr(E);
    if Path = '' then begin
     Do_SaveAs(E);
     Exit
    end;
    Assign(F,Path);
    Rewrite(F,1);
    Close(F)
   end;

  procedure TStend.Do_SaveAs(var E: TEvent);
   var
    F: File;
    DirInfo: SearchRec;
   begin
    Event_Clr(E);
    if Application^.Child_Exec(New(PWinFile,Init('Сохранить как','*.dat',@Path))) <> cm_Ok then Exit;
    FindFirst(Path, AnyFile, DirInfo);
    if (DosError = 0) and (MessageBox(
     'Предупреждение',
     #13#3'Файл '+Path+ ' cуществует. Переписать ?',mb_Yes+mb_No+mb_Yellow) <> cm_Ok) then Exit;
    Assign(F,Path);
    Rewrite(F,1);
    Close(F)
   end;

  procedure TStend.Do_M;
   begin
    Event_Clr(E);
    if Data_Find(PM)^.Focus then Exit;
    Application^.Child_Ins(New(PWinGraph,Init(Area.Open(10,10,500,400)^,'P1,Па;V,л/мин',
    'Расходная характеристика',High(PM),SizeOf(PM[1]) div 6)))^.Data_Ptr:=@PM;
    Data_Show(PM)
   end;

  procedure TStend.Do_PK;
   begin
    Event_Clr(E);
    if Data_Find(PK)^.Focus then Exit;
    Application^.Child_Ins(New(PWinGraph,Init(Area.Open(40,40,500,400)^,'P1,Па;P2,PK,PS,Па',
    'Давления в камере',High(PK),SizeOf(PK[1]) div 6)))^.Data_Ptr:=@PK;
    Data_Show(PK)
   end;

  procedure TStend.Do_About;
   begin
    Event_Clr(E);
    MessageBox('Автор',
    #3'Сумский Государственны университет'+
    #13#3'кафедра общей динамики'+
    #13#3'Новак С. Н.',mb_Ok+mb_Green)
   end;

  procedure TStend.Do_X;
   begin
    Event_Clr(E);
    if Data_Find(PX)^.Focus then Exit;
    Application^.Child_Ins(New(PWinGraph,Init(Area.Open(70,120,420,300)^,'P1,Па;X,m',
    'Статическая характеристика',High(PX),SizeOf(PX[1]) div 6)))^.Data_Ptr:=@PX;
    Data_Show(PX)
   end;

  procedure TStend.Do_Xs;
   begin
    Event_Clr(E);
    if Data_Find(PXs)^.Focus then Exit;
    Application^.Child_Ins(New(PWinGraph,Init(Area.Open(300,50,250,200)^,'P1,Па;Xs,Н/m',
    'Статическая жесткость',High(PXs),SizeOf(PXs[1]) div 6)))^.Data_Ptr:=@PXs;
    Data_Show(PXs)
   end;

  function TStend.Valid_Quit: boolean;
   begin
    Valid_Quit:=MessageBox('Внимание',
    #3'Вы, хотите завершить'#13#3' работу ?',mb_Yes+mb_No+mb_Yellow+mb_Green) = cm_Yes;
   end;

  constructor TStend.Init;
    var Slider: PSliderBar;
   procedure New_Edit(Rect: TRect; Form: TForm; Text:string; var Data);
    begin
     with Desktop^ do begin
      Dec(Rect.B.X,100);
      Child_Ins(New(PLabel,Init(Area,Text)));
      Child_Ins(New(PEdit,Init(Rect.Move(Area.B.X-Area.A.X+10,0)^,Form,of_Border)))^.Data_Ptr:=@Data;
     end
    end;
   begin
    with Area do begin
     inherited Init(Open(10,10,500,446)^,
     'Моделирование работы импульсного уплотнения', of_NoGrow);
     GrowMode:=gm_CenterX+gm_CenterY;
     New_Edit(Open(10,10,280,16)^,^E#0#4,'Внутренний радиус R1, м',R1);
     New_Edit(Move(0,20)^,^E#0#4,'Внешний радиус R3, м',R3);
     New_Edit(Move(0,20)^,^E#0#4,'Внутренний радиус камер Rk1, м',Rk1);
     New_Edit(Move(0,20)^,^E#0#4,'Внешний радиус камер Rk2, м',Rk2);
     New_Edit(Move(0,20)^,^E#0#4,'Радиус вторичного уплотнения, m',Ru);
     New_Edit(Move(0,20)^,^E#0#0,'Количество камер N, шт',N);
     New_Edit(Move(0,20)^,^E#0#0,'Количество питателей Z, шт,',Z);
     New_Edit(Move(0,20)^,^E#11 ,'Длинна камеры Lk, m',Lk);
     New_Edit(Move(0,20)^,^E#11 ,'Объем камер Vk, m^3',Vk);
     New_Edit(Move(0,20)^,^E#0#1,'Газовая постоянная R, Дж/(кг*K)',R);
     New_Edit(Move(0,20)^,^E#0#1,'Температура газа T, K',T);
     New_Edit(Move(0,20)^,^E#11  ,'Вязкость газа Mu, Па*с',Mu);
     New_Edit(Move(0,20)^,^E#0#2,'Давление на выходе P3, Па',P3);
     New_Edit(Move(0,20)^,^E#0#2,'Частота вращения W, об/мин',Wo);
     New_Edit(Move(0,20)^,^E#0#2,'Давление на входе P1, Па',P1);
     New_Edit(Move(0,20)^,^E#0#2,'Усилие сжатия пружыны F, H',F);
     with DeskTop^ do begin
      Child_Ins(New(PIndicator,Init(Open(10,335,470,10)^,4)))^.Data_Ptr:=@Progress;
      Child_Ins(New(PButton,InitDef(Open(10,355,110,20)^,'С&читать',cm_Ok)));
      Child_Ins(New(PButton,Init(Move(B.X-A.X+5,0)^,'В&остановить',cm_Cancel)));
      Child_Ins(New(PButton,Init(Move(B.X-A.X+5,0)^,'&Сохранить',cm_Save)));
      Child_Ins(New(PButton,Init(Move(B.X-A.X+5,0)^,'&Выход',cm_WinClose)));
      Child_Select(True)
     end
    end;
    Comm_Enable(cm_M,False);
    Comm_Enable(cm_X,False);
    Comm_Enable(cm_Xs,False);
   end;

 var

  App: TApplication;

 begin
  MM:=MemAvail;
  Data_Def;
  App.Init;
  App.Child_Ins(New(PStend,Init));
  App.Child_Ins(New(PWinClock,Init(Area.Open(500,15,100,90)^)));
  App.Dlg_Exec;
  App.Free;
  WriteLn(MM,' ',MemAvail);
 end.
