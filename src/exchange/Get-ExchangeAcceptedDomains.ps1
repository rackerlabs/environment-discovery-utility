function ConvertTo-AcceptedDomainFlagNames
{
    [CmdletBinding()]
    param (
        [int]
        $AcceptedDomainFlags
    )
    process
    {
        $flagMap = @{
            1  = "ExternalRelay"
            2  = "InternalRelay"
            4 = "Default"
            8 = "Authoritative"
        }

        $flagMap.Keys | Where-Object{$_ -bAnd $AcceptedDomainFlags} | ForEach-Object{$flagMap.Get_Item($_)}
    }
}

function Get-ExchangeAcceptedDomains
{
    param (
        [string]
        $DomainDN
    )

    $discoveredAcceptedDomains = @()
    $searchRoot = "CN=Configuration,$($DomainDN)"
    $ldapFilter = "(objectClass=msExchAcceptedDomain)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    [array] $properties = "name", "msExchAcceptedDomainFlags"
    $acceptedDomains = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($acceptedDomain in $acceptedDomains)
    {
        $currentAcceptedDomain = "" | Select-Object Name,IsDefault,AcceptedDomainType
        [int] $acceptedDomainFlagValue = $acceptedDomain.msExchAcceptedDomainFlags[0].ToString()
        [array] $acceptedDomainFlags = ConvertTo-AcceptedDomainFlagNames $acceptedDomainFlagValue
        $typeName = $acceptedDomainFlags | Where-Object {$_ -notlike 'Default'}

        if (-not $typeName)
        {
            $typeName = "Authoritative"
        }

        $currentAcceptedDomain.Name = $acceptedDomain.name
        $currentAcceptedDomain.AcceptedDomainType = $typeName

        if ($acceptedDomainFlags -contains 'Default')
        {
            $currentAcceptedDomain.IsDefault = $true
        }
        else
        {
            $currentAcceptedDomain.IsDefault = $false
        }

        $discoveredAcceptedDomains += $currentAcceptedDomain
    }

    $discoveredAcceptedDomains
}