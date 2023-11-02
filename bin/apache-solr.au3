#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <InetConstants.au3>
#include <WinAPIFiles.au3>

Global $sPROJECT_NAME = "docker-web-Apache-Solr"

;~ ---------------------

;~ MsgBox($MB_SYSTEMMODAL, "Title", "This message box will timeout after 10 seconds or select the OK button.", 10)

MsgBox($MB_SYSTEMMODAL, $sPROJECT_NAME, "Before executing the script, it is recommended to either disable your antivirus software or add this script to the antivirus software's whitelist to prevent any unintended issues.", 30)
Local $sWorkingDir = @WorkingDir

;~ ---------------------

Local $result = 0

$result = ShellExecuteWait('WHERE', 'git', "", "open", @SW_HIDE)
If $result = 1 then
	MsgBox($MB_SYSTEMMODAL, "Environment Setting", "Please install GIT.")
	ShellExecute("https://git-scm.com/downloads", "", "open", @SW_HIDE)
	Exit
EndIf

$result = ShellExecuteWait('WHERE', 'docker-compose', "", "open", @SW_HIDE)
If $result = 1 then
	MsgBox($MB_SYSTEMMODAL, "Environment Setting", "Please install Docker Desktop.")
	ShellExecute("https://docs.docker.com/compose/install/", "", "open", @SW_HIDE)
	Exit
EndIf

$result = ShellExecuteWait('docker', 'version', "", "open", @SW_HIDE)
If $result = 1 then
	MsgBox($MB_SYSTEMMODAL, "Environment Setting", "Please start Docker Desktop.")
	Exit
EndIf

;~ ---------------------

