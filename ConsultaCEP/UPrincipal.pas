unit UPrincipal;

interface

uses Vcl.StdCtrls, Vcl.Controls, System.Classes, System.ImageList, Vcl.Forms, Vcl.ImgList, Vcl.ExtCtrls,System.Types,
     System.SysUtils, Vcl.Dialogs, Vcl.ComCtrls, frxGIFGraphic, Vcl.Imaging.GIFImg, Vcl.Mask, Vcl.Imaging.pngimage, Vcl.Samples.Spin;


//  Winapi.Windows, Winapi.Messages, , System.Variants, System.Classes, Vcl.Graphics,
//  Vcl.Controls,  , Vcl.StdCtrls, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList;

type
  TFrmConsultaCEP = class(TForm)
    StatusBar1: TStatusBar;
    pg: TPageControl;
    tbCEP: TTabSheet;
    TabSheet2: TTabSheet;
    ImageList1: TImageList;
    pnlConfiguracao: TPanel;
    Button1: TButton;
    Panel2: TPanel;
    edtCidade: TLabeledEdit;
    edtBairro: TLabeledEdit;
    edtEndereco: TLabeledEdit;
    cbUF: TComboBox;
    Label1: TLabel;
    btnPesquisa: TButton;
    imgLoading: TImage;
    Label2: TLabel;
    edtCEP: TLabeledEdit;
    edtCEPFinal: TLabeledEdit;
    edtCEPInicial: TLabeledEdit;
    TimerConsulta: TTimer;
    Image1: TImage;
    spSegundos: TSpinEdit;
    Label3: TLabel;
    imgLoadingFaixa: TImage;
    List: TListBox;
    Panel3: TPanel;
    Shape7: TShape;
    lblCep: TLabel;
    lblEndereco: TLabel;
    lblDataVencimento: TLabel;
    lblUF: TLabel;
    lblCidade: TLabel;
    um: TLabel;
    Dois: TLabel;
    Tres: TLabel;
    procedure edtCEPEnter(Sender: TObject);
    procedure edtCEPExit(Sender: TObject);
    procedure edtCEPRightButtonClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure TimerConsultaTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
  private
    gif: TGIFImage;
    bConsultando : Boolean;
    function onlyNumber(const Value : string) : string;
    function FormataCep(const Value : string) : string;
    procedure ExecutarConsultaPorFaixa;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmConsultaCEP: TFrmConsultaCEP;

implementation
  uses untBrasilAPI, System.MaskUtils, System.Threading, Vcl.Graphics, math, Winapi.Windows;

{$R *.dfm}

procedure TFrmConsultaCEP.Button1Click(Sender: TObject);
begin
  if bConsultando then
  begin
    ShowMessage('J� existe uma consulta em andamento. Aguarde.');
    Exit;
  end;
  ExecutarConsultaPorFaixa;
end;

procedure TFrmConsultaCEP.edtCEPEnter(Sender: TObject);
begin
  TLabeledEdit(Sender).Text := OnlyNumber(TLabeledEdit(Sender).Text);
end;

procedure TFrmConsultaCEP.edtCEPExit(Sender: TObject);
begin
  TLabeledEdit(Sender).Text := FormataCEP(TLabeledEdit(Sender).Text);
end;

procedure TFrmConsultaCEP.edtCEPRightButtonClick(Sender: TObject);
begin
  if Trim(OnlyNumber(edtCEP.Text)).IsEmpty then
  begin
    ShowMessage('Informe um CEP v�lido.');
    Exit;
  end;

  if imgLoading.Visible then Exit;

  var Task := TTask.Create(
                            procedure
                            begin
                              imgLoading.Visible := True;
                              btnPesquisa.Visible := not imgLoading.Visible;
                              if not bConsultando then
                                StatusBar1.Panels.Items[0].Text := 'Pesquisando cep(s) informados, aguarde ';

                              var Item := TConsultaCEP.Create(Self);
                              try
                                try
                                  var sFaixaInicial := Trim(OnlyNumber(edtCEP.Text));
                                  var retorno := item.consultarCEP(sFaixaInicial);
                                  try
                                    cbUF.ItemIndex := cbUF.Items.IndexOf(retorno.state);
                                    edtCidade.Text := retorno.city;
                                    edtBairro.Text := retorno.neighborhood;
                                    edtEndereco.Text := retorno.street;
                                  finally
                                    FreeAndNil(retorno);
                                  end;
                                except
                                  on e: exception do
                                   ShowMessage('Erro: ' + e.Message);
                                end;
                              finally
                                imgLoading.Visible := False;
                                btnPesquisa.Visible := not imgLoading.Visible;
                                FreeAndNil(item);

                                if not bConsultando then
                                  StatusBar1.Panels.Items[0].Text := 'Pesquisa de cep finalizada';
                              end;

                            end
                            );
    Task.Start;
