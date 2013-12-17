{*******************************************************}
{                                                       }
{       Delphi CD Player settings unit                  }
{                                                       }
{       Copyright (c) 1995 Chua Chee Wee                }
{                                                       }
{*******************************************************}
{ Monday 01 May 1995, 10:00pm                           }
{ Created                                               }
{ Mostly code stolen from Borland's gallery's Form Templates' Dual Listbox }
unit Cdset;

interface

uses Messages, WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, IniFiles, CDIni, Dialogs, Menus;

type
  TDiscSettings = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    SrcList: TListBox;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    Bevel1: TBevel;
    TrackLabel: TLabel;
    Bevel2: TBevel;
    LabelTitle: TLabel;
    GroupBoxCDTitle: TGroupBox;
    EditTitle: TEdit;
    LabelArtist: TLabel;
    GroupBox2: TGroupBox;
    TrackEdit: TEdit;
    GroupBoxArtist: TGroupBox;
    SetNameButton: TButton;
    Label3: TLabel;
    Label4: TLabel;
    DstList: TListBox;
    GroupBox1: TGroupBox;
    EditArtists: TComboBox;
    PopupMenuCategory: TPopupMenu;
    Classic1: TMenuItem;
    Classic2: TMenuItem;
    Rock1: TMenuItem;
    Favorite1: TMenuItem;
    DiscSettingsStatusBar: TPanel;
    Skip2: TMenuItem;
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExcAllBtnClick(Sender: TObject);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetButtons;
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure SrcListClick(Sender: TObject);
    procedure SetNameButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PopupMenuSkipPopup(Sender: TObject);
    procedure Skip2Click(Sender: TObject);
  private
    EditIndex: Integer;
    ToFocusNow, OkClicked: Boolean;
    { Private declarations }
    procedure GetAvailableTracksFocus;
    procedure CMCancelMode(var Message: TMessage); message CM_CANCELMODE;
  public
    { Public declarations }
    procedure AddArtist(const Artist: string);
  end;

var
  DiscSettings: TDiscSettings;

implementation
uses SysUtils;
{$R *.DFM}

procedure TDiscSettings.IncludeBtnClick(Sender: TObject);
var
  Index: Integer;
  List: TCustomListBox; Items: TStrings;
  I: Integer;
begin
  Index := GetFirstSelection(SrcList);
  List := SrcList;Items := DstList.Items;
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then
    begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
    end;
  SetItem(SrcList, Index);
end;

procedure TDiscSettings.ExcludeBtnClick(Sender: TObject);
var
  Index: Integer;
  List: TCustomListBox; Items: TStrings;
  I: Integer;
begin
  Index := GetFirstSelection(DstList);
  List := DstList;Items := DstList.Items;
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then
    begin
      Items.Delete(I);
    end;
  SetItem(DstList, Index);
end;

procedure TDiscSettings.IncAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  DstList.Items.Clear;
  for I := 0 to SrcList.Items.Count - 1 do
    DstList.Items.AddObject(SrcList.Items[I],
      SrcList.Items.Objects[I]);
  SetButtons;
end;

procedure TDiscSettings.ExcAllBtnClick(Sender: TObject);
begin
{  for I := 0 to DstList.Items.Count - 1 do
    SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]); }
  DstList.Items.Clear;
  SetItem(DstList, 0);
end;

procedure TDiscSettings.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then
    begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end;
end;

procedure TDiscSettings.SetButtons;
var
  SrcEmpty, DstEmpty: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  IncludeBtn.Enabled := not SrcEmpty;
  IncAllBtn.Enabled := not SrcEmpty;
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled := not DstEmpty;
end;

function TDiscSettings.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TDiscSettings.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do
  begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
end;

{ When ok button is clicked, save the various stuffs like
  Available Tracks name, artist name and CD Title }
procedure TDiscSettings.OKBtnClick(Sender: TObject);
begin
 AvailableTracks.Assign(SrcList.Items);
 if DstList.Items.Count>0 then
  PlayList.Assign(DstList.Items);
 sArtistName := EditArtists.Text;
 sCDTitle := EditTitle.Text;
 OkClicked := True;
 Release;
