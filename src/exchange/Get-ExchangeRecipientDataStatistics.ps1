function Get-ExchangeRecipientDataStatistics
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
        [object]
        $Recipient
    )

    $mailboxTypeValues = @(1, 2, 4, 8, 16, 32)

    if ($mailboxTypeValues -contains $Recipient.RecipientTypeDetails)
    {
        $recipientStatistics = Get-MailboxStatistics $($Recipient.ObjectGuid.ToString()) -WarningAction SilentlyContinue
    }

    $recipientStatistics
}
