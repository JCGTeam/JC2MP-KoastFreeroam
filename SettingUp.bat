@echo off

REM Настройка кода перед публикацией в открытый доступ.

set "file=scripts\3-Tags\server\specialplayers.lua"
set "tempfile=%file%.tmp"

type nul > "%tempfile%"

echo sp = {} >> "%tempfile%"
echo spcol = {} >> "%tempfile%"
echo. >> "%tempfile%"
echo spcol["KF-DEV"] = Color( 170, 70, 255 ) >> "%tempfile%"
echo. >> "%tempfile%"
echo sp["STEAM_0:0:90087002"] = "KF-DEV" -- Hallkezz >> "%tempfile%"
move /y "%tempfile%" "%file%"

echo Code successfully replaced. Path: %file%

set "dtojc_file=scripts\OM-DiscordSupport\dtojc.lua"
set "tempfile=%dtojc_file%.tmp"

powershell -Command "(Get-Content -Path '%dtojc_file%') | ForEach-Object { $_ -replace 'local token = ''.*''', 'local token = ''''' } | Set-Content -Path '%tempfile%'"

move /y "%tempfile%" "%dtojc_file%"

echo Discord token successfully removed. Path: %dtojc_file%

REM set "links_to_replace=clck.ru/37FZrU vk.com/koastfreeroam steamcommunity.com/groups/koastfreeroam t.me/koastfreeroam clck.ru/37FZkT www.youtube.com/@jcgteam 62.122.214.141:7777 62.122.214.141:6666 vk.com/jcsurv"
REM set "replacement=[empty_link]"

for /r "scripts" %%I in (*.lua) do (
    for %%L in (%links_to_replace%) do (
        findstr "%%L" "%%I" > nul
        if not errorlevel 1 (
            powershell -Command "(Get-Content -Path '%%I') | ForEach-Object { $_ -replace '%%L', '%replacement%' } | Set-Content -Path '%%I.tmp'"
            move /y "%%I.tmp" "%%I"
            echo Link replaced in file: %%I
        )
    )
)

echo Links successfully replaced.

set "server_health_file=scripts\91-ServerHealth\server\ServerHealth.lua"
set "tempfile=%server_health_file%.tmp"

powershell -Command "(Get-Content -Path '%server_health_file%') | ForEach-Object { $_ -replace 'self.autoShutdown = true', 'self.autoShutdown = false' } | Set-Content -Path '%tempfile%'"

move /y "%tempfile%" "%server_health_file%"

echo ServerHealth autoShutdown setting updated. Path: %server_health_file%

set "logo_file=scripts\0-KoastFreeroam\client\logo.lua"
set "tempfile=%logo_file%.tmp"

powershell -Command "(Get-Content -Path '%logo_file%') | ForEach-Object { $_ -replace 'self.logo_txt = \"Koast Freeroam!\"', 'self.logo_txt = \"Koast Freeroam! [Open Source]\"' } | Set-Content -Path '%tempfile%'"

move /y "%tempfile%" "%logo_file%"

echo Logo text updated. Path: %logo_file%

pause