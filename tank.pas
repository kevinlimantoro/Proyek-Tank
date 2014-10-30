unit tank;



interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ScktComp;

type
      TForm1 = class(TForm)
    tank1: TImage;
    ServerSocket1: TServerSocket;
    ClientSocket1: TClientSocket;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    tank2: TImage;
    tank3: TImage;
    tank4: TImage;
    lp1: TShape;
    Timer1: TTimer;
    lp2: TShape;
    lp3: TShape;
    lp4: TShape;
    label1: TLabel;
    AITimer: TTimer;
    Button3: TButton;
    Bonus: TTimer;
    special: TImage;
    Heal: TTimer;
    special2: TImage;
    special3: TImage;
    bomber: TTimer;

    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ServerSocket1ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Timer1Timer(Sender: TObject);
    procedure tank1Click(Sender: TObject);
    procedure tank3Click(Sender: TObject);
    procedure tank4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure AITimerTimer(Sender: TObject);
    procedure BonusTimer(Sender: TObject);
    procedure tank2Click(Sender: TObject);
    procedure HealTimer(Sender: TObject);
    procedure bomberTimer(Sender: TObject);
  private
    { Private declarations }
  public
    
  end;

var
  Form1: TForm1;
  total:integer=-1;
  tipe,wktbonus,wktheal,xb,yb,xh,yh:integer;
  onMove:boolean;
  temp,temp2:string;
  kejar:integer=8;
  hadapan,xp,yp:integer;
  papan:array[0..9,0..14] of timage;
  ammo:array[0..3] of timage;
  shooting:boolean=false;
  bnsammo:boolean=false;
  AIPlay:boolean=false;
  mati:boolean=false;
  xai,yai:integer;
  wktbomber:integer;
  target:integer;
implementation

{$R *.dfm}
procedure randomHadapan();
begin
randomize();
 hadapan:=1+random(4);
end;

procedure serverbroadcast(serper:tserversocket;total:integer;pesan:string);
var
i:integer;
begin
for i:=0 to total do
begin
serper.Socket.Connections[i].SendText(pesan);

end;
end;

procedure start(mapfile: string);
var
  i,j:integer;
  myfile: TextFile;
  kalfile: string;
begin
  AssignFile(myfile,mapfile);
  Reset(myfile);

  for i:=0 to 9 do
  begin
    Readln(myfile,kalfile);
    for j:=0 to 14 do
    begin
      papan[i,j]:=Timage.Create(form1);
      papan[i,j].Parent:=form1;
      papan[i,j].Top:=i*60;
      papan[i,j].Left:=j*60;
      papan[i,j].Width:=60;
      papan[i,j].Height:=60;
      papan[i,j].Stretch:=true;
      papan[i,j].Hint:=kalfile[j+1];//aneh kon kayak ada 1 char nde depane

      if (kalfile[j+1]='w') then
        papan[i,j].Picture.LoadFromFile('wall.bmp')
        else
        papan[i,j].Picture.LoadFromFile('tanah.bmp')

    end;
  end;

  CloseFile(myfile);

  for i:=0 to 3 do
  begin
  ammo[i]:=Timage.Create(form1);
      ammo[i].Parent:=form1;
      ammo[i].Top:=i*60;
      ammo[i].Left:=-40;
      ammo[i].Width:=40;
      ammo[i].Height:=40;
      ammo[i].Transparent:=true;
  end;

end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
if (aitimer.Enabled=false) and (mati=false) then
begin
if key='w' then
begin
hadapan:=1;
if tipe=0 then
  begin
  if (tank1.Top-2>0) and(papan[(tank1.Top-2) div 60,(tank1.Left+15)div 60].hint<>'w') and (papan[(tank1.Top-2) div 60,(tank1.Left+tank1.Width-15)div 60].hint<>'w') then
  begin
    if papan[(tank1.Top-2) div 60,(tank1.Left+30)div 60].Hint='b' then
    begin
    wktbonus:=41;
    bnsammo:=true;
    end;
    if papan[(tank1.Top-2) div 60,(tank1.Left+30)div 60].Hint='h' then
    begin
    wktheal:=31;
    lp1.Width:=lp1.Width+150;
    serverbroadcast(serversocket1,total,'addlp1');
    papan[(tank1.Top-2) div 60,(tank1.Left+30)div 60].Hint:='.';
    end;
  papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].Hint:='.';
  papan[(tank1.Top+30-2) div 60,(tank1.Left+30)div 60].Hint:='0';
  tank1.Picture.LoadFromFile('tank1-1.bmp');
  tank1.Top:=tank1.Top-2;
  serverbroadcast(serversocket1,total,'POS11'+inttostr(tank1.left)+'!'+inttostr(tank1.top)+'&');
  end;
  end
  else if tipe=1 then
  begin
  if (tank2.Top-2>0) and(papan[(tank2.Top-1) div 60,(tank2.Left+15)div 60].hint<>'w') and (papan[(tank2.Top-1) div 60,(tank2.Left+tank2.Width-15)div 60].hint<>'w') then
  begin
  if papan[(tank2.Top-2) div 60,(tank2.Left+30)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank2.Top-2) div 60,(tank2.Left+30)div 60].Hint='h' then
    begin
    lp2.Width:=lp2.Width+150;
    clientsocket1.Socket.SendText('addlp2');
    papan[(tank2.Top-2) div 60,(tank2.Left+30)div 60].Hint:='.';
    end;
  papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].Hint:='.';
  papan[(tank2.Top+30-2) div 60,(tank2.Left+30)div 60].hint:=inttostr(tipe);
  tank2.Picture.LoadFromFile('tank2-1.bmp');
  tank2.Top:=tank2.Top-2;
  clientsocket1.Socket.SendText('POS21'+inttostr(tank2.left)+'!'+inttostr(tank2.top)+'&');

  end;
  end
  else if tipe=2 then
  begin
  if (tank3.Top-2>0) and(papan[(tank3.Top-1) div 60,(tank3.Left+15)div 60].hint<>'w') and (papan[(tank3.Top-1) div 60,(tank3.Left+tank3.Width-15)div 60].hint<>'w') then
  begin
  if papan[(tank3.Top-2) div 60,(tank3.Left+30)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank3.Top-2) div 60,(tank3.Left+30)div 60].Hint='h' then
    begin
    lp3.Width:=lp3.Width+150;
    clientsocket1.Socket.SendText('addlp3');
    papan[(tank3.Top-2) div 60,(tank3.Left+30)div 60].Hint:='.';
    end;
  papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].Hint:='.';
  papan[(tank3.Top+30-2) div 60,(tank3.Left+30)div 60].Hint:='2';
  tank3.Picture.LoadFromFile('tank3-1.bmp');
  tank3.Top:=tank3.Top-2;
    clientsocket1.Socket.SendText('POS31'+inttostr(tank3.left)+'!'+inttostr(tank3.top)+'&');

  end;
  end
  else if tipe=3 then
  begin
  if (tank4.Top-2>0) and(papan[(tank4.Top-1) div 60,(tank4.Left+15)div 60].hint<>'w') and (papan[(tank4.Top-1) div 60,(tank4.Left+tank4.Width-15)div 60].hint<>'w') then
  begin
  if papan[(tank4.Top-2) div 60,(tank4.Left+30)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank4.Top-2) div 60,(tank4.Left+30)div 60].Hint='h' then
    begin
    lp4.Width:=lp4.Width+150;
    clientsocket1.Socket.SendText('addlp4');
    papan[(tank4.Top-2) div 60,(tank4.Left+30)div 60].Hint:='.';
    end;
  papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].Hint:='.';
  papan[(tank4.Top+30-2) div 60,(tank4.Left+30)div 60].Hint:='3';
  tank4.Picture.LoadFromFile('tank4-1.bmp');
  tank4.Top:=tank4.Top-2;
  clientsocket1.Socket.SendText('POS41'+inttostr(tank4.left)+'!'+inttostr(tank4.top)+'&');

  end;
  end;
end
else if key='s' then
begin
hadapan:=3;
if tipe=0 then
  begin
   if (tank1.Top+tank1.Height+2<form1.Height-40) and(papan[(tank1.Top+tank1.height+1) div 60,(tank1.Left+15)div 60].hint<>'w') and (papan[(tank1.Top+tank1.Height+1) div 60,(tank1.Left+tank1.Width-15)div 60].hint<>'w') then
  begin
  if papan[(tank1.Top+60+2) div 60,(tank1.Left+30)div 60].Hint='b' then
    begin
    wktbonus:=41;
    bnsammo:=true;
    end;
  if papan[(tank1.Top+60+2) div 60,(tank1.Left+30)div 60].Hint='h' then
  begin
    wktheal:=31;
    lp1.Width:=lp1.Width+150;
    serverbroadcast(serversocket1,total,'addlp1');
    papan[(tank1.Top+60+2) div 60,(tank1.Left+30)div 60].Hint:='.';
    end;
    papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].Hint:='.';
  papan[(tank1.Top+30+2) div 60,(tank1.Left+30)div 60].Hint:='0';
  tank1.Picture.LoadFromFile('tank1-3.bmp');
  tank1.Top:=tank1.Top+2;
  serverbroadcast(serversocket1,total,'POS13'+inttostr(tank1.left)+'!'+inttostr(tank1.top)+'&');

  end;
  end
  else if tipe=1 then
  begin
  if (tank2.Top+tank2.Height+2<form1.Height-40) and(papan[(tank2.Top+tank2.height+1) div 60,(tank2.Left+15)div 60].hint<>'w') and (papan[(tank2.Top+tank2.Height+1) div 60,(tank2.Left+tank2.Width-15)div 60].hint<>'w') then
  begin
   if papan[(tank2.Top+60+2) div 60,(tank2.Left+30)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank2.Top+60+2) div 60,(tank2.Left+30)div 60].Hint='h' then
    begin
    lp2.Width:=lp2.Width+150;
    clientsocket1.Socket.SendText('addlp2');
    papan[(tank2.Top+60+2) div 60,(tank2.Left+30)div 60].Hint:='.';
    end;
    papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].Hint:='.';
  papan[(tank2.Top+30+2) div 60,(tank2.Left+30)div 60].hint:=inttostr(tipe);
  tank2.Picture.LoadFromFile('tank2-3.bmp');
  tank2.Top:=tank2.Top+2;
  clientsocket1.Socket.SendText('POS23'+inttostr(tank2.left)+'!'+inttostr(tank2.top)+'&');
  
  end;
  end
  else if tipe=2 then
  begin
  if (tank3.Top+tank3.Height+2<form1.Height-40) and(papan[(tank3.Top+tank3.height+1) div 60,(tank3.Left+15)div 60].hint<>'w') and (papan[(tank3.Top+tank3.Height+1) div 60,(tank3.Left+tank3.Width-15)div 60].hint<>'w') then
  begin
   if papan[(tank3.Top+60+2) div 60,(tank3.Left+30)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank3.Top+60+2) div 60,(tank3.Left+30)div 60].Hint='h' then
    begin
    lp3.Width:=lp3.Width+150;
    clientsocket1.Socket.SendText('addlp3');
    papan[(tank3.Top+60+2) div 60,(tank3.Left+30)div 60].Hint:='.';
    end;
   papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].Hint:='.';
  papan[(tank3.Top+30+2) div 60,(tank3.Left+30)div 60].Hint:='2';
  tank3.Picture.LoadFromFile('tank3-3.bmp');
  tank3.Top:=tank3.Top+2;
    clientsocket1.Socket.SendText('POS33'+inttostr(tank3.left)+'!'+inttostr(tank3.top)+'&');
  
  end;
  end
  else if tipe=3 then
  begin
  if (tank4.Top+tank4.Height+2<form1.Height-40) and(papan[(tank4.Top+tank4.height+1) div 60,(tank4.Left+15)div 60].hint<>'w') and (papan[(tank4.Top+tank4.Height+1) div 60,(tank4.Left+tank4.Width-15)div 60].hint<>'w') then
  begin
   if papan[(tank4.Top+60+2) div 60,(tank4.Left+30)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank4.Top+60+2) div 60,(tank4.Left+30)div 60].Hint='h' then
    begin
    lp4.Width:=lp4.Width+150;
    clientsocket1.Socket.SendText('addlp4');
    papan[(tank4.Top+60+2) div 60,(tank4.Left+30)div 60].Hint:='.';
    end;
   papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].Hint:='.';
  papan[(tank4.Top+30+2) div 60,(tank4.Left+30)div 60].Hint:='3';
  tank4.Picture.LoadFromFile('tank4-3.bmp');
  tank4.Top:=tank4.Top+2;
  clientsocket1.Socket.SendText('POS43'+inttostr(tank4.left)+'!'+inttostr(tank4.top)+'&');

  end;
  end;