end;

procedure TFrmConsultaCEP.ExecutarConsultaPorFaixa;
begin
  TimerConsulta.Interval := (spSegundos.Value * 60000);
  var Task := TTask.Create(
                            procedure
                            begin
                              bConsultando := True;
                              imgLoadingFaixa.Visible := True;
                              btnPesquisa.Visible := not imgLoadingFaixa.Visible;
                              StatusBar1.Panels.Items[0].Text := 'Pesquisando cep(s) informados, aguarde ';
                              var Item := TConsultaCEP.Create(Self);

                              try
                                try
                                  var sFaixaInicial := Trim(OnlyNumber(edtCEPInicial.Text));
                                  var sFaixaFinal   := Trim(OnlyNumber(edtCEPFinal.Text));
                                  var sl := item.consultarCEPPorFaixa(sFaixaInicial.ToInteger, sFaixaFinal.ToInteger);
                                  List.Items := SL;
                                  FreeAndNil(Sl);
                                except
                                  on e: exception do
                                    StatusBar1.Panels.Items[0].Text := e.Message;
                                end;
                              finally
                                imgLoadingFaixa.Visible := False;
                                btnPesquisa.Visible := not imgLoadingFaixa.Visible;
                                FreeAndNil(item);
                                StatusBar1.Panels.Items[0].Text := 'Pesquisa de cep finalizada';
                                bConsultando := False;
                              end;
                            end
                            );
    Task.Start;
end;

function TFrmConsultaCEP.FormataCep(const Value : string): string;
const
  MascaraCEP  : string   = '00.000-000;0;_';
begin
  result := FormatMaskText(MascaraCEP, OnlyNumber(Value));
end;

procedure TFrmConsultaCEP.FormCreate(Sender: TObject);
begin
  bConsultando := False;
  if FileExists('img\05.gif') then
  begin
    gif := TGIFImage.Create;
    gif.LoadFromFile('img\05.gif');
    gif.Animate := true;

    imgLoading.Stretch := True;
    imgLoading.Proportional := True;
    imgLoading.Picture.Assign(GIF);

    imgLoadingFaixa.Stretch := True;
    imgLoadingFaixa.Proportional := True;
    imgLoadingFaixa.Picture.Assign(GIF);
  end;
end;

procedure TFrmConsultaCEP.FormDestroy(Sender: TObject);
begin
  if Assigned(gif) then 
    FreeAndNil(gif);
end;

procedure TFrmConsultaCEP.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then
    SelectNext(Screen.ActiveControl, True, True)
  else if (key = #23) then Close;
end;

procedure TFrmConsultaCEP.FormShow(Sender: TObject);
begin
  pg.TabIndex := 0;
  pnlConfiguracao.Height := 58;
  TimerConsulta.Interval := 1 * 60000;
  TimerConsulta.Enabled  := True;
  imgLoading.Visible := False;
  imgLoadingFaixa.Visible := False;
end;

procedure TFrmConsultaCEP.Image1Click(Sender: TObject);
begin
  pnlConfiguracao.Height := IfThen(pnlConfiguracao.Height = 58, 113, 58 );
end;

procedure TFrmConsultaCEP.ListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with TListBox(Control).Canvas do
  begin

    FillRect(Rect);
    Font.Style := [];

    if odSelected in State then
    begin
      Brush.Color := TColor($00FFD2A6);
      Font.Color := clBlack;
      Font.Style := [TFontStyle.fsBold];
      RoundRect(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, 1, 1);
    end;
    var Item := TConsultaCEP(TListBox(Control).Items.Objects[Index]);
    var r := Rect;
    r.top := r.top + 7;

    r.Left  := lblCep.Left;
    r.Right := Um.Left;
    DrawText(Handle, PChar(Item.Cep), -1, r, DT_CENTER);

    r.Left  := lblEndereco.Left;
    r.Right := Dois.Left;
    DrawText(Handle, PChar(Item.street), -1, r, Dt_Left);

    r.Left  := lblUF.Left;
    r.Right := Tres.Left;
    DrawText(Handle, PChar(Item.State), -1, r, DT_CENTER);

    r.Left  := lblCidade.Left;
    r.Right := lblCidade.Left + lblCidade.Width;
    DrawText(Handle, PChar(Item.city), -1, r, Dt_Left);
  end;
end;


function TFrmConsultaCEP.onlyNumber(const Value : string): string;
begin
  result   := '' ;
  var LenValue := Length(value) ;
  for var I := 1 to LenValue  do
  begin
     if CharInSet(value[I], ['0'..'9']) then
        Result := Result + value[I];
  end;
end ;


procedure TFrmConsultaCEP.TimerConsultaTimer(Sender: TObject);
begin
  if not bConsultando then 
    ExecutarConsultaPorFaixa;
end;

end.
