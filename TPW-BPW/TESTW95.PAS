program TestW95;    {Shows the directory of c:\ with long filenames in Win95/WinNT}
                    {Written in Turbo Pascal for Windows 1.5      }
                    {By Christian Ghisler, CIS: 100332,1175       }
                    {Released to the public domain on June 14,1995}

uses wintypes,
     winprocs,
     Wincrt,
     call32nt;

type
  ttime=array[0..1] of longint;
  fd=record
    dwFileAttributes:longint;
    ftCreationTime,
    ftLastAccessTime,
    ftLastWriteTime:ttime;
    nFileSizeHigh,
    nFileSizeLow,
    dwReserved0,
    dwReserved1:longint;
    cFileName:array[0..259] of char;
    cAlternateFileName:array[0..13] of char;
  end;
  pfd=^fd;

  tSYSTEMTIME=record
    wYear,
    wMonth,
    wDayOfWeek,
    wDay,
    wHour,
    wMinute,
    wSecond,
    wMilliseconds:WORD;
  end;

{Declaration of the 32 bit functions}
{W32 is put in front of the name to distinguish from 16 bit functions}
{This is not necessary, the functions can have ANY name}
var
 W32FindFirstFile:function(lpszSearchFile:pchar;var lpffd:fd;id:longint):longint;
 W32FindNextFile:function(hFindFile:longint;var lpffd:fd;id:longint):longbool;
 W32FindClose:function(hFindFile:longint;id:longint):Longbool;
 W32FileTimeToSystemTime:function(var lpft:ttime;var lpst:tsystemtime;id:longint):longbool;
 W32FileTimeToLocalFileTime:function(var lpft,lpftlocal:ttime;id:longint):longbool;

{Declaration of a unique identifier for each 32 bit function}
var
  id_W32FindFirstFile,
  id_W32FindNextFile,
  id_W32FindClose,
  id_W32FileTimeToSystemTime,
  id_W32FileTimeToLocalFileTime:longint;
  lr:fd;
  handle:longint;
  localtime:ttime;
  ok:longbool;
  i:integer;
  tdt:tsystemtime;

begin
  screensize.y:=100;
  writeln('Test of Win32 functions from Win16!');

  {Initialization of the 32 bit functions}
  @W32FindFirstFile:=@Call32;
  @W32FindNextFile:=@Call32;
  @W32FindClose:=@Call32;
  @W32FileTimeToSystemTime:=@Call32;
  @W32FileTimeToLocalFileTime:=@Call32;

  {Each function must be declared with Declare32. The handle returned by Declare32
   must be passed as the last parameter of the function when the function is called}
  {Parameters of Declare32: }
  {First:  The name of the original win32 function: CASE SENSITIVE!!!!!}
  {Second: The name of the 32 bit module where the function is located}
  {Third:  A string describing all parameters. p=pointer, i=longint, w=Windows handle}

  id_W32FindFirstFile:=Declare32('FindFirstFile', 'kernel32', 'pp');
  id_W32FindNextFile:=Declare32('FindNextFile', 'kernel32', 'ip');
  id_W32FindClose:=Declare32('FindClose', 'kernel32', 'i');
  id_W32FileTimeToSystemTime:=Declare32('FileTimeToSystemTime', 'kernel32', 'pp');
  id_W32FileTimeToLocalFileTime:=Declare32('FileTimeToLocalFileTime', 'kernel32', 'pp');

  {Check if everything went well. If there was only a single error, Call32NTError=false}
  if Call32NTError then begin
    writeln('Sorry, cannot load the desired 32 bit functions!');
    halt(1);
  end;

  {Initialization is done, here comes the code which actually uses the functions}

  writeln('Directory of c:\');
  handle:=W32FindFirstFile('c:\*.*',lr,id_W32FindFirstFile);
  if handle<>-1 then repeat
    write(lr.cfilename);
    W32FileTimeToLocalFileTime(lr.ftLastWriteTime,localtime,id_W32FileTimeToLocalFileTime);
    W32FileTimeToSystemTime(localtime,tdt,id_W32FileTimeToSystemTime);
    gotoxy(40,wherey);
    writeln(tdt.wmonth,'/',tdt.wday,'/',tdt.wyear,'  ',tdt.whour,':',tdt.wminute,':',tdt.wsecond);
    ok:=W32FindNextFile(handle,lr,id_W32FindNextFile);
  until not ok;
  W32FindClose(handle,id_W32FindClose);
  {No need to un-initialize, the 32-bit libraries are automatically freed when the program terminates}
end.

