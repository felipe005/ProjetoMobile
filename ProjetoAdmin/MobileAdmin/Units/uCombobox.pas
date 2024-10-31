unit uCombobox;

interface

uses FMX.Layouts, FMX.Objects, FMX.Types, FMX.Forms, FMX.Graphics, FMX.Ani,
     FMX.StdCtrls, SysUtils, System.Types, Data.DB;

type
  TExecutaClickWin = procedure(Sender: TObject) of Object;
  TExecutaClickMobile = procedure(Sender: TObject; const Point: TPointF) of Object;

  TCustomCombobox = class
  private
    rectFundo, rectItem: TRectangle;
    vert : TVertScrollBox;
    ani : TFloatAnimation;
    btnBack, btnOK : TSpeedButton;
    lblTitulo, lblSubTitulo, lblItem : TLabel;
    FTitleMenuText, FSubTitleMenuText, FCodItem, FDescrItem : string;
    FTitleFontSize, FItemFontSize, FSubTitleFontSize, FSubItemFontSize : integer;
    FBackgroundColor, FTitleFontColor, FSubTitleFontColor, FItemFontColor, FItemBackgroundColor : Cardinal;
    FVisible, FMultiSelect: Boolean;

    {$IFDEF MSWINDOWS}
    ACallBack: TExecutaClickWin;
    {$ELSE}
    ACallBack: TExecutaClickMobile;
    {$ENDIF}

    procedure SetTitleFontColor(const Value: Cardinal);
    procedure SetTitleMenuText(const Value: string);
    procedure SetTitleFontSize(const Value: integer);
    procedure SetMultiSelect(const Value: Boolean);
    procedure ClickOK(Sender: TObject);

  public
    constructor Create(Frm: TForm);
    procedure ShowMenu();
    procedure ClickCancel(Sender: TObject);
    procedure HideMenu();
    procedure FinishFade(Sender: TObject);
    procedure ProcessFade(Sender: TObject);
    procedure AddItem(codItem: string; itemText: string);
    procedure ClearAll;
    procedure LoadFromDataset(ds: TDataSet; FieldId, FieldDescription: string);

    {$IFDEF MSWINDOWS}
    procedure ItemClick(Sender: TObject);
    {$ELSE}
    procedure ItemClick(Sender: TObject; const Point: TPointF);
    {$ENDIF}

  published
    property TitleMenuText: string read FTitleMenuText write SetTitleMenuText;
    property TitleFontSize: integer read FTitleFontSize write SetTitleFontSize;
    property TitleFontColor: Cardinal read FTitleFontColor write SetTitleFontColor;

    property SubTitleMenuText: string read FSubTitleMenuText write FSubTitleMenuText;
    property SubTitleFontSize: integer read FSubTitleFontSize write FSubTitleFontSize;
    property SubTitleFontColor: Cardinal read FSubTitleFontColor write FSubTitleFontColor;

    property ItemFontSize: integer read FItemFontSize write FItemFontSize;
    property ItemFontColor: Cardinal read FItemFontColor write FItemFontColor;
    property ItemBackgroundColor: Cardinal read FItemBackgroundColor write FItemBackgroundColor;

    property BackgroundColor: Cardinal read FBackgroundColor write FBackgroundColor;
    property Visible: Boolean read FVisible write FVisible;
    property CodItem: String read FCodItem write FCodItem;
    property DescrItem: String read FDescrItem write FDescrItem;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;

    {$IFDEF MSWINDOWS}
    property OnClick: TExecutaClickWin read ACallBack write ACallBack;
    {$ELSE}
    property OnClick: TExecutaClickMobile read ACallBack write ACallBack;
    {$ENDIF}


end;


implementation



