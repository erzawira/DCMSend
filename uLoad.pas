unit uLoad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellApi, IdHTTP, IdGlobal, IdIOHandlerSocket,
  IdMultipartFormData, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdAuthentication, IdTCPServer, IdCustomHTTPServer,
  IdHTTPServer, ADODB, DB, ZConnection, ZAbstractRODataset, ZAbstractDataset,
  ZDataset, ZAbstractConnection, XMLIntf, XMLDoc, IniFiles, Grids, DBGrids,
  ExtCtrls, jpeg, XPMan, CurvyControls, TaskDialog, AdvShape,
  AdvGlassButton, AdvSmoothButton, AdvGlowButton, AdvSmoothToggleButton,
  W7Classes, W7Buttons, AdvCircularProgress, DCPcrypt2, DCPsha256, DCPrijndael,
  EncdDecd;

type
  TfLoad = class(TForm)
    AdvCircularProgress1: TAdvCircularProgress;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    DCP_sha2561: TDCP_sha256;
    procedure FormClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  Procedure KoneksiDB;
  Procedure Dekripsi;
  end;

var
  fLoad: TfLoad;
  detik:integer;
  koneksi : TIniFile;
  Hostname,User,Password,Database,Protokol,Port,Nama,HostnameOrthanc,
  UserOrthanc,PasswordOrthanc :string;

implementation

uses uDcmsend;

{$R *.dfm}

procedure TfLoad.FormClick(Sender: TObject);
begin
Close;
detik:=0;
end;

procedure TfLoad.Timer1Timer(Sender: TObject);
begin
detik:=detik+1;
Label2.Caption:=Label2.Caption+'..';

  if detik = 1 then
  begin
    fSendDcm.Bersih;
    Label2.Caption := 'Menginisialisasi Modul...';
  end;

  if detik = 5 then
  begin
    Label2.Caption := 'Connection Database...';
  end;

  if detik = 8 then
  begin
    KoneksiDB;
  end;
   
  if detik = 11 then
  begin
    Label2.Caption := 'Sedikit Lagi...';
  end;

  if detik = 12 then
  begin
    Label2.Caption := 'Selesai...';
  end;
  
  if detik = 14 then
  begin
    Timer1.Enabled := False;
    Close;
  end;
end;

procedure TfLoad.FormActivate(Sender: TObject);
begin
Label2.Caption :='';
end;

function DekripsiAES(TeksTerinkripsi, Kunci: string): string;
var
  Cipher: TDCP_rijndael;
begin
  if TeksTerinkripsi = '' then Exit;

  Cipher := TDCP_rijndael.Create(nil);
  try
    Cipher.InitStr(Kunci, TDCP_sha256);
    // Dekode dari Base64 kembali ke biner, lalu didekripsi
    Result := Cipher.DecryptString(DecodeString(TeksTerinkripsi));
    Cipher.Burn;
  finally
    Cipher.Free;
  end;
end;

procedure TfLoad.KoneksiDB;
begin
Dekripsi;

if (fSendDcm.ZConnection1.Connected) then
fSendDcm.zConnection1.Disconnect;
fSendDcm.ZConnection1.HostName := Hostname;
fSendDcm.ZConnection1.User     := User;
fSendDcm.ZConnection1.Password := Password;
fSendDcm.ZConnection1.Port     := StrToInt(Port);
fSendDcm.ZConnection1.Database := Database;
fSendDcm.ZConnection1.Protocol := Protokol;
fSendDcm.ZConnection1.LibraryLocation := ExtractFilePath(Application.ExeName)+'\libmysql.dll';
ORTHANC_URL           := ORTHANC_URL;
USERNAME              := UserOrthanc;
PASSWORD              := PasswordOrthanc;
ORTHANC_URL           := ORTHANC_URL+'instances';
NamaRS                := NamaRS;

 try
  fSendDcm.ZConnection1.Connect;
  fSendDcm.zConnection1.Connected    :=True;
    if (fSendDcm.ZConnection1.Connected)  then
      begin
      Label2.Caption := 'Connection Sukses...';
      end
        except
        Label2.Caption := 'Connection Gagal...';
        Application.Terminate;
        end;
end;

procedure TfLoad.Dekripsi;
var
  Hostname1,User1,Password1,Database1,Protokol1,Port1,Nama1,HostnameOrthanc1,
  UserOrthanc1,PasswordOrthanc1 :string;
begin
koneksi := TIniFile.Create(ExtractFilePath(Application.ExeName)+ 'conf.ini'); //tipe single database

Hostname1       :=koneksi.ReadString('Database','Hostname','');
User1           :=koneksi.ReadString('Database','User','');
Password1       :=koneksi.ReadString('Database','Password','');
Port1           :=koneksi.ReadString('Database','Port','');
Database1       :=koneksi.ReadString('Database','Database','');
Protokol1       :=koneksi.ReadString('Database','Protokol','');
HostnameOrthanc1:=koneksi.ReadString('Orthanc','HostnameOrthanc','');
UserOrthanc1    :=koneksi.ReadString('Orthanc','UserOrthanc','');
PasswordOrthanc1:=koneksi.ReadString('Orthanc','PasswordOrthanc','');
Nama1           :=koneksi.ReadString('Orthanc','Nama','');

Hostname       :=Hostname1;
User           :=DekripsiAES(User1, 'KaKaBersaudara');
Password       :=DekripsiAES(Password1, 'KaKaBersaudara');
Port           :=Port1;
Database       :=DekripsiAES(Database1, 'KaKaBersaudara');
Protokol       :=Protokol1;
HostnameOrthanc:=HostnameOrthanc1;
UserOrthanc    :=DekripsiAES(UserOrthanc1, 'KaKaBersaudara');
PasswordOrthanc:=DekripsiAES(PasswordOrthanc, 'KaKaBersaudara');
Nama           :=Nama1;
end;

end.
