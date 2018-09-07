function Get-ExchangeEmailAddressPolicies
{
    <#

        .SYNOPSIS
            Discover Exchange Email Address Policies.

        .DESCRIPTION
            Uses native Exchange cmdlets to discover Email Address Policies.

        .OUTPUTS
            Returns a custom object containing Email Address Policies.

        .EXAMPLE
            Get-ExchangeEmailAddressPolicies

    #>

    [CmdletBinding()]
    param ()

    $activity = "Email Address Policies"
    $discoveredEmailAddressPolicies = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Gathering Exchange Email Address Policies." -WriteProgress
        $emailAddressPolicies = Get-EmailAddressPolicy
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to run Get-EmailAddressPolicy. $($_.Exception.Message)"
        return
    }

    foreach ($emailAddressPolicy in $emailAddressPolicies)
    {
        $currentEmailAddressPolicy = "" | Select-Object Guid, Name, Priority, RecipientFilterApplied, RecipientFilterType, HasConditionalCustomAttribute
        $conditionalCustomAttributes = (($emailAddressPolicy | Select-Object ConditionalCustomAttribute*).PSObject.Properties | Select-Object Value)
        $hasConditionalCustomAttributes = $false
        
        foreach ($attribute in $conditionalCustomAttributes)
        {
            if ($attribute.Value -ne $null)
            {
                $hasConditionalCustomAttributes = $true
            }
        }

        $currentEmailAddressPolicy.Guid = [guid]$emailAddressPolicy.Guid
        $currentEmailAddressPolicy.Name = $emailAddressPolicy.Name
        $currentEmailAddressPolicy.Priority = $emailAddressPolicy.Priority
        $currentEmailAddressPolicy.RecipientFilterApplied = [bool]$emailAddressPolicy.RecipientFilterApplied
        $currentEmailAddressPolicy.RecipientFilterType = $emailAddressPolicy.RecipientFilterType
        $currentEmailAddressPolicy.HasConditionalCustomAttribute = [bool]$hasConditionalCustomAttributes

        $discoveredEmailAddressPolicies += $currentEmailAddressPolicy
    }

    $discoveredEmailAddressPolicies
}
