function Get-ExchangeRecipients
{
    <#

        .SYNOPSIS
            Discover all recipients in Exchange that have the msexchRecipientDisplayType attribute set in Active Directory.

        .DESCRIPTION
            Runs LDAP queries against Active Directory to discover all Exchange recipients.  If an Exchange shell is detected it will extract additional recipient statistics.

        .OUTPUTS
            Returns a custom object containing recipient information.  Personally Identifiable Information (PII) is excluded.

        .EXAMPLE
            Get-ExchangeRecipients

    #>

    [CmdletBinding()]
    param ()

    $activity = "Recipients"
    $discoveredRecipients = @()
    Write-Log -Level "INFO" -Activity $activity -Message "Gathering Exchange recipient details." -PercentComplete 0 -WriteProgress

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Discovering Exchange Recipients.  Running Get-Recipient for all recipients, this can take a long time." -WriteProgress
        $recipients = Get-Recipient -ResultSize Unlimited -IgnoreDefaultScope
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to run Get-Recipient. $($_.Exception.Message)"
        return
    }

    if ($recipients.Count -gt 0)
    {
        $progressFrequency = 25
        $x = 0
        $retentionPolicies = Get-RetentionPolicy

        foreach ($recipient in $recipients)
        {
            if ($x % $progressFrequency -eq 0)
            {
                $percentComplete = (100 / $recipients.Count) * $x
                Write-Log -Level "VERBOSE" -Activity $activity -Message "Gathering Exchange recipient details $x / $($recipients.Count)" -PercentComplete $percentComplete -WriteProgress
            }

            $recipientStatistics = $null

            $currentRecipient = "" | Select-Object ObjectGuid, PrimarySmtpDomain, UserPrincipalNameSuffix, RecipientTypeDetails, RecipientDisplayType, PrimaryMatchesUPN, TotalItemSizeKB, ItemCount, ArchiveGuid, EmailAddressPolicyEnabled, LitigationHoldEnabled, Protocols, RetentionPolicy
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
                $currentUser = Get-User $recipient.distinguishedName
                $userPrincipalName = $currentUser.userPrincipalName

                if (-not [String]::IsNullOrEmpty($userPrincipalName))
                {
                    if ($userPrincipalName.Contains("@"))
                    {
                        $splitUserPrincipalName = $userPrincipalName.Split("@")
                        $domain = $splitUserPrincipalName[1]
                        $currentRecipient.UserPrincipalNameSuffix = $domain
                    }
                    else
                    {
                        Write-Warning "The User Principal Name attribute for $($currentRecipient.ObjectGuid). doesn't have a domain suffix."
                    }

                    $currentRecipient.PrimaryMatchesUPN = ($recipient.PrimarySmtpAddress.ToString()) -eq $userPrincipalName
                }

                try
                {
                    Write-Log -Level "VERBOSE" -Activity $activity -Message "Getting recipient connection protocols for object $($recipient.Guid)." -WriteProgress
                    $casMailbox = Get-CASMailbox $userPrincipalName
                }
                catch
                {
                    Write-Log -Level "WARNING" -Activity $activity -Message "Failed to run Get-CasMailbox against object $($recipient.Guid). $($_.Exception.Message)"
                }

                if ($casMailbox)
                {
                    $protocols = "" | select ActiveSyncEnabled, OwaEnabled, PopEnabled, ImapEnabled, MapiEnabled
                    $protocols.ActiveSyncEnabled = $casMailbox.ActiveSyncEnabled
                    $protocols.OwaEnabled = $casMailbox.OwaEnabled
                    $protocols.PopEnabled = $casMailbox.PopEnabled
                    $protocols.ImapEnabled = $casMailbox.ImapEnabled
                    $protocols.MapiEnabled = $casMailbox.MapiEnabled

                    $currentRecipient.Protocols = $protocols
                }
            }

            $recipientStatistics = Get-ExchangeRecipientDataStatistics -Recipient $currentRecipient

            if ($recipientStatistics)
            {
                $currentRecipient.TotalItemSizeKB = $recipientStatistics.TotalItemSize.Value.ToKB()
                $currentRecipient.ItemCount = $recipientStatistics.itemCount
            }
            else
            {
                Write-Log -Level "VERBOSE" -Activity $activity -Message "Unable to get recipient statistics for $($currentRecipient.ObjectGuid)." -PercentComplete $percentComplete -WriteProgress
            }

            $x++

            $discoveredRecipients += $currentRecipient
        }

        Write-Log -Level "INFO" -Activity $activity -Message "Completed Exchange recipient discovery." -ProgressComplete -WriteProgress
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "No recpients discovered."
    }

    $discoveredRecipients
}
