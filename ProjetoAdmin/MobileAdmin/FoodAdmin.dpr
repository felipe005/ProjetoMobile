program FoodAdmin;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  UnitConfiguracoes in 'UnitConfiguracoes.pas' {FrmConfiguracoes},
  UnitPedidoDetalhe in 'UnitPedidoDetalhe.pas' {FrmPedidoDetalhe},
  Frame.Produto in 'Frames\Frame.Produto.pas' {FrameProduto: TFrame},
  UnitCategoria in 'UnitCategoria.pas' {FrmCategoria},
  UnitCategoriaProd in 'UnitCategoriaProd.pas' {FrmCategoriaProd},
  UnitCategoriaProdCad in 'UnitCategoriaProdCad.pas' {FrmCategoriaProdCad},
  uCombobox in 'Units\uCombobox.pas',
  uLoading in 'Units\uLoading.pas',
  uFunctions in 'Units\uFunctions.pas',
  DataModule.Global in 'DataModules\DataModule.Global.pas' {Dm: TDataModule},
  u99Permissions in 'Units\u99Permissions.pas',
  FMX.MediaLibrary.Android in 'FMX.MediaLibrary.Android.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TDm, Dm);
  Application.Run;
end.
