function Escape-Json 
{
	<#  
		.SYNOPSIS
			Handle special characters in JSON.

		.DESCRIPTION
			Escape special characters in JSON (see json.org), such as newlines, backslashes
			carriage returns and tabs.
			
			Derived from regex: '\\(?!["/bfnrt]|u[0-9a-f]{4})'
	#>

	[CmdletBinding()]
    [OutputType([string])]
    param(
        [string] 
		$JsonString
	)

    $JsonString -replace '\\', '\\' -replace '\n', '\n' `
        -replace '\u0008', '\b' -replace '\u000C', '\f' -replace '\r', '\r' `
        -replace '\t', '\t' -replace '"', '\"'
}

function Get-NumberOrString 
{
	<#  
		.SYNOPSIS
			Close JSON string correctly.

		.DESCRIPTION
			Meant to be used as the "end value". Adding coercion of strings that match numerical formats
			supported by JSON as an optional, non-default feature (could actually be useful and save a lot of
			calculated properties with casts before passing..).	If it's a number (or the parameter 
			-CoerceNumberStrings is passed and it can be "coerced" into one), it'll be returned as 
			a string containing the number.  If it's not a number, it'll be surrounded by double quotes 
			as is the JSON requirement.
	#>

	[CmdletBinding()]
    param(
        $InputObject # Specifically not typed
	)

    if ($InputObject -is [System.Byte] -or $InputObject -is [System.Int32] -or `
        ($env:PROCESSOR_ARCHITECTURE -imatch '^(?:amd64|ia64)$' -and $InputObject -is [System.Int64]) -or `
        $InputObject -is [System.Decimal] -or $InputObject -is [System.Double] -or `
        $InputObject -is [System.Single] -or $InputObject -is [long] -or `
        ($Script:CoerceNumberStrings -and $InputObject -match $Script:NumberRegex)) 
	{
        Write-Verbose -Message "Got a number as end value."

        "$InputObject"
    }
    else 
	{
        Write-Verbose -Message "Got a string as end value."

        """$(Escape-Json -JsonString $InputObject)"""
    }
}

