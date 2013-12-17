unit Testw32;   {Draws Bezier curves in Win95/WinNT, which is normally impossible in Win16}
                {Written in Delphi for Windows 1.0         }
                {By Christian Ghisler, CIS: 100332,1175    }
                {Released to the public domain June 14,1995}
interface

uses
  WinTypes, WinProcs, Forms,
  call32nt;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private-Declarations }
  public
    { Public-Declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


type tagpoint=array[0..3] of record
       x,y:longint;
     end;

{Declaration of the 32 bit functions}
var
  GetDC:function(hwnd,id:longint):longint;
  ReleaseDC:function(hwnd,hdc,id:Longint):longint;
  PolyBezier:function(hdc:longint;var points:tagPoint;count,id:Longint):Longint;
  GetDesktopWindow:function(id:Longint):longint;
  CreatePen:function(style,w,c,id:Longint):Longint;
  SelectObject:function(hdc,hpen,id:longint):Longint;
  DeleteObject:function(hpen,id:Longint):Longint;

{Declaration of a unique identifier for each 32 bit function}
var
  idGetDC,
  idReleaseDC,
  idPolyBezier,
  idCreatePen,
  idSelectObject,
  idDeleteObject,
  dc:longint;
  finished:boolean;

{Here comes the code which actually uses the 32-bit functions}
procedure TForm1.FormCreate(Sender: TObject);var points:tagPoint;
var i,j:Integer;
    r,hpen,oldpen:Longint;
    msg:tmsg;
Const PointCount = 4;

begin
  Show;
  dc:=GetDC(Form1.handle, idGetDC);
  finished:=false;
  repeat
    hpen:=CreatePen(PS_SOLID, 5,trunc(Random*$1000000), idCreatePen);
    For i:=0 To 3 do begin
      points[i].x:=Random(Form1.width);
      points[i].y:=Random(form1.height);
    end;
    OldPen:=SelectObject(dc, hpen, idSelectObject);
    PolyBezier(dc, points, PointCount, idPolyBezier);
    SelectObject(dc, OldPen, idSelectObject);  {Very important! A selected pen cannot be deleted!}
    DeleteObject(hpen, idDeleteObject);
    Application.ProcessMessages;
  until finished;
  Application.Terminate;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not finished then begin
    finished:=true;
    ReleaseDC(Form1.handle,dc,idReleaseDC);
   {No need to un-initialize, the 32-bit libraries are automatically freed when the program terminates}
    CanClose:=false;
  end else
    CanClose:=true;
end;

begin
  {Initialization of the 32 bit functions}
  @GetDC:=@Call32;
  @ReleaseDC:=@Call32;
  @PolyBezier:=@Call32;
  @GetDesktopWindow:=@Call32;
  @CreatePen:=@Call32;
  @SelectObject:=@Call32;
  @DeleteObject:=@Call32;

  {Each function must be declared with Declare32. The handle returned by Declare32
   must be passed as the last parameter of the function when the function is called}
  {Parameters of Declare32: }
  {First:  The name of the original win32 function: CASE SENSITIVE!!!!!}
  {Second: The name of the 32 bit module where the function is located}
  {Third:  A string describing all parameters. p=pointer, i=longint, w=Windows handle}
  idGetDC:=Declare32('GetDC', 'user32', 'w');
  idReleaseDC:=Declare32('ReleaseDC', 'user32', 'wi');
  idPolyBezier:=Declare32('PolyBezier', 'gdi32', 'ipi');
  idCreatePen:=Declare32('CreatePen', 'gdi32', 'iii');
  idSelectObject:=Declare32('SelectObject', 'gdi32', 'ii');
  idDeleteObject:=Declare32('DeleteObject', 'gdi32', 'i');
  {Check if everything went well. If there was only a single error, Call32NTError=false}
  if Call32NTError then begin
    messagebox(0,'Sorry, cannot load 32 bit system!','testw32',mb_ok);
    halt(1);
  end;
end.
