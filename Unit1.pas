unit Unit1;

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  uArabicNumAndChineseNumInterchange;

{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
var
  aArabicNumAndChineseNumInterchange: TArabicNumAndChineseNumInterchange;
begin
  aArabicNumAndChineseNumInterchange := TArabicNumAndChineseNumInterchange.Create;
  try
    ShowMessage(aArabicNumAndChineseNumInterchange.ArabicNumToChineseNum(1252));

    ShowMessage(IntToStr(aArabicNumAndChineseNumInterchange.ChineseNumToArabicNum('ʮһ')));
  finally
    aArabicNumAndChineseNumInterchange.Free;
  end;
end;

end.

