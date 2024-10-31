unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, DataSet.Serialize, DataSet.Serialize.Config,
  RESTRequest4D, System.JSON,
  DataSet.Serialize.Adapter.RESTRequest4D, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  System.IOUtils, FireDAC.DApt;

type
  TDm = class(TDataModule)
    TabUsuario: TFDMemTable;
    conn: TFDConnection;
    qryUsuario: TFDQuery;
    TabPedido: TFDMemTable;
    TabCategoria: TFDMemTable;
    TabProduto: TFDMemTable;
    TabProdDetalhe: TFDMemTable;
    TabCategoriaDetalhe: TFDMemTable;
    TabConfig: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure connBeforeConnect(Sender: TObject);
    procedure connAfterConnect(Sender: TObject);
  private


  public
    procedure LoginAPI(email, senha: string);
    procedure InserirUsuarioAPI(nome, email, senha: string);

    procedure SalvarUsuarioMobile(id_usuario: integer; nome, email: string);
    procedure ExcluirUsuarioMobile;
    procedure ListarUsuarioMobile;
    procedure ListarPedidosAPI(dt_de, dt_ate, status: string);
    function JsonPedidoByIdAPI(id_pedido: integer): TJsonObject;
    procedure EditarStatusPedidoAPI(id_pedido: integer; status: string);
    procedure ListarCategoriasAPI;
    procedure OrdenarCategoriaAPI(id_categoria: integer; up_down: string);
    procedure ListarCategoriaIdAPI(id_categoria: integer);
    procedure InserirEditarCategoriaAPI(id_categoria: integer;
                                          categoria: string);
    procedure ExcluirCategoriaAPI(id_categoria: integer);
    procedure ListarProdutosAPI(id_categoria: integer);
    procedure ListarProdutoIdAPI(id_produto: integer);
    procedure InserirProdutoAPI(nome, descricao: string; preco: double;
                                  id_categoria: integer);
    procedure EditarProdutoAPI(id_produto: integer; nome, descricao: string;
                               preco: double; id_categoria: integer);
    procedure ExcluirProdutoAPI(id_produto: integer);
    procedure EditarFotoProdutoAPI(id_produto: integer; arq_foto: string);
    procedure OrdenarProdutoAPI(id_produto: integer; up_down: string);
    procedure EditarConfigAPI(vl_entrega: double);
    procedure ListarConfigAPI;
  end;

var
  Dm: TDm;

Const
  BASE_URL = 'http://localhost:3003';
  //BASE_URL = 'http://192.168.0.103:3003';

  {
  Ajustar tab Application do AndroidManifestTemplate:
     android:usesCleartextTraffic="true"
  }

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDm.connAfterConnect(Sender: TObject);
begin
    conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_USUARIO( ' +
                 'ID_USUARIO INTEGER NOT NULL PRIMARY KEY,' +
                 'NOME VARCHAR(100),' +
                 'EMAIL VARCHAR(100))');

end;

procedure TDm.connBeforeConnect(Sender: TObject);
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
    conn.Connected := true;
end;

procedure TDm.LoginAPI(email, senha: string);
var
    json: TJsonObject;
    resp: IResponse;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('email', email);
        json.AddPair('senha', senha);

        resp := TRequest.New.BaseURL(BASE_URL)
                        .Resource('admin/usuarios/login')
                        .Adapters(TDataSetSerializeAdapter.New(TabUsuario))
                        .AddBody(json.ToJSON)
                        .Accept('application/json')
                        .Post;

        if (resp.StatusCode <> 200) then
            raise Exception.Create(resp.Content);

    finally
        FreeAndNil(json);
    end;
end;

procedure TDm.InserirUsuarioAPI(nome, email, senha: string);
var
    json: TJsonObject;
    resp: IResponse;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('nome', nome);
        json.AddPair('email', email);
        json.AddPair('senha', senha);

        resp := TRequest.New.BaseURL(BASE_URL)
                        .Resource('admin/usuarios')
                        .Adapters(TDataSetSerializeAdapter.New(TabUsuario))
                        .AddBody(json.ToJSON)
                        .Accept('application/json')
                        .Post;

        if (resp.StatusCode <> 201) then
            raise Exception.Create(resp.Content);

    finally
        FreeAndNil(json);
    end;
