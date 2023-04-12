unit untDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Comp.UI, Data.DB,
  FireDAC.Comp.Client;

type
  TDM = class(TDataModule)
    Conexao: TFDConnection;
    Cursor: TFDGUIxWaitCursor;
    Link: TFDPhysFBDriverLink;
    procedure ConexaoLost(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation
  uses
    iniFiles;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.ConexaoLost(Sender: TObject);
begin
  raise Exception.Create('Conexão com a base de dados foi perdida.');
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  Link.VendorLib := 'fbclient.dll';
end;

end.
