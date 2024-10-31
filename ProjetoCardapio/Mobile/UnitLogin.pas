unit UnitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit,
  uLoading, uSession;

type
  TFrmLogin = class(TForm)
    Label10: TLabel;
    Image1: TImage;
    Layout1: TLayout;
    Layout2: TLayout;
    Label8: TLabel;
    edtWhatsApp: TEdit;
    rectSacola: TRectangle;
    btnAcessar: TSpeedButton;
    procedure btnAcessarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ThreadLoginTerminate(Sender: TObject);
    procedure ValidarUsuario;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.fmx}

uses DataModule.Global, UnitPrincipal;

procedure TFrmLogin.ValidarUsuario;
begin
    Dm.ListarUsuarioLocal;

    if Dm.qryUsuario.RecordCount > 0 then
    begin
        TSession.ID_USUARIO := Dm.qryUsuario.FieldByName('id_usuario').AsInteger;
        TSession.FONE := Dm.qryUsuario.FieldByName('fone').AsString;
        TSession.ENDERECO := Dm.qryUsuario.FieldByName('endereco').AsString;

        Application.MainForm := FrmPrincipal;
        FrmPrincipal.Show;
        FrmLogin.Close;
    end;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
begin
    ValidarUsuario;
end;

procedure TFrmLogin.ThreadLoginTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    FrmPrincipal.Show;
end;

procedure TFrmLogin.btnAcessarClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmLogin, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        Dm.Login(edtWhatsApp.Text);

        Dm.EditarUsuarioLocal(Dm.TabUsuario.FieldByName('id_usuario').AsInteger,
                              Dm.TabUsuario.FieldByName('fone').AsString,
                              Dm.TabUsuario.FieldByName('endereco').AsString);

        TSession.ID_USUARIO := Dm.TabUsuario.FieldByName('id_usuario').AsInteger;
        TSession.FONE := Dm.TabUsuario.FieldByName('fone').AsString;
        TSession.ENDERECO := Dm.TabUsuario.FieldByName('endereco').AsString;

    end);

    t.OnTerminate := ThreadLoginTerminate;
    t.Start;
end;

end.