constructor TCustomCombobox.Create(Frm: TForm);
begin
    FTitleMenuText := 'Escolha uma opção';
    FTitleFontSize := 18;
    FTitleFontColor := $FF1F2035;

    FSubTitleMenuText := '';
    FSubTitleFontSize := 15;
    FSubTitleFontColor := $FF9E9EB4;

    FItemFontSize := 15;
    FItemFontColor := $FF1F2035;
    FItemBackgroundColor := $FFFFFFFF;

    FMultiSelect := false;

    FBackgroundColor := $FFFFFFFF;


    // Cria rect de fundo...
    rectFundo := TRectangle.Create(Frm);
    with rectFundo do
    begin
        Align := TAlignLayout.Contents;
        Fill.Kind := TBrushKind.Solid;
        Fill.Color := FBackgroundColor;
        BringToFront;
        HitTest := true;
        Margins.Right := (Frm.Width + 100) * -1;
        Visible := false;
        Stroke.Kind := TBrushKind.None;
        Padding.Left := 20;
        Padding.Right := 20;
        Tag := 0;
    end;
    Frm.AddObject(rectFundo);


    // Cria animacao de entrada do fundo...
    ani := TFloatAnimation.Create(rectFundo);
    with ani do
    begin
        PropertyName := 'Margins.Right';
        StartValue := (Frm.Width + 100) * -1;
        StopValue := 0;
        Inverse := false;
        Duration := 0.3;
        OnFinish := FinishFade;
        OnProcess := ProcessFade;
    end;
    rectFundo.AddObject(ani);


    // Label com titulo da tela...
    lblTitulo := TLabel.Create(rectFundo);
    with lblTitulo do
    begin
        Text := FTitleMenuText;
        Align := TAlignLayout.MostTop;
        Height := 50;
        VertTextAlign := TTextAlign.Center;
        TextAlign := TTextAlign.Center;
        StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
        Font.Size := FTitleFontSize;
        FontColor := FTitleFontColor;
        //AutoSize := true;
        Margins.Top := 0;
        Margins.Bottom := 0;
    end;
    rectFundo.AddObject(lblTitulo);


    // Label com subtitulo da tela...
    lblSubTitulo := TLabel.Create(rectFundo);
    with lblSubTitulo do
    begin
        Text := FSubTitleMenuText;
        Align := TAlignLayout.MostTop;
        Height := 20;
        VertTextAlign := TTextAlign.Center;
        TextAlign := TTextAlign.Center;
        StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
        Font.Size := FSubTitleFontSize;
        FontColor := FSubTitleFontColor;
        //AutoSize := true;
        Margins.Top := 0;
        Margins.Bottom := 0;
    end;
    rectFundo.AddObject(lblSubTitulo);


    // Layout que vai conter o botao cancelar...
    vert := TVertScrollBox.Create(rectFundo);
    with vert do
    begin
        Align := TAlignLayout.Client;
        ShowScrollBars := false;
        Margins.Top := 20;
        Margins.Bottom := 20;
        Visible := true;
    end;
    rectFundo.AddObject(vert);


    // Botao voltar...
    btnBack := TSpeedButton.Create(rectFundo);
    with btnBack do
    begin
        Width := 48;
        Height := 48;
        Position.X := 13;
        Position.Y := 5;
        BringToFront;
        StyleLookup := 'backtoolbutton';
        Text := '';
        OnClick := ClickCancel;
        IconTintColor := $FFC64848;
    end;
    rectFundo.AddObject(btnBack);


    // Botao salvar (para casos de multiselect)...
    btnOk := TSpeedButton.Create(rectFundo);
    with btnOK do
    begin
        Width := 48;
        Height := 48;
        Position.X := Frm.Width - btnOK.Width - 13;
        Position.Y := 5;
        BringToFront;
        StyleLookup := 'donetoolbutton';
        FontColor := $FFC64848;

        {$IFDEF MSWINDOWS}
        Text := 'OK';
        {$ELSE}
        Text := '';
        {$ENDIF}

        OnClick := ClickOK;
        IconTintColor := $FFC64848;
        Visible := FMultiSelect;
    end;
    rectFundo.AddObject(btnOK);


    {
    // Fundo do cancelar...
    rectCancelar := TRectangle.Create(rectMenu);
    with rectCancelar do
    begin
        Align := TAlignLayout.Bottom;
        Fill.Kind := TBrushKind.Solid;
        Fill.Color := FMenuColor;
        Opacity := 1;
        BringToFront;
        Visible := true;
        HitTest := true;
        XRadius := 10;
        YRadius := 10;
        Margins.Bottom := -60;
        Height := 50;
        Parent := rectMenu;
        Stroke.Kind := TBrushKind.None;
    end;
    rectMenu.AddObject(rectCancelar);


    // Label cancelar
    lblCanc := TLabel.Create(rectCancelar);
    with lblCanc do
    begin
        Text := FCancelMenuText;
        Align := TAlignLayout.Client;
        VertTextAlign := TTextAlign.Center;
        TextAlign := TTextAlign.Center;
        StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
        Font.Size := FCancelFontSize;
        FontColor := FCancelFontColor;
        HitTest := true;
        OnClick := ClickBackground;
    end;
    rectCancelar.AddObject(lblCanc);
    }
