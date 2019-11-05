#### Installs the appropriate KMS client key for the detected OS ####
$OSversion = (Get-WmiObject -class Win32_OperatingSystem).Caption
switch -Regex ($OSversion) {
    'Windows 7 Professional'                 {$key = 'HMCNV-VVBFX-7HMBH-CTY9B-B4FXY';break}
    'Windows 7 Enterprise'                   {$key = 'MHF9N-XY6XB-WVXMC-BTDCT-MKKG7';break}
    'Windows 8 Professional'                 {$key = 'NG4HW-VH26C-733KW-K6F98-J8CK4';break}
    'Windows 8 Enterprise'                   {$key = '32JNW-9KQ84-P47T8-D8GGY-CWCK7';break}
    'Windows 8.1 Professional'               {$key = 'GCRJD-8NW9H-F2CDX-CCM8D-9D6T9';break}
    'Windows 8.1 Enterprise'                 {$key = 'MHF9N-XY6XB-WVXMC-BTDCT-MKKG7';break}
    'Windows 10 Professional'                {$key = 'W269N-WFGWX-YVC9B-4J6C9-T83GX';break}
    'Windows 10 Enterprise'                  {$key = 'NPPR9-FWDCX-D2C8J-H872K-2YT43';break}
    'Windows Server 2008 Standard'           {$key = 'TM24T-X9RMF-VWXK6-X8JC9-BFGM2';break}
    'Windows Server 2008 Datacenter'         {$key = '7M67G-PC374-GR742-YH8V4-TCBY3';break}
    'Windows Server 2008 R2 Standard'        {$key = 'YC6KT-GKW9T-YTKYR-T4X34-R7VHC';break}
    'Windows Server 2008 R2 Datacenter'      {$key = '74YFP-3QFB3-KQT8W-PMXWJ-7M648';break}
    'Windows Server 2012 Standard'           {$key = 'XC9B7-NBPP2-83J2H-RHMBY-92BT4';break}
    'Windows Server 2012 Datacenter'         {$key = '48HP8-DN98B-MYWDG-T2DCC-8W83P';break}
    'Windows Server 2012 R2 Standard'        {$key = 'D2N9P-3P6X9-2R39C-7RTCD-MDVJX';break}
    'Windows Server 2012 R2 Datacenter'      {$key = 'W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9';break}
    'Windows Server 2016 Standard LTSC'      {$key = 'WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY';break}
    'Windows Server 2016 Datacenter LTSC'    {$key = 'CB7KF-BWN84-R7R2Y-793K2-8XDDG';break}
    'Windows Server 2019 Standard 1709'      {$key = 'DPCNP-XQFKJ-BJF7R-FRC8D-GF6G4';break}
    'Windows Server 2019 Datacenter 1709'    {$key = '6Y6KB-N82V8-D8CQV-23MJW-BWTG6';break}
    'Windows Server 2019 Standard 1803'      {$key = 'PTXN8-JFHJM-4WC78-MPCBR-9W4KR';break}
    'Windows Server 2019 Datacenter 1803'    {$key = '2HXDN-KRXHB-GPYC7-YCKFJ-7FVDG';break}
    'Windows Server 2019 Standard 1903'      {$key = 'N2KJX-J94YW-TQVFB-DG9YT-724CC';break}
    'Windows Server 2019 Datacenter 1903'    {$key = '6NMRW-2C8FM-D24W7-TQWMY-CWH2D';break}
    'Windows Server 2019 Standard LTSC'      {$key = 'N69G4-B89J2-4G8F4-WWYCC-J464C';break}
    'Windows Server 2019 Datacenter LTSC'    {$key = 'WMDGN-G9PQG-XVVXX-R3X43-63DFG';break}
}
$KMSservice = Get-WMIObject -query "select * from SoftwareLicensingService"
Write-Debug 'Activating Windows.'
$null = $KMSservice.InstallProductKey($key)
$null = $KMSservice.RefreshLicenseStatus()