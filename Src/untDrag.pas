unit untDrag;

interface
//��������Windows���Form���Խ����ļ��Ϸ�
{$EXTERNALSYM DragAcceptFiles}
procedure DragAcceptFiles(hWnd: Cardinal; fAccept:
  Boolean); stdcall;
//�õ��Ϸ��ļ������ļ�������API
{$EXTERNALSYM DragQueryFile}
function DragQueryFile(hDrop: Cardinal; iFile: Cardinal; lpszFile: PChar; cch:
  Integer): Integer; stdcall;
//�ͷ�Windows������ϷŲ������ڴ�
{$EXTERNALSYM DragFinish}
procedure DragFinish(hDrop: Cardinal); stdcall;
//�õ��Ϸŵ��ļ�����
function GetDragFileCount(hDrop: Cardinal): Integer;
//�õ��Ϸŵ��ļ�����ͨ��FileIndex��ָ���ļ���ţ�Ĭ��Ϊ��һ���ļ�
function GetDragFileName(hDrop: Cardinal; FileIndex: Integer = 1): AnsiString;

implementation

procedure DragAcceptFiles; external 'Shell32';
function DragQueryFile; external 'Shell32';
procedure DragFinish; external 'Shell32';

function GetDragFileCount(hDrop: Cardinal): Integer;
const
  DragFileCount = High(Cardinal);
begin
  Result := DragQueryFile(hDrop, DragFileCount, nil, 0);
end;

function GetDragFileName(hDrop: Cardinal; FileIndex: Integer = 1): AnsiString;
const
  Size = 255;
var
  Len: Integer;
  FileName: AnsiString;
begin
  SetLength(FileName, Size);
  Len := DragQueryFile(hDrop, FileIndex - 1, PChar(FileName), Size);
  SetLength(FileName, Len);
  Result := FileName;
end;

end.