end
else if key='a' then
begin
hadapan:=4;
if tipe=0 then
  begin
  if (tank1.left-2>0) and(papan[(tank1.Top+tank1.height-15) div 60,(tank1.Left-1)div 60].hint<>'w') and (papan[(tank1.Top+15) div 60,(tank1.Left-1)div 60].hint<>'w') then
  begin
  if papan[(tank1.Top+30) div 60,(tank1.Left-2)div 60].Hint='b' then
    begin
    wktbonus:=41;
    bnsammo:=true;
    end;
    if papan[(tank1.Top+30) div 60,(tank1.Left-2)div 60].Hint='b' then
    begin
    wktheal:=31;
    lp1.Width:=lp1.Width+150;
    serverbroadcast(serversocket1,total,'addlp1');
    end;
    if papan[(tank1.Top+30) div 60,(tank1.Left-2)div 60].Hint='h' then
    begin
    wktbonus:=31;
    lp1.Width:=lp1.Width+150;
    serverbroadcast(serversocket1,total,'addlp1');
    papan[(tank1.Top+30) div 60,(tank1.Left-2)div 60].Hint:='.';
    end;
   papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].Hint:='.';
  papan[(tank1.Top+30) div 60,(tank1.Left+30-2)div 60].Hint:='0';
  tank1.Picture.LoadFromFile('tank1-4.bmp');
  tank1.Left:=tank1.Left-2;
  serverbroadcast(serversocket1,total,'POS14'+inttostr(tank1.left)+'!'+inttostr(tank1.top)+'&');

  end;
  end
  else if tipe=1 then
  begin
  if (tank2.left-2>0) and(papan[(tank2.Top+tank2.height-15) div 60,(tank2.Left-1)div 60].hint<>'w') and (papan[(tank2.Top+15) div 60,(tank2.Left-1)div 60].hint<>'w') then
  begin
  if papan[(tank2.Top+30) div 60,(tank2.Left-2)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank2.Top+30) div 60,(tank2.Left-2)div 60].Hint='h' then
    begin
    lp2.Width:=lp2.Width+150;
    clientsocket1.Socket.SendText('addlp2');
    papan[(tank2.Top+30) div 60,(tank2.Left-2)div 60].Hint:='.';
    end;
    papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].Hint:='.';
  papan[(tank2.Top+30) div 60,(tank2.Left+30-2)div 60].hint:=inttostr(tipe);
  tank2.Picture.LoadFromFile('tank2-4.bmp');
  tank2.Left:=tank2.Left-2;
  clientsocket1.Socket.SendText('POS24'+inttostr(tank2.left)+'!'+inttostr(tank2.top)+'&');

  end;
  end
  else if tipe=2 then
  begin
  if (tank3.left-2>0) and(papan[(tank3.Top+tank3.height-15) div 60,(tank3.Left-1)div 60].hint<>'w') and (papan[(tank3.Top+15) div 60,(tank3.Left-1)div 60].hint<>'w') then
  begin
  if papan[(tank3.Top+30) div 60,(tank3.Left-2)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank3.Top+30) div 60,(tank3.Left-2)div 60].Hint='h' then
    begin
    lp3.Width:=lp3.Width+150;
    clientsocket1.Socket.SendText('addlp3');
    papan[(tank3.Top+30) div 60,(tank3.Left-2)div 60].Hint:='.';
    end;
  papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].Hint:='.';
  papan[(tank3.Top+30) div 60,(tank3.Left+30-2)div 60].Hint:='2';
  tank3.Picture.LoadFromFile('tank3-4.bmp');
  tank3.Left:=tank3.Left-2;
  clientsocket1.Socket.SendText('POS34'+inttostr(tank3.left)+'!'+inttostr(tank3.top)+'&');

  end;
  end
  else if tipe=3 then
  begin
  if (tank4.left-2>0) and(papan[(tank3.Top+tank3.height-15) div 60,(tank3.Left-1)div 60].hint<>'w') and (papan[(tank3.Top+15) div 60,(tank3.Left-1)div 60].hint<>'w') then
  begin
  if papan[(tank4.Top+30) div 60,(tank4.Left-2)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank4.Top+30) div 60,(tank4.Left-2)div 60].Hint='h' then
    begin
    lp4.Width:=lp4.Width+150;
    clientsocket1.Socket.SendText('addlp4');
    papan[(tank4.Top+30) div 60,(tank4.Left-2)div 60].Hint:='.';
    end;
  papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].Hint:='.';
  papan[(tank4.Top+30) div 60,(tank4.Left+30-2)div 60].Hint:='3';
  tank4.Picture.LoadFromFile('tank4-4.bmp');
  tank4.left:=tank4.Left-2;
    clientsocket1.Socket.SendText('POS44'+inttostr(tank4.left)+'!'+inttostr(tank4.top)+'&');
  
  end;
  end;
end
else if key='d' then
begin
hadapan:=2;
if tipe=0 then
  begin
  if (tank1.left+tank1.Width+2<form1.Width-20) and(papan[(tank1.Top+45) div 60,(tank1.Left+tank1.Width+1)div 60].hint<>'w') and (papan[(tank1.Top+15) div 60,(tank1.Left+tank1.Width+1)div 60].hint<>'w') then
  begin
  if papan[(tank1.Top+30) div 60,(tank1.Left+60+2)div 60].Hint='b' then
    begin
    wktbonus:=41;
    bnsammo:=true;
    end;
   if papan[(tank1.Top+30) div 60,(tank1.Left+60+2)div 60].Hint='h' then
    begin
    wktheal:=31;
    lp1.Width:=lp1.Width+150;
    serverbroadcast(serversocket1,total,'addlp1');
    papan[(tank1.Top+30) div 60,(tank1.Left+60+2)div 60].Hint:='.';
    end;
  papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].Hint:='.';
  papan[(tank1.Top+30) div 60,(tank1.Left+30+2)div 60].Hint:='0';
  tank1.Picture.LoadFromFile('tank1-2.bmp');
  tank1.Left:=tank1.Left+2;
  serverbroadcast(serversocket1,total,'POS12'+inttostr(tank1.left)+'!'+inttostr(tank1.top)+'&');

  end;
  end
  else if tipe=1 then
  begin
  if (tank2.left+tank2.Width+2<form1.Width-20)and(papan[(tank2.Top+45) div 60,(tank2.Left+tank2.Width+1)div 60].hint<>'w') and (papan[(tank2.Top+15) div 60,(tank2.Left+tank2.Width+1)div 60].hint<>'w') then
  begin
  if papan[(tank2.Top+30) div 60,(tank2.Left+60+2)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank2.Top+30) div 60,(tank2.Left+60+2)div 60].Hint='h' then
    begin
    lp2.Width:=lp2.Width+150;
    clientsocket1.Socket.SendText('addlp2');
    papan[(tank2.Top+30) div 60,(tank2.Left+60+2)div 60].Hint:='.';
    end;
    papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].Hint:='.';
  papan[(tank2.Top+30) div 60,(tank2.Left+30+2)div 60].hint:=inttostr(tipe);
  tank2.Picture.LoadFromFile('tank2-2.bmp');
  tank2.Left:=tank2.Left+2;
  clientsocket1.Socket.SendText('POS22'+inttostr(tank2.left)+'!'+inttostr(tank2.top)+'&');

  end;
  end
  else if tipe=2 then
  begin
  if (tank3.left+tank3.Width+2<form1.Width-20)and(papan[(tank3.Top+45) div 60,(tank3.Left+tank3.Width+1)div 60].hint<>'w') and (papan[(tank3.Top+15) div 60,(tank3.Left+tank3.Width+1)div 60].hint<>'w') then
  begin
    if papan[(tank3.Top+30) div 60,(tank3.Left+60+2)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank3.Top+30) div 60,(tank3.Left+60+2)div 60].Hint='h' then
    begin
    lp3.Width:=lp3.Width+150;
    clientsocket1.Socket.SendText('addlp3');
    papan[(tank3.Top+30) div 60,(tank3.Left+60+2)div 60].Hint:='.';
    end;
    papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].Hint:='.';
  papan[(tank3.Top+30) div 60,(tank3.Left+30+2)div 60].Hint:='2';
  tank3.Picture.LoadFromFile('tank3-2.bmp');
  tank3.Left:=tank3.Left+2;
  clientsocket1.Socket.SendText('POS32'+inttostr(tank3.left)+'!'+inttostr(tank3.top)+'&');
  
  end;
  end
  else if tipe=3 then
  begin
  if (tank4.left+tank4.Width+2<form1.Width-20)and(papan[(tank4.Top+45) div 60,(tank4.Left+tank4.Width+1)div 60].hint<>'w') and (papan[(tank4.Top+15) div 60,(tank4.Left+tank4.Width+1)div 60].hint<>'w') then
  begin
    if papan[(tank4.Top+30) div 60,(tank4.Left+60+2)div 60].Hint='b' then
    begin
    clientsocket1.Socket.SendText('bonusget');
    bnsammo:=true;
    end;
    if papan[(tank4.Top+30) div 60,(tank4.Left+60+2)div 60].Hint='h' then
    begin
    lp4.Width:=lp4.Width+150;
    clientsocket1.Socket.SendText('addlp4');
    papan[(tank4.Top+30) div 60,(tank4.Left+60+2)div 60].Hint:='.';
    end;
    papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].Hint:='.';
  papan[(tank4.Top+30) div 60,(tank4.Left+30+2)div 60].Hint:='3';
  tank4.Picture.LoadFromFile('tank4-2.bmp');
  tank4.left:=tank4.Left+2;
  clientsocket1.Socket.SendText('POS42'+inttostr(tank4.left)+'!'+inttostr(tank4.top)+'&');

  end;
  end
end

else if key=' ' then
begin
if shooting=false then
begin
if hadapan=1 then
begin
yp:=-10;
xp:=0;
if tipe=0 then
begin
ammo[tipe].Left:=tank1.Left+10;
ammo[tipe].Top:=tank1.Top-40;
end
else if tipe=1 then
begin
ammo[tipe].Left:=tank2.Left+10;
ammo[tipe].Top:=tank2.Top-40;
end
else if tipe=2 then
begin
ammo[tipe].Left:=tank3.Left+10;
ammo[tipe].Top:=tank3.Top-40;
end
else if tipe=3 then
begin
ammo[tipe].Left:=tank4.Left+10;
ammo[tipe].Top:=tank4.Top-40;
end;
end
else if hadapan=2 then
begin
yp:=0;
xp:=10;
if tipe=0 then
begin
ammo[tipe].Left:=tank1.Left+tank1.Width;
ammo[tipe].Top:=tank1.Top+10;
end
else if tipe=1 then
begin
ammo[tipe].Left:=tank2.Left+tank2.Width;
ammo[tipe].Top:=tank2.Top+10;
end
else if tipe=2 then
begin
ammo[tipe].Left:=tank3.Left+tank3.Width;
ammo[tipe].Top:=tank3.Top+10;
end
else if tipe=3 then
begin
ammo[tipe].Left:=tank4.Left+tank4.Width;
ammo[tipe].Top:=tank4.Top+10;
end;
end
else if hadapan=3 then
begin
yp:=10;
xp:=0;
if tipe=0 then
begin
ammo[tipe].Left:=tank1.Left+10;
ammo[tipe].Top:=tank1.Top+tank1.Height;
end
else if tipe=1 then
begin
ammo[tipe].Left:=tank2.Left+10;
ammo[tipe].Top:=tank2.Top+tank2.Height;
end
else if tipe=2 then
begin
ammo[tipe].Left:=tank3.Left+10;
ammo[tipe].Top:=tank3.Top+tank3.Height;
end
else if tipe=3 then
begin
ammo[tipe].Left:=tank4.Left+10;
ammo[tipe].Top:=tank4.Top+tank4.Height;
end;
end
else if hadapan=4 then
begin
yp:=0;
xp:=-10;
if tipe=0 then
begin
ammo[tipe].Left:=tank1.Left-40;
ammo[tipe].Top:=tank1.Top+10;
end
else if tipe=1 then
begin
ammo[tipe].Left:=tank2.Left-40;
ammo[tipe].Top:=tank2.Top+10;
end
else if tipe=2 then
begin
ammo[tipe].Left:=tank3.Left-40;
ammo[tipe].Top:=tank3.Top+10;
end
else if tipe=3 then
begin
ammo[tipe].Left:=tank4.Left-40;
ammo[tipe].Top:=tank4.Top+10;
end
end;
ammo[tipe].Picture.LoadFromFile('peluru.bmp');
timer1.Interval:=50;
timer1.Enabled:=true;
shooting:=true;
end;
end;

