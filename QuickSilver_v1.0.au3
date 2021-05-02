#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
	#AutoIt3Wrapper_Icon=Assets\QuickSilver.ico
	#AutoIt3Wrapper_Outfile_x64=QuickSilver v1.0.exe
	#AutoIt3Wrapper_Compression=4
	#AutoIt3Wrapper_Res_Comment=QuickSilver - TU Config Generator
	#AutoIt3Wrapper_Res_Description=QuickSilver - Config Generator. Scans for models in GameData, and makes a config, for Textures Unlimited.
	#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
	#AutoIt3Wrapper_Res_ProductName=QuickSilver
	#AutoIt3Wrapper_Res_ProductVersion=1
	#AutoIt3Wrapper_Res_CompanyName=By u\0-0-1
	#AutoIt3Wrapper_Res_LegalCopyright=Open Source
	#AutoIt3Wrapper_Res_SaveSource=y
	#AutoIt3Wrapper_Res_requestedExecutionLevel=None
	#AutoIt3Wrapper_Run_AU3Check=n
	#AutoIt3Wrapper_Run_Tidy=y
	#Tidy_Parameters=/reel /ri /gd /gds
	#AutoIt3Wrapper_Run_Au3Stripper=y
	#Au3Stripper_Parameters=/tl /debug /pe /so /sf /sv /mo /mi /rm /rsln /beta
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;

; +-------------------------------------------------+------------------------------------------------+
; ¦                                      /// QuickSilver v1.0 \\\                                    ¦
; ¦--------------------------------------------------------------------------------------------------¦
; ¦                                                                                                  ¦
; ¦						   Creates a cfg file for Textures Unlimited.                          ¦
; ¦					Maintains and applies blacklist of non-compatible parts.                    ¦
; ¦					       Allows selection of which mods are included.                         ¦
; ¦                                                                                                  ¦
; +-------------------------------------------------+------------------------------------------------+

; Included Functions:

#include <Array.au3>
#include <AutoItConstants.au3>
#include <ButtonConstants.au3>
#include <Constants.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <GDIPlus.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListView.au3>
#include <GuiImageList.au3>
#include <GuiScrollBars.au3>
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <String.au3>
#include <StaticConstants.au3>
#include <WinAPIGdiDC.au3>
#include <WinAPISysWin.au3>
#include <WindowsConstants.au3>

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                                    \\\  Initialise Main UI  ///                                  ¦
; +-------------------------------------------------+------------------------------------------------+

;

_PreLaunchChecks() ;... 1) Reasons not to launch.
_DpiConfig()       ;... 2) Get and set the display environment (Must be done before launching the UI)
_QuickSilverUI()   ;... 3) Launch the UI

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                                            \\\  UI  ///                                          ¦
; +-------------------------------------------------+------------------------------------------------+

;

