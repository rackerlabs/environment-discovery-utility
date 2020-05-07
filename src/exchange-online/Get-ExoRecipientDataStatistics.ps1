function Get-ExoRecipientDataStatistics
{
    <#

        .SYNOPSIS
            Load mailbox statistics for a mailbox.

        .DESCRIPTION
            Analyzes the mailbox type and conditionally loads mailbox statistics if appropriate.

        .OUTPUTS
            Returns a custom object containing mailbox statistics for a mailbox.

        .EXAMPLE
            Get-ExchangeRecipientDataStatistics -Recipient $currentRecipient

    #>

    [CmdletBinding()]
    param (
        # Recipient The recipient to execute Get-MailboxStatistics against
        [object]
        $Recipient
    )

    $mailboxTypeValues = @("UserMailbox", "LinkedMailbox", "SharedMailbox", "LegacyMailbox", "RoomMailbox", "EquipmentMailbox")

    if ($mailboxTypeValues -contains $Recipient.RecipientTypeDetails)
    {
        $recipientStatistics = $null
        $recipientStatistics = $Script:ExoRecipientStats | Where-Object {$_.Guid -eq $Recipient.Guid}
    }

    $recipientStatistics
}
