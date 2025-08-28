@echo off
set "target_dir=%~1"
if not exist "%target_dir%\pgr" (
    md "%target_dir%\pgr"
    if errorlevel 1 (
		@echo on
        echo failed to create folder: %target_dir%\pgr
		@echo off
        exit /b 1
    ) else (
		@echo on
        echo folder created: %target_dir%\pgr
		@echo off
    )
)

"C:\Program Files\Horus View and Explore\Horus SystemV2\horus_app_system_v2.exe" --lua-run topgr "C:\HORUS\kempkes_pgr_export.lua" "%target_dir%" "C:\HORUS\ladybug24466088.cal"