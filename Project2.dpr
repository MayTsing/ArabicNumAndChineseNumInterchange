program Project2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uArabicNumAndChineseNumInterchange in 'uArabicNumAndChineseNumInterchange.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
