#NoEnv  					; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance				; Only allows one instance of the script to run.
#Warn  						; Enable warnings to assist with detecting common errors.
SendMode Input  			; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; AUDIO DEVICE SWAPPER by ImOnMars ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Created so that you can iterate through multiple sound devices on Windows with hotkeys
;
; To make this run automatically when your PC starts, put it (or a shortcut to it) in the Startup folder (For Windows 10: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp)
; 
; Requirements:
; - AutoHotkey
; - nircmd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;          CONFIG OPTIONS          ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Redshift Settings
NIRCMD_PATH = nircmd 				; The path where nircmd is, if nircmd is in your path environment variable, then you can leave as is

; Options File
SAVE_OPTIONS := true				; Whether or not to save options to a file after script restart or PC reboot
OPTIONS_PATH = C:\audioDeviceSwapperOptions.ini  ; Path of where to save options if SAVE_OPTIONS is true

; Sound Devices Options
DEVICES := ["Speakers", "Headphones"] ; A list of device names to switch to
INITIAL_DEVICE_INDEX = 1			; The initial device when SAVE_OPTIONS is false or the options file does not exist

; Hotkeys, see here for key combinations: https://autohotkey.com/docs/Hotkeys.htm
NEXT_SOUND_DEVICE_HOTKEY = +!v		; Default: (Shift + Alt + v)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;           INITIAL RUN            ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Defaults
currentDeviceIndex := INITIAL_DEVICE_INDEX

; If necessary, read or write all of the options
if (SAVE_OPTIONS)
{
	if (FileExist(OPTIONS_PATH))
	{
		readAllOptionsFromFile()
	}
	else
	{
		writeAllOptionsToFile()
	}
}

; Set the initial audio device
device := DEVICES[currentDeviceIndex]
Run, %NIRCMD_PATH% setdefaultsounddevice "%device%"
soundDeviceBox(DEVICES[currentDeviceIndex])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;         HOTKEY BINDINGS          ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;`

Hotkey, %NEXT_SOUND_DEVICE_HOTKEY%, NextSoundDevice
return

NextSoundDevice:
	currentDeviceIndex++
	if (currentDeviceIndex = DEVICES.length() + 1)
	{
		currentDeviceIndex = 1
	}
	device := DEVICES[currentDeviceIndex]
	Run, %NIRCMD_PATH% setdefaultsounddevice "%device%"
	soundDeviceBox(DEVICES[currentDeviceIndex])
	
	writeOptionToFile("currentDeviceIndex", currentDeviceIndex)
	return

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;       INI FILE MANAGEMENT        ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

writeOptionToFile(optionName, optionValue)
{
	global SAVE_OPTIONS
	global OPTIONS_PATH

	if (NOT SAVE_OPTIONS)
	{
		return
	}

	IniWrite, %optionValue%, %OPTIONS_PATH%, General, %optionName%
}

readOptionFromFile(optionName, ByRef optionValue)
{
	global SAVE_OPTIONS
	global OPTIONS_PATH
	
	if (NOT SAVE_OPTIONS)
	{
		return
	}
	
	IniRead, optionValue, %OPTIONS_PATH%, General, %optionName%
}

writeAllOptionsToFile()
{
	global SAVE_OPTIONS
	global currentDeviceIndex
	
	if (NOT SAVE_OPTIONS)
	{
		return
	}

	writeOptionToFile("currentDeviceIndex", currentDeviceIndex)
}

readAllOptionsFromFile()
{
	global SAVE_OPTIONS
	global currentDeviceIndex

	if (NOT SAVE_OPTIONS)
	{
		return
	}

	readOptionFromFile("currentDeviceIndex", currentDeviceIndex)
}

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;               GUI                ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Sound device GUI
soundDeviceBox(device)
{
	IfWinExist, soundDeviceWindow
	{
		Gui, Destroy
	}
	
	Gui, +ToolWindow -Caption +0x400000 +AlwaysOnTop
	Gui, Color, FFFFFF,
	Gui, Font, s12, Calibri
	Gui, Add, Text, x5 y5, Sound Device:
	Gui, Font, Bold
	Gui, Add, Text, x100 y5, %device%
	SysGet, screenx, 0
	SysGet, screeny, 1
	xpos:=screenx-275
	ypos:=screeny-100
	Gui, Show, NoActivate x%xpos% y%ypos% h30 w260, soundDeviceWindow
	
	SetTimer, soundDeviceClose, 2250
}
soundDeviceClose:
    SetTimer, soundDeviceClose, Off
    Gui, Destroy
	return