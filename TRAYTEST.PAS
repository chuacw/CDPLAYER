unit Traytest;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Shell;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
   Handle32: Longint;
   procedure MyWMTrayIcon(var Message: TMessage); message MYWM_NOTIFYICON;
  end;

var
  Form1: TForm1;

implementation
uses Call32NT;
{$R *.DFM}

procedure TForm1.MyWMTrayIcon(var Message: TMessage);
begin
 case Message.lParam of
  WM_LBUTTONDBLCLK: Application.Restore;
  WM_LBUTTONDOWN:
   begin
    Application.Restore;
    ShowWindow(Handle, sw_Restore);
    MessageDlg('Hello', mtInformation, [mbOk], 0);
   end;
  WM_RBUTTONDOWN:;
 end;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
 Handle32 := Handle;
 XlatHwnd(Handle32);
 TrayMsg(Handle32, NIM_ADD, 1, LoadIcon(HInstance,'MAINICON'), 'A Tray Item');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 TrayMsg(Handle32, NIM_DELETE, 1, 0, nil);
 InvalidateRect(GetDesktopWindow, nil, True);
end;

end.


