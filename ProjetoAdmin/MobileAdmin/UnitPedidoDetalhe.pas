unit UnitPedidoDetalhe;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, uCombobox,
  FMX.DialogService, uLoading, uFunctions, System.JSON;

type
  TExecuteOnClose = procedure of Object;

  TFrmPedidoDetalhe = class(TForm)
    rectToolBar: TRectangle;
    Label3: TLabel;
    imgFechar: TImage;
    Rectangle1: TRectangle;
    lblPedido: TLabel;
    lblData: TLabel;
    lblCliente: TLabel;
    lblEndereco: TLabel;
    lbProdutos: TListBox;
    lytRodape: TLayout;
    rectValores: TRectangle;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lblEntrega: TLabel;
    lblSubtotal: TLabel;
    lblTotal: TLabel;
    rectCmbStatus: TRectangle;
    lblCmbStatus: TLabel;
    Image1: TImage;
    rectBtnFinalizar: TRectangle;
    btnFinalizar: TSpeedButton;
    Label13: TLabel;
    lblStatus: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rectCmbStatusClick(Sender: TObject);
    procedure btnFinalizarClick(Sender: TObject);
  private
    cmbFiltroStatus: TCustomCombobox;
    FId_pedido: integer;
    FExecuteOnClose: TExecuteOnClose;
    procedure AddProduto(id_produto: integer;
                                       url_foto, nome, descricao, obs: string;
                                       preco: double;
                                       ind_ordenacao: boolean = false);
    procedure DetalhesPedido(id_ped: integer);

    {$IFDEF MSWINDOWS}
    procedure EditarStatusClick(Sender: TObject);
    {$ELSE}
    procedure EditarStatusClick(Sender: TObject; const PointF: TPointF);
    {$ENDIF}

    procedure SetupCombobox;
    procedure TerminateDadosPedido(Sender: TObject);
    procedure TerminateStatusPedido(Sender: TObject);
    procedure AlterarStatusPedido(id_ped: integer; status: string);

    { Private declarations }
  public
    property id_pedido: integer read FId_pedido write FId_pedido;
    property ExecuteOnClose: TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
  end;

var
  FrmPedidoDetalhe: TFrmPedidoDetalhe;

implementation

{$R *.fmx}

uses Frame.Produto, DataModule.Global;

procedure TFrmPedidoDetalhe.AddProduto(id_produto: integer;
                                       url_foto, nome, descricao, obs: string;
                                       preco: double;
                                       ind_ordenacao: boolean = false);
var
    item: TListBoxItem;
    frame: TFrameProduto;
begin
    item := TListBoxItem.Create(lbProdutos);
    item.Selectable := false;
    item.Text := '';
    item.Height := 60;
    item.Tag := id_produto;

    // Frame...
    frame := TFrameProduto.Create(item);
    frame.lblNome.Text := nome;
    frame.lblDescricao.Text := descricao;
    frame.lblPreco.Text := FormatFloat('R$ #,##0.00', preco);
    frame.imgFoto.TagString := url_foto;
    frame.imgUp.visible := ind_ordenacao;
    frame.imgDown.visible := ind_ordenacao;


    item.AddObject(frame);
    lbProdutos.AddObject(item);
end;

