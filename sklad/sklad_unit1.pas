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
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
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
type
  statistiky=record
    typ:char;
    id_t:integer;
    kod:integer;
    mnozstvo:integer;
    cena:float;
  end;
const
  path='';  //\\comenius\public\market\timb\
var
  Form1: TForm1;
  sklad,cena,tovar,transakcia:textfile;
  pole:array of hodnoty;
  prikazy:array of trvale;
  stat:array of statistiky;
  riadky,prikaz,obchody:integer;
  aktual:boolean;
  editcennik,edittovar:LongInt;
implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.Kontrola;
var i,z,k,F1,F2,F3,F4,help,test:integer;lock:boolean;c:char;cislo,price,ks:string;
begin
//READ SUBOROV, UPOZORNENIA MALO KS, CHECK TRVALE PRIKAZY
cislo:='';
price:='';
ks:='';
test:=0;

if (FileExists(path+'SKLAD.txt')=true) and (FileExists(path+'CENNIK.txt')=true) and (FileExists(path+'TOVAR.txt')=true) then
begin
if not (FileExists(path+'SKLAD_LOCK.txt')=true) or (FileExists(path+'CENNIK_LOCK.txt')=true) or (FileExists(path+'TOVAR_LOCK.txt')=true) then
begin
//LOCKOVANIE
F1:=FileCreate(path+'SKLAD_LOCK.txt');

{if (FileAge(path+'CENNIK.txt')<>editcennik) or (FileAge(path+'TOVAR.txt')<>edittovar) then
begin
editcennik:=FileAge(path+'CENNIK.txt');
edittovar:=FileAge(path+'TOVAR.txt');}

F2:=FileCreate(path+'CENNIK_LOCK.txt');
F3:=FileCreate(path+'TOVAR_LOCK.txt');

//NAZOV
Reset(tovar);
  ReadLn(tovar,riadky);
  SetLength(pole,riadky);

  //cistenie pola nech mam nove hodnoty len
  for k:=0 to riadky-1 do
  begin
    pole[k].kod:=0;
    pole[k].cena:=0;
    pole[k].nazov:='';
    pole[k].mnozstvo:=0;
  end;
  //StringGrid1.RowCount:=riadky+1;
  //StringGrid1.ColCount:=3;
  for i:=0 to riadky-1 do
  begin
    Read(tovar,c);
    repeat
        cislo:=cislo+c;
      Read(tovar,c);
    until c=';';
    pole[i].kod:=StrToInt(cislo);
    ReadLn(tovar,pole[i].nazov);
    cislo:='';
  end;
  CloseFile(tovar);

//CENA
Reset(cena);
  ReadLn(cena,help);
  for i:=0 to help-1 do
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
    //StringGrid1.Cells[1,i+1]:=FloatToStr(pole[i].cena);
  end;
  CloseFile(cena);

