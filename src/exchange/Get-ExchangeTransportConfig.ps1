function Get-ExchangeTransportConfig
{
    <#

        .SYNOPSIS
            Discover Exchange transport configuration settings.

        .DESCRIPTION
            Calls a set of child scripts which find key transportation configuration settings in Exchange.

        .OUTPUTS
            Returns a custom object containing key send/receive connector settings from Exchange.

        .EXAMPLE
            Get-ExchangeTransportConfig

    #>

    [CmdletBinding()]
    param ()

    begin
    {
        Write-Log -Level "INFO" -Activity "Transport Configuration Discovery" -Message "Attempting Transport Configuration Discovery." -WriteProgress
        $transportSettings = @{}
    }
    process
    {
        [array]$receiveConnectors = Get-ExchangeReceiveConnectors
        [array]$sendConnectors = Get-ExchangeSendConnectors

        $transportSettings.Add("ReceiveConnectors", $receiveConnectors)
        $transportSettings.Add("SendConnectors", $sendConnectors)
        
        Write-Log -Level "INFO" -Activity "Transport Configuration Discovery" -Message "Completed Transport Configuration Discovery." -WriteProgress

        $transportSettings
    }
}
