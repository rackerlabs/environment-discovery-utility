function Search-Directory
{
    <#
    
    .SYNOPSIS
        Query active directory through LDAP.

    .DESCRIPTION
        Creates LDAP queries using provided parameters dynamically.

    .PARAMETER Context
        Specifies active directory partition to search in.

    .PARAMETER Filter
        Specifies LDAP filter used to target objects.

    .PARAMETER Properties
        Specifies properties that need to be returned.

    .PARAMETER SearchRoot
        Specifies partition search root.
    
    .OUTPUTS
        Returns all properties provided to the calling script.

    .EXAMPLE
        Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    
    #>


    [CmdletBinding()]
    param(
        [string]
        $Context,

        [string]
        $Filter,

        [int]
        $PageSize = 1000,

        [string[]]
        $Properties,

        [string]
        $SearchRoot,

        [string]
        $SearchScope = "SubTree"
    )
    process
    {
        $output = @()

        if ($Context)
        {
            $nameSpace = New-Object System.DirectoryServices.DirectoryEntry $Context
        }
        else
        {
            $nameSpace = New-Object System.DirectoryServices.DirectoryEntry
        }

        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
        $objsearcher.SearchRoot = $nameSpace

        if ($PageSize)
        {
            $objSearcher.PageSize = $PageSize
        }

        if ($Filter)
        {
            $objSearcher.Filter = $Filter
        }

        $objSearcher.SearchScope = "Subtree"

        foreach ($property in $properties)
        {
            $objSearcher.PropertiesToLoad.Add($property) | Out-Null
        }

        $results = $objSearcher.FindAll()

        foreach ($result in $results)
        {
            $object = New-Object -TypeName PSObject

            foreach ($adProperty in $result.Properties.PropertyNames)
            {
                $object | Add-Member -MemberType NoteProperty -Name $adProperty -Value $result.Properties[$adProperty]
            }

            $output += $object
        }

        $output
    }
}