end;

procedure TCustomCombobox.ClickCancel(Sender: TObject);
begin
    FCodItem := '';
    FDescrItem := '';
    HideMenu;
end;

procedure TCustomCombobox.ClickOK(Sender: TObject);
var
    x : integer;
begin
    FCodItem := '';
    FDescrItem := '';

    for x := 0 to vert.ComponentCount - 1 do
        if vert.Components[x] is TRectangle then
            if TRectangle(vert.Components[x]).Tag = 1 then
            begin
                if FCodItem <> '' then
                begin
                    FCodItem := FCodItem + ', ';
                    FDescrItem := FDescrItem + ', ';
                end;

                FCodItem := FCodItem + TLabel(TRectangle(vert.Components[x]).FindComponent('lblItem')).TagString;
                FDescrItem := FDescrItem + TLabel(TRectangle(vert.Components[x]).FindComponent('lblItem')).Text;
            end;

    HideMenu;

    {$IFDEF MSWINDOWS}
    ACallBack(Sender);
    {$ELSE}
    ACallBack(Sender, TPointF.Create(0, 0));
    {$ENDIF}
end;

{$IFDEF MSWINDOWS}
procedure TCustomCombobox.ItemClick(Sender: TObject);
begin
    FCodItem := TLabel(Sender).TagString;
    FDescrItem := TLabel(Sender).Text;

    if NOT FMultiSelect then
    begin
        ACallBack(Sender);
        HideMenu;
    end
    else
    begin
        if TRectangle(TLabel(Sender).Parent).Tag = 0 then
        begin
            TRectangle(TLabel(Sender).Parent).Fill.Color := $FFCCCCCC;
            TRectangle(TLabel(Sender).Parent).Tag := 1;
        end
        else
        begin
            TRectangle(TLabel(Sender).Parent).Fill.Color := FItemBackgroundColor;
            TRectangle(TLabel(Sender).Parent).Tag := 0;
        end
    end;

end;
{$ELSE}
procedure TCustomCombobox.ItemClick(Sender: TObject; const Point: TPointF);
begin
    FCodItem := TLabel(Sender).TagString;
    FDescrItem := TLabel(Sender).Text;

    if NOT FMultiSelect then
    begin
        ACallBack(Sender, Point);
        HideMenu;
    end
    else
    begin
        if TRectangle(TLabel(Sender).Parent).Tag = 0 then
        begin
            TRectangle(TLabel(Sender).Parent).Fill.Color := $FFCCCCCC;
            TRectangle(TLabel(Sender).Parent).Tag := 1;
        end
        else
        begin
            TRectangle(TLabel(Sender).Parent).Fill.Color := FItemBackgroundColor;
            TRectangle(TLabel(Sender).Parent).Tag := 0;
        end
    end;

end;
{$ENDIF}

procedure TCustomCombobox.SetMultiSelect(const Value: Boolean);
begin
  FMultiSelect := Value;
  btnOk.Visible := Value;
end;

procedure TCustomCombobox.SetTitleFontColor(const Value: Cardinal);
begin
  FTitleFontColor := Value;
  lblTitulo.FontColor := Value;
