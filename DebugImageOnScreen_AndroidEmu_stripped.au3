Global Const $GDIP_EPGCOLORDEPTH = '{66087055-AD66-4C7C-9A18-38A2310B8337}'
Global Const $GDIP_EPGCOMPRESSION = '{E09D739D-CCD4-44EE-8EBA-3FBF8BE4FC58}'
Global Const $GDIP_EPGQUALITY = '{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}'
Global Const $GDIP_EPTLONG = 4
Global Const $GDIP_EVTCOMPRESSIONLZW = 2
Global Const $GDIP_PXF24RGB = 0x00021808
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagSYSTEMTIME = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $tagGDIPENCODERPARAM = "struct;byte GUID[16];ulong NumberOfValues;ulong Type;ptr Values;endstruct"
Global Const $tagGDIPENCODERPARAMS = "uint Count;" & $tagGDIPENCODERPARAM
Global Const $tagGDIPSTARTUPINPUT = "uint Version;ptr Callback;bool NoThread;bool NoCodecs"
Global Const $tagGDIPIMAGECODECINFO = "byte CLSID[16];byte FormatID[16];ptr CodecName;ptr DllName;ptr FormatDesc;ptr FileExt;" & "ptr MimeType;dword Flags;dword Version;dword SigCount;dword SigSize;ptr SigPattern;ptr SigMask"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Global Const $tagGUID = "struct;ulong Data1;ushort Data2;ushort Data3;byte Data4[8];endstruct"
Global Const $WINDOWS_ONTOP = 1
Global Const $FO_APPEND = 1
Global Const $MB_OK = 0
Global Const $MB_ICONINFORMATION = 64
Global Const $tagOSVERSIONINFO = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $__tagCURSORINFO = "dword Size;dword Flags;handle hCursor;" & "struct;long X;long Y;endstruct"
Global Const $__WINVER = __WINVER()
Func _WinAPI_GetCursorInfo()
Local $tCursor = DllStructCreate($__tagCURSORINFO)
Local $iCursor = DllStructGetSize($tCursor)
DllStructSetData($tCursor, "Size", $iCursor)
Local $aRet = DllCall("user32.dll", "bool", "GetCursorInfo", "struct*", $tCursor)
If @error Or Not $aRet[0] Then Return SetError(@error + 10, @extended, 0)
Local $aCursor[5]
$aCursor[0] = True
$aCursor[1] = DllStructGetData($tCursor, "Flags") <> 0
$aCursor[2] = DllStructGetData($tCursor, "hCursor")
$aCursor[3] = DllStructGetData($tCursor, "X")
$aCursor[4] = DllStructGetData($tCursor, "Y")
Return $aCursor
EndFunc
Func __WINVER()
Local $tOSVI = DllStructCreate($tagOSVERSIONINFO)
DllStructSetData($tOSVI, 1, DllStructGetSize($tOSVI))
Local $aRet = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $tOSVI)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($tOSVI, 2), -8), DllStructGetData($tOSVI, 3))
EndFunc
Global Const $STR_NOCASESENSEBASIC = 2
Global Const $STR_STRIPLEADING = 1
Global Const $STR_STRIPTRAILING = 2
Func _WinAPI_GUIDFromString($sGUID)
Local $tGUID = DllStructCreate($tagGUID)
_WinAPI_GUIDFromStringEx($sGUID, $tGUID)
If @error Then Return SetError(@error + 10, @extended, 0)
Return $tGUID
EndFunc
Func _WinAPI_GUIDFromStringEx($sGUID, $tGUID)
Local $aResult = DllCall("ole32.dll", "long", "CLSIDFromString", "wstr", $sGUID, "struct*", $tGUID)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_StringFromGUID($tGUID)
Local $aResult = DllCall("ole32.dll", "int", "StringFromGUID2", "struct*", $tGUID, "wstr", "", "int", 40)
If @error Or Not $aResult[0] Then Return SetError(@error, @extended, "")
Return SetExtended($aResult[0], $aResult[2])
EndFunc
Func _WinAPI_WideCharToMultiByte($vUnicode, $iCodePage = 0, $bRetNoStruct = True, $bRetBinary = False)
Local $sUnicodeType = "wstr"
If Not IsString($vUnicode) Then $sUnicodeType = "struct*"
Local $aResult = DllCall("kernel32.dll", "int", "WideCharToMultiByte", "uint", $iCodePage, "dword", 0, $sUnicodeType, $vUnicode, "int", -1, "ptr", 0, "int", 0, "ptr", 0, "ptr", 0)
If @error Or Not $aResult[0] Then Return SetError(@error + 20, @extended, "")
Local $tMultiByte = DllStructCreate((($bRetBinary) ?("byte") :("char")) & "[" & $aResult[0] & "]")
$aResult = DllCall("kernel32.dll", "int", "WideCharToMultiByte", "uint", $iCodePage, "dword", 0, $sUnicodeType, $vUnicode, "int", -1, "struct*", $tMultiByte, "int", $aResult[0], "ptr", 0, "ptr", 0)
If @error Or Not $aResult[0] Then Return SetError(@error + 10, @extended, "")
If $bRetNoStruct Then Return DllStructGetData($tMultiByte, 1)
Return $tMultiByte
EndFunc
Func _WinAPI_DeleteObject($hObject)
Local $aResult = DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hObject)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_SelectObject($hDC, $hGDIObj)
Local $aResult = DllCall("gdi32.dll", "handle", "SelectObject", "handle", $hDC, "handle", $hGDIObj)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_BitBlt($hDestDC, $iXDest, $iYDest, $iWidth, $iHeight, $hSrcDC, $iXSrc, $iYSrc, $iROP)
Local $aResult = DllCall("gdi32.dll", "bool", "BitBlt", "handle", $hDestDC, "int", $iXDest, "int", $iYDest, "int", $iWidth, "int", $iHeight, "handle", $hSrcDC, "int", $iXSrc, "int", $iYSrc, "dword", $iROP)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
Local $aResult = DllCall("gdi32.dll", "handle", "CreateCompatibleBitmap", "handle", $hDC, "int", $iWidth, "int", $iHeight)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_RedrawWindow($hWnd, $tRECT = 0, $hRegion = 0, $iFlags = 5)
Local $aResult = DllCall("user32.dll", "bool", "RedrawWindow", "hwnd", $hWnd, "struct*", $tRECT, "handle", $hRegion, "uint", $iFlags)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_CreateCompatibleDC($hDC)
Local $aResult = DllCall("gdi32.dll", "handle", "CreateCompatibleDC", "handle", $hDC)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_DeleteDC($hDC)
Local $aResult = DllCall("gdi32.dll", "bool", "DeleteDC", "handle", $hDC)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_DrawIcon($hDC, $iX, $iY, $hIcon)
Local $aResult = DllCall("user32.dll", "bool", "DrawIcon", "handle", $hDC, "int", $iX, "int", $iY, "handle", $hIcon)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_DrawText($hDC, $sText, ByRef $tRECT, $iFlags)
Local $aResult = DllCall("user32.dll", "int", "DrawTextW", "handle", $hDC, "wstr", $sText, "int", -1, "struct*", $tRECT, "uint", $iFlags)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetDC($hWnd)
Local $aResult = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetWindowDC($hWnd)
Local $aResult = DllCall("user32.dll", "handle", "GetWindowDC", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_ReleaseDC($hWnd, $hDC)
Local $aResult = DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $hWnd, "handle", $hDC)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Global Const $tagICONINFO = "bool Icon;dword XHotSpot;dword YHotSpot;handle hMask;handle hColor"
Func _WinAPI_CopyIcon($hIcon)
Local $aResult = DllCall("user32.dll", "handle", "CopyIcon", "handle", $hIcon)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_DestroyIcon($hIcon)
Local $aResult = DllCall("user32.dll", "bool", "DestroyIcon", "handle", $hIcon)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_GetIconInfo($hIcon)
Local $tInfo = DllStructCreate($tagICONINFO)
Local $aRet = DllCall("user32.dll", "bool", "GetIconInfo", "handle", $hIcon, "struct*", $tInfo)
If @error Or Not $aRet[0] Then Return SetError(@error + 10, @extended, 0)
Local $aIcon[6]
$aIcon[0] = True
$aIcon[1] = DllStructGetData($tInfo, "Icon") <> 0
$aIcon[2] = DllStructGetData($tInfo, "XHotSpot")
$aIcon[3] = DllStructGetData($tInfo, "YHotSpot")
$aIcon[4] = DllStructGetData($tInfo, "hMask")
$aIcon[5] = DllStructGetData($tInfo, "hColor")
Return $aIcon
EndFunc
Func _WinAPI_CreatePen($iPenStyle, $iWidth, $iColor)
Local $aResult = DllCall("gdi32.dll", "handle", "CreatePen", "int", $iPenStyle, "int", $iWidth, "INT", $iColor)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_DrawLine($hDC, $iX1, $iY1, $iX2, $iY2)
_WinAPI_MoveTo($hDC, $iX1, $iY1)
If @error Then Return SetError(@error, @extended, False)
_WinAPI_LineTo($hDC, $iX2, $iY2)
If @error Then Return SetError(@error + 10, @extended, False)
Return True
EndFunc
Func _WinAPI_LineTo($hDC, $iX, $iY)
Local $aResult = DllCall("gdi32.dll", "bool", "LineTo", "handle", $hDC, "int", $iX, "int", $iY)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_MoveTo($hDC, $iX, $iY)
Local $aResult = DllCall("gdi32.dll", "bool", "MoveToEx", "handle", $hDC, "int", $iX, "int", $iY, "ptr", 0)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Global $__g_hGDIPDll = 0
Global $__g_hGDIPPen = 0
Global $__g_iGDIPRef = 0
Global $__g_iGDIPToken = 0
Global $__g_bGDIP_V1_0 = True
Func _GDIPlus_BitmapCloneArea($hBitmap, $nLeft, $nTop, $nWidth, $nHeight, $iFormat = 0x00021808)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCloneBitmapArea", "float", $nLeft, "float", $nTop, "float", $nWidth, "float", $nHeight, "int", $iFormat, "handle", $hBitmap, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[7]
EndFunc
Func _GDIPlus_BitmapCreateFromHBITMAP($hBitmap, $hPal = 0)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateBitmapFromHBITMAP", "handle", $hBitmap, "handle", $hPal, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[3]
EndFunc
Func _GDIPlus_Encoders()
Local $iCount = _GDIPlus_EncodersGetCount()
Local $iSize = _GDIPlus_EncodersGetSize()
Local $tBuffer = DllStructCreate("byte[" & $iSize & "]")
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageEncoders", "uint", $iCount, "uint", $iSize, "struct*", $tBuffer)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Local $pBuffer = DllStructGetPtr($tBuffer)
Local $tCodec, $aInfo[$iCount + 1][14]
$aInfo[0][0] = $iCount
For $iI = 1 To $iCount
$tCodec = DllStructCreate($tagGDIPIMAGECODECINFO, $pBuffer)
$aInfo[$iI][1] = _WinAPI_StringFromGUID(DllStructGetPtr($tCodec, "CLSID"))
$aInfo[$iI][2] = _WinAPI_StringFromGUID(DllStructGetPtr($tCodec, "FormatID"))
$aInfo[$iI][3] = _WinAPI_WideCharToMultiByte(DllStructGetData($tCodec, "CodecName"))
$aInfo[$iI][4] = _WinAPI_WideCharToMultiByte(DllStructGetData($tCodec, "DllName"))
$aInfo[$iI][5] = _WinAPI_WideCharToMultiByte(DllStructGetData($tCodec, "FormatDesc"))
$aInfo[$iI][6] = _WinAPI_WideCharToMultiByte(DllStructGetData($tCodec, "FileExt"))
$aInfo[$iI][7] = _WinAPI_WideCharToMultiByte(DllStructGetData($tCodec, "MimeType"))
$aInfo[$iI][8] = DllStructGetData($tCodec, "Flags")
$aInfo[$iI][9] = DllStructGetData($tCodec, "Version")
$aInfo[$iI][10] = DllStructGetData($tCodec, "SigCount")
$aInfo[$iI][11] = DllStructGetData($tCodec, "SigSize")
$aInfo[$iI][12] = DllStructGetData($tCodec, "SigPattern")
$aInfo[$iI][13] = DllStructGetData($tCodec, "SigMask")
$pBuffer += DllStructGetSize($tCodec)
Next
Return $aInfo
EndFunc
Func _GDIPlus_EncodersGetCLSID($sFileExtension)
Local $aEncoders = _GDIPlus_Encoders()
If @error Then Return SetError(@error, 0, "")
For $iI = 1 To $aEncoders[0][0]
If StringInStr($aEncoders[$iI][6], "*." & $sFileExtension) > 0 Then Return $aEncoders[$iI][1]
Next
Return SetError(-1, -1, "")
EndFunc
Func _GDIPlus_EncodersGetCount()
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageEncodersSize", "uint*", 0, "uint*", 0)
If @error Then Return SetError(@error, @extended, -1)
If $aResult[0] Then Return SetError(10, $aResult[0], -1)
Return $aResult[1]
EndFunc
Func _GDIPlus_EncodersGetSize()
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageEncodersSize", "uint*", 0, "uint*", 0)
If @error Then Return SetError(@error, @extended, -1)
If $aResult[0] Then Return SetError(10, $aResult[0], -1)
Return $aResult[2]
EndFunc
Func _GDIPlus_GraphicsDispose($hGraphics)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDeleteGraphics", "handle", $hGraphics)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsDrawRect($hGraphics, $nX, $nY, $nWidth, $nHeight, $hPen = 0)
__GDIPlus_PenDefCreate($hPen)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDrawRectangle", "handle", $hGraphics, "handle", $hPen, "float", $nX, "float", $nY, "float", $nWidth, "float", $nHeight)
__GDIPlus_PenDefDispose()
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_ImageDispose($hImage)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDisposeImage", "handle", $hImage)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_ImageGetGraphicsContext($hImage)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageGraphicsContext", "handle", $hImage, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[2]
EndFunc
Func _GDIPlus_ImageGetHeight($hImage)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageHeight", "handle", $hImage, "uint*", 0)
If @error Then Return SetError(@error, @extended, -1)
If $aResult[0] Then Return SetError(10, $aResult[0], -1)
Return $aResult[2]
EndFunc
Func _GDIPlus_ImageGetWidth($hImage)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageWidth", "handle", $hImage, "uint*", -1)
If @error Then Return SetError(@error, @extended, -1)
If $aResult[0] Then Return SetError(10, $aResult[0], -1)
Return $aResult[2]
EndFunc
Func _GDIPlus_ImageSaveToFile($hImage, $sFileName)
Local $sExt = __GDIPlus_ExtractFileExt($sFileName)
Local $sCLSID = _GDIPlus_EncodersGetCLSID($sExt)
If $sCLSID = "" Then Return SetError(-1, 0, False)
Local $bRet = _GDIPlus_ImageSaveToFileEx($hImage, $sFileName, $sCLSID, 0)
Return SetError(@error, @extended, $bRet)
EndFunc
Func _GDIPlus_ImageSaveToFileEx($hImage, $sFileName, $sEncoder, $tParams = 0)
Local $tGUID = _WinAPI_GUIDFromString($sEncoder)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipSaveImageToFile", "handle", $hImage, "wstr", $sFileName, "struct*", $tGUID, "struct*", $tParams)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_ParamAdd(ByRef $tParams, $sGUID, $iNbOfValues, $iType, $pValues)
Local $iCount = DllStructGetData($tParams, "Count")
Local $pGUID = DllStructGetPtr($tParams, "GUID") +($iCount * _GDIPlus_ParamSize())
Local $tParam = DllStructCreate($tagGDIPENCODERPARAM, $pGUID)
_WinAPI_GUIDFromStringEx($sGUID, $pGUID)
DllStructSetData($tParam, "Type", $iType)
DllStructSetData($tParam, "NumberOfValues", $iNbOfValues)
DllStructSetData($tParam, "Values", $pValues)
DllStructSetData($tParams, "Count", $iCount + 1)
EndFunc
Func _GDIPlus_ParamInit($iCount)
Local $sStruct = $tagGDIPENCODERPARAMS
For $i = 2 To $iCount
$sStruct &= ";struct;byte[16];ulong;ulong;ptr;endstruct"
Next
Return DllStructCreate($sStruct)
EndFunc
Func _GDIPlus_ParamSize()
Local $tParam = DllStructCreate($tagGDIPENCODERPARAM)
Return DllStructGetSize($tParam)
EndFunc
Func _GDIPlus_PenCreate($iARGB = 0xFF000000, $nWidth = 1, $iUnit = 2)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreatePen1", "dword", $iARGB, "float", $nWidth, "int", $iUnit, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[4]
EndFunc
Func _GDIPlus_PenDispose($hPen)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDeletePen", "handle", $hPen)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_Shutdown()
If $__g_hGDIPDll = 0 Then Return SetError(-1, -1, False)
$__g_iGDIPRef -= 1
If $__g_iGDIPRef = 0 Then
DllCall($__g_hGDIPDll, "none", "GdiplusShutdown", "ulong_ptr", $__g_iGDIPToken)
DllClose($__g_hGDIPDll)
$__g_hGDIPDll = 0
EndIf
Return True
EndFunc
Func _GDIPlus_Startup($sGDIPDLL = Default, $bRetDllHandle = False)
$__g_iGDIPRef += 1
If $__g_iGDIPRef > 1 Then Return True
If $sGDIPDLL = Default Then $sGDIPDLL = "gdiplus.dll"
$__g_hGDIPDll = DllOpen($sGDIPDLL)
If $__g_hGDIPDll = -1 Then
$__g_iGDIPRef = 0
Return SetError(1, 2, False)
EndIf
Local $sVer = FileGetVersion($sGDIPDLL)
$sVer = StringSplit($sVer, ".")
If $sVer[1] > 5 Then $__g_bGDIP_V1_0 = False
Local $tInput = DllStructCreate($tagGDIPSTARTUPINPUT)
Local $tToken = DllStructCreate("ulong_ptr Data")
DllStructSetData($tInput, "Version", 1)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdiplusStartup", "struct*", $tToken, "struct*", $tInput, "ptr", 0)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
$__g_iGDIPToken = DllStructGetData($tToken, "Data")
If $bRetDllHandle Then Return $__g_hGDIPDll
Return SetExtended($sVer[1], True)
EndFunc
Func __GDIPlus_ExtractFileExt($sFileName, $bNoDot = True)
Local $iIndex = __GDIPlus_LastDelimiter(".\:", $sFileName)
If($iIndex > 0) And(StringMid($sFileName, $iIndex, 1) = '.') Then
If $bNoDot Then
Return StringMid($sFileName, $iIndex + 1)
Else
Return StringMid($sFileName, $iIndex)
EndIf
Else
Return ""
EndIf
EndFunc
Func __GDIPlus_LastDelimiter($sDelimiters, $sString)
Local $sDelimiter, $iN
For $iI = 1 To StringLen($sDelimiters)
$sDelimiter = StringMid($sDelimiters, $iI, 1)
$iN = StringInStr($sString, $sDelimiter, $STR_NOCASESENSEBASIC, -1)
If $iN > 0 Then Return $iN
Next
EndFunc
Func __GDIPlus_PenDefCreate(ByRef $hPen)
If $hPen = 0 Then
$__g_hGDIPPen = _GDIPlus_PenCreate()
$hPen = $__g_hGDIPPen
EndIf
EndFunc
Func __GDIPlus_PenDefDispose($iCurError = @error, $iCurExtended = @extended)
If $__g_hGDIPPen <> 0 Then
_GDIPlus_PenDispose($__g_hGDIPPen)
$__g_hGDIPPen = 0
EndIf
Return SetError($iCurError, $iCurExtended)
EndFunc
Global Const $_ARRAYCONSTANT_SORTINFOSIZE = 11
Global $__g_aArrayDisplay_SortInfo[$_ARRAYCONSTANT_SORTINFOSIZE]
Global Const $_ARRAYCONSTANT_tagLVITEM = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
#Au3Stripper_Ignore_Funcs=__ArrayDisplay_SortCallBack
Func __ArrayDisplay_SortCallBack($nItem1, $nItem2, $hWnd)
If $__g_aArrayDisplay_SortInfo[3] = $__g_aArrayDisplay_SortInfo[4] Then
If Not $__g_aArrayDisplay_SortInfo[7] Then
$__g_aArrayDisplay_SortInfo[5] *= -1
$__g_aArrayDisplay_SortInfo[7] = 1
EndIf
Else
$__g_aArrayDisplay_SortInfo[7] = 1
EndIf
$__g_aArrayDisplay_SortInfo[6] = $__g_aArrayDisplay_SortInfo[3]
Local $sVal1 = __ArrayDisplay_GetItemText($hWnd, $nItem1, $__g_aArrayDisplay_SortInfo[3])
Local $sVal2 = __ArrayDisplay_GetItemText($hWnd, $nItem2, $__g_aArrayDisplay_SortInfo[3])
If $__g_aArrayDisplay_SortInfo[8] = 1 Then
If(StringIsFloat($sVal1) Or StringIsInt($sVal1)) Then $sVal1 = Number($sVal1)
If(StringIsFloat($sVal2) Or StringIsInt($sVal2)) Then $sVal2 = Number($sVal2)
EndIf
Local $nResult
If $__g_aArrayDisplay_SortInfo[8] < 2 Then
$nResult = 0
If $sVal1 < $sVal2 Then
$nResult = -1
ElseIf $sVal1 > $sVal2 Then
$nResult = 1
EndIf
Else
$nResult = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $sVal1, 'wstr', $sVal2)[0]
EndIf
$nResult = $nResult * $__g_aArrayDisplay_SortInfo[5]
Return $nResult
EndFunc
Func __ArrayDisplay_GetItemText($hWnd, $iIndex, $iSubItem = 0)
Local $tBuffer = DllStructCreate("wchar Text[4096]")
Local $pBuffer = DllStructGetPtr($tBuffer)
Local $tItem = DllStructCreate($_ARRAYCONSTANT_tagLVITEM)
DllStructSetData($tItem, "SubItem", $iSubItem)
DllStructSetData($tItem, "TextMax", 4096)
DllStructSetData($tItem, "Text", $pBuffer)
If IsHWnd($hWnd) Then
DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", 0x1073, "wparam", $iIndex, "struct*", $tItem)
Else
Local $pItem = DllStructGetPtr($tItem)
GUICtrlSendMsg($hWnd, 0x1073, $iIndex, $pItem)
EndIf
Return DllStructGetData($tBuffer, "Text")
EndFunc
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $KF_EXTENDED = 0x0100
Global Const $KF_ALTDOWN = 0x2000
Global Const $KF_UP = 0x8000
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)
Global $__g_aWinList_WinAPI[64][2] = [[0, 0]]
Global Const $GW_HWNDNEXT = 2
Global Const $GW_CHILD = 5
Func _WinAPI_GetDesktopWindow()
Local $aResult = DllCall("user32.dll", "hwnd", "GetDesktopWindow")
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_EnumWindowsTop()
__WinAPI_EnumWindowsInit()
Local $hWnd = _WinAPI_GetWindow(_WinAPI_GetDesktopWindow(), $GW_CHILD)
While $hWnd <> 0
If _WinAPI_IsWindowVisible($hWnd) Then __WinAPI_EnumWindowsAdd($hWnd)
$hWnd = _WinAPI_GetWindow($hWnd, $GW_HWNDNEXT)
WEnd
Return $__g_aWinList_WinAPI
EndFunc
Func _WinAPI_GetClassName($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $aResult = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
If @error Or Not $aResult[0] Then Return SetError(@error, @extended, '')
Return SetExtended($aResult[0], $aResult[2])
EndFunc
Func _WinAPI_GetSystemMetrics($iIndex)
Local $aResult = DllCall("user32.dll", "int", "GetSystemMetrics", "int", $iIndex)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetWindow($hWnd, $iCmd)
Local $aResult = DllCall("user32.dll", "hwnd", "GetWindow", "hwnd", $hWnd, "uint", $iCmd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetWindowRect($hWnd)
Local $tRECT = DllStructCreate($tagRECT)
Local $aRet = DllCall("user32.dll", "bool", "GetWindowRect", "hwnd", $hWnd, "struct*", $tRECT)
If @error Or Not $aRet[0] Then Return SetError(@error + 10, @extended, 0)
Return $tRECT
EndFunc
Func _WinAPI_IsWindowVisible($hWnd)
Local $aResult = DllCall("user32.dll", "bool", "IsWindowVisible", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func __WinAPI_EnumWindowsAdd($hWnd, $sClass = "")
If $sClass = "" Then $sClass = _WinAPI_GetClassName($hWnd)
$__g_aWinList_WinAPI[0][0] += 1
Local $iCount = $__g_aWinList_WinAPI[0][0]
If $iCount >= $__g_aWinList_WinAPI[0][1] Then
ReDim $__g_aWinList_WinAPI[$iCount + 64][2]
$__g_aWinList_WinAPI[0][1] += 64
EndIf
$__g_aWinList_WinAPI[$iCount][0] = $hWnd
$__g_aWinList_WinAPI[$iCount][1] = $sClass
EndFunc
Func __WinAPI_EnumWindowsInit()
ReDim $__g_aWinList_WinAPI[64][2]
$__g_aWinList_WinAPI[0][0] = 0
$__g_aWinList_WinAPI[0][1] = 64
EndFunc
Func _WinAPI_SetLayeredWindowAttributes($hWnd, $iTransColor, $iTransGUI = 255, $iFlags = 0x03, $bColorRef = False)
If $iFlags = Default Or $iFlags = "" Or $iFlags < 0 Then $iFlags = 0x03
If Not $bColorRef Then
$iTransColor = Int(BinaryMid($iTransColor, 3, 1) & BinaryMid($iTransColor, 2, 1) & BinaryMid($iTransColor, 1, 1))
EndIf
Local $aResult = DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $hWnd, "INT", $iTransColor, "byte", $iTransGUI, "dword", $iFlags)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Global Const $LOCALE_SDATE = 0x001D
Global Const $LOCALE_STIME = 0x001E
Global Const $LOCALE_SSHORTDATE = 0x001F
Global Const $LOCALE_SLONGDATE = 0x0020
Global Const $LOCALE_STIMEFORMAT = 0x1003
Global Const $LOCALE_S1159 = 0x0028
Global Const $LOCALE_S2359 = 0x0029
Global Const $LOCALE_INVARIANT = 0x007F
Global Const $LOCALE_USER_DEFAULT = 0x0400
Global Const $WS_BORDER = 0x00800000
Global Const $WS_POPUP = 0x80000000
Global Const $WS_EX_LAYERED = 0x00080000
Global Const $PS_SOLID = 0
Global Const $DT_LEFT = 0x0
Global Const $RDW_INVALIDATE = 0x0001
Global Const $RDW_ALLCHILDREN = 0x0080
Global Const $GUI_WS_EX_PARENTDRAG = 0x00100000
Global Const $COLOR_WHITE = 0xFFFFFF
Global Const $DMW_SHORTNAME = 1
Global Const $DMW_LOCALE_LONGNAME = 2
Global Const $SS_CENTER = 0x1
Func _WinAPI_GetDateFormat($iLCID = 0, $tSYSTEMTIME = 0, $iFlags = 0, $sFormat = '')
If Not $iLCID Then $iLCID = 0x0400
Local $sTypeOfFormat = 'wstr'
If Not StringStripWS($sFormat, $STR_STRIPLEADING + $STR_STRIPTRAILING) Then
$sTypeOfFormat = 'ptr'
$sFormat = 0
EndIf
Local $aRet = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'dword', $iLCID, 'dword', $iFlags, 'struct*', $tSYSTEMTIME, $sTypeOfFormat, $sFormat, 'wstr', '', 'int', 2048)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, '')
Return $aRet[5]
EndFunc
Func _WinAPI_GetLocaleInfo($iLCID, $iType)
Local $aRet = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'dword', $iLCID, 'dword', $iType, 'wstr', '', 'int', 2048)
If @error Or Not $aRet[0] Then Return SetError(@error + 10, @extended, '')
Return $aRet[3]
EndFunc
Func _DateDayOfWeek($iDayNum, $iFormat = Default)
Local Const $MONDAY_IS_NO1 = 128
If $iFormat = Default Then $iFormat = 0
$iDayNum = Int($iDayNum)
If $iDayNum < 1 Or $iDayNum > 7 Then Return SetError(1, 0, "")
Local $tSYSTEMTIME = DllStructCreate($tagSYSTEMTIME)
DllStructSetData($tSYSTEMTIME, "Year", BitAND($iFormat, $MONDAY_IS_NO1) ? 2007 : 2006)
DllStructSetData($tSYSTEMTIME, "Month", 1)
DllStructSetData($tSYSTEMTIME, "Day", $iDayNum)
Return _WinAPI_GetDateFormat(BitAND($iFormat, $DMW_LOCALE_LONGNAME) ? $LOCALE_USER_DEFAULT : $LOCALE_INVARIANT, $tSYSTEMTIME, 0, BitAND($iFormat, $DMW_SHORTNAME) ? "ddd" : "dddd")
EndFunc
Func _DateIsLeapYear($iYear)
If StringIsInt($iYear) Then
Select
Case Mod($iYear, 4) = 0 And Mod($iYear, 100) <> 0
Return 1
Case Mod($iYear, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func __DateIsMonth($iNumber)
$iNumber = Int($iNumber)
Return $iNumber >= 1 And $iNumber <= 12
EndFunc
Func _DateIsValid($sDate)
Local $asDatePart[4], $asTimePart[4]
_DateTimeSplit($sDate, $asDatePart, $asTimePart)
If Not StringIsInt($asDatePart[1]) Then Return 0
If Not StringIsInt($asDatePart[2]) Then Return 0
If Not StringIsInt($asDatePart[3]) Then Return 0
$asDatePart[1] = Int($asDatePart[1])
$asDatePart[2] = Int($asDatePart[2])
$asDatePart[3] = Int($asDatePart[3])
Local $iNumDays = _DaysInMonth($asDatePart[1])
If $asDatePart[1] < 1000 Or $asDatePart[1] > 2999 Then Return 0
If $asDatePart[2] < 1 Or $asDatePart[2] > 12 Then Return 0
If $asDatePart[3] < 1 Or $asDatePart[3] > $iNumDays[$asDatePart[2]] Then Return 0
If $asTimePart[0] < 1 Then Return 1
If $asTimePart[0] < 2 Then Return 0
If $asTimePart[0] = 2 Then $asTimePart[3] = "00"
If Not StringIsInt($asTimePart[1]) Then Return 0
If Not StringIsInt($asTimePart[2]) Then Return 0
If Not StringIsInt($asTimePart[3]) Then Return 0
$asTimePart[1] = Int($asTimePart[1])
$asTimePart[2] = Int($asTimePart[2])
$asTimePart[3] = Int($asTimePart[3])
If $asTimePart[1] < 0 Or $asTimePart[1] > 23 Then Return 0
If $asTimePart[2] < 0 Or $asTimePart[2] > 59 Then Return 0
If $asTimePart[3] < 0 Or $asTimePart[3] > 59 Then Return 0
Return 1
EndFunc
Func _DateTimeFormat($sDate, $sType)
Local $asDatePart[4], $asTimePart[4]
Local $sTempDate = "", $sTempTime = ""
Local $sAM, $sPM, $sTempString = ""
If Not _DateIsValid($sDate) Then
Return SetError(1, 0, "")
EndIf
If $sType < 0 Or $sType > 5 Or Not IsInt($sType) Then
Return SetError(2, 0, "")
EndIf
_DateTimeSplit($sDate, $asDatePart, $asTimePart)
Switch $sType
Case 0
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE)
If Not @error And Not($sTempString = '') Then
$sTempDate = $sTempString
Else
$sTempDate = "M/d/yyyy"
EndIf
If $asTimePart[0] > 1 Then
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_STIMEFORMAT)
If Not @error And Not($sTempString = '') Then
$sTempTime = $sTempString
Else
$sTempTime = "h:mm:ss tt"
EndIf
EndIf
Case 1
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SLONGDATE)
If Not @error And Not($sTempString = '') Then
$sTempDate = $sTempString
Else
$sTempDate = "dddd, MMMM dd, yyyy"
EndIf
Case 2
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE)
If Not @error And Not($sTempString = '') Then
$sTempDate = $sTempString
Else
$sTempDate = "M/d/yyyy"
EndIf
Case 3
If $asTimePart[0] > 1 Then
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_STIMEFORMAT)
If Not @error And Not($sTempString = '') Then
$sTempTime = $sTempString
Else
$sTempTime = "h:mm:ss tt"
EndIf
EndIf
Case 4
If $asTimePart[0] > 1 Then
$sTempTime = "hh:mm"
EndIf
Case 5
If $asTimePart[0] > 1 Then
$sTempTime = "hh:mm:ss"
EndIf
EndSwitch
If $sTempDate <> "" Then
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SDATE)
If Not @error And Not($sTempString = '') Then
$sTempDate = StringReplace($sTempDate, "/", $sTempString)
EndIf
Local $iWday = _DateToDayOfWeek($asDatePart[1], $asDatePart[2], $asDatePart[3])
$asDatePart[3] = StringRight("0" & $asDatePart[3], 2)
$asDatePart[2] = StringRight("0" & $asDatePart[2], 2)
$sTempDate = StringReplace($sTempDate, "d", "@")
$sTempDate = StringReplace($sTempDate, "m", "#")
$sTempDate = StringReplace($sTempDate, "y", "&")
$sTempDate = StringReplace($sTempDate, "@@@@", _DateDayOfWeek($iWday, 0))
$sTempDate = StringReplace($sTempDate, "@@@", _DateDayOfWeek($iWday, 1))
$sTempDate = StringReplace($sTempDate, "@@", $asDatePart[3])
$sTempDate = StringReplace($sTempDate, "@", StringReplace(StringLeft($asDatePart[3], 1), "0", "") & StringRight($asDatePart[3], 1))
$sTempDate = StringReplace($sTempDate, "####", _DateToMonth($asDatePart[2], 0))
$sTempDate = StringReplace($sTempDate, "###", _DateToMonth($asDatePart[2], 1))
$sTempDate = StringReplace($sTempDate, "##", $asDatePart[2])
$sTempDate = StringReplace($sTempDate, "#", StringReplace(StringLeft($asDatePart[2], 1), "0", "") & StringRight($asDatePart[2], 1))
$sTempDate = StringReplace($sTempDate, "&&&&", $asDatePart[1])
$sTempDate = StringReplace($sTempDate, "&&", StringRight($asDatePart[1], 2))
EndIf
If $sTempTime <> "" Then
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_S1159)
If Not @error And Not($sTempString = '') Then
$sAM = $sTempString
Else
$sAM = "AM"
EndIf
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_S2359)
If Not @error And Not($sTempString = '') Then
$sPM = $sTempString
Else
$sPM = "PM"
EndIf
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_STIME)
If Not @error And Not($sTempString = '') Then
$sTempTime = StringReplace($sTempTime, ":", $sTempString)
EndIf
If StringInStr($sTempTime, "tt") Then
If $asTimePart[1] < 12 Then
$sTempTime = StringReplace($sTempTime, "tt", $sAM)
If $asTimePart[1] = 0 Then $asTimePart[1] = 12
Else
$sTempTime = StringReplace($sTempTime, "tt", $sPM)
If $asTimePart[1] > 12 Then $asTimePart[1] = $asTimePart[1] - 12
EndIf
EndIf
$asTimePart[1] = StringRight("0" & $asTimePart[1], 2)
$asTimePart[2] = StringRight("0" & $asTimePart[2], 2)
$asTimePart[3] = StringRight("0" & $asTimePart[3], 2)
$sTempTime = StringReplace($sTempTime, "hh", StringFormat("%02d", $asTimePart[1]))
$sTempTime = StringReplace($sTempTime, "h", StringReplace(StringLeft($asTimePart[1], 1), "0", "") & StringRight($asTimePart[1], 1))
$sTempTime = StringReplace($sTempTime, "mm", StringFormat("%02d", $asTimePart[2]))
$sTempTime = StringReplace($sTempTime, "ss", StringFormat("%02d", $asTimePart[3]))
$sTempDate = StringStripWS($sTempDate & " " & $sTempTime, $STR_STRIPLEADING + $STR_STRIPTRAILING)
EndIf
Return $sTempDate
EndFunc
Func _DateTimeSplit($sDate, ByRef $aDatePart, ByRef $iTimePart)
Local $sDateTime = StringSplit($sDate, " T")
If $sDateTime[0] > 0 Then $aDatePart = StringSplit($sDateTime[1], "/-.")
If $sDateTime[0] > 1 Then
$iTimePart = StringSplit($sDateTime[2], ":")
If UBound($iTimePart) < 4 Then ReDim $iTimePart[4]
Else
Dim $iTimePart[4]
EndIf
If UBound($aDatePart) < 4 Then ReDim $aDatePart[4]
For $x = 1 To 3
If StringIsInt($aDatePart[$x]) Then
$aDatePart[$x] = Int($aDatePart[$x])
Else
$aDatePart[$x] = -1
EndIf
If StringIsInt($iTimePart[$x]) Then
$iTimePart[$x] = Int($iTimePart[$x])
Else
$iTimePart[$x] = 0
EndIf
Next
Return 1
EndFunc
Func _DateToDayOfWeek($iYear, $iMonth, $iDay)
If Not _DateIsValid($iYear & "/" & $iMonth & "/" & $iDay) Then
Return SetError(1, 0, "")
EndIf
Local $i_FactorA = Int((14 - $iMonth) / 12)
Local $i_FactorY = $iYear - $i_FactorA
Local $i_FactorM = $iMonth +(12 * $i_FactorA) - 2
Local $i_FactorD = Mod($iDay + $i_FactorY + Int($i_FactorY / 4) - Int($i_FactorY / 100) + Int($i_FactorY / 400) + Int((31 * $i_FactorM) / 12), 7)
Return $i_FactorD + 1
EndFunc
Func _DateToMonth($iMonNum, $iFormat = Default)
If $iFormat = Default Then $iFormat = 0
$iMonNum = Int($iMonNum)
If Not __DateIsMonth($iMonNum) Then Return SetError(1, 0, "")
Local $tSYSTEMTIME = DllStructCreate($tagSYSTEMTIME)
DllStructSetData($tSYSTEMTIME, "Year", @YEAR)
DllStructSetData($tSYSTEMTIME, "Month", $iMonNum)
DllStructSetData($tSYSTEMTIME, "Day", 1)
Return _WinAPI_GetDateFormat(BitAND($iFormat, $DMW_LOCALE_LONGNAME) ? $LOCALE_USER_DEFAULT : $LOCALE_INVARIANT, $tSYSTEMTIME, 0, BitAND($iFormat, $DMW_SHORTNAME) ? "MMM" : "MMMM")
EndFunc
Func _Now()
Return _DateTimeFormat(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, 0)
EndFunc
Func _DaysInMonth($iYear)
Local $aDays = [12, 31,(_DateIsLeapYear($iYear) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $aDays
EndFunc
Global $__g_iBMPFormat = $GDIP_PXF24RGB
Global $__g_iJPGQuality = 100
Global $__g_iTIFColorDepth = 24
Global $__g_iTIFCompression = $GDIP_EVTCOMPRESSIONLZW
Global Const $__SCREENCAPTURECONSTANT_SM_CXSCREEN = 0
Global Const $__SCREENCAPTURECONSTANT_SM_CYSCREEN = 1
Global Const $__SCREENCAPTURECONSTANT_SRCCOPY = 0x00CC0020
Func _ScreenCapture_Capture($sFileName = "", $iLeft = 0, $iTop = 0, $iRight = -1, $iBottom = -1, $bCursor = True)
Local $bRet = False
If $iRight = -1 Then $iRight = _WinAPI_GetSystemMetrics($__SCREENCAPTURECONSTANT_SM_CXSCREEN) - 1
If $iBottom = -1 Then $iBottom = _WinAPI_GetSystemMetrics($__SCREENCAPTURECONSTANT_SM_CYSCREEN) - 1
If $iRight < $iLeft Then Return SetError(-1, 0, $bRet)
If $iBottom < $iTop Then Return SetError(-2, 0, $bRet)
Local $iW =($iRight - $iLeft) + 1
Local $iH =($iBottom - $iTop) + 1
Local $hWnd = _WinAPI_GetDesktopWindow()
Local $hDDC = _WinAPI_GetDC($hWnd)
Local $hCDC = _WinAPI_CreateCompatibleDC($hDDC)
Local $hBMP = _WinAPI_CreateCompatibleBitmap($hDDC, $iW, $iH)
_WinAPI_SelectObject($hCDC, $hBMP)
_WinAPI_BitBlt($hCDC, 0, 0, $iW, $iH, $hDDC, $iLeft, $iTop, $__SCREENCAPTURECONSTANT_SRCCOPY)
If $bCursor Then
Local $aCursor = _WinAPI_GetCursorInfo()
If Not @error And $aCursor[1] Then
$bCursor = True
Local $hIcon = _WinAPI_CopyIcon($aCursor[2])
Local $aIcon = _WinAPI_GetIconInfo($hIcon)
If Not @error Then
_WinAPI_DeleteObject($aIcon[4])
If $aIcon[5] <> 0 Then _WinAPI_DeleteObject($aIcon[5])
_WinAPI_DrawIcon($hCDC, $aCursor[3] - $aIcon[2] - $iLeft, $aCursor[4] - $aIcon[3] - $iTop, $hIcon)
EndIf
_WinAPI_DestroyIcon($hIcon)
EndIf
EndIf
_WinAPI_ReleaseDC($hWnd, $hDDC)
_WinAPI_DeleteDC($hCDC)
If $sFileName = "" Then Return $hBMP
$bRet = _ScreenCapture_SaveImage($sFileName, $hBMP, True)
Return SetError(@error, @extended, $bRet)
EndFunc
Func _ScreenCapture_CaptureWnd($sFileName, $hWnd, $iLeft = 0, $iTop = 0, $iRight = -1, $iBottom = -1, $bCursor = True)
If Not IsHWnd($hWnd) Then $hWnd = WinGetHandle($hWnd)
Local $tRECT = DllStructCreate($tagRECT)
Local Const $DWMWA_EXTENDED_FRAME_BOUNDS = 9
Local $bRet = DllCall("dwmapi.dll", "long", "DwmGetWindowAttribute", "hwnd", $hWnd, "dword", $DWMWA_EXTENDED_FRAME_BOUNDS, "struct*", $tRECT, "dword", DllStructGetSize($tRECT))
If(@error Or $bRet[0] Or(Abs(DllStructGetData($tRECT, "Left")) + Abs(DllStructGetData($tRECT, "Top")) + Abs(DllStructGetData($tRECT, "Right")) + Abs(DllStructGetData($tRECT, "Bottom"))) = 0) Then
$tRECT = _WinAPI_GetWindowRect($hWnd)
If @error Then Return SetError(@error + 10, @extended, False)
EndIf
$iLeft += DllStructGetData($tRECT, "Left")
$iTop += DllStructGetData($tRECT, "Top")
If $iRight = -1 Then $iRight = DllStructGetData($tRECT, "Right") - DllStructGetData($tRECT, "Left") - 1
If $iBottom = -1 Then $iBottom = DllStructGetData($tRECT, "Bottom") - DllStructGetData($tRECT, "Top") - 1
$iRight += DllStructGetData($tRECT, "Left")
$iBottom += DllStructGetData($tRECT, "Top")
If $iLeft > DllStructGetData($tRECT, "Right") Then $iLeft = DllStructGetData($tRECT, "Left")
If $iTop > DllStructGetData($tRECT, "Bottom") Then $iTop = DllStructGetData($tRECT, "Top")
If $iRight > DllStructGetData($tRECT, "Right") Then $iRight = DllStructGetData($tRECT, "Right") - 1
If $iBottom > DllStructGetData($tRECT, "Bottom") Then $iBottom = DllStructGetData($tRECT, "Bottom") - 1
$bRet = _ScreenCapture_Capture($sFileName, $iLeft, $iTop, $iRight, $iBottom, $bCursor)
Return SetError(@error, @extended, $bRet)
EndFunc
Func _ScreenCapture_SaveImage($sFileName, $hBitmap, $bFreeBmp = True)
_GDIPlus_Startup()
If @error Then Return SetError(-1, -1, False)
Local $sExt = StringUpper(__GDIPlus_ExtractFileExt($sFileName))
Local $sCLSID = _GDIPlus_EncodersGetCLSID($sExt)
If $sCLSID = "" Then Return SetError(-2, -2, False)
Local $hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
If @error Then Return SetError(-3, -3, False)
Local $tData, $tParams
Switch $sExt
Case "BMP"
Local $iX = _GDIPlus_ImageGetWidth($hImage)
Local $iY = _GDIPlus_ImageGetHeight($hImage)
Local $hClone = _GDIPlus_BitmapCloneArea($hImage, 0, 0, $iX, $iY, $__g_iBMPFormat)
_GDIPlus_ImageDispose($hImage)
$hImage = $hClone
Case "JPG", "JPEG"
$tParams = _GDIPlus_ParamInit(1)
$tData = DllStructCreate("int Quality")
DllStructSetData($tData, "Quality", $__g_iJPGQuality)
_GDIPlus_ParamAdd($tParams, $GDIP_EPGQUALITY, 1, $GDIP_EPTLONG, DllStructGetPtr($tData))
Case "TIF", "TIFF"
$tParams = _GDIPlus_ParamInit(2)
$tData = DllStructCreate("int ColorDepth;int Compression")
DllStructSetData($tData, "ColorDepth", $__g_iTIFColorDepth)
DllStructSetData($tData, "Compression", $__g_iTIFCompression)
_GDIPlus_ParamAdd($tParams, $GDIP_EPGCOLORDEPTH, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "ColorDepth"))
_GDIPlus_ParamAdd($tParams, $GDIP_EPGCOMPRESSION, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "Compression"))
EndSwitch
Local $pParams = 0
If IsDllStruct($tParams) Then $pParams = $tParams
Local $bRet = _GDIPlus_ImageSaveToFileEx($hImage, $sFileName, $sCLSID, $pParams)
_GDIPlus_ImageDispose($hImage)
If $bFreeBmp Then _WinAPI_DeleteObject($hBitmap)
_GDIPlus_Shutdown()
Return SetError($bRet = False, 0, $bRet)
EndFunc
Func _IsPressed($sHexKey, $vDLL = "user32.dll")
Local $aReturn = DllCall($vDLL, "short", "GetAsyncKeyState", "int", "0x" & $sHexKey)
If @error Then Return SetError(@error, @extended, False)
Return BitAND($aReturn[0], 0x8000) <> 0
EndFunc
Opt("MustDeclareVars", 1)
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
EndFunc
Func _WinGetallEmulators()
Local $aWindows = _WinAPI_EnumWindowsTop(), $sHold = ""
For $i = 1 To $aWindows[0][0]
Local $temp = WinGetTitle($aWindows[$i][0])
If(StringInStr(WinGetText($aWindows[$i][0]), "RenderWindowWindow") > 0 And $aWindows[$i][1] = "Qt5QWindowIcon") Or(StringInStr(WinGetText($aWindows[$i][0]), "default_title_barWindow") > 0 And $aWindows[$i][1] = "Qt5QWindowIcon") Or($temp = "BlueStacks Android PluginAndroid") Then
$sHold &= WinGetTitle($aWindows[$i][0]) & "|"
EndIf
Next
If Not $sHold = "" Then Return StringTrimRight($sHold, 1)
Return SetError(1, 0, 0)
EndFunc
Func GethandleHwd()
$g_hWnd = ControlGetHandle($InstanceName, "sub", "")
If IsHWnd($g_hWnd) Then
$g_hAndroidWindow = ControlGetHandle($g_hWnd, "sub", "[CLASS:subWin; INSTANCE:1]")
If IsHWnd($g_hAndroidWindow) Then Return True
EndIf
$g_hWnd = ControlGetHandle($InstanceName, "sub", "")
If IsHWnd($g_hWnd) Then
$g_hAndroidWindow = ControlGetHandle($g_hWnd, "sub", "[CLASS:subWin; INSTANCE:1]")
If IsHWnd($g_hAndroidWindow) Then Return True
EndIf
$g_hWnd = ControlGetHandle($InstanceName, "QWidgetClassWindow", "")
If IsHWnd($g_hWnd) Then
$g_hAndroidWindow = ControlGetHandle($g_hWnd, "QWidgetClassWindow", "[CLASS:Qt5QWindowIcon; INSTANCE:2]")
If IsHWnd($g_hAndroidWindow) Then Return True
EndIf
$g_hWnd = WinWait("[TITLE:BlueStacks Android PluginAndroid]", "_ctl.Window", 35)
If IsHWnd($g_hWnd) Then
$g_hAndroidWindow = ControlGetHandle($g_hWnd, "_ctl.Window", "[CLASS:BlueStacksApp; INSTANCE:1]")
If IsHWnd($g_hAndroidWindow) Then Return True
EndIf
Return False
EndFunc
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
$hDC = _WinAPI_GetWindowDC($g_frmGuiDebug)
$hPen = _WinAPI_CreatePen($PS_SOLID, $PenWidth, $color)
$obj_orig = _WinAPI_SelectObject($hDC, $hPen)
_WinAPI_DrawLine($hDC, $x1, $y1, $x2, $y1)
_WinAPI_DrawLine($hDC, $x2, $y1, $x2, $y2)
_WinAPI_DrawLine($hDC, $x2, $y2, $x1, $y2)
_WinAPI_DrawLine($hDC, $x1, $y2, $x1, $y1)
_WinAPI_DrawText($hDC, $sFileName & "(" & $Xaxis & "," & $Yaxis & ")", $g_tRECT, $DT_LEFT)
_WinAPI_SelectObject($hDC, $obj_orig)
_WinAPI_DeleteObject($hPen)
_WinAPI_ReleaseDC(0, $hDC)
EndFunc
Func MoveGUIDebug()
If $g_frmGuiDebug = 0 Then Return
Local $aPos = WinGetPos($g_hAndroidWindow, "")
If Not IsArray($aPos) Then
GethandleHwd()
EndIf
$aPos = WinGetPos($g_hAndroidWindow, "")
WinMove($g_frmGuiDebug, "", $aPos[0], $aPos[1], $aPos[2], $aPos[3])
EndFunc
Func GuiDebug()
$g_frmGuiDebug = GUICreate("DEBUG-IMAGE ONSCREEN @ PROMAC 2018 ", 860 - 6, 732 - 29, -1, -1, -1, $WS_EX_LAYERED)
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
EndFunc
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
EndFunc
Func _ScreenCapture()
GUICtrlSetData($g_lblDebugOnScreenHelp, "ScreenCap")
_GDIPlus_Startup()
Local Static $n = 0
Local $path = @DesktopCommonDir & "\OnScreen_0x" & $g_iColor & "_" & $g_aMouse[0] & "x" & $g_aMouse[1] & "_Image" & $n & ".png"
WinActivate($g_hWnd)
Local $hPen = _GDIPlus_PenCreate(0xFFF90E0E, 2)
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
EndFunc
Func _BitmapCapture()
Return _ScreenCapture_CaptureWnd("", $g_frmGuiDebug, 0, 0, -1, -1, False)
EndFunc
Func _GetColor()
Local $Mouse1 = MouseGetPos()
Local $iColor = Hex(PixelGetColor($Mouse1[0], $Mouse1[1], $g_frmGuiDebug), 6)
Return $iColor
EndFunc
Func _Help()
GUICtrlSetData($g_lblDebugOnScreenHelp, "HELP")
Local $Txt = "'ESC'" & @TAB & "- Exit " & @CRLF & "'F1' " & @TAB & "- Grabs all yours left click with coordinates and " & @CRLF & @TAB & "   pixel color to a .au3, Right click will stop it." & @CRLF & "'F2' " & @TAB & "- Takes a Screencapture and save it to your desktop" & @CRLF & "'F3' " & @TAB & "- Help Message" & @CRLF
MsgBox($MB_OK + $MB_ICONINFORMATION, "DEBUG-IMAGE ONSCREEN @ PROMAC 2018", $Txt, 30)
GUICtrlSetData($g_lblDebugOnScreenHelp, "Standby")
EndFunc
Func _Terminate()
Exit
EndFunc
