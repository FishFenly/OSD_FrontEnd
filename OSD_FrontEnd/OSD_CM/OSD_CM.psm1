function Get-CMConnectionStatus ($siteserver) {
    <#
    .SYNOPSIS
        Attempt connection to the site server
    #>
    try {
        Test-Connection $siteserver -ea stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Get-CMDeviceState ($cName) {
    <#
    .SYNOPSIS
        Detect if the device already exists in the Site DB
    #>

}

function Import-Device ($cName) {
    <#
    .SYNOPSIS
        Import the device
    #>
}

Export-ModuleMember -function 'Get-CMConnectionStatus','Get-CMDeviceState'