@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================================================
::  USB AUTO CHECK - QC RENTAL QC TERMINAL EDITION
::  기능 유지 + 터미널 UI 정리 + 출고 BIOS 진입 옵션 유지
:: ============================================================================

title QC AUTOMATION :: RENTAL QC TERMINAL
color 0A
mode con: cols=136 lines=38 >nul 2>&1
call :centerConsole

set "USB_RESULT=확인 전"
set "SYSTEM_TOOLS_RESULT=실행 전"
set "C_EXTEND_RESULT=RENTAL SKIP"
set "BLUETOOTH_RESULT=실행 전"
set "BATTERY_RESULT=실행 전"
set "BATTERY_HEALTH=N/A"
set "BATTERY_CYCLE=N/A"
set "BATTERY_LEVEL=N/A"
set "BATTERY_CHARGE=N/A"
set "TIME_SYNC_RESULT=실행 전"
set "CAMERA_RESULT=실행 전"
set "SOUND_RESULT=실행 전"
set "RAM_RESULT=UNKNOWN"
set "CPU_RESULT=UNKNOWN"
set "GPU_RESULT=UNKNOWN"
set "OVERALL_RESULT=확인 전"
set "CURRENT_STAGE=STARTUP"
set "CURRENT_DETAIL=Initializing rental console..."
set "LAST_ACTION=Idle"
set "TRACE_ID=HF-%RANDOM%-%RANDOM%"
set "NODE_NAME=%COMPUTERNAME%"
set "AUTH_STATE=CHECKING"
set "CHANNEL_STATE=RENTAL>USB>QC"

:: ANSI color codes are disabled because some consoles print them as text.
set "C_RESET="
set "C_GREEN="
set "C_RED="
set "C_YELLOW="
set "C_CYAN="
set "C_MAGENTA="
set "C_DIM="
set "C_WHITE="

set "BOX_BORDER=+------------------------------------------------------------------------------------------------------------------------------+"
set "BOX_PAD=                                                                                                                              "
set "FRAME_BORDER="
for /L %%I in (1,1,134) do set "FRAME_BORDER=!FRAME_BORDER!-"
set "FRAME_BORDER=+!FRAME_BORDER!+"
set "QC_LOGO_FILE=%TEMP%\halfet_rental_qc_logo.txt"

call :prepareLogo

if /I "%~1"=="--preview" (
    call :renderDashboard
    exit /b 0
)

if /I "%~1"=="--preview-final" (
    set "CURRENT_STAGE=FINAL REPORT"
    set "CURRENT_DETAIL=Final report locked"
    set "LAST_ACTION=Final report locked"
    set "OVERALL_RESULT=확인 필요"
    set "USB_RESULT=찾기 실패"
    set "SYSTEM_TOOLS_RESULT=실행 완료"
    set "C_EXTEND_RESULT=RENTAL SKIP"
    set "BLUETOOTH_RESULT=정상"
    set "BATTERY_RESULT=정상"
    set "BATTERY_HEALTH=86"
    set "BATTERY_CYCLE=115"
    set "BATTERY_LEVEL=99"
    set "BATTERY_CHARGE=ON AC"
    set "TIME_SYNC_RESULT=정상"
    set "CAMERA_RESULT=실행 완료"
    set "SOUND_RESULT=실행 완료"
    set "RAM_RESULT=31 GB"
    set "CPU_RESULT=Intel Core i7"
    set "GPU_RESULT=Intel Iris Xe"
    set "AUTH_STATE=ADMIN"
    call :renderDashboard
    call :boxTop
    call :boxTitle "OPERATOR COMMAND"
    call :printTwinLine "1" "CLOSE TERMINAL" "2" "SHUTDOWN TO UEFI BIOS"
    call :boxBottom
    call :frameBottom
    echo  QC^>
    exit /b 0
)

call :renderDashboard
goto main

:boxTop
set "BOX_OUT=  %BOX_BORDER%"
call :frameLine "!BOX_OUT!"
exit /b

:boxSep
set "BOX_OUT=  %BOX_BORDER%"
call :frameLine "!BOX_OUT!"
exit /b

:boxBottom
set "BOX_OUT=  %BOX_BORDER%"
call :frameLine "!BOX_OUT!"
exit /b

:boxTitle
set "BOXLINE=  [ %~1 ]"
set "BOXLINE=!BOXLINE!!BOX_PAD!"
set "BOXLINE=!BOXLINE:~0,126!"
set "BOX_OUT=  |!BOXLINE!|"
call :frameLine "!BOX_OUT!"
exit /b

:printLine
set "LABEL=%~1"
set "VALUE=%~2"
set "ROW=  !LABEL! : !VALUE!"
set "ROW=!ROW!!BOX_PAD!"
set "ROW=!ROW:~0,126!"
set "BOX_OUT=  |!ROW!|"
call :frameLine "!BOX_OUT!"
exit /b

:printLineColor
set "LABEL=%~1"
set "VALUE=%~2"
set "COLOR=%~3"
set "ROW=  !LABEL! : !VALUE!"
set "ROW=!ROW!!BOX_PAD!"
set "ROW=!ROW:~0,126!"
set "BOX_OUT=  |!ROW!|"
call :frameLine "!BOX_OUT!"
exit /b

