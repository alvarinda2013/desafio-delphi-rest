{
           Seu objetivo � realizar o consumo desta API, seguindo o escopo abaixo:
****************************************************************************************************
Deve possuir um bot�o "Consultar" que ap�s clicado, dever� executar a rotina de consulta de CEP
e exibir na tela TODOS os dados retornados da consulta, como UF, Endere�o, Bairro, etc...
Implementar tratamentos de erros e de time-out.
Caso a API n�o responda em at� 5 segundos, uma mensagem dever� ser retornada para o usu�rio
que o servi�o de CEP est� indispon�vel no momento e que ele dever� tentar novamente mais tarde.
Caso o usu�rio informe um CEP com formato ou conte�do inv�lido o tratamento dever� ser realizado
pela aplica��o antes de realizar a consulta na API e a mensagem adequada exibida para o usu�rio.
A rotina de consulta de CEP dever� ser encapsulada em uma Classe TConsultaCEP, onde tudo que seja necess�rio para realizar o acesso a API
esteja auto contido na classe de maneira que essa consulta de CEP possa ser utilizada numa outra tela ou at� mesmo numa outra aplica��o
apenas instanciando a classe e chamando um m�todo "ConsultarCEP(xxx)", que dever� encapsular o retorno dos dados tamb�m numa classe.
Ex: TRetornoCEP.
Ao consultar um CEP, os dados retornados devem ser gravados num banco de dados (Postgres de preferencia, mas pode ser outro). Ao consultar um cep, antes de acessar a API, dever� consultar no banco e retornar do banco caso o CEP j� exista. Para isso, dever� ser criado a logica de acesso banco numa classe DAO separada da classe de consulta na API (n�o misturar responsabilidade das classes, pois a classe TConsultaCEP deve continuar sendo possivel obter os CEPs sem que seja necessario acesso a banco de dados)
}
unit untBrasilAPI;

interface
  uses
    FireDAC.Comp.Client, System.Classes, untExecutaSQL, REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope;
  type

//'{"cep":"72261011","state":"DF","city":"Bras�lia","neighborhood":"Ceil�ndia Norte (Ceil�ndia)",
//"street":"QNO 19 Conjunto 11","service":"correios"}'

  TRetornoCEP = class(TComponent)
  private
    Fstreet: string;
    Fstate: string;
    Fcep: string;
    Fservice: string;
    Fneighborhood: string;
    Fcity: string;
    procedure Limpar;
  public
    property cep          : string read Fcep          write Fcep;
    property state        : string read Fstate        write Fstate;
    property city         : string read Fcity         write Fcity;
    property neighborhood : string read Fneighborhood write Fneighborhood;
    property street       : string read Fstreet       write Fstreet;
    property service      : string read Fservice      write Fservice;
    procedure GravarDados;
    function TemCepNaBase : boolean;
    constructor Create(Owner : TComponent);reintroduce; overload;
  end;
  retCEP = array of TRetornoCEp;

  TConsultaCEP = class(TRetornoCEP)
    REST    : TRESTClient;
    Request : TRESTRequest;
    Response: TRESTResponse;
  private
    procedure ValidarCEP(const pValue : string);
    procedure consultar(const pValue : string);overload;

  public
    constructor Create(Owner : TComponent);reintroduce; overload;
    function consultarCEP(const pValue : string) : TRetornoCEP;overload;
    function consultarCEPPorFaixa(const pInicial, pFinal : integer) : TStrings;
  end;
  const
    incrementador = 2;{Este incrementador foi adicionado pois o range do CEP pode ficar muito alto,
                       fazendo com que o desenvolvedor possa aumentar o incremento no la�o de repeti��o.
                      }

implementation
  uses
    FireDAC.Stan.Option, System.SysUtils, REST.Json, iniFiles;

{ TPadrao }

function TConsultaCEP.consultarCEP(const pValue : string) : TRetornoCEP;
begin
  try
    consultar(pValue);
    Result := TRetornoCEP(Self);
    if Trim(Result.FCep).IsEmpty then
      Result := TJson.JsonToObject<TRetornoCEp>(Response.Content);
  except
    raise;
  end;
end;

