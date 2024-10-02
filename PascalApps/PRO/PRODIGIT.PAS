unit ProDigit;
interface
uses Objects,Profiles,ProfView,ProfComm;
type
  PDigital = ^TDigital;
  TDigital = object(TObject);
      Profile:PProfile;
      constructor Init;
      constructor Load(var S:TStream);
      procedure Store(var S:TStream);
      procedure GetLeftPart;
      procedure GetRightPart;
      procedure GetIncogPart;
      procedure MiddleProcess;virtual;
      procedure Execute;
      end;
implementation
begin
end;