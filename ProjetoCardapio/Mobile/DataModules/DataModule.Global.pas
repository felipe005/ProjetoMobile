unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, System.IOUtils,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, System.JSON,

  DataSet.Serialize,
  DataSet.Serialize.Config,
  RESTRequest4D,
  DataSet.Serialize.Adapter.RESTRequest4D;

type
  TDm = class(TDataModule)
    Conn: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    qrySacola: TFDQuery;
    qryConfig: TFDQuery;
    TabPedido: TFDMemTable;
    TabProduto: TFDMemTable;
    qryUsuario: TFDQuery;
    TabUsuario: TFDMemTable;
    TabConfig: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
  private

  public
    procedure AdicionarCarrinhoLocal(id_produto: integer; nome, descricao, foto,
                                    obs: string; qtd: integer; vl_unitario: double);
    procedure EditarConfigLocal(vl_entrega: double);
    procedure ListarSacolaLocal;
    procedure ListarConfigLocal;
    procedure LimparSacolaLocal;
    function ListarPedidos(id_usuario: integer): TJsonArray;
    procedure ListarProdutos;
    procedure FinalizarPedido(jsonPedido: TJsonObject);
    function JsonPedido(id_usuario: integer; fone, endereco: string;
                      vl_subtotal, vl_entrega, vl_total: double): TJsonObject;
    function JsonPedidoItem: TJsonArray;
    procedure EditarUsuarioLocal(id_usuario: integer; fone, endereco: string);
    procedure ListarUsuarioLocal;
    procedure Login(fone: string);
    procedure ListarConfig;
    procedure LimparUsuarioLocal;
  end;

var
  Dm: TDm;

Const
  Base_URL = 'http://localhost:9030';
  //Base_URL = 'http://192.168.0.103:3002';
  //Base_URL = 'http://api.pedidoapp.com.br:3002';

  // Comando para acessar dados no Android
  // android:usesCleartextTraffic="true"

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDm.ConnAfterConnect(Sender: TObject);
begin
    {
    try
        conn.ExecSQL('DROP TABLE TAB_CONFIG');
        conn.ExecSQL('DROP TABLE TAB_USUARIO');
        conn.ExecSQL('DROP TABLE TAB_SACOLA_ITEM');
    except
    end;
    }

    conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_CONFIG(' +
                 'VL_ENTREGA DECIMAL(9,2))');

    conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_USUARIO(' +
                 'ID_USUARIO INTEGER, ' +
                 'FONE   VARCHAR(20), ' +
                 'ENDERECO VARCHAR(200))');

    conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_SACOLA_ITEM(' +
                 'ID_ITEM    INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                 'ID_PRODUTO INTEGER, ' +
                 'NOME        VARCHAR(100), ' +
                 'DESCRICAO   VARCHAR(200), ' +
                 'FOTO       VARCHAR(1000), ' +
                 'QTD        INTEGER, ' +
                 'OBS        VARCHAR(200), ' +
                 'VL_UNITARIO  DECIMAL(9,2), ' +
                 'VL_TOTAL   DECIMAL(9,2))');
end;

procedure TDm.ConnBeforeConnect(Sender: TObject);
begin
    conn.DriverName := 'SQLite';

    {$IFDEF MSWINDOWS}
    conn.Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\banco.db';
    {$ELSE}
    conn.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'banco.db');
    {$ENDIF}
end;

procedure TDm.DataModuleCreate(Sender: TObject);
begin
    TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
    Conn.Connected := true;
end;

procedure TDm.AdicionarCarrinhoLocal(id_produto: integer;
                                     nome, descricao, foto, obs: string;
                                     qtd: integer;
                                     vl_unitario: double);
begin
    with qrySacola do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('INSERT INTO TAB_SACOLA_ITEM(ID_PRODUTO, NOME, DESCRICAO, FOTO,');
        SQL.Add('QTD, OBS, VL_UNITARIO, VL_TOTAL)');
        SQL.Add('VALUES(:ID_PRODUTO, :NOME, :DESCRICAO, :FOTO,');
        SQL.Add(':QTD, :OBS, :VL_UNITARIO, :VL_TOTAL)');

        ParamByName('ID_PRODUTO').Value := id_produto;
        ParamByName('NOME').Value := nome;
        ParamByName('DESCRICAO').Value := descricao;
        ParamByName('FOTO').Value := foto;
        ParamByName('QTD').Value := qtd;
        ParamByName('OBS').Value := obs;
        ParamByName('VL_UNITARIO').Value := vl_unitario;
        ParamByName('VL_TOTAL').Value := vl_unitario * qtd;

        ExecSQL;
    end;
end;

procedure TDm.EditarConfigLocal(vl_entrega: double);
begin
    with qryConfig do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('DELETE FROM TAB_CONFIG');
        ExecSQL;

        Active := false;
        SQL.Clear;
        SQL.Add('INSERT INTO TAB_CONFIG(VL_ENTREGA)');
        SQL.Add('VALUES(:VL_ENTREGA)');
        ParamByName('VL_ENTREGA').Value := vl_entrega;
        ExecSQL;
    end;
