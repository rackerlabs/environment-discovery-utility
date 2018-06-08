function Search-Directory
{
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
