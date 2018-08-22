function Get-PowerState {
    <#
    .SYNOPSIS
        Get power status and make sure 
    #>
    try {
        $Battery = Get-WmiObject -Namespace "root\wmi" -class BatteryStatus | 
            ? voltage -ne 0 | select -expand PowerOnline

        return $Battery        
    } catch {
        return "fail"
    }
}

Export-ModuleMember -Function 'Get-PowerState'