program Cdplay;

uses
  Forms,
  Cdpref in 'CDPREF.PAS' {Preference},
  Cdset in 'CDSET.PAS' {DiscSettings},
  CdInt in 'CDINT.PAS' {CDPlayerForm},
  Cdplayhb in 'CDPLAYHB.PAS' {Win95HintBrushForm};
{$G CDInt, CDPlay, Forms, Classes, CDSet, IniFiles}
{$G MPlayer, Dialogs, Buttons, ExtCtrls, Menus, StdCtrls}
{$G Graphics, Controls, Printers, TypInfo, SysUtils, System}
{$R *.RES}

begin
  if HPrevInst=0 then
   begin
    Application.Title := 'CD Player';
    Application.CreateForm(TCDPlayerForm, CDPlayerForm);
    Application.Run;
   end;
end.