end;

procedure TDm.SalvarUsuarioMobile(id_usuario: integer;
                                  nome, email: string);
begin
    with qryUsuario do
    begin
        ExcluirUsuarioMobile;

        Active := false;
        SQL.Clear;
        SQL.Add('INSERT INTO TAB_USUARIO(ID_USUARIO, NOME, EMAIL)');
        SQL.Add('VALUES(:ID_USUARIO, :NOME, :EMAIL)');
        ParamByName('ID_USUARIO').Value := id_usuario;
        ParamByName('NOME').Value := nome;
        ParamByName('EMAIL').Value := email;
        ExecSQL;
    end;
end;

procedure TDm.ExcluirUsuarioMobile;
begin
    with qryUsuario do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('DELETE FROM TAB_USUARIO');
        ExecSQL;
    end;
end;

procedure TDm.ListarUsuarioMobile;
begin
    with qryUsuario do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('SELECT * FROM TAB_USUARIO');
        Active := true;
    end;
end;

procedure TDm.ListarPedidosAPI(dt_de, dt_ate, status: string);
var
    resp: IResponse;
begin
    // Query Params...
    // http://localhost:3000/admin/pedidos?dt_de=2024-05-10&dt_ate=2024-05-10&status=A

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/pedidos')
                    .AddParam('dt_de', dt_de)
                    .AddParam('dt_ate', dt_ate)
                    .AddParam('status', status)
                    .Adapters(TDataSetSerializeAdapter.New(TabPedido))
                    .Accept('application/json')
                    .Get;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);

end;

function TDm.JsonPedidoByIdAPI(id_pedido: integer): TJsonObject;
var
    resp: IResponse;
begin
    // URI Params...
    // http://localhost:3000/admin/pedidos/123

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/pedidos')
                    .ResourceSuffix(id_pedido.ToString)
                    .Accept('application/json')
                    .Get;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content)
    else
        Result := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(resp.Content), 0) as TJSONObject;

end;

procedure TDm.EditarStatusPedidoAPI(id_pedido: integer;
                                    status: string);
var
    json: TJsonObject;
    resp: IResponse;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('status', status);

        resp := TRequest.New.BaseURL(BASE_URL)
                        .Resource('admin/pedidos/')
                        .ResourceSuffix(id_pedido.ToString + '/status')
                        .AddBody(json.ToJSON)
                        .Accept('application/json')
                        .Put;

        if (resp.StatusCode <> 200) then
            raise Exception.Create(resp.Content);

    finally
        FreeAndNil(json);
    end;
end;

procedure TDm.ListarCategoriasAPI();
var
    resp: IResponse;
begin
    // http://localhost:3000/admin/categorias

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/categorias')
                    .Adapters(TDataSetSerializeAdapter.New(TabCategoria))
                    .Accept('application/json')
                    .Get;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDm.OrdenarCategoriaAPI(id_categoria: integer; up_down: string);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/categorias/')
                    .ResourceSuffix(id_categoria.ToString + '/' + LowerCase(up_down))
                    .Accept('application/json')
                    .Put;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;


procedure TDm.ListarCategoriaIdAPI(id_categoria: integer);
var
    resp: IResponse;
begin
    // http://localhost:3003/admin/categorias/2

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/categorias')
                    .ResourceSuffix(id_categoria.ToString)
                    .Adapters(TDataSetSerializeAdapter.New(TabCategoriaDetalhe))
                    .Accept('application/json')
                    .Get;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDm.InserirEditarCategoriaAPI(id_categoria: integer;
                                        categoria: string);
var
    json: TJsonObject;
    resp: IResponse;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('descricao', categoria);

        if id_categoria = 0 then // Novo registro...
        begin
            resp := TRequest.New.BaseURL(BASE_URL)
                            .Resource('admin/categorias')
                            .AddBody(json.ToJSON)
                            .Accept('application/json')
                            .Post;

            if (resp.StatusCode <> 201) then
                raise Exception.Create(resp.Content);
        end
        else // ALteracao...
        begin
            resp := TRequest.New.BaseURL(BASE_URL)
                            .Resource('admin/categorias')
                            .ResourceSuffix(id_categoria.ToString)
                            .AddBody(json.ToJSON)
                            .Accept('application/json')
                            .Put;

            if (resp.StatusCode <> 200) then
                raise Exception.Create(resp.Content);
        end

    finally
        FreeAndNil(json);
    end;