procedure TConsultaCEP.consultar(const pValue: string);
const
  Resource = 'cep/v1/';
begin
  ValidarCEP(pVALUE);
  try
    Self.cep := pValue;
    if (Self.TemCepNaBase) then Exit;
    Request.Method := rmGET;
    Request.Resource := Resource + pValue;
    Request.Execute;
    case Response.StatusCode of
      200 : begin
              Self := TJson.JsonToObject<TConsultaCEP>(Response.Content);
              Self.GravarDados;
            end;
      404 : raise Exception.Create('CEP informado n�o retornou nenhum endere�o.');
      else raise Exception.Create(response.Content);
    end;
  except
    on e: exception do
      raise;
  end;
end;

function TConsultaCEP.consultarCEPPorFaixa(const pInicial, pFinal: integer) : TStrings;
var
  Item : TRetornoCEP;
begin
  result := TStringList.Create;

  if (pInicial = 0) or (pFinal = 0)  then
    raise Exception.Create('Informe uma faixa de CEP(s) v�lida.');

  if (pInicial > pFinal) then
    raise Exception.Create('O Cep inicial n�o pode ser menor que o final.');

  if ((pFinal - pInicial) > 10) then
    raise Exception.Create('O intervalo de pesquisa entre CEP(s), n�o poder�o ser superiores a 30 CEP(s).');

  for var I := pInicial to pred(pFinal) do
  begin
    sleep(3000);
    Item := consultarCEP(I.ToString);
    Result.AddObject(Item.Fcep, Item);
  end;
end;

constructor TConsultaCEP.Create(Owner: TComponent);
begin
  inherited create(owner);

  REST     := TRESTClient.Create('https://brasilapi.com.br/api/');
  REST.ReadTimeout := 5000;

  Request  := TRESTRequest.Create(Owner);
  Response := TRESTResponse.Create(Owner);

  Request.Client := Rest;
  Request.Response := Response;
end;

function TRetornoCEP.TemCepNaBase : boolean;
const
  SQL = 'SELECT CEP, UF, CIDADE, BAIRRO, ENDERECO FROM CEP WHERE CEP = :CEP';
begin
  result := False;

  if Trim(FCep).IsEmpty then Exit;
  
  var qry := TExecutaSQL.Create(Owner);
  try
    try
      qry.FetchOptions.Items := qry.FetchOptions.Items - [fiMeta];
      qry.Open(SQL, [FCep]);

      Limpar;

      if qry.IsEmpty then Exit;

      Self.Cep    := qry.FindField('CEP').AsString;
      self.State  := qry.FindField('UF').AsString;
      self.City   := qry.FindField('CIDADE').AsString;
      self.Neighborhood := qry.FindField('BAIRRO').AsString;
      self.Street := qry.FindField('ENDERECO').AsString;
    except
      raise;
    end;
  finally
    FreeAndNil(qry);
  end;
end;

constructor TRetornoCEP.Create(Owner: TComponent);
begin
  inherited create(owner);
 
end;

procedure TRetornoCEP.GravarDados;
const
  SQL = ' UPDATE OR  INSERT INTO CEP(CEP,  UF,     CIDADE,  BAIRRO,        ENDERECO)    '#13+
        ' VALUES        (:CEP, :STATE, :CITY, :NEIGHBORHOOD, :STREET) MATCHING(CEP, UF) ';
begin
  var qry := TExecutaSQL.Create(Owner);
  try
    try
      qry.FetchOptions.Items := qry.FetchOptions.Items - [fiMeta];
      qry.ExecSQL(SQL, [FCep, Fstate, Fcity, Fneighborhood, Fstreet]);
    except
      raise;
    end;
  finally
    FreeAndNil(qry);
  end;
end;

procedure TRetornoCEP.Limpar;
begin
  Cep    := '';
  State  := '';
  City   := '';
  Neighborhood := '';
  Street       := '';
end;

procedure TConsultaCEP.ValidarCEP(const pValue: string);
begin
  if (Trim(pVALUE).IsEmpty)
  or (Trim(pvalue).Length <> 08)
  then raise Exception.Create('Informe um CEP v�lido.');
end;

end.
