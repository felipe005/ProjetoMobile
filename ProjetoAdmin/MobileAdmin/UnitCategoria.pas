unit UnitCategoria;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.DialogService,
  uLoading;

type
  TExecuteOnClose = procedure of Object;

  TFrmCategoria = class(TForm)
    rectToolBar: TRectangle;
    lblTitulo: TLabel;
    imgFechar: TImage;
    imgSalvar: TImage;
    Label6: TLabel;
    edtCategoria: TEdit;
    imgExcluir: TImage;
    procedure imgFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgExcluirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgSalvarClick(Sender: TObject);
  private
    FId_categoria: integer;
    FExecuteOnClose: TExecuteOnClose;
    procedure TerminateCategoria(Sender: TObject);
    procedure DetalhesCategoria;
    procedure TerminateCadCategoria(Sender: TObject);
    procedure ExcluirCategoria;
    { Private declarations }
  public
    property id_categoria: integer read FId_categoria write FId_categoria;
    property ExecuteOnClose: TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
  end;

var
  FrmCategoria: TFrmCategoria;


implementation

{$R *.fmx}

uses DataModule.Global;

procedure TFrmCategoria.DetalhesCategoria;
var
    t: TThread;
begin
    TLoading.Show(FrmCategoria, 'Carregando...'); // Thread Principal..

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.ListarCategoriaIdAPI(id_categoria);

        TThread.Synchronize(TThread.CurrentThread, procedure
        begin
            edtCategoria.Text := Dm.TabCategoriaDetalhe.FieldByName('categoria').AsString;
        end);

    end);

    t.OnTerminate := TerminateCategoria;
    t.Start;
end;

procedure TFrmCategoria.TerminateCategoria(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;
end;

procedure TFrmCategoria.TerminateCadCategoria(Sender: TObject);
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

procedure TFrmCategoria.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmCategoria := nil;
end;

procedure TFrmCategoria.FormShow(Sender: TObject);
begin
    if id_categoria > 0 then
    begin
        lblTitulo.Text := 'Editar Categoria';
        imgExcluir.Visible := true;
        DetalhesCategoria;
    end
    else
    begin
        lblTitulo.Text := 'Nova Categoria';
        imgExcluir.Visible := false;
    end;
end;

procedure TFrmCategoria.imgExcluirClick(Sender: TObject);
begin
    TDialogService.MessageDialog('Deseja excluir a categoria?',
                     TMsgDlgType.mtConfirmation,
                     [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                     TMsgDlgBtn.mbNo,
                     0,
     procedure(const AResult: TModalResult)
     begin
        if AResult = mrYes then
            ExcluirCategoria;
     end);
end;

procedure TFrmCategoria.imgFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmCategoria.imgSalvarClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmCategoria, 'Salvando...'); // Thread Principal..

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.InserirEditarCategoriaAPI(id_categoria, edtCategoria.Text);

        TThread.Synchronize(TThread.CurrentThread, procedure
        begin
            edtCategoria.Text := Dm.TabCategoria.FieldByName('categoria').AsString;
        end);

    end);

    t.OnTerminate := TerminateCadCategoria;
    t.Start;
end;

procedure TFrmCategoria.ExcluirCategoria();
var
    t: TThread;
begin
    TLoading.Show(FrmCategoria, 'Excluindo...'); // Thread Principal..

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.ExcluirCategoriaAPI(id_categoria);
    end);

    t.OnTerminate := TerminateCadCategoria;
    t.Start;
end;

end.
