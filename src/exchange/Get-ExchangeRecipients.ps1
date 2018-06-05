function Get-ExchangeRecipients
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN,

        [bool]
        $IncludeStatistics
    )

    $discoveredRecipients = @()
    $ldapFilter = "(&(msExchRecipientTypeDetails=*)(mail=*))"
    $context = "LDAP://$($DomainDN)"
    $searchRoot = "$($DomainDN)"
    [array] $properties = "msexchRecipientTypeDetails", "msexchRecipientDisplayType", "msExchRemoteRecipientType", "objectGuid", "mail", "userPrincipalName"
    $recipients = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($recipient in $recipients)
    {
        $recipientStatistics = $null
        $currentRecipient = "" | Select-Object ObjectGuid, PrimarySmtpDomain, UserPrincipalNameSuffix, RecipientTypeDetails, RemoteRecipientType, RecipientDisplayType, PrimaryMatchesUPN, TotalItemSizeKB, ItemCount
        $currentRecipient.ObjectGuid = [GUID]  $( $recipient.objectGuid | Select-Object -First 1 )
        $currentRecipient.PrimarySmtpDomain = $( $recipient.mail | Select-Object -First 1 ).Split('@')[1]
        $currentRecipient.RecipientTypeDetails = $recipient.msexchRecipientTypeDetails | Select-Object -First 1
        $currentRecipient.RemoteRecipientType = $recipient.msExchRemoteRecipientType | Select-Object -First 1
        $currentRecipient.RecipientDisplayType = $recipient.msexchRecipientDisplayType | Select-Object -First 1
        
		if ([array]$recipient.ObjectClass -contains "user")
		{
			$currentRecipient.UserPrincipalNameSuffix = $( $recipient.userPrincipalName | Select-Object -First 1 ).Split('@')[1]
			$currentRecipient.PrimaryMatchesUPN = $( $recipient.mail | Select-Object -First 1 ) -eq $( $recipient.userPrincipalName | Select-Object -First 1 )
		}

        if ($IncludeStatistics)
        {
            $recipientStatistics = Get-ExchangeRecipientDataStatistics -Recipient $currentRecipient
            
            if ($recipientStatistics)
            {
                $currentRecipient.TotalItemSizeKB = $recipientStatistics.TotalItemSize.Value.ToKB()
                $currentRecipient.ItemCount = $recipientStatistics.itemCount
            }
        }

        $discoveredRecipients += $currentRecipient
    }

    $discoveredRecipients
}