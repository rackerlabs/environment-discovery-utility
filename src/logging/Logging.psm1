function Write-Log
{
    #TODO: Fix the below documentation
    <#
    .SYNOPSIS
        This cmdlet will write to log

    .DESCRIPTION
        This cmdlet will write to log

    .PARAMETER Modules
        This cmdlet will write to log

    .OUTPUTS
        This cmdlet will write to log

    .EXAMPLE
        This cmdlet will write to log

    .EXAMPLE
        This cmdlet will write to log
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('DEBUG','VERBOSE','ERROR','WARNING','INFO')]
        [array]
        $Level = 'DEBUG',

        [string]
        $Message,

        [string]
        $Activity,

        [int]
        $ProgressId,

        [int]
        $ParentProgressId,

        [switch]
        $ProgressComplete
    )

    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'
    $dateString = [DateTime]::UtcNow | Get-Date -Format o
    $logEntry = "$dateString,$Level,$Activity,$Message"
    $logEntry | Out-File -Append -Encoding utf8 -FilePath $Global:logFilePath

    <#
    switch ($Level)
    {
        'DEBUG' { Write-Debug $Message }
        'VERBOSE' { Write-Verbose $Message }
        'ERROR' { Write-Error $Message }
        default { Write-Verbose $Message }
    }
    #>
    if ($ProgressId)
    {
        Write-Progress -Id $ProgressId -Activity $Activity -Status $Message
        if ($ParentProgressId)
        {
            Write-Progress -Id $ProgressId -Activity $Activity -Status $Message -ParentId $ParentProgressId
        }
        else
        {
            Write-Progress -Id $ProgressId -Activity $Activity -Status $Message
        }
        if ($ProgressComplete)
        {
            Write-Progress -Id $ProgressId -Completed -Activity $Activity -Status $Message
        }
    }
}

function Enable-Logging
{
    [CmdletBinding()]
    param (
        [string]
        $LogFilePath
    )

    $Global:logFilePath = $LogFilePath
    $Global:logSubscriber = Enable-OutputSubscriber `
                            -OnWriteError {Write-Log -Level "ERROR" -Message $args[0]}`
                            -OnWriteWarning {Write-Log -Level "WARNING" -Message $args[0]}`
                            -OnWriteOutput {Write-Log -Level "INFO" -Message $args[0]}`
                            -OnWriteDebug {Write-Log -Level "DEBUG" -Message $args[0]}`
                            -OnWriteVerbose {Write-Log -Level "VERBOSE" -Message $args[0]}
    $logEntry = "DateTime,Level,Activity,Message"
    $logEntry | Out-File -Append -Encoding utf8 -FilePath $Global:logFilePath

    $logger
}

function Disable-Logging
{
    [CmdletBinding()]
    param ()

    $Global:logSubscriber | Disable-OutputSubscriber
}
