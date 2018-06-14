function Get-ExchangeTransportConfig
{
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


