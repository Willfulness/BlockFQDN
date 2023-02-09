Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class Win32Api
{
[System.Runtime.InteropServices.DllImportAttribute( "User32.dll", EntryPoint =  "GetWindowThreadProcessId" )]
public static extern int GetWindowThreadProcessId ( [System.Runtime.InteropServices.InAttribute()] System.IntPtr hWnd, out int lpdwProcessId );

[DllImport("User32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();

[DllImport("user32.dll")]
public static extern bool GetWindowRect(
    HandleRef hWnd,
    out RECT lpRect);
}

public struct RECT
{
    public int Left;        // x position of upper-left corner
    public int Top;         // y position of upper-left corner
    public int Right;       // x position of lower-right corner
    public int Bottom;      // y position of lower-right corner
}

"@

[Reflection.Assembly]::LoadWithPartialName("System.Drawing")

function screenshot([Drawing.Rectangle]$bounds, $path) {
   $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
   $graphics = [Drawing.Graphics]::FromImage($bmp)

   $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)

   $bmp.Save($path)

   $graphics.Dispose()
   $bmp.Dispose()
}

$perpetuum=1;

Do
{

 $HWND = [Win32Api]::GetForegroundWindow();

# print pid
$FWPid = [IntPtr]::Zero
 [Win32Api]::GetWindowThreadProcessId($HWND, [ref] $FWPid );
# "PID=" + $FWPid | write-host
# write-host $FWPid

$processes=[System.Diagnostics.Process]::GetProcessById($FWPid)
#If ($processes.ProcessName -eq "iexplore")
#If (($processes.ProcessName -eq "iexplore") -or ($processes.ProcessName -eq "firefox"))

$ProcessNames = "iexplore", "firefox", "chrome","opera"
If ($ProcessNames -contains $processes.ProcessName)
     {
 $o    = New-Object -TypeName System.Object
 $href = New-Object -TypeName System.RunTime.InteropServices.HandleRef -ArgumentList $o, $HWND
# write-host $href

$rct =  New-Object RECT

[Win32Api]::GetWindowRect($href, [ref]$rct)

#write-host $rct.Right
#write-host $rct.Left
#write-host $rct.Bottom
#write-host $rct.Top

$bounds = [Drawing.Rectangle]::FromLTRB($rct.Left, $rct.Top,$rct.Right, $rct.Bottom)
$script:SaveImageTime = Get-Date -f 'yyyy-MM-dd.HH.mm.ss'
screenshot $bounds ".\$script:SaveImageTime.png"
    }
Start-Sleep 5
}
Until ($perpetuum -eq 0)
