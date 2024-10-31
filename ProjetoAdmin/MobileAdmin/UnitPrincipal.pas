unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Ani,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Layouts, uCombobox, uLoading, uFunctions;

type
  TFrmPrincipal = class(TForm)
    rectAbas: TRectangle;
    imgAba1: TImage;
    imgAba2: TImage;
    imgAba3: TImage;
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Image4: TImage;
    Rectangle2: TRectangle;
    Label2: TLabel;
    Image5: TImage;
    Rectangle3: TRectangle;
    Label3: TLabel;
    Image6: TImage;
    rectIndicador: TRectangle;
    lvPedidos: TListView;
    imgPedido: TImage;
    imgData: TImage;
    imgEndereco: TImage;
    imgFone: TImage;
    imgValor: TImage;
    imgAberto: TImage;
    ImgEntrega: TImage;
    imgCancelado: TImage;
    ImgFinalizado: TImage;
    rectFiltro: TRectangle;
    rectBtnFiltro: TRectangle;
    btnFiltrar: TSpeedButton;
    rectFiltroData: TRectangle;
    lblFiltroData: TLabel;
    Image1: TImage;
    rectFiltroStatus: TRectangle;
    lblFiltroStatus: TLabel;
    Image2: TImage;
    imgAddCategoria: TImage;
    lvCardapio: TListView;
    imgMais: TImage;
    imgMenu: TImage;
    rectFundoCardapio: TRectangle;
    lytMenuCardapio: TLayout;
    rectMenuCardapio: TRectangle;
    btnCima: TSpeedButton;
    btnBaixo: TSpeedButton;
    btnProdutos: TSpeedButton;
    btnCancelar: TSpeedButton;
    Line1: TLine;
    rectItemConfig: TRectangle;
    Image3: TImage;
    Label6: TLabel;
    Image7: TImage;
    rectItemLogout: TRectangle;
    Image8: TImage;
    Label7: TLabel;
    Image9: TImage;
    procedure imgAba1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvCardapioItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure btnCancelarClick(Sender: TObject);
    procedure rectItemConfigClick(Sender: TObject);
    procedure rectItemLogoutClick(Sender: TObject);
    procedure lvPedidosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure btnProdutosClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rectFiltroDataClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rectFiltroStatusClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCimaClick(Sender: TObject);
    procedure btnBaixoClick(Sender: TObject);
    procedure imgAddCategoriaClick(Sender: TObject);
  private
    cmbFiltroData, cmbFiltroStatus: TCustomCombobox;

    procedure MudarAba(img: TImage);
    procedure SetupAbas;
    procedure AddPedido(id_pedido: integer; dt_pedido, fone, endereco,
                        status: string; vl_total: double);
    function ImagemStatus(status: string): TBitmap;
    procedure AddCategoria(id_categoria: integer; descricao: string);
    procedure ListarCategorias;

    {$IFDEF MSWINDOWS}
    procedure FiltroDataClick(Sender: TObject);
    {$ELSE}
    procedure FiltroDataClick(Sender: TObject; const PointF: TPointF);
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    procedure FiltroStatusClick(Sender: TObject);
    {$ELSE}
    procedure FiltroStatusClick(Sender: TObject; const PointF: TPointF);
    {$ENDIF}



    procedure SetupCombobox;
    procedure TerminateListarPedido(Sender: TObject);
    procedure TerminateListarCategoria(Sender: TObject);
    procedure ListarPedidos();
    procedure OrdenarCategoria(id_categoria: integer; up_down: string);
    procedure TerminateOrdenarCategoria(Sender: TObject);
  public

  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses UnitConfiguracoes, UnitPedidoDetalhe, UnitCategoria, UnitCategoriaProd,
  DataModule.Global, UnitLogin;

function TFrmPrincipal.ImagemStatus(status: string): TBitmap;
begin
    if (status = 'A') then
        Result := imgAberto.Bitmap
    else if (status = 'C') then
        Result := imgCancelado.Bitmap
    else if (status = 'E') then
        Result := ImgEntrega.Bitmap
    else
        Result := ImgFinalizado.Bitmap;
end;

procedure TFrmPrincipal.AddPedido(id_pedido: integer;
                                  dt_pedido, fone, endereco, status: string;
                                  vl_total: double);
var
    item: TListViewItem;
