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