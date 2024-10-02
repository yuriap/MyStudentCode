Program InterFase;
Uses Crt,Windows;
Type
   PColorType = ^TColorType;
   TColorType = record
     BkCol,TextCol:word;
     end;
Const ColWind : array [1..5] of TColorType =((BkCol:11;TextCol:14),
                                             (BkCol:12;TextCol:2),
                                             (BkCol:13;TextCol:3),
                                             (BkCol:15;TextCol:4),
                                             (BkCol:10;TextCol:5));
Type
   PRectung = ^TRectung;
   TRectung = object
     xa,ya,width,height:word;
     NumWind : byte;
     end;
   PWindows =^TWindows;
   TWindows = object(TRectung)
     Color:TColorType;
     constructor InitWind(x,y,w,h:word;ColorType:TColorType;Num:byte);
     procedure ShowWind;virtual;
     procedure HideWind;virtual;
     procedure WriteText(x,y:byte;text:string);
     function GetX:word;
     function GetY:word;
     destructor DoneWind;
     end;
 Constructor Twindows.InitWind(x,y,w,h:word;ColorType:TColorType;Num:Byte);
 Begin
  xa:=x;ya:=y;
  width:=w;height:=h;
  Color:=ColorType;
  NumWind:=Num;
  ShowWind;
 end;{Twindows.InitWind}
 Procedure TWindows.ShowWind;
 Var s                       :String[3];
 begin
   DoubleBoxWindow(xa, ya, width, height, Color.BkCol, Color.TextCol );
   If NumWind = 0 Then s:=''Else Str(NumWind,s);
   WriteText(3,1,'éäçé '+s);
 end;
 Procedure TWindows.HideWind;
 begin
 end;
 Procedure TWindows.WriteText(x,y:byte;text:string);
 begin
    WriteXY(x,y,text);
 End;
 {$F+}
 function TWindows.GetX:word;
 begin
   GetX:=xa;
 end;
 function TWindows.GetY:word;
 begin
   GetY:=ya;
 end;
 {$F-}
 Destructor TWindows.DoneWind;
 begin
 end;

 Type
     PScreen = ^TScreen;
     TScreen = object(TWindows)
        end;

     PListWind = ^TListWind;
     TListWind = record
        PtrScreen : PScreen;
        PtrWind   : PWindows;
        NextWind  : PListWind;
        PredWind  : PListWind;
        end;
     PList = ^TList;
     TList = object
         First    :PListWind;
         Ptr      :PListWind;
         PtrPred  :PListWind;
         Count    :integer;
         constructor ListInit;
         procedure ScreenInit;
         procedure Make;
         procedure MakeNext;
         destructor ListDone;
         end;
 constructor TList.ListInit;
 begin
   First:=nil;
   Ptr:=nil;
   Count:=0;
 end;
 procedure TList.ScreenInit;
 begin
    First:=New(PListWind);
    First^.PtrScreen:=New(PScreen,InitWind(1,1,79,24,ColWind[1],Count));
    First^.PtrWind:= nil;
    First^.PredWind:= nil;
    First^.NextWind:= New(PListWind);
    Ptr:=First^.NextWind;
    PtrPred:=First;
 end;
 procedure TList.Make;
 var  x,y  :word;
 begin
   If PtrPred^.PtrWind <> nil Then begin
       x:=PtrPred^.PtrWind^.xa;
       y:=PtrPred^.PtrWind^.ya;
       end
      else begin
       x:=PtrPred^.PtrScreen^.xa;
       y:=PtrPred^.PtrScreen^.ya;
       end;
   Ptr^.PtrWind:=New(PWindows,InitWind(x+5,y+1,20,5,ColWind[2],Count));
   Ptr^.PtrScreen:=nil;
   Ptr^.NextWind:=New(PListWind);
   Ptr^.PredWind:=PtrPred;
   PtrPred:=Ptr;
   Ptr:=Ptr^.NextWind;
 end;
 procedure TList.MakeNext;
 begin
 Repeat
   Count:=Count+1;
   Case UpCase(ReadKey) of
        'M' : Make;
        'E' : Exit;
        end;
 Until false;
 end;
 destructor TList.ListDone;
 begin
 end;
 Var
   List : PList;
 Begin
    List:=New(PList,ListInit);
    List^.ScreenInit;
    List^.MakeNext;
    ReadKey;
    Dispose(List,ListDone);
 End.