begin
    item := lvPedidos.Items.Add;
    item.Height := 110;
    item.Tag := id_pedido;

    TListItemText(item.Objects.FindDrawable('txtPedido')).Text := 'Pedido ' + id_pedido.ToString;
    TListItemText(item.Objects.FindDrawable('txtData')).Text := dt_pedido;
    TListItemText(item.Objects.FindDrawable('txtFone')).Text := fone;
    TListItemText(item.Objects.FindDrawable('txtEndereco')).Text := endereco;
    TListItemText(item.Objects.FindDrawable('txtValor')).Text := FormatFloat('R$ #,##0.00', vl_total);

    TListItemImage(item.Objects.FindDrawable('imgPedido')).Bitmap := imgPedido.Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgData')).Bitmap := imgData.Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgFone')).Bitmap := imgFone.Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgEndereco')).Bitmap := imgEndereco.Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgValor')).Bitmap := imgValor.Bitmap;

    TListItemImage(item.Objects.FindDrawable('imgStatus')).Bitmap := ImagemStatus(status);
end;

procedure TFrmPrincipal.btnCancelarClick(Sender: TObject);
begin
    lytMenuCardapio.Visible := false;
end;

procedure TFrmPrincipal.OrdenarCategoria(id_categoria: integer;
                                         up_down: string);
var
    t: TThread;
begin
    lytMenuCardapio.Visible := false;
    TLoading.Show(FrmPrincipal, ''); // Thread Principal..

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.OrdenarCategoriaAPI(id_categoria, up_down);

    end);

    t.OnTerminate := TerminateOrdenarCategoria;
    t.Start;
end;

procedure TFrmPrincipal.btnBaixoClick(Sender: TObject);
begin
    OrdenarCategoria(lytMenuCardapio.Tag, 'DOWN');
end;

procedure TFrmPrincipal.btnCimaClick(Sender: TObject);
begin
    OrdenarCategoria(lytMenuCardapio.Tag, 'UP');
end;

procedure TFrmPrincipal.btnFiltrarClick(Sender: TObject);
begin
    ListarPedidos();
end;

procedure TFrmPrincipal.btnProdutosClick(Sender: TObject);
begin
    if NOT Assigned(FrmCategoriaProd) then
        Application.CreateForm(TFrmCategoriaProd, FrmCategoriaProd);

    lytMenuCardapio.Visible := false;

    FrmCategoriaProd.id_categoria := lytMenuCardapio.Tag;
    FrmCategoriaProd.categoria := lytMenuCardapio.TagString;
    FrmCategoriaProd.Show;
end;

procedure TFrmPrincipal.AddCategoria(id_categoria: integer; descricao: string);
var
    item: TListViewItem;
begin
    item := lvCardapio.Items.Add;
    item.Height := 50;
    item.Tag := id_categoria;

    TListItemText(item.Objects.FindDrawable('txtDescricao')).Text := descricao;
    TListItemImage(item.Objects.FindDrawable('imgMais')).Bitmap := imgMais.Bitmap;

    TListItemImage(item.Objects.FindDrawable('imgMenu')).Bitmap := imgMenu.Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgMenu')).TagFloat := id_categoria;
    TListItemImage(item.Objects.FindDrawable('imgMenu')).TagString := descricao;
end;

procedure TFrmPrincipal.TerminateOrdenarCategoria(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    ListarCategorias;
end;

procedure TFrmPrincipal.TerminateListarPedido(Sender: TObject);
begin
    lvPedidos.EndUpdate;
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;
end;

procedure TFrmPrincipal.TerminateListarCategoria(Sender: TObject);
begin
    lvCardapio.EndUpdate;
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;
end;


procedure TFrmPrincipal.ListarPedidos();
var
    t: TThread;
    dt_de, dt_ate, status: string;
begin
    // Verifica filtro...
    dt_de := '';
    dt_ate := '';
    status := rectFiltroStatus.TagString;


    if (rectFiltroData.TagString = 'Pedidos Hoje') then
    begin
        dt_de := FormatDateTime('yyyy-mm-dd', now);
        dt_ate := FormatDateTime('yyyy-mm-dd', now);
    end
    else if (rectFiltroData.TagString = 'Pedidos Ontem') then
    begin
        dt_de := FormatDateTime('yyyy-mm-dd', now - 1);
        dt_ate := FormatDateTime('yyyy-mm-dd', now - 1);
    end
    else if (rectFiltroData.TagString = 'Últimos 7 dias') then
    begin
        dt_de := FormatDateTime('yyyy-mm-dd', now - 7);
        dt_ate := FormatDateTime('yyyy-mm-dd', now);
    end
    else if (rectFiltroData.TagString = 'Últimos 30 dias') then
    begin
        dt_de := FormatDateTime('yyyy-mm-dd', now - 30);
        dt_ate := FormatDateTime('yyyy-mm-dd', now);
    end;
    //------------------



    TLoading.Show(FrmPrincipal, 'Carregando...'); // Thread Principal..
    lvPedidos.BeginUpdate;
    lvPedidos.Items.Clear;

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.ListarPedidosAPI(dt_de, dt_ate, status);

        TThread.Synchronize(TThread.CurrentThread, procedure
        begin

            with Dm.TabPedido do
            begin
                while NOT eof do
                begin
                    AddPedido(fieldbyname('id_pedido').AsInteger,
                             UTCtoDateBR(fieldbyname('dt_pedido').asstring),
                             fieldbyname('fone').asstring,
                             fieldbyname('endereco').asstring,
                             fieldbyname('status').asstring,
                             fieldbyname('vl_total').AsFloat);
                    Next;
                end;
            end;
        end);

    end);

    t.OnTerminate := TerminateListarPedido;
    t.Start;