end;

procedure TDiscSettings.GetAvailableTracksFocus;
begin
 TrackLabel.Caption := Format('Track %2.2d', [SrcList.ItemIndex+1]);
 TrackEdit.Text := SrcList.Items[SrcList.ItemIndex];
end;

procedure TDiscSettings.CMCancelMode(var Message: TMessage);
var
 P: TPoint;
 I: Integer;
begin
 inherited;
 if not Assigned(Pointer(Message.LParam)) then
  begin
   GetCursorPos(P);
   if ControlAtPos(P, True)=DstList then
    begin
     I := DstList.ItemAtPos(P, True);
     if I<>-1 then
      DstList.ItemIndex := I;
    end;
  end;
end;


procedure TDiscSettings.AddArtist(const Artist: string);
begin
 EditArtists.Items.Add(Artist);
end;

procedure TDiscSettings.FormCreate(Sender: TObject);
begin
 OkClicked := False;
 EditArtists.Text := sArtistName;
 EditTitle.Text := sCDTitle;
 ToFocusNow := True;
 SrcList.ItemIndex := 1; EditIndex := 0;
 SrcList.Selected[0] := True;
 try
  SrcList.Items.Assign(AvailableTracks);
  if DstList.Items.Count=0 then DstList.Items.Assign(PlayList);
 except
 end;
 GetAvailableTracksFocus;
 SetButtons;
end;

{ Abandon changes by closing, not saving the list}
procedure TDiscSettings.CancelBtnClick(Sender: TObject);
begin
 OkClicked := False;
 Release;
end;

{ Update the track label and name }
procedure TDiscSettings.SrcListClick(Sender: TObject);
begin
 GetAvailableTracksFocus;
 EditIndex := SrcList.ItemIndex;
end;

{ When enter key is pressed, set the name and move to the next
  in the list }
procedure TDiscSettings.SetNameButtonClick(Sender: TObject);
begin
 if ActiveControl=EditTitle then
  begin
   { Switch to }
   TrackEdit.SetFocus;
   exit;
  end;
 EditIndex := SrcList.ItemIndex;
 if EditIndex in [0..MaxTracks-1] then
  begin

   { Update playlist track names, if any }
   try { IndexOf may return -1 which indicates string not in list.
         attempting to access the object by -1 will cause an EGPFault
         or EFault }
    with DstList, Items do
     Items[IndexOf(SrcList.Items[EditIndex])] := TrackEdit.Text;
   except
   end;

   SrcList.Items.Delete(EditIndex);
   SrcList.Items.Insert(EditIndex, TrackEdit.Text);
   if EditIndex<MaxTracks-1 then
    begin
     Inc(EditIndex);
     SrcList.ItemIndex := EditIndex;
     SetItem(SrcList, EditIndex); GetAvailableTracksFocus;
     TrackEdit.SelectAll;
     TrackEdit.SetFocus;
    end else
{ When the end of the list is reached,
  focus the Ok button so that the next enter
  will close the dialog }
    begin
     OkBtn.SetFocus;
    end;
  end;
end;

{ Focus on the Artist field when the form is about to be shown for
  the first time }
procedure TDiscSettings.FormShow(Sender: TObject);
begin
 if ToFocusNow then
  begin
   EditArtists.SetFocus;
   ToFocusNow := False;
  end;
end;

procedure TDiscSettings.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if OkClicked and (DstList.Items.Count=0) then
  begin
   MessageDlg('Must have at least 1 song to play!', mtError,
              [mbOk], 0);
  end;
 try
  CanClose := (OkClicked and (DstList.Items.Count<>0)) or
              (not OkClicked);
 except
  CanClose := False;
 end;
end;



procedure TDiscSettings.PopupMenuSkipPopup(Sender: TObject);
begin
 { Determine who popped us up. DstList or SrcList }
end;

procedure TDiscSettings.Skip2Click(Sender: TObject);
begin
 { Pop us up owner determined. Now set the caller's attribute to skipped }
end;

end.
