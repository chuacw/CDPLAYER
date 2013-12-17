unit Cdplayer;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, Buttons, ExtCtrls;

type
  TToolbarPanel = class(TForm)
    MainMenu1: TMainMenu;
    Disc1: TMenuItem;
    Options1: TMenuItem;
    Help1: TMenuItem;
    EditPlayList1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    View1: TMenuItem;
    Toolbar1: TMenuItem;
    DiscTrackinfo1: TMenuItem;
    Statusinfo1: TMenuItem;
    N2: TMenuItem;
    Tracktimeelapsed1: TMenuItem;
    TrackTimeremaining1: TMenuItem;
    Disctimeremaining1: TMenuItem;
    N3: TMenuItem;
    Volumecontrol1: TMenuItem;
    Randomorder1: TMenuItem;
    Continuousplay1: TMenuItem;
    Introplay1: TMenuItem;
    N4: TMenuItem;
    Preferences1: TMenuItem;
    Helptopics1: TMenuItem;
    AboutCDPlayer1: TMenuItem;
    N5: TMenuItem;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    procedure Randomorder1Click(Sender: TObject);
    procedure Toolbar1Click(Sender: TObject);
    procedure DiscTrackinfo1Click(Sender: TObject);
    procedure Statusinfo1Click(Sender: TObject);
    procedure Tracktimeelapsed1Click(Sender: TObject);
    procedure TrackTimeremaining1Click(Sender: TObject);
    procedure Disctimeremaining1Click(Sender: TObject);
    procedure Continuousplay1Click(Sender: TObject);
    procedure Introplay1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure AboutCDPlayer1Click(Sender: TObject);
  private
    procedure CheckThisMenuItem(Sender: TMenuItem);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ToolbarPanel: TToolbarPanel;

implementation
uses Shell;
{$R *.DFM}

procedure TToolbarPanel.CheckThisMenuItem(Sender: TMenuItem);
var
 Count: Word;
begin
  for Count := 0 to Sender.Parent.Count-1 do
   with Sender.Parent.Items[Count] as TMenuItem do
    if GroupIndex = Sender.GroupIndex then
     Checked := False;
 Sender.Checked := True;
end;

procedure TToolbarPanel.Randomorder1Click(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TToolbarPanel.Toolbar1Click(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TToolbarPanel.DiscTrackinfo1Click(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TToolbarPanel.Statusinfo1Click(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TToolbarPanel.Tracktimeelapsed1Click(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TToolbarPanel.TrackTimeremaining1Click(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TToolbarPanel.Disctimeremaining1Click(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TToolbarPanel.Continuousplay1Click(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TToolbarPanel.Introplay1Click(Sender: TObject);
begin
 CheckThisMenuItem(Sender as TMenuItem);
end;

procedure TToolbarPanel.Exit1Click(Sender: TObject);
begin
 Close;
end;

procedure TToolbarPanel.SpeedButton1Click(Sender: TObject);
begin
 Close;
end;

procedure TToolbarPanel.AboutCDPlayer1Click(Sender: TObject);
begin
 ShellAbout(Handle, 'About CD Player#CD Player', 'Written by Chua Chee Wee in Borland Delphi', Icon.Handle);
end;

end.
