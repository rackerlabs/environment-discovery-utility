function Write-Log
{
    [CmdletBinding()]
    param (
        [ValidateSet('DEBUG','VERBOSE','ERROR','WARNING','INFO')]
        [array]
        $Level = 'DEBUG',

        [string]
        $Message,

        [string]
        $Activity,

        [switch]
        $WriteProgress,

        [int]
        $ProgressId,

        [int]
        $PercentComplete,

        [switch]
        $ProgressComplete
    )

    $utcDate = [DateTime]::UtcNow | Get-Date -Format o
    $Message = $Message.Trim().Replace("`"","\`"")
    $logEntry = "" | Select Date, Level, Activity, Message
    $logEntry.Date = $utcDate
    $logEntry.Level = $Level
    $logEntry.Activity = $Activity
    $logEntry.Message = $Message
    "$utcDate,$Level,$Activity,`"$Message`"" | Out-File -Append -Encoding utf8 -FilePath $Global:logFilePath -n
    $Global:logEntries += $logEntry
    if ($WriteProgress)
    {
        $progressArgs = @{}
        $progressArgs.Add('Status',$Message)
        $progressArgs.Add('Activity',$Activity)
        if ($ProgressId) { $progressArgs.Add('Id',$progressId) }
        if ($ProgressComplete) { $progressArgs.Add('Completed',$null) }
        if ($PercentComplete) { $progressArgs.Add('PercentComplete',$PercentComplete) }

        Write-Progress @progressArgs
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
    $Global:logEntries = @()
    $Global:logSubscriber = Enable-OutputSubscriber `
                            -OnWriteError {Write-Log -Level "ERROR" -Message $args[0]}`
                            -OnWriteWarning {Write-Log -Level "WARNING" -Message $args[0]}`
                            -OnWriteOutput {Write-Log -Level "INFO" -Message $args[0]}`
                            -OnWriteDebug {Write-Log -Level "DEBUG" -Message $args[0]}`
                            -OnWriteVerbose {Write-Log -Level "VERBOSE" -Message $args[0]}
    $logEntry = "DateTime,Level,Activity,Message"
    $logEntry | Out-File -Append -Encoding utf8 -FilePath $Global:logFilePath
}

function Disable-Logging
{
    [CmdletBinding()]
    param ()

    $Global:logSubscriber | Disable-OutputSubscriber
}

function Get-LogEntries
{
    $Global:logEntries
}
