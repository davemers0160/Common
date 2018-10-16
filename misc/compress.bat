
for /f "delims=" %%D in ('dir /a:d /b') do (
"C:\Program Files\7-Zip\7z" a %%~D_resnet18.zip  %%~D/*resnet18.mat )