end;

procedure TDm.InserirProdutoAPI(nome, descricao: string;
                                preco: double;
                                id_categoria: integer);
var
    json: TJsonObject;
    resp: IResponse;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('nome', nome);
        json.AddPair('descricao', descricao);
        json.AddPair('preco', preco);
        json.AddPair('id_categoria', id_categoria);

        resp := TRequest.New.BaseURL(BASE_URL)
                        .Resource('admin/produtos')
                        .AddBody(json.ToJSON)
                        .Accept('application/json')
                        .Adapters(TDataSetSerializeAdapter.New(TabProdDetalhe))
                        .Post;

        if (resp.StatusCode <> 201) then
            raise Exception.Create(resp.Content);

    finally
        FreeAndNil(json);
    end;
end;

procedure TDm.EditarProdutoAPI( id_produto: integer;
                                nome, descricao: string;
                                preco: double;
                                id_categoria: integer);
var
    json: TJsonObject;
    resp: IResponse;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('nome', nome);
        json.AddPair('descricao', descricao);
        json.AddPair('preco', preco);
        json.AddPair('id_categoria', id_categoria);

        resp := TRequest.New.BaseURL(BASE_URL)
                        .Resource('admin/produtos')
                        .ResourceSuffix(id_produto.ToString)
                        .AddBody(json.ToJSON)
                        .Accept('application/json')
                        .Put;

        if (resp.StatusCode <> 200) then
            raise Exception.Create(resp.Content);

    finally
        FreeAndNil(json);
    end;
end;

procedure TDm.ExcluirProdutoAPI( id_produto: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/produtos')
                    .ResourceSuffix(id_produto.ToString)
                    .Accept('application/json')
                    .Delete;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDm.ExcluirCategoriaAPI(id_categoria: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/categorias/')
                    .ResourceSuffix(id_categoria.ToString)
                    .Accept('application/json')
                    .Delete;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDm.ListarProdutosAPI(id_categoria: integer);
var
    resp: IResponse;
begin
    // Query Params...
    // http://localhost:3000/admin/produtos?id_categoria=1

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/produtos')
                    .AddParam('id_categoria', id_categoria.ToString)
                    .Adapters(TDataSetSerializeAdapter.New(TabProduto))
                    .Accept('application/json')
                    .Get;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);

end;

procedure TDm.ListarProdutoIdAPI(id_produto: integer);
var
    resp: IResponse;
begin
    // URI Params...
    // http://localhost:3000/admin/produtos/123

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/produtos')
                    .ResourceSuffix(id_produto.tostring)
                    .Adapters(TDataSetSerializeAdapter.New(TabProdDetalhe))
                    .Accept('application/json')
                    .Get;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);

end;

procedure TDm.EditarFotoProdutoAPI(id_produto: integer; arq_foto: string);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/produtos')
                    .ResourceSuffix(id_produto.tostring + '/foto')
                    .AddParam('files', arq_foto, pkFILE)
                    .Put;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);

end;

procedure TDm.OrdenarProdutoAPI(id_produto: integer; up_down: string);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/produtos/')
                    .ResourceSuffix(id_produto.ToString + '/' + LowerCase(up_down))
                    .Accept('application/json')
                    .Put;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDm.ListarConfigAPI();
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('admin/config')
                    .Accept('application/json')
                    .Adapters(TDataSetSerializeAdapter.New(TabConfig))
                    .Get;

    if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;


procedure TDm.EditarConfigAPI( vl_entrega: double);
var
    json: TJsonObject;
    resp: IResponse;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('vl_entrega', vl_entrega);

        resp := TRequest.New.BaseURL(BASE_URL)
                        .Resource('admin/config')
                        .AddBody(json.ToJSON)
                        .Accept('application/json')
                        .Put;

        if (resp.StatusCode <> 200) then
            raise Exception.Create(resp.Content);

    finally
        FreeAndNil(json);
    end;
end;

end.