:printTwinLine
set "LEFT_LABEL=%~1"
set "LEFT_VALUE=%~2"
set "RIGHT_LABEL=%~3"
set "RIGHT_VALUE=%~4"
set "LEFT_ROW=  [!LEFT_LABEL!] !LEFT_VALUE!"
set "RIGHT_ROW=  [!RIGHT_LABEL!] !RIGHT_VALUE!"
set "LEFT_ROW=!LEFT_ROW!!BOX_PAD!"
set "RIGHT_ROW=!RIGHT_ROW!!BOX_PAD!"
set "LEFT_ROW=!LEFT_ROW:~0,63!"
set "RIGHT_ROW=!RIGHT_ROW:~0,63!"
set "BOX_OUT=  |!LEFT_ROW!!RIGHT_ROW!|"
call :frameLine "!BOX_OUT!"
exit /b

:frameTop
echo %FRAME_BORDER%
exit /b

:frameBottom
echo %FRAME_BORDER%
exit /b

:frameBlank
call :frameLine ""
exit /b

:frameLine
set "FRAME_ROW=%~1"
set "FRAME_ROW=!FRAME_ROW!!BOX_PAD!!BOX_PAD!"
set "FRAME_ROW=!FRAME_ROW:~0,132!"
echo ^| !FRAME_ROW! ^|
call :reportTick
exit /b

:printLogo
if exist "%QC_LOGO_FILE%" (
    for /f "usebackq delims=" %%L in ("%QC_LOGO_FILE%") do call :frameLine "%%L"
) else (
    call :frameLine "  QC"
)
exit /b

:reportTick
exit /b

:buildDisplayValues
set /a ISSUE_COUNT=0
if "!C_EXTEND_RESULT!"=="확장 실패" set /a ISSUE_COUNT+=1
if "!BLUETOOTH_RESULT!"=="오류 또는 없음" set /a ISSUE_COUNT+=1
if "!BATTERY_RESULT!"=="경고" set /a ISSUE_COUNT+=1
if "!TIME_SYNC_RESULT!"=="실패" set /a ISSUE_COUNT+=1
if "!USB_RESULT!"=="찾기 실패" set /a ISSUE_COUNT+=1

set "DISPLAY_OVERALL=RUNNING"
if "!OVERALL_RESULT!"=="정상" set "DISPLAY_OVERALL=OK"
if "!OVERALL_RESULT!"=="확인 필요" set "DISPLAY_OVERALL=CHECK REQUIRED"

set "DISPLAY_ALERT=CHECK IN PROGRESS"
if "!OVERALL_RESULT!"=="정상" set "DISPLAY_ALERT=ALL CHECKS PASSED"
if "!OVERALL_RESULT!"=="확인 필요" set "DISPLAY_ALERT=CHECK ISSUES BELOW"

set "DISPLAY_USB=WAITING"
if "!USB_RESULT!"=="탐색 중" set "DISPLAY_USB=SCANNING"
if not "!USB_RESULT!"=="확인 전" if not "!USB_RESULT!"=="탐색 중" set "DISPLAY_USB=FOUND"
if "!USB_RESULT!"=="찾기 실패" set "DISPLAY_USB=NOT FOUND"

set "DISPLAY_SYSTEM=WAITING"
if "!SYSTEM_TOOLS_RESULT!"=="실행 중" set "DISPLAY_SYSTEM=RUNNING"
if "!SYSTEM_TOOLS_RESULT!"=="실행 완료" set "DISPLAY_SYSTEM=DONE"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!SYSTEM_TOOLS_RESULT!"=="실행 전" set "DISPLAY_SYSTEM=NOT RUN"

set "DISPLAY_CDRIVE=WAITING"
if "!C_EXTEND_RESULT!"=="확인 중" set "DISPLAY_CDRIVE=RUNNING"
if "!C_EXTEND_RESULT!"=="확장 완료" set "DISPLAY_CDRIVE=EXTENDED"
if "!C_EXTEND_RESULT!"=="확장 실패" set "DISPLAY_CDRIVE=FAILED"
if "!C_EXTEND_RESULT!"=="이미 확장되어 있음" set "DISPLAY_CDRIVE=MAX SIZE"
if "!C_EXTEND_RESULT!"=="RENTAL SKIP" set "DISPLAY_CDRIVE=SKIPPED"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!C_EXTEND_RESULT!"=="실행 전" set "DISPLAY_CDRIVE=NOT RUN"

set "DISPLAY_BT=WAITING"
if "!BLUETOOTH_RESULT!"=="확인 중" set "DISPLAY_BT=RUNNING"
if "!BLUETOOTH_RESULT!"=="정상" set "DISPLAY_BT=OK"
if "!BLUETOOTH_RESULT!"=="오류 또는 없음" set "DISPLAY_BT=ERROR"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!BLUETOOTH_RESULT!"=="실행 전" set "DISPLAY_BT=NOT RUN"

