function Get-ExoRecipients
{
    <#

        .SYNOPSIS
            Discover all recipients in Exchange Online.

        .DESCRIPTION
            Discover all recipients and recipient statistics in Exchange Online.

        .OUTPUTS
            Returns a custom object containing recipient information.  Personally Identifiable Information (PII) is excluded.

        .EXAMPLE
            Get-ExchangeOnlineRecipients

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online Recipients"
    $discoveredRecipients = @()
    Write-Log -Level "INFO" -Activity $activity -Message "Gathering Exchange Online recipient details." -PercentComplete 0 -WriteProgress
    $mailboxTypeValues = @("UserMailbox", "LinkedMailbox", "SharedMailbox", "LegacyMailbox", "RoomMailbox", "EquipmentMailbox")
   
    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Discovering Exchange Online Recipients.  Running Get-Recipient for all recipients, this can take a long time." -WriteProgress
        Get-ExchangeOnlineSession | Out-Null
        $recipients = Get-ExoRecipient -ResultSize unlimited -Properties "Guid", "PrimarySmtpAddress", "RecipientTypeDetails","RecipientType", "ArchiveGuid", "EmailAddressPolicyEnabled", "LitigationHoldEnabled", "ObjectClass"
        Write-Log -Level "INFO" -Activity $activity -Message "Discovering Exchange Online Recipient Statistics.  Running Get-ExoMailboxStatistics for all recipients, this can take a long time." -WriteProgress
        $recipientStats = $recipients | Where-Object {$_.RecipientTypeDetails -in $mailboxTypeValues} `
            | Get-EXOMailboxStatistics -Properties OwnerADGuid -ErrorAction SilentlyContinue
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to run Get-Recipient. $($_.Exception.Message)"
        return
    }
    $x = 0
    $progressFrequency = 100

    foreach ($recipient in $recipients)
    {
        $x++
        if ($x % $progressFrequency -eq 0)
        {
            $percentComplete = (100 / $recipients.Count) * $x
            Write-Log -Level "INFO" -Activity $activity -Message "Gathering Exchange Online recipient details $x / $($recipients.Count)" -PercentComplete $percentComplete -WriteProgress
        }

        $recipientStatistics = $null

        $currentRecipient = "" | Select-Object ObjectGuid, PrimarySmtpDomain, RecipientTypeDetails, RecipientDisplayType, TotalItemSizeKB, ItemCount, ArchiveGuid, EmailAddressPolicyEnabled, LitigationHoldEnabled, Protocols, RetentionPolicy
        $currentRecipient.ObjectGuid = [GUID]($recipient.guid)
        $currentRecipient.RecipientTypeDetails = $recipient.RecipientTypeDetails.ToString()
        $currentRecipient.RecipientDisplayType = $recipient.RecipientType.ToString()
        $currentRecipient.EmailAddressPolicyEnabled = $recipient.EmailAddressPolicyEnabled
        $currentRecipient.LitigationHoldEnabled = $recipient.LitigationHoldEnabled
        $currentRecipient.ArchiveGuid = $recipient.ArchiveGuid

        if ($recipient.RetentionPolicy -notlike $null)
        {
            $retentionPolicy = $retentionPolicies | Where-Object {$_.Name -eq $recipient.RetentionPolicy}

            if ($retentionPolicy -notlike $null)
            {
                $retentionPolicyGuid = $retentionPolicy.Guid
                $currentRecipient.RetentionPolicy = $retentionPolicyGuid.ToString()
            }
            else
            {
                Write-Warning "Recipient $($currentRecipient.ObjectGuid) has a retention policy but it couldn't be matched to an existing policy.  This could be a permissions issue."
            }
        }

        $recipientMail = $recipient.PrimarySmtpAddress.ToString()

        if ($recipientMail.Contains("@"))
        {
            $smtpParts = $currentRecipient.PrimarySmtpDomain = $recipientMail.Split("@")

            if ($smtpParts.Count -gt 0)
            {
                $currentRecipient.PrimarySmtpDomain = $recipientMail.Split("@")[1]
            }
            else
            {
                Write-Log -Level "WARNING" -Activity $activity -Message "Recipient $($currentRecipient.ObjectGuid) doesn't have a valid primary SMTP address, no @ symbol found." -PercentComplete $percentComplete -WriteProgress
                $currentRecipient.PrimarySmtpDomain = $null
            }
        }

        if ([array]$recipient.ObjectClass -contains "user")
        {
            $mailboxTypeValues = @("UserMailbox", "LinkedMailbox", "SharedMailbox", "LegacyMailbox", "RoomMailbox", "EquipmentMailbox")

            if ($mailboxTypeValues -contains $currentRecipient.RecipientTypeDetails)
            {
                try
                {
                    Write-Log -Level "VERBOSE" -Activity $activity -Message "Getting recipient connection protocols for object $($recipient.Guid)." -WriteProgress
                    $casMailbox = Get-ExoCASMailbox $recipient.Guid.ToString() -ErrorAction stop
                }
                catch
                {
                    Write-Log -Level "WARNING" -Activity $activity -Message "Failed to run Get-CasMailbox against object $($recipient.Guid). $($_.Exception.Message)"
                }

                if ($null -notlike $casMailbox)
                {
                    $protocols = "" | Select-Object ActiveSyncEnabled, OwaEnabled, PopEnabled, ImapEnabled, MapiEnabled
                    $protocols.ActiveSyncEnabled = $casMailbox.ActiveSyncEnabled
                    $protocols.OwaEnabled = $casMailbox.OwaEnabled
                    $protocols.PopEnabled = $casMailbox.PopEnabled
                    $protocols.ImapEnabled = $casMailbox.ImapEnabled
                    $protocols.MapiEnabled = $casMailbox.MapiEnabled

                    $currentRecipient.Protocols = $protocols
                }
                else
                {
                    Write-Log -Level "WARNING" -Activity $activity -Message "Get-CasMailbox result null for $($recipient.Guid)."
                }
            }
        }

        $recipientStatistics = $recipientStats | Where-Object {$_.OwnerADGuid -like $currentRecipient.ObjectGuid}

        if ($recipientStatistics -notlike $null)
        {
            $currentRecipient.TotalItemSizeKB = ($recipientStatistics.TotalItemSize -replace "(.*\()|,| [a-z]*\)", "") / 1024
            $currentRecipient.ItemCount = $recipientStatistics.itemCount
        }
        else
        {
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Unable to get recipient statistics for $($currentRecipient.ObjectGuid)." -PercentComplete $percentComplete -WriteProgress
        }

        $discoveredRecipients += $currentRecipient       
    }

    Write-Log -Level "INFO" -Activity $activity -Message "Completed Exchange recipient discovery." -ProgressComplete -WriteProgress

    $discoveredRecipients
}
