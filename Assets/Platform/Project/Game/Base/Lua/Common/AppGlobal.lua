
AppGlobal = {}

--小版本号，针对大版本做出的处理
AppGlobal.littleVersion = 0
--是否PC
AppGlobal.isPc = IsEditorOrPcPlatform()
--是否只有pc
AppGlobal.isOnlyPc = IsOnlyPcPlatform()
--App类型，针对iOS版本，0为正常App版本
AppGlobal.appType = 0
--是否是小游戏
AppGlobal.isMiniGame = false
--是否是测试
AppGlobal.isTest = false
--截图数据保存地址
AppGlobal.GetScreenshotPngPath = ""
--战绩回放类型
AppGlobal.RecordType = nil