set "DISPLAY_BATTERY=WAITING"
if "!BATTERY_RESULT!"=="확인 중" set "DISPLAY_BATTERY=RUNNING"
if "!BATTERY_RESULT!"=="정상" set "DISPLAY_BATTERY=OK"
if "!BATTERY_RESULT!"=="배터리 없음" set "DISPLAY_BATTERY=NO BATTERY"
if "!BATTERY_RESULT!"=="경고" set "DISPLAY_BATTERY=ERROR"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!BATTERY_RESULT!"=="실행 전" set "DISPLAY_BATTERY=NOT RUN"

set "DISPLAY_TIME=WAITING"
if "!TIME_SYNC_RESULT!"=="동기화 중" set "DISPLAY_TIME=RUNNING"
if "!TIME_SYNC_RESULT!"=="정상" set "DISPLAY_TIME=OK"
if "!TIME_SYNC_RESULT!"=="실패" set "DISPLAY_TIME=FAILED"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!TIME_SYNC_RESULT!"=="실행 전" set "DISPLAY_TIME=NOT RUN"

set "DISPLAY_CAMERA=WAITING"
if "!CAMERA_RESULT!"=="실행 중" set "DISPLAY_CAMERA=RUNNING"
if "!CAMERA_RESULT!"=="실행 완료" set "DISPLAY_CAMERA=DONE"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!CAMERA_RESULT!"=="실행 전" set "DISPLAY_CAMERA=NOT RUN"

set "DISPLAY_SOUND=WAITING"
if "!SOUND_RESULT!"=="실행 중" set "DISPLAY_SOUND=RUNNING"
if "!SOUND_RESULT!"=="실행 완료" set "DISPLAY_SOUND=DONE"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!SOUND_RESULT!"=="실행 전" set "DISPLAY_SOUND=NOT RUN"

set "DISPLAY_RAM=!RAM_RESULT!"
if "!RAM_RESULT!"=="UNKNOWN" set "DISPLAY_RAM=WAITING"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!RAM_RESULT!"=="UNKNOWN" set "DISPLAY_RAM=UNKNOWN"
set "DISPLAY_CPU=!CPU_RESULT!"
if "!CPU_RESULT!"=="UNKNOWN" set "DISPLAY_CPU=WAITING"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!CPU_RESULT!"=="UNKNOWN" set "DISPLAY_CPU=UNKNOWN"
set "DISPLAY_GPU=!GPU_RESULT!"
if "!GPU_RESULT!"=="UNKNOWN" set "DISPLAY_GPU=WAITING"
if "!CURRENT_STAGE!"=="FINAL REPORT" if "!GPU_RESULT!"=="UNKNOWN" set "DISPLAY_GPU=UNKNOWN"
exit /b

:renderDashboard
call :buildDisplayValues
set "CLOCK_STAMP=%DATE% %TIME:~0,8%"
cls
call :frameTop
call :frameBlank
call :printLogo
call :frameBlank

call :boxTop
call :boxTitle "QC // RENTAL NODE OPS :: LIVE QC TRACE"
call :boxSep

call :printTwinLine "TRACE-ID" "!TRACE_ID!" "CLOCK" "!CLOCK_STAMP!"
call :printTwinLine "NODE" "!NODE_NAME!" "AUTH" "!AUTH_STATE!"
call :printTwinLine "CHANNEL" "!CHANNEL_STATE!" "WINDOW" "136x38 / LIVE"
call :boxSep

if /I not "!CURRENT_STAGE!"=="FINAL REPORT" (
    call :boxTitle "LIVE TRACE BUFFER"
    call :boxSep
    call :printLine "CURRENT PHASE" "!CURRENT_STAGE!"
    call :printLine "DETAIL" "!CURRENT_DETAIL!"
    call :printLine "LAST ACTION" "!LAST_ACTION!"
    call :boxSep
)

call :boxTitle "MODULE GRID"
call :boxSep

call :printTwinLine "OVERALL" "!DISPLAY_OVERALL!" "ALERT" "!DISPLAY_ALERT!"
call :printTwinLine "ISSUES" "!ISSUE_COUNT!" "USB" "!DISPLAY_USB!"
call :printTwinLine "SYS TOOLS" "!DISPLAY_SYSTEM!" "C DRIVE" "!DISPLAY_CDRIVE!"
call :printTwinLine "BLUETOOTH" "!DISPLAY_BT!" "TIME SYNC" "!DISPLAY_TIME!"
call :printTwinLine "CAMERA" "!DISPLAY_CAMERA!" "SOUND" "!DISPLAY_SOUND!"
call :printTwinLine "RAM" "!DISPLAY_RAM!" "BATTERY" "!DISPLAY_BATTERY!"
call :printTwinLine "CPU" "!DISPLAY_CPU!" "GPU" "!DISPLAY_GPU!"
call :boxSep
call :boxTitle "POWER TELEMETRY"
call :boxSep
call :printTwinLine "EFFICIENCY" "!BATTERY_HEALTH!" "CYCLE" "!BATTERY_CYCLE!"
call :printTwinLine "LEVEL" "!BATTERY_LEVEL!" "CHARGE" "!BATTERY_CHARGE!"
call :boxBottom
if /I not "!CURRENT_STAGE!"=="FINAL REPORT" call :frameBottom
exit /b

