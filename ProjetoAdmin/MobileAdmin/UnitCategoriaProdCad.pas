unit UnitCategoriaProdCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Edit, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox,
  FMX.DialogService, uCombobox, uLoading, u99Permissions, System.Actions,
  FMX.ActnList, FMX.StdActns, FMX.MediaLibrary.Actions, System.IOUtils,
  uFunctions;

type
  TExecuteOnClose = procedure of Object;

  TFrmCategoriaProdCad = class(TForm)
    rectToolBar: TRectangle;
    lblTitulo: TLabel;
    imgFechar: TImage;
    imgSalvar: TImage;
    Label6: TLabel;
    edtNome: TEdit;
    imgExcluir: TImage;
    imgFoto: TImage;
    Layout1: TLayout;
    Label1: TLabel;
    Label2: TLabel;
    EdtDescricao: TEdit;
    Label3: TLabel;
    edtPreco: TEdit;
    Label4: TLabel;
    rectCategoria: TRectangle;
    Image2: TImage;
    lblCategoria: TLabel;
    ActionList1: TActionList;
    ActionLibrary: TTakePhotoFromLibraryAction;
    OpenDialog: TOpenDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgFecharClick(Sender: TObject);
    procedure imgExcluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rectCategoriaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgSalvarClick(Sender: TObject);
    procedure imgFotoClick(Sender: TObject);
    procedure ActionLibraryDidFinishTaking(Image: TBitmap);
  private
    permissao: T99Permissions;
    cmbCategoria: TCustomCombobox;
    FId_produto: integer;
    FCategoria: string;
    FId_categoria: integer;
    FExecuteOnClose: TExecuteOnClose;

    {$IFDEF MSWINDOWS}
    procedure CategoriaClick(Sender: TObject);
    {$ELSE}
    procedure CategoriaClick(Sender: TObject; const PointF: TPointF);
    {$ENDIF}

    procedure SetupCombobox;
    procedure DetalhesProduto;
    procedure TerminateDadosProduto(Sender: TObject);
    procedure TerminateSalvar(Sender: TObject);
    procedure ErroPermissao(Sender: TObject);
    function SaveFotoToDisk(id_produto: integer; Foto: TBitmap): string;
  public
    property ExecuteOnClose: TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
    property id_produto: integer read FId_produto write FId_produto;
    property id_categoria: integer read FId_categoria write FId_categoria;
    property categoria: string read FCategoria write FCategoria;
  end;

var
  FrmCategoriaProdCad: TFrmCategoriaProdCad;

implementation

{$R *.fmx}

uses DataModule.Global;

procedure TFrmCategoriaProdCad.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmCategoriaProdCad := nil;
end;

procedure TFrmCategoriaProdCad.FormCreate(Sender: TObject);
begin
    SetupCombobox;
    permissao := T99Permissions.Create;
end;

procedure TFrmCategoriaProdCad.FormDestroy(Sender: TObject);
begin
    cmbCategoria.DisposeOf;
    permissao.DisposeOf;
end;

procedure TFrmCategoriaProdCad.TerminateDadosProduto(Sender: TObject);
var
    url: string;
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    url := Dm.TabProdDetalhe.FieldByName('foto').AsString;
    LoadImageFromURL(imgFoto.Bitmap, url);
end;

procedure TFrmCategoriaProdCad.DetalhesProduto;
var
    t: TThread;
begin
    lblCategoria.Text := categoria;

    if id_produto = 0 then
        exit;

    TLoading.Show(FrmCategoriaProdCad, ''); // Thread Principal..

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.ListarProdutoIdAPI(id_produto);

        TThread.Synchronize(TThread.CurrentThread, procedure
        begin
            edtNome.Text := Dm.TabProdDetalhe.FieldByName('nome').AsString;
            edtDescricao.Text := Dm.TabProdDetalhe.FieldByName('descricao').AsString;
            edtPreco.Text := FormatFloat('0.00', Dm.TabProdDetalhe.FieldByName('preco').AsFloat);
            lblCategoria.Text := Dm.TabProdDetalhe.FieldByName('categoria').AsString;

            id_categoria := Dm.TabProdDetalhe.FieldByName('id_categoria').AsInteger;
            categoria := Dm.TabProdDetalhe.FieldByName('categoria').AsString;
        end);
    end);

    t.OnTerminate := TerminateDadosProduto;
    t.Start;
end;

procedure TFrmCategoriaProdCad.FormShow(Sender: TObject);
begin
    DetalhesProduto;
end;

