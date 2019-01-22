function Get-ExchangeDnsRecords
{
    <#

        .SYNOPSIS
            Discover DNS records relevant to Microsoft Exchange.

        .DESCRIPTION
            Query DNS for records relevant to Microsoft Exchange and perform internal lookups to detect split-dns.

        .OUTPUTS
            Returns a custom object containing DNS records relevant to Microsoft Exchange.

        .EXAMPLE
            Get-ExchangeDnsRecords -VirtualDirectories $virtualDirectories -AcceptedDomains $acceptedDomains

    #>

    [CmdletBinding()]
    param (
        # Virtual directories objects already discovered by EDU
        [object]
        $VirtualDirectories,

        # AcceptedDomain objects already discovered by EDU
        [array]
        $AcceptedDomains
    )

    $activity = "Exchange DNS Records"
    $urlList = @()
    $hostNames = @()
    $discoveredDnsEntries = @{}

    Write-Log -Level "INFO" -Activity $activity -Message "Query DNS for all records pertinent to Exchange." -WriteProgress
    [array]$virtualDirectoryUrls = Get-VirtualDirectoryUrls -VirtualDirectories $VirtualDirectories

    if ($virtualDirectoryUrls.Count -gt 0)
    {
        $urlList += $virtualDirectoryUrls
    }
    else
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "No URLs were discovered on Exchange Virtual Directories.  Skipping DNS lookups for this item."
    }

    if ($urlList.Count -gt 0)
    {
        foreach ($url in $urlList)
        {
            $urlObject = [System.Uri]"$url"
            $hostNameString = $urlObject.Host

            if ($hostNames -notcontains $hostNameString)
            {
                $hostNames += $hostNameString
            }
        }
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "No URLs discovered for DNS Lookups for Exchange."
    }

    if ($acceptedDomains.Count -gt 0)
    {
        [array]$acceptedDomainNames = $acceptedDomains | Select-Object -ExpandProperty AcceptedDomain | Select-Object -ExpandProperty Address

        $hostNames += $acceptedDomainNames
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "No Accepted Domains discovered for DNS Lookups for Exchange."
    }

    $sortedHostNames = $hostNames | Sort-Object | Select-Object -Unique

    foreach ($hostEntry in $sortedHostNames)
    {
        Write-Log -Level "DEBUG" -Activity $activity -Message "Querying DNS for Exchange URLs discovered with hostname $hostEntry - recordType ANY." -WriteProgress
        $records = Export-DnsRecord -HostName $hostEntry -Type ANY
        $discoveredDnsEntries.Add($hostEntry, $records)
    }

    $discoveredDnsEntries
}

function Get-VirtualDirectoryUrls
{
    param (
        [object]
        $VirtualDirectories
    )

    [array]$virtualDirectoryTypes = $VirtualDirectories.Keys
    [array]$virtualDirectoryUrls = @()

    foreach ($virtualDirectoryType in $virtualDirectoryTypes)
    {
        $typeDirectories = $VirtualDirectories[$virtualDirectoryType]

        foreach ($virtualDirectory in $typeDirectories)
        {
            if ((-not [string]::IsNullOrEmpty($virtualDirectory.InternalUrl)) -and ($urlList -notcontains $virtualDirectory.InternalUrl))
            {
                $virtualDirectoryUrls += $virtualDirectory.InternalUrl
            }

            if ((-not [string]::IsNullOrEmpty($virtualDirectory.ExternalUrl)) -and ($urlList -notcontains $virtualDirectory.ExternalUrl))
            {
                $virtualDirectoryUrls += $virtualDirectory.ExternalUrl
            }
        }
    }

    $virtualDirectoryUrls
}
