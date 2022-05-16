# Generic Utils
Invoke-WebRequest -Uri "https://www.guru3d.com/files-get/cpu-z-download,4.html" -OutFile "C:\Utils\CPUz\"
Invoke-WebRequest -Uri "https://www.guru3d.com/files-get/display-driver-uninstaller-download,9.html" -OutFile "C:\Utils\DDU\"
Invoke-WebRequest -Uri "https://www.guru3d.com/files-get/hwmonitor-download,4.html" -OutFile "C:\Utils\HWMonitor\"
# ATI Video Card Drivers
Invoke-WebRequest -Uri "https://www.guru3d.com/files-get/amd-radeon-software-adrenalin-22-5-1-whql-driver-download,1.html" -OutFile "C:\Utils\ATi"
# nVidia Video Card Drivers
Invoke-WebRequest -Uri "https://www.guru3d.com/files-get/geforce-512-77-whql-driver-download,1.html" -OutFile "C:\Utils\nVidia"
# Intel Graphics Drivers
Invoke-WebRequest -Uri "https://downloadmirror.intel.com/730488/igfx_win_101.1960.exe" -OutFile "C:\Utils\Intel"