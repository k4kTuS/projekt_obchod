unit sklad_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Math, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ValEdit, ComCtrls, Grids, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button3: TButton;
    Button7: TButton;
    Button8: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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
type
  trvale=record
    kod:integer;
    pokles:integer;
    dokup:integer;
    nazov:string;
  end;

var
  Form1: TForm1;
  sklad,cena,tovar,transakcia,statistiky:textfile;
  pole:array of hodnoty;
  prikazy:array of trvale;
  riadky,prikaz:integer;
  aktual:boolean;
implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.Kontrola;
var i,z,k:integer;c:char;cislo,price,namee:string;
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

    //kontrola prikazov
    if prikaz>0 then
    begin
      for z:=1 to prikaz do
      begin
        if (pole[i].kod = prikazy[z].kod) or (prikazy[z].kod = 0) then
        begin
          if pole[i].mnozstvo < prikazy[z].pokles then
          begin
            pole[i].mnozstvo:=pole[i].mnozstvo + prikazy[z].dokup;
            Memo2.Append('Trvaly: '+IntToStr(pole[i].kod)+'/'+pole[i].nazov+' '+IntToStr(prikazy[z].dokup)+'ks');

          end;
        end;
      end;
    end;
  end;

  //update suboru + tabulky po prikazoch
  ReWrite(sklad);
  WriteLn(sklad,riadky);
  for k:=0 to riadky-1 do
  begin
    WriteLn(sklad,pole[k].kod,';',pole[k].mnozstvo);
    StringGrid1.Cells[0,k+1]:=IntToStr(pole[k].kod);
    StringGrid1.Cells[2,k+1]:=IntToStr(pole[k].mnozstvo);
  end;
  CloseFile(sklad);


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
        Memo1.Append(IntToStr(pole[i].kod)+'/'+pole[i].nazov+' '+IntToStr(pole[i].mnozstvo)+'ks');
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
  aktual:=true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if aktual=true then
    Kontrola;
end;

procedure TForm1.Button3Click(Sender: TObject);
var z,cisla:boolean;i,k:integer;
begin
//MANUALNA OBJEDNAVKA
aktual:=false;
z:=false;
i:=0;
repeat
  cisla:=true;
  if (ID.Text = pole[i].nazov) then
  begin
    z:=true;
    if StrToInT(Pocet.Text)>0 then
    begin
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
      {AssignFile(transakcia,'N'+IntToStr(Random(8999999999)+1000000000)+'.txt');
      ReWrite(transakcia);
      WriteLn(transakcia,pole[i].kod,';',Pocet.Text+';'+FloatToStr(pole[i].cena));
      CloseFile(transakcia);}
    end
    else
      ShowMessage('Dokúpiť môžete len kladné množstvo tovaru');
  end
  else
  begin
    for k:=1 to length(ID.Text) do
    begin
      if (ID.Text[k] < '0') or (ID.Text[k] > '9') then
      begin
        cisla:=false;
      end;
    end;
    if cisla=true then
    begin
      if StrToInt(ID.Text)=pole[i].kod then
      begin
        z:=true;
        if StrToInT(Pocet.Text)>0 then
        begin
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

        end
        else
          ShowMessage('Dokúpiť môžete len kladné množstvo tovaru');
      end;
    end;
  end;
  inc(i);
until (z=true) or (i=riadky);
if z=false then
  ShowMessage('Vami zadany nazov alebo kod produktu nie je v databaze');

aktual:=true;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Kontrola;
end;

procedure TForm1.Button1Click(Sender: TObject);
var help,k:integer;cisla:boolean;
begin
cisla:=true;
  for k:=1 to length(Edit3.Text) do
  begin
    if (Edit3.Text[k] < '0') or (Edit3.Text[k] > '9') then
      begin
        cisla:=false;
      end;
  end;
  if cisla=true then
  begin
    aktual:=false;
    help:=StrToInt(Edit3.text);
    for k:=help to prikaz-1 do
    begin
      prikazy[k].kod:=prikazy[k+1].kod;
      prikazy[k].nazov:=prikazy[k+1].nazov;
      prikazy[k].pokles:=prikazy[k+1].pokles;
      prikazy[k].dokup:=prikazy[k+1].dokup;
    end;
    prikaz:=prikaz-1;
    SetLength(prikazy,prikaz+1);
    StringGrid3.RowCount:=StringGrid3.RowCount-1;
    aktual:=true;

    for k:=1 to prikaz do
    begin
      StringGrid3.Cells[0,k]:=IntToStr(k);
      StringGrid3.Cells[1,k]:=IntToStr(prikazy[k].kod);
      StringGrid3.Cells[2,k]:=prikazy[k].nazov;
      StringGrid3.Cells[3,k]:=IntToStr(prikazy[k].pokles);
      StringGrid3.Cells[4,k]:=IntToStr(prikazy[k].dokup);
    end;
  end
  else
    ShowMessage('Príkaz z daným číslom nie je aktuálny');
