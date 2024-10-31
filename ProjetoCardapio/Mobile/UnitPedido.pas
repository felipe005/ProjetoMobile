unit UnitPedido;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation, FMX.ListBox, System.JSON,
  uFunctions;

type
  TFrmPedido = class(TForm)
    lbCardapio: TListBox;
    rectEndereco: TRectangle;
    lblPedido: TLabel;
    lblEndereco: TLabel;
    rectToolbar2: TRectangle;
    Label1: TLabel;
    imgVoltar: TImage;
    rectTotal: TRectangle;
    Layout1: TLayout;
    Label2: TLabel;
    lblSubtotal: TLabel;
    Layout2: TLayout;
    Label4: TLabel;
    lblEntrega: TLabel;
    Layout3: TLayout;
    Label6: TLabel;
    lblTotal: TLabel;
    lblData: TLabel;
    Label11: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgVoltarClick(Sender: TObject);
  private
    procedure AddProduto(id_produto: integer;
                                  url_foto, nome, obs: string;
                                  qtd: integer;
                                  vl_unitario: double);
    procedure ListarProdutos;
    procedure DownloadFoto(lb: TListBox);
    { Private declarations }
  public
    json: TJsonObject;
  end;

var
  FrmPedido: TFrmPedido;

implementation

{$R *.fmx}

uses Frame.Produto;

procedure TFrmPedido.DownloadFoto(lb: TListBox);
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

procedure TFrmPedido.AddProduto(id_produto: integer;
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

procedure TFrmPedido.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmPedido := nil;
end;

procedure TFrmPedido.FormShow(Sender: TObject);
begin
    ListarProdutos;
end;

procedure TFrmPedido.imgVoltarClick(Sender: TObject);
begin
    close;
end;

procedure TFrmPedido.ListarProdutos;
var
    itens: TJSONArray;
    i: integer;
begin
    lbCardapio.Items.Clear;

    lblPedido.Text := 'Pedido ' + json.GetValue<string>('id_pedido', '');
    lblEndereco.Text := 'Entrega: ' + json.GetValue<string>('endereco', '');
    lblData.Text := json.GetValue<string>('dt_pedido', '') + 'h';
    lblSubtotal.Text := FormatFloat('R$ #,##0.00', json.GetValue<double>('vl_subtotal', 0));
    lblEntrega.Text := FormatFloat('R$ #,##0.00', json.GetValue<double>('vl_entrega', 0));
    lblTotal.Text := FormatFloat('R$ #,##0.00', json.GetValue<double>('vl_total', 0));
    itens := json.GetValue<TJSONArray>('itens');

    for i := 0 to itens.Size - 1 do
    begin
        AddProduto(itens[i].GetValue<integer>('id_produto', 0),
                   itens[i].GetValue<string>('foto', ''),
                   itens[i].GetValue<string>('nome', ''),
                   itens[i].GetValue<string>('obs', ''),
                   itens[i].GetValue<integer>('qtd', 0),
                   itens[i].GetValue<double>('vl_unitario', 0));
    end;

    DownloadFoto(lbCardapio);

end;


end.
