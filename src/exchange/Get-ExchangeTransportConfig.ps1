function Get-ExchangeTransportConfig
{
    <#
    .SYNOPSIS
        Discover Exchange transport configuration settings.

    .DESCRIPTION
        Calls a set of child scripts which find key transportation configuration settings in Exchange.

    .OUTPUTS
        Returns a custom object containing key send/recieve connector settings from Exchange.

    .EXAMPLE
        Get-ExchangeTransportConfig -DomainDN $domainDN
    #>

    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    begin
    {
        Write-Log -Level "VERBOSE" -Activity "Transport Configuration Discovery" -Message "Attempting Transport Configuration Discovery." -WriteProgress
        $transportSettings = @{}
    }

    process
    {
        $transportSettings.Add("RecieveConnectors", $(Get-ExchangeReceiveConnectors -DomainDN $DomainDN))
        $transportSettings.Add("SendConnectors", $(Get-ExchangeSendConnectors -DomainDN $DomainDN))
        Write-Log -Level "VERBOSE" -Activity "Transport Configuration Discovery" -Message "Completed Transport Configuration Discovery." -WriteProgress

        $transportSettings
    }
}
