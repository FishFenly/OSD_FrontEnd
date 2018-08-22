function Get-EthIP {
    <#
    .SYNOPSIS
        Get ethernet ipv4 IP address
    #>
    try {
        $ip = Get-NetIPConfiguration | ? InterfaceAlias -Like "*Ethernet*" | 
            select -Expand IPv4Address | select -Expand IPaddress -First 1

        return "SUCCESS: IP Address is - " + $ip
    } catch {
        return "ERROR: A problem occured while getting IP address"
    }
}

function Get-EthStatus {
    <#
    .SYNOPSIS
        Get ethernet adapter status
    #>
    try {
        $netstate = gwmi Win32_NetworkAdapter | ? NetConnectionID -like "*Ethernet*" |
            select -expand NetConnectionStatus

        return $netstate
    } catch {
        return "ERROR: A problem occured while getting net adapter status"
    }
}

Export-ModuleMember -Function 'Get-EthIP', 'Get-EthStatus'