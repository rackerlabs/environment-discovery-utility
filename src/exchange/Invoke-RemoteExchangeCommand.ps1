function Invoke-RemoteExchangeCommand
{
    <#

        .SYNOPSIS
            Executes a remote Exchange command on a specified server.  Will fall back to executing in the local session if it fails.

        .DESCRIPTION
            Create a new PSSession to the specified Exchange server and executes a remote Exchange command.  The function can fall back to executing in the local session on failure if specified.

        .OUTPUTS
            Returns the object returned by the Exchange command.

        .EXAMPLE
            Invoke-RemoteExchangeCommand -Command "Get-WebServicesVirtualDirectory -Server CAS01" -Session $session -EnableFallback

        .EXAMPLE
            Invoke-RemoteExchangeCommand -Command "Get-MailboxDatabaseCopyStatus -Server MBX01" -Session $session -EnableFallback

    #>

    [CmdletBinding()]
    param (
        # Command A string containing the command to be executed.  Variables are not allowed.
        [string]
        $Command,

        # Session The PSSession to execute the command against
        [System.Management.Automation.Runspaces.PSSession]
        $Session,

        # EnableFallback Enable Fallback to local session.
        [switch]
        $EnableFallback
    )

    $scriptBlock = [ScriptBlock]::Create($Command)

    try
    {
        $result = Invoke-RemoteCommand
    }
    catch
    {
        Write-Verbose "Failed to execute rmote Exchange command: $command, on server $server."
    }

    if ($result -like $null)
    {
        Write-Verbose "Remote command returned and result is not null."
        Invoke-LocalCommand
    }
    else
    {
        $result
    }
}

function Invoke-LocalCommand
{
    try
    {
        $result = & $scriptBlock

        $result
    }
    catch
    {
        Write-Error "Failed to execute command in local session. Command: $($scriptBlock.ToString()) $($_.Exception)"
    }
}

function Invoke-RemoteCommand
{
    try
    {
        $result = Invoke-Command -Session $Session -ScriptBlock $scriptBlock -ErrorAction Stop
        $result
    }
    catch
    {
        Write-Warning "Failed to execute command in remote session.  Falling back to local session which is slower.  Command: $($scriptBlock.ToString()) `n$($_.Exception)"
    }
}

