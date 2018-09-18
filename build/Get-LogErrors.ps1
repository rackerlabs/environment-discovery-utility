function Get-LogErrors
{
    <#

        .SYNOPSIS
            Check if there are errors in EDU log output.

        .DESCRIPTION
            Check if there are errors in EDU log output.

        .PARAMETER LabIpAddress
            IP address the logs are located at.
        
        .PARAMETER LogFile
            Log location.
        
        .OUTPUTS
            Returns the number of errors found in the log file.

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LabIpAddress,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogFile
    )
    
    $errors = 0

    $logs = Import-Csv $LogFile
    
    foreach ($log in $logs)
    {
        if ($log.Level -eq "ERROR")
        {
            $errors++
        }
    }

    $errors
}