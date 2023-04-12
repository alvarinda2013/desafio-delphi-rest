unit untCep;

interface

implementation
uses
  REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope;
type
//  TRetornoCEP = record
//
//  end;

  TConsultaCEP = class
    REST : TRESTClient;
    Request: TRESTRequest;
    Response: TRESTResponse;
  private
    fCep : integer;
  public
    procedure ConsultaCEP(const Value);

    property cep : integer read fCep write fCep;
  end;

{ TConsultaCEP }

procedure TConsultaCEP.ConsultaCEP(const Value);
begin

end;

end.
