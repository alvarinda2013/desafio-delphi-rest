unit untExecutaSQL;


interface
  uses
    FireDAC.Comp.Client, System.Classes, Data.DB, FireDAC.Phys.FB, FireDAC.Comp.UI;

  type
  TExecutaSQL = class(TFDQuery)
  protected
    procedure GravaLog(sLog: String);
    procedure CopiarParaAreaDeTransferencia;
  private
    Cursor: TFDGUIxWaitCursor;
    Link: TFDPhysFBDriverLink;
    function ConectarBase : boolean;
  public
    conexao    : TFDConnection;
    sSQL : String;
    procedure ExecSQL;overload;
    procedure ExecSQL(const sSQL : String);overload;
    function ExecSQL(const sSQL: String; const AParams: array of Variant): LongInt; overload;
    procedure Post; reintroduce;overload;
    procedure Open;overload;
    procedure Open(Const sSQL : String);overload;
    procedure Open(const ASQL: String; const AParams: array of Variant); overload;
    function FindField(const FieldName: string): TField;
    constructor Create(Owner : TComponent);reintroduce; overload;
    procedure LimparQuery;

  end;

implementation
  uses
    System.SysUtils, ClipBrd, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.DApt, iniFiles,
    FireDAC.Stan.Def;

{ TExecutaSQL }

function TExecutaSQL.ConectarBase : boolean;
begin
  result := False;
  var sPathConfig := ExtractFilePath(ParamStr(0)) + 'Config.ini';
  var ini := TIniFile.Create(sPathConfig);
  var sbase := ExtractFilePath(ParamStr(0))+'base\base.dbd';
  if not FileExists(sPathConfig) then Exit;
  if not FileExists(sbase) then Exit;

  try
    try
      conexao.Connected := False;
      conexao.LoginPrompt := False;
      conexao.Params.Clear;
      conexao.Params.Add('DriverID=FB');

      conexao.Params.Add('user_name=' + ini.ReadString('FIREBIRD', 'user', 'SYSDBA'));
      conexao.Params.Add('password='  + ini.ReadString('FIREBIRD', 'password', 'masterkey'));
      conexao.Params.Add('Database='  + sbase);
      result := True;
    except
      raise;
    end;
  finally
    ini.Free;
  end;
end;

procedure TExecutaSQL.CopiarParaAreaDeTransferencia;
begin
//  if DebugHook <> 0 then
//    Clipboard.AsText := Self.SQL.Text;
end;

constructor TExecutaSQL.Create(Owner: TComponent);
begin
  inherited create(owner);
  conexao := TFDConnection.Create(Owner);
  Cursor  := TFDGUIxWaitCursor.Create(Owner);
  Link    := TFDPhysFBDriverLink.Create(Owner);

  Link.VendorLib := 'fbClient.dll';
  Self.Connection := Conexao;
  Self.FetchOptions.Items := Self.FetchOptions.Items - [fiMeta];
  ConectarBase;
end;

function TExecutaSQL.ExecSQL(const sSQL: String; const AParams: array of Variant): LongInt;
begin
  Result := -1;
  try
    try
      if not ConectarBase then exit;
      Result := ExecSQL(sSQL, AParams, []);
    except
      on e: exception do
      begin
//        if DebugHook <> 0 then
//          CopiarParaAreaDeTransferencia;
        GravaLog('Erro: ' + E.Message);
        raise;
      end;
    end;
  finally
    LimparQuery;
  end;
end;

procedure TExecutaSQL.ExecSQL(const sSQL: String);
begin
  try
    SQL.Text := sSQL;
    ExecSQL;
  except
    raise;
  end;
end;

function TExecutaSQL.FindField(const FieldName: string): TField;
begin
  result := inherited;
end;

procedure TExecutaSQL.GravaLog(sLog: String);
var
  sPath: String;
  sl : TStrings;
begin
  try
    sPath := ExtractFilePath(ParamStr(0)) + 'Log';

    if not DirectoryExists(sPath) then  // Verifica diretorio
      ForceDirectories(sPath);

    sPath := sPath + '\LogErro.txt';

    sl := TStringList.Create;

    if FileExists(sPath) then
      sl.LoadFromFile(sPath);

    sl.Append(FormatDateTime('dd/mm/yyyy hh:mm:ss',Now) + ' - ' + sLog);
    sl.SaveToFile(sPath);
  finally
    FreeAndNil(sl);
  end;
end;

procedure TExecutaSQL.ExecSQL;
begin
  try
    try
      Self.Connection.StartTransaction;
      inherited;
      Self.Connection.Commit;
    except
      on e: exception do
      begin
        if Self.Connection.InTransaction then
        Self.Connection.Rollback;
//        if DebugHook <> 0 then
//          CopiarParaAreaDeTransferencia;
        GravaLog('Erro: ' + E.Message);
        raise;
      end;
    end;
  finally
    LimparQuery;
  end;
end;

procedure TExecutaSQL.LimparQuery;
begin
  Self.Close;
  Self.SQL.Clear;
  Self.Params.Clear;
end;

procedure TExecutaSQL.Open(const ASQL: String; const AParams: array of Variant);
begin
  try
    Self.Close;
    if not ConectarBase then exit;
    Connection.StartTransaction;
    inherited;
    Self.First;
    Self.Connection.Commit;
  except
    on e: exception do
    begin
      Self.Connection.Rollback;
      CopiarParaAreaDeTransferencia;
      GravaLog('Erro: ' + e.Message);
      raise;
    end;
  end;

end;

procedure TExecutaSQL.Open;
begin
  try
    try
      Self.Connection.StartTransaction;
      inherited;
      Self.First;
      Self.Connection.Commit;
    except
//      on e: exception do
      on E : EFDDBEngineException do
      begin
      var sErro := '';
        for var I := 0 to pred(e.ErrorCount) do
          sErro := e.Errors[i].Message + #13;

//        case E.Kind of
//            ekOther: ;
//            ekNoDataFound: ;
//            ekTooManyRows: ;
//            ekRecordLocked: ;
//            ekUKViolated: sErro := 'C�digo j� existe;' ;
//            ekFKViolated: ;
//            ekObjNotExists: ;
//            ekUserPwdInvalid: ;
//            ekUserPwdExpired: ;
//            ekUserPwdWillExpire: ;
//            ekCmdAborted: ;
//            ekServerGone: ;
//            ekServerOutput: ;
//            ekArrExecMalfunc: ;
//            ekInvalidParams: ;
//        end;
        Self.Connection.Rollback;
        CopiarParaAreaDeTransferencia;
        GravaLog('Erro: ' + sErro);
        raise Exception.Create(sErro);
      end;
    end;
  finally
//    if (UpperCase(Self.SQL.Text).IndexOf('RETURNING') < 0) then
//      LimparQuery;
  end;
end;

procedure TExecutaSQL.Open(Const sSQL : String);
begin
  try
    try
      Self.Connection.StartTransaction;
      inherited;
      Self.Connection.Commit;
    except
      on e: exception do
      begin
        Self.Connection.Rollback;

//        if (DebugHook <> 0) then
//          CopiarParaAreaDeTransferencia;

        GravaLog('Erro: ' + e.Message);
        raise;
      end;
    end;
  finally
//    LimparQuery;
  end;
end;

procedure TExecutaSQL.Post;
begin
  try
    Self.Connection.StartTransaction;
    inherited;
    Self.First;
    Self.Connection.Commit;
  except
    on e: exception do
    begin
      Self.Connection.Rollback;
      CopiarParaAreaDeTransferencia;
      GravaLog('Erro: ' + e.Message);
      raise;
    end;
  end;
end;

end.