procedure TFrmPedidoDetalhe.TerminateStatusPedido(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    if Assigned(ExecuteOnClose) then
        ExecuteOnClose();

    close;
end;

{$IFDEF MSWINDOWS}
procedure TFrmPedidoDetalhe.EditarStatusClick(Sender: TObject);
{$ELSE}
procedure TFrmPedidoDetalhe.EditarStatusClick(Sender: TObject; const PointF: TPointF);
{$ENDIF}
var
    status: string;
begin
    cmbFiltroStatus.HideMenu;
    status := cmbFiltroStatus.CodItem;
    AlterarStatusPedido(id_pedido, status);
end;

procedure TFrmPedidoDetalhe.AlterarStatusPedido(id_ped: integer;
                                                status: string);
var
    t: TThread;
begin
    TLoading.Show(FrmPedidoDetalhe, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.EditarStatusPedidoAPI(id_ped, status);
    end);

    t.OnTerminate := TerminateStatusPedido;
    t.Start;
end;


procedure TFrmPedidoDetalhe.SetupCombobox;
begin
    cmbFiltroStatus := TCustomCombobox.Create(FrmPedidoDetalhe);
    cmbFiltroStatus.TitleMenuText := 'Alterar Status';
    cmbFiltroStatus.SubTitleMenuText := 'Escolha o status do pedido:';

    cmbFiltroStatus.BackgroundColor := $FFFFFFFF;
    cmbFiltroStatus.ItemBackgroundColor := $FFE84F3D;
    cmbFiltroStatus.ItemFontColor := $FFFFFFFF;

    cmbFiltroStatus.OnClick := EditarStatusClick;

    cmbFiltroStatus.AddItem('A', 'Aberto');
    cmbFiltroStatus.AddItem('C', 'Cancelado');
    cmbFiltroStatus.AddItem('E', 'Saiu p/ Entrega');
    cmbFiltroStatus.AddItem('F', 'Finalizado');

end;

procedure TFrmPedidoDetalhe.btnFinalizarClick(Sender: TObject);
begin
    TDialogService.MessageDialog('Deseja finalizar o pedido?',
                     TMsgDlgType.mtConfirmation,
                     [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                     TMsgDlgBtn.mbNo,
                     0,
     procedure(const AResult: TModalResult)
     begin
        if AResult = mrYes then
        begin
            AlterarStatusPedido(id_pedido, 'F');
        end;
     end);
end;


procedure TFrmPedidoDetalhe.TerminateDadosPedido(Sender: TObject);
begin
    lbProdutos.EndUpdate;
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    DownloadFotos(lbProdutos);
end;


procedure TFrmPedidoDetalhe.DetalhesPedido(id_ped: integer);
var
    t: TThread;
begin
    TLoading.Show(FrmPedidoDetalhe, 'Carregando...'); // Thread Principal..
    lbProdutos.BeginUpdate;
    lbProdutos.Items.Clear;

    t := TThread.CreateAnonymousThread(procedure
    var
        json: TJsonObject;
        itens: TJSONArray;
    begin
        json := Dm.JsonPedidoByIdAPI(id_ped);

        TThread.Synchronize(TThread.CurrentThread, procedure
        var
            i: integer;
        begin
            lblPedido.Text := 'Pedido #' + json.GetValue<string>('id_pedido', '');
            lblCliente.Text := json.GetValue<string>('fone', '');
            lblEndereco.Text := json.GetValue<string>('endereco', '');
            lblData.Text := UTCtoDateBR(json.GetValue<string>('dt_pedido', '')) + 'h';
            lblStatus.Text := json.GetValue<string>('descr_status', '');

            lblSubtotal.Text := FormatFloat('R$ #,##0.00', json.GetValue<double>('vl_subtotal', 0));
            lblEntrega.Text := FormatFloat('R$ #,##0.00', json.GetValue<double>('vl_entrega', 0));
            lblTotal.Text := FormatFloat('R$ #,##0.00', json.GetValue<double>('vl_total', 0));

            // Tratamento cor status...
            lblStatus.FontColor := json.GetValue<TAlphaColor>('cor_status');

            // Tratamento dos itens...
            itens := json.GetValue<TJSONArray>('itens');

            for i := 0 to itens.Size - 1 do
            begin
                AddProduto(itens.Get(i).GetValue<integer>('id_produto', 0),
                           itens.Get(i).GetValue<string>('foto', ''),
                           itens.Get(i).GetValue<string>('nome', ''),
                           itens.Get(i).GetValue<double>('qtd', 0).ToString + ' x ' +
                               FormatFloat('R$ #,##0.00', itens.Get(i).GetValue<double>('vl_unitario', 0)),
                           itens.Get(i).GetValue<string>('obs', ''),
                           itens.Get(i).GetValue<double>('vl_total', 0));
            end;



        end);
    end);

    t.OnTerminate := TerminateDadosPedido;
    t.Start;
end;


procedure TFrmPedidoDetalhe.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmPedidoDetalhe := nil;
end;

procedure TFrmPedidoDetalhe.FormCreate(Sender: TObject);
begin
    SetupCombobox;
end;

procedure TFrmPedidoDetalhe.FormDestroy(Sender: TObject);
begin
    cmbFiltroStatus.DisposeOf;
end;

procedure TFrmPedidoDetalhe.FormShow(Sender: TObject);
begin
    DetalhesPedido(id_pedido);
end;

procedure TFrmPedidoDetalhe.imgFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmPedidoDetalhe.rectCmbStatusClick(Sender: TObject);
begin
    cmbFiltroStatus.ShowMenu;
end;

end.
