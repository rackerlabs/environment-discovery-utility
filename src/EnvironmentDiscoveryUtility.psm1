#region Functions

function Get-LibraryManifest
{
    $libraryManifestPath = "$(split-path $SCRIPT:MyInvocation.MyCommand.Path -parent)\library-manifest.json"

    if (-not $( Test-Path $libraryManifestPath ))
    {
        Throw "Failed to find library manifest at $libraryManifestPath"
    }

    [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | Out-Null
    
    $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $rawLibraryManifest = Get-Content $libraryManifestPath
    
    try
    {
        $libraryManifest = $serializer.DeserializeObject($rawLibraryManifest)
    }
    catch
    {
        throw "Failed to deserialize library manifest file. $error"
    }

    $libraryManifest
}

function Start-EnvironmentDiscovery
{
    $forestDetails = Get-ADForestDetails
    if ($forestDetails)
    {
        SerializeTo-Json $forestDetails
    }
}

#endregion

#region Initialize Module

$manifest = Get-LibraryManifest

foreach ($library in $manifest.libraries)
{
    $libraryPath = "$(split-path $SCRIPT:MyInvocation.MyCommand.Path -parent)$($library.path)"
    . "$($libraryPath)" > $null
}

#endregion