end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
serversocket1.Port:=2000;
serversocket1.Open;
edit1.Hide;
edit1.Enabled:=false;
button1.Enabled:=false;
button2.Enabled:=false;
button3.Enabled:=false;
button1.Hide;
button2.Hide;
button3.Hide;
tank1.Picture.LoadFromFile('tank1-2.bmp');
lp1.Visible:=true;
tipe:=0;
hadapan:=2;
label1.BringToFront;
bonus.Interval:=1000;
bonus.Enabled:=true;
heal.Interval:=1000;
heal.Enabled:=true;
bomber.Interval:=300;
bomber.Enabled:=true;
timer1.Enabled:=false;
 wktbonus:=0;
 wktheal:=0;
 wktbomber:=0;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
clientsocket1.Port:=2000;
clientsocket1.Address:=edit1.Text;
clientsocket1.Open;
edit1.Hide;
edit1.Enabled:=false;
button1.Enabled:=false;
button2.Enabled:=false;
button3.Enabled:=false;
button1.Hide;
button2.Hide;
button3.Hide;

end;

procedure TForm1.ServerSocket1ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
total:=total+1;
serverbroadcast(serversocket1,total,'#'+inttostr(total));
serversocket1.Socket.Connections[total].SendText('tipe'+inttostr(total));
if total=0 then
begin
tank2.Picture.LoadFromFile('tank2-1.bmp');
lp2.Visible:=true;
end
else if total=1 then
begin
tank3.Picture.LoadFromFile('tank3-4.bmp');
lp3.Visible:=true;
end
else if total=2 then
begin
tank4.Picture.LoadFromFile('tank4-4.bmp');
lp4.Visible:=true;
end;
end;

procedure TForm1.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
begin
temp:=clientsocket1.Socket.ReceiveText;
if copy(temp,1,1)='#' then
begin
  if strtoint(copy(temp,2,1))>=0 then
    begin
    tank1.Picture.LoadFromFile('tank1-2.bmp');
    tank2.Picture.LoadFromFile('tank2-1.bmp');
    lp1.Visible:=true;
    lp2.Visible:=true;
    end;
    if strtoint(copy(temp,2,1))>=1 then
    begin
    tank1.Picture.LoadFromFile('tank1-2.bmp');
    tank2.Picture.LoadFromFile('tank2-1.bmp');
    tank3.Picture.LoadFromFile('tank3-4.bmp');
    lp1.Visible:=true;
    lp2.Visible:=true;
    lp3.Visible:=true;
    end;
    if strtoint(copy(temp,2,1))>=2 then
    begin
    tank1.Picture.LoadFromFile('tank1-2.bmp');
    tank2.Picture.LoadFromFile('tank2-1.bmp');
    tank3.Picture.LoadFromFile('tank3-4.bmp');
    tank4.Picture.LoadFromFile('tank4-4.bmp');
    lp1.Visible:=true;
    lp2.Visible:=true;
    lp3.Visible:=true;
    lp4.Visible:=true;
    end;
    temp:=copy(temp,3,5);
end;
if copy(temp,1,4)='tipe' then
begin
 if copy(temp,5,1)='0' then
 tipe:=1
 else if copy(temp,5,1)='1' then
 tipe:=2
 else if copy(temp,5,1)='2' then
 tipe:=3;
end
else if copy(temp,1,3)='POS' then
begin
  if copy(temp,4,1)='1' then
  begin
      if copy(temp,5,1)='1' then
      begin
      tank1.Picture.LoadFromFile('tank1-1.bmp');
       papan[(tank1.Top+30+2) div 60,(tank1.Left+30)div 60].Hint:='.';
       papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].hint:='0';
      end
      else if copy(temp,5,1)='2' then
      begin
      tank1.Picture.LoadFromFile('tank1-2.bmp');
       papan[(tank1.Top+30) div 60,(tank1.Left+30-2)div 60].Hint:='.';
       papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].hint:='0';
      end
      else if copy(temp,5,1)='3' then
      begin
      tank1.Picture.LoadFromFile('tank1-3.bmp');
       papan[(tank1.Top+30-2) div 60,(tank1.Left+30)div 60].Hint:='.';
       papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].hint:='0';
      end
      else if copy(temp,5,1)='4' then
      begin
      tank1.Picture.LoadFromFile('tank1-4.bmp');
       papan[(tank1.Top+30) div 60,(tank1.Left+30+2)div 60].Hint:='.';
       papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].hint:='0';
      end;
    tank1.Left:=strtoint(copy(temp,6,pos('!',temp)-6));
    tank1.top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
  end
  else if copy(temp,4,1)='2' then
  begin
      if copy(temp,5,1)='1' then
      begin
      tank2.Picture.LoadFromFile('tank2-1.bmp');
       papan[(tank2.Top+30+2) div 60,(tank2.Left+30)div 60].Hint:='.';
       papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].hint:='1';
      end
      else if copy(temp,5,1)='2' then
      begin
      tank2.Picture.LoadFromFile('tank2-2.bmp');
       papan[(tank2.Top+30) div 60,(tank2.Left+30-2)div 60].Hint:='.';
       papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].hint:='1';
      end
      else if copy(temp,5,1)='3' then
      begin
      tank2.Picture.LoadFromFile('tank2-3.bmp');
       papan[(tank2.Top+30-2) div 60,(tank2.Left+30)div 60].Hint:='.';
       papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].hint:='1';
      end
      else if copy(temp,5,1)='4' then
      begin
      tank2.Picture.LoadFromFile('tank2-4.bmp');
       papan[(tank2.Top+30) div 60,(tank2.Left+30+2)div 60].Hint:='.';
       papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].hint:='1';
      end;
    tank2.Left:=strtoint(copy(temp,6,pos('!',temp)-6));
    tank2.top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
  end
  else if copy(temp,4,1)='3' then
  begin
      if copy(temp,5,1)='1' then
      begin
      tank3.Picture.LoadFromFile('tank3-1.bmp');
       papan[(tank3.Top+30+2) div 60,(tank3.Left+30)div 60].Hint:='.';
       papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].hint:='2';
      end
      else if copy(temp,5,1)='2' then
      begin
      tank3.Picture.LoadFromFile('tank3-2.bmp');
       papan[(tank3.Top+30) div 60,(tank3.Left+30-2)div 60].Hint:='.';
       papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].hint:='2';
      end
      else if copy(temp,5,1)='3' then
      begin
      tank3.Picture.LoadFromFile('tank3-3.bmp');
       papan[(tank3.Top+30-2) div 60,(tank3.Left+30)div 60].Hint:='.';
       papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].hint:='2';
      end
      else if copy(temp,5,1)='4' then
      begin
      tank3.Picture.LoadFromFile('tank3-4.bmp');
       papan[(tank3.Top+30) div 60,(tank3.Left+30+2)div 60].Hint:='.';
       papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].hint:='2';
      end;
    tank3.Left:=strtoint(copy(temp,6,pos('!',temp)-6));
    tank3.top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
  end
  else if copy(temp,4,1)='4' then
  begin
      if copy(temp,5,1)='1' then
      begin
      tank4.Picture.LoadFromFile('tank4-1.bmp');
       papan[(tank4.Top+30+2) div 60,(tank4.Left+30)div 60].Hint:='.';
       papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].hint:='3';
      end
      else if copy(temp,5,1)='2' then
      begin
      tank4.Picture.LoadFromFile('tank4-2.bmp');
       papan[(tank4.Top+30) div 60,(tank4.Left+30-2)div 60].Hint:='.';
       papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].hint:='3';
      end
      else if copy(temp,5,1)='3' then
      begin
      tank4.Picture.LoadFromFile('tank4-3.bmp');
       papan[(tank4.Top+30-2) div 60,(tank4.Left+30)div 60].Hint:='.';
       papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].hint:='3';
      end
      else if copy(temp,5,1)='4' then
      begin
      tank4.Picture.LoadFromFile('tank4-4.bmp');
       papan[(tank4.Top+30) div 60,(tank4.Left+30+2)div 60].Hint:='.';
       papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].hint:='3';
      end;
    tank4.Left:=strtoint(copy(temp,6,pos('!',temp)-6));
    tank4.top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
  end;
end
else if copy(temp,1,4)='kena' then
begin
ammo[strtoint(copy(temp,6,1))].Picture.loadfromfile('boom.bmp');
ammo[strtoint(copy(temp,6,1))].Left:=strtoint(copy(temp,7,pos('!',temp)-7));
ammo[strtoint(copy(temp,6,1))].top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));

    if copy(temp,5,1)='0' then
    lp1.Width:=lp1.Width-30

    else if (copy(temp,5,1)='1')  then
    begin
    lp2.Width:=lp2.Width-30;
    if (lp2.Width<=0) and (tipe=1)then
    begin
      clientsocket1.Socket.SendText('tewas2');
      tank2.Picture.loadfromfile('tewas.bmp');
      mati:=true;aitimer.Enabled:=false;
    end;
    end
    else if (copy(temp,5,1)='2')  then
    begin
    lp3.Width:=lp3.Width-30;
    if (lp3.Width<=0) and (tipe=2) then
    begin
      clientsocket1.socket.sendtext('tewas3');
      tank3.Picture.loadfromfile('tewas.bmp');
      mati:=true;aitimer.Enabled:=false;
    end;
    end
    else if (copy(temp,5,1)='3')  then
    begin
    lp4.Width:=lp4.Width-30;
    if (lp4.Width<=0) and (tipe=3) then
    begin
      clientsocket1.socket.sendtext('tewas4');
      tank4.Picture.loadfromfile('tewas.bmp');
      mati:=true;
      aitimer.Enabled:=false;
    end;
    end;
end
else if copy(temp,1,5)='tewas' then
begin
    if copy(temp,6,1)='1' then
    tank1.Picture.LoadFromFile('tewas.bmp')
    else  if copy(temp,6,1)='2' then
    tank2.Picture.LoadFromFile('tewas.bmp')
    else if copy(temp,6,1)='3' then
    tank3.Picture.LoadFromFile('tewas.bmp')
    else if copy(temp,6,1)='4' then
    tank4.Picture.LoadFromFile('tewas.bmp');
end
else if copy(temp,1,4)='ammo' then
begin
  ammo[strtoint(copy(temp,5,1))].Picture.LoadFromFile('peluru.bmp');
  ammo[strtoint(copy(temp,5,1))].Left:=strtoint(copy(temp,6,pos('!',temp)-6));
  ammo[strtoint(copy(temp,5,1))].top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
end
else if copy(temp,1,5)='bonus' then
begin

    if copy(temp,6,3)='del' then
    begin
       special.Hide;
       papan[yb,xb].Hint:='.';
    end
    else if copy(temp,6,3)='get' then
    begin
       special.Hide;
       papan[yb,xb].Hint:='.';
    end
    else
    begin
    xb:=strtoint(copy(temp,6,pos('!',temp)-6));
    yb:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-pos('!',temp)-1));
    special.Left:=xb*60;
    special.Top:=yb*60;
    special.Visible:=true;
    special.Picture.LoadFromFile('bonus.bmp');
    special.BringToFront;
    papan[yb,xb].Hint:='b';
    end;
