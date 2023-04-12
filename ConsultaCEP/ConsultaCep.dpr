program ConsultaCep;

uses
  Vcl.Forms,
  UPrincipal in 'UPrincipal.pas' {FrmConsultaCEP},
  untCep in 'units\untCep.pas',
  untExecutaSQL in 'units\untExecutaSQL.pas',
  untBrasilAPI in 'units\untBrasilAPI.pas',
  untDM in 'untDM.pas' {DM: TDataModule};

{$R *.res}

begin
//  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmConsultaCEP, FrmConsultaCEP);
  Application.Run;
end.