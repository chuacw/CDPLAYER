{*******************************************************}
{                                                       }
{       Delphi CD Player unit                           }
{                                                       }
{       Copyright (c) 1995 Chua Chee Wee                }
{                                                       }
{*******************************************************}
{ Sunday 30 April 1995, 2:28pm                          }
{ Created                                               }

unit CdInt;
interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, Buttons, ExtCtrls, MPlayer, StdCtrls, IniFiles,
  CDIni, ColorGrd, DB, DBTables, Spin, ComCtrls;
const
 WM_CDCHANGED = $0219;
{ When a CD is ejected, message received is,
  Msg: 537
  WParam: 32772, $8004          WParamHi: $0080, WParamLo: $0004
  lParam: 1394999296, $53260000 lParamHi: $5326, lparamLo: $0000


  When a CD is inserted, message received is,
  Msg: 537
  WParam: 32768, $8000          WParamHi: $0080, WParamLo: $0000
  lParam, 254148608, $0F260000  lParamHi: $0F26, lParamLo: $0000
}
type
  TTimeDisplayStyle = (tTrackTimeElapsed, tTrackTimeRemaining,
                       tDiscTimeRemaining);
  TCDPlayerForm = class(TForm)
    MainMenu1: TMainMenu;
    Disc1: TMenuItem;
    Options1: TMenuItem;
    Help1: TMenuItem;
    EditPlayList1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    View1: TMenuItem;
    Toolbar: TMenuItem;
    Statusinfo1: TMenuItem;
    N2: TMenuItem;
    Tracktimeelapsed1: TMenuItem;
    TrackTimeremaining1: TMenuItem;
    Disctimeremaining1: TMenuItem;
    N3: TMenuItem;
    Volumecontrol1: TMenuItem;
    RandomOrder: TMenuItem;
    Continuousplay: TMenuItem;
    Introplay1: TMenuItem;
    N4: TMenuItem;
    Preferences1: TMenuItem;
    Helptopics1: TMenuItem;
    AboutCDPlayer1: TMenuItem;
    N5: TMenuItem;
    DiscTrackinfo1: TMenuItem;
    UpdateDisplayTimer: TTimer;
    GroupBox1: TGroupBox;
    TimeDisplay: TLabel;
    CDPlayer: TMediaPlayer;
    TrackTime: TPanel;
    TotalPlayTimeOfTrack: TPanel;
    Label2: TLabel;
    ArtistName: TGroupBox;
    LabelArtistName: TLabel;
    Label1: TLabel;
    GroupBoxCDTitle: TGroupBox;
    LabelCDTitle: TLabel;
    RepeatTrack: TMenuItem;
    Label3: TLabel;
    GroupBox4: TGroupBox;
    TrackToPlay: TComboBox;
    FromAtoB: TMenuItem;
    N6: TMenuItem;
    Export1: TMenuItem;
    TableCDAuthor: TTable;
    DataSourceCDAuthor: TDataSource;
    TableCDSongs: TTable;
    DataSourceCDSongs: TDataSource;
    TableCDTitles: TTable;
    DataSourceCDTitles: TDataSource;
    TableCDAuthorAuthorID: TIntegerField;
    TableCDAuthorAuthor: TStringField;
    TableCDSongsTitleID: TIntegerField;
    TableCDSongsSongTitle: TStringField;
    TableCDTitlesAuthorID: TIntegerField;
    TableCDTitlesTitleID: TIntegerField;
    TableCDTitlesTitle: TStringField;
    TableCDSongsAuthorID: TIntegerField;
    TableCDSongsTrack: TSmallintField;
    N7: TMenuItem;
    SongDatabase1: TMenuItem;
    SpinButton1: TSpinButton;
    Edit1: TEdit;
    StatusBar: TStatusBar;
    procedure MenuClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure AboutCDPlayer1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpdateDisplay(Sender: TObject);
    procedure EditPlayList1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RepeatTrackClick(Sender: TObject);
    procedure CDPlayerNotify(Sender: TObject);
    procedure CDPlayerClick(Sender: TObject; Button: TMPBtnType;
      var DoDefault: Boolean);
    procedure Preferences1Click(Sender: TObject);
    procedure TrackToPlayClick(Sender: TObject);
    procedure Volumecontrol1Click(Sender: TObject);
    procedure Tracktimeelapsed1Click(Sender: TObject);
    procedure TrackTimeremaining1Click(Sender: TObject);
    procedure Disctimeremaining1Click(Sender: TObject);
    procedure Export1Click(Sender: TObject);
  private
    { Private declarations }
    CDStarted: Boolean; RepeatStartPos, RepeatEndPos,
    MicrosoftDiscID, Pos, DiscID: Longint; PlayHour, PlayMin, PlaySec: Word;
    PlayTime: TDateTime;
    Stopped, Paused, TogglePausedMode, DiscLoaded: Boolean;
    CDDrive, TrackNum: Integer;
    Minutes, Secs: Shortint;

    procedure CheckThisMenuItem(Sender: TMenuItem);
    procedure OnCheckedChange(Sender: TMenuItem);
    procedure OnDiscChange;
    procedure UpdatePlayListTime;
  protected
    function GetMicrosoftCDID: Longint;
  public
    { Public declarations }
    PlayingTrack: Word;
    DiscMsg: array[0..5] of TMessage;
    DiscIndex: Word;
    TimeDisplayStyle: TTimeDisplayStyle;
{ This message will only be seen on Win95 and/or
  most members of the Windows family that includes the Win95 specs}
    procedure DiscInserted(var Message: TMessage); message WM_CDCHANGED;
    procedure PlayTrack(TrackNo: Word);
    procedure PlayNextTrack(Next: Integer; WrapAround: Boolean);
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SysCommand;
    procedure FlushCDTracks;
  end;

  T95HintWindow = class(THintWindow)
  public
    constructor Create(AOwner: TComponent); override;
  protected
      procedure Paint; override;
  end;