Func _QuickSilverUI()
	Local Const $hGUI2 = GUICreate(" QuickSilver. V1.0 ", 300 * $iDPI_ratio, 400 * $iDPI_ratio, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, "", ""))
	GUISetIcon(@ScriptDir & "\Source\Ico\QuickSilver.ico")
	Local Const $iListView = GUICtrlCreateListView("Press scan button to begin.", 0, 0, 300 * $iDPI_ratio, 300 * $iDPI_ratio) ;... List view window
	_GUICtrlListView_SetColumnWidth(-1, 0, 278)
	_GUICtrlListView_SetExtendedListViewStyle($iListView, $LVS_EX_GRIDLINES)
	Global Const $hListView = GUICtrlGetHandle($iListView)
	_GUICtrlListView_SetExtendedListViewStyle($hListView, BitOR("", $LVS_EX_REGIONAL, $LVS_EX_BORDERSELECT, $LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, $LVS_EX_CHECKBOXES, $LVS_EX_FLATSB, $LVS_EX_DOUBLEBUFFER))

	Local $bDisable = GUICtrlCreateButton("Disable", 210 * $iDPI_ratio, 351 * $iDPI_ratio, 85 * $iDPI_ratio, 45 * $iDPI_ratio) ;... Disable button
	GUICtrlSetTip($bDisable, "Disable Quicksilver")

	Local $bDeselectAll = GUICtrlCreateButton(" ", 5 * $iDPI_ratio, 303 * $iDPI_ratio, 15 * $iDPI_ratio, 15 * $iDPI_ratio) ;... DeSelect all button
	GUICtrlSetTip($bDeselectAll, "Ignored mods saved when you hit generate", "Clear selection")

	Local $bSelectAll = GUICtrlCreateButton("✓", 5 * $iDPI_ratio, 303 * $iDPI_ratio, 15 * $iDPI_ratio, 15 * $iDPI_ratio) ;... Select all button
	GUICtrlSetState($bSelectAll, $GUI_HIDE)
	GUICtrlSetTip($bSelectAll, "Select All")
	GUICtrlSetFont(-1, 10, "", "", "Segoe UI Emoji")

	Local $bCancel = GUICtrlCreateButton("Exit", 5 * $iDPI_ratio, 351 * $iDPI_ratio, 85 * $iDPI_ratio, 45 * $iDPI_ratio) ;... Exit button

	Global $bSave = GUICtrlCreateButton(" Generate", 101 * $iDPI_ratio, 351 * $iDPI_ratio, 100 * $iDPI_ratio, 45 * $iDPI_ratio) ;.. Generate button
	GUICtrlSetImage($bSave, @ScriptDir & "\Assets\QuickSilver.ico", 4)
	GUICtrlSetState($bSave, $GUI_DISABLE)

	Global $bScan = GUICtrlCreateButton("Start Scan", 5 * $iDPI_ratio, 304 * $iDPI_ratio, 290 * $iDPI_ratio, 40 * $iDPI_ratio, $SS_CENTER) ;... Scan button

	GUISetState(@SW_SHOWNORMAL, $hGUI2)

	While 1
		
		Switch GUIGetMsg()

			Case $bScan ;... Scan button pressed
				GUICtrlSetData($bScan, "Scanning . . .")
				_PopulateListView($hListView)
				GUICtrlSetState($bScan, $GUI_HIDE)
				Sleep(250)
				PreSelect()
				GUICtrlCreateLabel("Total parts: " & IniRead("Settings.ini", "PartCounts", "Total", ""), 111 * $iDPI_ratio, 310 * $iDPI_ratio, 145 * $iDPI_ratio)
				Local $lAvail = GUICtrlCreateLabel("Available: " & IniRead("Settings.ini", "PartCounts", "Pruned", ""), 115 * $iDPI_ratio, 330 * $iDPI_ratio, 150 * $iDPI_ratio)
				GUICtrlSetColor($lAvail, 0x0d5300)
				GUICtrlSetData($iListView, "Mods with parts: " & IniReadSection("Settings.ini", "ModsWithParts")[0][0])
				GUICtrlSetState($bSave, $GUI_ENABLE)
				
			Case $GUI_EVENT_CLOSE ;... Window closed
				GUIDelete($hGUI2)
				Exit

			Case $bCancel ;... Exit button pressed
				GUIDelete($hGUI2)
				Exit

			Case $bDisable ;... Disable button pressed
				$ret = MsgBox(4, "Disable for all mods", "Do you want to disable QuickSilver?")
				If $ret == 6 Then
					_DisableCFG()
					Exit
				EndIf

			Case $bDeselectAll ;... DeSelect all button pressed
				_GUICtrlListView_SetCheckedStates($hListView, 0)
				GUICtrlSetState($bDeselectAll, $GUI_HIDE)
				GUICtrlSetState($bSelectAll, $GUI_SHOW)

			Case $bSelectAll ;... Select all button pressed
				_GUICtrlListView_SetCheckedStates($hListView, 1)
				GUICtrlSetState($bSelectAll, $GUI_HIDE)
				GUICtrlSetState($bDeselectAll, $GUI_SHOW)

			Case $bSave ;... Generate button pressed
				GUISetState(@SW_HIDE, $hGUI2)
				_GUICtrlListView_SetCheckedStates($hListView, 2) ;... Invert the checkboxes to reveal only deselected ones
				Local $aItems, $Item, $sString
				$aItems = _ListView_GetCheckedStates($hListView) ;... Grab the checked item indices
				_ArrayDelete($aItems, "0") ;... Remove array count

				$aReturn = _GUICtrlListView_CreateArray($hListView, Default) ;... Make a new array from the list view
				IniWriteSection("Settings.ini", "DisabledMods", "") ;... Clear the disabled mods section in the ini

				For $x = 0 To UBound($aItems) - 1 ;... Commit to settings file for later reading
					For $Item In $aItems

						If $x = UBound($aItems) Then
							ExitLoop
						EndIf
						If $Item = "" Then
							IniWriteSection("Settings.ini", "DisabledMods", "")
							ExitLoop
						Else
							$sString = _GUICtrlListView_GetItemText($hListView, $Item)
							IniWrite("Settings.ini", "DisabledMods", $aItems[$x], $sString)
							$x = $x + 1
						EndIf
						If $x = UBound($aItems) Then
							ExitLoop
						EndIf
					Next
					_ResortINISec("Settings.ini", "DisabledMods") ;... Resort the newly written section
				Next
				MakeConfig() ;... Proceed to build the config
				MsgBox("", "Finished.", "Done!", 1.5)
				Exit
		EndSwitch
	WEnd
EndFunc   ;==>_QuickSilverUI

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                                  \\\  Generate the cfg file  ///                                 ¦
; +-------------------------------------------------+------------------------------------------------+

;

Func MakeConfig()

	;
	SplashTextOn("", "Building Config... ", 250 * $iDPI_ratio, 75 * $iDPI_ratio, -1, -1, "", "", 8 * $iDPI_ratio)
	_BuildCFGBody() ;... List parts and apply filters, and alter strings to fit final config
	SplashOff()
	MergeFiles() ;... Retreive header and footer from setting.ini and compile the final cfg
	SplashTextOn("", "Done!", 250 * $iDPI_ratio, 75 * $iDPI_ratio, -1, -1, "", "", 10 * $iDPI_ratio)
	Sleep(800)
	SplashOff()
	Exit ;... Finsh

EndFunc   ;==>MakeConfig

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                             \\\  Build the body of the CFG  ///                                  ¦
; +-------------------------------------------------+------------------------------------------------+

; The main function of QuickSilver, it builds a valid cfg segment, from parts found and after filters are applied.