:matrix
set "CURRENT_STAGE=BOOT"
set "CURRENT_DETAIL=Preparing rental QC console..."
set "LAST_ACTION=Console session opened"
call :renderDashboard
ping -n 1 127.0.0.1 >nul
set "CURRENT_STAGE=AUTH"
set "CURRENT_DETAIL=Administrator token verified"
set "LAST_ACTION=Administrator privilege verified"
call :renderDashboard
ping -n 1 127.0.0.1 >nul
set "CURRENT_STAGE=NODE"
set "CURRENT_DETAIL=Opening local inspection channel..."
set "LAST_ACTION=Localhost inspection channel ready"
call :renderDashboard
ping -n 1 127.0.0.1 >nul
set "CURRENT_STAGE=LOAD"
set "CURRENT_DETAIL=Diagnostic modules loaded"
set "LAST_ACTION=Diagnostic modules prepared"
call :renderDashboard
ping -n 1 127.0.0.1 >nul
exit /b

:runUsbTool
set "TOOL_DIR=%~1"
set "TOOL_NAME=%~2"
set "TOOL_DELAY=%~3"
if "!TOOL_DELAY!"=="" set "TOOL_DELAY=2"

if exist "!TOOL_DIR!\!TOOL_NAME!" (
    set "CURRENT_STAGE=USB TOOLKIT"
    set "CURRENT_DETAIL=Launching USB utility..."
    set "LAST_ACTION=USB tool launch requested"
    call :renderDashboard
    start "" "!TOOL_DIR!\!TOOL_NAME!"
) else (
    set "CURRENT_STAGE=USB TOOLKIT"
    set "CURRENT_DETAIL=USB utility missing. Skipping slot..."
    set "LAST_ACTION=USB tool skipped"
    call :renderDashboard
)
if not "!TOOL_DELAY!"=="0" timeout /t !TOOL_DELAY! >nul
exit /b

:openTool
set "TOOL_LABEL=%~1"
set "TOOL_TARGET=%~2"
set "TOOL_DELAY=%~3"
set "TOOL_STAGE=%~4"
if "!TOOL_DELAY!"=="" set "TOOL_DELAY=1"
if "!TOOL_STAGE!"=="" set "TOOL_STAGE=SYSTEM TOOL CHAIN"

set "CURRENT_STAGE=!TOOL_STAGE!"
set "CURRENT_DETAIL=Opening !TOOL_LABEL!..."
set "LAST_ACTION=Opened !TOOL_LABEL!"
call :renderDashboard
start !TOOL_TARGET!
timeout /t !TOOL_DELAY! >nul
exit /b

:main

:: 관리자 권한 체크
set "CURRENT_STAGE=AUTH"
set "CURRENT_DETAIL=Checking administrator privilege..."
set "LAST_ACTION=Checking administrator privilege"
set "AUTH_STATE=CHECKING"
call :renderDashboard
net session >nul 2>&1
if %errorLevel% neq 0 (
    set "CURRENT_STAGE=AUTH"
    set "CURRENT_DETAIL=Elevation required. Sending UAC request..."
    set "LAST_ACTION=UAC elevation requested"
    set "AUTH_STATE=ELEVATION REQUIRED"
    call :renderDashboard
    set "QC_SCRIPT=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand JABxAD0AWwBjAGgAYQByAF0AMwA0ADsAIABTAHQAYQByAHQALQBQAHIAbwBjAGUAcwBzACAALQBGAGkAbABlAFAAYQB0AGgAIAAkAGUAbgB2ADoAQwBvAG0AUwBwAGUAYwAgAC0AQQByAGcAdQBtAGUAbgB0AEwAaQBzAHQAIABAACgAJwAvAGsAJwAsACAAKAAnAGMAYQBsAGwAIAAnACAAKwAgACQAcQAgACsAIAAkAGUAbgB2ADoASABBAEwARgBFAFQAXwBTAEMAUgBJAFAAVAAgACsAIAAkAHEAKQApACAALQBWAGUAcgBiACAAUgB1AG4AQQBzAA==
    exit
)

set "AUTH_STATE=ADMIN"
call :section "ADMIN ELEVATION VERIFIED" "SYSTEM ACCESS LEVEL : ADMIN"
call :matrix

set "CURRENT_STAGE=DEVICE MAP"
set "CURRENT_DETAIL=Building PCI / ACPI / USB / STORAGE map..."
set "LAST_ACTION=Secure Boot state requires BIOS verification"
call :renderDashboard

set "USB_RESULT=탐색 중"
set "CURRENT_STAGE=USB SCAN"
set "CURRENT_DETAIL=Scanning removable drives for USB Utill folder..."
set "LAST_ACTION=Removable media scan started"
call :renderDashboard

for %%d in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\Utill\" (
        set "USB_RESULT=발견됨 (%%d:\Utill)"
        set "CURRENT_STAGE=USB SCAN"
        set "CURRENT_DETAIL=USB toolkit located at %%d:\Utill"
        set "LAST_ACTION=USB toolkit located"
        call :renderDashboard

        call :runUsbTool "%%d:\Utill" "1.tm5.exe"
        call :runUsbTool "%%d:\Utill" "1.노트북 배터리 상태 확인.exe"
        call :runUsbTool "%%d:\Utill" "1.온도 테스트 툴.exe"
        call :runUsbTool "%%d:\Utill" "1.저장장치 상태 확인 툴.exe"
        call :runUsbTool "%%d:\Utill" "1.저장장치 확인 툴.exe"
        call :runUsbTool "%%d:\Utill" "2.키보드 테스트 툴.exe" 0

        goto tools
    )
)

