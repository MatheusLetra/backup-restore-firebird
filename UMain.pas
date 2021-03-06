unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Def, FireDAC.VCLUI.Wait,
  FireDAC.Phys.IBWrapper, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB, Data.DB, FireDAC.Comp.Client, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Imaging.GIFImg;

const
  CAMINHO_BACKUP = 'C:\Backups\backup.fbk';
  CAMINHO_RESTORE = 'C:\Restores\BancoRestaurado.fdb';

type
  TForm1 = class(TForm)
    Backup: TFDIBBackup;
    Restore: TFDIBRestore;
    DriverLink: TFDPhysFBDriverLink;
    Panel1: TPanel;
    MessagesBackup: TMemo;
    edOrigem: TEdit;
    SpeedButton1: TSpeedButton;
    DriverLink2: TFDPhysFBDriverLink;
    Label1: TLabel;
    SelecionaBanco: TOpenDialog;
    BtnIniciar: TPanel;
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure BackupProgress(ASender: TFDPhysDriverService;
      const AMessage: string);
    procedure RestoreProgress(ASender: TFDPhysDriverService;
      const AMessage: string);
    procedure BtnIniciarClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    procedure initConfigs();
    procedure BackupRestore();
    procedure StartAnimate(Image: TImage; LabelText: TLabel; Text: String;
      Button: TPanel);
    procedure StopAnimate(Image: TImage; LabelText: TLabel; Text: String;
      Button: TPanel);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BackupProgress(ASender: TFDPhysDriverService;
  const AMessage: string);
begin
  MessagesBackup.Lines.Add('Backup: ' + AMessage);
end;

procedure TForm1.BackupRestore;
begin
  StartAnimate(Image1, Label2, 'Processando...', BtnIniciar);
  Backup.Database := UpperCase(edOrigem.Text);
  TThread.CreateAnonymousThread(
    procedure
    begin
      Backup.Backup;
      Restore.Restore;;

      TThread.Synchronize(nil,
        procedure
        begin
          StopAnimate(Image1, Label2, 'Iniciar', BtnIniciar);
          MessageDlg('Backup/Restore Realizado com Sucesso!', mtInformation,
            [mbOk], 0);
        end);
    end).Start;
end;

procedure TForm1.BtnIniciarClick(Sender: TObject);
begin
  if Trim(edOrigem.Text) <> '' then
    BackupRestore;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  initConfigs;
end;

procedure TForm1.initConfigs;
begin
  if not DirectoryExists('C:\Backups') then
    ForceDirectories('C:\Backups');

  if not DirectoryExists('C:\Restores') then
    ForceDirectories('C:\Restores');

  if FileExists(CAMINHO_BACKUP) then
    DeleteFile(CAMINHO_BACKUP);

  if FileExists(CAMINHO_RESTORE) then
    DeleteFile(CAMINHO_RESTORE);

  DriverLink.DriverID := 'FB';
  DriverLink.VendorLib := 'fbclient.dll';
  Backup.UserName := 'SYSDBA';
  Backup.Password := 'masterkey';
  Backup.Protocol := ipLocal;
  Backup.Verbose := True;
  Backup.Host := 'localhost';
  Backup.BackupFiles.Clear;
  Backup.BackupFiles.Add(CAMINHO_BACKUP);

  DriverLink2.DriverID := 'FB';
  DriverLink2.VendorLib := 'fbclient.dll';
  Restore.UserName := 'SYSDBA';
  Restore.Password := 'masterkey';
  Restore.Host := 'localhost';
  Restore.Protocol := ipLocal;
  Restore.Verbose := True;
  Restore.Database := CAMINHO_RESTORE;
  Restore.BackupFiles.Add(CAMINHO_BACKUP);

  SelecionaBanco.Filter := 'Arquivos Firebird (*.fdb)|*.fdb';
end;

procedure TForm1.RestoreProgress(ASender: TFDPhysDriverService;
const AMessage: string);
begin
  MessagesBackup.Lines.Add('Restore: ' + AMessage);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  if SelecionaBanco.Execute = True then
  begin
    edOrigem.Text := UpperCase(SelecionaBanco.FileName);
  end;
end;

procedure TForm1.StartAnimate(Image: TImage; LabelText: TLabel; Text: String;
Button: TPanel);
begin
  (Image.Picture.Graphic as TGIFImage).AnimationSpeed := 50;
  (Image.Picture.Graphic as TGIFImage).Animate := True;
  LabelText.Caption := Text;
  Button.Enabled := False;
end;

procedure TForm1.StopAnimate(Image: TImage; LabelText: TLabel; Text: String;
Button: TPanel);
begin
  (Image.Picture.Graphic as TGIFImage).Animate := False;
  LabelText.Caption := Text;
  Button.Enabled := True;
end;

end.