FileClose(F2);
FileClose(F3);
DeleteFile(path+'CENNIK_LOCK.txt');
DeleteFile(path+'TOVAR_LOCK.txt');
{end;}

  //SKLAD
  Reset(sklad);
    ReadLn(sklad,help);
    for i:=0 to help-1 do
    begin
      Read(sklad,c);
      repeat
          cislo:=cislo+c;
        Read(sklad,c);
      until c=';';
      ReadLn(sklad,ks);

      for k:=0 to riadky-1 do
      begin
        if StrToInt(cislo) = pole[k].kod then
        begin
          pole[k].mnozstvo:=StrToInt(ks);
        end;
      end;
      cislo:='';
      ks:='';
    end;
    CloseFile(sklad);

    //Shity ked nema vsetko cenu
      help:=riadky;
      test:=0;
      for k:=0 to help-1 do
      begin
        //vymazanie veci z pola ked nemaju este nahodenu cenu
        if pole[k].cena=0 {(FloatToStr(pole[k].cena)='') and (pole[k].mnozstvo=0) or (FloatToStr(pole[k].cena)='') and (IntToStr(pole[k].mnozstvo)='')} then
        begin
          for z:=k to riadky-2 do
          begin
            pole[z].kod:=pole[z+1].kod;
            pole[z].nazov:=pole[z+1].nazov;
            pole[z].cena:=pole[z+1].cena;
            pole[z].mnozstvo:=pole[z+1].mnozstvo;
          end;
          inc(test);
        end;
      end;
      riadky:=riadky-test;
      SetLength(pole,riadky);
      StringGrid1.RowCount:=riadky+1;
      //Memo2.Append(IntToStr(test)+' '+IntToStr(riadky));

    //kontrola prikazov
    for i:=0 to riadky-1 do
    begin
      if prikaz>0 then
      begin
        for z:=1 to prikaz do
        begin
          if (pole[i].kod = prikazy[z].kod) or (prikazy[z].kod = 0) then
          begin
            if pole[i].mnozstvo < prikazy[z].pokles then
            begin
              pole[i].mnozstvo:=pole[i].mnozstvo + prikazy[z].dokup;
              Memo2.Append('Trvaly: '+'['+IntToStr(pole[i].kod)+']'+pole[i].nazov+' '+IntToStr(prikazy[z].dokup)+'ks     '+DateToStr(Date)+' '+TimeToStr(Time));
              //tu dojde generovanie transakcie
              lock:=true;
              //lock
              repeat
                if not FileExists(path+'STATISTIKY_LOCK.txt')=true then
                  lock:=false;
              until lock=false;
              F4:=FileCreate(path+'STATISTIKY_LOCK.txt');
              lock:=true;
              //lock

              Reset(transakcia);
              ReadLn(transakcia,obchody);
              SetLength(stat,obchody+1);
              for k:=1 to obchody do
              begin
                //typ
                Read(transakcia,stat[k].typ);
                Read(transakcia,c);
                Read(transakcia,c);
                cislo:='';
                //id transakcie
                repeat
                  cislo:=cislo+c;
                  Read(transakcia,c);
                until c=';';
                stat[k].id_t:=StrToInt(cislo);
                cislo:='';
                Read(transakcia,c);
                //id tovaru
                repeat
                  cislo:=cislo+c;
                  Read(transakcia,c);
                until c=';';
                stat[k].kod:=StrToInt(cislo);
                cislo:='';
                Read(transakcia,c);
                //mnozstvo
                repeat
                  cislo:=cislo+c;
                  Read(transakcia,c);
                until c=';';
                stat[k].mnozstvo:=StrToInt(cislo);
                cislo:='';
                //cena kus
                ReadLn(transakcia,cislo);
                stat[k].cena:=StrToFloat(cislo);
                cislo:='';
              end;
              //pridanie novej transakcie a zapisanie do suboru
              inc(obchody);
              SetLength(stat,obchody+1);
              stat[obchody].typ:='N';
              stat[obchody].id_t:=Random(89999999)+10000000;
              stat[obchody].kod:=pole[i].kod;
              stat[obchody].mnozstvo:=prikazy[z].dokup;
              stat[obchody].cena:=pole[i].cena;
              //Zapis do statistik
              if obchody>0 then
              begin
                ReWrite(transakcia);
                WriteLn(transakcia,obchody);
                for k:=1 to obchody do
                begin
                  WriteLn(transakcia,stat[k].typ,';',stat[k].id_t,';',stat[k].kod,';',stat[k].mnozstvo,';',FloatToStr(stat[k].cena));
                end;
                CloseFile(transakcia);
              end;
              FileClose(F4);
              DeleteFile(path+'STATISTIKY_LOCK.txt');
              //koniec transakcie
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
      StringGrid1.Cells[1,k+1]:=pole[k].nazov;
      StringGrid1.Cells[2,k+1]:=IntToStr(pole[k].mnozstvo);
    end;
    CloseFile(sklad);


  //DELETE LOCKU
  FileClose(F1);
  DeleteFile(path+'SKLAD_LOCK.txt');


  //nahodenie upozorneni
  Memo1.Clear;
  for i:=0 to riadky-1 do
  begin
    if pole[i].mnozstvo<50 then
      begin
        Memo1.Append('['+IntToStr(pole[i].kod)+']'+pole[i].nazov+' '+IntToStr(pole[i].mnozstvo)+'ks');
      end;
  end;

end;
end
else
  ShowMessage('Program nemôže správne pracovať, jeden z potrebných súborov chýba alebo je v nesprávnom formáte');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Clear;
  Memo2.Clear;
  AssignFile(sklad,path+'SKLAD.txt');
  AssignFile(tovar,path+'TOVAR.txt');
  AssignFile(cena,path+'CENNIK.txt');
  AssignFile(transakcia,path+'STATISTIKY.txt');
  prikaz:=0;
  //citanie SKLAD,CENA,TOVAR
  editcennik:=FileAge(path+'CENNIK.txt');
  edittovar:=FileAge(path+'TOVAR.txt');
  Kontrola;
  aktual:=true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if aktual=true then
    Kontrola;
