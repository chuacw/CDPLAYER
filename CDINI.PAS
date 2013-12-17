{*******************************************************}
{                                                       }
{       Delphi CD Player unit INI file data             }
{                                                       }
{       Copyright (c) 1995 Chua Chee Wee                }
{                                                       }
{*******************************************************}
{ Monday 01 May 1995, 3:25pm                            }
{ Created                                               }
unit Cdini;

interface
uses WinTypes, IniFiles, Classes;

type

    TSongTrack = class
     TrackNo: Word;
     Skipped, Favourite: Bool;
     Instruments: Longint;
     public
     constructor Create(const ATrackNo: Word);
    end;

var
 CDPlayerIniFile: TIniFile;

{
Uses the Microsoft CD Player INI file format

These information are saved to an INI file as CDINI.INI

Each CD is stored in a section.
The section name for each CD is unique.
The section name is the string value of the playing length of the entire
CD.

AvailableTracks are written/read as
01=...
02=...
nn=...
for as many times as there are tracks on a disc

PlayList is written/read as
order=3 2 1 4 6 ... n
where 3 2 1 4 6 represents the songs to play in Available Tracks
The number of songs to play is listed as
numplay=nn in the INI file.

The artist name is stored as Artist and
the cd title is stored as CDTitle


Stored under Preferences section
IntroLength=nn where nn is the number of seconds to play for each track
               before seeking to next one
SaveOnExit=bb where bb is a boolean representing whether to save the
              menu checks on exiting the program.
StopOnExit=bb where bb is a boolean representing whether to stop the
              CD player on exiting the program.
Frame=nn where nn is the number of seconds to step/backstep
Repeat=True/False to repeat track
Continuous=True/False to continuously play the songs listed playlist in
           a circle
}
 AvailableTracks, PlayList: TStringList;
 sArtistName: string;
 sCDTitle: string;
 PlayListIndex: Integer;
 FrameLength, IntroLength: Word;
 SaveOnExit, StopOnExit: Boolean;

{ Global values, not INI values }
MaxTracks: Word;

implementation


constructor TSongTrack.Create(const ATrackNo: Word);
begin
 inherited Create;
 TrackNo := ATrackNo;
end;

end.
