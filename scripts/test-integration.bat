@echo off
setlocal

pushd %~dp0\..

set VSCODEUSERDATADIR=%TEMP%\vscodeuserfolder-%RANDOM%-%TIME:~6,2%
set VSCODECRASHDIR=%~dp0\..\.build\crashes

:: Figure out which Electron to use for running tests
if "%INTEGRATION_TEST_ELECTRON_PATH%"=="" (
	:: Run out of sources: no need to compile as code.bat takes care of it
	chcp 65001
	set INTEGRATION_TEST_ELECTRON_PATH=.\scripts\code.bat
	set VSCODE_BUILD_BUILTIN_EXTENSIONS_SILENCE_PLEASE=1

	echo Storing crash reports into '%VSCODECRASHDIR%'.
	echo Running integration tests out of sources.
) else (
	:: Run from a built: need to compile all test extensions
	:: because we run extension tests from their source folders
	:: and the build bundles extensions into .build webpacked
	call yarn gulp 	compile-extension:azurecore^
					compile-extension:git

	:: Configuration for more verbose output
	set VSCODE_CLI=1
	set ELECTRON_ENABLE_LOGGING=1

	echo Storing crash reports into '%VSCODECRASHDIR%'.
	echo Running integration tests with '%INTEGRATION_TEST_ELECTRON_PATH%' as build.
)

:: Integration & performance tests in AMD
:: TODO port over an re-enable API tests
:: call .\scripts\test.bat --runGlob **\*.integrationTest.js %*
:: if %errorlevel% neq 0 exit /b %errorlevel%

:: Tests in the extension host

REM call "%INTEGRATION_TEST_ELECTRON_PATH%" %~dp0\..\extensions\vscode-api-tests\testWorkspace --enable-proposed-api=vscode.vscode-api-tests --extensionDevelopmentPath=%~dp0\..\extensions\vscode-api-tests --extensionTestsPath=%~dp0\..\extensions\vscode-api-tests\out\singlefolder-tests --disable-telemetry --crash-reporter-directory=%VSCODECRASHDIR% --no-cached-data --disable-updates --disable-extensions --user-data-dir=%VSCODEUSERDATADIR%
REM if %errorlevel% neq 0 exit /b %errorlevel%

REM call "%INTEGRATION_TEST_ELECTRON_PATH%" %~dp0\..\extensions\vscode-api-tests\testworkspace.code-workspace --enable-proposed-api=vscode.vscode-api-tests --extensionDevelopmentPath=%~dp0\..\extensions\vscode-api-tests --extensionTestsPath=%~dp0\..\extensions\vscode-api-tests\out\workspace-tests --disable-telemetry --crash-reporter-directory=%VSCODECRASHDIR% --no-cached-data --disable-updates --disable-extensions --user-data-dir=%VSCODEUSERDATADIR%
REM if %errorlevel% neq 0 exit /b %errorlevel%

REM call "%INTEGRATION_TEST_ELECTRON_PATH%" %~dp0\..\extensions\vscode-colorize-tests\test --extensionDevelopmentPath=%~dp0\..\extensions\vscode-colorize-tests --extensionTestsPath=%~dp0\..\extensions\vscode-colorize-tests\out --disable-telemetry --crash-reporter-directory=%VSCODECRASHDIR% --no-cached-data --disable-updates --disable-extensions --user-data-dir=%VSCODEUSERDATADIR%
REM if %errorlevel% neq 0 exit /b %errorlevel%

REM call "%INTEGRATION_TEST_ELECTRON_PATH%" %~dp0\..\extensions\typescript-language-features\test-workspace --extensionDevelopmentPath=%~dp0\..\extensions\typescript-language-features --extensionTestsPath=%~dp0\..\extensions\typescript-language-features\out\test --disable-telemetry --crash-reporter-directory=%VSCODECRASHDIR% --no-cached-data --disable-updates --disable-extensions --user-data-dir=%VSCODEUSERDATADIR%
REM if %errorlevel% neq 0 exit /b %errorlevel%

REM call "%INTEGRATION_TEST_ELECTRON_PATH%" %~dp0\..\extensions\markdown-language-features\out\test\test-fixtures --extensionDevelopmentPath=%~dp0\..\extensions\markdown-language-features --extensionTestsPath=%~dp0\..\extensions\markdown-language-features\out\test --disable-telemetry --crash-reporter-directory=%VSCODECRASHDIR% --no-cached-data --disable-updates --disable-extensions --user-data-dir=%VSCODEUSERDATADIR%
REM if %errorlevel% neq 0 exit /b %errorlevel%

REM call "%INTEGRATION_TEST_ELECTRON_PATH%" $%~dp0\..\extensions\emmet\out\test\test-fixtures --extensionDevelopmentPath=%~dp0\..\extensions\emmet --extensionTestsPath=%~dp0\..\extensions\emmet\out\test --disable-telemetry --crash-reporter-directory=%VSCODECRASHDIR% --no-cached-data --disable-updates --disable-extensions --user-data-dir=%VSCODEUSERDATADIR% .
REM if %errorlevel% neq 0 exit /b %errorlevel%

call "%INTEGRATION_TEST_ELECTRON_PATH%" %~dp0\..\extensions\azurecore\test-fixtures --extensionDevelopmentPath=%~dp0\..\extensions\azurecore --extensionTestsPath=%~dp0\..\extensions\azurecore\out\test --no-cached-data --disable-telemetry --disable-crash-reporter --disable-updates --disable-extensions --user-data-dir=%VSCODEUSERDATADIR%
if %errorlevel% neq 0 exit /b %errorlevel%

REM call "%INTEGRATION_TEST_ELECTRON_PATH%" %~dp0\..\extensions\vscode-notebook-tests\test --enable-proposed-api=vscode.vscode-notebook-tests --extensionDevelopmentPath=%~dp0\..\extensions\vscode-notebook-tests --extensionTestsPath=%~dp0\..\extensions\vscode-notebook-tests\out --disable-telemetry --crash-reporter-directory=%VSCODECRASHDIR% --no-cached-data --disable-updates --disable-extensions --user-data-dir=%VSCODEUSERDATADIR%
REM if %errorlevel% neq 0 exit /b %errorlevel%

for /f "delims=" %%i in ('node -p "require('fs').realpathSync.native(require('os').tmpdir())"') do set TEMPDIR=%%i
set GITWORKSPACE=%TEMPDIR%\git-%RANDOM%
mkdir %GITWORKSPACE%
call "%INTEGRATION_TEST_ELECTRON_PATH%" %GITWORKSPACE% --extensionDevelopmentPath=%~dp0\..\extensions\git --extensionTestsPath=%~dp0\..\extensions\git\out\test --enable-proposed-api=vscode.git --disable-telemetry --crash-reporter-directory=%VSCODECRASHDIR% --no-cached-data --disable-updates --disable-extensions --user-data-dir=%VSCODEUSERDATADIR%
if %errorlevel% neq 0 exit /b %errorlevel%

:: Tests in commonJS (HTML, CSS, JSON language server tests...)
REM call .\scripts\node-electron.bat .\node_modules\mocha\bin\_mocha .\extensions\*\server\out\test\**\*.test.js
REM if %errorlevel% neq 0 exit /b %errorlevel%

REM rmdir /s /q %VSCODEUSERDATADIR%

popd

endlocal
