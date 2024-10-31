unit Frame.Produto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation;

type
  TFrameProduto = class(TFrame)
    imgFoto: TImage;
    Layout1: TLayout;
    lblNome: TLabel;
    lblPreco: TLabel;
    lblDescricao: TLabel;
    Line1: TLine;
    Layout2: TLayout;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