var
  CDPlayerForm: TCDPlayerForm;


implementation

uses Shell, CDSet, CDPref, MMSystem, CDPlayHB;
{$R *.DFM}

var
 SongLength: array[1..100] of Longint;

type

 tfTMSFRec = record
  Tracks, Minutes, Secs, Frames: Byte;
 end;

 tfMSFRec = record
  Minutes, Secs, Frames, Unused: Byte;
 end;

procedure TCDPlayerForm.OnCheckedChange(Sender: TMenuItem);
begin
 if Sender.Command = Toolbar.Command then
  CDPlayer.Visible := Toolbar.Checked;
end;

{ Called when a menu item(Sender) is clicked upon.

  GroupIndex            Result
      0                 Toggle checked status of menuitem
     <>0                Check the checked status of sender and
                        uncheck all menu items having the same GroupIndex
                        as Sender.

  Events                Notifies OnCheckedChange when Checked is changed.

}
procedure TCDPlayerForm.CheckThisMenuItem(Sender: TMenuItem);
var
 Count: Word;
begin
  for Count := 0 to Sender.Parent.Count-1 do
   with Sender.Parent.Items[Count] as TMenuItem do
    begin
     if (Command<>Sender.Command) and (GroupIndex<>0) and (GroupIndex = Sender.GroupIndex) then
      begin
       Checked := False;
       OnCheckedChange(Sender.Parent.Items[Count]);
      end;
    end;
 Sender.Checked := not Sender.Checked;
 OnCheckedChange(Sender);
end;

{ Menu click procedure for
  RandomOrder, Toolbar, DiscTrackInfo, StatusInfo,
  Track/Disc Time elapsed/remaining, Continuous/Intro Play
}

