unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,shellapi,
  uLog,uConfig,uBrowseForFolder,uFuncs, Vcl.OleCtrls, SHDocVw,IdGlobalProtocols;

type
  TfMain = class(TForm)
    Bar1: TStatusBar;
    Panel1: TPanel;
    btnOpen: TButton;
    btnClose: TButton;
    cmbDir: TComboBox;
    Page1: TPageControl;
    tspic: TTabSheet;
    tsHtm: TTabSheet;
    tsText: TTabSheet;
    ListFile: TListBox;
    Splitter1: TSplitter;
    Image1: TImage;
    Memo1: TMemo;
    Panel2: TPanel;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    MemoHTMLcode: TMemo;
    MemoHTMLmodel: TMemo;
    Web1: TWebBrowser;
    procedure btnOpenClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure ListFileClick(Sender: TObject);
    procedure Web1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure LoadHTMLfile(filename:string);
    procedure LoadHTMLImagefile(filename:string);
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}
procedure TfMain.LoadHTMLImagefile(filename:string);
var
  line:string;
begin

try
  line:='<img src="'+filename+'"></img>';
  memoHTMLcode.Lines.Text:=memoHTMLmodel.Lines.Text;
  memoHTMLcode.Lines.Insert(8,line);
  WBLoadHTML(web1,memoHTMLcode.Lines);

finally

end;
end;
procedure TfMain.LoadHTMLfile(filename:string);
var
  line:string;
  ss:tstrings;
begin
  ss:=tstringlist.Create;
try
  ss.LoadFromFile(filename,TEncoding.UTF8);
  //memoHTMLcode.Lines.LoadFromFile(filename);
  line:=LowerCase(ss[0]);
  if(pos('html',line)<=0)then
  begin
    memoHTMLcode.Lines.Text:=memoHTMLmodel.Lines.Text;
    memoHTMLcode.Lines.Insert(8,ss.Text);
    WBLoadHTML(web1,memoHTMLcode.Lines);
  end else begin
    WBLoadHTML(web1,ss);
  end;
finally
  ss.Free;
end;
end;
procedure TfMain.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TfMain.btnOpenClick(Sender: TObject);
var opath,dpath,omsg:String;
begin
  dpath:='c:';
  omsg:='��ѡ��·����';
  opath:=BrowseForFolder(omsg,dpath);
  if opath<>'' then cmbDir.Text:=opath
  else begin
    Application.MessageBox('û��ѡ��·��','ϵͳ��ʾ',MB_OK+MB_ICONERROR);
    exit;
  end;
  ListFile.Items:=uFuncs.MakeFileList(opath,'.*');
  bar1.Panels[1].Text:=''+inttostr(listFile.Items.Count)+'���ļ�';
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  //IEEmulator();
  IEEmulator(11001);
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  fmain.Caption:=uConfig.APP_NAME+uConfig.APP_VERSION+uConfig.APP_CONTACT;
end;

procedure TfMain.ListFileClick(Sender: TObject);
var
  filename,fileext:string;
  filesize:integer;
begin
  filename:=Listfile.Items[Listfile.ItemIndex];
  filesize:=FileSizeByName(filename);
  bar1.Panels[0].Text:=filename+'  size='+inttostr(filesize)+' ��'+inttostr(Listfile.ItemIndex)+'��';
  if(filesize=0)then exit;
  fileext:=extractfileext(filename);
  if(fileext='.htm')or(fileext='.html')or(fileext='.txt')or(pos('.htm',filename)>0)then
  begin
    page1.ActivePage:=tsHtm;
    LoadHTMLfile(filename);
    exit;
  end;
  if(uFuncs.CheckImageType(filename)<>IT_None)then
  begin
    LoadHTMLImagefile(filename);
    exit;
  end;
  ShellExecute(Handle,pchar('open'), pchar('explorer.exe'), pchar(filename), nil, SW_SHOW);
end;

procedure TfMain.Web1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
begin
  Web1.Silent := True;
end;

end.