end;

procedure TDm.EditarUsuarioLocal(id_usuario: integer;
                                 fone, endereco: string);
begin
    with qryUsuario do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('DELETE FROM TAB_USUARIO');
        ExecSQL;

        Active := false;
        SQL.Clear;
        SQL.Add('INSERT INTO TAB_USUARIO(ID_USUARIO, FONE, ENDERECO)');
        SQL.Add('VALUES(:ID_USUARIO, :FONE, :ENDERECO)');
        ParamByName('ID_USUARIO').Value := id_usuario;
        ParamByName('FONE').Value := fone;
        ParamByName('ENDERECO').Value := endereco;
        ExecSQL;
    end;
end;

procedure TDm.ListarSacolaLocal;
begin
    with qrySacola do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('SELECT * FROM TAB_SACOLA_ITEM ORDER BY ID_ITEM');
        Active := true;
    end;
end;

procedure TDm.LimparSacolaLocal;
begin
    with qrySacola do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('DELETE FROM TAB_SACOLA_ITEM');
        ExecSQL;
    end;
end;

procedure TDm.LimparUsuarioLocal;
begin
    with qryUsuario do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('DELETE FROM TAB_USUARIO');
        ExecSQL;
    end;
end;


procedure TDm.ListarConfigLocal;
begin
    with qryConfig do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('SELECT * FROM TAB_CONFIG');
        Active := true;
    end;
end;

procedure TDm.ListarUsuarioLocal;
begin
    with qryUsuario do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('SELECT * FROM TAB_USUARIO');
        Active := true;
    end;
end;

function TDm.ListarPedidos(id_usuario: integer): TJsonArray;
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(Base_URL)
            .Resource('/pedidos')
            .AddParam('id_usuario', id_usuario.ToString)
            .Accept('application/json')
            //.Adapters(TDataSetSerializeAdapter.New(TabPedido))
            .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create('Erro ao consultar dados: ' + resp.Content)
    else
        Result := TJSONObject.ParseJSONValue(TEncoding.UTF8.getbytes(resp.Content), 0)
                  as TJSONArray;

end;

procedure TDm.ListarProdutos;
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(Base_URL)
            .Resource('/cardapios')
            .Accept('application/json')
            .Adapters(TDataSetSerializeAdapter.New(TabProduto))
            .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create('Erro ao consultar produtos: ' + resp.Content);
end;

function TDm.JsonPedido(id_usuario: integer;
                        fone, endereco: string;
                        vl_subtotal, vl_entrega, vl_total: double): TJsonObject;
var
    json: TJSONObject;
begin
    json := TJSONObject.Create;

    json.AddPair('id_usuario', TJSONNumber.Create(id_usuario));
    json.AddPair('endereco', TJSONString.Create(endereco));
    json.AddPair('fone', TJSONString.Create(fone));
    json.AddPair('vl_subtotal', TJSONNumber.Create(vl_subtotal));
    json.AddPair('vl_entrega', TJSONNumber.Create(vl_entrega));
    json.AddPair('vl_total', TJSONNumber.Create(vl_total));

    Result := json;
end;

procedure TDm.FinalizarPedido(jsonPedido: TJsonObject);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(Base_URL)
            .Resource('/pedidos')
            .Accept('application/json')
            .AddBody(jsonPedido.ToJSON)
            .Post;

    if resp.StatusCode <> 201 then
        raise Exception.Create('Erro ao cadastrar pedido: ' + resp.Content);
end;

function TDm.JsonPedidoItem(): TJsonArray;
var
    itens: TJSONArray;
    obj: TJSONObject;
begin
    ListarSacolaLocal;

    Result := qrySacola.ToJSONArray();

    {
    itens := TJSONArray.Create;

    with qrySacola do
    begin
        while NOT Eof do
        begin
            obj := TJSONObject.Create;

            json.AddPair('id_usuario', TJSONNumber.Create(id_usuario));
            json.AddPair('endereco', endereco);
            json.AddPair('fone', fone);
            json.AddPair('vl_subtotal', TJSONNumber.Create(vl_subtotal));
            json.AddPair('vl_entrega', TJSONNumber.Create(vl_entrega));
            json.AddPair('vl_total', TJSONNumber.Create(vl_total));

            Next;
        end;
    end;

    Result := json;
    }
end;

procedure TDm.Login(fone: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    try
        json := TJSONObject.Create;
        json.AddPair('fone', fone);

        resp := TRequest.New.BaseURL(Base_URL)
                .Resource('/usuarios/login')
                .Accept('application/json')
                .AddBody(json.ToJSON)
                .Adapters(TDataSetSerializeAdapter.New(TabUsuario))
                .Post;

        if resp.StatusCode <> 200 then
            raise Exception.Create('Erro ao validar usuário: ' + resp.Content);

    finally
        json.DisposeOf;
    end;
end;

procedure TDm.ListarConfig;
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(Base_URL)
            .Resource('/configs')
            .Accept('application/json')
            .Adapters(TDataSetSerializeAdapter.New(TabConfig))
            .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create('Erro ao carregar configurações: ' + resp.Content);
end;


end.