set "USB_RESULT=찾기 실패"
set "OVERALL_RESULT=확인 필요"
set "CURRENT_STAGE=USB SCAN"
set "CURRENT_DETAIL=USB Utill folder not found. Continuing system checks..."
set "LAST_ACTION=USB toolkit not found / continuing"
call :renderDashboard
timeout /t 1 >nul
goto tools

:tools
title [RENTAL QC ACTIVE] QC USB AUTO CHECK
set "SYSTEM_TOOLS_RESULT=실행 중"
call :section "SYSTEM TOOL CHAIN" "TOOLS OPENING / LIVE OUTPUT STREAM"

call :openTool "Device Manager" "devmgmt.msc"
call :openTool "Disk Management" "diskmgmt.msc"
call :openTool "Task Manager" "taskmgr"
call :openTool "Windows Activation" "ms-settings:activation" 3
set "SYSTEM_TOOLS_RESULT=실행 완료"
set "CURRENT_STAGE=SYSTEM TOOL CHAIN"
set "CURRENT_DETAIL=Core Windows tools opened"
set "LAST_ACTION=System tools opened"
call :renderDashboard

:: RAM 체크
call :section "MEMORY RECON" "HARDWARE SNAPSHOT"
for /f "usebackq delims=" %%R in (`powershell -NoProfile -Command "$ErrorActionPreference='Stop'; try { $mem = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory; ([string][math]::Round($mem / 1GB, 0)) + ' GB' } catch { 'UNKNOWN' }"`) do set "RAM_RESULT=%%R"
set "CURRENT_STAGE=MEMORY RECON"
set "CURRENT_DETAIL=Memory snapshot captured"
set "LAST_ACTION=RAM detected: !RAM_RESULT!"
call :renderDashboard
timeout /t 1 >nul

:: CPU / GPU check
call :section "HARDWARE RECON" "CPU / GPU SNAPSHOT"
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$ErrorActionPreference='Stop'; try { $n=(Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty Name); if ([string]::IsNullOrWhiteSpace($n)) { 'UNKNOWN' } else { $n=$n.Trim(); if ($n.Length -gt 44) { $n.Substring(0,44) } else { $n } } } catch { 'UNKNOWN' }"`) do set "CPU_RESULT=%%P"
for /f "usebackq delims=" %%G in (`powershell -NoProfile -Command "$ErrorActionPreference='Stop'; try { $g=(Get-CimInstance Win32_VideoController | Where-Object { $_.Name } | Select-Object -ExpandProperty Name); $n=($g -join ' / '); if ([string]::IsNullOrWhiteSpace($n)) { 'UNKNOWN' } else { $n=$n.Trim(); if ($n.Length -gt 44) { $n.Substring(0,44) } else { $n } } } catch { 'UNKNOWN' }"`) do set "GPU_RESULT=%%G"
set "CURRENT_STAGE=HARDWARE RECON"
set "CURRENT_DETAIL=CPU and graphics snapshot captured"
set "LAST_ACTION=CPU: !CPU_RESULT! / GPU: !GPU_RESULT!"
call :renderDashboard
timeout /t 1 >nul

:: Rental workflow does not resize the C drive.
set "C_EXTEND_RESULT=RENTAL SKIP"
set "CURRENT_STAGE=RENTAL STORAGE POLICY"
set "CURRENT_DETAIL=C drive expansion disabled for rental workflow"
set "LAST_ACTION=C drive expansion skipped"
call :renderDashboard
timeout /t 1 >nul

:: 블루투스 체크
set "BLUETOOTH_RESULT=확인 중"
call :section "BLUETOOTH LINK CHECK" "DEVICE ENUMERATION"
powershell -Command "if (Get-PnpDevice -Class Bluetooth -Status OK) { exit 0 } else { exit 1 }" >nul 2>&1

if %errorlevel%==0 (
    set "BLUETOOTH_RESULT=정상"
    set "BT_ACTION=Bluetooth OK"
) else (
    set "BLUETOOTH_RESULT=오류 또는 없음"
    set "BT_ACTION=Bluetooth check failed"
    set "OVERALL_RESULT=확인 필요"
)
set "CURRENT_STAGE=BLUETOOTH LINK CHECK"
set "CURRENT_DETAIL=Bluetooth device enumeration completed"
set "LAST_ACTION=!BT_ACTION!"
call :renderDashboard
timeout /t 2 >nul

:: 배터리 체크
set "BATTERY_RESULT=확인 중"
call :section "BATTERY DIAGNOSTICS" "POWER TELEMETRY"
set "BATTERY_RESULT=배터리 없음"
set "BATTERY_HEALTH=N/A"
set "BATTERY_CYCLE=N/A"
set "BATTERY_LEVEL=N/A"
set "BATTERY_CHARGE=N/A"

