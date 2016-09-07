program RemoteInject;

uses
  Forms,
  UMainform in 'UMainform.pas' {Form1},
  UProcessMgr in 'UProcessMgr.pas',
  untDrag in 'untDrag.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
