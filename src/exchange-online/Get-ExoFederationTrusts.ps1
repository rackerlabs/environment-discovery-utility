function Get-ExoFederationTrusts
{
    <#

        .SYNOPSIS
            Discover Exchange Online federation trusts

        .DESCRIPTION
            Query Exchange Online for configured federation trusts

        .OUTPUTS
            Returns a custom object containing configured Exchange Online federation trusts

        .EXAMPLE
            Get-ExoFederationTrusts

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online Federation Trusts"
    $discoveredTrusts = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for configured federation trustss." -WriteProgress
        $federationTrusts = Get-FederationTrust
        $properties = $federationTrusts | Get-Member | Where-Object {$_.MemberType -like "Property" -and $_.Definition -like "System.*"} | Select-Object -ExpandProperty Name

        foreach ($federationTrust in $federationTrusts)
        {
            $trust = $federationTrust | Select-Object $properties
            $discoveredTrusts += $trust
        }
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query AzureAD for configured federation trusts. $($_.Exception.Message)"
        return
    }

    $discoveredTrusts
}
