function Export-DnsRecord
{
    <#

    .SYNOPSIS
        Perform a DNS query and provide result.

    .DESCRIPTION
        Perform a DNS query and provide result.  Optionally, you can provide the record type and DNS server to query.
        This function is a helper script for the JHSoftware DnsClient http://www.simpledns.com/.  
        
    .OUTPUTS
        JHSoftware.DnsClient+Response
        Name                MemberType Definition
        ----                ---------- ----------
        Equals              Method     bool Equals(System.Object obj)
        GetHashCode         Method     int GetHashCode()
        GetType             Method     type GetType()
        ToString            Method     string ToString()
        AdditionalRecords   Property   System.Collections.ObjectModel.ReadOnlyCollection[JHSoftware.DnsClient+Response+Record] AdditionalRecords {get;}
        AnswerRecords       Property   System.Collections.ObjectModel.ReadOnlyCollection[JHSoftware.DnsClient+Response+Record] AnswerRecords {get;}
        AuthoritativeAnswer Property   bool AuthoritativeAnswer {get;}
        AuthorityRecords    Property   System.Collections.ObjectModel.ReadOnlyCollection[JHSoftware.DnsClient+Response+Record] AuthorityRecords {get;}
        Edns0PayLoad        Property   int Edns0PayLoad {get;}
        FromServer          Property   ipaddress FromServer {get;}
        HasEdns0            Property   bool HasEdns0 {get;}
        RecursionAvailable  Property   bool RecursionAvailable {get;}

    .EXAMPLE
        Export-DnsRecord -HostName rackspace.com -RecordType Any

        FromServer          : 10.13.90.38
        RecursionAvailable  : True
        AuthoritativeAnswer : False
        AnswerRecords       : {rackspace.com, rackspace.com, rackspace.com, rackspace.com...}
        AuthorityRecords    : {}
        AdditionalRecords   : {ns2.rackspace.com, ns.rackspace.com, cust65406-2-in.mailcontrol.com, cust65406-1-in.mailcontrol.com}
        HasEdns0            : True
        Edns0PayLoad        : 4000

    .EXAMPLE
        Export-DnsRecord -HostName sts.rackspace.com -Type A | Select -ExpandProperty AnswerRecords

        Name              Type TTL Data
        ----              ---- --- ----
        sts.rackspace.com    A  17 10.13.196.16

    .EXAMPLE
        Export-DnsRecord -HostName sts.rackspace.com -Type A -Server 8.8.8.8 | Select -ExpandProperty AnswerRecords

        Name              Type TTL Data
        ----              ---- --- ----
        sts.rackspace.com    A 287 166.78.43.3
        sts.rackspace.com    A 287 104.130.100.220

    #>

[CmdletBinding()]
param (
    # HostName The hostname to query in DNS
    [string]
    $HostName,

    # Type The type of DNS Record to look up, defaults to ANY
    [string]
    $Type = "ANY",

    # Server The IP of the DNS server to query
    [string]
    $Server = $null
)

    $validTypes = @("A", "A6", "AAAA", "AFSDB", "ANY", "APL", "ATMA", "CERT", "CNAME", "DHCID", "DLV", "DNAME","DNSKEY",
        "DS", "EID", "GID", "GPOS", "HINFO", "HIP", "IPSECKEY", "ISDN", "KEY","KX", "LOC", "MB", "MD", "MF", "MG", "MINFO",
        "MR", "MX", "NAPTR", "NIMLOC", "NS", "NSAP","NSAPPTR", "NSEC", "NSEC3", "NSEC3PARAM", "NXT", "OPT", "PTR", "PX",
        "RP", "RRSIG", "RT", "SIG", "SINK", "SOA", "SPF", "SRV", "SSHFP", "TA", "TXT", "UID", "UINFO", "UNSPEC", "WKS", "X2S")

    $options = New-Object JHSoftware.DnsClient+RequestOptions
    
    if (-not [string]::IsNullOrEmpty($Server))
    {
        $options.DnsServers = $Server
    }

    if ($validTypes -contains $Type)
    {
        $dnsRecords = @()

        try
        {
            $dnsResponse = [JHSoftware.DnsClient]::Lookup($HostName, [JHSoftware.DnsClient+RecordType]::$Type, $options)
        }
        catch
        {
            Write-Warning -Message "Failed to query DNS for $HostName type $Type`.  $($_.Exception.Message)"
        }

        [array]$answerRecords = $dnsResponse.AnswerRecords
        
        if ($answerRecords.Count -gt 0)
        {
            foreach ($answerRecord in $answerRecords)
            {
                $convertedRecord = "" | Select-Object Name, Type, Ttl, Data
                $convertedRecord.Name = $answerRecord.Name
                $convertedRecord.Type = $answerRecord.Type
                $convertedRecord.Ttl = $answerRecord.Ttl
                $convertedRecord.Data = $answerRecord.Data

                $dnsRecords += $convertedRecord
            }
        }

        $dnsRecords
    }
    else
    {
        Write-Error "An invalid record type was provided.  Cannot perform lookup."
    }
}
