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
    CheckBox1: TCheckBox;
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
    procedure Kontrola;
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
  sklad,cena,tovar:textfile;
  pole:array of hodnoty;
  riadky,prikaz:integer;
implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.Kontrola;
var i,k:integer;c:char;cislo,price,namee:string;
begin
//READ SUBOROV, UPOZORNENIA MALO KS, CHECK TRVALE PRIKAZY
cislo:='';
price:='';
namee:='';

//SKLAD
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

//CENA
Reset(cena);
  ReadLn(cena);
  for i:=0 to riadky-1 do
  begin
    Read(cena,c);
    repeat
        cislo:=cislo+c;
      Read(cena,c);
    until c=';';

    Read(cena,c);
    repeat
      price:=price+c;
      Read(cena,c);
    until c=';';
    Readln(cena);

    for k:=0 to riadky-1 do
    begin
      if StrToInt(cislo) = pole[k].kod then
      begin
        pole[k].cena:=StrToFloat(price);
      end;
    end;
    cislo:='';
    price:='';
    StringGrid1.Cells[1,i+1]:=FloatToStr(pole[i].cena);
  end;

//NAZOV
Reset(tovar);
  ReadLn(tovar);
  for i:=0 to riadky-1 do
  begin
    Read(tovar,c);
    repeat
        cislo:=cislo+c;
      Read(tovar,c);
    until c=';';
    ReadLn(tovar,namee);

    for k:=0 to riadky-1 do
    begin
      if StrToInt(cislo) = pole[k].kod then
      begin
        pole[k].nazov:=namee;
      end;
    end;
    cislo:='';
    namee:='';
    StringGrid1.Cells[1,i+1]:=pole[i].nazov;
  end;

  //nahodenie upozorneni
  Memo1.Clear;
  for i:=0 to riadky-1 do
  begin
    if pole[i].mnozstvo<50 then
      begin
        Memo1.Append(IntToStr(pole[i].kod)+' '+pole[i].nazov+' '+IntToStr(pole[i].mnozstvo)+'ks');
      end;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Clear;
  Memo2.Clear;
  AssignFile(sklad,'SKLAD.txt');
  AssignFile(tovar,'TOVAR.txt');
  AssignFile(cena,'CENNIK.txt');
  prikaz:=0;
  //citanie SKLAD,CENA,TOVAR
  Kontrola;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin

end;

procedure TForm1.Button3Click(Sender: TObject);
var z:boolean;i,k:integer;
begin
//MANUALNA OBJEDNAVKA
z:=false;
i:=0;
repeat
  if StrToInt(ID.Text)=pole[i].kod {or (ID.Text = pole[i].nazov)}  then
  begin
    z:=true;
    Memo2.Append('Manual: '+IntToStr(pole[i].kod)+'/'+pole[i].nazov+' '+Pocet.Text+'ks');
    pole[i].mnozstvo:=pole[i].mnozstvo+StrToInt(Pocet.Text);
    ReWrite(sklad);
    WriteLn(sklad,riadky);
    for k:=0 to riadky-1 do
    begin
    WriteLn(sklad,pole[k].kod,';',pole[k].mnozstvo);
    end;
    CloseFile(sklad);
    //aktualizacia tabulky
    Kontrola;
    //tu dojde generovanie transakcie
  end;
  inc(i);
until (z=true) or (i=riadky-1);
if z=false then
  ShowMessage('Vami zadany nazov alebo kod produktu nie je v databaze');
end;

procedure TForm1.Button7Click(Sender: TObject);
var z:boolean;i,k:integer;
begin
//TRVALY PRIKAZ
z:=false;
i:=0;

if CheckBox1.Checked=true then
begin
  inc(prikaz);
    StringGrid3.Cells[0,prikaz]:='Vsetko';
    StringGrid3.Cells[1,prikaz]:=Pod.Text;
    StringGrid3.Cells[2,prikaz]:=pocet_2.Text;
end
else begin
  repeat
    if (StrToInt(ID_2.Text)=pole[i].kod) then
    begin
      z:=true;
      inc(prikaz);
       StringGrid3.Cells[0,prikaz]:=ID_2.Text;
       StringGrid3.Cells[1,prikaz]:=Pod.Text;
        StringGrid3.Cells[2,prikaz]:=pocet_2.Text;
    end;
    inc(i);
  until (z=true) or (i=riadky-1);
end;

if (z=false) and (CheckBox1.Checked=false) then
  ShowMessage('Vami zadany nazov alebo kod produktu nie je v databaze');

end;

procedure TForm1.Button8Click(Sender: TObject);
var i,k:integer;
begin
//SEMI-AUTO NAKUP
  for i:=0 to riadky-1 do
  begin
    if pole[i].mnozstvo<StrToInt(Edit1.Text) then
    begin
      pole[i].mnozstvo:=pole[i].mnozstvo+StrToInt(Edit2.Text);
      ReWrite(sklad);
      WriteLn(sklad,riadky);
      for k:=0 to riadky do
      begin
        WriteLn(sklad,pole[k].kod,';',pole[k].mnozstvo);
      end;
      CloseFile(sklad);
      //aktualizacia tabulky
      Kontrola;
      //tu dojde generovanie transakcie
    end;
  end;

end;

end.