end;

procedure TCustomCombobox.SetTitleFontSize(const Value: integer);
begin
  FTitleFontSize := Value;
  lblTitulo.Font.Size := Value;
end;

procedure TCustomCombobox.SetTitleMenuText(const Value: string);
begin
  FTitleMenuText := Value;
  lblTitulo.Text := Value;
end;

procedure TCustomCombobox.ShowMenu();
begin
    // Volta scroll para o inicio...
    vert.ViewportPosition := TPointF.Zero;

    // Acerta o fundo opaco...
    rectFundo.Visible := true;
    FVisible := true;
    rectFundo.Fill.Color := FBackgroundColor;

    ani.Inverse := false;
    ani.Start;


    // Acerta titulo do menu...
    if Trim(FTitleMenuText) = '' then
        lblTitulo.Height := 0
    else
    begin
        lblTitulo.Height := 50;
        lblTitulo.Margins.Top := 50;
        lblTitulo.Margins.Bottom := 10;
    end;

    lblTitulo.Font.Size := FTitleFontSize;
    lblTitulo.Text := FTitleMenuText;

    // Acerta subtitulo do menu...
    if Trim(FSubTitleMenuText) = '' then
        lblSubTitulo.Height := 0
    else
    begin
        lblSubTitulo.Height := 20;

        if lblTitulo.Height > 0 then
            lblSubTitulo.Margins.Top := 10
        else
            lblSubTitulo.Margins.Top := 50;

        lblSubTitulo.Margins.Bottom := 10;
    end;

    lblSubTitulo.Font.Size := FSubTitleFontSize;
    lblSubTitulo.Text := FSubTitleMenuText;

end;

procedure TCustomCombobox.AddItem(codItem: string; itemText: string);
begin

    // Fundo do item...
    rectItem := TRectangle.Create(vert);
    with rectItem do
    begin
        Align := TAlignLayout.MostTop;
        Fill.Kind := TBrushKind.Solid;
        Fill.Color := FItemBackgroundColor;
        HitTest := true;
        XRadius := 6;
        YRadius := 6;
        Margins.Bottom := 10;
        Height := 60;
        Stroke.Kind := TBrushKind.None;
    end;
    vert.AddObject(rectItem);


    lblItem := TLabel.Create(rectItem);
    with lblItem do
    begin
        Text := itemText;
        Align := TAlignLayout.Client;
        VertTextAlign := TTextAlign.Center;
        TextAlign := TTextAlign.Leading;
        StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
        Font.Size := FItemFontSize;
        FontColor := FItemFontColor;
        HitTest := true;
        Margins.Left := 10;
        Margins.Right := 10;
        TagString := codItem;
        Name := 'lblItem';

        {$IFDEF MSWINDOWS}
        OnClick := ItemClick;
        {$ELSE}
        OnTap := ItemClick;
        {$ENDIF}
    end;
    rectItem.AddObject(lblItem);

    vert.Repaint;
end;

procedure TCustomCombobox.FinishFade(Sender: TObject);
begin
    rectFundo.Visible := FVisible;
end;

procedure TCustomCombobox.ProcessFade(Sender: TObject);
begin
    rectFundo.Margins.Left := rectFundo.Margins.Right * -1;
end;

procedure TCustomCombobox.HideMenu();
begin
    FVisible := false;

    ani.Delay := 0;
    ani.Inverse := true;
    ani.Start;
end;

procedure TCustomCombobox.ClearAll();
var
    x : integer;
begin
    for x := vert.ComponentCount - 1 downto 0 do
        if vert.Components[x] is TRectangle then
            TRectangle(vert.Components[x]).DisposeOf;
end;

procedure TCustomCombobox.LoadFromDataset(ds: TDataSet; FieldId, FieldDescription : string);
begin
    ClearAll;

    while NOT ds.Eof do
    begin
        AddItem(ds.FieldByName(FieldId).AsString,
                ds.FieldByName(FieldDescription).AsString);

        ds.Next;
    end;
end;


end.
