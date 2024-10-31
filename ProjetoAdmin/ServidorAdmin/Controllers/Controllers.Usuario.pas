unit Controllers.Usuario;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DataModule.Global;

procedure RegistrarRotas;
procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure InserirUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse.Post('/admin/usuarios/login', Login);
    THorse.Post('/admin/usuarios', InserirUsuario);
end;

procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    body, json: TJSONObject;
    email, senha: string;
    DmGlobal: TDmGlobal;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);


            body := Req.Body<TJSONObject>;
            email := body.GetValue<string>('email', '');
            senha := body.GetValue<string>('senha', '');

            json := DmGlobal.Login(email, senha);

            if (json.Size = 0) then
            begin
                Res.Send('E-mail ou senha inválida...').Status(401);
                FreeAndNil(json);
            end
            else
                Res.Send<TJSONObject>(json);

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure InserirUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    body: TJSONObject;
    nome, email, senha: string;
    DmGlobal: TDmGlobal;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            body := Req.Body<TJSONObject>;
            nome := body.GetValue<string>('nome', '');
            email := body.GetValue<string>('email', '');
            senha := body.GetValue<string>('senha', '');

            Res.Send<TJSONObject>(DmGlobal.InserirUsuario(nome, email, senha)).Status(201);

        except on ex:exception do
            Res.Send('Erro: ' + ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;



end.
