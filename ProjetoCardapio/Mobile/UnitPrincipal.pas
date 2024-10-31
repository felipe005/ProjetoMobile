unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox,
  uLoading, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, uFunctions, uSession, System.JSON;

type
  TFrmPrincipal = class(TForm)
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    rectAbas: TRectangle;
    img1: TImage;
    img2: TImage;
    img3: TImage;
    rectToobar1: TRectangle;
    Image1: TImage;
    imgSacola: TImage;
    rectToolbar2: TRectangle;
    Label1: TLabel;
    Rectangle1: TRectangle;
    Label2: TLabel;
    lbCardapio: TListBox;
    lvPedidos: TListView;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    Image3: TImage;
    Label3: TLabel;
    Image4: TImage;
    lbiLogout: TListBoxItem;
    Image5: TImage;
    Label4: TLabel;
    Image6: TImage;
    Line1: TLine;
    Line2: TLine;
    lytProduto: TLayout;
    rectFundo: TRectangle;
    rectProduto: TRectangle;
    imgFecharProd: TImage;
    imgProduto: TImage;
    Layout1: TLayout;
    lblNome: TLabel;
    lblPreco: TLabel;
    lblDescricao: TLabel;
    Label5: TLabel;
    mObs: TMemo;
    lytProdutoBotoes: TLayout;
    imgMenos: TImage;
    imgMais: TImage;
    lblQtd: TLabel;
    rectSacola: TRectangle;
    btnSacola: TSpeedButton;
    procedure img1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbCardapioItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure imgFecharProdClick(Sender: TObject);
    procedure imgSacolaClick(Sender: TObject);
    procedure lvPedidosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure imgMenosClick(Sender: TObject);
    procedure btnSacolaClick(Sender: TObject);
    procedure lbiLogoutClick(Sender: TObject);
  private
    procedure MudarAba(img: TImage);
    procedure AddProduto(id_produto: integer;
                                   url_foto, nome, descricao: string;
                                   preco: double);
    procedure ListarProdutos;
    procedure AddCategoria(id_categoria: integer; categoria: string);
    procedure ThreadProdutosTerminate(Sender: TObject);
    procedure AddPedido(id_pedido: integer;
                                  dt_pedido: string;
                                  vl_total: double;
                                  jsonStr: string);
    procedure ListarPedidos;
    procedure ThreadPedidosTerminate(Sender: TObject);
    procedure OpenProduto(Item: TListBoxItem);
    procedure CloseProduto;
    procedure OpenDetalhePedido(jsonPedido: string);
    procedure Qtd(valor: integer);
    procedure DownloadFoto(lb: TListBox);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses Frame.Produto, Frame.Categoria, UnitCheckout, UnitPedido,
  DataModule.Global, UnitLogin;

procedure TFrmPrincipal.AddPedido(id_pedido: integer;
                                  dt_pedido: string;
                                  vl_total: double;
                                  jsonStr: string);
var
    item: TListViewItem;
    txt: TListItemText;
begin
    item := lvPedidos.Items.Add;
    item.Height := 60;
    item.Tag := id_pedido;
    item.TagString := jsonStr;

    txt := TListItemText(item.Objects.FindDrawable('txtPedido'));
    txt.Text := 'Pedido ' + id_pedido.ToString;

    txt := TListItemText(item.Objects.FindDrawable('txtData'));
    txt.Text := dt_pedido;

    txt := TListItemText(item.Objects.FindDrawable('txtValor'));
    txt.Text := FormatFloat('R$ #,##0.00', vl_total);
end;

procedure TFrmPrincipal.AddProduto(id_produto: integer;
                                   url_foto, nome, descricao: string;
                                   preco: double);
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
    frame.lblDescricao.Text := descricao;
    frame.lblPreco.Text := FormatFloat('R$ #,##0.00', preco);
    frame.lblPreco.TagFloat := preco;
    item.AddObject(frame);

    lbCardapio.AddObject(item);
end;

procedure TFrmPrincipal.btnSacolaClick(Sender: TObject);
begin
    try
        Dm.AdicionarCarrinhoLocal(imgProduto.Tag,
                                  lblNome.Text,
                                  lblDescricao.Text,
                                  imgProduto.TagString,
                                  mObs.Text,
                                  lblQtd.Tag,
                                  lblPreco.TagFloat);

        CloseProduto;
    except on ex:exception do
        showmessage('Erro ao salvar produto: ' + ex.Message);
    end;
end;

procedure TFrmPrincipal.AddCategoria(id_categoria: integer;
                                   categoria: string);
var
    item: TListBoxItem;
    frame: TFrameCategoria;
begin
    item := TListBoxItem.Create(lbCardapio);
    item.Selectable := false;
    item.Text := '';
    item.Height := 45;
    item.Tag := 0;

    // Frame...
    frame := TFrameCategoria.Create(item);
    frame.lblCategoria.Text := categoria;
    item.AddObject(frame);

    lbCardapio.AddObject(item);
end;

procedure TFrmPrincipal.DownloadFoto(lb: TListBox);
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

procedure TFrmPrincipal.ThreadProdutosTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    // Carregar as fotos...
    DownloadFoto(lbCardapio);

    // Buscar configs do app...
    try
        Dm.ListarConfig;
        Dm.EditarConfigLocal(Dm.TabConfig.FieldByName('vl_entrega').AsFloat);
    except on ex:exception do
        showmessage(ex.Message);
    end;
end;

procedure TFrmPrincipal.ThreadPedidosTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
            showmessage(Exception(TThread(sender).FatalException).Message);
end;

procedure TFrmPrincipal.ListarProdutos;
var
    t: TThread;
    categoria_anterior: string;
