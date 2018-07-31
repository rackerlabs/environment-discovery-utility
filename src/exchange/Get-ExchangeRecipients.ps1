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
        Get-ExchangeRecipients -DomainDN $domainDN -ExchangeShellConnected $exchangeShellConnected
    #>

    [CmdletBinding()]
    param (
        [string]
        $DomainDN,

        [bool]
        $ExchangeShellConnected
    )

    $activity = "Recipients"
    $discoveredRecipients = @()
    $ldapFilter = "(&(msexchRecipientDisplayType=*)(mail=*))"
    $context = "LDAP://$DomainDN"
    [array]$properties = "msexchRecipientTypeDetails", "msexchRecipientDisplayType", "msExchRemoteRecipientType", "objectGuid", "mail", "userPrincipalName", "objectClass", "userAccountControl"
    Write-Log -Level "VERBOSE" -Activity $activity -Message "Gathering Exchange recipient details." -PercentComplete 0 -WriteProgress

    if (-not $ExchangeShellConnected)
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Skipping Exchange recipient data statistic gathering. No connection to Exchange."
    }

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Exchange Recipients." -WriteProgress
        $recipients = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $DomainDN
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for recipients. $($_.Exception.Message)"
        return
    }

    if ($recipients.Count -gt 0)
    {
        $progressFrequency = 25
        $x = 0

        foreach ($recipient in $recipients)
        {
            if ($x % $progressFrequency -eq 0)
            {
                $percentComplete = (100 / $recipients.Count) * $x
                Write-Log -Level "DEBUG" -Activity $activity -Message "Gathering Exchange recipient details $x / $($recipients.Count)" -PercentComplete $percentComplete -WriteProgress
            }

            $recipientStatistics = $null
            $currentRecipient = "" | Select-Object ObjectGuid, PrimarySmtpDomain, UserPrincipalNameSuffix, RecipientTypeDetails, RemoteRecipientType, RecipientDisplayType, PrimaryMatchesUPN, TotalItemSizeKB, ItemCount, UserAccountControl
            $currentRecipient.ObjectGuid = [GUID]($recipient.objectGuid | Select-Object -First 1)
            $currentRecipient.PrimarySmtpDomain = ($recipient.mail | Select-Object -First 1).Split("@")[1]
            $currentRecipient.RecipientTypeDetails = $recipient.msexchRecipientTypeDetails | Select-Object -First 1
            $currentRecipient.RemoteRecipientType = $recipient.msExchRemoteRecipientType | Select-Object -First 1
            $currentRecipient.RecipientDisplayType = $recipient.msexchRecipientDisplayType | Select-Object -First 1

            if ([array]$recipient.ObjectClass -contains "user")
            {
                $userPrincipalName = ($recipient.userPrincipalName | Select-Object -First 1)
                if (-not [String]::IsNullOrEmpty($userPrincipalName))
                {
                    if ($userPrincipalName.Contains("@"))
                    {
                        $currentRecipient.UserPrincipalNameSuffix = ($recipient.userPrincipalName | Select-Object -First 1).Split("@")[1]
                    }
                    else
                    {
                        Write-Warning "The User Principal Name attribute for $($currentRecipient.ObjectGuid). doesn't have a domain suffix."
                    }

                    $currentRecipient.PrimaryMatchesUPN = ($recipient.mail | Select-Object -First 1) -eq ($recipient.userPrincipalName | Select-Object -First 1)
                }

                $currentRecipient.UserAccountControl = $recipient.userAccountControl | Select-Object -First 1
            }

            if ($ExchangeShellConnected)
            {
                $recipientStatistics = Get-ExchangeRecipientDataStatistics -Recipient $currentRecipient

                if ($recipientStatistics)
                {
                    $currentRecipient.TotalItemSizeKB = $recipientStatistics.TotalItemSize.Value.ToKB()
                    $currentRecipient.ItemCount = $recipientStatistics.itemCount
                }
            }

            $x++

            $discoveredRecipients += $currentRecipient
        }

        Write-Log -Level "VERBOSE" -Activity $activity -Message "Completed Exchange recipient discovery." -ProgressComplete -WriteProgress
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "No recpients discovered."
    }

    $discoveredRecipients
}
