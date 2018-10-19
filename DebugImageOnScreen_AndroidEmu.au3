#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	A small tool made in AutoIt v3 to take screenshots / grab macros / pixel color ,
	inside the Emulator Window handle , useful for those who help us.

#ce ----------------------------------------------------------------------------

#AutoIt3Wrapper_Icon=Main.ico
#AutoIt3Wrapper_Res_Description=DocOC Debug OnScreen
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=ProMac @2018
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_Au3Stripper=y

#include <GDIPlus.au3>
#include <File.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <ColorConstantS.au3>
#include <Constants.au3>
#include <GuiConstants.au3>
#include <StaticConstants.au3>
#include <Date.au3>
#include <ScreenCapture.au3>
#include <MsgBoxConstants.au3>
#include <GDIPlus.au3>
#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include <Misc.au3>

; Enforce variable declarations
Opt("MustDeclareVars", 1)

; ESC as HotKey
HotKeySet("{ESC}", "_Terminate")
HotKeySet("{F2}", "_ScreenCapture")
HotKeySet("{F1}", "_MakeMacro")
HotKeySet("{F3}", "_Help")

Global $g_frmGuiDebug = 0, $g_bDebugOnScreen = False, $g_sAndroidEmulator, $g_aiMouseOffsetWindowOnly, $g_hAndroidWindow, $g_hWnd, $g_aMouse, $g_iColor, $g_lblDebugOnScreen, $g_lblDebugOnScreenColor, $g_lblDebugOnScreenHelp
Global $InstanceName = ""
Global $sSerial = DriveGetSerial(@HomeDrive & "\")


CheckPrerequisites()

If $InstanceName = "" Then Exit

GuiDebug()

If GethandleHwd() = False Then Exit

While 1
	MoveGUIDebug()
	Sleep(100)
	$g_aMouse = GUIGetCursorInfo($g_frmGuiDebug)
	If Not @error Then
		$g_iColor = _GetColor()
		GUICtrlSetData($g_lblDebugOnScreen, " ::DEBUG-IMAGE ONSCREEN @ PROMAC 2018:: -- 'F1'(MakeMacro) -- 'F2'(ScreenCapture) -- 'F3' (HELP) -- 'ESC'(Exit) -- (" & $g_aMouse[0] & "," & $g_aMouse[1] & ") -- 0x" & $g_iColor)
		GUICtrlSetBkColor($g_lblDebugOnScreenColor, '0x' & $g_iColor)
	EndIf
WEnd

Func CheckPrerequisites()
	Local $aWindows = WinList()
	$InstanceName = ""

	$InstanceName = _WinGetallEmulators()
	ConsoleWrite("$emu: " & $InstanceName & @CRLF)
	If $InstanceName = "0" Then Exit
	If StringInStr($InstanceName, "|") > 0 Then
		MsgBox($MB_OK, "Error", "Exist more than one instance.")
		Exit
	EndIf

	Local $sMessage = ""
	SplashTextOn("DocOC Debug Image ONSCREEN", $sMessage, 500, 100, -1, -1, "", "")
	For $i = 5 To 1 Step -1
		$sMessage = $i
		If $InstanceName <> "" Then
			ControlSetText("DocOC Debug Image ONSCREEN", "", "Static1", "Starts in " & $sMessage & " s" & @LF & "Debug will use '" & $InstanceName & "' Instance title")
		Else
			ControlSetText("DocOC Debug Image ONSCREEN", "", "Static1", "Exit in " & $sMessage & " s" & @LF & "Please Open a MEmu or Nox Instance First!")
		EndIf
		Sleep(1000)
	Next
	SplashOff()
EndFunc   ;==>CheckPrerequisites

Func _WinGetallEmulators() ;0 will return 1 base array; leaving it 1 will return the first visible window it finds

	Local $aWindows = _WinAPI_EnumWindowsTop(), $sHold = ""
	; _ArrayDisplay($aWindows)
	For $i = 1 To $aWindows[0][0]
		Local $temp = WinGetTitle($aWindows[$i][0])
		If (StringInStr(WinGetText($aWindows[$i][0]), "RenderWindowWindow") > 0 And $aWindows[$i][1] = "Qt5QWindowIcon") Or _
				(StringInStr(WinGetText($aWindows[$i][0]), "default_title_barWindow") > 0 And $aWindows[$i][1] = "Qt5QWindowIcon") Or _
				($temp = "BlueStacks Android PluginAndroid") Then
			$sHold &= WinGetTitle($aWindows[$i][0]) & "|"
			; ConsoleWrite("$emu: " & WinGetTitle($aWindows[$i][0]) & @CRLF)
		EndIf
	Next
	If Not $sHold = "" Then Return StringTrimRight($sHold, 1)

	Return SetError(1, 0, 0)
EndFunc   ;==>_WinGetallEmulators

Func GethandleHwd()

	; MEmu
	$g_hWnd = ControlGetHandle($InstanceName, "sub", "")
	If IsHWnd($g_hWnd) Then
		$g_hAndroidWindow = ControlGetHandle($g_hWnd, "sub", "[CLASS:subWin; INSTANCE:1]")
		If IsHWnd($g_hAndroidWindow) Then Return True
	EndIf
	; Nox
	$g_hWnd = ControlGetHandle($InstanceName, "sub", "")
	If IsHWnd($g_hWnd) Then
		$g_hAndroidWindow = ControlGetHandle($g_hWnd, "sub", "[CLASS:subWin; INSTANCE:1]")
		If IsHWnd($g_hAndroidWindow) Then Return True
	EndIf
	; Nox 6.2.2
	$g_hWnd = ControlGetHandle($InstanceName, "QWidgetClassWindow", "")
	If IsHWnd($g_hWnd) Then
		$g_hAndroidWindow = ControlGetHandle($g_hWnd, "QWidgetClassWindow", "[CLASS:Qt5QWindowIcon; INSTANCE:2]")
		If IsHWnd($g_hAndroidWindow) Then Return True
	EndIf
	; BlueStacks2
	$g_hWnd = WinWait("[TITLE:BlueStacks Android PluginAndroid]", "_ctl.Window", 35)
	If IsHWnd($g_hWnd) Then
		$g_hAndroidWindow = ControlGetHandle($g_hWnd, "_ctl.Window", "[CLASS:BlueStacksApp; INSTANCE:1]")
		If IsHWnd($g_hAndroidWindow) Then Return True
	EndIf

	Return False

EndFunc   ;==>GethandleHwd

Func _UIA_Debug($tX, $tY, $tWidth, $tHeight, $sFileName, $color = 0x0000FF, $PenWidth = 4)

	If $g_frmGuiDebug = 0 Then Return
	Local $Xaxis = $tX, $Yaxis = $tY

	If $sFileName = "" Then $sFileName = "Click"
	GUISetBkColor(0xABCDEF, $g_frmGuiDebug)
	_WinAPI_RedrawWindow($g_frmGuiDebug, 0, 0, $RDW_INVALIDATE + $RDW_ALLCHILDREN)

	Local $hDC, $hPen, $obj_orig, $x1, $x2, $y1, $y2
	$x1 = $tX - $tWidth / 2
	$y1 = $tY - $tHeight / 2
	$x2 = $tWidth / 2 + $tX
	$y2 = $tHeight / 2 + $tY

	Local $g_tRECT = DllStructCreate($tagRect)
	DllStructSetData($g_tRECT, "Left", $x1)
	DllStructSetData($g_tRECT, "Top", $y1 - 20)
	DllStructSetData($g_tRECT, "Right", $x1 + 250)
	DllStructSetData($g_tRECT, "Bottom", $y1)

	$hDC = _WinAPI_GetWindowDC($g_frmGuiDebug) ; DC of entire screen (desktop)
	$hPen = _WinAPI_CreatePen($PS_SOLID, $PenWidth, $color) ; BGR
	$obj_orig = _WinAPI_SelectObject($hDC, $hPen)

	_WinAPI_DrawLine($hDC, $x1, $y1, $x2, $y1) ; horizontal to right
	_WinAPI_DrawLine($hDC, $x2, $y1, $x2, $y2) ; vertical down on right
	_WinAPI_DrawLine($hDC, $x2, $y2, $x1, $y2) ; horizontal to left right
	_WinAPI_DrawLine($hDC, $x1, $y2, $x1, $y1) ; vertical up on left
	_WinAPI_DrawText($hDC, $sFileName & "(" & $Xaxis & "," & $Yaxis & ")", $g_tRECT, $DT_LEFT)


	; clear resources
	_WinAPI_SelectObject($hDC, $obj_orig)
	_WinAPI_DeleteObject($hPen)
	_WinAPI_ReleaseDC(0, $hDC)
	;_WinAPI_InvalidateRect($Handle, 0)
	;$g_tRECT = 0

EndFunc   ;==>_UIA_Debug

Func MoveGUIDebug()

	If $g_frmGuiDebug = 0 Then Return
	Local $aPos = WinGetPos($g_hAndroidWindow, "")
	If Not IsArray($aPos) Then
		GethandleHwd()
	EndIf
	$aPos = WinGetPos($g_hAndroidWindow, "")
	; ConsoleWrite("Nox handle: " & $g_hAndroidWindow & " sizes: " & $aPos[2] & "x" & $aPos[3] & @CRLF)
	WinMove($g_frmGuiDebug, "", $aPos[0], $aPos[1], $aPos[2], $aPos[3])

EndFunc   ;==>MoveGUIDebug

Func GuiDebug()

	$g_frmGuiDebug = GUICreate("DEBUG-IMAGE ONSCREEN @ PROMAC 2018 ", 860 - 6, 732 - 29, -1, -1, -1, $WS_EX_LAYERED)
	;GUISetIcon(@ScriptDir & "\MainCode\Lib\ImageSearch.dll", 1)
	$g_lblDebugOnScreen = GUICtrlCreateLabel(" ::DEBUG-IMAGE ONSCREEN @ PROMAC 2018:: -- 'F1'(MakeMacro) -- 'F2'(ScreenCapture) -- 'F3' (HELP) -- 'ESC'(Exit) -- ", 0, 0, 700, 14, -1, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetBkColor($g_lblDebugOnScreen, $COLOR_WHITE)
	$g_lblDebugOnScreenColor = GUICtrlCreateLabel("  ", 700, 0, 50, 14, $SS_CENTER, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetBkColor($g_lblDebugOnScreenColor, $COLOR_WHITE)
	$g_lblDebugOnScreenHelp = GUICtrlCreateLabel("Standby", 750, 0, 100, 14, $SS_CENTER, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetBkColor($g_lblDebugOnScreenHelp, $COLOR_WHITE)
	GUISetBkColor(0xABCDEF)
	_WinAPI_SetLayeredWindowAttributes($g_frmGuiDebug, 0xABCDEF)
	GUISetState(@SW_SHOW)
	WinSetOnTop($g_frmGuiDebug, "", $WINDOWS_ONTOP)
	GUISetStyle($WS_POPUP + $WS_BORDER, -1, $g_frmGuiDebug)

EndFunc   ;==>GuiDebug

Func _MakeMacro()
	GUICtrlSetData($g_lblDebugOnScreenHelp, "Clicks: 0")
	Local Static $sFilePath = ""
	Local Static $hTimer = 0
	If $sFilePath = "" Then $sFilePath = @DesktopDir & "\" & @HOUR & "_" & @MIN & "_" & @SEC & ".au3"
	$hTimer = TimerInit()
	Local $hDLL = DllOpen("user32.dll")
	Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)
	FileWrite($hFileOpen, ";	" & _Now() & " - MybotRun - ProMac @2018 - Macro - " & @CRLF)
	FileClose($hFileOpen)
	Local $Click = 0

	While Not _IsPressed("02", $hDLL)
		; Left Click Detected
		If _IsPressed("01", $hDLL) Then
			$Click += 1
			GUICtrlSetData($g_lblDebugOnScreenHelp, "Clicks: " & $Click)
			$g_aMouse = GUIGetCursorInfo($g_frmGuiDebug)
			$g_iColor = _GetColor()
			GUICtrlSetData($g_lblDebugOnScreen, " ::DEBUG-IMAGE ONSCREEN @ PROMAC 2018:: -- 'F1'(MakeMacro) -- 'F2'(ScreenCapture) -- 'F3' (HELP) -- 'ESC'(Exit) -- (" & $g_aMouse[0] & "," & $g_aMouse[1] & ") -- 0x" & $g_iColor)
			GUICtrlSetBkColor($g_lblDebugOnScreenColor, '0x' & $g_iColor)
			_UIA_Debug($g_aMouse[0], $g_aMouse[1], 20, 20, "Click")

			Local $fDiff = Floor(TimerDiff($hTimer))
			Local $Sleep = "If _Sleep(" & $fDiff & ") Then Return"

			Local $sTopText = ";	[0] = X-Axis , [1] = Y-Axis , [2] = Color Hex , [3] = Tolerance"
			Local $sVariableStruc = "Local $aArray = [" & $g_aMouse[0] & ", " & $g_aMouse[1] & ", 0x" & $g_iColor & ", 10]"
			Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)

			FileWrite($hFileOpen, $Sleep & @CRLF & ";	" & _Now() & @CRLF & $sTopText & @CRLF & $sVariableStruc & @CRLF & @CRLF)
			FileClose($hFileOpen)
			; Wait until Left Click is released.
			While _IsPressed("01", $hDLL)
				Sleep(250)
			WEnd
			$hTimer = TimerInit()
		EndIf
	WEnd
	DllClose($hDLL)
	GUICtrlSetData($g_lblDebugOnScreenHelp, @HotKeyPressed)
	GUISetBkColor(0xABCDEF, $g_frmGuiDebug)
	_WinAPI_RedrawWindow($g_frmGuiDebug, 0, 0, $RDW_INVALIDATE + $RDW_ALLCHILDREN)
EndFunc   ;==>_MakeMacro

Func _ScreenCapture()
	GUICtrlSetData($g_lblDebugOnScreenHelp, "ScreenCap")
	_GDIPlus_Startup()
	Local Static $n = 0
	Local $path = @DesktopCommonDir & "\OnScreen_0x" & $g_iColor & "_" & $g_aMouse[0] & "x" & $g_aMouse[1] & "_Image" & $n & ".png"
	WinActivate($g_hWnd)
	Local $hPen = _GDIPlus_PenCreate(0xFFF90E0E, 2) ;color format AARRGGBB (hex)
	Local $hbitmap = _BitmapCapture()
	Local $hImage1 = _GDIPlus_BitmapCreateFromHBITMAP($hbitmap)
	Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hImage1)
	_GDIPlus_GraphicsDrawRect($hGraphics, $g_aMouse[0] - 4, $g_aMouse[1] - 4, 8, 8, $hPen)
	_GDIPlus_ImageSaveToFile($hImage1, $path)

	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_ImageDispose($hImage1)
	_WinAPI_DeleteObject($hbitmap)
	_GDIPlus_PenDispose($hPen)

	$n += 1
	_GDIPlus_Shutdown()
	GUICtrlSetData($g_lblDebugOnScreenHelp, @HotKeyPressed)
EndFunc   ;==>_ScreenCapture

Func _BitmapCapture()
	; a handle to an hBitmap
	Return _ScreenCapture_CaptureWnd("", $g_frmGuiDebug, 0, 0, -1, -1, False)
EndFunc   ;==>_BitmapCapture

Func _BitmapCaptureBck()
	_GDIPlus_Startup()
	Local $aPos = WinGetPos($g_hAndroidWindow, "")
	Local $hDC_Capture = _WinAPI_GetWindowDC($g_hAndroidWindow)
	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
	Local $hHBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $aPos[2], $aPos[3])
	Local $hObject = _WinAPI_SelectObject($hMemDC, $hHBitmap)
	DllCall("user32.dll", "int", "PrintWindow", "hwnd", $g_hAndroidWindow, "handle", $hMemDC, "int", 0)
	_WinAPI_DeleteDC($hMemDC)
	Local $hObject = _WinAPI_SelectObject($hMemDC, $hObject)
	_WinAPI_ReleaseDC($g_hAndroidWindow, $hDC_Capture)
	Local $hBmp = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
	_WinAPI_DeleteObject($hHBitmap)
	_GDIPlus_Shutdown()
	Return $hBmp
