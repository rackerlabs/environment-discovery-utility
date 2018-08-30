function Get-ExchangeDatabaseJournaling
{
    <#

        .SYNOPSIS
            Discover Exchange database journaling settings.

        .DESCRIPTION
            Query Exchange database journaling settings.

        .OUTPUTS
            Returns a custom object containing Exchange database journaling settings.

        .EXAMPLE
            Get-ExchangeDatabaseJournaling

    #>

    [CmdletBinding()]
    param (
        [array]
        $acceptedDomains
    )

    $activity = "Database Journaling"
    $discoveredDatabaseJournaling = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Database Journaling." -WriteProgress
        $databases = Get-MailboxDatabase -Status
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Exchange for Database Journaling. $($_.Exception.Message)"
        return
    }

    if ($databases)
    {
        foreach ($database in $databases)
        {
            $journalRecipientValue = $database.JournalRecipient

            if ($journalRecipientValue)
            {
                $acceptedDomain = $null
                $journalingTarget = Get-Recipient $journalRecipientValue
                $journalingTargetSMTP = $journalingTarget.PrimarySmtpAddress.ToString() 
                $journalRecipientDomain = $journalingTargetSMTP.Split("@")[1]

                $acceptedDomain = $acceptedDomains | where {$_.domain -like $journalRecipientDomain}

                if($acceptedDomain)
                {
                    $isLocalAddress = $true
                }
                else
                {
                    $isLocalAddress = $false
                }

                $databaseJournaling = $null
                $databaseJournaling = "" | Select-Object ObjectGuid, TargetGuid, TargetObjectClass, IsLocalAddress
                $databaseJournaling.ObjectGuid = $database.GUID
                $databaseJournaling.TargetGuid = $journalingTarget.GUID
                $databaseJournaling.TargetObjectClass = $journalingTarget.RecipientTypeDetails
                $databaseJournaling.IsLocalAddress = $isLocalAddress

                $discoveredDatabaseJournaling += $DatabaseJournaling
            }
        }
    }

    $discoveredDatabaseJournaling
}