end;

procedure TForm1.Button3Click(Sender: TObject);
var z,cisla,lock:boolean;i,k,F4:integer;c:char;cislo:string;
begin
//MANUALNA OBJEDNAVKA
aktual:=false;
Kontrola;
z:=false;
i:=0;
cisla:=true;
lock:=true;

if (ID.Text='') or (Pocet.Text='') then
  cisla:=false;

if cisla=true then
begin

repeat

  if (ID.Text = pole[i].nazov) then
  begin
    z:=true;

    if StrToInT(Pocet.Text)>0 then
    begin
      Memo2.Append('Manual: '+'['+IntToStr(pole[i].kod)+']'+pole[i].nazov+' '+Pocet.Text+'ks     '+DateToStr(Date)+' '+TimeToStr(Time));
      pole[i].mnozstvo:=pole[i].mnozstvo+StrToInt(Pocet.Text);

      //lock
      repeat
        if not FileExists(path+'SKLAD_LOCK.txt')=true then
          lock:=false;
      until lock=false;
      F4:=FileCreate(path+'SKLAD_LOCK.txt');
      lock:=true;
      //lock

      ReWrite(sklad);
      WriteLn(sklad,riadky);
      for k:=0 to riadky-1 do
      begin
        WriteLn(sklad,pole[k].kod,';',pole[k].mnozstvo);
      end;
      CloseFile(sklad);
      //unlock
      FileClose(F4);
      DeleteFile(path+'SKLAD_LOCK.txt');

      //aktualizacia tabulky
      Kontrola;
      //tu dojde generovanie transakcie

      //lock
      repeat
        if not FileExists(path+'STATISTIKY_LOCK.txt')=true then
          lock:=false;
      until lock=false;
      F4:=FileCreate(path+'STATISTIKY_LOCK.txt');
      lock:=true;
      //lock

      Reset(transakcia);
      ReadLn(transakcia,obchody);
      SetLength(stat,obchody+1);
      for k:=1 to obchody do
      begin
        //typ
        Read(transakcia,stat[k].typ);
        Read(transakcia,c);
        Read(transakcia,c);
        cislo:='';
        //id transakcie
        repeat
          cislo:=cislo+c;
          Read(transakcia,c);
        until c=';';
        stat[k].id_t:=StrToInt(cislo);
        cislo:='';
        Read(transakcia,c);
        //id tovaru
        repeat
          cislo:=cislo+c;
          Read(transakcia,c);
        until c=';';
        stat[k].kod:=StrToInt(cislo);
        cislo:='';
        Read(transakcia,c);
        //mnozstvo
        repeat
          cislo:=cislo+c;
          Read(transakcia,c);
        until c=';';
        stat[k].mnozstvo:=StrToInt(cislo);
        cislo:='';
        //cena kus
        ReadLn(transakcia,cislo);
        stat[k].cena:=StrToFloat(cislo);
        cislo:='';
      end;
      //pridanie novej transakcie a zapisanie do suboru
      inc(obchody);
      SetLength(stat,obchody+1);
      stat[obchody].typ:='N';
      stat[obchody].id_t:=Random(89999999)+10000000;
      stat[obchody].kod:=pole[i].kod;
      stat[obchody].mnozstvo:=StrToInt(Pocet.Text);
      stat[obchody].cena:=pole[i].cena;
      //Zapis do statistik
      if obchody>0 then
      begin
        ReWrite(transakcia);
        WriteLn(transakcia,obchody);
        for k:=1 to obchody do
        begin
          WriteLn(transakcia,stat[k].typ,';',stat[k].id_t,';',stat[k].kod,';',stat[k].mnozstvo,';',FloatToStr(stat[k].cena));
        end;
        CloseFile(transakcia);
      end;
      FileClose(F4);
      DeleteFile(path+'STATISTIKY_LOCK.txt');
      //koniec transakcie
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
          Memo2.Append('Manual: '+'['+IntToStr(pole[i].kod)+']'+pole[i].nazov+' '+Pocet.Text+'ks     '+DateToStr(Date)+' '+TimeToStr(Time));
          pole[i].mnozstvo:=pole[i].mnozstvo+StrToInt(Pocet.Text);

          //lock
          repeat
            if not FileExists(path+'SKLAD_LOCK.txt')=true then
              lock:=false;
          until lock=false;
          F4:=FileCreate(path+'SKLAD_LOCK.txt');
          lock:=true;
          //lock

          ReWrite(sklad);
          WriteLn(sklad,riadky);
          for k:=0 to riadky-1 do
          begin
            WriteLn(sklad,pole[k].kod,';',pole[k].mnozstvo);
          end;
          CloseFile(sklad);
          //unlock
          FileClose(F4);
          DeleteFile(path+'SKLAD_LOCK.txt');

          //aktualizacia tabulky
          Kontrola;
          //tu dojde generovanie transakcie

          //lock
          repeat
            if not FileExists(path+'STATISTIKY_LOCK.txt')=true then
              lock:=false;
          until lock=false;
          F4:=FileCreate(path+'STATISTIKY_LOCK.txt');
          lock:=true;
          //lock

          Reset(transakcia);
          ReadLn(transakcia,obchody);
          SetLength(stat,obchody+1);
          for k:=1 to obchody do
          begin
            //typ
            Read(transakcia,stat[k].typ);
            Read(transakcia,c);
            Read(transakcia,c);
            cislo:='';
            //id transakcie
            repeat
              cislo:=cislo+c;
              Read(transakcia,c);
            until c=';';
            stat[k].id_t:=StrToInt(cislo);
            cislo:='';
            Read(transakcia,c);
            //id tovaru
            repeat
              cislo:=cislo+c;
              Read(transakcia,c);
            until c=';';
            stat[k].kod:=StrToInt(cislo);
            cislo:='';
            Read(transakcia,c);
            //mnozstvo
            repeat
              cislo:=cislo+c;
              Read(transakcia,c);
            until c=';';
            stat[k].mnozstvo:=StrToInt(cislo);
            cislo:='';
            //cena kus
            ReadLn(transakcia,cislo);
            stat[k].cena:=StrToFloat(cislo);
            cislo:='';
          end;
          //pridanie novej transakcie a zapisanie do suboru
          inc(obchody);
          SetLength(stat,obchody+1);
          stat[obchody].typ:='N';
          stat[obchody].id_t:=Random(89999999)+10000000;
          stat[obchody].kod:=pole[i].kod;
          stat[obchody].mnozstvo:=StrToInt(Pocet.Text);
          stat[obchody].cena:=pole[i].cena;
          //Zapis do statistik
          if obchody>0 then
          begin
            ReWrite(transakcia);
            WriteLn(transakcia,obchody);
            for k:=1 to obchody do
            begin
              WriteLn(transakcia,stat[k].typ,';',stat[k].id_t,';',stat[k].kod,';',stat[k].mnozstvo,';',FloatToStr(stat[k].cena));
            end;
            CloseFile(transakcia);
          end;
          FileClose(F4);
          DeleteFile(path+'STATISTIKY_LOCK.txt');
          //koniec transakcie
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
end
else
  ShowMessage('Treba vyplniť všetky polia');

