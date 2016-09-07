object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Remote Inject Build 20160907'
  ClientHeight = 461
  ClientWidth = 338
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 0
    Top = 0
    Width = 338
    Height = 273
    Align = alClient
    Caption = #36827#31243#21015#34920
    TabOrder = 0
    object lv1: TListView
      Left = 2
      Top = 15
      Width = 334
      Height = 256
      Align = alClient
      Columns = <
        item
          Caption = 'Pid'
        end
        item
          Caption = 'Process'
          Width = 200
        end
        item
          Caption = 'Visit'
          Width = 55
        end>
      GridLines = True
      RowSelect = True
      PopupMenu = pm1
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = lv1Click
    end
  end
  object grp2: TGroupBox
    Left = 0
    Top = 273
    Width = 338
    Height = 188
    Align = alBottom
    Caption = #25805#20316
    TabOrder = 1
    object stat1: TStatusBar
      Left = 2
      Top = 167
      Width = 334
      Height = 19
      Panels = <
        item
          Text = #29366#24577':'
          Width = 180
        end
        item
          Text = #31649#29702#21592#27169#24335
          Width = 50
        end>
    end
    object lbledt1: TLabeledEdit
      Left = 96
      Top = 32
      Width = 217
      Height = 21
      EditLabel.Width = 76
      EditLabel.Height = 13
      EditLabel.Caption = #27880#20837#27169#22359#36335#24452':'
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object lbledt2: TLabeledEdit
      Left = 96
      Top = 72
      Width = 217
      Height = 21
      EditLabel.Width = 52
      EditLabel.Height = 13
      EditLabel.Caption = #30446#26631#36827#31243':'
      LabelPosition = lpLeft
      TabOrder = 2
    end
    object btn1: TButton
      Left = 238
      Top = 112
      Width = 75
      Height = 33
      Caption = #27880#20837
      TabOrder = 3
      OnClick = btn1Click
    end
  end
  object pm1: TPopupMenu
    AutoHotkeys = maManual
    AutoLineReduction = maManual
    Left = 160
    Top = 232
    object N1: TMenuItem
      Caption = #21047#26032#21015#34920
      OnClick = N1Click
    end
  end
end
