unit uConfig;

interface
uses
  Vcl.Forms,System.SysUtils,windows;
const
  DEBUG:boolean=false;
  APP_NAME='��Դ�����';
  APP_VERSION='v1.01';
  APP_CONTACT='��ϵ��ʽ��QQ:39848872΢��:byc6352';
  WORK_DIR:string='mypic';
  LOG_NAME:string='mypicLog.txt';
  KEY:string='182.16.38.162';
var
  workdir:string;//����Ŀ¼
  logfile:string;//
  apkfilename:string;
  isInit:boolean=false;

  procedure init();
implementation
procedure init();
var
    me:String;
begin
  isInit:=true;
  me:=application.ExeName;
  workdir:=extractfiledir(me)+'\'+WORK_DIR;
  if(not DirectoryExists(workdir))then ForceDirectories(workdir);

  logfile:=workdir+'\'+LOG_NAME;

end;
begin
  init();
end.