end
else if copy(temp,1,4)='heal' then
begin

    if copy(temp,5,3)='del' then
    begin
       special2.Hide;
       papan[yh,xh].Hint:='.';
    end
    else if copy(temp,5,3)='get' then
    begin
       special2.Hide;
       papan[yh,xh].Hint:='.';
    end
    else
    begin
    xh:=strtoint(copy(temp,5,pos('!',temp)-5));
    yh:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-pos('!',temp)-1));
    special2.Left:=xh*60;
    special2.Top:=yh*60;
    special2.Visible:=true;
    special2.Picture.LoadFromFile('heal.bmp');
    special2.BringToFront;
    papan[yh,xh].Hint:='h';
    end;
end
else if copy(temp,1,6)='bomber' then
begin

    if copy(temp,7,3)='del' then
    begin
       special3.Hide;
    end
    else if copy(temp,7,1)='!' then
    begin
       if copy(temp,8,1)='0' then
    lp1.Width:=lp1.Width-10

    else if (copy(temp,8,1)='1')  then
    begin
    lp2.Width:=lp2.Width-10;
    if (lp2.Width<=0) and (tipe=1)then
    begin
      clientsocket1.Socket.SendText('tewas2');
      tank2.Picture.loadfromfile('tewas.bmp');
      mati:=true;aitimer.Enabled:=false;
    end;
    end
    else if (copy(temp,8,1)='2')  then
    begin
    lp3.Width:=lp3.Width-10;
    if (lp3.Width<=0) and (tipe=2) then
    begin
      clientsocket1.socket.sendtext('tewas3');
      tank3.Picture.loadfromfile('tewas.bmp');
      mati:=true;aitimer.Enabled:=false;
    end;
    end
    else if (copy(temp,8,1)='3')  then
    begin
    lp4.Width:=lp4.Width-10;
    if (lp4.Width<=0) and (tipe=3) then
    begin
      clientsocket1.socket.sendtext('tewas4');
      tank4.Picture.loadfromfile('tewas.bmp');
      mati:=true;
      aitimer.Enabled:=false;
    end;
    end;
    end
    else
    begin
    special3.Picture.LoadFromFile('bomber.bmp');
    if special3.Left>strtoint(copy(temp,7,pos('!',temp)-7)) then
    special3.Picture.LoadFromFile('bomber2.bmp');
    special3.Left:=strtoint(copy(temp,7,pos('!',temp)-7));
    special3.Top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-pos('!',temp)-1));;
    special3.Visible:=true;
    
    special3.BringToFront;
    end;
end
else if copy(temp,1,5)='addlp' then
begin
   if (copy(temp,6,1)='1') and (tipe<>0) then
   lp1.Width:=lp1.Width+150
   else if (copy(temp,6,1)='2') and (tipe<>1) then
   lp2.Width:=lp2.Width+150
   else if (copy(temp,6,1)='3') and (tipe<>2) then
   lp3.Width:=lp3.Width+150
   else if (copy(temp,6,1)='4') and (tipe<>3) then
   lp4.Width:=lp4.Width+150
end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  start('map.txt');
  tank1.Transparent:=true;
tank2.Transparent:=true;
tank3.Transparent:=true;
tank4.Transparent:=true;
tank1.BringToFront;
tank2.BringToFront;
tank3.BringToFront;
tank4.BringToFront;
lp1.BringToFront;
lp2.BringToFront;
lp3.BringToFront;
lp4.BringToFront;

end;

procedure TForm1.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
begin
temp:=socket.ReceiveText;
if copy(temp,1,3)='POS' then
begin
 if copy(temp,4,1)='2' then
  begin
      if copy(temp,5,1)='1' then
      begin
      tank2.Picture.LoadFromFile('tank2-1.bmp');
       papan[(tank2.Top+30+2) div 60,(tank2.Left+30)div 60].Hint:='.';
       papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].hint:='1';
      end
      else if copy(temp,5,1)='2' then
      begin
      tank2.Picture.LoadFromFile('tank2-2.bmp');
       papan[(tank2.Top+30) div 60,(tank2.Left+30-2)div 60].Hint:='.';
       papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].hint:='1';
      end
      else if copy(temp,5,1)='3' then
      begin
      tank2.Picture.LoadFromFile('tank2-3.bmp');
       papan[(tank2.Top+30-2) div 60,(tank2.Left+30)div 60].Hint:='.';
       papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].hint:='1';
      end
      else if copy(temp,5,1)='4' then
      begin
      tank2.Picture.LoadFromFile('tank2-4.bmp');
       papan[(tank2.Top+30) div 60,(tank2.Left+30+2)div 60].Hint:='.';
       papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].hint:='1';
      end;
    tank2.Left:=strtoint(copy(temp,6,pos('!',temp)-6));
    tank2.top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
  end
  else if copy(temp,4,1)='3' then
  begin
      if copy(temp,5,1)='1' then
      begin
      tank3.Picture.LoadFromFile('tank3-1.bmp');
       papan[(tank3.Top+30+2) div 60,(tank3.Left+30)div 60].Hint:='.';
       papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].hint:='2';
      end
      else if copy(temp,5,1)='2' then
      begin
      tank3.Picture.LoadFromFile('tank3-2.bmp');
       papan[(tank3.Top+30) div 60,(tank3.Left+30-2)div 60].Hint:='.';
       papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].hint:='2';
      end
      else if copy(temp,5,1)='3' then
      begin
      tank3.Picture.LoadFromFile('tank3-3.bmp');
       papan[(tank3.Top+30-2) div 60,(tank3.Left+30)div 60].Hint:='.';
       papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].hint:='2';
      end
      else if copy(temp,5,1)='4' then
      begin
      tank3.Picture.LoadFromFile('tank3-4.bmp');
       papan[(tank3.Top+30) div 60,(tank3.Left+30+2)div 60].Hint:='.';
       papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].hint:='2';
      end;
    tank3.Left:=strtoint(copy(temp,6,pos('!',temp)-6));
    tank3.top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
  end
  else if copy(temp,4,1)='4' then
  begin
      if copy(temp,5,1)='1' then
      begin
      tank4.Picture.LoadFromFile('tank4-1.bmp');
       papan[(tank4.Top+30+2) div 60,(tank4.Left+30)div 60].Hint:='.';
       papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].hint:='3';
      end
      else if copy(temp,5,1)='2' then
      begin
      tank4.Picture.LoadFromFile('tank4-2.bmp');
       papan[(tank4.Top+30) div 60,(tank4.Left+30-2)div 60].Hint:='.';
       papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].hint:='3';
      end
      else if copy(temp,5,1)='3' then
      begin
      tank4.Picture.LoadFromFile('tank4-3.bmp');
       papan[(tank4.Top+30-2) div 60,(tank4.Left+30)div 60].Hint:='.';
       papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].hint:='3';
      end
      else if copy(temp,5,1)='4' then
      begin
      tank4.Picture.LoadFromFile('tank4-4.bmp');
       papan[(tank4.Top+30) div 60,(tank4.Left+30+2)div 60].Hint:='.';
       papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].hint:='3';
      end;
    tank4.Left:=strtoint(copy(temp,6,pos('!',temp)-6));
    tank4.top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
  end;
  serverbroadcast(serversocket1,total,temp);
end

else if copy(temp,1,4)='ammo' then
begin
  ammo[strtoint(copy(temp,5,1))].Picture.LoadFromFile('peluru.bmp');
  ammo[strtoint(copy(temp,5,1))].Left:=strtoint(copy(temp,6,pos('!',temp)-6));
  ammo[strtoint(copy(temp,5,1))].top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
end

else if copy(temp,1,5)='bonus' then
begin

    if copy(temp,6,3)='del' then
    begin
       special.Hide;
       papan[yb,xb].Hint:='.';
    end
    else if copy(temp,6,3)='get' then
    begin
    wktbonus:=41;//jadi kl server yg dapet cm ngubah jadi 41;
       special.Hide;
       papan[yb,xb].Hint:='.';
    end
    else
    begin
    xb:=strtoint(copy(temp,6,pos('!',temp)-6));
    yb:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-pos('!',temp)-1));
    special.Left:=xb*60;
    special.Top:=yb*60;
    special.Visible:=true;
    special.Picture.LoadFromFile('bonus.bmp');
    special.BringToFront;
    papan[yb,xb].Hint:='b';
    end;
end

else if copy(temp,1,5)='addlp' then
begin
   if copy(temp,6,1)='1' then
   lp1.Width:=lp1.Width+150
   else if copy(temp,6,1)='2' then
   lp2.Width:=lp2.Width+150
   else if copy(temp,6,1)='3' then
   lp3.Width:=lp3.Width+150
   else if copy(temp,6,1)='4' then
   lp4.Width:=lp4.Width+150;
   wktheal:=31;
   serverbroadcast(serversocket1,total,temp);
end

else if copy(temp,1,4)='kena' then
begin
ammo[strtoint(copy(temp,6,1))].Picture.loadfromfile('boom.bmp');
ammo[strtoint(copy(temp,6,1))].Left:=strtoint(copy(temp,7,pos('!',temp)-7));
ammo[strtoint(copy(temp,6,1))].top:=strtoint(copy(temp,pos('!',temp)+1,pos('&',temp)-1-pos('!',temp)));
    if copy(temp,5,1)='0' then
    begin
    lp1.Width:=lp1.Width-30;
    if lp1.Width<=0 then
    begin
      serverbroadcast(serversocket1,total,'tewas1');
      tank1.Picture.loadfromfile('tewas.bmp');
      mati:=true;
    end;
    end
    else if copy(temp,5,1)='1' then
    lp2.Width:=lp2.Width-30

    else if copy(temp,5,1)='2' then
    lp3.Width:=lp3.Width-30

    else if copy(temp,5,1)='3' then
    lp4.Width:=lp4.Width-30;

    serverbroadcast(serversocket1,total,temp);

end

else if copy(temp,1,5)='tewas' then
begin
    if copy(temp,6,1)='1' then
    tank1.Picture.LoadFromFile('tewas.bmp')
    else  if copy(temp,6,1)='2' then
    tank2.Picture.LoadFromFile('tewas.bmp')
    else if copy(temp,6,1)='3' then
    tank3.Picture.LoadFromFile('tewas.bmp')
    else if copy(temp,6,1)='4' then
    tank4.Picture.LoadFromFile('tewas.bmp');
end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
if kejar=8 then
begin
ammo[tipe].Left:=ammo[tipe].Left+xp;
ammo[tipe].top:=ammo[tipe].Top+yp;
end
else
begin
if kejar=1 then
begin
  if (ammo[tipe].Left+20)<(tank2.Left) then
    ammo[tipe].Left:=ammo[tipe].Left+10
  else if (ammo[tipe].Left+20)>(tank2.Left+60) then
    ammo[tipe].Left:=ammo[tipe].Left-10;

    if (ammo[tipe].top+20)<(tank2.top) then
      ammo[tipe].Top:=ammo[tipe].Top+10
    else if (ammo[tipe].top+20)>(tank2.top+60) then
      ammo[tipe].Top:=ammo[tipe].Top-10;
end
else if kejar=2 then
begin
  if (ammo[tipe].Left+20)<(tank3.Left) then
    ammo[tipe].Left:=ammo[tipe].Left+10
  else if (ammo[tipe].Left+20)>(tank3.Left+60) then
    ammo[tipe].Left:=ammo[tipe].Left-10;

    if (ammo[tipe].top+20)<(tank3.top) then
      ammo[tipe].Top:=ammo[tipe].Top+10
    else if (ammo[tipe].top+20)>(tank3.top+60) then
      ammo[tipe].Top:=ammo[tipe].Top-10;
end
else if kejar=3 then
begin
  if (ammo[tipe].Left+20)<(tank4.Left) then
    ammo[tipe].Left:=ammo[tipe].Left+10
  else if (ammo[tipe].Left+20)>(tank4.Left+60) then
    ammo[tipe].Left:=ammo[tipe].Left-10;

    if (ammo[tipe].top+20)<(tank4.top) then
      ammo[tipe].Top:=ammo[tipe].Top+10
    else if (ammo[tipe].top+20)>(tank4.top+60) then
      ammo[tipe].Top:=ammo[tipe].Top-10;
