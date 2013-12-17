{*******************************************************}
{                                                       }
{       Delphi CD Player unit INI file data             }
{                                                       }
{       Copyright (c) 1995 Chua Chee Wee                }
{                                                       }
{*******************************************************}
{ Thursday 04 May 1995, 10:05pm                         }
{ Created                                               }
unit Cdpref;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Buttons, Spin, CDIni;

type
  TPreference = class(TForm)
    OkBtn: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    CheckStopOnExit: TCheckBox;
    CheckSaveOnExit: TCheckBox;
    IntroLengthEdit: TSpinEdit;
    Label1: TLabel;
    SpinEditFrameLength: TSpinEdit;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  end;

var
  Preference: TPreference;

implementation

{$R *.DFM}

procedure TPreference.FormCreate(Sender: TObject);
begin
 CheckStopOnExit.Checked := StopOnExit;
 CheckSaveOnExit.Checked := SaveOnExit;
 IntroLengthEdit.MinValue := 5;
 IntroLengthEdit.MaxValue := 60;
 IntroLengthEdit.Value := IntroLength;
 SpinEditFrameLength.Value := FrameLength;
end;

procedure TPreference.OkBtnClick(Sender: TObject);
begin
 FrameLength := SpinEditFrameLength.Value;
 IntroLength := IntroLengthEdit.Value;
 StopOnExit := CheckStopOnExit.Checked;
 SaveOnExit := CheckSaveOnExit.Checked;
 Release;
end;

end.
