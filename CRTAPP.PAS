program CrtApp;
uses Classes, SysUtils, WinTypes;

type

  TNicknameName = string[10];
  TInternalRecord = record
   AByteOrWhatever: Byte;
   ALongOrWhatever: Longint;
   AUserNameOrSomething: string;
   AUserNickName: TNicknameName;
  end;

  TError = (teNone, teSuccess, teCantOpen, teCantClose, teCantSeek, teCantRead,
            teCantFlush, teCantWrite, teCantAppend, teCantDelete, teAccessDenied,
            teBufferOverrun);

  TFileRecord = class
   private
    fFile: File of TInternalRecord;
    fEmpty, fAppended, fDirty: Bool;
    fPosition: Longint;
    fInternalRecord: TInternalRecord;
    fError: TError;
    function GetPosition: Longint;
    procedure SetPosition(const Value: Longint);
    function GetError: TError;
    function GetSize: Longint;
    function GetInternalRecord: TInternalRecord;
    procedure SetInternalRecord(const Value: TInternalRecord);
    function GetTop: Bool;
   public
    procedure Append;
    constructor Create(const Filename: string); virtual;
    procedure Delete;
    function EOF: Bool;
    property Error: TError read GetError;
    procedure First;
    procedure Flush;
    destructor Free; virtual;
    property InternalRecord: TInternalRecord read  GetInternalRecord
                                             write SetInternalRecord;
    procedure Next;
    property Position: Longint read GetPosition write SetPosition;
    procedure Previous;
    procedure SetRecord(AByteOrWhatever: Byte;
                        ALongOrWhatever: Longint;
                        AUserNameOrSomething: string;
                        AUserNickName: TNicknameName);
    property Size: Longint read GetSize;
    property Top: Bool read GetTop;
  end;

procedure TFileRecord.Append;
begin
 try
  Position := Size+1;
  Flush;
  Position := Position-1;
 except
  fError := teCantAppend;
 end;
end;

constructor TFileRecord.Create;
begin
 fError := teSuccess; fDirty := False;
 AssignFile(fFile, Filename);
 try
  if FileExists(Filename) then
   Reset(fFile) else
   Rewrite(fFile);
  try
   First;
  except
   fError := teCantSeek;
  end;
  fEmpty := EOF;
 except
  fError := teCantOpen;
 end;
end;

procedure TFileRecord.Delete;
var
 TempInternalRecord: TInternalRecord;
 I, ThisPos: Longint;
begin
end;

procedure TFileRecord.Flush;
var PosI: Longint;
begin
 try
  if fDirty then
   begin
    PosI := FilePos(fFile);
    Write(fFile, fInternalRecord);
    fDirty := False;
   end;
 except
  fError := teCantFlush;
 end;
end;

function TFileRecord.GetError;
begin
 Result := fError;
 fError := teNone;
end;

function TFileRecord.GetTop;
begin
 Result := Position = 1;
end;

procedure TFileRecord.First;
begin
 Position := 1;
end;

procedure TFileRecord.Previous;
begin
 if not Top then
  Position := Position-1;
end;

procedure TFileRecord.Next;
begin
 if not EOF then
  Position := Position + 1;
end;

destructor TFileRecord.Free;
begin
 Flush;
 Position := Size;
 try
  CloseFile(fFile);
 except
  fError := teCantClose;
 end;
end;

function TFileRecord.GetPosition;
begin
 fPosition := FilePos(fFile);
 Result := fPosition+1;
end;

procedure TFileRecord.SetPosition;
var
 I: Longint;
begin
end;

function TFileRecord.EOF;
begin
end;

function TFileRecord.GetSize;
begin
end;

function TFileRecord.GetInternalRecord;
begin
 try
  Read(fFile, fInternalRecord);
 except
  fError := teCantRead;
 end;
 Result := fInternalRecord;
end;

procedure TFileRecord.SetInternalRecord;
begin
 if fDirty then
  begin
   fError := teBufferOverrun;
   raise EInOutError.Create('Buffer overrun');
   exit;
  end;
 fDirty := True;
 fInternalRecord.AByteOrWhatever :=      Value.AByteOrWhatever;
 fInternalRecord.ALongOrWhatever :=      Value.ALongOrWhatever;
 fInternalRecord.AUserNameOrSomething := Value.AUserNameOrSomething;
 fInternalRecord.AUserNickName :=        Value.AUserNickName;
 fError := teSuccess;
end;

procedure TFileRecord.SetRecord(AByteOrWhatever: Byte;
                                ALongOrWhatever: Longint;
                                AUserNameOrSomething: string;
                                AUserNickName: TNicknameName);
var
 AnInternalRecord: TInternalRecord;
begin
 AnInternalRecord.AByteOrWhatever := AByteOrWhatever;
 AnInternalRecord.ALongOrWhatever := ALongOrWhatever;
 AnInternalRecord.AUserNameOrSomething := AUserNameOrSomething;
 AnInternalRecord.AUserNickName := AUserNickName;
 try
  InternalRecord := AnInternalRecord;
 except
 end;
end;

var
 FileRecord: TFileRecord;
 APos, ASize: Longint;
 ARecord: TInternalRecord;
begin
 FileRecord := TFileRecord.Create('\HELLO.TFT');
 ASize := FileRecord.Size;
 while not FileRecord.EOF do
  begin
   ARecord := FileRecord.InternalRecord;
   FileRecord.Next;
  end;
 ASize := FileRecord.Size;
 APos := FileRecord.Position;
 FileRecord.SetRecord(1, 1, 'Allen wants a simple Table', 'Allen');
 FileRecord.Append;
 APos := FileRecord.Position;
 ASize := FileRecord.Size;
 FileRecord.SetRecord(2, 2, 'Chee Wee is a Pascal programmer', 'Chee Wee');
 FileRecord.Append;
 APos := FileRecord.Position;
 ASize := FileRecord.Size;
 FileRecord.SetRecord(3, 3, 'Chee Wee is a Delphi programmer', 'Chee Wee');
 FileRecord.Append;
 APos := FileRecord.Position;
 ASize := FileRecord.Size;
 FileRecord.Position := 2;
 FileRecord.Delete;
 FileRecord.Free;
end.