aktual:=true;
end;

procedure TForm1.Button1Click(Sender: TObject);
var help,k:integer;cisla:boolean;
begin
cisla:=true;
  if Edit3.Text='' then
  begin
    cisla:=false;
  end;

  if (cisla=true) and (prikaz>0) and (StrToInt(Edit3.Text) <= prikaz) then
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
    ShowMessage('Príkaz s daným číslom nie je aktuálny');
end;

procedure TForm1.Button7Click(Sender: TObject);
var z,cisla,opakovanie:boolean;i,k:integer;
begin
//TRVALY PRIKAZ
aktual:=false;
Kontrola;
z:=false;
i:=0;
opakovanie:=false;
cisla:=true;

if (((ID_2.Text='') or (pocet_2.Text='') or (Pod.Text='')) and (CheckBox1.Checked=false)) or (((pocet_2.Text='') or (Pod.Text='')) and (CheckBox1.Checked=true)) then
    cisla:=false;

if cisla=true then
begin

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
    //cisla:=true;

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
  until (z=true) or (i=riadky);
end;

if (z=false) and (CheckBox1.Checked=false) and (opakovanie = false) then
  ShowMessage('Vami zadany nazov alebo kod produktu nie je v databaze');

if opakovanie = true then
  ShowMessage('Pre tento tovar už existuje vytvorený príkaz, ak chcete príkaz zmeniť, musíte aktuálny najprv odstrániť');
