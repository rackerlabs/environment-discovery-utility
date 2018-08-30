function Convert-ExchangeDataStatisticToKB
{
    <#

        .SYNOPSIS
            This script abstracts an inconsistency with the Exchange PowerShell modules.

        .DESCRIPTION
            This script abstracts an inconsistency with the Exchange PowerShell modules.  Some Exchange data statistics require cmdlets require .Value to use .ToKB() depending on Exchange version.

        .OUTPUTS
            [int?]
            An integer value representing the total item size in KB.

        .EXAMPLE
            Convert-ExchangeDataStatisticToKB -Statistic $object.TotalItemSize

    #>

    [CmdletBinding()]
    param (
        # The Exchange statistic property, for instance TotalItemSize
        [object]
        $Property
    )

    $propertyType = $Property.GetType()
    $propertyMembers = $Property | get-member
    $kbValue = $null

    if ($propertyMembers | Where-Object {$_.Name -like 'Value'})
    {
        $valueType = $Property.Value.GetType()

        if ($valueType -eq [Microsoft.Exchange.Data.ByteQuantifiedSize])
        {
            $Property = $Property.Value
        }
    }

    if ($Property.GetType() -eq [Microsoft.Exchange.Data.ByteQuantifiedSize])
    {
        $kbValue = $Property.ToKB()
    }
    else
    {
        Write-Error "The property provided does not appear to be of the correct type."
    }

    $kbValue
}
