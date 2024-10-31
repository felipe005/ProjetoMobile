unit uFunctions;

interface

uses FMX.Graphics, System.Net.HttpClient, System.Net.HttpClientComponent,
     System.Classes, System.SysUtils, FMX.ListBox, Frame.Produto;

procedure LoadImageFromURL(img: TBitmap; url: string);
procedure DownloadFotos(lb: TListBox);
function UTCtoDateBR(dt: string): string;

implementation

procedure LoadImageFromURL(img: TBitmap; url: string);
var
    http : TNetHTTPClient;
    vStream : TMemoryStream;
begin
    try
        try
            http := TNetHTTPClient.Create(nil);
            vStream :=  TMemoryStream.Create;

            if (Pos('https', LowerCase(url)) > 0) then
                  HTTP.SecureProtocols  := [THTTPSecureProtocol.TLS1,
                                            THTTPSecureProtocol.TLS11,
                                            THTTPSecureProtocol.TLS12];

            http.Get(url, vStream);
            vStream.Position  :=  0;


            img.LoadFromStream(vStream);
        except
        end;

    finally
        vStream.DisposeOf;
        http.DisposeOf;
    end;
end;

procedure DownloadFotos(lb: TListBox);
var
    t:TThread;
    foto: TBitmap;
    frame: TFrameProduto;
begin
    // Loop as lista e baixar fotos...
    t := TThread.CreateAnonymousThread(procedure
    var
        i: integer;
    begin
        sleep(1000);
        for i := 0 to lb.Items.Count - 1 do
        begin
            frame := TFrameProduto(lb.ItemByIndex(i).Components[0]);

            if frame.imgFoto.TagString <> '' then // URL da foto...
            begin
                foto := TBitmap.Create;
                LoadImageFromURL(foto, frame.imgFoto.TagString);

                //frame.lblNome.Text := frame.imgFoto.TagString;

                TThread.Synchronize(TThread.CurrentThread, procedure
                begin
                    frame.imgFoto.TagString := '';
                    frame.imgFoto.Bitmap := foto;
                end);

            end;
        end;
    end);

    t.Start;
end;

function UTCtoDateBR(dt: string): string;
begin
    // 2022-05-05T15:23:52.000Z
    Result := Copy(dt, 9, 2) + '/' + Copy(dt, 6, 2) + '/' + Copy(dt, 1, 4) + ' ' + Copy(dt, 12, 8);
end;

end.
