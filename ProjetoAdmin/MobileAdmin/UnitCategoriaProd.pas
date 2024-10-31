unit UnitCategoriaProd;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox,
  uLoading, uFunctions;

type
  TFrmCategoriaProd = class(TForm)
    rectToolBar: TRectangle;
    lblTitulo: TLabel;
    imgFechar: TImage;
    imgAdd: TImage;
    lbProdutos: TListBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbProdutosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure imgAddClick(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
  private
    FId_categoria: integer;
    FCategoria: string;
    procedure AddProduto(id_produto: integer;
                                       url_foto, nome, descricao, obs: string;
                                       preco: double;
                                       ind_ordenacao: boolean = true);
    procedure ListarProdutos;
    procedure TerminateProduto(Sender: TObject);
    procedure OrdenarProduto(id_produto: integer; up_down: string);
    procedure TerminateOrdenarProduto(Sender: TObject);
    procedure ReordenarProduto(Sender: TObject);
    { Private declarations }
  public
    property id_categoria: integer read FId_categoria write FId_categoria;
    property categoria: string read FCategoria write FCategoria;
  end;

var
  FrmCategoriaProd: TFrmCategoriaProd;

implementation

{$R *.fmx}

uses Frame.Produto, UnitCategoriaProdCad, DataModule.Global;

procedure TFrmCategoriaProd.AddProduto(id_produto: integer;
                                       url_foto, nome, descricao, obs: string;
                                       preco: double;
                                       ind_ordenacao: boolean = true);
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
    frame.imgUp.OnClick := ReordenarProduto;
    frame.imgUp.Tag := id_produto;
    frame.imgUp.TagString := 'UP';

    frame.imgDown.visible := ind_ordenacao;
    frame.imgDown.OnClick := ReordenarProduto;
    frame.imgDown.Tag := id_produto;
    frame.imgDown.TagString := 'DOWN';

    item.AddObject(frame);
    lbProdutos.AddObject(item);
end;

procedure TFrmCategoriaProd.ReordenarProduto(Sender: TObject);
begin
    OrdenarProduto(TImage(Sender).Tag, TImage(Sender).TagString);
end;


procedure TFrmCategoriaProd.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmCategoriaProd := nil;
end;

procedure TFrmCategoriaProd.FormShow(Sender: TObject);
begin
    ListarProdutos;
    lblTitulo.Text := categoria;
end;

procedure TFrmCategoriaProd.imgAddClick(Sender: TObject);
begin
    if NOT Assigned(FrmCategoriaProdCad) then
        Application.CreateForm(TFrmCategoriaProdCad, FrmCategoriaProdCad);

    FrmCategoriaProdCad.ExecuteOnClose := ListarProdutos;
    FrmCategoriaProdCad.id_categoria := id_categoria;
    FrmCategoriaProdCad.categoria := categoria;
    FrmCategoriaProdCad.id_produto := 0;
    FrmCategoriaProdCad.Show;
end;

procedure TFrmCategoriaProd.imgFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmCategoriaProd.lbProdutosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    if NOT Assigned(FrmCategoriaProdCad) then
        Application.CreateForm(TFrmCategoriaProdCad, FrmCategoriaProdCad);

    FrmCategoriaProdCad.ExecuteOnClose := ListarProdutos;
    FrmCategoriaProdCad.id_categoria := id_categoria;
    FrmCategoriaProdCad.categoria := categoria;
    FrmCategoriaProdCad.id_produto := Item.Tag;
    FrmCategoriaProdCad.Show;
end;

procedure TFrmCategoriaProd.TerminateOrdenarProduto(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    ListarProdutos;
end;


procedure TFrmCategoriaProd.OrdenarProduto(id_produto: integer;
                                           up_down: string);
var
    t: TThread;
begin
    TLoading.Show(FrmCategoriaProd, ''); // Thread Principal..

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.OrdenarProdutoAPI(id_produto, up_down);

    end);

    t.OnTerminate := TerminateOrdenarProduto;
    t.Start;
end;

procedure TFrmCategoriaProd.TerminateProduto(Sender: TObject);
begin
    TLoading.Hide;
    lbProdutos.EndUpdate;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    with Dm.TabProduto do
    begin
        while NOT eof do
        begin
            AddProduto(fieldbyname('id_produto').AsInteger,
                       fieldbyname('foto').AsString,
                       fieldbyname('nome').AsString,
                       fieldbyname('descricao').AsString,
                       '',
                       fieldbyname('preco').AsFloat);

            Next;
        end;
    end;

    DownloadFotos(lbProdutos);
end;

procedure TFrmCategoriaProd.ListarProdutos;
var
    t: TThread;
begin
    TLoading.Show(FrmCategoriaProd, 'Carregando...'); // Thread Principal..
    lbProdutos.BeginUpdate;
    lbProdutos.Items.Clear;

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.ListarProdutosAPI(id_categoria);
    end);

    t.OnTerminate := TerminateProduto;
    t.Start;
end;


end.
