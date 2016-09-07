unit UProcessMgr;

interface
uses
  windows,ComCtrls,Classes,SysUtils,SyncObjs,TlHelp32;

type
  TProcessObj = class
    private
      mPid:Cardinal;
      mItem:TListItem;
      mName:String;
    function GetTargetAPI: Pointer;
    function GetTargetKerBase(Pid: Cardinal): Cardinal;

    public
      constructor Create(_Pid:Cardinal;_Str:String;_Item:TListItem);

      Function Inject(Module:String):Bool;

      procedure Update;

      property Name:String read mName;
      property Pid:Cardinal read mPid write mPid;
  end;
  TProcessMgr = class
    private
      Cri:TCriticalSection;
      List:TList;
      mListView:TListView;
      Procedure Clear();
    function EnableDebugPriv: Boolean;
    public
      constructor Create(_ListView:TListView = nil);

      Function Reload():Integer;

      Function FindObjByName(Name:String):TProcessObj;
      Function FindObjByIndex(Idx:Integer):TProcessObj;
  end;

 var
  ProcessMgr:TProcessMgr;
implementation
  uses
    UMainForm;
{ TProcessMgr }
function TProcessMgr.EnableDebugPriv: Boolean;
var
  hToken: THandle;
  tp: TTokenPrivileges;
  rl: Cardinal;
begin
  Result := false;

  //打开进程令牌环
  OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
    hToken);

  //获得进程本地唯一ID
  if LookupPrivilegeValue(nil, 'SeDebugPrivilege', tp.Privileges[0].Luid) then
  begin
    tp.PrivilegeCount := 1;
    tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    //调整权限
    Result := AdjustTokenPrivileges(hToken, false, tp, SizeOf(tp), nil, rl);
  end;
end;

procedure TProcessMgr.Clear;
var
  i:Integer;
begin
  Cri.Enter;
  try
    if List.Count > 0 then
      begin
        for i := 0 to List.Count - 1 do
          begin
            TObject(List[i]).Free;
          end;
        List.Clear;
      end;
  finally
    Cri.Leave;
  end;

  if mListView.Items.Count > 0 then
    begin
      for i := 0 to mListView.Items.Count - 1 do
        begin
          TObject(mListView.Items[i]).Free;
        end;
      mListView.Clear;
    end;
end;

constructor TProcessMgr.Create(_ListView:TListView = nil);
begin
  EnableDebugPriv();
  Cri:=TCriticalSection.Create;
  List:=Tlist.Create;
  mListView:=_ListView;
end;

function TProcessMgr.FindObjByIndex(Idx: Integer): TProcessObj;
begin
  Result:=nil;
  Cri.Enter;
  try
    if Idx < List.Count then Result:= List[Idx];
  finally
    Cri.Leave;
  end;
end;

function TProcessMgr.FindObjByName(Name: String): TProcessObj;
var
  i:Integer;
begin
  Result:=nil;
  Cri.Enter;
  try
    for i := 0 to List.Count - 1 do
      begin
        if TProcessObj(List[i]).Name = Name then
          begin
            Result:= List[i];
            Break;
          end;
      end;
  finally
    Cri.Leave;
  end;
end;

function TProcessMgr.Reload: Integer;
var
  Pe32:TProcessEntry32;
  ShotHandle:THandle;
  IsDone:Bool;
  Node:TProcessObj;
begin
  Clear();
  Result:=-1;
  Pe32.dwSize := SizeOf(TProcessEntry32);
  ShotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  if ShotHandle <> 0 then
    begin
      IsDone:=Process32First(ShotHandle,Pe32);
      while IsDone do
        begin
          if Assigned(mListView) then
            begin
              Node:=TProcessObj.Create(Pe32.th32ProcessID,Pe32.szExeFile,mListView.Items.Add);
            end
          else
            begin
              Node:=TProcessObj.Create(Pe32.th32ProcessID,Pe32.szExeFile,nil);
            end;
          Cri.Enter;
          List.Add(Node);
          Cri.Leave;
          IsDone:=Process32Next(ShotHandle,Pe32);
        end;
    end;

end;

{ TProcessObj }