end;

procedure TFrmPrincipal.lvCardapioItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
    if ItemObject <> nil then
        if ItemObject.Name = 'imgMenu' then
        begin
            lytMenuCardapio.Tag := Trunc(ItemObject.TagFloat); // id_categoria
            lytMenuCardapio.TagString := ItemObject.TagString; // descricao categoria
            lytMenuCardapio.Visible := true;
            exit;
        end;

    // Abre cadastro das categorias/menu
    if NOT Assigned(FrmCategoria) then
        application.CreateForm(TFrmCategoria, FrmCategoria);

    FrmCategoria.ExecuteOnClose := ListarCategorias;
    FrmCategoria.id_categoria := lvCardapio.Items[ItemIndex].Tag;
    FrmCategoria.Show;
end;

procedure TFrmPrincipal.lvPedidosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
    if NOT Assigned(FrmPedidoDetalhe) then
        application.CreateForm(TFrmPedidoDetalhe, FrmPedidoDetalhe);

    FrmPedidoDetalhe.ExecuteOnClose := ListarPedidos;
    FrmPedidoDetalhe.id_pedido := Aitem.Tag;
    FrmPedidoDetalhe.Show;
end;


procedure TFrmPrincipal.ListarCategorias;
var
    t: TThread;
begin
    TLoading.Show(FrmPrincipal, 'Carregando...'); // Thread Principal..
    lvCardapio.BeginUpdate;
    lvCardapio.Items.Clear;

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.ListarCategoriasAPI();

        TThread.Synchronize(TThread.CurrentThread, procedure
        begin
            while NOT Dm.TabCategoria.eof do
            begin
                AddCategoria(Dm.TabCategoria.FieldByName('id_categoria').AsInteger,
                             Dm.TabCategoria.FieldByName('categoria').AsString);

                Dm.TabCategoria.Next;
            end;
        end);

    end);

    t.OnTerminate := TerminateListarCategoria;
    t.Start;
end;


procedure TFrmPrincipal.MudarAba(img: TImage);
begin
    imgAba1.Opacity := 0.5;
    imgAba2.Opacity := 0.5;
    imgAba3.Opacity := 0.5;
    img.Opacity := 1;

    TAnimator.AnimateFloat(rectIndicador, 'Position.x',
                           img.position.x, 0.2, TAnimationType.InOut,
                           TInterpolationType.Circular);

    TabControl.GotoVisibleTab(img.Tag); // Tag contem o indice da aba

    if img.Tag = 1 then
        ListarCategorias;
end;

procedure TFrmPrincipal.rectFiltroDataClick(Sender: TObject);
begin
    cmbFiltroData.ShowMenu;
end;

procedure TFrmPrincipal.rectFiltroStatusClick(Sender: TObject);
begin
    cmbFiltroStatus.ShowMenu;
end;

procedure TFrmPrincipal.rectItemConfigClick(Sender: TObject);
begin
    if NOT Assigned(FrmConfiguracoes) then
        Application.CreateForm(TFrmConfiguracoes, FrmConfiguracoes);

    FrmConfiguracoes.Show;
end;

procedure TFrmPrincipal.rectItemLogoutClick(Sender: TObject);
begin
    Dm.ExcluirUsuarioMobile;

    if NOT Assigned(FrmLogin) then
        Application.CreateForm(TFrmLogin, FrmLogin);

    Application.MainForm := FrmLogin;
    FrmLogin.Show;

    FrmPrincipal.Close;
end;

procedure TFrmPrincipal.SetupAbas;
begin
    rectIndicador.Width := imgAba1.Width;

    if TabControl.TabIndex = 0 then
        rectIndicador.Position.X := imgAba1.Position.x
    else if TabControl.TabIndex = 1 then
        rectIndicador.Position.X := imgAba2.Position.x
    else
        rectIndicador.Position.X := imgAba3.Position.x;
