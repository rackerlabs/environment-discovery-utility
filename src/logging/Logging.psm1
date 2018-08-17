function Write-Log
{
    <#

        .SYNOPSIS
            This function writes to the configured log file, as well as PowerShell progress bars.

        .DESCRIPTION
            This function writes to the configured log file, as well as PowerShell progress bars. Messages can be written to log file only, or to progress as well based on the parameters.

        .OUTPUTS
            None

        .EXAMPLE
            Write a warning message without writing progress bar
            Write-Log -Level 'WARNING' -Activity $activity -Message 'Failed to do something that is not critical but we would want to know about.'

        .EXAMPLE
            Write a verbose message with progress
            Write-Log -Level 'VERBOSE' -Activity $activity -Message 'Gathering Public Folder statistics. This may take some time without feedback.' -WriteProgress

        .EXAMPLE
            Write a verbose message with progress and completion percentage 
            Write-Log -Level 'DEBUG' -Activity $activity -Message "Gathering Exchange recipient details $x / $($recipients.Count)" -PercentComplete $percentComplete -WriteProgress

    #>

    [CmdletBinding()]
    param (
        # Level A string representation of Logging Level. Can be one of DEBUG, VERBOSE, ERROR, WARNING, INFO.
        [ValidateSet("DEBUG","VERBOSE","ERROR","WARNING","INFO")]
        [string]
        $Level = "VERBOSE",

        # Message The string to log. This will be used as the status if writing to Progress as well.
        [string]
        $Message,

        # Activity The activity being performed when the entry was logged
        [string]
        $Activity,

        # WriteProgress Toggles writing to Write-Progress. Omit this if you want to write to log file only.
        [switch]
        $WriteProgress,

        # ProgressId Allows the caller to hard-code the progressId in the case that we want to show multiple progress bars on screen.
        [int]
        $ProgressId,

        # PercentComplete Allows passing the PercentComplete parameter to Write-Progress.
        [int]
        $PercentComplete,

        # PercentComplete Allows for setting a progress bar as complete to remove it from the screen.
        [switch]
        $ProgressComplete
    )

    if (-not [string]::IsNullOrEmpty($Message) -and $Message.Trim().Length -ge 1)
    {
        $utcDate = [DateTime]::UtcNow | Get-Date -Format o
        $Message = $Message.Trim().Replace("`"","\`"")
        $logEntry = "" | Select Date, Level, Activity, Message
        $logEntry.Date = $utcDate
        $logEntry.Level = $Level
        $logEntry.Activity = $Activity
        $logEntry.Message = $Message
        $writeEntry = $true

        if ($Level -like "DEBUG")
        {
            if ($Global:DebugPreference -like 'SilentlyContinue')
            {
                $writeEntry = $false
            }
        }

        if ($Level -like 'VERBOSE')
        {
            if ($Global:VerbosePreference -like 'SilentlyContinue')
            {
                $writeEntry = $false
            }
        }

        if ($writeEntry -eq $true)
        {
            Export-LogEntry $logEntry
            $Global:logEntries += $logEntry
            if ($WriteProgress)
            {
                $progressArgs = @{
                    Status = $Message
                    Activity = $Activity
                }

                if ($ProgressId)
                {
                    $progressArgs.Add("Id",$progressId)
                }

                if ($ProgressComplete)
                {
                    $progressArgs.Add("Completed",$null)
                }

                if ($PercentComplete)
                {
                    $progressArgs.Add("PercentComplete",$PercentComplete)
                }

                Write-Progress @progressArgs
            }
        }
    }
}

function Enable-Logging
{
    <#

        .SYNOPSIS
            This function enables logging using the PowerShellLogging module to intercept streams and write to log files.

        .DESCRIPTION
            This function enables logging. Output subscribers will be created for the Error, Warning, Output, Debug and Verbose streams. Intercepted streams will be sent to the Write-Log function.

        .EXAMPLE
            Enable-Logging -LogFilePath somefile.log

    #>

    [CmdletBinding()]
    param (
        # LogFilePath The path for the log file.
        [string]
        $LogFilePath
    )

    if (Test-Path $LogFilePath)
    {
        Remove-Item $LogFilePath -Force
    }

    $Global:logFilePath = $LogFilePath
    $Global:logEntries = @()
    $Global:debugPreference = $DebugPreference
    $Global:verbosePreference = $VerbosePreference

    $subscriberActions = @{
        OnWriteError = {Write-Log -Level "ERROR" -Message $args[0] -Activity "StreamInterception"}
        OnWriteWarning = {Write-Log -Level "WARNING" -Message $args[0] -Activity "StreamInterception"}
        OnWriteOutput = {Write-Log -Level "INFO" -Message $args[0] -Activity "StreamInterception"}
        OnWriteDebug = {Write-Log -Level "DEBUG" -Message $args[0] -Activity "StreamInterception"}
        OnWriteVerbose = {Write-Log -Level "VERBOSE" -Message $args[0] -Activity "StreamInterception"}
    }

    $Global:logSubscriber = Enable-OutputSubscriber @subscriberActions

    $logEntry = "DateTime,Level,Activity,Message"
    $logEntry | Out-File -Append -Encoding utf8 -FilePath $Global:logFilePath
}

function Disable-Logging
{
    <#
        .SYNOPSIS
            This function disables logging.

        .DESCRIPTION
            This function disables logging.

        .EXAMPLE
            Disable-Logging
    #>

    [CmdletBinding()]
    param ()

    $Global:logSubscriber | Disable-OutputSubscriber
    Remove-Variable -Scope Global logFilePath
    Remove-Variable -Scope Global logEntries
    Remove-Variable -Scope Global debugPreference
    Remove-Variable -Scope Global verbosePreference
    Remove-Variable -Scope Global logSubscriber
}

function Export-LogEntry
{
    <#
        .SYNOPSIS
            This function saves a log entry to the log file on disk.

        .DESCRIPTION
            This function saves a log entry to the log file on disk.

        .EXAMPLE
            Export-LogEntry
    #>

    [CmdletBinding()]
    param (
        [object]
        $LogEntry
    )

    "$($logEntry.Date),$($logEntry.Level),$($Activity),`"$($logEntry.Message)`"" | Out-File -Append -Encoding utf8 -FilePath $Global:logFilePath -NoClobber
}

function Get-LogEntries
{
    <#
        .SYNOPSIS
            This function returns all log entries for the current session.

        .DESCRIPTION
            This function returns all log entries for the current session.

        .EXAMPLE
            Get-LogEntries
    #>

    [CmdletBinding()]
    param ()

    $Global:logEntries
}
