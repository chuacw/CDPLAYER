unit Shell;

interface
uses WinTypes, WinProcs, Messages;
type
 PNotifyIconDataA = ^TNotifyIconDataA;
 TNotifyIconDataA = record
        cbSize: Longint;
        HWnd: Longint;
        uID: Longint;
        uFlags: Longint;
        uCallbackMessage: Longint;
        hIcon: Longint;
        szTip: array[0..63] of Char;
 end;

const
 NIM_ADD         = $00000000;
 NIM_MODIFY      = $00000001;
 NIM_DELETE      = $00000002;

 NIF_MESSAGE     = $00000001;
 NIF_ICON        = $00000002;
 NIF_TIP         = $00000004;

 MYWM_NOTIFYICON = WM_USER + 4096;

function ShellAbout(Wnd: HWnd; ProgTitle, InfoText: PChar; Icon: HIcon): Integer;
{$IFDEF Win32}
 stdcall;
function ShellAboutA(Wnd: HWnd; ProgTitle, InfoText: PChar; Icon: HIcon): Integer;
 stdcall;
function ShellAboutW(Wnd: HWnd; ProgTitle, InfoText: PWideChar; Icon: HIcon): Integer;
 stdcall;
{$ELSE}
var
 Shell_NotifyIconA: function(dwMessage: Longint;
                            var lpData: TNotifyIconDataA; id: Longint): Bool;
function TrayMsg(Wnd: HWnd; dwMessage: Longint; uID: Word; Icon: HIcon;
                 pszTip: PChar): Bool;
{$ENDIF}
implementation
uses
{$IFNDEF Win32}Call32NT, {$ENDIF}SysUtils;

{$IFDEF Win32}
 function ShellAbout; external 'shell32.dll' name 'ShellAboutA' {index 243};
 function ShellAboutA; external 'shell32.dll' name 'ShellAboutA' {index 243};
 function ShellAboutW; external 'shell32.dll' name 'ShellAboutW' {index 244};
{$ELSE}
 function ShellAbout; external 'SHELL' index 22;
 function Shell_NotifyIconA; external 'shell32.dll' index 248;

var
 id_Shell_NotifyIconA: Longint;

 function Shell_NotifyIcon(dwMessage: Longint;
                           var lpData: TNotifyIconDataA): Bool;
 begin
  Result := Shell_NotifyIconA(dwMessage, lpData, id_Shell_NotifyIconA);
 end;

 function TrayMsg(Wnd: HWnd; dwMessage: Longint; uID: Word; Icon: HIcon;
                 pszTip: PChar): Bool;
var
	tnd: TNotifyIconDataA;
begin
	tnd.cbSize		:= sizeof(TNOTIFYICONDATAA);
	tnd.hWnd		:= Wnd;
	tnd.uID			:= uID;
	tnd.uFlags		:= NIF_MESSAGE or NIF_ICON or NIF_TIP;
	tnd.uCallbackMessage	:= MYWM_NOTIFYICON;
	tnd.hIcon		:= Icon;
	if Assigned(pszTip) then
		StrLCopy(tnd.szTip, pszTip, sizeof(tnd.szTip)-1)
	else
		tnd.szTip[0] := #0;

	Result := Shell_NotifyIcon(dwMessage, tnd);
	if Bool(Icon) then DestroyIcon(Icon);

end;
{$ENDIF}