Func _BuildCFGBody()
	$RootFolder = IniRead("Settings.ini", "Settings", "KSP Root", "")
	Local $sGameData = $RootFolder
	$aArray = _FileListToArrayRec($sGameData, "*.mu", $FLTAR_RECUR, $FLTAR_SORT, 1) ;... Search GameData for every folder with a .mu
	_FileWriteFromArray(@TempDir & "\List.tmp", $aArray) ;... Write list to a temp file
	_FileWriteToLine(@TempDir & "\List.tmp", 1, "", 1) ;... Delete array count

	$szFile = @TempDir & "\List.tmp"
	$szText = FileRead($szFile, FileGetSize($szFile)) ;... Read the temp file
	$szText = StringReplace($szText, "GameData\", "	model = ") ;... Find and replace strings
	$szText = StringReplace($szText, "\", "/")
	$szText = StringReplace($szText, ".mu", "")
	FileDelete($szFile)
	FileWrite($szFile, $szText) ;... Write the altered array to a new file
	Global $_Array
	_FileReadToArray(@TempDir & "\List.tmp", $_Array) ;... Read the temp file once more to an array for filtering
	$aInitialArray = $_Array
	Local $aCompare = IniReadSection("Settings.ini", "BlackListedParts") ;... Grab list of blacklisted parts from ini

	For $j = UBound($aCompare) - 1 To 0 Step -1                          ;... Remove any blacklisted parts found
		For $iI = UBound($aInitialArray) - 1 To 0 Step -1
			Local $_Item
			If StringInStr($aInitialArray[$iI], $aCompare[$j][1]) <> 0 Then
				_ArrayDelete($aInitialArray, $iI)
			Else
				$_Item += 1
			EndIf
		Next
	Next

	Local $aCompare = IniReadSection("Settings.ini", "DisabledMods") ;... Grab list of disabled Mods from ini
	
	For $j = UBound($aCompare) - 1 To 0 Step -1                      ;... Remove any disabled mods found
		For $iI = UBound($aInitialArray) - 1 To 0 Step -1
			Local $_Item
			If StringInStr($aInitialArray[$iI], $aCompare[$j][1]) <> 0 Then
				_ArrayDelete($aInitialArray, $iI)
			Else
				$_Item += 1
			EndIf
		Next
	Next

	_FileWriteFromArray(@TempDir & "\Body.tmp", $aInitialArray) ;... Temporarily save the fixed & filtered array as the body of the cfg file
	_FileWriteToLine(@TempDir & "\Body.tmp", 1, "", 1) ;... Remove array count

EndFunc   ;==>_BuildCFGBody

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                             \\\  Find all mods with parts in GameData  ///                       ¦
; +-------------------------------------------------+------------------------------------------------+

; Reterieves the top level folder names, of only mods with parts. Used for the list view.

Func FetchAllMods()
	$RootFolder = IniRead("Settings.ini", "Settings", "KSP Root", "")
	Local $sGameData = $RootFolder
	GUICtrlSetData($bScan, "Searching GameData ...")
	Local $aAllModels = _FileListToArrayRec($sGameData, "*.mu", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_RELPATH) ;... Get every models path
	_ArrayDelete($aAllModels, 0)
	$szFile = @TempDir & "\mulist._"
	GUICtrlSetData($bScan, "Filtering file ...")
	_FileWriteFromArray($szFile, $aAllModels)
	$szText = FileRead($szFile, FileGetSize($szFile))
	$szText = StringReplace($szText, "GameData\", "") ;... Alter strings
	$szText = StringReplace($szText, ".mu", "")
	$szText = StringReplace($szText, "\", ",")
	FileDelete($szFile)
	FileWrite($szFile, $szText)
	Global $_Array
	_FileReadToArray($szFile, $_Array)
	GUICtrlSetData($bScan, "Finding parts ...")
	IniWrite("Settings.ini", "PartCounts", "Total", UBound($_Array)) ;... Write the part count to file for later reading
	$aInitialArray = $_Array
	Local $aCompare = IniReadSection("Settings.ini", "BlackListedParts") ;... Prune unwanted parts
	For $j = UBound($aCompare) - 1 To 0 Step -1
		For $iI = UBound($aInitialArray) - 1 To 0 Step -1
			Local $_Item
			If StringInStr($aInitialArray[$iI], $aCompare[$j][1]) <> 0 Then
				_ArrayDelete($aInitialArray, $iI)
			Else
				$_Item += 1
			EndIf
		Next
	Next
	_FileWriteFromArray($szFile, $aInitialArray)
	IniWrite("Settings.ini", "PartCounts", "Pruned", UBound($aInitialArray)) ;... Write the filtered part count to file for later reading

	Local $szFile2
	$szFile2 = @TempDir & "\mulist.__"
	If FileExists($szFile2) Then FileDelete($szFile2)

	GUICtrlSetData($bScan, "Listing Mods ...")
	; The following line is a run via dos, it removes the filename part of the list so far since we no longer need it.
	RunWait(@ComSpec & " /c for /F ""tokens=1 delims=,"" %i in (%TMP%\mulist._) do @echo %i >> %TMP%\Mulist.__", "", @SW_HIDE)
	_FileWriteToLine($szFile2, 1, "", 1)         ;...At this point we have only top level folders but lots of duplicate lines so..

	Local $aPreDeDuped

	_FileReadToArray($szFile2, $aPreDeDuped)     ;... Read the file to a new array
	_ArrayDelete($aPreDeDuped, 0)

	Local $aDeDuped = _ArrayUnique($aPreDeDuped) ;...DeDupe the array
	_ArrayDelete($aDeDuped, 0)
	_ArrayDelete($aDeDuped, 0)
	_ArraySort($aDeDuped, 0)                     ;...Sort it
	FileDelete($szFile)
	FileDelete($szFile2)
	_ArrayToIni("Settings.ini", "ModsWithParts", $aDeDuped) ;... Write the mods with parts only as a section in ini for later reading
	
EndFunc   ;==>FetchAllMods

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                             \\\  Combine sections & output the cfg  ///                          ¦
; +-------------------------------------------------+------------------------------------------------+

; Combines the cfg header, body, and footer.

Func MergeFiles()

	If FileExists(@TempDir & "\TU_Config.cfg") Then FileDelete(@TempDir & "\TU_Config.cfg")
	
	_WriteHeaderText()     ;... Retreive header section from setting settings and write it to a temporary file
	
	RunWait(@ComSpec & " /c Type %TMP%\Body.tmp>>%TMP%\TU_Config.cfg", "", @SW_HIDE)     ;... Inject body into temporary file
	
	_WriteFooterText()     ;... Retreive footer section from setting settings and write it to a temporary file

	Local $aLines

	_FileReadToArray(@TempDir & "\TU_Config.cfg", $aLines)

	For $i = $aLines[0] To 1 Step -1 ;... Remove extra blank lines from final cfg
		If $aLines[$i] = "" Then
			_ArrayDelete($aLines, $i)
		EndIf
	Next

	_FileWriteFromArray(@TempDir & "\TU_Config.cfg", $aLines, 1)

	_FileReadToArray(@TempDir & "\TU_Config.cfg", $aLines)

	For $i = $aLines[0] To 1 Step -1
		If $aLines[$i] = "KSP_MODEL_SHADER" Then ;... Add Spacers between sections of the final cfg
			_FileWriteToLine(@TempDir & "\TU_Config.cfg", $i, "" & @CRLF & ";-" & @CRLF & "" & @CRLF & "KSP_MODEL_SHADER", 1)
		EndIf
	Next
	Local $CFGName = IniRead("Settings.ini", "Settings", "CFG Name", "")
	If FileExists($CFGName) Then FileDelete($CFGName)
	FileMove(@TempDir & "\TU_Config.cfg", $CFGName)
EndFunc   ;==>MergeFiles

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                             \\\  Retreive header strings from ini  ///                           ¦
; +-------------------------------------------------+------------------------------------------------+

; Finds and retreives header text from ini

Func _WriteHeaderText()
	Local $Startline, $Endline, $FirstLine, $LastLine, $sText
	$sText = ""
	$Startline = _FindLine("Settings.ini", "[CFG_Header_Start]")
	$Endline = _FindLine("Settings.ini", "[CFG_Header_End]")
	$FirstLine = $Startline + 1
	$LastLine = $Endline - 1
	FileWrite(@TempDir & "\TU_Config.cfg", _GetSectionAsText("Settings.ini", $FirstLine, $LastLine))
EndFunc   ;==>_WriteHeaderText

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                            \\\  Retreive footer strings from ini  ///                            ¦
; +-------------------------------------------------+------------------------------------------------+

; Finds and retreives footer text from ini

Func _WriteFooterText()
	Local $Startline, $Endline, $FirstLine, $LastLine, $sText
	$Startline = _FindLine("Settings.ini", "[CFG_Footer_Start]")
	$Endline = _FindLine("Settings.ini", "[CFG_Footer_End]")
	$FirstLine = $Startline + 1
	$LastLine = $Endline - 2
	FileWrite(@TempDir & "\TU_Config.cfg", _GetSectionAsText("Settings.ini", $FirstLine, $LastLine))
EndFunc   ;==>_WriteFooterText

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                          \\\  Find and return line based on string  ///                          ¦
; +-------------------------------------------------+------------------------------------------------+

; Used by _WriteHeaderText() and _WriteFooterText() to find the segment, this way the real line number doesnt matter

Func _FindLine($File, $sSearch)

	Local $aLines

	_FileReadToArray($File, $aLines)

	For $i = 1 To $aLines[0]
		If $aLines[$i] == $sSearch Then
			Return ($i)
			ExitLoop
		EndIf
	Next

EndFunc   ;==>_FindLine

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                      \\\  Retreive ini section as strings by line range  ///                     ¦
; +-------------------------------------------------+------------------------------------------------+

; Used by _WriteHeaderText() and _WriteFooterText() to retreive the strings in the segment.

Func _GetSectionAsText($File, $Start, $Finish)
	Local $sText
	$hFile = FileOpen($File, 0)
	$sText = FileReadLine($hFile, $Start) & @CRLF

	$i = $Start
	For $i = $Start To $Finish - 1 Step 1
		$sText &= FileReadLine($hFile) & @CRLF
	Next
	;MsgBox(0,"Result Text",$sText)
	FileClose($hFile)
	Return $sText
EndFunc   ;==>_GetSectionAsText

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                             \\\  Windows Dpi awareness functions  ///                            ¦
; +-------------------------------------------------+------------------------------------------------+

; Needed for correct UI funcionality in windows multi monitor environments

Func _DpiConfig()

	Global Enum $DPI_AWARENESS_INVALID = -1, $PROCESS_DPI_UNAWARE = 0, $PROCESS_SYSTEM_DPI_AWARE, $PROCESS_PER_MONITOR_DPI_AWARE
	Global Enum $Context_UnawareGdiScaled = -5, $Context_PerMonitorAwareV2, $Context_PerMonitorAware, $Context_SystemAware, $Context_Unaware
	Global Const $WM_DPICHANGED = 0x02E0, $WM_GETDPISCALEDSIZE = 0x02E4
	Global $dpiScaledX, $dpiScaledY, $aCtrlFS[5][2], $hGUI, $hGUI_child, $g_iDPI_ratio2
	_WinAPI_SetDPIAwareness()
	Local $iDPI
	If @OSBuild < 14393 Then
		$iDPI = _GDIPlus_GraphicsGetDPIRatio()
	Else
		Local $hGUI_dummy = GUICreate("", 1, 1)
		$iDPI = _WinAPI_GetDpiForWindow($hGUI_dummy)
		GUIDelete($hGUI_dummy)
	EndIf
	Global $iDPI_ratio = $iDPI / 96
	$g_iDPI_ratio2 = 96 / $iDPI
EndFunc   ;==>_DpiConfig

;-

Func ResizeFont($hWnd)
	If $hWnd = $hGUI Then
		Local $iDPI = _WinAPI_GetDpiForWindow($hWnd)
		Local $i, $dpi_ratio = $iDPI / 96
		For $i = 0 To UBound($aCtrlFS) - 1
			GUICtrlSetFont($aCtrlFS[$i][0], $aCtrlFS[$i][1] * $dpi_ratio * $g_iDPI_ratio2, 400, 0, "Segoe UI", 5)
		Next
	EndIf
EndFunc   ;==>ResizeFont

;-

Func _WinAPI_FindWindowEx($hWndParent, $hWndChildAfter = 0, $sClassName = "", $sWindowName = "")
	Local $aResult = DllCall("user32.dll", "hwnd", "FindWindowEx", "hwnd", $hWndParent, "hwnd", $hWndChildAfter, "wstr", $sClassName, "wstr", $sWindowName)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FindWindowEx

;-

Func _WinAPI_GetDpiForWindow($hWnd)
	Local $aResult = DllCall("user32.dll", "uint", "GetDpiForWindow", "hwnd", $hWnd) ;requires Win10 v1607+ / no server support
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDpiForWindow

;-

Func _GDIPlus_GraphicsGetDPIRatio($iDPIDef = 96)
	_GDIPlus_Startup()
	Local $hGfx = _GDIPlus_GraphicsCreateFromHWND(0)
	If @error Then Return SetError(1, @extended, 0)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetDpiX", "handle", $hGfx, "float*", 0)
	If @error Then Return SetError(2, @extended, 0)
	_GDIPlus_GraphicsDispose($hGfx)
	_GDIPlus_Shutdown()
	Return $aResult[2]
EndFunc   ;==>_GDIPlus_GraphicsGetDPIRatio

;-

Func WM_GETDPISCALEDSIZE($hWnd, $iMsg, $wParam, $lParam)
	Local $tSize = DllStructCreate($tagSIZE, $lParam)
	Return True
EndFunc   ;==>WM_GETDPISCALEDSIZE

;-

Func WM_DPICHANGED($hWnd, $iMsg, $wParam, $lParam)
	Local $tRECT = DllStructCreate($tagRECT, $lParam)
	Local $iX = $tRECT.left, $iY = $tRECT.top, $iW = $tRECT.right - $iX, $iH = $tRECT.bottom - $iY
	_WinAPI_SetWindowPos($hWnd, 0, $iX, $iY, $iW, $iH, BitOR($SWP_NOZORDER, $SWP_NOACTIVATE))
	ResizeFont($hWnd)
	$tRECT = 0
	Return 1
EndFunc   ;==>WM_DPICHANGED

;-

Func _WinAPI_SetDPIAwareness($hGUI = 0)
	Switch @OSBuild
		Case 6000 To 9199
			If Not DllCall("user32.dll", "bool", "SetProcessDPIAware") Then Return SetError(1, 0, 0)
			Return 1
		Case 9200 To 13999
			_WinAPI_SetProcessDpiAwareness($PROCESS_PER_MONITOR_DPI_AWARE)
			If @error Then Return SetError(2, 0, 0)
			Return 1
		Case @OSBuild > 13999
			_WinAPI_SetProcessDpiAwarenessContext($Context_PerMonitorAwareV2, $hGUI, 1)
			If @error Then Return SetError(3, @error, 0)
			Return 1
	EndSwitch
	Return -1
EndFunc   ;==>_WinAPI_SetDPIAwareness

;-

Func _WinAPI_SetProcessDpiAwareness($DPIAware)
	Local $aResult = DllCall("Shcore.dll", "long", "SetProcessDpiAwareness", "int", $DPIAware)
	If @error Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_WinAPI_SetProcessDpiAwareness

;-

Func _WinAPI_SetProcessDpiAwarenessContext($DPIAwareContext = $Context_PerMonitorAware, $hGUI = 0, $iMode = 1)
	$DPIAwareContext = ($DPIAwareContext < -5) ? -5 : ($DPIAwareContext > -1) ? -1 : $DPIAwareContext
	$iMode = ($iMode < 1) ? 1 : ($iMode > 3) ? 3 : $iMode
	Switch $iMode
		Case 1
			Local $hDC = _WinAPI_GetDC($hGUI)
			Local $aResult1 = DllCall("user32.dll", "int", "GetDpiFromDpiAwarenessContext", "ptr", $hDC)
			If @error Or Not IsArray($aResult1) Then Return SetError(11, 0, 0)
			_WinAPI_ReleaseDC(0, $hDC)
			Local $aResult = DllCall("user32.dll", "Bool", "SetProcessDpiAwarenessContext", "int", $aResult1[0] + $DPIAwareContext)
			If @error Or Not IsArray($aResult) Then Return SetError(12, 0, 0)
		Case 2
			Local $aResult2 = DllCall("user32.dll", "int", "GetWindowDpiAwarenessContext", "ptr", $hGUI)
			If @error Or Not IsArray($aResult2) Then Return SetError(21, 0, 0)
			Local $aResult = DllCall("user32.dll", "Bool", "SetProcessDpiAwarenessContext", "int", $aResult2[0] + $DPIAwareContext)
			If @error Or Not IsArray($aResult) Then Return SetError(22, 0, 0)
		Case 3
			Local $aResult31 = DllCall("user32.dll", "ptr", "GetThreadDpiAwarenessContext")
			If @error Or Not IsArray($aResult31) Then Return SetError(31, 0, 0)
			Local $aResult32 = DllCall("user32.dll", "int", "GetAwarenessFromDpiAwarenessContext", "ptr", $aResult31[0])
			If @error Or Not IsArray($aResult32) Then Return SetError(32, 0, 0)
			Local $aResult = DllCall("user32.dll", "Bool", "SetThreadDpiAwarenessContext", "int", $aResult32[0] + $DPIAwareContext)
			If @error Or Not IsArray($aResult) Then Return SetError(33, 0, 0)
	EndSwitch

	Return 1
EndFunc   ;==>_WinAPI_SetProcessDpiAwarenessContext

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                                \\\  Resorts an ini section  ///                                  ¦
; +-------------------------------------------------+------------------------------------------------+

; Used to resort the Disabled mods section after it is re-written

Func _ResortINISec($File, $Section)
	Local $aSource[1][1]
	Local $aOutput[1]
	$aSource = IniReadSection($File, $Section)

	For $i = 0 To UBound($aSource) - 1
		_ArrayAdd($aOutput, $aSource[$i][1])
	Next

	$aOutput[0] = UBound($aOutput) - 1
	_ArrayDelete($aOutput, 0)
	_ArrayDelete($aOutput, 0)
	$aOutput = _ArrayUnique($aOutput)
	_ArrayDelete($aOutput, 0)
	_ArrayColInsert($aOutput, 0)

	For $i = 0 To UBound($aOutput) - 1
		$aOutput[$i][0] = $i
	Next

	IniWriteSection($File, $Section, $aOutput, 0)
EndFunc   ;==>_ResortINISec

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                               \\\  Disable Quicksilver Config  ///                               ¦
; +-------------------------------------------------+------------------------------------------------+

; Quickly disables the cfg by simply renaming it

Func _DisableCFG()
	SplashTextOn("", " QuickSilver Disabled!.. ", 250 * $iDPI_ratio, 75 * $iDPI_ratio, -1, -1, "", "", 8 * $iDPI_ratio)
	IniWrite("Settings.ini", "Settings", "Disable", "True")
	Local $CFGName = IniRead("Settings.ini", "Settings", "CFG Name", "") ; Remembers setting for UI option to re-enable
	If FileExists($CFGName) Then FileMove($CFGName, "QSCFG._")
	;Endif
	Sleep(800)
	SplashOff()
EndFunc   ;==>_DisableCFG

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                        \\\  Retreive the check states of listed items  ///                       ¦
; +-------------------------------------------------+------------------------------------------------+

; Used to figure out with chekboxes are checked

Func _ListView_GetCheckedStates($hListView)
	Local $sReturn = ''
	For $i = 0 To _GUICtrlListView_GetItemCount($hListView) - 1
		If _GUICtrlListView_GetItemChecked($hListView, $i) Then
			$sReturn &= $i & '|'
		EndIf
	Next
	Return StringSplit(StringTrimRight($sReturn, StringLen('|')), '|')
EndFunc   ;==>_ListView_GetCheckedStates

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                         \\\  Create a new array from the list view  ///                          ¦
; +-------------------------------------------------+------------------------------------------------+

; Used to store the list view as an array with correct indices to determine which check boxes are checked

Func _GUICtrlListView_CreateArray($hListView, $sDelimeter = '|')
	Local $iColumnCount = _GUICtrlListView_GetColumnCount($hListView), $iDim = 0, $iItemCount = _GUICtrlListView_GetItemCount($hListView)
	If $iColumnCount < 3 Then
		$iDim = 3 - $iColumnCount
	EndIf
	If $sDelimeter = Default Then
		$sDelimeter = '|'
	EndIf

	Local $aColumns = 0, $aReturn[$iItemCount + 1][$iColumnCount + $iDim] = [[$iItemCount, $iColumnCount, '']]
	For $i = 0 To $iColumnCount - 1
		$aColumns = _GUICtrlListView_GetColumn($hListView, $i)
		$aReturn[0][2] &= $aColumns[5] & $sDelimeter
	Next
	$aReturn[0][2] = StringTrimRight($aReturn[0][2], StringLen($sDelimeter))

	For $i = 0 To $iItemCount - 1
		For $j = 0 To $iColumnCount - 1
			$aReturn[$i + 1][$j] = _GUICtrlListView_GetItemText($hListView, $i, $j)
		Next
	Next
	Return SetError(Number($aReturn[0][0] = 0), 0, $aReturn)
EndFunc   ;==>_GUICtrlListView_CreateArray

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                        \\\  Set the checked states of list checkboxes  ///                       ¦
; +-------------------------------------------------+------------------------------------------------+

; Used to set all buttons as check/unchecked via a button press

Func _GUICtrlListView_SetCheckedStates(Const $hListView, Const $iType)
	Local $fState = False

	Local Const $iCount = _GUICtrlListView_GetItemCount($hListView)

	If $iType < 0 Or $iType > 2 Then
		Return SetError(1, 0, 0)
	EndIf

	If $iType Then
		$fState = True
	EndIf

	For $i = 0 To $iCount - 1
		If $iType = 2 Then
			$fState = Not _GUICtrlListView_GetItemChecked($hListView, $i)
		EndIf
		_GUICtrlListView_SetItemChecked($hListView, $i, $fState)
	Next
EndFunc   ;==>_GUICtrlListView_SetCheckedStates

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                                \\\  Populate the list view  ///                                  ¦
; +-------------------------------------------------+------------------------------------------------+

; Reads mods list from settings and adds it as a list of checkboxes to list view

Func _PopulateListView($hListView)

	FetchAllMods()
	$aInitialArray = IniReadSection("Settings.ini", "ModsWithParts")
	_ArrayColDelete($aInitialArray, 0)
	_ArrayDelete($aInitialArray, 0)
	_GUICtrlListView_AddArray($hListView, $aInitialArray)
	_GUICtrlListView_SetItemChecked($hListView, -1, True)

EndFunc   ;==>_PopulateListView

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                                \\\  Deselect disable mods  ///                                   ¦
; +-------------------------------------------------+------------------------------------------------+

; Finds already disabled mods in ini then unchecks the boxes since they were previously deselected.

Func PreSelect()
	
	Local $aPreList[1][1]
	Local $aPreItem[1]

	$aPreList = IniReadSection("Settings.ini", "DisabledMods")
	_ArrayDelete($aPreList, "0")
	For $i = 0 To UBound($aPreList) - 1
		_ArrayAdd($aPreItem, $aPreList[$i][1])
	Next
	$aPreItem[0] = UBound($aPreItem) - 1
	_ArrayDelete($aPreItem, "0")
	For $i = 0 To UBound($aPreItem) - 1
		$iI = _GUICtrlListView_FindText($hListView, $aPreItem[$i])
		_GUICtrlListView_SetItemChecked($hListView, $iI, False)

	Next
EndFunc   ;==>PreSelect

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                              \\\  Commit array to ini section  ///                               ¦
; +-------------------------------------------------+------------------------------------------------+

; Used by FetchAllMods() to commit the depude array to the relevant ini section

Func _ArrayToIni($hFile, $sSection, $aName)
	Global $defaultSeparator = Opt("GUIDataSeparatorChar", "|")
	Global $defaultSeparatorString = "<%Separator%>"
	Local $iLines = UBound($aName)
	Switch UBound($aName, 2)
		Case 0
			Local $sTemp = ""
			For $iI = 0 To $iLines - 1
				$aName[$iI] = StringReplace($aName[$iI], @LF, "At^LF")
				$sTemp &= $iI & "=" & $aName[$iI] & @LF
			Next
			IniWriteSection($hFile, $sSection, $sTemp, 0)
		Case Else
			Local $aTemp[1], $sString = "", $iColumns = UBound($aName, 2)
			For $iI = 0 To $iLines - 1
				For $jj = 0 To $iColumns - 1
					$aName[$iI][$jj] = StringReplace($aName[$iI][$jj], $defaultSeparator, $defaultSeparatorString)
					$sString &= $aName[$iI][$jj] & $defaultSeparator
				Next
				_ArrayAdd($aTemp, StringTrimRight($sString, 1))
				$sString = ""
			Next
			_ArrayDelete($aTemp, 0)
			_ArrayToIni($hFile, $sSection & "#" & $iColumns & "#" & $defaultSeparator & "#" & $defaultSeparatorString, $aTemp)
	EndSwitch
EndFunc   ;==>_ArrayToIni

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                                  \\\  Pre launch check list  ///                                 ¦
; +-------------------------------------------------+------------------------------------------------+

; Because finding a solid reason not to launch is always a good thing.

Func _PreLaunchChecks()

	;... Is the program already running

	If _Singleton("QuickSilver_v1.0", 1) = 0 Then
		MsgBox($MB_SYSTEMMODAL, "", " QuickSilver is already running! ", 1)
		WinActivate("QuickSilver v1.0 - Textures Unlimited Config Generator.")
		Exit
	EndIf

	;... Is the icon file present and in the right location

	If FileExists(@ScriptDir & "\Assets\QuickSilver.ico") = 0 Then
		MsgBox("", "", "Assets Missing." & @LF & "Please reinstall Quicksilver!")
		Exit
	Else
	EndIf

	;... Is the Settings.ini file present

	If FileExists(@ScriptDir & "\Settings.ini") = 0 Then
		MsgBox("", "", "Settings Missing." & @LF & "Please reinstall Quicksilver!")
		Exit
	Else
	EndIf

	;... Has QuickSilver been disabled via the UI

	Local $OnOffState = IniRead("Settings.ini", "Settings", "Disable", "")
	Local $CFGName = IniRead("Settings.ini", "Settings", "CFG Name", "")

	If $OnOffState = "True" Then
		$ret = MsgBox(4, "Disabled for all mods.", "Do you want to Re-Enabled QuickSilver?")
		If $ret == 6 Then
			If FileExists("QSCFG._") Then FileMove("QSCFG._", $CFGName)
			IniWrite("Settings.ini", "Settings", "Disable", "False")
			Exit
		ElseIf $ret == 7 Then
			SplashTextOn("", " Clearing list.. ", 250 * $iDPI_ratio, 75 * $iDPI_ratio, -1, -1, "", "", 8 * $iDPI_ratio)
			Sleep(800)
		EndIf
		Exit
	EndIf

	;... Is QuickSilver in a subfolder under GameData (Very important, since all paths are assumed as relative to this location)

	Local $InstallPath = String(@ScriptDir)

	If StringInStr(_PathSplit(StringLeft($InstallPath, StringInStr($InstallPath, '\', 0, -1) - 1), "", "", "", "")[$PATH_FILENAME], "GameData") = 0 Then
		MsgBox("", "", "GameData not found!" & @LF & "QuickSilver should be launched from within: " & @LF & "..\GameData\QuickSilver")
		Exit
	Else
	EndIf

	;... Get and set the Kerbal Space Program root path, using the current folder as a point of reference.

	Local $iPath
	$iPath = _PathSplit(StringLeft($InstallPath, StringInStr($InstallPath, '\', 0, -1) - 1), "", "", "", "")
	Global $KSP_ROOT = String($iPath[1] & $iPath[2])
	IniWrite("Settings.ini", "Settings", "KSP Root", $KSP_ROOT) ;... Store root path for later use

EndFunc   ;==>_PreLaunchChecks

;

; +-------------------------------------------------+------------------------------------------------+
; ¦                                           \\\  End  ///                                          ¦
; +-------------------------------------------------+------------------------------------------------+

; ↓                                                 ↓                                                ↓
; ↓                                                 ↓                                                ↓
; ↓                                                 ↓                                                ↓

; ↓                                                 ↓                                                ↓
; ↓                                                 ↓                                                ↓

; ↓                                                 ↓                                                ↓

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                  ;
;                        .***/#/@#*//(###%%##(//**,. .(##,,                        ;
;                     ,/%*&&&/&((//*,.........,,*///,(*/&%&,(/,                    ;
;                    &&&&./..                            .,/#%#%                   ;
;                  &&&/.                                      .,&,                 ;
;               *&&*.              ...        ..                 .((               ;
;             ,&%*                     ..   .   ..                 ..%             ;
;            &@/              ...,*/((/(%&(,.,...**//*.. .           ..,           ;
;          #&#,              ../(##%%%%%%##/**,*(#####(//, .           ,#          ;
;         #@(.            . .,/##%%%%%&%%&%%%###%%%%%##((/,             ,/         ;
;        %@(                ./(#%%%%%%%&%&&%%%%%%%%%%%##((*,             .((       ;
;      &&/*                .*(#%%%%%%%&&&&&&&%&&%%%%%%###(/,              ./&      ;
;    ,.*(/.               ..*(#%%%%%&&&&&&&&&&&&%%%%%%###(/*               ,*,(    ;
;   *.//,.             .  .,/(#%%%%%%&&&&&&&&&&&%%%%%####(/*.            .. ,(, .  ;
;  .../(.        .        .,/(##%%%%%%%%&&&&&&&%%%%%%%###((*.               .**    ;
;  ..*//         .     ...,*((#&@@@@@@@@%%%%%%%%%%%%####((/*..  ...          ,/. . ;
;  , .*,       ............*/(%&@*@@@@@&&##%%%%%%%%###@@@@&%......   .....   ...   ;
;  , .,*    ..............,*/(%& ..@@&&&%##%%%%%%%###@@@@& %#.... .          ,,.   ;
;  ,*...           ... ....*/*/(###%######%%%%%%%%###&&&&& .&.. .  . . . .   *,..  ;
;  .*#... .................*/(***/////(#%%%%%%%%%%%###(#((&/*.,.,.,..,,.,....,..   ;
;   ,(##*..,.,,,,,,,......./(((######%%%%%%%%%%%%%%####(/*,,,,,.............*.*/   ;
;     *(#.*.........,,...../(#####%%%%%%%%%%%%%%%%%%%###((/*......,,,,..,..*./,    ;
;       (#.*,,,*,,,,,,,,,,.*((((*,,,....,,,,,,,****,*****//*,,,,,,,,,,,,,,..,      ;
;        /#,*,,...,.,,,,...*/((#,*                   ,** /**...,,,,,.,,,,, .       ;
;         *##/..,,*,,,.....**//((#&&&@@@@@@@@@@@@@@&&%#%#,,,,,,,,,,,.,... .        ;
;          ,(((((##,..........,,,***////(((((((((////**,,,,....,**..  (//          ;
;             ,/(////((((((((((((((((#(((((#(#(####(((((((((((((/////*,            ;
;                  ,*//***/////////////////////////////*//*/*/****,                ;
;                    .,***,,,,,,,****,*****,********,,,,,,,,,.                     ;
;                    .*/*//*,,***//,(/(***/(#***,(/*****,,.,*.                     ;
;                          ,***##*((/##///*#//*#/(/(*(#***,.                       ;
;                       .////*,, .,**,,...,,,,,...,,,****/*.                       ;
;                   ,((((//***,,,.,... (/..#/#. ..,,,,,**/(((/*.                   ;
;                 ,/*/*/**,,,.   .,*//../(//////.. .  .,*////(((((/                ;
;               *((#(//.. ./   .//////***((###((/..,,    .,((####(#*               ;
;              .*****//*,,., .*///((//,/((((((////..//. ./((/***(/*,;              ;
;              .***/(((##(##(,////(//,,/((((((/////.(#######(/***,,,;              ;
;               /////((((((/.,*/////,...,/////////*(/(((((((/////*.;               ;
;                *////////*,(,,****,,,. ,,***,**/(///////((////**.;                ;
;                 .,*******,.*//**,.,,.,....,,*/((/,*//********,;                  ;
;                     ..... .**/**,,,.       ,.**/((((,,,,,,;                      ;
;                           ,//***,,,.,       *//(((#((/.                          ;
;                           */(((/////*,     ,/(((#####//                          ;
;                           /((((((///*,*    *//((((##(((/.                        ;
;                          ,//**//////**,*   ,*//*,....,///                        ;
;                        .,,,.,,,*,.    .        ,,....,****                       ;
;                   .***,...,     .   .           ....,*///*,                      ;
;                  .*/##*..     .                 .,/##///**.                      ;
;                     ....   .                     ...,..,*.                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                 QuickSilver v1.0 ;
;                                                                       by u\0-0-1 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
