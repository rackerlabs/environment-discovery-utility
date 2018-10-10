function Get-ExchangeSslCerts
{
    <#

        .SYNOPSIS
            Discovers Exchange SSL Certificates.

        .DESCRIPTION
            Query Exchange to find all Exchange SSL Certificates.

        .OUTPUTS
            Returns a custom object containing several key values for the SSL certificates.

        .EXAMPLE
            Get-ExchangeSslCerts -Servers $exchangeServers

    #>

    [CmdletBinding()]
    param (
        # An array of server objects to run an Exchange SSL certificate discovery against
        [array]
        $Servers
    )

    $activity = "SSL Certificates"
    $discoveredSslCertificates = @()

    foreach ($server in $Servers)
    {
        $sslCertificates = $null
        $serverName = $null
        $serverName = $Server.Name
        
        if ($serverName -eq $null)
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to find Exchange Server Name." -WriteProgress
            Continue
        }

        try
        {
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Querying $serverName for Exchange SSL certificates."
            $sslCertificates = Get-ExchangeCertificate -Server $serverName -ErrorAction Stop
        }
        catch [System.Management.Automation.RuntimeException]
        {
            Write-Log -Level "WARNING" -Activity $activity -Message "Runtime exception while querying Exchange for SSL certificates on $serverName. This is usually caused by insufficient permissions. $($_.Exception.Message)"
            Continue 
        }
        catch
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for SSL certificates on $serverName. $($_.Exception.Message)"
            Continue 
        }

        if ($sslCertificates -ne $null)
        {
            foreach ($sslCertificate in $sslCertificates)
            {
                $currentCert = "" | Select-Object Server, Status, CommonName, Services, Issuer, NotAfter, NotBefore
                $currentCert.Server = $serverName
                $currentCert.Status = $sslCertificate.Status
                $currentCert.CommonName = $sslCertificate.Subject
                $currentCert.Services = $sslCertificate.Services
                $currentCert.Issuer = $sslCertificate.Issuer
                $currentCert.NotAfter = $sslCertificate.NotAfter
                $currentCert.NotBefore = $sslCertificate.NotBefore

                $discoveredSslCertificates += $currentCert
            }
        }
    }

    $discoveredSslCertificates
}