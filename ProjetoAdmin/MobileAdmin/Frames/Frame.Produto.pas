unit Frame.Produto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation;

type
  TFrameProduto = class(TFrame)
    imgFoto: TImage;
    lblPreco: TLabel;
    Layout1: TLayout;
    lblNome: TLabel;
    lblDescricao: TLabel;
    Layout2: TLayout;
    imgUp: TImage;
    imgDown: TImage;
    Line1: TLine;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
