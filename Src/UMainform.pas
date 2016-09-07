unit UMainform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Menus,UProcessMgr,untDrag;

type
  FChangeWindowMessageFilter = function (flag:Cardinal;Act:Cardinal):Bool;Stdcall;
  TForm1 = class(TForm)
    grp1: TGroupBox;
    grp2: TGroupBox;
    stat1: TStatusBar;
    lbledt1: TLabeledEdit;
    lbledt2: TLabeledEdit;
    btn1: TButton;
    lv1: TListView;
    pm1: TPopupMenu;
    N1: TMenuItem;
    procedure N1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lv1Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    procedure OnDrapDrop(var Msg: TWMDropFiles); message WM_DROPFILES;
  public
    Procedure LoadProcess();
  end;

var
  Form1: TForm1;
  ChangeWindowMessageFilter:FChangeWindowMessageFilter;
implementation

{$R *.dfm}

procedure TForm1.btn1Click(Sender: TObject);
var
  Node:TProcessObj;
begin
  Node:=ProcessMgr.FindObjByName(lbledt2.Text);
  if Assigned(Node) then
   begin
     Node.Update;
     if Node.Inject(lbledt1.Text) then
       begin
         stat1.Panels[0].Text:=Format('注入成功[%s]',[lbledt1.Text]);
       end
     else
       stat1.Panels[0].Text:='注入失败';
   end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {win7 以上版本在管理员权限下需要添加以下代码,否则拖拽无效}
  ChangeWindowMessageFilter:=getprocaddress(LoadLibrary('user32.dll'),'ChangeWindowMessageFilter');
  ChangeWindowMessageFilter(WM_DROPFILES, 1);
  ChangeWindowMessageFilter(WM_COPYDATA, 1);
  ChangeWindowMessageFilter($0049, 1);


  DragAcceptFiles(Handle, True);
  ProcessMgr:=TProcessMgr.Create(Form1.lv1);
  ProcessMgr.Reload;
end;

procedure TForm1.LoadProcess;
begin
  ProcessMgr.Reload;
end;

procedure TForm1.lv1Click(Sender: TObject);
var
  Node:TProcessObj;
begin
  if Lv1.ItemIndex > -1 then
   begin
     Node:=ProcessMgr.FindObjByIndex(Lv1.ItemIndex);
     if Assigned(Node) then
       begin
         lbledt2.Text:= Node.Name;
       end;
   end;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
  LoadProcess();
end;

procedure TForm1.OnDrapDrop(var Msg: TWMDropFiles);
begin
  lbledt1.text := GetDragFileName(Msg.Drop);
  DragFinish(Msg.Drop);
end;

end.
