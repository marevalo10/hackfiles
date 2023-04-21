# '----------------------------------------------------------------------------------------
# '  Check computer description
# '  Author:    Miguel Arevalo
# '  Date:      15/09/2022
# '  Version:   1.0
# '  
# '  Comments:  Extractr computer description for the current logged on user in Active Directory for Windows 10.
# '  Note:      1.0  -  Based on a client script
# '                     Update Format:    <SiteCode> | <UserName> | <Date> | <ChassisType> | <OSVersion>
# '----------------------------------------------------------------------------------------




$mainFunction = {

function UpdateDescription(){
	Param($description)

	$url = "http://melmp0455.internal.bupa.com.au:8080/OSDKioskService/Service1.asmx"
	$Proxy = New-WebserviceProxy $url –Namespace X
	$Proxy.UpdateComputerDescription($description)

}

function Get-ComputerVirtualStatus {
    [cmdletBinding(SupportsShouldProcess = $true)] 
    param( 
        [parameter(Position=0, ValueFromPipeline=$true, HelpMessage="Computer or IP address of machine to test")] 
        [string[]]$ComputerName = $env:COMPUTERNAME, 
        [parameter(HelpMessage="Pass an alternate credential")] 
        [System.Management.Automation.PSCredential]$Credential = $null 
    ) 
    begin {
        $WMISplat = @{} 
        if ($Credential -ne $null) { 
            $WMISplat.Credential = $Credential 
        } 
        $results = @()
        $computernames = @()
    } 
    process { 
        $computernames += $ComputerName 
    } 
    end {
        foreach($computer in $computernames) { 
            $WMISplat.ComputerName = $computer 
            try { 
                $wmibios = Get-WmiObject Win32_BIOS @WMISplat -ErrorAction Stop | Select-Object version,serialnumber 
                $wmisystem = Get-WmiObject Win32_ComputerSystem @WMISplat -ErrorAction Stop | Select-Object model,manufacturer
                $ResultProps = @{
                    ComputerName = $computer 
                    BIOSVersion = $wmibios.Version 
                    SerialNumber = $wmibios.serialnumber 
                    Manufacturer = $wmisystem.manufacturer 
                    Model = $wmisystem.model 
                    IsVirtual = $false 
                    VirtualType = $null 
                }
                if ($wmibios.SerialNumber -like "*VMware*") {
                    $ResultProps.IsVirtual = $true
                    $ResultProps.VirtualType = "Virtual - VMWare"
                }
                else {
                    switch -wildcard ($wmibios.Version) {
                        'VIRTUAL' { 
                            $ResultProps.IsVirtual = $true 
                            $ResultProps.VirtualType = "Virtual - Hyper-V" 
                        } 
                        'A M I' {
                            $ResultProps.IsVirtual = $true 
                            $ResultProps.VirtualType = "Virtual - Virtual PC" 
                        } 
                        '*Xen*' { 
                            $ResultProps.IsVirtual = $true 
                            $ResultProps.VirtualType = "Virtual - Xen" 
                        }
                    }
                }
                if (-not $ResultProps.IsVirtual) {
                    if ($wmisystem.manufacturer -like "*Microsoft*") 
                    { 
                        $ResultProps.IsVirtual = $true 
                        $ResultProps.VirtualType = "Virtual - Hyper-V" 
                    } 
                    elseif ($wmisystem.manufacturer -like "*VMWare*") 
                    { 
                        $ResultProps.IsVirtual = $true 
                        $ResultProps.VirtualType = "Virtual - VMWare" 
                    } 
                    elseif ($wmisystem.model -like "*Virtual*") { 
                        $ResultProps.IsVirtual = $true
                        $ResultProps.VirtualType = "Unknown Virtual Machine"
                    }
		    elseif ($wmisystem.model -like "*AHV*") { 
                        $ResultProps.IsVirtual = $true
                        $ResultProps.VirtualType = "Nutanix AHV"
                    }
                }
                $results += New-Object PsObject -Property $ResultProps
            }
            catch {
                Write-Warning "Cannot connect to $computer"
            } 
        } 
        return $results 
    } 
}

function Get-Chassis {  
	$laptopTypes = @("8", "9", "10", "11", "12", "14", "18", "21", "30", "31", "32", "33")
	$desktopTypes = @("3", "4", "5", "6", "7", "15", "16")
	$serverTypes = @("23")
	$chassis = Get-WmiObject win32_systemenclosure | select chassistypes
	$isLaptop = (@($laptopTypes| where {$chassis.chassistypes -contains $_ }).Count) -ne 0
	$isDesktop = (@($desktopTypes| where {$chassis.chassistypes -contains $_}).Count) -ne 0
	$isServer = (@($serverTypes| where {$chassis.chassistypes -contains $_}).Count) -ne 0
	if ( $isLaptop ) { return "Laptop" } 
	elseif ($isDesktop) { return "Desktop" } 
	elseif ($isServer) { return "Server" } 
	else { return "Uknown" }
}



function Get-OSVersion {
$signature = @"
 [DllImport("kernel32.dll")]
 public static extern uint GetVersion();
"@
    try {
    	Add-Type -MemberDefinition $signature -Name "Win32OSVersion" -Namespace Win32Functions -PassThru
    } catch {
    }
}

if ( -not ((Get-OSVersion)::GetVersion() -like '10*') ) { 
    "Not Windoows 10"
   # exit 1 
}

$ADSiteCode = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Net.NetworkInformation;

public static class NetApi32 {
    private class unmanaged {
        [DllImport("NetApi32.dll", CharSet=CharSet.Auto, SetLastError=true)]
        internal static extern UInt32 DsGetSiteName([MarshalAs(UnmanagedType.LPTStr)]string ComputerName, out IntPtr SiteNameBuffer);

        [DllImport("Netapi32.dll", SetLastError=true)]
        internal static extern int NetApiBufferFree(IntPtr Buffer);
    }

    public static string DsGetSiteName(string ComputerName) {
	try {
            IntPtr siteNameBuffer = IntPtr.Zero;
            UInt32 hResult = unmanaged.DsGetSiteName(ComputerName, out siteNameBuffer);
            string siteName = Marshal.PtrToStringAuto(siteNameBuffer);
            unmanaged.NetApiBufferFree(siteNameBuffer);
            if(hResult == 0x6ba) { throw new Exception("ComputerName not found"); }
            return siteName;
	} catch  {
		return null;
	}
    }
    public static bool IsNetworkAvailable() {
	long minimumSpeed = 0;
        if (!NetworkInterface.GetIsNetworkAvailable())
            return false;

        foreach (NetworkInterface ni in NetworkInterface.GetAllNetworkInterfaces())
        {
            // discard because of standard reasons
            if ((ni.OperationalStatus != OperationalStatus.Up) ||
                (ni.NetworkInterfaceType == NetworkInterfaceType.Loopback) ||
                (ni.NetworkInterfaceType == NetworkInterfaceType.Tunnel))
                continue;

            // this allow to filter modems, serial, etc.
            // I use 10000000 as a minimum speed for most cases
            if (ni.Speed < minimumSpeed)
                continue;

            // discard virtual cards (virtual box, virtual pc, etc.)
            if ((ni.Description.IndexOf("virtual", StringComparison.OrdinalIgnoreCase) >= 0) ||
                (ni.Name.IndexOf("virtual", StringComparison.OrdinalIgnoreCase) >= 0))
                continue;

            // discard "Microsoft Loopback Adapter", it will not show as NetworkInterfaceType.Loopback but as Ethernet Card.
            if (ni.Description.Equals("Microsoft Loopback Adapter", StringComparison.OrdinalIgnoreCase))
                continue;

            return true;
        }
        return false;
    }
}
"@
try {
	Add-Type -TypeDefinition $ADSiteCode
} catch {
	"Type already added. $($_.Message)" 
}

# HKEY_CURRENT_USER\Software\Citrix\Receiver

$hostDetails = Get-ComputerVirtualStatus
$isVirtual = $false
if ( $hostDetails.IsVirtual ) {
    $isVirtual = $true
    $chassisType = $hostDetails.VirtualType
    if ( $hostDetails.VirtualType -eq "Nutanix AHV" ){
        $registryPath = "HKCU:\Software\Citrix\Receiver"
        if ( Test-Path ($registryPath)) {
            New-ItemProperty -Path $registryPath -Name HideAddAccountOnRestart -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }
}

$networkAvailable = [NetApi32]::IsNetworkAvailable()
if ( $networkAvailable ) {
	$adSiteName = [NetApi32]::DsGetSiteName("$($env::Computername)")
	if ( -not $adSiteName ) {
		"Unable to determine site code.  Default to Melbourne"
		$adSiteName = "Melbourne"
	}
	$logonName = $($env:USERNAME)
	$time = [DateTime]::Now.ToString("dd/MM/yyyy hh:mm:ss tt")
	
    if ( -not $isVirtual ) {
        $chassisType = Get-Chassis
    }
	$os = [System.BitConverter]::GetBytes((Get-OSVersion)::GetVersion())
	$build = [byte]$os[2],[byte]$os[3]
	$buildNumber = [System.BitConverter]::ToInt16($build,0)
	$majorVersion = $os[0]
	$minorVersion = $os[1]
    try {

        $resleaseKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId -ErrorAction SilentlyContinue)
        if ( $resleaseKey ) {
	        $release = $resleaseKey.ReleaseId
        }
    } catch {
        $release = "Unknown"
    }
	$osVersion = "Windows {1} Version {0} (OS Build {3})" -F $release,$majorVersion,$minorVersion,$buildNumber
	$user = Get-WMIObject -class Win32_ComputerSystem | select username
    if ( -not $logonName ) {
	    if ( $user -and ($user.username -ne $logonName )) {
		    $logonName = $user.username
	    }
    }
	$description = "{0} | {1} | {2} | {3} | {4}" -F $adSiteName, $logonName, $time, $chassisType, $osVersion
	try {

		UpdateDescription -description $description
	        "Updating description to $description"
		"Update complete"
	}
	catch {
		"Failed to update details. $($_.ToString())"
	}
} else {
	"No Network Available"
}
}

# Create a job

Start-Job -ScriptBlock $mainFunction 