constructor TProcessObj.Create(_Pid: Cardinal;_Str:String; _Item: TListItem);
var
 Handle:Cardinal;
begin
  mPid:=_Pid;
  mItem:=_Item;
  mName:=_Str;
  if Assigned(mItem) then
    begin
      mItem.Caption:=Format('%.6d',[mPid]);
      mItem.SubItems.Add(mName);
      Handle:=OpenProcess(PROCESS_ALL_ACCESS, false, mPid);
      if Handle <> 0 then
        begin
          mItem.SubItems.Add('Access');
          CloseHandle(Handle);
        end
      else
        mItem.SubItems.Add('Denied');
    end;
end;

function TProcessObj.GetTargetKerBase(Pid:Cardinal):Cardinal;
var
  T32:TModuleEntry32;
  Handle:Cardinal;
  Listloop:bool;
begin
  Result:=0;
  Handle := CreateToolHelp32SnapShot(TH32CS_SNAPMODULE, Pid);
  T32.dwsize := SizeOF(TModuleEntry32);
  Listloop := Module32First(Handle, T32);
  while Listloop do
  begin
    if StrPas(T32.szModule) = 'KERNEL32.DLL' then
      begin
        Result:= T32.hModule;
        Break;
      end;
    ListLoop := Module32Next(Handle, T32);
  end;
end;

Function TProcessObj.GetTargetAPI():Pointer;
var
 pfnLoadLibraryWOffset, fnModule:Cardinal;
begin
  Result:=nil;
  fnModule:= LoadLibrary('Kernel32.dll');
  if fnModule <> 0 then
    begin
      //获取个偏移
      pfnLoadLibraryWOffset:=  Cardinal(GetProcAddress(fnModule,'LoadLibraryW'))- fnModule;
      Result:=Pointer(GetTargetKerBase(mPid) + pfnLoadLibraryWOffset);
    end;
end;

Function TProcessObj.Inject(Module:String):Bool;
var
  hRemoteThread: THandle;
  Handle:Cardinal;
  memSize,lpThreadId: Cardinal;
  WriteSize:Cardinal;
  pszLibFileRemote: Pointer;
  pszLibAFilename: PwideChar;
  fnLoadLibraryW:TFNThreadStartRoutine;
begin
  Result := False;
  Handle:= OpenProcess(PROCESS_ALL_ACCESS, false, mPid);
  if Handle <> 0 then
    begin

      GetMem(pszLibAFilename, Length(Module) * 2 + 1);
      StringToWideChar(Module, pszLibAFilename, Length(Module) * 2 + 1);
      memSize := (1 + lstrlenW(pszLibAFilename)) * SizeOf(WCHAR);
      pszLibFileRemote := VirtualAllocEx(Handle, nil,
          memSize, MEM_COMMIT, PAGE_READWRITE);
      if Assigned(pszLibFileRemote) then
        begin
          if WriteProcessMemory(Handle, pszLibFileRemote,
              pszLibAFilename, memSize, WriteSize) and (WriteSize = memSize) then
            begin
              lpThreadId := 0;
              fnLoadLibraryW:= GetTargetAPI();
              if Assigned(fnLoadLibraryW) then
                begin
                  hRemoteThread := CreateRemoteThread(Handle, nil,
                        0, fnLoadLibraryW, pszLibFileRemote, 0, lpThreadId);
                  if (hRemoteThread <> 0) then
                        Result := true;
                  CloseHandle(hRemoteThread);
                end;
            end;
        end;
       CloseHandle(Handle);
    end;
end;

procedure TProcessObj.Update;
var
  Pe32:TProcessEntry32;
  ShotHandle:THandle;
  IsDone:Bool;
begin
  Pe32.dwSize := SizeOf(TProcessEntry32);
  ShotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  if ShotHandle <> 0 then
    begin
      IsDone:=Process32First(ShotHandle,Pe32);
      while IsDone do
        begin
          if Pe32.szExeFile = mName then
            begin
              mPid:=Pe32.th32ProcessID;
              if Assigned(mItem) then
                begin
                  mItem.Caption:=Format('%.6d',[mPid]);
                end;
            end;
          IsDone:=Process32Next(ShotHandle,Pe32);
        end;
    end;
end;

end.
