{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit StrmErr;

interface

uses Objects,App;

type
  PMsgStream = ^TMsgStream;
  TMsgStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;


implementation

uses MsgBox;

const
  MsgString: array[-6..-1] of String =
    ('Put для незарегистрированного типа объекта %d',
     'Get для незарегистрированного типа объекта %d',
    'Ошибка записи %d;'+^M^C'нельзя расширить поток', '%d Чтение за концом потока',
    'Нельзя инициализировать поток'+^M^C'код %d', 'Ошибка доступа %d');

procedure TMsgStream.Error(Code, Info: Integer);
var
  LongInfo: Longint;
begin
  inherited Error(Code, Info);
  LongInfo := Longint(Info);
  If DeskTop <> nil Then
      MessageBox(MsgString[Code], @LongInfo, mfError or mfOKButton)
      Else
      begin
        Writeln(MsgString[Code]);
      end;
end;

end.