procedure TCDPlayerForm.MenuClick(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TCDPlayerForm.Exit1Click(Sender: TObject);
begin
 Close;
end;

procedure TCDPlayerForm.AboutCDPlayer1Click(Sender: TObject);
var
 sAbout, sInfoText: array[0..50] of Char;
begin
 StrCopy(sAbout, 'About CD Player#CD Player');
 StrCopy(sInfoText, 'Written by Chua Chee Wee in Borland Delphi');
 ShellAbout(0, sAbout, sInfoText, Icon.Handle);
{
 Will cause Access Violation. Possibly because Windows is trying
 to write a #0 to the string and Delphi places constant string into
 code segment.
 ShellAbout(0, 'About CD Player#CD Player',
               'Written by Chua Chee Wee in Borland Delphi', Icon.Handle); }
end;
{$IFNDEF Win32}
  function CheckCDDrive(DriveToCheck: Word): Word; assembler;
  type
   PCtrlBlk = ^TCtrlBlk;
   TCtrlBlk = record
    SubCmdCode: Byte;
    Status: Longint;
   end;
   TCDStatus = record
    Len, UnitNo, CmdCode: Byte; { UnitNo filled by MSCDEX }
    Status: Word;
    Reserved: array[0..7] of Byte;
    Desc: Byte;
    lpCtrlBlk: PCtrlBlk;
    TransferSize,
    StartingSector: Word;
    VolID: Longint;
    CtrlBlk: TCtrlBlk;
   end;
{  var
   CDStatus: TCDStatus; }
(*   FillChar(CDStatus, SizeOf(CDStatus), 0);
   with CDStatus do
    begin
     Len := 26;
     CmdCode := 3; { Read }
     lpCtrlBlk := @CtrlBlk;
     CtrlBlk.SubCmdCode := 6; { Device status }
    end; *)
   asm
    MOV   DX,DriveToCheck
    MOV   AX,150Bh
    XOR   BX,BX
    XOR   CX,CX
    MOV   CL,DL
    INT   2Fh
    CMP   BX,0ADADh
    JNE   @@NoMSCDEX
    OR    AX,AX
    JZ    @@NotCDDrive
    PUSH  ES
    PUSH  BP
    SUB   SP,32
    MOV   BP,SP
    MOV   AX,SS
    MOV   ES,AX
    CLD
    MOV   DI,BP
    MOV   CX,16
    XOR   AX,AX
    REP   STOSW
    MOV   BYTE PTR [BP],26
    MOV   BYTE PTR [BP+2],3
    MOV   WORD PTR [BP+14],BP
    ADD   WORD PTR [BP+14],26
    MOV   WORD PTR [BP+16],SS
    MOV   BYTE PTR [BP+26],6
{    MOV   AX,SEG CDStatus
    MOV   ES,AX }
    MOV   AX,1510h
    MOV   BX,BP
    XOR   CX,CX
    MOV   CL,DL
    INT   2Fh
    XOR   AX,AX
    TEST  WORD PTR [BP+27],0800h
    JZ    @@GotCDExit
    MOV   AX,1        { No disc in drive }
    JMP   @@GotCDExit
@@NoMSCDEX:
    MOV   AX,3        { MSCDEX not loaded }
    JMP   @@GotCDExit
@@NotCDDrive:
    MOV   AX,2        { Not a CD ROM drive }
@@GotCDExit:
    ADD   SP,32
    POP   BP
    POP   ES
{    RET }
   end;
{$ENDIF}


procedure TCDPlayerForm.FormCreate(Sender: TObject);
var
 I: Word;
{$IFDEF Win32} Drive: array[0..3] of Char; {$ENDIF}
 MCISysInfo: TMCI_SysInfo_Parms;
 Data: array[1..30] of Char;
begin

{ Gets the drive name for the CD ROM Drive.
  Assumes that the first CD ROM Drive on the system is used as CD Audio Player,
  instead of anything else. This kind of assumption is made because
  the Borland MPlayer unit doesn't support more than 1 CD ROM Drive.
  The drive name is needed so that later on, it can be checked that
  whether files exist on the CD disc currently in the CD drive.
  If files exist, the CD is a data disc. If no files exist and an error
  occured, then the drive should be empty.}
 CDDrive := -1;
 for I := 0 to 26 do
  begin
{$IFDEF Win32}
   StrPCopy(Drive, Chr(I+Ord('A'))+':\');
{$ENDIF}
{$IFNDEF Win32}
   case GetDriveType(I) of
{$ELSE}
   case GetDriveType(Drive) of
{$ENDIF}
    0: Break;
{$IFDEF Win32}
    drive_CDROM: CDDrive := I;
{$ENDIF}
{$IFNDEF Win32}
    drive_Remote:
    if CheckCDDrive(I)<=1 then
     begin
      CDDrive := I;
      Break;
     end;
{$ENDIF}
   end;
  end;

 for I := 5 downto 0 do
  FillChar(DiscMsg[I], SizeOf(DiscMsg[0]), 0);
 Stopped := False; PlayListIndex := 0;
 DiscID := 0; DiscLoaded := False; Paused := False;
 with CDPlayer do
  begin
    try
     Notify := True;
     CDPlayerINIFile := TIniFile.Create('CDINI.INI');
     AvailableTracks := TStringList.Create;
     PlayList := TStringList.Create;
     FillChar(MCISysInfo, SizeOf(MCISysInfo), #0);
     FillChar(Data, SizeOf(Data), 0);
     MCISysInfo.wDeviceType := mci_DevType_CD_Audio;
     MCISysInfo.lpstrReturn := @Data;
     MCISysInfo.dwNumber := 1;
     MCISysInfo.dwRetSize := SizeOf(Data);
     mciSendCommand(0, mci_SysInfo, mci_SysInfo_InstallName, Longint(@MCISysInfo));
     mciSendCommand(0, mci_SysInfo, mci_SysInfo_Name, Longint(@MCISysInfo));
     mciSendCommand(0, mci_SysInfo, mci_SysInfo_Open, Longint(@MCISysInfo));
{ The following command returns the number of CD audio devices in
  lpstrReturn as longint) }
     mciSendCommand(0, mci_SysInfo, mci_SysInfo_Quantity, Longint(@MCISysInfo));
     Open;
     TimeFormat := tfTMSF;
     OnDiscChange; Notify := True;
     RepeatTrack.Checked := CDPlayerINIFile.ReadBool('Preferences', 'Repeat', False);
     ContinuousPlay.Checked := CDPlayerINIFile.ReadBool('Preferences', 'Continuous', False);
     StopOnExit := CDPlayerINIFile.ReadBool('Preferences', 'StopOnExit', True);
     SaveOnExit := CDPlayerINIFile.ReadBool('Preferences', 'SaveOnExit', True);
     IntroLength := CDPlayerINIFile.ReadInteger('Preferences', 'IntroLength', 10);
     FrameLength := CDPlayerINIFile.ReadInteger('Preferences', 'Frame', 1);
     {UpdateDisplay(Self); OnDiscChange is already calling UpdateDisplay}
     if CDPlayer.Mode in [mpStopped, mpPlaying] then
      UpdateDisplayTimer.Enabled := True;
    except
     MessageDlg(ErrorMessage, mtError, [mbOk], 0);
     CDPlayer.EnabledButtons := [];
    end;
  end;
 end;

procedure TCDPlayerForm.UpdateDisplay(Sender: TObject);

  procedure DoUpdate;
  begin
  end;

const
 TitleWord:Word=0;
var
 TrackLen: Longint;
 TrackNo, CurrItem, IndexTrack: Integer;
begin
{ if (CDPlayer.Mode in [mpNotReady, mpOpen, mpStopped]) and not Paused then exit; }
 Pos := CDPlayer.Position;
 if CDPlayer.Mode<>mpOpen then
  begin
   TrackNum := mci_TMSF_Track(Pos);
   Minutes := mci_TMSF_Minute(Pos);
   Secs := mci_TMSF_Second(Pos);
  end;
{ The next statement will cause the harddisk LED to light up,
  if the CD ROM is an IDE model. Otherwise, the CD ROM LED will light up }
{ TrackLen := CDPlayer.TrackLength[tfTMSFRec(Pos).Tracks]; }
  TrackLen := SongLength[TrackNum];
{ PlayListIndex is initially 0. It is updated as long as a song is being
  played }
  try
   TrackNo := TSongTrack(PlayList.Objects[PlayListIndex]).TrackNo;
  except
  { assume that TrackNo := ...Objects[PlayListIndex]... failed,
    Search through the playlist for a song that matches the current track
    being played and update PlayListIndex to it}
  for IndexTrack := 0 to PlayList.Count-1 do
   if TSongTrack(PlayList.Objects[IndexTrack]).TrackNo=TrackNum then
     begin
      PlayListIndex := IndexTrack;
      Break;
     end;
  end;
  CurrItem := TrackToPlay.ItemIndex;
  try
  if CurrItem=lb_Err then
   begin
    if PlayListIndex<=PlayList.Count-1 then
     for IndexTrack := 0 to PlayList.Count-1 do
      if TSongTrack(PlayList.Objects[IndexTrack]).TrackNo=TrackNum then
       begin
        PlayListIndex := IndexTrack;
        Break;
       end;
    CurrItem := PlayListIndex;
   end;
{ if a song is playing, and the display on the screen doesn't match
  the track that is currently being played, then
  2 things may have happened.
  1: Just started playing a song.
     Really need to update the display and the play list index.
  2: Finished playing a song and without our noticing, the CD drive is
     going to play the next song already. Skip update of the play list index.
     The code that test mpStopped will do that. }
   if (TrackToPlay.Items.Count>0) and
      (TSongTrack(TrackToPlay.Items.Objects[CurrItem]).TrackNo<>TrackNum) and
      (CDPlayer.Mode=mpPlaying) then
   begin
     for IndexTrack := 0 to PlayList.Count-1 do
      if TSongTrack(PlayList.Objects[IndexTrack]).TrackNo=TrackNum then
       begin
        PlayListIndex := IndexTrack;
        Break;
       end;
    TrackToPlay.ItemIndex := PlayListIndex;
   end else if TrackToPlay.ItemIndex=-1 then TrackToPlay.ItemIndex := CurrItem;
  except
   { error where? PlayList.Objects[PlayListIndex]? }

  end;
 try
  case TimeDisplayStyle of
   tTrackTimeElapsed:
    TimeDisplay.Caption := Format('[%2.2d] %2.2d:%2.2d', [TrackNum,Minutes, Secs]);
   tTrackTimeRemaining:
    TimeDisplay.Caption := Format('[%2.2d] %2.2d:%2.2d', [TrackNum,Minutes, Secs]);
   tDiscTimeRemaining: ;
  end;
 except
  TimeDisplay.Caption := 'Exception occurred';
 end;
{$IFDEF Win32}
  StatusBar.Panels.Items[1].Text :=
{$ELSE}
  TrackTime.Caption :=
{$ENDIF}
                       Format('Track %2.2d:%2.2d m:s',
                              [mci_MSF_Minute(TrackLen),
                               mci_MSF_Second(TrackLen)]);

{ Watch out for this in Windows 95 when minimized!
  Look at the taskbar! Neat feature to have! }
 try
  Application.Title := Format('%s - [%s] %2.2d:%2.2d',
                             [sCDTitle, PlayList[PlayListIndex], Minutes, Secs]);
  if GetActiveWindow<>Handle then
   Caption := Application.Title else
   Caption := 'CD Player';
 except
  Application.Title := CDPlayerForm.Caption;
 end;
 case CDPlayer.Mode of
  mpStopped:
    if not Stopped then
    if Paused then
     begin
      TogglePausedMode := not TogglePausedMode;
      if TogglePausedMode then TimeDisplay.Caption := EmptyStr;
     end else
    if RepeatTrack.Checked then
     begin { repeat mode takes priority over continuous mode }
           { check if in repeat mode, if so repeat track/s }
      if (RepeatStartPos=RepeatEndPos) or
         (RepeatStartPos+1=RepeatEndPos) then {is our variables initialised? }
       begin
{ Code for repeating single track }
{ Update PlayListIndex to the proper track }
{ Check that RepeatStartPos is initialized. If it is, RepeatEndPos is also
  initialised. Next, check that the track after RepeatStartPos is the
  same as RepeatEndPos so we can establish that we need to repeat a single
  track. If RepeatStartPos+1 < RepeatEndPos, we'll have established that
  we need to repeat several tracks, so we need to take another kind of
  action. }
        if (RepeatStartPos>0) and (RepeatStartPos+1=RepeatEndPos) then
         for IndexTrack := 0 to PlayList.Count-1 do
          if TSongTrack(PlayList.Objects[IndexTrack]).TrackNo=RepeatStartPos then
           begin
            PlayListIndex := IndexTrack;
            Break;
           end;
        PlayNextTrack(0, False);
{ End code for repeating single track }
       end;
     end else
      PlayNextTrack(1, ContinuousPlay.Checked);
  mpPlaying:
   begin
    CDStarted := True; Stopped := False;
    PlayingTrack := TrackNum;
    if (IntroPlay1.Checked) and (mci_TMSF_Second(Pos)>IntroLength) then
     begin
      CDPlayer.Next;
      exit;
     end;
   end;
 end;
end;

procedure TCDPlayerForm.EditPlayList1Click(Sender: TObject);
var
 I, Listed: Word;
begin
  PlayList.Assign(TrackToPlay.Items);
  DiscSettings := TDiscSettings.Create(Application);

  Listed := CDPlayerIniFile.ReadInteger('Artist Name', 'Listed', 0);
  if Listed>0 then
   for I := 0 to Listed-1 do
    begin
     DiscSettings.AddArtist(CDPlayerIniFile.ReadString('Artist Name', Format('%d', [I]), ''));
    end;

  if DiscSettings.ShowModal=mrOk then
   begin
    LabelArtistName.Caption := sArtistName;
    LabelCDTitle.Caption := sCDTitle;
    TrackToPlay.Items.Assign(PlayList);
    UpdatePlayListTime;
    FlushCDTracks;
   end;
  DiscSettings.Free;
end;

{ If a CD is inserted, read the info from it and write to disk }
procedure TCDPlayerForm.OnDiscChange;
 procedure NoDisc;
 var
  SR: TSearchRec;
  SavedMode: Word;
        begin { Assumes audio CD have more than 1 track }
         TrackNum := 0; Minutes := 0; Secs := 0;
{$IFNDEF Win32}
         if CheckCDDrive(CDDrive)<=1 then
{$ELSE}
{$ENDIF}
          begin
           try
            SavedMode := SetErrorMode(sem_FailCriticalErrors);
            try
             if FindFirst(Char(CDDrive+Ord('A'))+':\*.*', faAnyFile, SR)=0 then
              LabelArtistName.Caption := 'Data disc loaded' else
              LabelArtistName.Caption := 'Drive empty';
              SysUtils.FindClose(SR);
            except
             LabelArtistName.Caption := 'Data disc loaded or drive empty';
            end;
           finally
            SetErrorMode(SavedMode);
           end;
          end;
         LabelCDTitle.Caption := 'Please insert an audio CD';
{ Will cause an exception initially, when called by FormCreate, right
  after Open, if a data disc is loaded }
         try
          UpdateDisplay(Self);
         except
         end;
         UpdateDisplayTimer.Enabled := False;
         DiscLoaded := False; MaxTracks := 0;
         FillChar(SongLength, SizeOf(SongLength), 0);
         RepeatStartPos := 0; CDStarted := False;
         RepeatEndPos := 0; PlayListIndex := 0;
         PlayHour := 0; PlayMin := 0; PlaySec := 0;
         EditPlayList1.Enabled := False;
         CDPlayer.EnabledButtons := [btEject];
         DiscID := 0;
        end;
 var
  TrackName, Section: String;
  numorder: string absolute TrackName;
  I, Track: Word; icError: Integer;
  numplay: Word; { no. of songs in playlist }
  SongTrack: TSongTrack;
  FirstTimeLoadedIntoCD: Boolean;
  SavedStyle: TComboBoxStyle absolute icError;
begin
     PlayTime := 0.0;
     if (CDPlayer.Mode<>mpOpen) then
      with CDPlayer do begin
       if Tracks>=1 then
        begin
         FirstTimeLoadedIntoCD := False;
         EnabledButtons := [btPlay..btEject];
         EditPlayList1.Enabled := True;
         DiscID := Length; MaxTracks := Tracks;
{ The Microsoft CD Disc ID must be converted to a hex string before
  showing it on screen. Here, we are just showing how to get the ID }
         MicrosoftDiscID := GetMicrosoftCDID;
         SavedStyle := TrackToPlay.Style;
         TrackToPlay.Style := csSimple;
         for I := 1 to Tracks do { Update tracks length to variable}
          begin
           TrackToPlay.Text := Format('Scanning track %d', [I]);
           TrackToPlay.Update;
           SongLength[I] := CDPlayer.TrackLength[I];
          end;
         TrackToPlay.Style := SavedStyle;
         DiscLoaded := True;
         UpdateDisplayTimer.Enabled := True;
         Section := IntToStr(Length);
{ Artist 00 is unknown. }
         LabelArtistName.Caption :=
         CDPlayerIniFile.ReadString('Artist Name', IntToStr(CDPlayerIniFile.ReadInteger(Section, 'Artist', 0)), EmptyStr);
         if LabelArtistName.Caption=EmptyStr then
          begin
           LabelArtistName.Caption := 'Artist Name';
           FirstTimeLoadedIntoCD := True;
          end;
         LabelCDTitle.Caption := CDPlayerIniFile.ReadString(Section, 'CDTitle', 'CD Title');
         sArtistName := LabelArtistName.Caption;
         sCDTitle := LabelCDTitle.Caption;
         AvailableTracks.Clear;
         for I := 1 to MaxTracks do
          begin
           TrackName := Format('%2.2d', [I]);
           TrackName := CDPlayerIniFile.ReadString(Section, TrackName, 'Track '+TrackName);
           SongTrack := TSongTrack.Create(I);
           AvailableTracks.AddObject(TrackName, SongTrack);
          end;
         numplay := CDPlayerIniFile.ReadInteger(Section, 'numplay', 0);
         if numplay=0 then
          begin { if no songs in play list, default to all tracks }
           PlayList.Assign(AvailableTracks);
           TrackToPlay.Items.Assign(PlayList);
{           numplay := MaxTracks; }
          end else
          begin
           PlayList.Clear;
           numorder := CDPlayerIniFile.ReadString(Section, 'numorder', EmptyStr);
           for I := 1 to numplay do
            begin
             Val(Copy(numorder, ((I-1)*3)+1, 2), Track, icError);
             try
              PlayList.AddObject(AvailableTracks.Strings[Track-1],
                                 AvailableTracks.Objects[Track-1] as TSongTrack);
             except
             end;
            end;
           TrackToPlay.Items.Assign(PlayList);
           TrackToPlay.ItemIndex := 0;
          end;
         if FirstTimeLoadedIntoCD then FlushCDTracks;
         Refresh;
         UpdatePlayListTime;
        end else NoDisc;
      end else NoDisc;
end;

procedure TCDPlayerForm.UpdatePlayListTime;
var
 I: Integer;
 Track: Word;
begin
 PlayTime := 0.0;
 for I := 0 to PlayList.Count-1 do
  begin
   Track := TSongTrack(PlayList.Objects[I]).TrackNo;
   PlayTime := PlayTime +
               EncodeTime(0, tfMSFRec(SongLength[Track]).Minutes,
                             tfMSFRec(SongLength[Track]).Secs, 0);
  end;
 DecodeTime(PlayTime, PlayHour, PlayMin, PlaySec, Track);
{$IFDEF Win32}
  StatusBar.Panels.Items[0].Text :=
{$ELSE}
 TotalPlayTimeOfTrack.Caption :=
{$ENDIF}
 Format('Total Play %2.2d:%2.2d m:s', [PlayMin+PlayHour*60, PlaySec]);
end;

{ Produces the equivalent Microsoft CD ID for an audio CD provided the
  tracks/songs are more than 2. Tested for CDs with tracks/songs more than 2 }
function TCDPlayerForm.GetMicrosoftCDID: Longint;
var
 SavedFormat: TMPTimeFormats;
 Temp, Total, Position, Length, Index: Longint;
begin
 SavedFormat := CDPlayer.TimeFormat;

 Total := 0;
 CDPlayer.TimeFormat := tfMSF;
 for Index := 1 to CDPlayer.Tracks do
  begin
   Position := CDPlayer.TrackPosition[Index];
   if MaxTracks<3 then
    begin
     Length := CDPlayer.TrackLength[Index];
     Inc(Total,           MCI_MSF_FRAME (Length)+
               (75*       MCI_MSF_SECOND(Length))+
               (75 * 60 * MCI_MSF_MINUTE(Length)));
    end;
   Temp := MCI_MAKE_MSF( MCI_MSF_FRAME (Position),
                         MCI_MSF_SECOND(Position),
                         MCI_MSF_MINUTE(Position) );
   Inc(Total, Temp);
  end;

 CDPlayer.TimeFormat := SavedFormat;

 Result := Total;
end;

procedure TCDPlayerForm.CDPlayerNotify(Sender: TObject);
begin
 if DiscID<>CDPlayer.Length then
  begin
   OnDiscChange;
  end else
  begin { Reached the end of a song? }
  end;
end;


procedure TCDPlayerForm.FormDestroy(Sender: TObject);
begin
 if StopOnExit then
   CDPlayer.Stop;
 try
   with CDPlayerINIFile do
    begin
     WriteBool('Preferences', 'Repeat', RepeatTrack.Checked);
     WriteBool('Preferences', 'Continuous', ContinuousPlay.Checked);
     WriteBool('Preferences', 'StopOnExit', StopOnExit);
     WriteBool('Preferences', 'SaveOnExit', SaveOnExit);
     WriteInteger('Preferences', 'IntroLength', IntroLength);
     WriteInteger('Preferences', 'Frame', FrameLength);
    end;
{   FlushCDTracks; }
 finally
  CDPlayerIniFile.Free;
  AvailableTracks.Free;
  PlayList.Free; { May occur list index out of bounds }
 end;
end;

procedure TCDPlayerForm.RepeatTrackClick(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;



procedure TCDPlayerForm.CDPlayerClick(Sender: TObject; Button: TMPBtnType;
  var DoDefault: Boolean);
var
 TrackNo: Word; 
 SetParm: TMCI_Set_Parms;
 StatusParm: TMCI_Status_Parms;
 SavedFormat: TMPTimeFormats;
begin
 CDPlayer.Notify := True;
 case Button of
  btPlay:
   begin
    if CDPlayer.Mode=mpPlaying then exit;
    PlayNextTrack(0, False);
    Stopped := False;
{    I := TrackToPlay.ItemIndex;
    TrackNo := TSongTrack(TrackToPlay.Items.Objects[I]).TrackNo;
    TrackToPlay.ItemIndex := TrackToPlay.ItemIndex+1; }
    RepeatStartPos := CDPlayer.TrackPosition[TrackNo];
    RepeatEndPos := CDPlayer.TrackPosition[TrackNo+1];
    CDPlayer.StartPos := RepeatStartPos;
    CDPlayer.EndPos := RepeatEndPos;
   end;
  btPause:
  if CDPlayer.Mode=mpStopped then
   begin
    Paused := False;
    DoDefault := False;
    CDPlayer.Resume;
   end else
   begin
    Paused := True;
    DoDefault := False;
    CDPlayer.Pause;
   end;
  btStop:
  begin
   Stopped := True;
   CDPlayer.Stop;
   CDPlayer.Position := TrackNum;
   DoDefault := False;
  end;
  MPlayer.btNext:
  begin
   DoDefault := False;
   PlayNextTrack(1, True);
   UpdateDisplay(Self);
  end;
  MPlayer.btPrev:
  begin
   DoDefault := False;
   PlayNextTrack(-1, False);
   UpdateDisplay(Self);
  end;
  btStep:
  begin   { Borland's MPlayer unit handles only Step for Videos }
   SavedFormat := CDPlayer.TimeFormat;
   CDPlayer.EndPos := TrackNum+1;
   Secs := Secs+2;
   CDPlayer.StartPos := mci_Make_TMSF(TrackNum, Minutes, Secs, 0);
   CDPlayer.Pause;
   CDPlayer.Notify := True;
   CDPlayer.Play;
   CDPlayer.TimeFormat := SavedFormat;
  end;
  btBack:
  begin
   CDPlayer.Position := mci_Make_TMSF(TrackNum, Minutes, Secs-1, 0);
   CDPlayer.EndPos := TrackNum+1;
   CDPlayer.Play;
  end;
  btEject:
  begin { Bug in Borland's MPlayer: MPlayer's default eject routine doesn't
          handle the case where the door is already ejected once, ie already
          opened }
{ Will return 0 in dwReturn, if no CD inserted or drive out of bay.
  1 if CD is present and drive in bay.
  Doesn't distinguish between audio and data CD
  Doesn't force the drive into the bay if it's out of bay }
   StatusParm.dwCallback := CDPlayer.Handle;
   StatusParm.dwItem := mci_Status_Ready;
   mciSendCommand(CDPlayer.DeviceID, mci_Status,
                  mci_Status_Item, Longint(@StatusParm));

{
  dwReturn = 1 if media present, 0 otherwise. Doesn't distinguish
  between audio and data CD }

   StatusParm.dwItem := mci_Status_Media_Present;
   mciSendCommand(CDPlayer.DeviceID, mci_Status,
                  mci_Status_Item, Longint(@StatusParm));

   if CDPlayer.Mode=mpOpen then
    begin
     DoDefault := False;
     SetParm.dwCallback := CDPlayer.Handle;
     mciSendCommand(CDPlayer.DeviceID, mci_Set,
                    mci_Set_Door_Closed or mci_Notify, Longint(@SetParm) );
    end;
  end;
 end;
end;

procedure TCDPlayerForm.Preferences1Click(Sender: TObject);
begin
 Preference := TPreference.Create(Application);
 Preference.Visible := False;
 Preference.ShowModal;
end;

{ This method seeks to a certain track in the CD and play it.
  Ways to seek, use Next and Previous, or Position}
procedure TCDPlayerForm.TrackToPlayClick(Sender: TObject);
var
 TrackNo: Word;
begin
 CDPlayer.Wait := True;
 CDPlayer.Stop;
 with TrackToPlay do
  begin
   PlayListIndex := ItemIndex;
   TrackNo := TSongTrack(Items.Objects[PlayListIndex]).TrackNo;
  end;
{ TrackNo := TSongTrack(TrackToPlay.Items.Objects[TrackToPlay.ItemIndex]).TrackNo; }
 RepeatStartPos := CDPlayer.TrackPosition[TrackNo];
 CDPlayer.StartPos := RepeatStartPos;
 if TrackNo<>MaxTracks then
  begin
   RepeatEndPos := CDPlayer.TrackPosition[TrackNo+1];
   CDPlayer.EndPos := RepeatEndPos;
  end else
  begin
   {CDPlayer.EndPos := CDPlayer.TrackLength[TrackNo];}
   CDPlayer.Play;
  end;
 CDPlayer.Notify := True;
 CDPlayer.Play;
end;

procedure TCDPlayerForm.PlayTrack(TrackNo: Word);
begin
 CDPlayer.StartPos := TrackNo;
 if TrackNo<MaxTracks then
  CDPlayer.EndPos := TrackNo+1;
 CDPlayer.Notify := True;
 CDPlayer.Play;
end;

procedure TCDPlayerForm.PlayNextTrack(Next: Integer; WrapAround: Boolean);
var
 MaxTracks: Integer;
 WrappedAround: Boolean;
var
 GonnaPlayTrack: Word;
begin
 WrappedAround := False;
 if CDStarted then
  begin
   Inc(PlayListIndex, Next);
   MaxTracks := TrackToPlay.Items.Count;
   if (PlayListIndex<0) or (PlayListIndex>=MaxTracks) then
    begin
     PlayListIndex := 0;
     WrappedAround := True;
    end;
   TrackToPlay.ItemIndex := PlayListIndex;
  end;


 if (WrapAround and WrappedAround) or (not WrappedAround) then
  begin
   GonnaPlayTrack := TSongTrack(TrackToPlay.Items.Objects[PlayListIndex]).TrackNo;
   PlayTrack(GonnaPlayTrack);
  end else
{ Last track has been played and we're not in continuous play mode.
  Signal stop to program }
  Stopped := True;
end;

{ When a CD is inserted, WParamLo = 4,
  When ejected, WParamLo = 0 }
procedure TCDPlayerForm.DiscInserted(var Message: TMessage);
begin
 DiscMsg[DiscIndex] := Message;
 if DiscIndex<5 then Inc(DiscIndex);
 Message.Result := 1;
 OnDiscChange;
 MessageBeep(mb_Ok);
end;

procedure TCDPlayerForm.WMSysCommand(var Message: TWMSysCommand);
begin
{ inherited; }
inherited;
exit;
 case Message.CmdType and $FFF0 of
  sc_Minimize: WindowState := wsMinimized;
  sc_Maximize: WindowState := wsMaximized;
  sc_Restore: WindowState := wsNormal;
 else
  inherited;
 end;
end;

{
Writes all the tracks of a CD onto disk
Checks that a CD is actually inserted by looking at the DiscID variable
}
procedure TCDPlayerForm.FlushCDTracks;
var
 FoundListed: Bool;
 xCount, I, Listed, TrackNo: Word;
 ID: string[3];
 TrackName: String;
 Section: String[10];
begin
  with CDPlayer do
  if (DiscID<>0) and (DiscLoaded) then
  begin
   if MaxTracks=1 then Abort;
   Section := IntToStr(DiscID);

   Listed := CDPlayerIniFile.ReadInteger('CDTitles', 'Listed', 0);
   FoundListed := False;
   for I := 1 to Listed do
    begin
     FoundListed := CDPlayerIniFile.ReadInteger('CDTitles', Format('%.2d', [I]), 0)=DiscID;
     if FoundListed then Break;
    end;
   if not FoundListed then
    begin
     CDPlayerIniFile.WriteInteger('CDTitles', 'Listed', Listed+1);
     CDPlayerIniFile.WriteInteger('CDTitles', Format('%.2d', [Listed+1]), DiscID);
    end;

   Listed := CDPlayerIniFile.ReadInteger('Artist Name', 'Listed', 0);
   FoundListed := False;
   if Listed>0 then
    for I := 0 to Listed-1 do
     begin
      FoundListed := CDPlayerIniFile.ReadString('Artist Name', Format('%d', [I]), '')=LabelArtistName.Caption;
      if FoundListed then Break;
     end;
   if not FoundListed then
    begin
     Inc(I);
     CDPlayerIniFile.WriteInteger('Artist Name', 'Listed', Listed+1);
     CDPlayerIniFile.WriteString('Artist Name', Format('%d', [I]), LabelArtistName.Caption);
    end;

   CDPlayerIniFile.WriteString(Section, 'Artist', IntToStr(I));
   CDPlayerIniFile.WriteString(Section, 'CDTitle', LabelCDTitle.Caption);
    for I := 1 to MaxTracks do
     begin
      ID := Format('%2.2d', [I]);
      TrackName := AvailableTracks.Strings[I-1]; { May or may not occur
                                                   index out of bounds }
      CDPlayerIniFile.WriteString(Section, ID, TrackName);
     end;
    CDPlayerIniFile.WriteInteger(Section, 'numplay', TrackToPlay.Items.Count);
    if TrackToPlay.Items.Count>=1 then
     begin
      TrackNo := TSongTrack(TrackToPlay.Items.Objects[0]).TrackNo;
      TrackName := Format('%2.2d', [TrackNo]);
      xCount := TrackToPlay.Items.Count;
      for I := 1 to xCount-1 do
       begin
        TrackNo := TSongTrack(TrackToPlay.Items.Objects[I]).TrackNo;
        TrackName := TrackName + ' ' +
                     Format('%2.2d', [TrackNo]);
       end;
      CDPlayerIniFile.WriteString(Section, 'numorder', TrackName);
     end;
  end;
end;

{ Windows 95 style hint window, actually encapsulated in COMCTL32.DLL,
  but we suffice by making our own }
constructor T95HintWindow.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 if Canvas.Brush.Bitmap=nil then
  Canvas.Brush.Bitmap := TBitmap.Create;
 Win95HintBrushForm := TWin95HintBrushForm.Create(Self);
 try
  try
  Canvas.Brush.Bitmap.Assign(Win95HintBrushForm.Win95HintBrush.Picture);
  except
  end;
 finally
  Win95HintBrushForm.Free;
 end;
end;

procedure T95HintWindow.Paint;
var
  R: TRect;
  CCaption: array[0..255] of Char;
  SaveHandle: HDC;
begin
  R := ClientRect;
  Inc(R.Left, 1);
  Canvas.FillRect(ClientRect);
  SaveHandle := Canvas.Handle;
  Canvas.Handle := GetWindowDC(Handle);
  with Canvas do
   begin
    Pen.Color := RGB(192, 220, 192);
    MoveTo(0, Height);
    LineTo(0, 0);
    LineTo(Width, 0);
   end;
  ReleaseDC(Handle, Canvas.Handle);
  Canvas.Handle := SaveHandle;
  SetBkMode(Canvas.Handle, Transparent);
  DrawText(Canvas.Handle, StrPCopy(CCaption, Caption), -1, R,
    DT_LEFT or DT_NOPREFIX or DT_WORDBREAK);
end;

procedure TCDPlayerForm.Volumecontrol1Click(Sender: TObject);
begin
 WinExec('SNDVOL32', sw_ShowNormal);
end;

function CheckWin95: Bool;
var
 Version: Word;
begin
 Version := LoWord(GetVersion);
 Result := Version=$5F03;
end;

function CheckGotCD: Bool;
begin
end;

function CheckCDAudioExist: Bool;
const
 DeviceID: array[1..2] of string[8]=('cdaudio', 'cdaudio1');
var
 IniFile: TIniFile;
 mciCDAudio: string[20];
 I: Word;
{ cdaudio=mcicda.drv is 18 in length }
begin
 Result := False;
 IniFile := TIniFile.Create('SYSTEM.INI');
 for I := 1 to 2 do
  begin
   mciCDAudio := IniFile.ReadString('mci', DeviceID[I], EmptyStr);
   Result := Result or (mciCDAudio<>EmptyStr);
  end;
 IniFile.Free;
end;

procedure TCDPlayerForm.Tracktimeelapsed1Click(Sender: TObject);
begin
 TimeDisplayStyle := tTrackTimeElapsed;
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TCDPlayerForm.TrackTimeremaining1Click(Sender: TObject);
begin
 TimeDisplayStyle := tTrackTimeRemaining;
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TCDPlayerForm.Disctimeremaining1Click(Sender: TObject);
begin
 TimeDisplayStyle := tDiscTimeRemaining;
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TCDPlayerForm.Export1Click(Sender: TObject);
var
 AuthorID, TitleID, I, SongCount, Listed: Word;
 Author, Section, SongTitle, CDTitle: string[50];
begin
 Listed := CDPlayerIniFile.ReadInteger('CDTitles', 'Listed', 0);
 if Listed<>0 then
  begin
   try
   Screen.Cursor := crHourglass;
   TableCDAuthor.Open;
   TableCDSongs.Open;
   TableCDTitles.Open;
   for I := 1 to Listed do
    begin
     Section := CDPlayerIniFile.ReadString('CDTitles', Format('%.2d', [I]), EmptyStr);
     Author := IntToStr(CDPlayerIniFile.ReadInteger(Section, 'Artist', 0));
     Author := CDPlayerIniFile.ReadString('Artist Name', Author, EmptyStr);
     TableCDAuthor.SetKey;
     TableCDAuthorAuthor.Value := Author;
     if not TableCDAuthor.GotoKey then
      begin
       TableCDAuthor.Append;
       TableCDAuthorAuthor.Value := Author;
       AuthorID := TableCDAuthor.RecordCount+1;
       TableCDAuthorAuthorID.Value := AuthorID;
       TableCDAuthor.Post;
      end else
      begin
       AuthorID := TableCDAuthorAuthorID.Value;
      end;
     CDTitle := CDPlayerIniFile.ReadString(Section, 'CDTitle', EmptyStr);
     TableCDTitles.SetKey;
     TableCDTitlesAuthorID.Value := AuthorID;
     TableCDTitlesTitle.Value := CDTitle;
     if not TableCDTitles.GotoKey then
      begin
       TableCDTitles.Append;
       TableCDTitlesTitle.Value := CDTitle;
       TableCDTitlesAuthorID.Value := AuthorID;
       TitleID := TableCDTitles.RecordCount+1;
       TableCDTitlesTitleID.Value := TitleID;
       TableCDTitles.Post;
      end else
      begin
       TitleID := TableCDTitlesTitleID.Value;
      end;
     SongCount := 1;
     repeat
      SongTitle := CDPlayerIniFile.ReadString(Section, Format('%.2d', [SongCount]), EmptyStr);
      if SongTitle=EmptyStr then Break;
      TableCDSongs.SetKey;
      TableCDSongsAuthorID.Value := AuthorID;
      TableCDSongsTitleID.Value := TitleID;
      TableCDSongsSongTitle.Value := SongTitle;
      if not TableCDSongs.GotoKey then
       begin
        TableCDSongs.Append;
        TableCDSongsAuthorID.Value := AuthorID;
        TableCDSongsTitleID.Value := TitleID;
        TableCDSongsSongTitle.Value := SongTitle;
        TableCDSongsTrack.Value := SongCount;
        TableCDSongs.Post;
       end;
      Inc(SongCount);
     until SongTitle=EmptyStr;
    end;
   finally
   Screen.Cursor := crDefault;
   TableCDAuthor.Close;
   TableCDSongs.Close;
   TableCDTitles.Close;
   end;
  end;
end;

initialization
 HintWindowClass := T95HintWindow;
{ Because we want a new kind of hint window, chang HintWindowClass.
  Since Application contains an old hint window, we need to release it
  and recreate application }
{$IFNDEF WIN32}
 if not CheckWin95 then
  begin
   MessageDlg('Windows 95 required!', mtWarning, [mbOk], 0);
   Halt;
  end;
{$ENDIF}
 if not CheckCDAudioExist then
  begin
   MessageDlg('No CD audio device exist!', mtError, [mbOk], 0);
   Halt;
  end;
 Application.Free;
 Application := TApplication.Create(nil);
 Application.ShowHint := True;
end.
