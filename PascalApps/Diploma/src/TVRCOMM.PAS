unit TvrComm;
interface
uses Crt,Objects,ProGraph,ProfMain,ProMain1,ProfView,Views;
var
  Graphic:PGraphic;
  Main:PMain1;
  MainRec:PMainRec;
  Viewer:PViewer;
  ViewerRec:TViewerRec;

const
    TvrFile = 'wpower.tvr';
    MenusId = 'Menus';
    StatusLineId = 'Status';
    BufferGraphParamID = 'BufGrPar';
    ColorDlgId = 'ColorDlg';
    MainParamId = 'MainParam';
    ProfParamID = 'ProfParam';
    BoundParamID = 'BoundParam';
    ViewerDialogId = 'ViewerDialog';
    OptionWindowId = 'OptionWindow';
    IsHelp : boolean = false;

    cmCreateObj = 201;
    cmOpenObj = 202;
    cmSaveObj = 203;
    cmSaveAsObj = 204;            hcSaveAsObj = 1004;
    cmDoneMain  = 205;
    cmChDir = 1006;                hcChDir = 1006;


                                   hcParametr = 1010;
                                   hcCalculate = 1011;
                                   hcResults = 1012;
                                   hcGraphics = 1020;
    cmManager = 221;              hcManager =1021;
    cmGraphParam = 1022;           hcGraphParam = 1022;
    cmChColor = 1023;              hcChColor = 1023;
    cmViewBufferGraph = 224;      hcViewBGraph = 1024;
    cmMainParam = 225;            hcMainParam = 1025;
    cmProfParam = 226;            hcProfParam = 1026;
    cmBoundParam = 227;           hcBoundParam = 1027;
    cmStart = 1028;
    cmChangeFasa = 1029;
    cmChangeBoundStatus = 1030;
    cmBegining = 231;             hcBegining = 1031;
    cmStop = 1032;
                                   hcWindType = 1032;
    cmGParam = 233;               hcGParam = 1033;
    cmCColor = 234;               hcCColor = 1034;
    cmViewGraph = 235;            hcViewGraph = 1035;
    cmDigitResults = 236;         hcDigitResults = 1036;
    cmDt = 237;                   hcDt = 1037;
    cmOmega = 238;                hcOmega = 1038;
    cmUx = 239;                   hcUx = 1039;
    cmUy = 240;                   hcUy = 1040;
    cmMaxTime = 241;              hcMaxTime = 1041;
    cmPsi = 242;                  hcPsi = 1042;
    cmS = 243;                    hcS = 1043;
    cmMaxIter = 244;              hcMaxIter = 1044;
    cmParNevazka = 245;           hcParNevazka = 1045;
    cmMaxNevazka = 246;           hcMaxNevazka = 1046;
    cmPrec = 247;                 hcPrec = 1047;
    cmSloy = 248;                 hcSloy = 1048;
    cmNFree = 249;                hcNFree = 1049;
    cmNewPicture = 250;           hcNewPicture = 1050;
    cmEditPicture = 251;          hcEditPicture = 1051;
    cmDelPicture = 252;           hcDelPicture = 1052;
    cmAbout = 1053;
    cmSLGraph = 1054;             hcSLGraph = 1054;
    cmLLGraph =1055;              hcLLGraph = 1055;
    cmErrorInGraphic = 1056;
    cmListing = 253;              hcListing = 1057;
    cmMainOptions = 254;          hcMainOptions = 1058;
    cmOptionView = 255;
    idSpecialDlg = 1000;
    idOption = 1001;
    idList = 1002;
    idCDlg = 1003;
    idInpLineNe = 1004;
    idStatusWindow = 1005;

    hcStatusWindow = $FF01;
Const
  {внетренняя команда}
  cmViewColor = 2002;
Type
   TListRec = record
     List : PCollection;
     Selection : word;
     end;
const
  NotAfterCreateSet:TCommandSet=[cmCreateObj,cmOpenObj];
  AfterCreateSet:TCommandSet=[cmSaveObj,cmSaveAsObj,cmDoneMain,
    cmMainParam,cmBegining,cmListing,cmMainOptions,
    cmGParam,cmCColor,cmViewGraph,cmDigitResults,cmDt,cmOmega,cmUx,
    cmUy,cmMaxTime,cmPsi,cmS,cmMaxIter,cmParNevazka,cmMaxNevazka,cmPrec,
    cmSloy,cmNFree,cmNewPicture];
const
  hcCreateObj            = 5;
  hcDoneMain             = 8;
  hcFile                 = 4;
  hcHelp                 = 10;
  hcNoContext            = 3;
  hcOpenObj              = 6;
  hcQuit                 = 9;
  hcSaveObj              = 7;

procedure Beep;
implementation
procedure Beep;
begin
  Sound(440);
  Delay(50);
  NoSound;
end;
begin
end.
