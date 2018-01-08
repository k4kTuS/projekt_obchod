unit sklad_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Math, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ValEdit, ComCtrls, Grids, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button3: TButton;
    Button7: TButton;
    Button8: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
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
    StringGrid3: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
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
type
  hodnoty=record
    kod:integer;
    nazov:string;
    mnozstvo:integer;
    cena:float;
  end;
var
  Form1: TForm1;
  sklad:textfile;
  pole:array of hodnoty;
  riadky,prikaz:integer;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;c:char;cislo:string;
begin
  Memo1.Clear;
  Memo2.Clear;
  AssignFile(sklad,'SKLAD.txt');
  cislo:='';
  prikaz:=0;
  //citanie SKLAD.txt
  Reset(sklad);
  ReadLn(sklad,riadky);
  SetLength(pole,riadky);
  StringGrid1.RowCount:=riadky+1;
  StringGrid1.ColCount:=3;
  for i:=0 to riadky-1 do
  begin
    Read(sklad,c);
    repeat
        cislo:=cislo+c;
      Read(sklad,c);
    until c=';';
    pole[i].kod:=StrToInt(cislo);
    cislo:='';
    ReadLn(sklad,pole[i].mnozstvo);
    StringGrid1.Cells[0,i+1]:=IntToStr(pole[i].kod);
    StringGrid1.Cells[2,i+1]:=IntToStr(pole[i].mnozstvo);
  end;

  //nahodenie upozorneni
  for i:=0 to riadky do
  begin
    if pole[i].mnozstvo<50 then
      begin
        Memo1.Append(IntToStr(pole[i].kod)+' '+'nazov'+' '+IntToStr(pole[i].mnozstvo)+'ks');
      end;
    {if pole[i].mnozstvo<20 then
      begin
        Memo1.Append(IntToStr(pole[i].kod)+' '+'nazov'+' '+IntToStr(pole[i].mnozstvo)+'ks');
      end;}
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin

end;

procedure TForm1.Button3Click(Sender: TObject);
var z:boolean;i,k:integer;
begin
z:=false;
i:=0;
repeat
  if StrToInt(ID.Text)=pole[i].kod then
  begin
    z:=true;
    Memo2.Append('Manual: '+IntToStr(pole[i].kod)+'/'+'Nazov'+' '+Pocet.Text+'ks');
    pole[i].mnozstvo:=pole[i].mnozstvo+StrToInt(Pocet.Text);
    ReWrite(sklad);
    WriteLn(sklad,riadky);
    for k:=0 to riadky-1 do
    begin
    WriteLn(sklad,pole[k].kod,';',pole[k].mnozstvo);
    end;
    CloseFile(sklad);
    //tu dojde generovanie transakcie
  end;
  inc(i);
until (z=true) or (i=riadky-1);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
inc(prikaz);
StringGrid3.Cells[0,prikaz]:=ID_2.Text;
StringGrid3.Cells[1,prikaz]:=Pod.Text;
StringGrid3.Cells[2,prikaz]:=pocet_2.Text;

end;

procedure TForm1.Button8Click(Sender: TObject);
var i,k:integer;
begin
  for i:=0 to riadky do
  begin
    if pole[i].mnozstvo<StrToInt(Edit1.Text) then
    begin
      pole[i].mnozstvo:=pole[i].mnozstvo+StrToInt(Edit1.Text);
      ReWrite(sklad);
      WriteLn(sklad,riadky);
      for k:=0 to riadky do
      begin
        WriteLn(sklad,pole[k].kod,';',pole[k].mnozstvo);
      end;
      CloseFile(sklad);
      //tu dojde generovanie transakcie
    end;
  end;

end;

end.

