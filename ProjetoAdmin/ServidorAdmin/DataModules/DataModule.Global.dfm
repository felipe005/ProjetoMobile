object DmGlobal: TDmGlobal
  OnCreate = DataModuleCreate
  Height = 301
  Width = 337
  object conn: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey'
      'Database=C:\BrKSistemas\DBASE\MOBILEFC.FDB'
      'Server=localhost'
      'Port=3050')
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = connBeforeConnect
    Left = 72
    Top = 40
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 184
    Top = 80
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 184
    Top = 160
  end
end
