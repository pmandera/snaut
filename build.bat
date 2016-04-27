pyinstaller snaut_windows.spec

mkdir "dist\static"
xcopy "snaut\static" "dist\static" /e /s /h

mkdir "dist\templates"
xcopy "snaut\templates" "dist\templates" /e /s /h

mkdir "dist\doc"
xcopy "doc" "dist\doc" /e /s /h

xcopy "config.ini" "dist" 
xcopy "utils\windows\snaut.bat" "dist" 
xcopy "utils\windows\icon.ico" "dist" 

mkdir "dist\data"