end;

procedure TForm1.Button7Click(Sender: TObject);
var z,cisla,opakovanie:boolean;i,k:integer;
begin
//TRVALY PRIKAZ
aktual:=false;
z:=false;
i:=0;
opakovanie:=false;

if CheckBox1.Checked=true then
begin
  if prikaz > 0 then
    begin
      for k:=1 to prikaz do
        if prikazy[k].nazov = 'Vsetko' then
          opakovanie:=true;
    end;

  if opakovanie = false then
  begin
    inc(prikaz);
  //tabulka
    StringGrid3.RowCount:=prikaz+1;
    StringGrid3.Cells[0,prikaz]:=IntToStr(prikaz);
    StringGrid3.Cells[2,prikaz]:='Vsetko';
    StringGrid3.Cells[3,prikaz]:=Pod.Text;
    StringGrid3.Cells[4,prikaz]:=pocet_2.Text;
  //pole
    SetLength(prikazy,prikaz+1);
    prikazy[prikaz].kod:=0;
    prikazy[prikaz].nazov:='Vsetko';
    prikazy[prikaz].pokles:=StrToInt(Pod.Text);
    prikazy[prikaz].dokup:=StrToInt(pocet_2.Text);
  end;
end
else begin
  repeat
    cisla:=true;

    if prikaz > 0 then
    begin
      for k:=1 to prikaz do
        if ID_2.Text = prikazy[k].nazov then
          opakovanie:=true;
    end;


    if (ID_2.Text = pole[i].nazov) and (opakovanie = false) then
    begin
      z:=true;
      inc(prikaz);
      //tabulka
       StringGrid3.RowCount:=prikaz+1;
       StringGrid3.Cells[0,prikaz]:=IntToStr(prikaz);
       StringGrid3.Cells[1,prikaz]:=IntToStr(pole[i].kod);
       StringGrid3.Cells[2,prikaz]:=pole[i].nazov;
       StringGrid3.Cells[3,prikaz]:=Pod.Text;
       StringGrid3.Cells[4,prikaz]:=pocet_2.Text;
     //pole
       SetLength(prikazy,prikaz+1);
       prikazy[prikaz].kod:=pole[i].kod;
       prikazy[prikaz].nazov:=pole[i].nazov;
       prikazy[prikaz].pokles:=StrToInt(Pod.Text);
       prikazy[prikaz].dokup:=StrToInt(pocet_2.Text);
    end
    else
    begin
      for k:=1 to length(ID_2.Text) do
      begin
        if (ID_2.Text[k] < '0') or (ID_2.Text[k] > '9') then
        begin
          cisla:=false;
        end;
      end;

      if cisla = true then
      begin
        if prikaz > 0 then
        begin
          for k:=1 to prikaz do
            if StrToInt(ID_2.Text) = prikazy[k].kod then
              opakovanie:=true;
        end;
      end;

      if (cisla = true) and (opakovanie = false) then
      begin
        if (StrToInt(ID_2.Text)=pole[i].kod) then
        begin
          z:=true;
          inc(prikaz);
          //tabulka
           StringGrid3.RowCount:=prikaz+1;
           StringGrid3.Cells[0,prikaz]:=IntToStr(prikaz);
           StringGrid3.Cells[1,prikaz]:=IntToStr(pole[i].kod);
           StringGrid3.Cells[2,prikaz]:=pole[i].nazov;
           StringGrid3.Cells[3,prikaz]:=Pod.Text;
           StringGrid3.Cells[4,prikaz]:=pocet_2.Text;
          //pole
            SetLength(prikazy,prikaz+1);
            prikazy[prikaz].kod:=pole[i].kod;
            prikazy[prikaz].nazov:=pole[i].nazov;
            prikazy[prikaz].pokles:=StrToInt(Pod.Text);
            prikazy[prikaz].dokup:=StrToInt(pocet_2.Text);
        end;
      end;
    end;
    inc(i);
  until (z=true) or (i=riadky-1);
end;

if (z=false) and (CheckBox1.Checked=false) and (opakovanie = false) then
  ShowMessage('Vami zadany nazov alebo kod produktu nie je v databaze');

if opakovanie = true then
  ShowMessage('Pre tento tovar už existuje vytvorený príkaz, ak chcete príkaz zmeniť, musíte aktuálny najprv odstrániť');

aktual:=true;
end;

procedure TForm1.Button8Click(Sender: TObject);
var i,k:integer;
begin
//SEMI-AUTO NAKUP
aktual:=false;
  for i:=0 to riadky-1 do
  begin
    if pole[i].mnozstvo<StrToInt(Edit1.Text) then
    begin
      Memo2.Append('Semi-auto: '+IntToStr(pole[i].kod)+'/'+pole[i].nazov+' '+Edit2.Text+'ks');
      pole[i].mnozstvo:=pole[i].mnozstvo+StrToInt(Edit2.Text);
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
  end;
aktual:=true;
end;

end.

