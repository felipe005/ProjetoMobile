program Food;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  Frame.Produto in 'Frames\Frame.Produto.pas' {FrameProduto: TFrame},
  Frame.Categoria in 'Frames\Frame.Categoria.pas' {FrameCategoria: TFrame},
  uLoading in 'Units\uLoading.pas',
  UnitCheckout in 'UnitCheckout.pas' {FrmCheckout},
  UnitPedido in 'UnitPedido.pas' {FrmPedido},
  DataModule.Global in 'DataModules\DataModule.Global.pas' {Dm: TDataModule},
  uFunctions in 'Units\uFunctions.pas',
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  uSession in 'Units\uSession.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDm, Dm);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