for /f "usebackq tokens=1,* delims==" %%A in (`powershell -NoProfile -Command "$report = Join-Path $env:TEMP 'usb_battery_report.html'; $state = '배터리 없음'; $health = 'N/A'; $cycle = 'N/A'; $level = 'N/A'; $charge = 'N/A'; powercfg /batteryreport /output $report > $null 2>&1; $battery = Get-WmiObject Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1; if ($battery) { $state = '정상'; if ($null -ne $battery.EstimatedChargeRemaining) { $level = [string]$battery.EstimatedChargeRemaining + '%%' }; switch ($battery.BatteryStatus) { 1 { $charge = 'DISCHARGING' } 2 { $charge = 'ON AC' } 3 { $charge = 'FULL' } 4 { $charge = 'LOW'; $state = '경고' } 5 { $charge = 'CRITICAL'; $state = '경고' } 6 { $charge = 'CHARGING' } 7 { $charge = 'CHARGING' } 8 { $charge = 'CHARGING' } 9 { $charge = 'CHARGING' } 11 { $charge = 'PARTIAL' } default { $charge = 'UNKNOWN' } } }; if (Test-Path $report) { $html = Get-Content -LiteralPath $report -Raw; $m1 = [regex]::Match($html, 'DESIGN CAPACITY</span></td><td>([0-9,]+) mWh', 'IgnoreCase'); $m2 = [regex]::Match($html, 'FULL CHARGE CAPACITY</span></td><td>([0-9,]+) mWh', 'IgnoreCase'); $m3 = [regex]::Match($html, 'CYCLE COUNT</span></td><td>([0-9,]+)', 'IgnoreCase'); if ($m1.Success -and $m2.Success) { $design = [double](($m1.Groups[1].Value) -replace ',', ''); $full = [double](($m2.Groups[1].Value) -replace ',', ''); if ($design -gt 0) { $health = [string][math]::Round(($full / $design) * 100, 0) + '%%' } }; if ($m3.Success) { $cycle = $m3.Groups[1].Value } }; Write-Output ('STATE=' + $state); Write-Output ('HEALTH=' + $health); Write-Output ('CYCLE=' + $cycle); Write-Output ('LEVEL=' + $level); Write-Output ('CHARGE=' + $charge)"`) do (
    if /I "%%A"=="STATE" set "BATTERY_RESULT=%%B"
    if /I "%%A"=="HEALTH" set "BATTERY_HEALTH=%%B"
    if /I "%%A"=="CYCLE" set "BATTERY_CYCLE=%%B"
    if /I "%%A"=="LEVEL" set "BATTERY_LEVEL=%%B"
    if /I "%%A"=="CHARGE" set "BATTERY_CHARGE=%%B"
)

if "%BATTERY_RESULT%"=="정상" (
    set "LAST_ACTION=Battery normal"
) else if "%BATTERY_RESULT%"=="배터리 없음" (
    set "LAST_ACTION=Battery not found"
) else (
    set "LAST_ACTION=Battery warning"
    set "OVERALL_RESULT=확인 필요"
)
set "CURRENT_STAGE=BATTERY DIAGNOSTICS"
set "CURRENT_DETAIL=Health !BATTERY_HEALTH! / Cycle !BATTERY_CYCLE! / Level !BATTERY_LEVEL!"
call :renderDashboard
timeout /t 2 >nul

:: 시간 동기화
set "TIME_SYNC_RESULT=동기화 중"
call :section "TIME SYNC" "NTP HANDSHAKE"

powershell -NoProfile -Command "$ErrorActionPreference='Stop'; try { tzutil /s 'Korea Standard Time' | Out-Null; w32tm /config /manualpeerlist:'time.windows.com,0x8 time.google.com,0x8 time.cloudflare.com,0x8' /syncfromflags:manual /update | Out-Null; Restart-Service w32time -Force; $ok = $false; for ($i = 0; $i -lt 5; $i++) { Start-Sleep -Seconds 2; w32tm /resync /force > $null 2>&1; if ($LASTEXITCODE -eq 0) { Start-Sleep -Seconds 2; $source = (w32tm /query /source 2>$null | Select-Object -First 1).Trim(); if ($LASTEXITCODE -eq 0 -and $source -and $source -notmatch 'Local CMOS Clock') { $ok = $true; break } } }; if ($ok) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1

if %errorlevel%==0 (
    set "TIME_SYNC_RESULT=정상"
    set "TIME_ACTION=Time sync OK"
) else (
    set "TIME_SYNC_RESULT=실패"
    set "TIME_ACTION=Time sync failed"
    set "OVERALL_RESULT=확인 필요"
)
set "CURRENT_STAGE=TIME SYNC"
set "CURRENT_DETAIL=NTP time synchronization completed"
set "LAST_ACTION=!TIME_ACTION!"
call :renderDashboard
timeout /t 2 >nul

:: 카메라 테스트
set "CAMERA_RESULT=실행 중"
call :section "CAMERA / SOUND / HUMAN IO CHECK" "FINAL DEVICE PROBE"
call :openTool "Camera App" "microsoft.windows.camera:" 1 "CAMERA CHECK"
set "CAMERA_RESULT=실행 완료"
set "CURRENT_STAGE=CAMERA CHECK"
set "CURRENT_DETAIL=Camera app launch requested"
set "LAST_ACTION=Camera app opened"
call :renderDashboard

