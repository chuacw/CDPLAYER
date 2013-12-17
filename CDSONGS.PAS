unit Cdsongs;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ExtCtrl2;

type
  TSongsList = class(TForm)
    Panel1: TPanel;
    ListBox1: TListBox;
    Panel2: TPanel;
    Panel3: TPanel;
    RadioGroup1: TRadioGroup;
    ListBox2: TListBox;
    Panel4: TPanel;
    ListBox3: TListBox;
    Panel5: TPanel;
    ListBox4: TListBox;
    Panel6: TPanel;
    ButtonsGroup1: TButtonsGroup;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SongsList: TSongsList;

implementation

{$R *.DFM}

end.
