object Form1: TForm1
  Left = 403
  Top = 98
  Width = 920
  Height = 640
  Caption = 'Form1'
  Color = clBtnFace
  TransparentColor = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object tank1: TImage
    Left = 88
    Top = 64
    Width = 60
    Height = 60
    OnClick = tank1Click
  end
  object tank2: TImage
    Left = 120
    Top = 480
    Width = 60
    Height = 60
    OnClick = tank2Click
  end
  object tank3: TImage
    Left = 784
    Top = 56
    Width = 60
    Height = 60
    OnClick = tank3Click
  end
  object tank4: TImage
    Left = 792
    Top = 472
    Width = 60
    Height = 60
    OnClick = tank4Click
  end
  object lp1: TShape
    Left = 56
    Top = 0
    Width = 300
    Height = 9
    Brush.Color = clRed
    Visible = False
  end
  object lp2: TShape
    Left = 56
    Top = 8
    Width = 300
    Height = 9
    Brush.Color = clLime
    Visible = False
  end
  object lp3: TShape
    Left = 56
    Top = 16
    Width = 300
    Height = 9
    Brush.Color = clBlue
    Visible = False
  end
  object lp4: TShape
    Left = 56
    Top = 24
    Width = 300
    Height = 9
    Brush.Color = clBtnShadow
    Visible = False
  end
  object label1: TLabel
    Left = 0
    Top = 8
    Width = 54
    Height = 20
    Caption = 'Health'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object special: TImage
    Left = 32
    Top = 176
    Width = 60
    Height = 60
    Transparent = True
  end
  object special2: TImage
    Left = 32
    Top = 288
    Width = 60
    Height = 60
    Transparent = True
    Visible = False
  end
  object special3: TImage
    Left = 88
    Top = 256
    Width = 60
    Height = 49
    Transparent = True
  end
  object Edit1: TEdit
    Left = 64
    Top = 0
    Width = 65
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object Button1: TButton
    Left = 64
    Top = 24
    Width = 33
    Height = 17
    Caption = 'Listen'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 96
    Top = 24
    Width = 25
    Height = 17
    Caption = 'Talk'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 64
    Top = 40
    Width = 33
    Height = 17
    Caption = 'AI'
    TabOrder = 3
    OnClick = Button3Click
  end
  object ServerSocket1: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientConnect = ServerSocket1ClientConnect
    OnClientRead = ServerSocket1ClientRead
    Left = 32
  end
  object ClientSocket1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnRead = ClientSocket1Read
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 128
  end
  object AITimer: TTimer
    Enabled = False
    OnTimer = AITimerTimer
    Left = 32
    Top = 64
  end
  object Bonus: TTimer
    Enabled = False
    OnTimer = BonusTimer
    Left = 32
    Top = 112
  end
  object Heal: TTimer
    Enabled = False
    OnTimer = HealTimer
    Left = 32
    Top = 152
  end
  object bomber: TTimer
    Enabled = False
    OnTimer = bomberTimer
    Left = 80
    Top = 152
  end
end
