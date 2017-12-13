unit sklad_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ValEdit, ComCtrls, Grids, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button3: TButton;
    Button7: TButton;
    Button8: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo2: TMemo;
    Pod: TEdit;
    pocet_2: TEdit;
    ID_2: TEdit;
    Pocet: TEdit;
    ID: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    StringGrid1: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Timer1: TTimer;
    procedure Button3Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Clear;
  Memo2.Clear;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Memo1.Append('ID: '+IntToStr(Random(600)+100)+' ks: '+IntToStr(Random(40)));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
Memo2.Append('Manual: ID: '+ID.Text+' ks: '+Pocet.Text);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
Memo2.Append('AutoADD: ID: '+ID_2.Text+' ks: '+pocet_2.Text+' pod: '+Pod.Text);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  Memo2.Append('Fast: ');
  Memo2.Append('ID: 157 ks: '+Edit2.Text);
  Memo2.Append('ID: 525 ks: '+Edit2.Text);
  Memo2.Append('ID: 471 ks: '+Edit2.Text);

end;

end.

