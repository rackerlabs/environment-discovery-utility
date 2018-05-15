#region Functions

function GetLibraryManifest
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

function ConverRelativePathToLiteralPath
{
    Param (
        [String]
        $RelativePath
    )

    $literalPath = "$(split-path $SCRIPT:MyInvocation.MyCommand.Path -parent)$( $RelativePath )"
    $literalPath
}

function Start-EnvironmentDiscovery
{
        <#
    .SYNOPSIS
        This cmdlet will start a run of the Environment Discovery Utility.  

    .DESCRIPTION
        This cmdlet will start a run of the Environment Discovery Utility.  This utility gathers important information regarding Microsoft products for the purpose of evaluating customer environments to aid in the scoping of projects.

    .PARAMETER Modules
        An array of strings indicating which modules the Environment Discovery Utility should run.  This defaults to 'All'

    .OUTPUTS
        A JSON representation of the discovered environment.

    .EXAMPLE
        Start-EnvironmentDiscovery -Modules All

    .EXAMPLE
        Start-EnvironmentDiscovery -Modules Exchange,AD

    #>

    Param (
        # An array of strings indicating which modules the Environment Discovery Utility should run.  Possible values: AD, Exchange, All.  This defaults to 'All'
        [ValidateSet("ad","exchange","all")] 
        [String] 
        $Modules 
    )
    
    BEGIN
    {
        $manifest = GetLibraryManifest
    
        foreach ($script in $manifest.scripts)
        {
            $path = ConverRelativePathToLiteralPath -RelativePath $script.path
            . "$($path)" > $null
        }

        if($Modules -like 'All')
        {
            $Modules = $manifest.libaries.ShortName
        }
        
        foreach($module in $modules)
        {
            if($Modules -contains $module.ToLower())
            {
                foreach ($library in $manifest.libraries)
                {
                    $libraryPath = ConverRelativePathToLiteralPath -RelativePath $library.path
                    $scriptFiles = Get-ChildItem -Path $libraryPath *.ps1
                    
                    foreach ($path in $scriptFiles.FullName)
                    {
                        . "$($path)" > $null
                    }
                }
            }
        }
    }
    PROCESS
    {
        $forestDetails = Get-ADForestDetails | SerializeTo-Json
    }
    END
    {
        $forestDetails
    }
}

#endregion