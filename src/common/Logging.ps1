function Write-Log
{
    [CmdletBinding()]
    param (
        [ValidateSet('DEBUG','VERBOSE','ERROR')]
        [array]
        $Level = 'DEBUG',

        [string]
        $Message,

        [string]
        $Activity,

        [int]
        $ProgressId,

        [int]
        $ParentProgressId,

        [switch]
        $ProgressComplete
    )

	$VerbosePreference = 'Continue' 
	$DebugPreference = 'Continue' 

    switch ($Level) {
        'DEBUG' { Write-Debug $Message }
        'VERBOSE' { Write-Verbose $Message }
        'ERROR' { Write-Error $Message }
        default { Write-Verbose $Message }
    }

	if ($ProgressId)
    {
		Write-Progress -Id $ProgressId -Activity $Activity -Status $Message
        if ($ParentProgressId)
        {
            #Write-Progress -Id $ProgressId -Activity $Activity -Status $Message -ParentId $ParentProgressId
        }
		else
		{
			#Write-Progress -Id $ProgressId -Activity $Activity -Status $Message
		}
        if ($ProgressComplete)
        {
            Write-Progress -Id $ProgressId -Completed -Activity $Activity -Status $Message
        }
    }
}

function Enable-Logging
{
    [CmdletBinding()]
    param (
        [string]
        $FilePath
    )

    $Global:logFile = Enable-LogFile -Path $FilePath
	$VerbosePreference = 'Continue' 
	$DebugPreference = 'Continue' 
}

function Disable-Logging
{
    [CmdletBinding()]
    param (
        [object]
        $LogFile
    )

    $LogFile | Disable-LogFile
}