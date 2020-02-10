unit uFuncs;

interface
uses
  windows, SysUtils,strutils,classes,forms,ShellAPI,registry, SHDocVw,ActiveX;

type
  TImageType = (IT_None, IT_Error, IT_Bmp, IT_JPEG, IT_GIF, IT_PCX, IT_PNG,
    IT_PSD, IT_RAS, IT_SGI, IT_TIFF);

  function MakeFileList(Path,FileExt:string):TStringList ;
  procedure IEEmulator(VerCode: Integer);overload;
  function IEEmulator(): Boolean;overload;
  function IsWin64: Boolean;
  procedure  WBLoadHTML(WebBrowser:  TWebBrowser;  HTMLCode:  tstrings);
  function CheckImageType(FileName: string): TImageType;
  function cryptfile(const filename: string):boolean;
  function ismp4(FileName: string): boolean;
implementation

function cryptfile(const filename: string):boolean;
const
  MAX_BUF=1024;
  XOR_KEY:byte=10;
var
 hFile:THandle;
 hMap:THandle;
 p:pbyte;
 filesize,bufsize,i:integer;
begin
  result:=false;
try
  hFile := CreateFile(PChar(filename),GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
  if hFile = INVALID_HANDLE_VALUE then Exit;
  filesize := GetFileSize(hFile,nil);
  if(filesize=0)then exit;
  if filesize>MAX_BUF then bufsize:=MAX_BUF else bufsize:=filesize;

  //����ӳ��
  hMap := CreateFileMapping(hFile,nil,PAGE_READWRITE,0,0,nil);
  if hMap = 0 then Exit;
  p:= PBYTE(MapViewOfFile(hMap,FILE_MAP_ALL_ACCESS,0,0,bufsize));
  if p=nil then exit;
  for i := 0 to bufsize-1 do
  begin
    p^:=p^ xor  XOR_KEY;
    inc(p);
  end;
  UnmapViewOfFile(p);
  result:=true;
finally
  CloseHandle(hMap);
  CloseHandle(hFile);
end;
end;


{-------------------------------------------------------------------------------
������:    ismp4 mp4�ж�
����:      FileName:  string;  1.�ļ���
����ֵ:    boolean;�Ƿ���mp4
-------------------------------------------------------------------------------}
function ismp4(FileName: string): boolean;
const
  MP4_ID_1:ansiString='ftypisom';
  MP4_ID_2:ansiString='ftypmp4';
var
  ms: TMemoryStream;
  buf: array[0..7] of ansiChar;
  ftyp:ansiString;
begin
  result:=false;
  ms := TMemoryStream.Create;
  try
    ms.LoadFromFile(FileName);
    if(ms.Size=0)then exit;
    ms.Position := 4;
    ms.ReadBuffer(buf,8);
    ftyp:=buf;
    if(pos(MP4_ID_1,ftyp)>0)or(pos(MP4_ID_1,ftyp)>0)then
    begin
      result:=true;
      exit;
    end;
  finally
    ms.Free;
  end;
end;

{-------------------------------------------------------------------------------
������:    CheckImageType ͼƬ�ж�
����:      FileName:  string;  1.�ļ���
����ֵ:    TImageType

USES

-------------------------------------------------------------------------------}
function CheckImageType(FileName: string): TImageType;
var
  MyImage: TMemoryStream;
  Buffer: Word;
begin
  MyImage := TMemoryStream.Create;
  try
    MyImage.LoadFromFile(FileName);
    MyImage.Position := 0;
    if MyImage.Size = 0 then // ����ļ���С����0����ô����(
    begin
      Result := IT_Error;
      Exit;
    end;
    MyImage.ReadBuffer(Buffer, 2); //��ȡ�ļ���ǰ�����ֽ�,�ŵ�Buffer����

    case Buffer of
      $4D42:
        Result := IT_Bmp;
      $D8FF:
        Result := IT_JPEG;
      $4947:
        Result := IT_GIF;
      $050A:
        Result := IT_PCX;
      $5089:
        Result := IT_PNG;
      $4238:
        Result := IT_PSD;
      $A659:
        Result := IT_RAS;
      $DA01:
        Result := IT_SGI;
      $4949:
        Result := IT_TIFF;
    else
      Result := IT_None;
    end;
  finally
    MyImage.Free;
  end;
end;

{-------------------------------------------------------------------------------
������:    WBLoadHTML ���ڴ��м���ҳ��
����:      WebBrowser:  TWebBrowser,HTMLCode:tstrings   1.�����2.����
����ֵ:

USES
SHDocVw,ActiveX
-------------------------------------------------------------------------------}
//���ڴ��м���ҳ�棨�ȼ���htm�ļ��ٶȿ죩uses ActiveX;
procedure  WBLoadHTML(WebBrowser:  TWebBrowser;  HTMLCode:  tstrings);
var
   ms:  TMemoryStream;
begin
   if  not Assigned(WebBrowser.Document)  then
      WebBrowser.Navigate('about:blank');
   if  Assigned(WebBrowser.Document)  then
   begin
       try
           ms  :=  TMemoryStream.Create;
           try
               HTMLCode.SaveToStream(ms,tEncoding.UTF8);
               ms.Seek(0,  0);
               (WebBrowser.Document  as  IPersistStreamInit).Load(TStreamAdapter.Create(ms));
               finally
               ms.Free;
           end;
       finally
       end;
   end;
end;

{-------------------------------------------------------------------------------
������:    MakeFileList �����ļ��м����ļ���
����:      Path,FileExt:string   1.��Ҫ������Ŀ¼ 2.Ҫ�������ļ���չ��
����ֵ:    TStringList

USE StrUtils

   Eg��ListBox1.Items:= MakeFileList( 'E:\��Ʒ�ɳ�','.exe') ;
       ListBox1.Items:= MakeFileList( 'E:\��Ʒ�ɳ�','.*') ;
-------------------------------------------------------------------------------}
function MakeFileList(Path,FileExt:string):TStringList ;
var
sch:TSearchrec;
begin
Result:=TStringlist.Create;

if rightStr(trim(Path), 1) <> '\' then
    Path := trim(Path) + '\'
else
    Path := trim(Path);

if not DirectoryExists(Path) then
begin
    Result.Clear;
    exit;
end;

if FindFirst(Path + '*', faAnyfile, sch) = 0 then
begin
    repeat
       Application.ProcessMessages;
       if ((sch.Name = '.') or (sch.Name = '..')) then Continue;
       if DirectoryExists(Path+sch.Name) then
       begin
         Result.AddStrings(MakeFileList(Path+sch.Name,FileExt));
       end
       else
       begin
         if (UpperCase(extractfileext(Path+sch.Name)) = UpperCase(FileExt)) or (FileExt='.*') then
         Result.Add(Path+sch.Name);
       end;
    until FindNext(sch) <> 0;
    SysUtils.FindClose(sch);
end;
end;









{
10001 (0x2711)	Internet Explorer 10����ҳ��IE 10�ı�׼ģʽչ�֣�ҳ��!DOCTYPE��Ч
10000 (0x02710)	Internet Explorer 10����IE 10��׼ģʽ�а�����ҳ��!DOCTYPEָ������ʾ��ҳ��Internet Explorer 10 Ĭ��ֵ��
9999 (0x270F)	Windows Internet Explorer 9. ǿ��IE9��ʾ������!DOCTYPEָ��
9000 (0x2328)	Internet Explorer 9. Internet Explorer 9Ĭ��ֵ����IE9��׼ģʽ�а�����ҳ��!DOCTYPEָ������ʾ��ҳ��
8888 (0x22B8)	Internet Explorer 8��ǿ��IE8��׼ģʽ��ʾ������!DOCTYPEָ��
8000 (0x1F40)	Internet Explorer 8Ĭ�����ã���IE8��׼ģʽ�а�����ҳ��!DOCTYPEָ��չʾ��ҳ
7000 (0x1B58)	ʹ��WebBrowser Control�ؼ���Ӧ�ó�����ʹ�õ�Ĭ��ֵ����IE7��׼ģʽ�а�����ҳ��!DOCTYPEָ����չʾ��ҳ��

11001 (0x2AF9	Internet Explorer 11. Webpages are displayed in IE11 edge mode, regardless of the declared !DOCTYPE directive. Failing to declare a !DOCTYPE directive causes the page to load in Quirks.
11000 (0x2AF8)	IE11. Webpages containing standards-based !DOCTYPE directives are displayed in IE11 edge mode. Default value for IE11.
10001 (0x2711)	Internet Explorer 10. Webpages are displayed in IE10 Standards mode, regardless of the !DOCTYPE directive.
10000 (0x02710)	Internet Explorer 10. Webpages containing standards-based !DOCTYPE directives are displayed in IE10 Standards mode. Default value for Internet Explorer 10.
9999 (0x270F)	Windows Internet Explorer 9. Webpages are displayed in IE9 Standards mode, regardless of the declared !DOCTYPE directive. Failing to declare a !DOCTYPE directive causes the page to load in Quirks.
9000 (0x2328)	Internet Explorer 9. Webpages containing standards-based !DOCTYPE directives are displayed in IE9 mode. Default value for Internet Explorer 9.
Important  In Internet Explorer 10, Webpages containing standards-based !DOCTYPE directives are displayed in IE10 Standards mode.

8888 (0x22B8)	Webpages are displayed in IE8 Standards mode, regardless of the declared !DOCTYPE directive. Failing to declare a !DOCTYPE directive causes the page to load in Quirks.
8000 (0x1F40)	Webpages containing standards-based !DOCTYPE directives are displayed in IE8 mode. Default value for Internet Explorer 8
Important  In Internet Explorer 10, Webpages containing standards-based !DOCTYPE directives are displayed in IE10 Standards mode.

7000 (0x1B58)	Webpages containing standards-based !DOCTYPE directives are displayed in IE7 Standards mode. Default value for applications hosting the WebBrowser Control.
}
procedure IEEmulator(VerCode: Integer);
const
  IE_SET_PATH_32='SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
  IE_SET_PATH_64='SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
var
  RegObj: TRegistry;
  sPath:string;
begin
  RegObj := TRegistry.Create;
  try
    //RegObj.RootKey := HKEY_CURRENT_USER;
    RegObj.RootKey := HKEY_LOCAL_MACHINE;
    RegObj.Access := KEY_ALL_ACCESS;
    if isWin64 then sPath := IE_SET_PATH_64 else sPath:=IE_SET_PATH_32;
    if not RegObj.OpenKey(sPath, False) then exit;
    try
      RegObj.WriteInteger(ExtractFileName(ParamStr(0)), VerCode);
    finally
      RegObj.CloseKey;
    end;
  finally
    RegObj.Free;
  end;
end;
{--}
{��Ҫע����GetNativeSystemInfo ������Windows XP ��ʼ���У�
 �� IsWow64Process ������ Windows XP with SP2 �Լ� Windows Server 2003 with SP1 ��ʼ���С�
 ����ʹ�øú�����ʱ�������GetProcAddress ��
}
function IsWin64: Boolean;
var
  Kernel32Handle: THandle;
  IsWow64Process: function(Handle: Windows.THandle; var Res: Windows.BOOL): Windows.BOOL; stdcall;
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;
  isWoW64: Bool;
  SystemInfo: TSystemInfo;
const
  PROCESSOR_ARCHITECTURE_AMD64 = 9;
  PROCESSOR_ARCHITECTURE_IA64 = 6;
begin
  Kernel32Handle := GetModuleHandle('KERNEL32.DLL');
  if Kernel32Handle = 0 then
    Kernel32Handle := LoadLibrary('KERNEL32.DLL');
  if Kernel32Handle <> 0 then
  begin
    IsWOW64Process := GetProcAddress(Kernel32Handle,'IsWow64Process');
    GetNativeSystemInfo := GetProcAddress(Kernel32Handle,'GetNativeSystemInfo');
    if Assigned(IsWow64Process) then
    begin
      IsWow64Process(GetCurrentProcess,isWoW64);
      Result := isWoW64 and Assigned(GetNativeSystemInfo);
      if Result then
      begin
        GetNativeSystemInfo(SystemInfo);
        Result := (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) or
                  (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64);
      end;
    end
    else Result := False;
  end
  else Result := False;
end;
{--}
function IEEmulator(): Boolean;
const
  IE_SET_PATH_32='SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
  IE_SET_PATH_64='SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
var
  reg :TRegistry;
  sPath,sAppName:String;
begin
  Result := True;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    sPath := IE_SET_PATH_32;
    if isWin64 then
      sPath :=IE_SET_PATH_64;
    if reg.OpenKey(sPath,True) then
    begin
      sAppName := ExtractFileName(ParamStr(0));
     //if not reg.ValueExists(sAppName) then
        reg.WriteInteger(sAppName,0);
    end;
    reg.CloseKey;
  finally
    FreeAndNil(reg);
  end;
end;
end.
