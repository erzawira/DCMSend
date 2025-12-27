program Project1;

uses
  Forms,
  uDcmsend in 'uDcmsend.pas' {fSendDcm},
  uLoad in 'uLoad.pas' {fLoad};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfSendDcm, fSendDcm);
  Application.CreateForm(TfLoad, fLoad);
  Application.Run;
end.