:: 사운드 테스트
set "SOUND_RESULT=실행 중"
set "CURRENT_STAGE=SOUND CHECK"
set "CURRENT_DETAIL=Running speaker beep test..."
set "LAST_ACTION=Speaker beep test"
call :renderDashboard
powershell -c "[console]::beep(1000,500)"
set "SOUND_RESULT=실행 완료"
set "CURRENT_STAGE=CHECK SEQUENCE COMPLETED"
set "CURRENT_DETAIL=Automatic checks completed. Compiling report..."
set "LAST_ACTION=Result buffer ready"
call :renderDashboard

:summary
@echo off
if "%OVERALL_RESULT%"=="확인 전" set "OVERALL_RESULT=정상"

title QC AUTOMATION :: RENTAL FINAL REPORT
color 0A
mode con: cols=136 lines=38 >nul 2>&1
call :centerConsole
set "CURRENT_STAGE=FINAL REPORT"
set "CURRENT_DETAIL=Final report locked"
set "LAST_ACTION=Final report locked"
call :renderDashboard
timeout /t 1 >nul
call :boxTop
call :boxTitle "OPERATOR COMMAND"
call :printTwinLine "1" "CLOSE TERMINAL" "2" "SHUTDOWN TO UEFI BIOS"
call :boxBottom
call :frameBottom
set /p FINAL_CHOICE=  QC^> 

:: 창 정리
taskkill /f /im mmc.exe >nul 2>&1
taskkill /f /im taskmgr.exe >nul 2>&1
taskkill /f /im SystemSettings.exe >nul 2>&1
taskkill /f /im WindowsCamera.exe >nul 2>&1

if "%FINAL_CHOICE%"=="2" (
    shutdown /r /fw /t 0
    exit
)

exit

:prepareLogo
powershell -NoProfile -ExecutionPolicy Bypass -Command "$w=132;$tag='[RENTAL | portfolio | 1.0v]';$on=([string][char]9608)+([string][char]9608);$sp='  ';function Draw($sets){$rows=@();for($i=0;$i -lt 5;$i++){$r='';foreach($set in $sets){if($r.Length -gt 0){$r+='00'};$r+=$set[$i]};$rows+=$r};$out=@();foreach($r in $rows){$line='';for($c=0;$c -lt $r.Length;$c++){if($r[$c] -eq '1'){$line+=$on}else{$line+=$sp}};$out+=$line.TrimEnd()};return $out};$A=@('1110','1001','1111','1001','1001');$R=@('1110','1001','1110','1010','1001');$T=@('11111','00100','00100','00100','00100');$H=@('1001','1001','1111','1001','1001');$U=@('1001','1001','1001','1001','1111');$out=Draw @($A,$R,$T,$H,$U,$R);$max=($out|Measure-Object -Property Length -Maximum).Maximum;$left=[Math]::Max(0,[int](($w-$max)/2));$lines=foreach($l in $out){(' '*$left)+$l};$pos=[Math]::Max(0,$w-$tag.Length);if($lines[0].Length -lt $pos){$lines[0]=$lines[0].PadRight($pos)+$tag}else{$lines[0]=$lines[0]+'  '+$tag};[IO.File]::WriteAllLines($env:QC_LOGO_FILE,$lines,[Text.UTF8Encoding]::new($false))" >nul 2>&1
exit /b

