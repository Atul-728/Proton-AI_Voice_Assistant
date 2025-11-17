@echo off
REM Bring working dir to the script directory
pushd "%~dp0"

REM Optional: give a short delay to let other startup tasks finish
REM timeout /t 5 /nobreak >nul

REM Activate venv if it exists
if exist "venv\Scripts\activate.bat" (
    call "venv\Scripts\activate.bat"
) else (
    echo Virtualenv not found at venv\Scripts\activate.bat
    echo Ensure venv is created, or modify this script to point to your Python.
    pause
    popd
    exit /b 1
)

REM Install requirements only if not already installed (safe, idempotent)
pip install -r requirements.txt

REM Run the assistant (adjust entrypoint if needed)
python agent.py console

REM Return to original dir
popd