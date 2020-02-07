unit uBrowseForFolder;

interface
function BrowseForFolder(const browseTitle:string;const initialFolder:string=''):string;
implementation
uses Windows,shlobj;
var
  lg_StartFolder:string;
function BrowseForFolderCallBack(Wnd:HWND;uMsg:UINT;
  lParam,lpData:LPARAM):Integer stdcall;
begin
  if uMsg=BFFM_INITIALIZED then
    SendMessage(Wnd,BFFM_SETSELECTION,1,Integer(@lg_StartFolder[1]));
  result:=0;
end;
function BrowseForFolder(const browseTitle:string;
  const initialFolder:string=''):string;
const
  BIF_NEWDIALOGSTYLE=$40;
var
  browse_info:TBrowseInfo;
  folder:array[0..MAX_PATH] of char;
  find_context:PItemIDList;
begin
  FillChar(browse_info,SizeOf(browse_info),#0);
  lg_StartFolder:=initialFolder;
  browse_info.pszDisplayName:=@folder[0];
  browse_info.lpszTitle:=PChar(browseTitle);
  browse_info.ulFlags:=BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
  if initialFolder<>'' then
    browse_info.lpfn:=BrowseForFolderCallBack;
  find_context:=SHBrowseForFolder(browse_info);
  if Assigned(find_context) then
  begin
    if SHGetPathFromIDList(find_context,folder) then
      result:=folder
    else
      result:='';
    GlobalFreePtr(find_context);
  end
  else
    result:='';
end;
end.

{
调用代码：
uses
　BrowseForFolderU；
procedure TForm1.Button1Click(Sender: TObject);
var opath,dpath,omsg:String;
begin
  dpath:='c:';
  omsg:='请选择路径：';
  opath:=BrowseForFolder(omsg,dpath);
  if opath<>'' then Edit1.Text:=opath
  else
    Application.MessageBox('没有选择路径','系统提示',MB_OK+MB_ICONERROR);
end;

}
