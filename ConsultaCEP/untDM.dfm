object DM: TDM
  OnCreate = DataModuleCreate
  Height = 170
  Width = 379
  object Conexao: TFDConnection
    OnLost = ConexaoLost
    Left = 64
    Top = 32
  end
  object Cursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrHourGlass
    Left = 232
    Top = 32
  end
  object Link: TFDPhysFBDriverLink
    VendorLib = 'fbClient.dll'
    Left = 144
    Top = 32
  end
end
