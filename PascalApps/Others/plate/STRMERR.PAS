{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit StrmErr;

interface

uses Objects;

type
  PMsgStream = ^TMsgStream;
  TMsgStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;


implementation

uses MsgBox;

const
  MsgString: array[-6..-1] of String =
    ('Put ��� ����ॣ����஢������'+^M^C'⨯� ��ꥪ� %d',
     'Get ��� ����ॣ����஢������'+^M^C'⨯� ��ꥪ� %d',
    '�訡�� ����� %d;'+^M^C'����� ������ ��⮪', '%d �⥭�� �� ���殬 ��⮪�',
    '����� ���樠����஢��� ��⮪'+^M^C'��� %d', '�訡�� ����㯠 %d');

procedure TMsgStream.Error(Code, Info: Integer);
var
  LongInfo: Longint;
begin
  inherited Error(Code, Info);
  LongInfo := Longint(Info);
  MessageBox(MsgString[Code], @LongInfo, mfError or mfOKButton);
end;

end.