:centerConsole
powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand JABjAG8AZABlACAAPQAgAEAAIgAKAHUAcwBpAG4AZwAgAFMAeQBzAHQAZQBtADsACgB1AHMAaQBuAGcAIABTAHkAcwB0AGUAbQAuAFIAdQBuAHQAaQBtAGUALgBJAG4AdABlAHIAbwBwAFMAZQByAHYAaQBjAGUAcwA7AAoAcAB1AGIAbABpAGMAIABjAGwAYQBzAHMAIABIAGEAbABmAGUAdABDAG8AbgBzAG8AbABlAFcAaQBuAGQAbwB3ACAAewAKACAAIAAgACAAWwBEAGwAbABJAG0AcABvAHIAdAAoACIAawBlAHIAbgBlAGwAMwAyAC4AZABsAGwAIgApAF0AIABwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABJAG4AdABQAHQAcgAgAEcAZQB0AEMAbwBuAHMAbwBsAGUAVwBpAG4AZABvAHcAKAApADsACgAgACAAIAAgAFsARABsAGwASQBtAHAAbwByAHQAKAAiAHUAcwBlAHIAMwAyAC4AZABsAGwAIgApAF0AIABwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABiAG8AbwBsACAARwBlAHQAVwBpAG4AZABvAHcAUgBlAGMAdAAoAEkAbgB0AFAAdAByACAAaABXAG4AZAAsACAAbwB1AHQAIABSAEUAQwBUACAAcgBlAGMAdAApADsACgAgACAAIAAgAFsARABsAGwASQBtAHAAbwByAHQAKAAiAHUAcwBlAHIAMwAyAC4AZABsAGwAIgApAF0AIABwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABiAG8AbwBsACAATQBvAHYAZQBXAGkAbgBkAG8AdwAoAEkAbgB0AFAAdAByACAAaABXAG4AZAAsACAAaQBuAHQAIABYACwAIABpAG4AdAAgAFkALAAgAGkAbgB0ACAAbgBXAGkAZAB0AGgALAAgAGkAbgB0ACAAbgBIAGUAaQBnAGgAdAAsACAAYgBvAG8AbAAgAGIAUgBlAHAAYQBpAG4AdAApADsACgAgACAAIAAgAHAAdQBiAGwAaQBjACAAcwB0AHIAdQBjAHQAIABSAEUAQwBUACAAewAgAHAAdQBiAGwAaQBjACAAaQBuAHQAIABMAGUAZgB0ADsAIABwAHUAYgBsAGkAYwAgAGkAbgB0ACAAVABvAHAAOwAgAHAAdQBiAGwAaQBjACAAaQBuAHQAIABSAGkAZwBoAHQAOwAgAHAAdQBiAGwAaQBjACAAaQBuAHQAIABCAG8AdAB0AG8AbQA7ACAAfQAKAH0ACgAiAEAACgB0AHIAeQAgAHsACgAgACAAIAAgAEEAZABkAC0AVAB5AHAAZQAgACQAYwBvAGQAZQAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAKACAAIAAgACAAQQBkAGQALQBUAHkAcABlACAALQBBAHMAcwBlAG0AYgBsAHkATgBhAG0AZQAgAFMAeQBzAHQAZQBtAC4AVwBpAG4AZABvAHcAcwAuAEYAbwByAG0AcwAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAKACAAIAAgACAAJABoACAAPQAgAFsASABhAGwAZgBlAHQAQwBvAG4AcwBvAGwAZQBXAGkAbgBkAG8AdwBdADoAOgBHAGUAdABDAG8AbgBzAG8AbABlAFcAaQBuAGQAbwB3ACgAKQAKACAAIAAgACAAaQBmACAAKAAkAGgAIAAtAG4AZQAgAFsASQBuAHQAUAB0AHIAXQA6ADoAWgBlAHIAbwApACAAewAKACAAIAAgACAAIAAgACAAIAAkAHIAIAA9ACAATgBlAHcALQBPAGIAagBlAGMAdAAgAEgAYQBsAGYAZQB0AEMAbwBuAHMAbwBsAGUAVwBpAG4AZABvAHcAKwBSAEUAQwBUAAoAIAAgACAAIAAgACAAIAAgAFsASABhAGwAZgBlAHQAQwBvAG4AcwBvAGwAZQBXAGkAbgBkAG8AdwBdADoAOgBHAGUAdABXAGkAbgBkAG8AdwBSAGUAYwB0ACgAJABoACwAIABbAHIAZQBmAF0AJAByACkAIAB8ACAATwB1AHQALQBOAHUAbABsAAoAIAAgACAAIAAgACAAIAAgACQAYwB3ACAAPQAgACQAcgAuAFIAaQBnAGgAdAAgAC0AIAAkAHIALgBMAGUAZgB0AAoAIAAgACAAIAAgACAAIAAgACQAYwBoACAAPQAgACQAcgAuAEIAbwB0AHQAbwBtACAALQAgACQAcgAuAFQAbwBwAAoAIAAgACAAIAAgACAAIAAgACQAdwBhACAAPQAgAFsAUwB5AHMAdABlAG0ALgBXAGkAbgBkAG8AdwBzAC4ARgBvAHIAbQBzAC4AUwBjAHIAZQBlAG4AXQA6ADoARgByAG8AbQBIAGEAbgBkAGwAZQAoACQAaAApAC4AVwBvAHIAawBpAG4AZwBBAHIAZQBhAAoAIAAgACAAIAAgACAAIAAgACQAeAAgAD0AIABbAGkAbgB0AF0AKAAkAHcAYQAuAEwAZQBmAHQAIAArACAAKAAoACQAdwBhAC4AVwBpAGQAdABoACAALQAgACQAYwB3ACkAIAAvACAAMgApACkACgAgACAAIAAgACAAIAAgACAAJAB5ACAAPQAgAFsAaQBuAHQAXQAoACQAdwBhAC4AVABvAHAAIAArACAAKAAoACQAdwBhAC4ASABlAGkAZwBoAHQAIAAtACAAJABjAGgAKQAgAC8AIAAyACkAKQAKACAAIAAgACAAIAAgACAAIABbAEgAYQBsAGYAZQB0AEMAbwBuAHMAbwBsAGUAVwBpAG4AZABvAHcAXQA6ADoATQBvAHYAZQBXAGkAbgBkAG8AdwAoACQAaAAsACAAJAB4ACwAIAAkAHkALAAgACQAYwB3ACwAIAAkAGMAaAAsACAAJAB0AHIAdQBlACkAIAB8ACAATwB1AHQALQBOAHUAbABsAAoAIAAgACAAIAB9AAoAfQAgAGMAYQB0AGMAaAAgAHsAfQA= >nul 2>&1
exit /b
:section
set "CURRENT_STAGE=%~1"
set "CURRENT_DETAIL=%~2"
set "LAST_ACTION=%~1"
call :renderDashboard
exit /b
