unit Controllers.Produto;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DataModule.Global,
     Horse.Upload,
     FMX.Graphics;

procedure RegistrarRotas;
procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarProdutoById(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure InserirProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ExcluirProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarFoto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarOrdemUp(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarOrdemDown(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse.Get('/admin/produtos', ListarProdutos);
    THorse.Put('/admin/produtos/:id_produto/foto', EditarFoto);
    THorse.Get('/admin/produtos/:id_produto', ListarProdutoById);
    THorse.Post('/admin/produtos', InserirProduto);
    THorse.Put('/admin/produtos/:id_produto', EditarProduto);
    THorse.Delete('/admin/produtos/:id_produto', ExcluirProduto);

    THorse.Put('/admin/produtos/:id_produto/up', EditarOrdemUp);
    THorse.Put('/admin/produtos/:id_produto/down', EditarOrdemDown);
end;



procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    id_categoria: integer;
begin
    try
        try
            // http://localhost:3000/admin/produtos?id_categoria=1

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_categoria := Req.Query['id_categoria'].ToInteger;
            except
                id_categoria := 0;
            end;

            Res.Send<TJSONArray>(DmGlobal.ListarProdutos(id_categoria));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ListarProdutoById(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_produto: integer;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/produtos/5

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_produto := Req.Params['id_produto'].ToInteger;
            except
                id_produto := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.ListarProdutoById(id_produto));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure InserirProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;
    nome, descricao: string;
    preco: double;
    id_categoria: integer;
begin
    try
        try
            // http://localhost:3000/admin/produtos
            // Body = nome, descricao, preco, foto, id_categoria

            DmGlobal := TDmGlobal.Create(nil);

            body := req.Body<TJSONObject>;
            nome := body.GetValue<string>('nome', '');
            descricao := body.GetValue<string>('descricao', '');
            preco := body.GetValue<double>('preco', 0);
            id_categoria := body.GetValue<integer>('id_categoria', 0);

            Res.Send<TJSONObject>(
                DmGlobal.InserirProduto(nome, descricao, preco,
                                        id_categoria)).Status(201);

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;
    nome, descricao: string;
    preco: double;
    id_produto, id_categoria: integer;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/produtos/5
            // Body = nome, descricao, preco, foto, id_categoria

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_produto := Req.Params['id_produto'].ToInteger;
            except
                id_produto := 0;
            end;


            // Ler dados do corpo da requisicao...
            body := req.Body<TJSONObject>;
            nome := body.GetValue<string>('nome', '');
            descricao := body.GetValue<string>('descricao', '');
            preco := body.GetValue<double>('preco', 0);
            id_categoria := body.GetValue<integer>('id_categoria', 0);

            Res.Send<TJSONObject>(DmGlobal.EditarProduto(id_produto, nome,
                                  descricao, preco, id_categoria));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ExcluirProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_produto: integer;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/produtos/5

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_produto := Req.Params['id_produto'].ToInteger;
            except
                id_produto := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.ExcluirProduto(id_produto));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarFoto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    LUploadConfig: TUploadConfig;
    DmGlobal: TDmGlobal;
    body: TJSONObject;
    id_produto: integer;
begin
    try
        id_produto := Req.Params['id_produto'].ToInteger;
    except
        id_produto := 0;
    end;

    LUploadConfig := TUploadConfig.Create(ExtractFilePath(ParamStr(0)) + 'Fotos');
    LUploadConfig.ForceDir := true;
    LUploadConfig.OverrideFiles := true;
    LUploadConfig.UploadFileCallBack :=
    procedure(Sender: TObject; AFile: TUploadFileInfo)
    begin
        try
            DmGlobal := TDmGlobal.Create(nil);
            DmGlobal.EditarFoto(id_produto, AFile.filename);
        finally
            FreeAndNil(DmGlobal);
        end;
    end;

    Res.Send<TUploadConfig>(LUploadConfig);



end;

procedure EditarOrdemUp(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_produto: integer;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/produtos/5/up

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_produto := Req.Params['id_produto'].ToInteger;
            except
                id_produto := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.OrdemProdutoUp(id_produto));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarOrdemDown(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_produto: integer;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/produtos/5/down

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_produto := Req.Params['id_produto'].ToInteger;
            except
                id_produto := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.OrdemProdutoDown(id_produto));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

end.
