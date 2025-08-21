@echo off
setlocal EnableDelayedExpansion

REM --------------------------------------------------
REM Embedded-Only Triton-Windows & SageAttention Installer
REM Requires python_embeded\\python.exe in the same folder
REM --------------------------------------------------

REM 1) Enter script directory (handles spaces/parentheses)
pushd "%~dp0"

REM 2) Verify embedded Python
if not exist "python_embeded\\python.exe" (
    echo [ERROR] python_embeded\\python.exe not found! Please extract the portable build first.
    pause
    exit /b 1
)

REM 2a) Always download and overwrite Python include & libs
set "INCLUDE_LIBS_URL=https://github.com/woct0rdho/triton-windows/releases/download/v3.0.0-windows.post1/python_3.12.7_include_libs.zip"
echo [INFO] Downloading Python include and libs (overwrite)...
powershell -Command "Invoke-WebRequest -Uri !INCLUDE_LIBS_URL! -OutFile include_libs.zip"
powershell -Command "Expand-Archive -Path include_libs.zip -DestinationPath python_embeded -Force"
del include_libs.zip

REM 3) Set Python executable
set "PYTHON=python_embeded\\python.exe"

REM 4) Upgrade pip and install Triton-Windows using embedded Python
echo [1/3] Upgrading pip...
%PYTHON% -m pip install --upgrade pip

echo [2/3] Installing Triton-Windows (force reinstall)...
%PYTHON% -m pip install --force-reinstall triton-windows
if errorlevel 1 (
    echo [WARN] PyPI install failed; searching for local Triton-Windows wheel...
    for %%W in (wheels\\triton-windows-*.whl) do (
        echo Installing %%~nxW...
        %PYTHON% -m pip install "%%W" && goto after_triton
    )
    echo [ERROR] Failed to install Triton-Windows.
    pause
    exit /b 1
)
:after_triton

REM 5) Clone and build Sage Attention locally
echo [3/3] Cloning and building Sage Attention locally...
pushd python_embeded
if exist SageAttention rmdir /s /q SageAttention
git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention
..\python.exe -m pip install .
popd

REM Done
echo(
echo [DONE] Triton-Windows and Sage Attention have been installed via embedded Python!
pause

REM Restore original directory
popd
endlocal
