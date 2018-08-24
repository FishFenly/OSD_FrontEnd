function Get-TPMStatus {
    <#
    .SYNOPSIS
        Get the status of the TPM module
    #>
    try{
        $tpmstate = gwmi win32_tpm -EnableAllPrivileges -Namespace "root\CIMV2\Security\MicrosoftTpm" | 
            select @{n='PC';e={$_.PSComputerName}},
                   @{n='Activated';e={$_.IsActivated_InitialValue}},
                   @{n='Enabled';e={$_.IsEnabled_InitialValue}},
                   @{n='Owned';e={$_.IsOwned_InitialValue}}
	    return $tpmstate
    } catch { 
	    return "fail"
    }
}

function Get-DeviceType {
    <#
    .SYNOPSIS
        Get the device type - Desktop or Laptop
    #>
    $ctype = gwmi win32_systemenclosure | select -expand ChassisTypes
    return $ctype
}

Export-ModuleMember -Function 'Get-TPMStatus','Get-DeviceType'