unit Controllers.Categoria;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DataModule.Global;

procedure RegistrarRotas;
procedure ListarCategorias(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarCategoriaById(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure InserirCategoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarCategoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ExcluirCategoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);

procedure EditarOrdemUp(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarOrdemDown(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse.Get('/admin/categorias', ListarCategorias);
    THorse.Get('/admin/categorias/:id_categoria', ListarCategoriaById);
    THorse.Post('/admin/categorias', InserirCategoria);
    THorse.Put('/admin/categorias/:id_categoria', EditarCategoria);
    THorse.Delete('/admin/categorias/:id_categoria', ExcluirCategoria);

    THorse.Put('/admin/categorias/:id_categoria/up', EditarOrdemUp);
    THorse.Put('/admin/categorias/:id_categoria/down', EditarOrdemDown);
end;

procedure ListarCategorias(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
begin
    try
        try
            // http://localhost:3000/admin/categorias

            DmGlobal := TDmGlobal.Create(nil);

            Res.Send<TJSONArray>(DmGlobal.ListarCategorias());

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ListarCategoriaById(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_categoria: integer;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/categorias/5

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_categoria := Req.Params['id_categoria'].ToInteger;
            except
                id_categoria := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.ListarCategoriaById(id_categoria));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure InserirCategoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;
    descricao: string;
begin
    try
        try
            // http://localhost:3000/admin/categorias
            // Body = {"descricao": "Sobremesa"}

            DmGlobal := TDmGlobal.Create(nil);

            body := req.Body<TJSONObject>;
            descricao := body.GetValue<string>('descricao', '');

            Res.Send<TJSONObject>(DmGlobal.InserirCategoria(descricao)).Status(201);

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarCategoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_categoria: integer;
    DmGlobal: TDmGlobal;
    body: TJSONObject;
    descricao: string;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/categorias/5
            // Body = {"descricao": "Sobremesa"}

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_categoria := Req.Params['id_categoria'].ToInteger;
            except
                id_categoria := 0;
            end;


            // Ler dados do corpo da requisicao...
            body := req.Body<TJSONObject>;
            descricao := body.GetValue<string>('descricao', '');

            Res.Send<TJSONObject>(DmGlobal.EditarCategoria(id_categoria, descricao));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ExcluirCategoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_categoria: integer;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/categorias/5

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_categoria := Req.Params['id_categoria'].ToInteger;
            except
                id_categoria := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.ExcluirCategoria(id_categoria));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarOrdemUp(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_categoria: integer;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/categorias/5/up

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_categoria := Req.Params['id_categoria'].ToInteger;
            except
                id_categoria := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.OrdemCategoriaUp(id_categoria));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarOrdemDown(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_categoria: integer;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/categorias/5/down

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_categoria := Req.Params['id_categoria'].ToInteger;
            except
                id_categoria := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.OrdemCategoriaDown(id_categoria));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

end.
