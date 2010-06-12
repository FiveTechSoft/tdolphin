@echo off
del objc\*.* /Q
del objh\*.* /Q
del objx\*.* /Q
del comp.log
del tmp
del lib\dolphin*.lib /Q
del lib\*.bak /Q
del *.bak /Q
del .\source\c\*.bak /Q
del .\source\prg\*.bak /Q
cd samples
del *.bak /Q
del *.log /Q
del *.bc /Q
del *.map /Q
del *.ppo /Q
del *.obj /Q
del *.exe /Q
del *.c /Q
del *.tds /Q
cd ..
cls
@echo on