end
else if kejar=0 then
begin
  if (ammo[tipe].Left+20)<(tank1.Left) then
    ammo[tipe].Left:=ammo[tipe].Left+10
  else if (ammo[tipe].Left+20)>(tank1.Left+60) then
    ammo[tipe].Left:=ammo[tipe].Left-10;

    if (ammo[tipe].top+20)<(tank1.top) then
      ammo[tipe].Top:=ammo[tipe].Top+10
    else if (ammo[tipe].top+20)>(tank1.top+60) then
      ammo[tipe].Top:=ammo[tipe].Top-10;
end;
end;
if tipe=0 then
serverbroadcast(serversocket1,total,'ammo'+inttostr(tipe)+inttostr(ammo[tipe].Left)+'!'+inttostr(ammo[tipe].top)+'&')
else
clientsocket1.Socket.SendText('ammo'+inttostr(tipe)+inttostr(ammo[tipe].Left)+'!'+inttostr(ammo[tipe].top)+'&');

if (ammo[tipe].Left+ammo[tipe].Width+xp>=form1.Width-20) or (ammo[tipe].Left<=0) or (ammo[tipe].top<=0) or (ammo[tipe].Top+ammo[tipe].Height>=form1.Height-40) then
begin
timer1.enabled:=false;
ammo[tipe].Transparent:=true;
ammo[tipe].Picture.LoadFromFile('boom.bmp');
shooting:=false;
kejar:=8;
end
else if papan[(ammo[tipe].Top+20) div 60,(ammo[tipe].Left+20) div 60].Hint<>'.' then
begin
timer1.enabled:=false;
ammo[tipe].Transparent:=true;
ammo[tipe].Picture.LoadFromFile('boom.bmp');
kejar:=8;
temp2:='kena'+papan[(ammo[tipe].Top+20) div 60,(ammo[tipe].Left+20) div 60].Hint+inttostr(tipe)+inttostr(ammo[tipe].Left)+'!'+inttostr(ammo[tipe].top)+'&';
if tipe=0 then
begin
serverbroadcast(serversocket1,total,temp2);
  if copy(temp2,5,1)='0' then
  lp1.Width:=lp1.Width-30

    else if copy(temp2,5,1)='1' then
    lp2.Width:=lp2.Width-30

    else if copy(temp2,5,1)='2' then
    lp3.Width:=lp3.Width-30

    else if copy(temp2,5,1)='3' then
    lp4.Width:=lp4.Width-30;
end
else
clientsocket1.Socket.SendText(temp2);
shooting:=false;
end;
end;

procedure TForm1.tank1Click(Sender: TObject);
begin
 if (tipe<>0) and (bnsammo=true) then
  begin
  bnsammo:=false;
if shooting=false then
begin
  if hadapan=1 then
  begin
    yp:=-10;
    xp:=0;
    if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left+10;
      ammo[tipe].Top:=tank2.Top-40;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left+10;
      ammo[tipe].Top:=tank3.Top-40;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left+10;
      ammo[tipe].Top:=tank4.Top-40;
    end;
  end
  else if hadapan=2 then
  begin
    yp:=0;
    xp:=10;
   if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left+tank2.Width;
      ammo[tipe].Top:=tank2.Top+10;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left+tank3.Width;
      ammo[tipe].Top:=tank3.Top+10;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left+tank4.Width;
      ammo[tipe].Top:=tank4.Top+10;
    end;
  end
  else if hadapan=3 then
  begin
    yp:=10;
    xp:=0;
   if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left+10;
      ammo[tipe].Top:=tank2.Top+tank2.Height;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left+10;
      ammo[tipe].Top:=tank3.Top+tank3.Height;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left+10;
      ammo[tipe].Top:=tank4.Top+tank4.Height;
    end;
  end
  else if hadapan=4 then
  begin
    yp:=0;
    xp:=-10;
    if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left-40;
      ammo[tipe].Top:=tank2.Top+10;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left-40;
      ammo[tipe].Top:=tank3.Top+10;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left-40;
      ammo[tipe].Top:=tank4.Top+10;
    end
  end;

ammo[tipe].Picture.LoadFromFile('peluru.bmp');
timer1.Interval:=50;
timer1.Enabled:=true;
shooting:=true;
kejar:=0;timer1.Enabled:=true;
end;
end;
end;

procedure TForm1.tank3Click(Sender: TObject);
begin
 if (tipe<>2) and (bnsammo=true) then
  begin
  bnsammo:=false;
  if shooting=false then
begin
  if hadapan=1 then
  begin
    yp:=-10;
    xp:=0;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left+10;
      ammo[tipe].Top:=tank1.Top-40;
    end
    else if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left+10;
      ammo[tipe].Top:=tank2.Top-40;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left+10;
      ammo[tipe].Top:=tank4.Top-40;
    end;
  end
  else if hadapan=2 then
  begin
    yp:=0;
    xp:=10;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left+tank1.Width;
      ammo[tipe].Top:=tank1.Top+10;
    end
    else if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left+tank2.Width;
      ammo[tipe].Top:=tank2.Top+10;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left+tank4.Width;
      ammo[tipe].Top:=tank4.Top+10;
    end;
  end
  else if hadapan=3 then
  begin
    yp:=10;
    xp:=0;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left+10;
      ammo[tipe].Top:=tank1.Top+tank1.Height;
    end
    else if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left+10;
      ammo[tipe].Top:=tank2.Top+tank2.Height;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left+10;
      ammo[tipe].Top:=tank4.Top+tank4.Height;
    end;
  end
  else if hadapan=4 then
  begin
    yp:=0;
    xp:=-10;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left-40;
      ammo[tipe].Top:=tank1.Top+10;
    end
    else if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left-40;
      ammo[tipe].Top:=tank2.Top+10;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left-40;
      ammo[tipe].Top:=tank4.Top+10;
    end
  end;

ammo[tipe].Picture.LoadFromFile('peluru.bmp');
timer1.Interval:=50;
timer1.Enabled:=true;
shooting:=true;
kejar:=2;timer1.Enabled:=true;
end;
end;
end;

procedure TForm1.tank4Click(Sender: TObject);
begin
 if (tipe<>3) and (bnsammo=true) then
  begin
  bnsammo:=false;
  if shooting=false then
begin
  if hadapan=1 then
  begin
    yp:=-10;
    xp:=0;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left+10;
      ammo[tipe].Top:=tank1.Top-40;
    end
    else if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left+10;
      ammo[tipe].Top:=tank2.Top-40;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left+10;
      ammo[tipe].Top:=tank3.Top-40;
    end;
  end
  else if hadapan=2 then
  begin
    yp:=0;
    xp:=10;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left+tank1.Width;
      ammo[tipe].Top:=tank1.Top+10;
    end
    else if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left+tank2.Width;
      ammo[tipe].Top:=tank2.Top+10;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left+tank3.Width;
      ammo[tipe].Top:=tank3.Top+10;
    end;
  end
  else if hadapan=3 then
  begin
    yp:=10;
    xp:=0;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left+10;
      ammo[tipe].Top:=tank1.Top+tank1.Height;
    end
    else if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left+10;
      ammo[tipe].Top:=tank2.Top+tank2.Height;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left+10;
      ammo[tipe].Top:=tank3.Top+tank3.Height;
    end;
  end
  else if hadapan=4 then
  begin
    yp:=0;
    xp:=-10;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left-40;
      ammo[tipe].Top:=tank1.Top+10;
    end
    else if tipe=1 then
    begin
      ammo[tipe].Left:=tank2.Left-40;
      ammo[tipe].Top:=tank2.Top+10;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left-40;
      ammo[tipe].Top:=tank3.Top+10;
    end
  end;

ammo[tipe].Picture.LoadFromFile('peluru.bmp');
timer1.Interval:=50;
timer1.Enabled:=true;
shooting:=true;
kejar:=3;timer1.Enabled:=true;
end;
end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
clientsocket1.Port:=2000;
clientsocket1.Address:=edit1.Text;
clientsocket1.Open;
edit1.Hide;
edit1.Enabled:=false;
button1.Enabled:=false;
button2.Enabled:=false;
button3.Enabled:=false;
button1.Hide;
button2.Hide;
button3.Hide;
AITimer.Interval:=50;
AItimer.Enabled:=true;
AIPlay:=true;
end;

procedure TForm1.AITimerTimer(Sender: TObject);
var moveSucc:boolean;i:integer;
begin
moveSucc:=false;
if hadapan=1 then
begin
if tipe=0 then
  begin
  if (tank1.Top-2>0) and(papan[(tank1.Top-2) div 60,(tank1.Left+15)div 60].hint<>'w') and (papan[(tank1.Top-2) div 60,(tank1.Left+tank1.Width-15)div 60].hint<>'w') then
  begin
  papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].Hint:='.';
  papan[(tank1.Top+30-2) div 60,(tank1.Left+30)div 60].Hint:='0';
  tank1.Picture.LoadFromFile('tank1-1.bmp');
  tank1.Top:=tank1.Top-2;
  serverbroadcast(serversocket1,total,'POS11'+inttostr(tank1.left)+'!'+inttostr(tank1.top)+'&');
  moveSucc:=true;
  end;
  end
  else if tipe=1 then
  begin
  if (tank2.Top-2>0) and(papan[(tank2.Top-1) div 60,(tank2.Left+15)div 60].hint<>'w') and (papan[(tank2.Top-1) div 60,(tank2.Left+tank2.Width-15)div 60].hint<>'w') then
  begin
  if papan[(tank2.Top-2) div 60,(tank2.Left+30)div 60].Hint='h' then
    begin
    lp2.Width:=lp2.Width+150;
    clientsocket1.Socket.SendText('addlp2');
    papan[(tank2.Top-2) div 60,(tank2.Left+30)div 60].Hint:='.';
    end;
  for i:=1 to 5 do
  begin
	if (shooting=false) and (((tank2.Top div 60)-i)>=0) and (papan[((tank2.Top) div 60)-i,(tank2.Left+15)div 60].hint<>'w') and (papan[((tank2.Top) div 60)-i,(tank2.Left+15)div 60].hint<>'.') and (papan[((tank2.Top) div 60)-i,(tank2.Left+15)div 60].hint<>'h') and (papan[((tank2.Top) div 60)-i,(tank2.Left+15)div 60].hint<>'b') then
		begin
      tank2.Picture.LoadFromFile('tank2-1.bmp');
			yp:=-10;
			xp:=0;
			ammo[tipe].Left:=tank2.Left+10;
			ammo[tipe].Top:=tank2.Top-40;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
		end;
  end;
  if shooting=false then
  begin
  papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].Hint:='.';
  papan[(tank2.Top+30-2) div 60,(tank2.Left+30)div 60].hint:=inttostr(tipe);
  tank2.Picture.LoadFromFile('tank2-1.bmp');
  tank2.Top:=tank2.Top-2;
  clientsocket1.Socket.SendText('POS21'+inttostr(tank2.left)+'!'+inttostr(tank2.top)+'&');
  end;moveSucc:=true;
  end;
  end
  else if tipe=2 then
  begin
    if (tank3.Top-2>0) and(papan[(tank3.Top-1) div 60,(tank3.Left+15)div 60].hint<>'w') and (papan[(tank3.Top-1) div 60,(tank3.Left+15)div 60].hint<>'w') then
  begin
   if papan[(tank3.Top-2) div 60,(tank3.Left+30)div 60].Hint='h' then
    begin
    lp3.Width:=lp3.Width+150;
    clientsocket1.Socket.SendText('addlp3');
    papan[(tank3.Top-2) div 60,(tank3.Left+30)div 60].Hint:='.';
    end;
    for i:=1 to 5 do
  begin
	if (shooting=false) and (((tank3.Top+15 div 60)-i)>=0) and (papan[((tank3.Top+15) div 60)-i,(tank3.Left+15)div 60].hint<>'h') and (papan[((tank3.Top+15) div 60)-i,(tank3.Left+15)div 60].hint<>'b') and (papan[((tank3.Top+15) div 60)-i,(tank3.Left+15)div 60].hint<>'w') and (papan[((tank3.Top+15) div 60)-i,(tank3.Left+tank3.Width-15)div 60].hint<>'.') then
		begin
    tank3.Picture.LoadFromFile('tank3-1.bmp');
			yp:=-10;
			xp:=0;
			ammo[tipe].Left:=tank3.Left+10;
			ammo[tipe].Top:=tank3.Top-40;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
		end;
  end;
  if shooting=false then
  begin
  papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].Hint:='.';
  papan[(tank3.Top+30-2) div 60,(tank3.Left+30)div 60].Hint:='2';
  tank3.Picture.LoadFromFile('tank3-1.bmp');
  tank3.Top:=tank3.Top-2;
    clientsocket1.Socket.SendText('POS31'+inttostr(tank3.left)+'!'+inttostr(tank3.top)+'&');
  end;moveSucc:=true;
  end;
  end
  else if tipe=3 then
  begin
    if (tank4.Top-2>0) and(papan[(tank4.Top-1) div 60,(tank4.Left+15)div 60].hint<>'w') and (papan[(tank4.Top-1) div 60,(tank4.Left+tank4.Width-15)div 60].hint<>'w') then
  begin
  	if papan[(tank4.Top-2) div 60,(tank4.Left+30)div 60].Hint='h' then
    begin
    lp4.Width:=lp4.Width+150;
    clientsocket1.Socket.SendText('addlp4');
    papan[(tank4.Top-2) div 60,(tank4.Left+30)div 60].Hint:='.';
    end;
    for i:=1 to 5 do
    begin
    if (shooting=false) and (((tank4.Top+15 div 60)-i)>=0) and (papan[((tank4.Top+15) div 60)-i,(tank4.Left+15)div 60].hint<>'h') and (papan[((tank4.Top+15) div 60)-i,(tank4.Left+15)div 60].hint<>'w') and (papan[((tank4.Top+15) div 60)-i,(tank4.Left+15)div 60].hint<>'b') and (papan[((tank4.Top+15) div 60)-i,(tank4.Left+15)div 60].hint<>'.') then
		begin
    tank4.Picture.LoadFromFile('tank4-1.bmp');
			yp:=-10;
			xp:=0;
			ammo[tipe].Left:=tank4.Left+10;
			ammo[tipe].Top:=tank4.Top-40;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
		end;
  end;
   if shooting=false then
  begin
  papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].Hint:='.';
  papan[(tank4.Top+30-2) div 60,(tank4.Left+30)div 60].Hint:='3';
  tank4.Picture.LoadFromFile('tank4-1.bmp');
  tank4.Top:=tank4.Top-2;
  clientsocket1.Socket.SendText('POS41'+inttostr(tank4.left)+'!'+inttostr(tank4.top)+'&');
   end;moveSucc:=true;
  end;
  end;
