unit Controllers.Config;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DataModule.Global;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

procedure RegistrarRotas;
begin
    THorse.Get('/admin/config', Listar);
    THorse.Put('/admin/config', Editar);
end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            Res.Send<TJSONObject>(DmGlobal.ListarConfig());

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;



procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;
    vl_entrega: double;
begin
    try
        try
            // PUT -> http://localhost:3000/admin/config
            // Body = {"vl_entrega": 10}

            DmGlobal := TDmGlobal.Create(nil);

            // Ler dados do corpo da requisicao...
            body := req.Body<TJSONObject>;
            vl_entrega := body.GetValue<double>('vl_entrega', 0);

            Res.Send<TJSONObject>(DmGlobal.EditarConfig(vl_entrega));

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

end.
