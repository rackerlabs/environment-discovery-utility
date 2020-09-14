function Get-ExoOrganizationRelationships
{
    <#

        .SYNOPSIS
            Discover Exchange Online organization relationship

        .DESCRIPTION
            Query Exchange Online for configured organization relationship

        .OUTPUTS
            Returns a custom object containing configured Exchange Online organization relationship

        .EXAMPLE
            Get-ExoOrganizationRelationship

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online Organization Relationships"
    $discoveredRelationships = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for configured organization relationships." -WriteProgress
        $organizationRelationships = Get-OrganizationRelationship
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query AzureAD for configured organization relationships. $($_.Exception.Message)"
        return
    }

    if ($organizationRelationships)
    {
        $properties = $organizationRelationships | Get-Member | Where-Object {$_.MemberType -like "Property" -and $_.Definition -like "System.*"} | Select-Object -ExpandProperty Name
        $properties += @("DomainNames")

        foreach ($organizationRelationship in $organizationRelationships)
        {
            $relationship = $organizationRelationship | Select-Object $properties
            $relationship.DomainNames = [array]$organizationRelationship.DomainNames
            $discoveredRelationships += $relationship
        }
    }

    $discoveredRelationships
}
