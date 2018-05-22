function ConvertTo-AuthenticationMethodNames
{
    [CmdletBinding()]
    param (
        [int]
        $AuthenticationMethodsValue
    )

    $authenticationFlagMap = @{
        0  = "None"
        1  = "Basic"
        2 = "Ntlm"
        4 = "Fba"
        8 = "Digest"
        16 = "WindowsIntegrated"
        32 = "LiveIdFba"
        64 = "LiveIdBasic"
        128 = "WSSecurity"
        256 = "Certificate"
        512 = "NegoEx"
        1024 = "OAuth"
        2048 = "Adfs"
        4096 = "Kerberos"
        8192 = "Negotiate"
        16384 = "LiveIdNegotiate"
    }

    $authenticationFlagMap.Keys | Where-Object{$_ -bAnd $AuthenticationMethodsValue} | ForEach-Object{$authenticationFlagMap.Get_Item($_)}
}

function Get-ExchangeVirtualDirectories
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $discoveredVirtualDirectories = @()
    $ldapFilter = "(objectClass=msExchVirtualDirectory)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "CN=Configuration,$($DomainDN)"
    [array] $properties = "name", "distinguishedName", "msExchExternalHostName", "msExchInternalHostName", "msExchMetabasePath", "msExchExternalAuthenticationMethods", "msExchInternalAuthenticationMethods"
    $virtualDirectories = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($virtualDirectory in $virtualDirectories)
    {
        $computerName = ($virtualDirectory.distinguishedname[0]).Split(",")[3]
        $computerName = $computerName.Split("=")[1]

        $VirtualDirectorySettings = "" | Select-Object ComputerName, Name, ExternalHostName, InternalHostName, IISRootPath, ExternalAuthenticationMethods, InternalAuthenticationMethods
        $VirtualDirectorySettings.ComputerName = $computerName
        $VirtualDirectorySettings.Name = $virtualDirectory.name[0]        
        $VirtualDirectorySettings.IISRootPath = $virtualDirectory.msexchmetabasepath[0]
        $VirtualDirectorySettings.ExternalAuthenticationMethods = $externalAuthenticationMethods
        $VirtualDirectorySettings.InternalAuthenticationMethods = $internalAuthenticationMethods

        if(($virtualDirectory.msExchExternalAuthenticationMethods.count -gt 0) -and (-not [string]::IsNullOrEmpty($virtualDirectory.msExchExternalAuthenticationMethods[0])))
        {
            [int] $externalAuthenticationFlagValue = $virtualDirectory.msExchExternalAuthenticationMethods[0].ToString()
            [array] $externalAuthenticationMethods = ConvertTo-AuthenticationMethodNames $externalAuthenticationFlagValue
        }

        if(($virtualDirectory.msExchInternalAuthenticationMethods.count -gt 0) -and (-not [string]::IsNullOrEmpty($virtualDirectory.msExchInternalAuthenticationMethods[0])))
        {
            [int] $internalAuthenticationFlagValue = $virtualDirectory.msExchInternalAuthenticationMethods[0].ToString()
            [array] $internalAuthenticationMethods = ConvertTo-AuthenticationMethodNames $internalAuthenticationFlagValue
        }

        if(($virtualDirectory.msExchExternalHostName.count -gt 0) -and (-not [string]::IsNullOrEmpty($virtualDirectory.msExchExternalHostName[0])))
        {
            $VirtualDirectorySettings.ExternalHostName = $virtualDirectory.msExchExternalHostName[0]
        }

        if(($virtualDirectory.msExchInternalHostName.count -gt 0) -and (-not [string]::IsNullOrEmpty($virtualDirectory.msExchInternalHostName[0])))
        {
            $VirtualDirectorySettings.InternalHostName = $virtualDirectory.msExchInternalHostName[0]
        }

        $discoveredVirtualDirectories += $VirtualDirectorySettings
    }

    $discoveredVirtualDirectories
}