procedure TFrmCategoriaProdCad.ActionLibraryDidFinishTaking(Image: TBitmap);
begin
    imgFoto.Bitmap := Image;
end;

{$IFDEF MSWINDOWS}
procedure TFrmCategoriaProdCad.CategoriaClick(Sender: TObject);
{$ELSE}
procedure TFrmCategoriaProdCad.CategoriaClick(Sender: TObject; const PointF: TPointF);
{$ENDIF}
var
    status: string;
begin
    cmbCategoria.HideMenu;
    id_categoria := cmbCategoria.CodItem.ToInteger;
    categoria := cmbCategoria.DescrItem;

    lblCategoria.Text := categoria;
end;

procedure TFrmCategoriaProdCad.SetupCombobox;
begin
    cmbCategoria := TCustomCombobox.Create(FrmCategoriaProdCad);
    cmbCategoria.TitleMenuText := 'Categoria do Produto';
    cmbCategoria.SubTitleMenuText := 'Selecione a categoria do produto:';

    cmbCategoria.BackgroundColor := $FFFFFFFF;
    cmbCategoria.ItemBackgroundColor := $FFE84F3D;
    cmbCategoria.ItemFontColor := $FFFFFFFF;

    cmbCategoria.OnClick := CategoriaClick;

    Dm.TabCategoria.First;
    cmbCategoria.LoadFromDataset(Dm.TabCategoria, 'id_categoria', 'categoria')
end;

procedure TFrmCategoriaProdCad.imgExcluirClick(Sender: TObject);
begin
    TDialogService.MessageDialog('Deseja excluir o produto?',
                     TMsgDlgType.mtConfirmation,
                     [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                     TMsgDlgBtn.mbNo,
                     0,
     procedure(const AResult: TModalResult)
     begin
        if AResult = mrYes then
        begin
            Dm.ExcluirProdutoAPI(id_produto);

            if Assigned(ExecuteOnClose) then
                ExecuteOnClose;

            close;
        end;
     end);
end;

procedure TFrmCategoriaProdCad.imgFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmCategoriaProdCad.ErroPermissao(Sender: TObject);
begin
    showmessage('Você não possui acesso a esse recurso');
end;

procedure TFrmCategoriaProdCad.imgFotoClick(Sender: TObject);
begin
    {$IFDEF MSWINDOWS}
    if OpenDialog.Execute then
        imgFoto.Bitmap.LoadFromFile(OpenDialog.FileName);
    {$ELSE}
    permissao.PhotoLibrary(ActionLibrary, ErroPermissao);
    {$ENDIF}
end;

procedure TFrmCategoriaProdCad.TerminateSalvar(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    if Assigned(ExecuteOnClose) then
        ExecuteOnClose;

    close;
end;

function TFrmCategoriaProdCad.SaveFotoToDisk(id_produto: integer; Foto: TBitmap): string;
var
    arq: string;
begin
    {$IFDEF MSWINDOWS}
    arq := System.SysUtils.GetCurrentDir + '\FotosTemp';

    if not TDirectory.Exists(arq) then
        TDirectory.CreateDirectory(arq);

    arq := arq + '\' + id_produto.ToString + '.jpg';
    {$ELSE}
    arq := TPath.Combine(TPath.GetDocumentsPath, id_produto.ToString + '.jpg');
    {$ENDIF}

    if FileExists(arq) then
        DeleteFile(arq);

    Foto.SaveToFile(arq);

    Result := arq;
end;

procedure TFrmCategoriaProdCad.imgSalvarClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmCategoriaProdCad, ''); // Thread Principal..

    t := TThread.CreateAnonymousThread(procedure
    var
        arq_foto: string;
    begin
        if id_produto > 0 then
            Dm.EditarProdutoAPI(id_produto, edtNome.Text, EdtDescricao.Text,
                               edtPreco.Text.ToDouble, id_categoria)
        else
        begin
            Dm.InserirProdutoAPI(edtNome.Text, EdtDescricao.Text,
                               edtPreco.Text.ToDouble, id_categoria);

            id_produto := Dm.TabProdDetalhe.FieldByName('id_produto').AsInteger;
        end;

        arq_foto := SaveFotoToDisk(id_produto, imgFoto.Bitmap);

        Dm.EditarFotoProdutoAPI(id_produto, arq_foto);
    end);

    t.OnTerminate := TerminateSalvar;
    t.Start;
end;

procedure TFrmCategoriaProdCad.rectCategoriaClick(Sender: TObject);
begin
    cmbCategoria.ShowMenu;
end;

end.