begin
    categoria_anterior := '';
    lbCardapio.Items.Clear;
    TLoading.Show(FrmPrincipal, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.ListarProdutos;

        while NOT Dm.TabProduto.Eof do
        begin
            TThread.Synchronize(TThread.CurrentThread, procedure
            begin
                if Dm.TabProduto.FieldByName('categoria').AsString <> categoria_anterior then
                    AddCategoria(Dm.TabProduto.FieldByName('id_categoria').AsInteger,
                                 Dm.TabProduto.FieldByName('categoria').AsString);

                AddProduto(Dm.TabProduto.FieldByName('id_produto').AsInteger,
                           Dm.TabProduto.FieldByName('foto').AsString,
                           Dm.TabProduto.FieldByName('nome').AsString,
                           Dm.TabProduto.FieldByName('descricao').AsString,
                           Dm.TabProduto.FieldByName('preco').AsFloat);
            end);

            categoria_anterior := Dm.TabProduto.FieldByName('categoria').AsString;
            Dm.TabProduto.Next;
        end;

    end);

    t.OnTerminate := ThreadProdutosTerminate;
    t.Start;

end;

procedure TFrmPrincipal.OpenDetalhePedido(jsonPedido: string);
begin
    if NOT Assigned(FrmPedido) then
        Application.CreateForm(TFrmPedido, FrmPedido);

    FrmPedido.json := TJSONObject.ParseJSONValue(TEncoding.UTF8.getbytes(jsonPedido), 0)
                      as TJSONObject;
    FrmPedido.Show;
end;

procedure TFrmPrincipal.lvPedidosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
    OpenDetalhePedido(AItem.Tagstring); // Passando json completo do pedido
end;

procedure TFrmPrincipal.ListarPedidos;
var
    t: TThread;
begin
    lvPedidos.Items.Clear;
    TLoading.Show(FrmPrincipal, '');

    t := TThread.CreateAnonymousThread(procedure
    var
        i: integer;
        json: TJsonArray;
    begin
        json := Dm.ListarPedidos(TSession.ID_USUARIO);

        for i := 0 to json.Size - 1 do
        begin
            TThread.Synchronize(TThread.CurrentThread, procedure
            begin
                AddPedido(json[i].GetValue<integer>('id_pedido', 0),
                          json[i].GetValue<string>('dt_pedido', ''),
                          json[i].GetValue<double>('vl_total', 0),
                          json[i].ToJSON);
            end);
        end;

    end);

    t.OnTerminate := ThreadPedidosTerminate;
    t.Start;
end;

procedure TFrmPrincipal.MudarAba(img: TImage);
begin
    img1.Opacity := 0.5;
    img2.Opacity := 0.5;
    img3.Opacity := 0.5;

    img.Opacity := 1;
    TabControl.GotoVisibleTab(img.Tag);

    if img.Tag = 1 then // Aba Pedidos...
        ListarPedidos;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
    CloseProduto;
    MudarAba(img1);
    ListarProdutos;
end;

procedure TFrmPrincipal.img1Click(Sender: TObject);
begin
    MudarAba(TImage(Sender));
end;

procedure TFrmPrincipal.imgFecharProdClick(Sender: TObject);
begin
    CloseProduto;
end;

procedure TFrmPrincipal.Qtd(valor: integer);
begin
    lblQtd.Tag := lblQtd.Tag + valor;

    if lblQtd.Tag < 1 then
        lblQtd.Tag := 1;

    lblQtd.Text := FormatFloat('00', lblQtd.Tag);
    btnSacola.Text := 'Adicionar a Sacola (R$ ' +
                      FormatFloat('#,##0.00', lblPreco.TagFloat * lblQtd.Tag) + ')';
end;

procedure TFrmPrincipal.imgMenosClick(Sender: TObject);
begin
    Qtd(TImage(Sender).Tag);
end;

procedure TFrmPrincipal.imgSacolaClick(Sender: TObject);
begin
    if NOT Assigned(FrmCheckout) then
        Application.CreateForm(TFrmCheckout, FrmCheckout);

    FrmCheckout.Show;
end;

procedure TFrmPrincipal.OpenProduto(Item: TListBoxItem);
var
    frame: TFrameProduto;
begin
    frame := TFrameProduto(Item.Components[0]);

    imgProduto.Bitmap := frame.imgFoto.Bitmap;
    imgProduto.Tag := Item.Tag; /// id_produto
    imgProduto.TagString := frame.imgFoto.TagString;
    lblNome.Text := frame.lblNome.Text;
    lblPreco.Text := frame.lblPreco.Text;
    lblPreco.TagFloat := frame.lblPreco.TagFloat;
    lblQtd.Text := '01';
    lblQtd.Tag := 1;
    lblDescricao.Text := frame.lblDescricao.Text;
    btnSacola.Text := 'Adicionar a Sacola (R$ ' + FormatFloat('#,##0.00', lblPreco.TagFloat) + ')';
    mObs.Lines.Clear;

    lytProduto.Visible := true;
end;

procedure TFrmPrincipal.CloseProduto;
begin
    lytProduto.Visible := false;
end;

procedure TFrmPrincipal.lbCardapioItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    if Item.Tag > 0 then // Clique na categoria nao aciona nada...
        OpenProduto(Item);

end;

procedure TFrmPrincipal.lbiLogoutClick(Sender: TObject);
begin
    Dm.LimparSacolaLocal;
    Dm.LimparUsuarioLocal;

    TSession.ID_USUARIO := 0;
    TSession.FONE := '';
    TSession.ENDERECO := '';

    Application.MainForm := FrmLogin;
    FrmLogin.Show;
    FrmPrincipal.Close;
end;

end.
