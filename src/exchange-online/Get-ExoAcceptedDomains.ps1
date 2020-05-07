function Get-ExoAcceptedDomains
{
    <#

        .SYNOPSIS
            Discover Exchange Online accepted domains

        .DESCRIPTION
            Query Exchange Online for configured accepted domains

        .OUTPUTS
            Returns a custom object containing configured Exchange Online accepted domains

        .EXAMPLE
            Get-ExchangeOnlineAcceptedDomains

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online Accepted Domains"
    $discoveredAcceptedDomains = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for configured accepted domains." -WriteProgress
        [array]$acceptedDomains = Get-AcceptedDomain
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange Online for configured applications. $($_.Exception.Message)"
        return
    }

    if ($acceptedDomains.Count -gt 0)
    {
        foreach ($acceptedDomain in $acceptedDomains)
        {
            $acceptedDomainObject = "" | Select-Object Name, DomainName, DomainType, IsDefault, MatchSubDomains, AddressBookEnabled, EmailOnly,
                ExternallyManaged, AuthenticationType, LiveIdInstanceType, PendingRemoval, PendingCompletion, FederatedOrganizationLink, MailFlowPartner,
                OutboundOnly, PendingFederatedAccountNamespace, PendingFederatedDomain, IsCoexistenceDomain, PerimeterDuplicateDetected, IsDefaultFederatedDomain,
                EnableNego2Authentication, InitialDomain, AdminDisplayName, ExchangeVersion, DistinguishedName, Identity, WhenChangedUTC, WhenCreatedUTC,
                OrganizationId, Id, Guid

            $acceptedDomainObject.Name = [string]$acceptedDomain.ObjectId
            $acceptedDomainObject.DomainNAme = [string]$acceptedDomain.DisplayName
            $acceptedDomainObject.DomainType = [string]$acceptedDomain.DomainType
            $acceptedDomainObject.IsDefault = [bool]$acceptedDomain.Default
            $acceptedDomainObject.MatchSubDomains = [bool]$acceptedDomain.MatchSubDomains
            $acceptedDomainObject.AddressBookEnabled = [bool]$acceptedDomain.AddressBookEnabled
            $acceptedDomainObject.EmailOnly = [bool]$acceptedDomain.EmailOnly
            $acceptedDomainObject.ExternallyManaged = [bool]$acceptedDomain.ExternallyManaged
            $acceptedDomainObject.AuthenticationType = [string]$acceptedDomain.AuthenticationType
            $acceptedDomainObject.LiveIdInstanceType = [string]$acceptedDomain.LiveIdInstanceType
            $acceptedDomainObject.PendingRemoval = [bool]$acceptedDomain.PendingRemoval
            $acceptedDomainObject.PendingCompletion = [bool]$acceptedDomain.PendingCompletion
            $acceptedDomainObject.FederatedOrganizationLink = [string]$acceptedDomain.FederatedOrganizationLink
            $acceptedDomainObject.MailFlowPartner = [string]$acceptedDomain.MailFlowPartner
            $acceptedDomainObject.OutboundOnly = [bool]$acceptedDomain.OutboundOnly
            $acceptedDomainObject.PendingFederatedAccountNamespace = [bool]$acceptedDomain.PendingFederatedAccountNamespace
            $acceptedDomainObject.PendingFederatedDomain = [bool]$acceptedDomain.PendingFederatedDomain
            $acceptedDomainObject.IsCoexistenceDomain = [bool]$acceptedDomain.IsCoexistenceDomain
            $acceptedDomainObject.PerimeterDuplicateDetected = [bool]$acceptedDomain.PerimeterDuplicateDetected
            $acceptedDomainObject.IsDefaultFederatedDomain = [bool]$acceptedDomain.IsDefaultFederatedDomain
            $acceptedDomainObject.EnableNego2Authentication = [bool]$acceptedDomain.EnableNego2Authentication
            $acceptedDomainObject.InitialDomain = [bool]$acceptedDomain.InitialDomain
            $acceptedDomainObject.AdminDisplayName = [string]$acceptedDomain.AdminDisplayName
            $acceptedDomainObject.ExchangeVersion = [string]$acceptedDomain.ExchangeVersion
            $acceptedDomainObject.DistinguishedName = [string]$acceptedDomain.DistinguishedName
            $acceptedDomainObject.Identity = [string]$acceptedDomain.Identity
            $acceptedDomainObject.WhenChangedUTC = [DateTime]$acceptedDomain.WhenChangedUTC
            $acceptedDomainObject.WhenCreatedUTC = [DateTime]$acceptedDomain.WhenCreatedUTC
            $acceptedDomainObject.OrganizationId = [string]$acceptedDomain.OrganizationId
            $acceptedDomainObject.Id = [string]$acceptedDomain.Id
            $acceptedDomainObject.Guid = [string]$acceptedDomain.Guid

            $discoveredAcceptedDomains += $acceptedDomainObject
        }
    }

    $discoveredAcceptedDomains
}
