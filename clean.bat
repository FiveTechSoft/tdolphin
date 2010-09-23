@echo off
del objc\*.* /Q
del objh\*.* /Q
del objx\*.* /Q
del objcm\*.* /Q
del objm\*.* /Q
del objmx\*.* /Q
del objx64\*.* /Q
del objh64\*.* /Q
del objc64\*.* /Q
del comp.log
del tmp
del lib\dolp*.lib /Q
del lib\*.bak /Q
del lib\*.exp /Q
del lib\lib64\*.exp /Q
del lib\lib64\*.bak /Q
del lib\lib64\dol*.lib /Q
del *.bak /Q
del .\source\c\*.bak /Q
del .\source\prg\*.bak /Q
del .\include\*.bak
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
del *.tmp /Q
del *.lib /Q
del *.exp /Q
cd ..
cls
@echo on