unit Graphics;
interface
uses Graph,Drivers,Din,Objects,Common;

Type
   TGrRec = record
     MasX,MasY,
     StepX,StepY,
     X,Y,
     XName,YName:String[7];
     OptionMas:word;
     Title:string[40];
     Color:TColor;
     end;
{0 - фон
 1 - сетка
 2 - выноски
 3 - метки}
Var
   GraphicRec:TGrRec;

type
   PBufferCollection = ^TBufferCollection;
   TBufferCollection = object(TCollection)
      procedure AtDelete(Index:integer);
      end;

   PGraphic = ^TGraphic;
   TGraphic = object
      masx,masy:real;
      x,y:integer;
      stepx,stepy:real;
      OptionMas:word;
      MaximumX,MinimumX:real;
      MaximumY,MinimumY:real;
      Yakor:integer;
      LineColor,LabelsColor,ColSetka,ColDesk:word;
      Collect:PBufferCollection;
      NumVector:byte;
      IsInsert:boolean;
      XName,YName:string[5];
      Title:string[40];
      YTitle:integer;
      constructor Init(GrRec:TGrRec);
      procedure NewParam(aGrRec:TGrRec);
      procedure StoreParam(var GrRec:TGrRec);
      destructor Done;virtual;
      procedure InsertBuffer(NewBuffer:PBuffer);
      function MaxX:real;virtual;
      function MinX:real;virtual;
      function MaxY:real;virtual;
      function MinY:real;virtual;
      procedure PredProcess;
      procedure GetAutoMasshtab;
      function GetYakor:integer;
      procedure Show;
      procedure Hide;
      procedure DrawSetka;virtual;
      procedure DrawGraphic(Buf:PBuffer);virtual;
      procedure DrawAllGraphic;virtual;
      procedure DrawTitle;virtual;
      procedure Resize(NewMasX,NewMasY:real);
      procedure Move(NewX,NewY:integer);
      procedure NewStep(NewStX,NewStY:real);
      procedure HandleEvent;
      function Execute:word;
      end;