end


else if hadapan=3 then
begin
if tipe=0 then
  begin
   if (tank1.Top+tank1.Height+2<form1.Height-40) and(papan[(tank1.Top+tank1.height+1) div 60,(tank1.Left+15)div 60].hint<>'w') and (papan[(tank1.Top+tank1.Height+1) div 60,(tank1.Left+tank1.Width-15)div 60].hint<>'w') then
  begin
  papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].Hint:='.';
  papan[(tank1.Top+30+2) div 60,(tank1.Left+30)div 60].Hint:='0';
  tank1.Picture.LoadFromFile('tank1-3.bmp');
  tank1.Top:=tank1.Top+2;
  serverbroadcast(serversocket1,total,'POS13'+inttostr(tank1.left)+'!'+inttostr(tank1.top)+'&');
  moveSucc:=true;
  end;
  end
  else if tipe=1 then
  begin
  if (tank2.Top+tank2.Height+2<form1.Height-40) and(papan[(tank2.Top+tank2.height+1) div 60,(tank2.Left+15)div 60].hint<>'w') and (papan[(tank2.Top+tank2.Height+1) div 60,(tank2.Left+tank2.Width-15)div 60].hint<>'w') then
  begin
  if papan[(tank2.Top+60+2) div 60,(tank2.Left+30)div 60].Hint='h' then
    begin
    lp2.Width:=lp2.Width+150;
    clientsocket1.Socket.SendText('addlp2');
    papan[(tank2.Top+60+2) div 60,(tank2.Left+30)div 60].Hint:='.';
    end;
  for i:=1 to 5 do
  begin
	if (shooting=false) and ((((tank2.Top+tank2.Height) div 60)+i)<10) and (papan[((tank2.Top+tank2.Height) div 60)+i,(tank2.Left+15)div 60].hint<>'w') and (papan[((tank2.Top+tank2.Height) div 60)+i,(tank2.Left+15)div 60].hint<>'h') and (papan[((tank2.Top+tank2.Height) div 60)+i,(tank2.Left+15)div 60].hint<>'b') and (papan[((tank2.Top+tank2.Height) div 60)+i,(tank2.Left+15)div 60].hint<>'.') then
		begin
    tank2.Picture.LoadFromFile('tank2-3.bmp');
			yp:=10;
			xp:=0;
			ammo[tipe].Left:=tank2.Left+10;
			ammo[tipe].Top:=tank2.Top+60;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
		end;
  end;
  if shooting=false then
   begin
   papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].Hint:='.';
  papan[(tank2.Top+30+2) div 60,(tank2.Left+30)div 60].hint:=inttostr(tipe);
  tank2.Picture.LoadFromFile('tank2-3.bmp');
  tank2.Top:=tank2.Top+2;
  clientsocket1.Socket.SendText('POS23'+inttostr(tank2.left)+'!'+inttostr(tank2.top)+'&');
	end;moveSucc:=true;
  end;
  end
  else if tipe=2 then
  begin
  if (tank3.Top+tank3.Height+2<form1.Height-40) and(papan[(tank3.Top+tank3.height+1) div 60,(tank3.Left+15)div 60].hint<>'w') and (papan[(tank3.Top+tank3.Height+1) div 60,(tank3.Left+tank3.Width-15)div 60].hint<>'w') then
  begin
   if papan[(tank3.Top+60+2) div 60,(tank3.Left+30)div 60].Hint='h' then
    begin
    lp3.Width:=lp3.Width+150;
    clientsocket1.Socket.SendText('addlp3');
    papan[(tank3.Top+60+2) div 60,(tank3.Left+30)div 60].Hint:='.';
    end;
    for i:=1 to 5 do
  begin
	if (shooting=false) and (((tank3.Top+15 div 60)+i)<11) and (papan[((tank3.Top+15) div 60)+i,(tank3.Left+15)div 60].hint<>'h') and (papan[((tank3.Top+15) div 60)+i,(tank3.Left+15)div 60].hint<>'w') and (papan[((tank3.Top+15) div 60)+i,(tank3.Left+15)div 60].hint<>'b') and (papan[((tank3.Top+15) div 60)+i,(tank3.Left+tank3.Width-15)div 60].hint<>'.') then
		begin
    tank3.Picture.LoadFromFile('tank3-3.bmp');
			yp:=10;
			xp:=0;
			ammo[tipe].Left:=tank3.Left+10;
			ammo[tipe].Top:=tank3.Top+60;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
		end;
  end;
  if shooting=false then
  begin
   papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].Hint:='.';
  papan[(tank3.Top+30+2) div 60,(tank3.Left+30)div 60].Hint:='2';
  tank3.Picture.LoadFromFile('tank3-3.bmp');
  tank3.Top:=tank3.Top+2;
    clientsocket1.Socket.SendText('POS33'+inttostr(tank3.left)+'!'+inttostr(tank3.top)+'&');
  end;moveSucc:=true;
  end;
  end
  else if tipe=3 then
  begin
  if (tank4.Top+tank4.Height+2<form1.Height-40) and(papan[(tank4.Top+tank4.height+1) div 60,(tank4.Left+15)div 60].hint<>'w') and (papan[(tank4.Top+tank4.Height+1) div 60,(tank4.Left+tank4.Width-15)div 60].hint<>'w') then
  begin
    if papan[(tank4.Top+60+2) div 60,(tank4.Left+30)div 60].Hint='h' then
    begin
    lp4.Width:=lp4.Width+150;
    clientsocket1.Socket.SendText('addlp4');
    papan[(tank4.Top+60+2) div 60,(tank4.Left+30)div 60].Hint:='.';
    end;
    for i:=1 to 5 do
  begin
	if (shooting=false) and (((tank4.Top+15 div 60)+i)<11) and (papan[((tank4.Top+15) div 60)+i,(tank4.Left+15)div 60].hint<>'h') and (papan[((tank4.Top+15) div 60)+i,(tank4.Left+15)div 60].hint<>'w') and (papan[((tank4.Top+15) div 60)+i,(tank4.Left+tank4.Width-15)div 60].hint<>'b') and (papan[((tank4.Top+15) div 60)+i,(tank4.Left+tank4.Width-15)div 60].hint<>'.') then
		begin
    tank4.Picture.LoadFromFile('tank4-3.bmp');
			yp:=10;
			xp:=0;
			ammo[tipe].Left:=tank4.Left+10;
			ammo[tipe].Top:=tank4.Top+60;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
		end;
  end;
  if shooting=false then
  begin
   papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].Hint:='.';
  papan[(tank4.Top+30+2) div 60,(tank4.Left+30)div 60].Hint:='3';
  tank4.Picture.LoadFromFile('tank4-3.bmp');
  tank4.Top:=tank4.Top+2;
  clientsocket1.Socket.SendText('POS43'+inttostr(tank4.left)+'!'+inttostr(tank4.top)+'&');
  end;moveSucc:=true;
  end;
  end;
end


