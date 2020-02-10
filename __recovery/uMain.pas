unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,shellapi,
  uLog,uConfig,uBrowseForFolder,uFuncs, Vcl.OleCtrls, SHDocVw,IdGlobalProtocols,strutils,
  uZip,uDes2010,system.zip, Vcl.Menus;

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
    Memoplayer: TMemo;
    Panel2: TPanel;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    MemoHTMLcode: TMemo;
    MemoHTMLmodel: TMemo;
    Web1: TWebBrowser;
    btnDecrypt: TButton;
    popListFile: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure btnOpenClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure ListFileClick(Sender: TObject);
    procedure Web1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDecryptClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
  private
    { Private declarations }
    procedure LoadHTMLfile(filename:string);
    procedure LoadHTMLImagefile(filename:string);
    procedure decryptfile(ss:tstrings);
    procedure LoadHTMLmp4file(filename:string);
    procedure playfile(filename:string);
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}
procedure TfMain.playfile(filename:string);
begin
  Shellexecute(handle,pchar('open'),pchar(uConfig.playfile),pchar(' -autoexit '+filename),nil,sw_normal);
end;
procedure TfMain.decryptfile(ss:tstrings);
const
  FILE_NAME_ID='x';
var
  i:integer;
  filename,newfilename,newdir:string;
begin
  for I := 0 to ss.Count-1 do
  begin
    filename:=ss[i];
    if(filename[length(filename)]<>FILE_NAME_ID)then continue;
    if(FileSizeByName(filename)=0)then
    begin
      deletefile(filename);
      continue;
    end;
    uFuncs.cryptfile(filename);
    newfilename:=leftstr(filename,length(filename)-1);
    newfilename:=extractfilepath(newfilename)+uDes2010.DecryStrHex(extractfilename(newfilename),uConfig.key);
    movefile(pchar(filename),pchar(newfilename));
    newdir:=leftstr(newfilename,length(newfilename)-4);
    if(TZipFile.IsValid(newfilename))then
    TZipFile.ExtractZipFile(newfilename, newdir);
    //uzip.DirectoryDecompression(newdir,newfilename);
  end;
end;
{

<object width="500" height="300" data="http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"></object>
}
procedure TfMain.LoadHTMLmp4file(filename:string);
var
  line:string;
  //ss:tstrings;
begin

try
  line:='<video controls="controls" autoplay="autoplay" loop="loop" name="media"><source src="'+filename+'" type="video/mp4"></video>';
  //line:='<object width="500" height="300" data="'+filename+'"></object>';
  //line:='<embed src="'+filename+'" width="500" height="300">';
  //ss:=tstringlist.Create;
  //ss.Text:=memoplayer.Text;
  //ss.Text:=StringReplace (ss.Text, '1.mp4',filename, [rfReplaceAll]);
  memoHTMLcode.Lines.Text:=memoHTMLmodel.Lines.Text;
  memoHTMLcode.Lines.Insert(8,line);
  WBLoadHTML(web1,memoHTMLcode.Lines);
  playfile(filename);
finally
  //ss.Free;
end;
end;
procedure TfMain.N1Click(Sender: TObject);
var
  filename:string;
begin
  if listFile.Count=0 then exit;
  if listFile.ItemIndex=-1 then  exit;
  filename:=listFile.Items[listFile.ItemIndex];
  ShellExecute(Handle,pchar('open'), pchar('explorer.exe'), pchar('/select,'+filename), nil, SW_SHOW);
end;

procedure TfMain.N2Click(Sender: TObject);
var
  filename:string;
begin
  if listFile.Count=0 then exit;
  if listFile.ItemIndex=-1 then  exit;
  filename:=listFile.Items[listFile.ItemIndex];
  ShellExecute(Handle,pchar('open'), pchar('explorer.exe'), pchar(filename), nil, SW_SHOW);

end;

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

procedure TfMain.btnDecryptClick(Sender: TObject);
begin
  if(listfile.Items.Count=0)then
  begin
    showmessage('请先选择目录！');
    exit;
  end;
  decryptfile(listfile.Items);
  ListFile.Items:=uFuncs.MakeFileList(cmbdir.Text,'.*');
  bar1.Panels[1].Text:=''+inttostr(listFile.Items.Count)+'个文件';
end;

procedure TfMain.btnOpenClick(Sender: TObject);
var opath,dpath,omsg:String;
begin
  dpath:='c:\temp';
  omsg:='请选择路径：';
  opath:=BrowseForFolder(omsg,dpath);
  if opath<>'' then cmbDir.Text:=opath
  else begin
    Application.MessageBox('没有选择路径','系统提示',MB_OK+MB_ICONERROR);
    exit;
  end;
  ListFile.Items:=uFuncs.MakeFileList(opath,'.*');
  bar1.Panels[1].Text:=''+inttostr(listFile.Items.Count)+'个文件';
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  //IEEmulator();
  IEEmulator(11001);
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  //fmain.Caption:=uConfig.APP_NAME+uConfig.APP_VERSION+uConfig.APP_CONTACT;
  fmain.Caption:=uConfig.APP_NAME+uConfig.APP_VERSION;
end;

procedure TfMain.ListFileClick(Sender: TObject);
var
  filename,fileext:string;
  filesize:integer;
begin
  filename:=Listfile.Items[Listfile.ItemIndex];
  filesize:=FileSizeByName(filename);
  bar1.Panels[0].Text:=filename+'  size='+inttostr(filesize)+' 第'+inttostr(Listfile.ItemIndex)+'个';
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
  if(uFuncs.ismp4(filename))then
  begin
    LoadHTMLmp4file(filename);
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
