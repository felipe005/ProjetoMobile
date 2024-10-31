unit UnitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  FMX.TabControl, FMX.Edit, uLoading;

type
  TFrmLogin = class(TForm)
    TabControl: TTabControl;
    TabLogin: TTabItem;
    TabNovaConta: TTabItem;
    lytLogo: TLayout;
    Image1: TImage;
    Label1: TLabel;
    lytCampos: TLayout;
    Label2: TLabel;
    Label3: TLabel;
    edtSenha: TEdit;
    Label4: TLabel;
    edtEmail: TEdit;
    Rectangle1: TRectangle;
    btnAcessar: TSpeedButton;
    lblCriarConta: TLabel;
    Layout3: TLayout;
    Image2: TImage;
    Label6: TLabel;
    Layout4: TLayout;
    Label7: TLabel;
    Label8: TLabel;
    edtContaSenha: TEdit;
    Label9: TLabel;
    edtContaNome: TEdit;
    Rectangle2: TRectangle;
    btnCriarConta: TSpeedButton;
    lblLogin: TLabel;
    Label11: TLabel;
    edtContaEmail: TEdit;
    timerAbertura: TTimer;
    imgSplash: TImage;
    procedure lblCriarContaClick(Sender: TObject);
    procedure lblLoginClick(Sender: TObject);
    procedure btnAcessarClick(Sender: TObject);
    procedure btnCriarContaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure timerAberturaTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
  private
    procedure TerminateLogin(Sender: TObject);
    procedure ValidaUsuarioLogado;
    procedure OpenMainForm;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.fmx}

uses UnitPrincipal, DataModule.Global;

procedure TFrmLogin.ValidaUsuarioLogado;
begin
    Dm.ListarUsuarioMobile;

    if Dm.qryUsuario.RecordCount > 0 then
        OpenMainForm
    else
    begin
        TabControl.Visible := true;
        imgSplash.Visible := false;
    end;
end;

procedure TFrmLogin.OpenMainForm;
begin
    if NOT Assigned(FrmPrincipal) then
        application.CreateForm(TFrmPrincipal, FrmPrincipal);

    Application.MainForm := FrmPrincipal;
    FrmPrincipal.Show;

    FrmLogin.Close;
end;

procedure TFrmLogin.TerminateLogin(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;


    // Salvar dados no banco local do aparelho...
     Dm.SalvarUsuarioMobile(dm.TabUsuario.FieldByName('id_usuario').AsInteger,
                            dm.TabUsuario.FieldByName('nome').AsString,
                            dm.TabUsuario.FieldByName('email').AsString);


    OpenMainForm;
end;

procedure TFrmLogin.timerAberturaTimer(Sender: TObject);
begin
    timerAbertura.Enabled := false;
    ValidaUsuarioLogado;
end;

procedure TFrmLogin.btnAcessarClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmLogin, ''); // Thread Principal..

    t := TThread.CreateAnonymousThread(procedure
    begin
        Sleep(1500);
        Dm.LoginAPI(edtEmail.text, edtSenha.Text);
    end);

    t.OnTerminate := TerminateLogin;
    t.Start;
end;

procedure TFrmLogin.btnCriarContaClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmLogin, ''); // Thread Principal..

    t := TThread.CreateAnonymousThread(procedure
    begin
        Sleep(1500);
        Dm.InserirUsuarioAPI(edtContaNome.Text, edtContaEmail.Text, edtContaSenha.Text);
    end);

    t.OnTerminate := TerminateLogin;
    t.Start;
end;

procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmLogin := nil;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
    TabControl.Visible := false;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
begin
    timerAbertura.Enabled := true;
end;

procedure TFrmLogin.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
    lytCampos.Margins.Top := 0;
    lytLogo.Margins.Top := 20;
end;

procedure TFrmLogin.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
    lytCampos.Margins.Top := -170;
    lytLogo.Margins.Top := 0;
end;

procedure TFrmLogin.lblCriarContaClick(Sender: TObject);
begin
    TabControl.GotoVisibleTab(1);
end;

procedure TFrmLogin.lblLoginClick(Sender: TObject);
begin
    TabControl.GotoVisibleTab(0);
end;

end.