else if hadapan=4 then
begin
if tipe=0 then
  begin
  if (tank1.left-2>0) and(papan[(tank1.Top+tank1.height-15) div 60,(tank1.Left-1)div 60].hint<>'w') and (papan[(tank1.Top+15) div 60,(tank1.Left-1)div 60].hint<>'w') then
  begin
   papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].Hint:='.';
  papan[(tank1.Top+30) div 60,(tank1.Left+30-2)div 60].Hint:='0';
  tank1.Picture.LoadFromFile('tank1-4.bmp');
  tank1.Left:=tank1.Left-2;
  serverbroadcast(serversocket1,total,'POS14'+inttostr(tank1.left)+'!'+inttostr(tank1.top)+'&');
  moveSucc:=true;
  end;
  end
  else if tipe=1 then
  begin
  if (tank2.left-2>0) and(papan[(tank2.Top+tank2.height-15) div 60,(tank2.Left-2)div 60].hint<>'w') and (papan[(tank2.Top+15) div 60,(tank2.Left-2)div 60].hint<>'w') then
  begin
  if papan[(tank2.Top+30) div 60,(tank2.Left-2)div 60].Hint='h' then
    begin
    lp2.Width:=lp2.Width+150;
    clientsocket1.Socket.SendText('addlp2');
    papan[(tank2.Top+30) div 60,(tank2.Left-2)div 60].Hint:='.';
    end;
    for i:=1 to 5 do
  begin
	if (shooting=false) and (((tank2.left div 60)-i)>=0) and (papan[((tank2.Top+15) div 60),((tank2.Left div 60)-i)].hint<>'h') and (papan[((tank2.Top+15) div 60),((tank2.Left div 60)-i)].hint<>'w') and (papan[((tank2.Top+15) div 60),((tank2.Left div 60)-i)].hint<>'b') and (papan[((tank2.Top+15) div 60),((tank2.Left)div 60)-i].hint<>'.') then
		begin
    tank2.Picture.LoadFromFile('tank2-4.bmp');
			yp:=0;
			xp:=-10;
			ammo[tipe].Left:=tank2.Left;
			ammo[tipe].Top:=tank2.Top+10;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
		end;
  end;
  if shooting=false then
  begin
  papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].Hint:='.';
  papan[(tank2.Top+30) div 60,(tank2.Left+30-2)div 60].hint:=inttostr(tipe);
  tank2.Picture.LoadFromFile('tank2-4.bmp');
  tank2.Left:=tank2.Left-2;
  clientsocket1.Socket.SendText('POS24'+inttostr(tank2.left)+'!'+inttostr(tank2.top)+'&');
  end;moveSucc:=true;
  end;
  end
  else if tipe=2 then
  begin
  if (tank3.left-2>0) and(papan[(tank3.Top+tank3.height-15) div 60,(tank3.Left-1)div 60].hint<>'w') and (papan[(tank3.Top+15) div 60,(tank3.Left-1)div 60].hint<>'w') then
  begin
  if papan[(tank3.Top+30) div 60,(tank3.Left-2)div 60].Hint='h' then
    begin
    lp3.Width:=lp3.Width+150;
    clientsocket1.Socket.SendText('addlp3');
    papan[(tank3.Top+30) div 60,(tank3.Left-2)div 60].Hint:='.';
    end;
   for i:=1 to 5 do
  begin
	if (shooting=false) and (((tank3.left div 60)-i)>=0) and (papan[((tank3.Top+15) div 60),((tank3.Left div 60)-i)].hint<>'h') and (papan[((tank3.Top+15) div 60),((tank3.Left div 60)-i)].hint<>'w') and (papan[((tank3.Top+15) div 60),((tank3.Left)div 60)-i].hint<>'.') and (papan[((tank3.Top+15) div 60),((tank3.Left)div 60)-i].hint<>'b') then
  	begin
    tank3.Picture.LoadFromFile('tank3-4.bmp');
			yp:=0;
			xp:=-10;
			ammo[tipe].Left:=tank3.Left;
			ammo[tipe].Top:=tank3.Top+10;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
		end;
  end;
  if shooting=false then
  begin
  papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].Hint:='.';
  papan[(tank3.Top+30) div 60,(tank3.Left+30-2)div 60].Hint:='2';
  tank3.Picture.LoadFromFile('tank3-4.bmp');
  tank3.Left:=tank3.Left-2;
  clientsocket1.Socket.SendText('POS34'+inttostr(tank3.left)+'!'+inttostr(tank3.top)+'&');
  end;moveSucc:=true;
  end;
  end
  else if tipe=3 then
  begin
  if (tank4.left-2>0) and(papan[(tank3.Top+tank3.height-15) div 60,(tank3.Left-1)div 60].hint<>'w') and (papan[(tank3.Top+15) div 60,(tank3.Left-1)div 60].hint<>'w') then
  begin
  if papan[(tank4.Top+30) div 60,(tank4.Left-2)div 60].Hint='h' then
    begin
    lp4.Width:=lp4.Width+150;
    clientsocket1.Socket.SendText('addlp4');
    papan[(tank4.Top+30) div 60,(tank4.Left-2)div 60].Hint:='.';
    end;
   for i:=1 to 5 do
  begin
	if (shooting=false) and (((tank4.left div 60)-i)>=0) and (papan[((tank4.Top+15) div 60),((tank4.Left div 60)-i)].hint<>'w') and (papan[((tank4.Top+15) div 60),((tank4.Left div 60)-i)].hint<>'h') and (papan[((tank4.Top+15) div 60),((tank4.Left)div 60)-i].hint<>'.')  and (papan[((tank3.Top+15) div 60),((tank3.Left)div 60)-i].hint<>'b') then
  	begin
    tank4.Picture.LoadFromFile('tank4-4.bmp');
			yp:=0;
			xp:=-10;
			ammo[tipe].Left:=tank4.Left;
			ammo[tipe].Top:=tank4.Top+10;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
		end;
  end;
  if shooting=false then
  begin
  papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].Hint:='.';
  papan[(tank4.Top+30) div 60,(tank4.Left+30-2)div 60].Hint:='3';
  tank4.Picture.LoadFromFile('tank4-4.bmp');
  tank4.left:=tank4.Left-2;
    clientsocket1.Socket.SendText('POS44'+inttostr(tank4.left)+'!'+inttostr(tank4.top)+'&');
  end;moveSucc:=true;
  end;
  end;
end

else if hadapan=2 then
begin
if tipe=0 then
  begin
  if (tank1.left+tank1.Width+2<form1.Width-20) and(papan[(tank1.Top+45) div 60,(tank1.Left+tank1.Width+1)div 60].hint<>'w') and (papan[(tank1.Top+15) div 60,(tank1.Left+tank1.Width+1)div 60].hint<>'w') then
  begin
  papan[(tank1.Top+30) div 60,(tank1.Left+30)div 60].Hint:='.';
  papan[(tank1.Top+30) div 60,(tank1.Left+30+2)div 60].Hint:='0';
  tank1.Picture.LoadFromFile('tank1-2.bmp');
  tank1.Left:=tank1.Left+2;
  serverbroadcast(serversocket1,total,'POS12'+inttostr(tank1.left)+'!'+inttostr(tank1.top)+'&');
  moveSucc:=true;
  end;
  end
  else if tipe=1 then
  begin
  if (tank2.left+tank2.Width+2<form1.Width-20)and(papan[(tank2.Top+45) div 60,(tank2.Left+tank2.Width+1)div 60].hint<>'w') and (papan[(tank2.Top+15) div 60,(tank2.Left+tank2.Width+1)div 60].hint<>'w') then
  begin
  if papan[(tank2.Top+30) div 60,(tank2.Left+60+2)div 60].Hint='h' then
    begin
    lp2.Width:=lp2.Width+150;
    clientsocket1.Socket.SendText('addlp2');
    papan[(tank2.Top+30) div 60,(tank2.Left+60+2)div 60].Hint:='.';
    end;
   for i:=1 to 5 do
  begin
	if (shooting=false) and ((((tank2.left+tank2.width) div 60)+i)<15) and (papan[((tank2.Top+15) div 60),((tank2.Left+tank2.Width)div 60)+i].hint<>'h') and (papan[((tank2.Top+15) div 60),((tank2.Left+tank2.Width)div 60)+i].hint<>'w') and (papan[((tank2.Top+15) div 60),((tank2.Left+tank2.Width)div 60)+i].hint<>'b') and (papan[((tank2.Top+15) div 60),((tank2.Left+tank2.Width)div 60)+i].hint<>'.') then
		begin
    tank2.Picture.LoadFromFile('tank2-2.bmp');
      yp:=0;
			xp:=10;
			ammo[tipe].Left:=tank2.Left+tank2.Width;
			ammo[tipe].Top:=tank2.Top+10;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
    end;
    end;
  if shooting=false then
  begin
  papan[(tank2.Top+30) div 60,(tank2.Left+30)div 60].Hint:='.';
  papan[(tank2.Top+30) div 60,(tank2.Left+30+2)div 60].hint:=inttostr(tipe);
  tank2.Picture.LoadFromFile('tank2-2.bmp');
  tank2.Left:=tank2.Left+2;
  clientsocket1.Socket.SendText('POS22'+inttostr(tank2.left)+'!'+inttostr(tank2.top)+'&');
  end;moveSucc:=true;
  end;
  end
  else if tipe=2 then
  begin
  if (tank3.left+tank3.Width+2<form1.Width-20)and(papan[(tank3.Top+45) div 60,(tank3.Left+tank3.Width+1)div 60].hint<>'w') and (papan[(tank3.Top+15) div 60,(tank3.Left+tank3.Width+1)div 60].hint<>'w') then
  begin
  if papan[(tank3.Top+30) div 60,(tank3.Left+60+2)div 60].Hint='h' then
    begin
    lp3.Width:=lp3.Width+150;
    clientsocket1.Socket.SendText('addlp3');
    papan[(tank3.Top+30) div 60,(tank3.Left+60+2)div 60].Hint:='.';
    end;
     for i:=1 to 5 do
  begin
	if (shooting=false) and ((((tank3.left+tank3.width) div 60)+i)<15) and (papan[((tank3.Top+15) div 60),((tank3.Left+tank3.Width)div 60)+i].hint<>'h') and (papan[((tank3.Top+15) div 60),((tank3.Left+tank3.Width)div 60)+i].hint<>'w') and (papan[((tank3.Top+15) div 60),((tank3.Left+tank3.Width)div 60)+i].hint<>'b') and (papan[((tank3.Top+15) div 60),((tank3.Left+tank3.Width)div 60)+i].hint<>'.') then
		begin
    tank3.Picture.LoadFromFile('tank3-2.bmp');
      yp:=0;
			xp:=10;
			ammo[tipe].Left:=tank3.Left+tank3.Width;
			ammo[tipe].Top:=tank3.Top+10;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
    end;
    end;
  if shooting=false then
  begin
  papan[(tank3.Top+30) div 60,(tank3.Left+30)div 60].Hint:='.';
  papan[(tank3.Top+30) div 60,(tank3.Left+30+2)div 60].Hint:='2';
  tank3.Picture.LoadFromFile('tank3-2.bmp');
  tank3.Left:=tank3.Left+2;
  clientsocket1.Socket.SendText('POS32'+inttostr(tank3.left)+'!'+inttostr(tank3.top)+'&');
  end;moveSucc:=true;
  end;
  end
  else if tipe=3 then
  begin
  if (tank4.left+tank4.Width+2<form1.Width-20)and(papan[(tank4.Top+45) div 60,(tank4.Left+tank4.Width+1)div 60].hint<>'w') and (papan[(tank4.Top+15) div 60,(tank4.Left+tank4.Width+1)div 60].hint<>'w') then
  begin
  if papan[(tank4.Top+30) div 60,(tank4.Left+60+2)div 60].Hint='h' then
    begin
    lp4.Width:=lp4.Width+150;
    clientsocket1.Socket.SendText('addlp4');
    papan[(tank4.Top+30) div 60,(tank4.Left+60+2)div 60].Hint:='.';
    end;
     for i:=1 to 5 do
  begin
	if (shooting=false) and ((((tank4.left+tank4.width) div 60)+i)<15) and (papan[((tank4.Top+15) div 60),((tank4.Left+tank4.Width)div 60)+i].hint<>'h') and (papan[((tank4.Top+15) div 60),((tank4.Left+tank4.Width)div 60)+i].hint<>'w') and (papan[((tank4.Top+15) div 60),((tank4.Left+tank4.Width)div 60)+i].hint<>'b') and (papan[((tank4.Top+15) div 60),((tank4.Left+tank4.Width)div 60)+i].hint<>'.') then
		begin
    tank4.Picture.LoadFromFile('tank4-2.bmp');
      yp:=0;
			xp:=10;
			ammo[tipe].Left:=tank4.Left+tank4.Width;
			ammo[tipe].Top:=tank4.Top+10;
      ammo[tipe].Picture.LoadFromFile('peluru.bmp');
      timer1.Interval:=50;
      timer1.Enabled:=true;
      shooting:=true;
    end;
    end;
  if shooting=false then
  begin
  papan[(tank4.Top+30) div 60,(tank4.Left+30)div 60].Hint:='.';
  papan[(tank4.Top+30) div 60,(tank4.Left+30+2)div 60].Hint:='3';
  tank4.Picture.LoadFromFile('tank4-2.bmp');
  tank4.left:=tank4.Left+2;
  clientsocket1.Socket.SendText('POS42'+inttostr(tank4.left)+'!'+inttostr(tank4.top)+'&');
  end;moveSucc:=true;
  end;
  end;
 end;

 for i:=1 to 14 do
 begin
 if tipe=1 then
 begin
  	if (shooting=false) and (((tank2.Top div 60)-i)>=0) and (papan[((tank2.Top) div 60)-1,(tank2.Left+15)div 60].hint<>'w') and (papan[((tank2.Top) div 60)-i,(tank2.Left+15)div 60].hint<>'w') and (papan[((tank2.Top) div 60)-i,(tank2.Left+15)div 60].hint<>'.') then
    begin
    hadapan:=1;
    tank2.Picture.LoadFromFile('tank2-1.bmp');
    end
    else 	if (shooting=false) and ((((tank2.Top+tank2.Height) div 60)+i)<10) and (papan[((tank2.Top+tank2.Height) div 60)+1,(tank2.Left+15)div 60].hint<>'w') and (papan[((tank2.Top+tank2.Height) div 60)+i,(tank2.Left+15)div 60].hint<>'w') and (papan[((tank2.Top+tank2.Height) div 60)+i,(tank2.Left+15)div 60].hint<>'.') then
    begin
    hadapan:=3;
     tank2.Picture.LoadFromFile('tank2-3.bmp');
     end
    else 	if (shooting=false) and (((tank2.left div 60)-i)>=0) and (papan[((tank2.Top+15) div 60),((tank2.Left div 60)-1)].hint<>'w') and (papan[((tank2.Top+15) div 60),((tank2.Left div 60)-i)].hint<>'w') and (papan[((tank2.Top+15) div 60),((tank2.Left)div 60)-i].hint<>'.') then
    begin
    hadapan:=4;
    tank2.Picture.LoadFromFile('tank2-4.bmp');
    end
    else if (shooting=false) and ((((tank2.left+tank2.width) div 60)+i)<15) and (papan[((tank2.Top+15) div 60),((tank2.Left+tank2.Width)div 60)+1].hint<>'w') and (papan[((tank2.Top+15) div 60),((tank2.Left+tank2.Width)div 60)+i].hint<>'w') and (papan[((tank2.Top+15) div 60),((tank2.Left+tank2.Width)div 60)+i].hint<>'.') then
    begin
    hadapan:=2;
    tank2.Picture.LoadFromFile('tank2-2.bmp');
    end;
 end
 else  if tipe=2 then
 begin
  	if (shooting=false) and (((tank3.Top div 60)-i)>=0) and (papan[((tank3.Top) div 60)-1,(tank3.Left+15)div 60].hint<>'w') and (papan[((tank3.Top) div 60)-i,(tank3.Left+15)div 60].hint<>'w') and (papan[((tank3.Top) div 60)-i,(tank3.Left+15)div 60].hint<>'.') then
    begin
    hadapan:=1;
    tank3.Picture.LoadFromFile('tank3-1.bmp');
    end
    else 	if (shooting=false) and ((((tank3.Top+tank3.Height) div 60)+i)<10) and (papan[((tank3.Top+tank3.Height) div 60)+1,(tank3.Left+15)div 60].hint<>'w') and (papan[((tank3.Top+tank3.Height) div 60)+i,(tank3.Left+15)div 60].hint<>'w') and (papan[((tank3.Top+tank3.Height) div 60)+i,(tank3.Left+15)div 60].hint<>'.') then
    begin
    hadapan:=3;
     tank3.Picture.LoadFromFile('tank3-3.bmp');
     end
    else 	if (shooting=false) and (((tank3.left div 60)-i)>=0) and (papan[((tank3.Top+15) div 60),((tank3.Left div 60)-i)].hint<>'w') and (papan[((tank3.Top+15) div 60),((tank3.Left div 60)-1)].hint<>'w') and (papan[((tank3.Top+15) div 60),((tank3.Left)div 60)-i].hint<>'.') then
    begin
    hadapan:=4;
    tank3.Picture.LoadFromFile('tank3-4.bmp');
    end
    else if (shooting=false) and ((((tank3.left+tank3.width) div 60)+i)<15) and (papan[((tank3.Top+15) div 60),((tank3.Left+tank3.Width)div 60)+1].hint<>'w') and (papan[((tank3.Top+15) div 60),((tank3.Left+tank3.Width)div 60)+i].hint<>'w') and (papan[((tank3.Top+15) div 60),((tank3.Left+tank3.Width)div 60)+i].hint<>'.') then
    begin
    hadapan:=2;
    tank3.Picture.LoadFromFile('tank3-2.bmp');
    end;
 end
 else  if tipe=3 then
 begin
  	if (shooting=false) and (((tank4.Top div 60)-i)>=0) and (papan[((tank4.Top) div 60)-1,(tank4.Left+15)div 60].hint<>'w') and (papan[((tank4.Top) div 60)-i,(tank4.Left+15)div 60].hint<>'w') and (papan[((tank4.Top) div 60)-i,(tank4.Left+15)div 60].hint<>'.') then
    begin
    hadapan:=1;
    tank4.Picture.LoadFromFile('tank4-1.bmp');
    end
    else 	if (shooting=false) and ((((tank4.Top+tank4.Height) div 60)+i)<10) and (papan[((tank4.Top+tank4.Height) div 60)+1,(tank4.Left+15)div 60].hint<>'w') and (papan[((tank4.Top+tank4.Height) div 60)+i,(tank4.Left+15)div 60].hint<>'w') and (papan[((tank4.Top+tank4.Height) div 60)+i,(tank4.Left+15)div 60].hint<>'.') then
    begin
    hadapan:=3;
     tank4.Picture.LoadFromFile('tank4-3.bmp');
     end
    else 	if (shooting=false) and (((tank4.left div 60)-i)>=0) and (papan[((tank4.Top+15) div 60),((tank4.Left div 60)-1)].hint<>'w') and (papan[((tank4.Top+15) div 60),((tank4.Left div 60)-i)].hint<>'w') and (papan[((tank4.Top+15) div 60),((tank4.Left)div 60)-i].hint<>'.') then
    begin
    hadapan:=4;
    tank4.Picture.LoadFromFile('tank4-4.bmp');
    end
    else if (shooting=false) and ((((tank4.left+tank4.width) div 60)+i)<15) and (papan[((tank4.Top+15) div 60),((tank4.Left+tank4.Width)div 60)+1].hint<>'w') and (papan[((tank4.Top+15) div 60),((tank4.Left+tank4.Width)div 60)+i].hint<>'w') and (papan[((tank4.Top+15) div 60),((tank4.Left+tank4.Width)div 60)+i].hint<>'.') then
    begin
    hadapan:=2;
    tank4.Picture.LoadFromFile('tank4-2.bmp');
    end;
 end;
 end;


 if (moveSucc=false) or (random(100)<1) then
 randomHadapan();

