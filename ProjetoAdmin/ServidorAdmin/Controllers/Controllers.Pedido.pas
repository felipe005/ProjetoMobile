unit Controllers.Pedido;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DataModule.Global;

procedure RegistrarRotas;
procedure ListarPedidos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarPedidoById(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarStatusPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse.Get('/admin/pedidos', ListarPedidos);
    THorse.Get('/admin/pedidos/:id_pedido', ListarPedidoById);
    THorse.Put('/admin/pedidos/:id_pedido/status', EditarStatusPedido);
end;

procedure ListarPedidos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    dt_de, dt_ate, status: string;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // Query Params...
            // http://localhost:3000/admin/pedidos?dt_de=2024-05-10&dt_ate=2024-05-10&status=A

            DmGlobal := TDmGlobal.Create(nil);


            try
                dt_de := Req.Query['dt_de'];
            except
                dt_de := '';
            end;

            try
                dt_ate := Req.Query['dt_ate'];
            except
                dt_ate := '';
            end;

            try
                status := Req.Query['status'];
            except
                status := '';
            end;

            Res.Send<TJSONArray>(DmGlobal.ListarPedidos(dt_de, dt_ate, status));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ListarPedidoById(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_pedido: integer;
    DmGlobal: TDmGlobal;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/pedidos/123

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_pedido := Req.Params['id_pedido'].ToInteger;
            except
                id_pedido := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.ListarPedidoById(id_pedido));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarStatusPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    id_pedido: integer;
    DmGlobal: TDmGlobal;
    body: TJSONObject;
    status: string;
begin
    try
        try
            // URL Params (URI Params)...
            // http://localhost:3000/admin/pedidos/123/status
            // Status: Corpoda requisicao
            // Body = {"status": "F"}

            DmGlobal := TDmGlobal.Create(nil);

            try
                id_pedido := Req.Params['id_pedido'].ToInteger;
            except
                id_pedido := 0;
            end;


            // Ler dados do corpo da requisicao...
            body := req.Body<TJSONObject>;
            status := body.GetValue<string>('status', '');

            Res.Send<TJSONObject>(DmGlobal.EditarStatusPedido(id_pedido, status));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;



end.