EndFunc   ;==>_BitmapCaptureBck

Func _VideoRecord()
	_GDIPlus_Startup()
	GUICtrlSetData($g_lblDebugOnScreenHelp, "RecordVideo")
	Local $sFile = @ScriptDir & "\Record.avi"
	FileDelete($sFile)
	Local $rec_duration = 60 ; 60 seconds
	Local $fps = 10
	Local $aPos = WinGetPos($g_frmGuiDebug, "")
	; TODO with FFMPEG
	; _WinAPI_CreateProcess
	; $tStartupInfo
	;
	_GDIPlus_Shutdown()
	GUICtrlSetData($g_lblDebugOnScreenHelp, @HotKeyPressed)
EndFunc   ;==>_VideoRecord

Func _GetColor()
	Local $Mouse1 = MouseGetPos()
	Local $iColor = Hex(PixelGetColor($Mouse1[0], $Mouse1[1], $g_frmGuiDebug), 6)
	Return $iColor
EndFunc   ;==>_GetColor

Func _Help()
	GUICtrlSetData($g_lblDebugOnScreenHelp, "HELP")
	Local $Txt = "'ESC'" & @TAB & "- Exit " & @CRLF & _
			"'F1' " & @TAB & "- Grabs all yours left click with coordinates and " & @CRLF & _
			@TAB & "   pixel color to a .au3, Right click will stop it." & @CRLF & _
			"'F2' " & @TAB & "- Takes a Screencapture and save it to your desktop" & @CRLF & _
			"'F3' " & @TAB & "- Help Message" & @CRLF
	MsgBox($MB_OK + $MB_ICONINFORMATION, "DEBUG-IMAGE ONSCREEN @ PROMAC 2018", $Txt, 30)
	GUICtrlSetData($g_lblDebugOnScreenHelp, "Standby")
EndFunc   ;==>_Help

Func _Terminate()
	Exit
EndFunc   ;==>_Terminate



