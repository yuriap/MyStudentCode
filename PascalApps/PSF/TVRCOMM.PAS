unit TvrComm;
interface
uses Crt,Objects;
const
    TvrFile = 'tvprof.tvr';
    MenusId = 'Menus';
    StatusLineId = 'Status';
    BufferGraphParamID = 'BufGrPar';
    ColorDlgId = 'ColorDlg';
    IsHelp : boolean = false;
                                   hcFile =1000;
    cmCreateObj = 1001;            hcCreateObj = 1001;
    cmOpenObj = 1002;              hcOpenObj = 1002;
    cmSaveObj = 1003;              hcSaveObj = 1003;
    cmSaveAsObj = 1004;            hcSaveAsObj = 1004;
    cmChDir = 1005;                hcChDir = 1005;
    hcQuit =1006;
    hcBuffer = 1010;
    cmServiceBuffer = 1011;        hcNoContext =1011;
    hcVievBuffer = 1020;
    cmGraphParam = 1021;           hcGraphParam = 1021;
    cmViewBufferGraph = 1022;      hcViewBGraph = 1022;
    cmChColor = 1023;              hcChColor = 1023;
    idSpecialDlg = 1000;
    idOption = 1001;
    idList = 1002;
    idCDlg = 1003;
    idInpLineNe = 1004;
Const
  {внетренняя команда}
  cmViewColor = 2002;
Type
   TListRec = record
     List : PCollection;
     Selection : word;
     end;

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