;Local $sProjectFolder = @TempDir & "\" & $sPROJECT_NAME
Local $sProjectFolder = @HomeDrive & @HomePath & "\docker-app\" & $sPROJECT_NAME
;~ MsgBox($MB_SYSTEMMODAL, FileExists($sProjectFolder), $sProjectFolder)
If Not FileExists($sProjectFolder) Then
	FileChangeDir(@HomeDrive & @HomePath & "\docker-app\")
	ShellExecuteWait("git", "clone https://github.com/pulipulichen/" & $sPROJECT_NAME & ".git")
	FileChangeDir($sProjectFolder)
Else
	FileChangeDir($sProjectFolder)
	ShellExecuteWait("git", "reset --hard", "", "open", @SW_HIDE)
	ShellExecuteWait("git", "pull --force", "", "open", @SW_HIDE)
EndIf

;~ ---------------------

Local $sProjectFolderCache = $sProjectFolder & ".cache"
If Not FileExists($sProjectFolderCache) Then
	DirCreate($sProjectFolderCache)
EndIf

$result = ShellExecuteWait("fc", '"' & $sProjectFolder & "\Dockerfile" & '" "' & $sProjectFolderCache & "\Dockerfile" & '"', "", "open", @SW_HIDE)
If $result = 1 then
	ShellExecuteWait("docker-compose", "build")
	FileCopy($sProjectFolder & "\Dockerfile", $sProjectFolderCache & "\Dockerfile", $FC_OVERWRITE)
EndIf

$result = ShellExecuteWait("fc", '"' & $sProjectFolder & "\package.json" & '" "' & $sProjectFolderCache & "\package.json" & '"', "", "open", @SW_HIDE)
If $result = 1 then
	ShellExecuteWait("docker-compose", "build")
EndIf

FileCopy($sProjectFolder & "\Dockerfile", $sProjectFolderCache & "\Dockerfile", $FC_OVERWRITE)
FileCopy($sProjectFolder & "\package.json", $sProjectFolderCache & "\package.json", $FC_OVERWRITE)

;~ =================================================================
;~ 從docker-compose-template.yml來判斷參數

Local $INPUT_FILE = 0

If FileExists($sProjectFolder & "\docker-build\docker-compose-template.yml") Then
  Local $fileContent = FileRead($sProjectFolder & "\docker-build\docker-compose-template.yml")
  If StringInStr($fileContent, "[INPUT]") Then
    $INPUT_FILE = 1
  EndIf
EndIf

;~ ---------------------

Local $PUBLIC_PORT = 0

Local $DOCKER_COMPOSE_FILE = $sProjectFolder &  "\docker-compose.yml"
If Not FileExists($DOCKER_COMPOSE_FILE) Then
  $DOCKER_COMPOSE_FILE = $sProjectFolder & "\docker-build\docker-compose-template.yml"
EndIf

If FileExists($DOCKER_COMPOSE_FILE) Then
  Local $fileContent = FileRead($DOCKER_COMPOSE_FILE)
  Local $pattern = "ports:"
  Local $lines = StringSplit($fileContent, @CRLF)

  Local $flag = False
  For $i = 1 To $lines[0]
      If StringInStr($lines[$i], $pattern) Then
          $flag = True
      EndIf

      If $flag Then
        Local $portMatch = StringRegExp($lines[$i], '"[0-9]+:[0-9]+"', 3)
        If IsArray($portMatch) Then
          Local $portSplit = StringSplit(StringTrimRight(StringTrimLeft($portMatch[0], 1), 1), ':')
          $PUBLIC_PORT = $portSplit[1]
          ExitLoop
        EndIf
      EndIf
  Next
EndIf

;~ ---------------------
;~ 選取檔案

Global $sFILE_EXT = "* (*.*)"

Local $sUseParams = true
Local $sFiles[]
If $INPUT_FILE = 1 Then
	If $CmdLine[0] = 0 Then
		$sUseParams = false
		Local $sMessage = "Select File"
		Local $sFileOpenDialog = FileOpenDialog($sMessage, @DesktopDir & "\", $sFILE_EXT , $FD_FILEMUSTEXIST + $FD_MULTISELECT)
		$sFiles = StringSplit($sFileOpenDialog, "|")
	EndIf
EndIf

;~ =================================================================
;~ 宣告函數

Func getCloudflarePublicURL()
	;ConsoleWrite("getCloudflarePublicURL"  & @CRLF)
    Local $dirname = @ScriptDir

    Local $cloudflareFile = $dirname & "" & $sPROJECT_NAME & "\.cloudflare.url"
	;ConsoleWrite($cloudflareFile  & @CRLF)

    While Not FileExists($cloudflareFile)
        Sleep(3000) ; Check every 1 second
    WEnd

    Local $fileContent = FileRead($cloudflareFile)
	While StringStripWS($fileContent, 1 + 2) = ""
        Sleep(3000) ; Check every 1 second
		$fileContent = FileRead($cloudflareFile)
    WEnd
	;ConsoleWrite($fileContent  & @CRLF)
    Return $fileContent
EndFunc

;~ ----------------------------------------------------------------

Func setDockerComposeYML($file)
	;ConsoleWrite($file)
  Local $dirname = StringLeft($file, StringInStr($file, "\", 0, -1) - 1)
	If StringLeft($dirname, 1) = '"' Then
		$dirname = StringTrimLeft($dirname, 1)
	EndIf
	$dirname = StringReplace($dirname, "\", "/")
	
    Local $filename = StringMid($file, StringInStr($file, "\", 0, -1) + 1)

    Local $template = FileRead($sProjectFolder & "\docker-build\docker-compose-template.yml")
	;ConsoleWrite($template)
	
    $template = StringReplace($template, "[SOURCE]", $dirname)
    $template = StringReplace($template, "[INPUT]", $filename)

	FileDelete($sProjectFolder & "\docker-compose.yml")
    FileWrite($sProjectFolder & "\docker-compose.yml", $template)
	;ConsoleWrite($template & @CRLF)
	
EndFunc

;~ ----------------------------------------------------------------

Func waitForConnection($port)
    Sleep(3000) ; Wait for 3 seconds
	Local $sURL = "http://127.0.0.1:" & $port

	Local $sFilePath = _WinAPI_GetTempFileName(@TempDir)

	While 1
		Local $iResult = InetGet($sURL, $sFilePath, $INET_FORCERELOAD)
		If $iResult <> -1 Then
			ConsoleWrite("Connection successful." & @CRLF)
			ExitLoop
		EndIf

		ConsoleWrite("Connection failed. Retrying in 5 seconds..." & @CRLF)
		Sleep(5000) ; Wait for 5 seconds before retrying
	WEnd
EndFunc

;~ ----------------------------------------------------------------

Func runDockerCompose()
	Local $dirname = StringLeft(@ScriptDir, StringInStr(@ScriptDir, "\", 0, -1) - 1)
	Local $cloudflareFile = $dirname & "\" & $sPROJECT_NAME & "\.cloudflare.url"
	If FileExists($cloudflareFile) Then
		FileDelete($cloudflareFile)
	EndIf
	
	RunWait(@ComSpec & " /c docker-compose down")
	If $PUBLIC_PORT = 0 then
		RunWait(@ComSpec & " /c docker-compose up --build")
		Exit(1)
	Else
		RunWait(@ComSpec & " /c docker-compose up --build -d")
	EndIf

	waitForConnection($PUBLIC_PORT)
	
	;ConsoleWrite("getCloudflarePublicURL" & @CRLF)
	
	Local $cloudflare_url=getCloudflarePublicURL()

	Sleep(1000)

	ConsoleWrite("================================================================" & @CRLF)
	ConsoleWrite("You can link the website via following URL:" & @CRLF)
	ConsoleWrite(@CRLF)

	ConsoleWrite($cloudflare_url)
	ConsoleWrite("http://127.0.0.1:" & $PUBLIC_PORT & @CRLF)

	ConsoleWrite(@CRLF)
	ConsoleWrite("Press Ctrl+C to stop the Docker container and exit." & @CRLF)
	ConsoleWrite("================================================================" & @CRLF)
	
	Sleep(3000)
	;ShellExecute($cloudflare_url, "", "open", @SW_HIDE)
	ShellExecute($cloudflare_url)
	
	While True
    Sleep(5000) ; Sleep for 1 second (1000 milliseconds)
	WEnd
EndFunc

;~ ---------------------

If $INPUT_FILE = 1 Then 
	If $sUseParams = true Then
		For $i = 1 To $CmdLine[0]
			If Not FileExists($CmdLine[$i]) Then
				If Not FileExists($sWorkingDir & "/" & $CmdLine[$i]) Then
					MsgBox($MB_SYSTEMMODAL, $sPROJECT_NAME, "File not found: " & $CmdLine[$i])
				Else
					; ShellExecuteWait("node", $sProjectFolder & "\index.js" & ' "' & $sWorkingDir & "/" & $CmdLine[$i] & '"')	
					setDockerComposeYML('"' & $sWorkingDir & "/" & $CmdLine[$i] & '"')
					runDockerCompose()
				EndIf
			Else
				; ShellExecuteWait("node", $sProjectFolder & "\index.js" & ' "' & $CmdLine[$i] & '"')
				setDockerComposeYML('"' & $CmdLine[$i] & '"')
				runDockerCompose()
			EndIf
		Next
	Else
		For $i = 1 To $sFiles[0]
			FileChangeDir($sProjectFolder)
			; ShellExecuteWait("node", $sProjectFolder & "\index.js" & ' "' & $sFiles[$i] & '"')
			setDockerComposeYML('"' & $sFiles[$i] & '"')
			runDockerCompose()
		Next
	EndIf
Else
	FileChangeDir($sProjectFolder)
	setDockerComposeYML('"' & @ScriptDir & '"')
	runDockerCompose()
EndIf