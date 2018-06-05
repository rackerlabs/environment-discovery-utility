function Get-ExchangeRecipientDataStatistics
{
    [CmdletBinding()]
    param (
        [object]
        $Recipient
    )

    $mailboxTypeValues = @(1, 2, 4, 8, 16, 32)

    if ($mailboxTypeValues -contains $Recipient.RecipientTypeDetails)
    {
        $recipientStatistics = Get-MailboxStatistics $( $Recipient.ObjectGuid.ToString()) -WarningAction SilentlyContinue
    }

    $recipientStatistics
}