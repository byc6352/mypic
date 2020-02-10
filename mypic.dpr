program mypic;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  uConfig in 'uConfig.pas',
  uLog in 'uLog.pas',
  uBrowseForFolder in 'uBrowseForFolder.pas',
  uFuncs in 'uFuncs.pas',
  uZip in 'uZip.pas',
  uDes2010 in 'uDes2010.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