end;



procedure TForm1.BonusTimer(Sender: TObject);
begin
  wktbonus:=wktbonus+1;
if wktbonus mod 60=1 then
begin
    randomize();
    xb:=random(15);
    yb:=random(10);
    while (papan[yb,xb].Hint='w') do
      begin
          randomize();
          xb:=random(15);
          yb:=random(10);
      end;
      special.Visible:=true;
    special.Left:=xb*60;
    special.Top:=yb*60;
    special.Picture.LoadFromFile('bonus.bmp');
    special.BringToFront;
    papan[yb,xb].Hint:='b';
    serverbroadcast(serversocket1,total,'bonus'+inttostr(xb)+'!'+inttostr(yb)+'&');
end
else if (wktbonus mod 60>1) and  (wktbonus mod 60 <=40) then
  begin
 serverbroadcast(serversocket1,total,'bonus'+inttostr(xb)+'!'+inttostr(yb)+'&');
 end
else if wktbonus mod 60 > 40 then
begin
  special.Hide;
  papan[yb,xb].Hint:='.';
  serverbroadcast(serversocket1,total,'bonusdel&');
end;
end;

procedure TForm1.tank2Click(Sender: TObject);
begin
  if (tipe<>1) and (bnsammo=true) then
  begin
  bnsammo:=false;
if hadapan=1 then
  begin
    yp:=-10;
    xp:=0;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left+10;
      ammo[tipe].Top:=tank1.Top-40;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left+10;
      ammo[tipe].Top:=tank3.Top-40;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left+10;
      ammo[tipe].Top:=tank4.Top-40;
    end;
  end
  else if hadapan=2 then
  begin
    yp:=0;
    xp:=10;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left+tank1.Width;
      ammo[tipe].Top:=tank1.Top+10;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left+tank3.Width;
      ammo[tipe].Top:=tank3.Top+10;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left+tank4.Width;
      ammo[tipe].Top:=tank4.Top+10;
    end;
  end
  else if hadapan=3 then
  begin
    yp:=10;
    xp:=0;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left+10;
      ammo[tipe].Top:=tank1.Top+tank1.Height;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left+10;
      ammo[tipe].Top:=tank3.Top+tank3.Height;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left+10;
      ammo[tipe].Top:=tank4.Top+tank4.Height;
    end;
  end
  else if hadapan=4 then
  begin
    yp:=0;
    xp:=-10;
    if tipe=0 then
    begin
      ammo[tipe].Left:=tank1.Left-40;
      ammo[tipe].Top:=tank1.Top+10;
    end
    else if tipe=2 then
    begin
      ammo[tipe].Left:=tank3.Left-40;
      ammo[tipe].Top:=tank3.Top+10;
    end
    else if tipe=3 then
    begin
      ammo[tipe].Left:=tank4.Left-40;
      ammo[tipe].Top:=tank4.Top+10;
    end
  end;

ammo[tipe].Picture.LoadFromFile('peluru.bmp');
timer1.Interval:=50;
timer1.Enabled:=true;
shooting:=true;
kejar:=1;timer1.Enabled:=true;
end;
end;

procedure TForm1.HealTimer(Sender: TObject);
begin
 wktheal:=wktheal+1;
if wktheal mod 60=1 then
begin
    randomize();
    xh:=random(15);
    yh:=random(10);
    while (papan[yh,xh].Hint='w') do
      begin
          randomize();
          xh:=random(15);
          yh:=random(10);
      end;
      special2.Visible:=true;
    special2.Left:=xh*60;
    special2.Top:=yh*60;
    special2.Picture.LoadFromFile('heal.bmp');
    special2.BringToFront;
    papan[yh,xh].Hint:='h';
    serverbroadcast(serversocket1,total,'heal'+inttostr(xh)+'!'+inttostr(yh)+'&');
end
else if (wktheal mod 60>1) and  (wktheal mod 60 <=30) then
  begin
 serverbroadcast(serversocket1,total,'heal'+inttostr(xh)+'!'+inttostr(yh)+'&');
 end
else if wktheal mod 60 > 30 then
begin
  special2.Hide;
  papan[yh,xh].Hint:='.';
  serverbroadcast(serversocket1,total,'healdel&');
end;
end;

procedure TForm1.bomberTimer(Sender: TObject);
var
lockontarget:boolean;//buat cek apa posisi pesawat uda sama dengan tank,kl sama kirim pesan bomber
//broadcast ke semua pesan baru ky pesan kena bedane mek lakukno pengurangan lp ae ga pk ngecek daerah
//pesan bomber dibaca ky heal atao bonus bedae peletakane ga pk *60
//didalam sini kl lockon bener selain broadcast 'bombing' tapi juga melakukan pengurangan
//sesuai target karena server ngga akan terima pesan itu
//jadi ngurangi dewe
targetimage:timage;
begin
 wktbomber:=wktbomber+1;
if wktbomber mod 60=5 then
begin
  randomize();
  target:=random(total+2);
  special3.Picture.LoadFromFile('bomber.bmp');
  special3.BringToFront;
  special3.Visible:=true;
end
else if (wktbomber mod 60>5) and  (wktbomber mod 60 <=50) then
  begin
  lockontarget:=true;
  if target=0 then
  targetimage:=tank1
  else if target=1 then
  targetimage:=tank2
  else if target=2 then
  targetimage:=tank3
  else if target=3 then
  targetimage:=tank4;

  if (targetimage.Left<special3.Left) and (targetimage.Left+20<special3.Left) then
  begin
  special3.Picture.LoadFromFile('bomber2.bmp');
  special3.Left:=special3.left-20;
  lockontarget:=false;
  end
  else if targetimage.Left>special3.Left then
  begin
  special3.Picture.LoadFromFile('bomber.bmp');
  special3.Left:=special3.left+20;
  lockontarget:=false;
  end;

  if (targetimage.top<special3.Top) and (targetimage.top+20<special3.Top) then
  begin
  special3.Top:=special3.Top-20;
  lockontarget:=false;
  end
  else if targetimage.top>special3.Top then
  begin
  special3.Top:=special3.Top+20;
  lockontarget:=false;
  end;

  if lockontarget=true then
  begin
  if target=0 then
  begin
  lp1.Width:=lp1.Width-10;
  if lp1.Width=0 then
  begin
    tank1.Picture.LoadFromFile('tewas.bmp');
    serverbroadcast(serversocket1,total,'tewas1');
    mati:=true;
  end;
  end
  else if target=1 then
  begin
  lp2.Width:=lp2.Width-10;
  end
  else if target=2 then
  begin
  lp3.Width:=lp3.Width-10;
  end
  else if target=3 then
  begin
  lp4.Width:=lp4.Width-10;
  end;
  serverbroadcast(serversocket1,total,'bomber'+'!'+inttostr(target));
  end;
 serverbroadcast(serversocket1,total,'bomber'+inttostr(special3.left)+'!'+inttostr(special3.top)+'&');
 end
else if wktbomber mod 60 > 30 then
begin
  special3.Hide;
  randomize();
  special3.Left:=random(840);
  special3.top:=random(560);
  serverbroadcast(serversocket1,total,'bomberdel&');
end;
end;

end.
