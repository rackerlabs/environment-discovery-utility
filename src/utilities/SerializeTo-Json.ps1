param(
	[psobject]$PSObject, 
	[string[]]$Properties = @(),
	[bool]$ForceMatch = $false,
	[string]$JsonDotNet = "$PSScriptRoot\..\..\ext\json.net\Newtonsoft.Json.dll"
)

Function Convert-Type($sourceType)
{   
    if ($sourceType -eq "System.Boolean" -or ($sourceType -match "System.Nullable" -and $sourceType -match "System.Boolean"))
    {
        $type = "bool?"
    }
    elseif ($sourceType -eq "System.Byte[]")
    {
        $type = "byte[]"
    }
    elseif ($sourceType -eq "System.DateTime" -or ($sourceType -match "System.Nullable" -and $sourceType -match "System.DateTime"))
    {
        $type = "DateTime?"
    }
    elseif ($sourceType -eq "System.Int32" -or ($sourceType -match "System.Nullable" -and $sourceType -match "System.Int32"))
    {
        $type = "int?"
    }
    elseif ($sourceType -eq "System.String")
    {
        $type = "string"
    }
    elseif ([string]::IsNullOrEmpty($sourceType) -eq $true)
    {
        $type = "string"
    }
    elseif ($forceMatch)
	{
		$type = $sourceType
	}
	else
	{
		$type = "string"
	}

    $type
}

[Reflection.Assembly]::LoadFile($JsonDotNet)

$jsonSerializerSettings = New-Object Newtonsoft.Json.JsonSerializerSettings
$jsonSerializerSettings.ReferenceLoopHandling = "Ignore"

[Newtonsoft.Json.JsonConvert]::SerializeObject($PSObject, [Newtonsoft.Json.Formatting]::Indented, $settings)

#$PSObject.Properties | ForEach-Object {
#	if ($Properties.Count -gt 0)
#	{
#		if ($Properties -notcontains $_.Name)
#		{
#			continue
#		}
#	}

#    $type = Convert-Type $_.TypeNameOfValue
    
#	$poco = $poco + "public $type $($_.Name) { get; set; }`r`n"
#}