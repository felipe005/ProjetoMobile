unit UnitCheckout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit, FMX.ListBox,
  FMX.TabControl, uFunctions, uLoading, System.JSON, uSession;

type
  TFrmCheckout = class(TForm)
    rectToolbar2: TRectangle;
    Label1: TLabel;
    imgVoltar: TImage;
    rectTotal: TRectangle;
    rectFinalizar: TRectangle;
    btnFinalizar: TSpeedButton;
    rectEndereco: TRectangle;
    Layout1: TLayout;
    Label2: TLabel;
    lblSubtotal: TLabel;
    Layout2: TLayout;
    Label4: TLabel;
    lblEntrega: TLabel;
    Layout3: TLayout;
    Label6: TLabel;
    lblTotal: TLabel;
    Label8: TLabel;
    edtWhatsApp: TEdit;
    Label9: TLabel;
    edtEndereco: TEdit;
    lbCardapio: TListBox;
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Image1: TImage;
    Label10: TLabel;
    imgFechar: TImage;
    btnLimpar: TSpeedButton;
    TabItem3: TTabItem;
    imgFecharVazia: TImage;
    Image3: TImage;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure imgVoltarClick(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure btnFinalizarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnLimparClick(Sender: TObject);
    procedure imgFecharVaziaClick(Sender: TObject);
  private
    procedure AddProduto(id_produto: integer;
                                  url_foto, nome, obs: string;
                                  qtd: integer;
                                  vl_unitario: double);
    procedure CarregarSacola;
    procedure DownloadFoto(lb: TListBox);
    procedure ThreadPedidoTerminate(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCheckout: TFrmCheckout;

implementation

{$R *.fmx}

uses Frame.Produto, DataModule.Global;

procedure TFrmCheckout.AddProduto(id_produto: integer;
                                  url_foto, nome, obs: string;
                                  qtd: integer;
                                  vl_unitario: double);
var
    item: TListBoxItem;
    frame: TFrameProduto;
begin
    item := TListBoxItem.Create(lbCardapio);
    item.Selectable := false;
    item.Text := '';
    item.Height := 100;
    item.Tag := id_produto;

    // Frame...
    frame := TFrameProduto.Create(item);
    frame.imgFoto.TagString := url_foto;
    frame.lblNome.Text := nome;
    frame.lblDescricao.Text := FormatFloat('00', qtd) + ' x ' +
                               FormatFloat('R$ #,##0.00', vl_unitario) + sLineBreak +
                               obs;
    frame.lblPreco.Text := FormatFloat('R$ #,##0.00', vl_unitario * qtd);
    item.AddObject(frame);

    lbCardapio.AddObject(item);
end;

procedure TFrmCheckout.DownloadFoto(lb: TListBox);
var
    t: TThread;
    foto: TBitmap;
    frame: TFrameProduto;
begin
    // Carregar imagens...
    t := TThread.CreateAnonymousThread(procedure
    var
        i : integer;
    begin

        for i := 0 to lb.Items.Count - 1 do
        begin
            //sleep(1000);
            frame := TFrameProduto(lb.ItemByIndex(i).Components[0]);

            // TagString = URL da foto...
            if frame.imgFoto.TagString <> '' then
            begin
                foto := TBitmap.Create;
                LoadImageFromURL(foto, frame.imgFoto.TagString);

                //frame.imgFoto.TagString := '';
                frame.imgFoto.bitmap := foto;
            end;
        end;

    end);

    t.Start;
end;

procedure TFrmCheckout.ThreadPedidoTerminate(Sender: TObject);
begin
    TLoading.Hide;

     if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    Dm.LimparSacolaLocal;
    Dm.EditarConfigLocal(lblEntrega.TagFloat);
    Dm.EditarUsuarioLocal(TSession.ID_USUARIO, edtWhatsApp.Text, edtEndereco.Text);

    TabControl.GotoVisibleTab(1);
end;

procedure TFrmCheckout.btnFinalizarClick(Sender: TObject);
var
    t: TThread;
    jsonPedido: TJsonObject;
begin
    TLoading.show(FrmCheckout, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        try
            jsonPedido := Dm.JsonPedido(TSession.ID_USUARIO,
                                      edtWhatsApp.Text,
                                      edtEndereco.Text,
                                      lblSubtotal.TagFloat,
                                      lblEntrega.TagFloat,
                                      lblTotal.TagFloat);

            jsonPedido.AddPair('itens', Dm.JsonPedidoItem());

            Dm.FinalizarPedido(jsonPedido);

        finally
            jsonPedido.DisposeOf;
        end;
    end);

    t.OnTerminate := ThreadPedidoTerminate;
    t.Start;
end;

procedure TFrmCheckout.btnLimparClick(Sender: TObject);
begin
    try
        Dm.LimparSacolaLocal;
        close;
    except on ex:exception do
        showmessage('Erro ao limpar dados: ' + ex.Message);
    end;
end;

procedure TFrmCheckout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmCheckout := nil;
end;

procedure TFrmCheckout.CarregarSacola;
var
    subtotal: double;
begin
    try
        Dm.ListarConfigLocal;
        Dm.ListarSacolaLocal;
        Dm.ListarUsuarioLocal;

        // Dados Config...
        lblEntrega.Text := FormatFloat('R$ #,##0.00', Dm.qryConfig.FieldByName('vl_entrega').AsFloat);
        lblEntrega.TagFloat := Dm.qryConfig.FieldByName('vl_entrega').AsFloat;
        edtWhatsApp.Text := Dm.qryUsuario.FieldByName('fone').AsString;
        edtEndereco.Text := Dm.qryUsuario.FieldByName('endereco').AsString;

        // Itens Carrinho...
        subtotal := 0;
        lbCardapio.Items.Clear;
        with Dm.qrySacola do
        begin
            While NOT Eof do
            begin
                AddProduto(FieldByName('id_produto').AsInteger,
                           FieldByName('foto').AsString,
                           FieldByName('nome').AsString,
                           FieldByName('obs').AsString,
                           FieldByName('qtd').AsInteger,
                           FieldByName('vl_unitario').AsFloat);

                subtotal := subtotal + FieldByName('vl_total').AsFloat;

                Next;
            end;
        end;

        // Valores...
        lblSubtotal.Text := FormatFloat('R$ #,##0.00', subtotal);
        lblSubtotal.TagFloat := subtotal;
        lblTotal.Text := FormatFloat('R$ #,##0.00', subtotal + lblEntrega.TagFloat);
        lblTotal.TagFloat := subtotal + lblEntrega.TagFloat;


        // Fotos dos produtos...
        DownloadFoto(lbCardapio);

        // Trata sacola vazia...
        if lbCardapio.Items.Count = 0 then
            TabControl.GotoVisibleTab(2);

    except on ex:exception do
        showmessage('Erro ao carregar itens: ' + ex.Message);
    end;
end;

procedure TFrmCheckout.FormShow(Sender: TObject);
begin
    TabControl.GotoVisibleTab(0);
    CarregarSacola;
end;

procedure TFrmCheckout.imgFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmCheckout.imgFecharVaziaClick(Sender: TObject);
begin
    close;
end;

procedure TFrmCheckout.imgVoltarClick(Sender: TObject);
begin
    close;
end;

end.
