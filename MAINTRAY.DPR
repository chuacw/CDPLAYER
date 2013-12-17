program Maintray;

uses
  Forms,
  Traytest in 'TRAYTEST.PAS' {Form1};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
