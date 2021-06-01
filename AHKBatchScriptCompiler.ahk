#SingleInstance force       ; Allow only a single instance of the script to run.
#Warn                       ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

ReadConfigFile()
GetAHKInstallDir()
CompileAll()
return

CompileAll()
{
	; Compile each file passed as argument
	loop % A_Args.Length()
	{
		; Get the value of the current argument
		l_sPath := A_Args[A_Index]

		; If it's a folder
		if InStr(FileExist(l_sPath), "D")
		{
			; Compile all AHK scripts in that folder
			l_sFilePattern := GetAbsolutePath(l_sPath) . "\*.ahk"
			loop, Files, %l_sFilePattern%, F
				CompileFile(A_LoopFileLongPath)
		}
		; Otherwise just compile the file
		else
			CompileFile(l_sPath)
	}
}

CompileFile(p_sFile)
{
	global g_bShowNotifications, g_nCompress, g_sAhk2ExeAbsPath, g_sBinAbsPath, g_sIconAbsPath, g_sScriptNameNoExt
	l_sFileAbsPath := GetAbsolutePath(p_sFile)

	; The specified file doesn't exist, exit
	if (!l_sFileAbsPath)
		ExitWithErrorMessage(p_sFile . " not found! The script will now exit.")

	; The specified file isn't an AHK script, exit
	SplitPath, l_sFileAbsPath, , , l_sScriptExt
	if (l_sScriptExt != "ahk")
		ExitWithErrorMessage(p_sFile . " isn't an AHK script! The script will now exit.")

	; Show a notification
	if (g_bShowNotifications)
		TrayTip, AutoHotkey Batch Script Compiler, % "Compiling file " . l_sFileAbsPath

	; Compile the script
	if (g_sIconAbsPath)
		RunWait "%g_sAhk2ExeAbsPath%" /in "%l_sFileAbsPath%" /icon "%g_sIconAbsPath%" /bin "%g_sBinAbsPath%" /compress %g_nCompress%
	else
		RunWait "%g_sAhk2ExeAbsPath%" /in "%l_sFileAbsPath%" /bin "%g_sBinAbsPath%" /compress %g_nCompress%
}

GetAbsolutePath(p_sPath)
{
	loop, %p_sPath%, 1
		return A_LoopFileLongPath

	return ""
}

GetAHKInstallDir()
{
	global g_sBinName

	; Get the install directory from globals
	SplitPath, A_AhkPath, , l_sAhkInstallAbsPath

	; Get the install directory from the registry
	if (!l_sAhkInstallAbsPath)
		RegRead, l_sAhkInstallAbsPatAbsh, HKEY_LOCAL_MACHINE\SOFTWARE\AutoHotkey, InstallDir

	; Install directory not found, exit
	if (!l_sAhkInstallAbsPath)
		ExitWithErrorMessage("Can't find the AHK installation directory!")

	global g_sAhk2ExeAbsPath := % l_sAhkInstallAbsPath . "\Compiler\Ahk2Exe.exe"
	global g_sBinAbsPath := % l_sAhkInstallAbsPath . "\Compiler\" . g_sBinName
}

ReadConfigFile()
{
	global g_bShowNotifications, g_nCompress, g_sBinName, g_sIconName, g_sScriptName

	SplitPath, A_ScriptName, , , , l_sScriptNameNoExt
	l_sConfigFileName := l_sScriptNameNoExt . ".ini"

	; Config file is missing, exit
	if (!FileExist(l_sConfigFileName))
		ExitWithErrorMessage(l_sConfigFileName . " not found! The script will now exit.")

	; Read the config file
	IniRead, g_sScriptName, %l_sConfigFileName%, General, scriptNames
	IniRead, g_sIconName, %l_sConfigFileName%, General, iconName
	IniRead, g_sBinName, %l_sConfigFileName%, General, binName, "AutoHotkeySC.bin"
	IniRead, g_nCompress, %l_sConfigFileName%, General, compress, 0
	IniRead, g_bShowNotifications, %l_sConfigFileName%, General, showNotifications, 0

	; Split the list of scripts and put it in the list of arguments to simplify parsing
	if (!A_Args.Length())
		A_Args := StrSplit(g_sScriptName, ",")

	global g_sIconAbsPath := GetAbsolutePath(g_sIconName)
}

; Display an error message and exit
ExitWithErrorMessage(p_sErrorMessage)
{
	MsgBox, 16, Error, %p_sErrorMessage%
	ExitApp, 1
}