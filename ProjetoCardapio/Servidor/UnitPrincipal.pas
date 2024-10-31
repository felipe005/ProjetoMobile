unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects;

type
  TFrmPrincipal = class(TForm)
    Image1: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses Horse,
     Horse.Jhonson,
     Horse.CORS,
     Controllers.Cardapio,
     Controllers.Pedido,
     Controllers.Config,
     Controllers.Usuario;


procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
    THorse.Use(Jhonson());
    THorse.Use(CORS);

    Controllers.Cardapio.RegistrarRotas;
    Controllers.Pedido.RegistrarRotas;
    Controllers.Config.RegistrarRotas;
    Controllers.Usuario.RegistrarRotas;

    THorse.Listen(9030);
end;

end.
