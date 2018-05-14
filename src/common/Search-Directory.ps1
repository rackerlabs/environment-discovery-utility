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

if ($Context)
{
	$root = New-Object System.DirectoryServices.DirectoryEntry $Context
}
else
{
	$root = New-Object System.DirectoryServices.DirectoryEntry
}

$directorySearcher = New-Object System.DirectoryServices.DirectorySearcher

if ($SearchRoot)
{
	$directorySearcher.SearchRoot = $SearchRoot
}

if ($PageSize)
{
	$directorySearcher.PageSize = $PageSize
}

if ($Filter)
{
	$directorySearcher.Filter = $Filter
}

$directorySearcher.SearchScope = $SearchScope

foreach ($property in $Properties)
{
	$directorySearcher.PropertiesToLoad.Add($property) | Out-Null
}

$directorySearcher.FindAll()
