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

    [CmdletBinding()]
    param (
        # An array of strings indicating which modules the Environment Discovery Utility should run.  Possible values: AD, Exchange, All.  This defaults to 'All'
        [ValidateSet("ad","exchange","all")] 
        [String] 
        $modules
    )
    process
    {
        $activeDirectoryObject = Start-ActiveDirectoryDiscovery | SerializeTo-Json

        $activeDirectoryObject
    }
}