end;

{$IFDEF MSWINDOWS}
procedure TFrmPrincipal.FiltroDataClick(Sender: TObject);
{$ELSE}
procedure TFrmPrincipal.FiltroDataClick(Sender: TObject; const PointF: TPointF);
{$ENDIF}
begin
    cmbFiltroData.HideMenu;

    if cmbFiltroData.CodItem <> 'Limpar Filtro' then
    begin
        rectFiltroData.TagString := cmbFiltroData.CodItem; // Pedidos Hoje, Pedidos Ontem...
        lblFiltroData.Text := cmbFiltroData.DescrItem;
    end
    else
    begin
        rectFiltroData.TagString := '';
        lblFiltroData.Text := 'Filtrar por data';
    end;
end;

{$IFDEF MSWINDOWS}
procedure TFrmPrincipal.FiltroStatusClick(Sender: TObject);
{$ELSE}
procedure TFrmPrincipal.FiltroStatusClick(Sender: TObject; const PointF: TPointF);
{$ENDIF}
begin
    cmbFiltroStatus.HideMenu;

    if cmbFiltroStatus.CodItem <> 'Limpar Filtro' then
    begin
        rectFiltroStatus.TagString := cmbFiltroStatus.CodItem;
        lblFiltroStatus.Text := cmbFiltroStatus.DescrItem;
    end
    else
    begin
        rectFiltroStatus.TagString := '';
        lblFiltroStatus.Text := 'Filtrar por status';
    end;
end;

procedure TFrmPrincipal.SetupCombobox;
begin
    cmbFiltroData := TCustomCombobox.Create(FrmPrincipal);
    cmbFiltroData.TitleMenuText := 'Filtro por Data';
    cmbFiltroData.SubTitleMenuText := 'Escolha uma das opções abaixo:';

    cmbFiltroData.BackgroundColor := $FFFFFFFF;
    cmbFiltroData.ItemBackgroundColor := $FFE84F3D;
    cmbFiltroData.ItemFontColor := $FFFFFFFF;

    cmbFiltroData.OnClick := FiltroDataClick;

    cmbFiltroData.AddItem('Pedidos Hoje', 'Pedidos Hoje');
    cmbFiltroData.AddItem('Pedidos Ontem', 'Pedidos Ontem');
    cmbFiltroData.AddItem('Últimos 7 dias', 'Últimos 7 dias');
    cmbFiltroData.AddItem('Últimos 30 dias', 'Últimos 30 dias');
    cmbFiltroData.AddItem('Limpar Filtro', 'Limpar Filtro');

    //------

    cmbFiltroStatus := TCustomCombobox.Create(FrmPrincipal);
    cmbFiltroStatus.TitleMenuText := 'Filtro por Status';
    cmbFiltroStatus.SubTitleMenuText := 'Escolha uma das opções abaixo:';

    cmbFiltroStatus.BackgroundColor := $FFFFFFFF;
    cmbFiltroStatus.ItemBackgroundColor := $FFE84F3D;
    cmbFiltroStatus.ItemFontColor := $FFFFFFFF;

    cmbFiltroStatus.OnClick := FiltroStatusClick;

    cmbFiltroStatus.AddItem('A', 'Aberto');
    cmbFiltroStatus.AddItem('C', 'Cancelado');
    cmbFiltroStatus.AddItem('E', 'Entrega');
    cmbFiltroStatus.AddItem('F', 'Finalizado');
    cmbFiltroStatus.AddItem('Limpar Filtro', 'Limpar Filtro');


end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmPrincipal := nil;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
    SetupCombobox;
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
    cmbFiltroData.DisposeOf;
    cmbFiltroStatus.DisposeOf;
end;

procedure TFrmPrincipal.FormResize(Sender: TObject);
begin
    SetupAbas;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
    SetupAbas;
    MudarAba(imgAba1);
    ListarPedidos();
end;

procedure TFrmPrincipal.imgAba1Click(Sender: TObject);
begin
    MudarAba(TImage(Sender));
end;

procedure TFrmPrincipal.imgAddCategoriaClick(Sender: TObject);
begin
    // Abre cadastro das categorias/menu
    if NOT Assigned(FrmCategoria) then
        application.CreateForm(TFrmCategoria, FrmCategoria);

    FrmCategoria.ExecuteOnClose := ListarCategorias;
    FrmCategoria.id_categoria := 0;
    FrmCategoria.Show;
end;

end.