(*ifndef UNICODE_ONLY
typedef struct _NOTIFYICONDATAA {
        DWORD cbSize;
        HWND hWnd;
        UINT uID;
        UINT uFlags;
        UINT uCallbackMessage;
        HICON hIcon;
        CHAR   szTip[64];
} NOTIFYICONDATAA, *PNOTIFYICONDATAA;

#ifndef ANSI_ONLY
typedef struct _NOTIFYICONDATAW {
        DWORD cbSize;
        HWND hWnd;
        UINT uID;
        UINT uFlags;
        UINT uCallbackMessage;
        HICON hIcon;
        WCHAR  szTip[64];
} NOTIFYICONDATAW, *PNOTIFYICONDATAW;
#endif //!ANSI_ONLY
#ifdef UNICODE
typedef NOTIFYICONDATAW NOTIFYICONDATA;
typedef PNOTIFYICONDATAW PNOTIFYICONDATA;
#else
typedef NOTIFYICONDATAA NOTIFYICONDATA;
typedef PNOTIFYICONDATAA PNOTIFYICONDATA;
#endif // UNICODE


#define NIM_ADD         = $00000000
#define NIM_MODIFY      = $00000001
#define NIM_DELETE      = $00000002

#define NIF_MESSAGE     = $00000001
#define NIF_ICON        = $00000002
#define NIF_TIP         = $00000004

#ifndef UNICODE_ONLY
WINSHELLAPI BOOL WINAPI Shell_NotifyIconA(DWORD dwMessage, PNOTIFYICONDATAA lpData);
#endif //!UNICODE_ONLY
#ifndef ANSI_ONLY
WINSHELLAPI BOOL WINAPI Shell_NotifyIconW(DWORD dwMessage, PNOTIFYICONDATAW lpData);
#endif //!ANSI_ONLY
#ifdef UNICODE
#define Shell_NotifyIcon  Shell_NotifyIconW
#else
#define Shell_NotifyIcon  Shell_NotifyIconA
#endif // !UNICODE

////
//// End Tray Notification Icons
////


Before I start I must confess that the solution I am providing is in C
SDK, Obviously their will be some differences between the C approach and
the Delphi approach. As yet I am still waiting for my copy of Delphi 2.0
to arrive, but I'm sure that it will be similar and just as undocumented
as in MS C.

(This has been ripped from a sample app I found on the MSVC++ v4.0 CD.)

Define a function called 'TrayMsg' which will fill in the relevant
structures for the Tray Icon.

The function has the following input

hWin		Handle to a windows
dwMessage	Message to send to System Tray
uID		ID associated with item on tray
hIcon		Handle to icon
pszTip		tip string to display when mouse is position over it.

BOOL TrayMsg(HWND hWnd, DWORD dwMessage, UINT uID, HICON hIcon, PSTR
pszTip)
{
        BOOL res;
	NOTIFYICONDATA tnd;

	tnd.cbSize		= sizeof(NOTIFYICONDATA);
	tnd.hWnd		= hWnd;
	tnd.uID			= uID;
	tnd.uFlags		= NIF_MESSAGE|NIF_ICON|NIF_TIP;
	tnd.uCallbackMessage	= MYWM_NOTIFYICON;
	tnd.hIcon		= hIcon;

	if (pszTip)
		lstrcpyn(tnd.szTip, pszTip, sizeof(tnd.szTip));
	else
		tnd.szTip[0] = '\0';

	res = Shell_NotifyIcon(dwMessage, &tnd);
	if (hIcon)
	    DestroyIcon(hIcon);

	return res;
}

One important aspect is the MYWM_NOTIFYICON callback message ID which is
defined as a user message.

The system tray is communicated to by send it messages. The three I have 
found are :-

NIM_ADD	This appends an Item to the system Tray,
NIM_MODIFY This modifies an existing tray item (it MUST exist before you 
modify it)
NIM_DELETE Removes an Item from the tray.

These are predefined window's constants !! you need to know the correct 
delphi equivalent .

and again in C SDK terms this function can be used as follows :-

TrayMsg (hWnd,NIM_ADD,1,LoadIcon (hInst,"ICON1"),"A Tray Item");
TrayMsg (hWnd,NIM_DELETE,1,NULL,NULL);
TrayMsg (hWnd,NIM_MODIFY,1,LoadIcon( hInst, ICON2"), "Different Text");

In all occurances shown the uID is '1', I think you can have more than 
one tray icon per window handle provided the uID's are different.

Also since the actual Icon is part of the Application not the system you 
must make sure you remove it before the user tries to access it after 
the app has closed. If you don't you could be asking for trouble !

To Capture Mouse events on the tray, the callback message is used. This 
can then be dealt with within your main 'windows message handling' 
routine.

LRESULT CALLBACK
MyMainWndProc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
	switch( msg )
	{
	case MYWM_NOTIFYICON:
		switch (lParam)
		{
		case WM_LBUTTONDOWN:
			/* Code To Handle Left Button Press */
			break;
		case WM_RBUTTONDOWN:
			/* Code to Handle Right Button Press */
			break;
		}
		break;
   	default:
		return DefWindowProc( hWnd, msg, wParam, lParam );
	}

return 0L;	// Never reached
} 


Once Again I must point out this is an SDK C answer not a Delphi one. 
Delphi may do it quite differently but it will be one of the first 
things I'll be looking at when my copy of delphi 2.0 arrives (which 
should be this week ... I Hope )

Hope that helps a bit
*)

{$IFNDEF Win32}
initialization
 @Shell_NotifyIconA := @Call32;
 id_Shell_NotifyIconA := Declare32('Shell_NotifyIconA','shell32','pp');
{$ENDIF}
end.
