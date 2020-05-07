function Get-ADContacts
{

    <#
  
        .SYNOPSIS
            Discover all Active Directory Contacts in the on premises directory. 
  
        .DESCRIPTION
            Uses the ADSISearcher type accelerator and System.DirectoryServices.AccountManagement namespace to discover all contacts.
  
        .OUTPUTS 
            Returns several attribute values for all contacts in Active Directory.
  
        .EXAMPLE
            Get-ADContacts
  
    #> 

    [CmdletBinding()] 
    param (
       #An array of domains.
       [array]
       $Domains
    )

    $activity = "Active Directory Contacts"
    Write-Log -Level "INFO" -Activity $activity -Message "Discovering Active Directory Contacts." -WriteProgress
    $allContacts = @()

    if ($null -ne $domains)
    {
        foreach ($domain in $domains)
        {
            $domainDistinguishedName = "DC="+($domain.Name.Replace(".",",DC="))
            $contactSearcher = [ADSISearcher]'ObjectClass=Contact'
            $contactSearcher.PageSize = 1000
            $contactSearcher.SearchRoot = "LDAP://"+$domainDistinguishedName
            $contacts = $contactSearcher.FindAll()

            if ($null -ne $contacts)
            {
                foreach ($contact in $contacts)
                {
                    $contactObject = "" | Select-Object DistinguishedName, ForwardingSMTPAddress, ForwardingAddress, DeliverAndRedirect, WhenCreated, WhenChanged, ObjectClass, AdminDescription, displayName, givenName, mail, mailNickname, proxyAddresses, targetAddress
                    $contactProperties = $contact.Properties

                    $contactObject.ObjectClass = [array] $contactProperties.objectclass

                    if ($null -notlike $contactProperties.distinguishedname)
                    {
                        $contactObject.DistinguishedName = $contactProperties.distinguishedname[0]
                    }

                    if ($null -notlike $contactProperties.msexchgenericforwardingaddress)
                    {
                        $contactObject.ForwardingSMTPAddress = $contactProperties.msexchgenericforwardingaddress[0]
                    }

                    if ($null -notlike $contactProperties.altrecipient)
                    {
                        $contactObject.ForwardingAddress = $contactProperties.altrecipient[0]
                    }

                    if ($null -notlike $contactProperties.deliverandredirect)
                    {
                        $contactObject.DeliverAndRedirect = $contactProperties.deliverandredirect[0]
                    }

                    if ($null -notlike $contactProperties.whencreated)
                    {
                        $contactObject.WhenCreated = $contactProperties.whencreated[0]
                    }

                    if ($null -notlike $contactProperties.whenchanged)
                    {
                        $contactObject.WhenChanged = $contactProperties.whenchanged[0]
                    }

                    if ($null -notlike $contactProperties.displayname)
                    {
                       $contactObject.displayName = $contactProperties.displayname[0]
                    }

                    if ($null -notlike $contactProperties.givenname)
                    {
                        $contactObject.givenName = $contactProperties.givenname[0]
                    }

                    if ($null -notlike $contactProperties.mail)
                    {
                        $contactObject.mail = $contactProperties.mail[0]
                    }

                    if ($null -notlike $contactProperties.mailnickname)
                    {
                        $contactObject.mailNickname = $contactProperties.mailnickname[0]
                    }

                    if ($null -notlike $contactProperties.proxyaddresses)
                    {
                        $contactObject.proxyAddresses = [array] $contactProperties.proxyaddresses
                    }

                    if ($null -notlike $contactProperties.targetaddress)
                    {   
                        $contactObject.targetAddress = $contactProperties.targetaddress[0]
                    }

                    if ($null -notlike $contactProperties.admindescription)
                    {
                        $contactObject.AdminDescription = $contactProperties.admindescription[0]
                    }

                    $allcontacts += $contactObject
                }
            }
        }
    }

    if ($null -ne $allcontacts)
    {
        $allcontacts
    }
    else
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to find Active Directory contacts."
    }
}