function ConvertTo-JsonInternal {
    param(
        $InputObject, # Specifically not typed

        [int32]
		$WhiteSpacePad = 0
	)
    
	[string]$Json = ""
    
	$keys = @()
    
	Write-Verbose -Message "WhiteSpacePad: $WhiteSpacePad."

    if ($null -eq $InputObject) 
	{
        Write-Verbose -Message "Got 'null' in `$InputObject in inner function"

        $null
    }
    elseif ($InputObject -is [bool] -and $InputObject -eq $true) 
	{
        Write-Verbose -Message "Got 'true' in `$InputObject in inner function"

        $true
    }
    elseif ($InputObject -is [bool] -and $InputObject -eq $false) 
	{
        Write-Verbose -Message "Got 'false' in `$InputObject in inner function"

        $false
    }
    elseif ($InputObject -is [hashtable]) 
	{
        $keys = @($InputObject.Keys)

        Write-Verbose -Message "Input object is a hash table (keys: $($keys -join ', '))."
    }
    elseif ($InputObject.GetType().FullName -eq "System.Management.Automation.PSCustomObject") 
	{
        $keys = @(Get-Member -InputObject $InputObject -MemberType NoteProperty | Select-Object -ExpandProperty Name)

        Write-Verbose -Message "Input object is a custom PowerShell object (properties: $($keys -join ', '))."
    }
    elseif ($InputObject.GetType().Name -match '\[\]|Array') 
	{
        Write-Verbose -Message "Input object appears to be of a collection/array type."
        Write-Verbose -Message "Building JSON for array input object."

        $json += "[`n" + (($InputObject | ForEach-Object {
            if ($null -eq $_) 
			{
                Write-Verbose -Message "Got null inside array."

                " " * ((4 * ($WhiteSpacePad / 4)) + 4) + "null"
            }
            elseif ($_ -is [bool] -and $_ -eq $true) 
			{
                Write-Verbose -Message "Got 'true' inside array."

                " " * ((4 * ($WhiteSpacePad / 4)) + 4) + "true"
            }
            elseif ($_ -is [bool] -and $_ -eq $false) 
			{
                Write-Verbose -Message "Got 'false' inside array."

                " " * ((4 * ($WhiteSpacePad / 4)) + 4) + "false"
            }
            elseif ($_ -is [hashtable] -or $_.GetType().FullName -eq "System.Management.Automation.PSCustomObject" -or $_.GetType().Name -match '\[\]|Array') 
			{
                Write-Verbose -Message "Found array, hash table or custom PowerShell object inside array."

                " " * ((4 * ($WhiteSpacePad / 4)) + 4) + (ConvertToJsonInternal -InputObject $_ -WhiteSpacePad ($WhiteSpacePad + 4)) -replace '\s*,\s*$' #-replace '\ {4}]', ']'
            }
            else 
			{
                Write-Verbose -Message "Got a number or string inside array."

                $TempJsonString = Get-NumberOrString -InputObject $_

                " " * ((4 * ($WhiteSpacePad / 4)) + 4) + $TempJsonString
            }
        }) -join ",`n") + "`n$(" " * (4 * ($WhiteSpacePad / 4)))],`n"
    }
    else {
        Write-Verbose -Message "Input object is a single element (treated as string/number)."

        Get-NumberOrString -InputObject $InputObject
    }
    if ($keys.Count) {
        Write-Verbose -Message "Building JSON for hash table or custom PowerShell object."

        $json += "{`n"

        foreach ($key in $keys) 
		{
            if ($null -eq $InputObject.$Key) 
			{
                Write-Verbose -Message "Got null as `$InputObject.`$Key in inner hash or PS object."

                $json += " " * ((4 * ($WhiteSpacePad / 4)) + 4) + """$key"": null,`n"
            }
            elseif ($InputObject.$Key -is [bool] -and $InputObject.$Key -eq $true) 
			{
                Write-Verbose -Message "Got 'true' in `$InputObject.`$Key in inner hash or PS object."

                $json += " " * ((4 * ($WhiteSpacePad / 4)) + 4) + """$Key"": true,`n"            
			}
            elseif ($InputObject.$Key -is [bool] -and $InputObject.$Key -eq $false) 
			{
                Write-Verbose -Message "Got 'false' in `$InputObject.`$Key in inner hash or PS object."

                $json += " " * ((4 * ($WhiteSpacePad / 4)) + 4) + """$key"": false,`n"
            }
            elseif ($InputObject.$Key -is [hashtable] -or $InputObject.$Key.GetType().FullName -eq "System.Management.Automation.PSCustomObject") 
			{
                Write-Verbose -Message "Input object's value for key '$key' is a hash table or custom PowerShell object."

                $json += " " * ($WhiteSpacePad + 4) + """$key"":`n$(" " * ($WhiteSpacePad + 4))"
                $json += ConvertToJsonInternal -InputObject $InputObject.$Key -WhiteSpacePad ($WhiteSpacePad + 4)
            }
            elseif ($InputObject.$Key.GetType().Name -match '\[\]|Array') {
                Write-Verbose -Message "Input object's value for key '$key' has a type that appears to be a collection/array."
                Write-Verbose -Message "Building JSON for ${Key}'s array value."

                $json += " " * ($WhiteSpacePad + 4) + """$key"":`n$(" " * ((4 * ($WhiteSpacePad / 4)) + 4))[`n" + (($InputObject.$Key | ForEach-Object {
                    if ($null -eq $_) 
					{
                        Write-Verbose -Message "Got null inside array inside inside array."

                        " " * ((4 * ($WhiteSpacePad / 4)) + 8) + "null"
                    }
                    elseif ($_ -is [bool] -and $_ -eq $true) 
					{
                        Write-Verbose -Message "Got 'true' inside array inside inside array."

                        " " * ((4 * ($WhiteSpacePad / 4)) + 8) + "true"
                    }
                    elseif ($_ -is [bool] -and $_ -eq $false) 
					{
                        Write-Verbose -Message "Got 'false' inside array inside inside array."

                        " " * ((4 * ($WhiteSpacePad / 4)) + 8) + "false"
                    }
                    elseif ($_ -is [hashtable] -or $_.GetType().FullName -eq "System.Management.Automation.PSCustomObject" -or $_.GetType().Name -match '\[\]|Array') 
					{
                        Write-Verbose -Message "Found array, hash table or custom PowerShell object inside inside array."

                        " " * ((4 * ($WhiteSpacePad / 4)) + 8) + (ConvertToJsonInternal -InputObject $_ -WhiteSpacePad ($WhiteSpacePad + 8)) -replace '\s*,\s*$'
                    }
                    else 
					{
                        Write-Verbose -Message "Got a string or number inside inside array."

                        $TempJsonString = Get-NumberOrString -InputObject $_

                        " " * ((4 * ($WhiteSpacePad / 4)) + 8) + $TempJsonString
                    }
                }) -join ",`n") + "`n$(" " * (4 * ($WhiteSpacePad / 4) + 4 ))],`n"
            }
            else {
                Write-Verbose -Message "Got a string inside inside hashtable or PSObject."

                $escapedJsonString = Get-NumberOrString -InputObject $InputObject.$Key

                $json += " " * ((4 * ($WhiteSpacePad / 4)) + 4) + """$key"": $escapedJsonString,`n"
            }
        }

        $json = $json -replace '\s*,$' # remove trailing comma that'll break syntax
        $json += "`n" + " " * $WhiteSpacePad + "},`n"
    }

    $json
}

function SerializeTo-Json {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $InputObject,

        [switch]
		$Compress,

        [switch] 
		$CoerceNumberStrings = $false
	)

    begin
	{
        $JsonOutput = ""
        $Collection = @()
        [bool]$Script:CoerceNumberStrings = $CoerceNumberStrings
        [string]$Script:NumberRegex = '^-?\d+(?:(?:\.\d+)?(?:e[+\-]?\d+)?)?$'
    }
    process 
	{
        if ($_) 
		{
            Write-Verbose -Message "Adding object to `$Collection. Type of object: $($_.GetType().FullName)."

            $Collection += $_
        }
    }
    end 
	{
        if ($Collection.Count) 
		{
            Write-Verbose -Message "Collection count: $($Collection.Count), type of first object: $($Collection[0].GetType().FullName)."

            $JsonOutput = ConvertToJsonInternal -InputObject ($Collection | ForEach-Object { $_ })
        }
        else 
		{
            $JsonOutput = ConvertToJsonInternal -InputObject $InputObject
        }

        if ($null -eq $JsonOutput) 
		{
            Write-Verbose -Message "Returning `$null."

            return $null # becomes an empty string :/
        }
        elseif ($JsonOutput -is [Bool] -and $JsonOutput -eq $true) 
		{
            Write-Verbose -Message "Returning `$true."

            [bool] $true # doesn't preserve bool type :/ but works for comparisons against $true
        }
        elseif ($JsonOutput-is [bool] -and $JsonOutput -eq $false) 
		{
            Write-Verbose -Message "Returning `$false."

            [bool] $false # doesn't preserve bool type :/ but works for comparisons against $false
        }
        elseif ($Compress) 
		{
            Write-Verbose -Message "Compress specified."

            (($JsonOutput -split "\n" | Where-Object { $_ -match '\S' }) -join "`n" -replace '^\s*|\s*,\s*$' -replace '\ *\]\ *$', ']') -replace (
                '(?m)^\s*("(?:\\"|[^"])+"): ((?:"(?:\\"|[^"])+")|(?:null|true|false|(?:' + $Script:NumberRegex.Trim('^$') + ')))\s*(?<Comma>,)?\s*$'), `
				"`${1}:`${2}`${Comma}`n" -replace '(?m)^\s*|\s*\z|[\r\n]+'
        }
        else 
		{
            ($JsonOutput -split "\n" | Where-Object { $_ -match '\S' }) -join "`n" -replace '^\s*|\s*,\s*$' -replace '\ *\]\ *$', ']'
        }
    }
}