end
else
  ShowMessage('Treba vyplniť všetky potrebné polia');
aktual:=true;
end;

procedure TForm1.Button8Click(Sender: TObject);
var i,k,F4:integer;cisla,lock:boolean;c:char;cislo:string;
begin
//SEMI-AUTO NAKUP
aktual:=false;
Kontrola;
cisla:=true;
lock:=true;



if (Edit1.Text='') or (Edit2.Text='') then
  cisla:=false;

if cisla=true then
begin
  for i:=0 to riadky-1 do
  begin
    if pole[i].mnozstvo<StrToInt(Edit1.Text) then
    begin
      Memo2.Append('Semi-auto: '+'['+IntToStr(pole[i].kod)+']'+pole[i].nazov+' '+Edit2.Text+'ks     '+DateToStr(Date)+' '+TimeToStr(Time));
      pole[i].mnozstvo:=pole[i].mnozstvo+StrToInt(Edit2.Text);

      //lock
      repeat
        if not FileExists(path+'SKLAD_LOCK.txt')=true then
          lock:=false;
      until lock=false;
      F4:=FileCreate(path+'SKLAD_LOCK.txt');
      lock:=true;
      //lock

      ReWrite(sklad);
      WriteLn(sklad,riadky);
      for k:=0 to riadky-1 do
      begin
        WriteLn(sklad,pole[k].kod,';',pole[k].mnozstvo);
      end;
      CloseFile(sklad);
      //unlock
      FileClose(F4);
      DeleteFile(path+'SKLAD_LOCK.txt');

      //aktualizacia tabulky
      Kontrola;
      //tu dojde generovanie transakcie

      //lock
      repeat
        if not FileExists(path+'STATISTIKY_LOCK.txt')=true then
          lock:=false;
      until lock=false;
      F4:=FileCreate(path+'STATISTIKY_LOCK.txt');
      lock:=true;
      //lock

      Reset(transakcia);
      ReadLn(transakcia,obchody);
      SetLength(stat,obchody+1);
      for k:=1 to obchody do
      begin
        //typ
        Read(transakcia,stat[k].typ);
        Read(transakcia,c);
        Read(transakcia,c);
        cislo:='';
        //id transakcie
        repeat
          cislo:=cislo+c;
          Read(transakcia,c);
        until c=';';
        stat[k].id_t:=StrToInt(cislo);
        cislo:='';
        Read(transakcia,c);
        //id tovaru
        repeat
          cislo:=cislo+c;
          Read(transakcia,c);
        until c=';';
        stat[k].kod:=StrToInt(cislo);
        cislo:='';
        Read(transakcia,c);
        //mnozstvo
        repeat
          cislo:=cislo+c;
          Read(transakcia,c);
        until c=';';
        stat[k].mnozstvo:=StrToInt(cislo);
        cislo:='';
        //cena kus
        ReadLn(transakcia,cislo);
        stat[k].cena:=StrToFloat(cislo);
        cislo:='';
      end;
      //pridanie novej transakcie a zapisanie do suboru
      inc(obchody);
      SetLength(stat,obchody+1);
      stat[obchody].typ:='N';
      stat[obchody].id_t:=Random(89999999)+10000000;
      stat[obchody].kod:=pole[i].kod;
      stat[obchody].mnozstvo:=StrToInt(Edit2.Text);
      stat[obchody].cena:=pole[i].cena;
      //Zapis do statistik
      if obchody>0 then
      begin
        ReWrite(transakcia);
        WriteLn(transakcia,obchody);
        for k:=1 to obchody do
        begin
          WriteLn(transakcia,stat[k].typ,';',stat[k].id_t,';',stat[k].kod,';',stat[k].mnozstvo,';',FloatToStr(stat[k].cena));
        end;
        CloseFile(transakcia);
      end;
      FileClose(F4);
      DeleteFile(path+'STATISTIKY_LOCK.txt');
      //koniec transakcie
    end;
  end;
end
else
  ShowMessage('Treba vyplniť všetky polia');

aktual:=true;
end;
end.

