function Get-ADUsers
{

    <#
  
        .SYNOPSIS
            Discover all Active Directory Users in the on premises directory. 
  
        .DESCRIPTION
            Uses the ADSISearcher type accelerator and System.DirectoryServices.AccountManagement namespace to discover all Users.
  
        .OUTPUTS 
            Returns several attribute values for all users in Active Directory.
  
        .EXAMPLE
            Get-ADUsers
  
    #> 

    [CmdletBinding()] 
    param (
       #An array of domains.
       [array]
       $Domains
    )

    $activity = "Active Directory Users"
    Write-Log -Level "INFO" -Activity $activity -Message "Discovering Active Directory Users." -WriteProgress
    $allUsers = @()

    if ($null -ne $domains)
    {
        foreach ($domain in $domains)
        {
            $domainDistinguishedName = "DC="+($domain.Name.Replace(".",",DC="))
            $userSearcher = [ADSISearcher]'ObjectClass=User'
            $userSearcher.PageSize = 1000
            $userSearcher.SearchRoot = "LDAP://"+$domainDistinguishedName
            $users = $userSearcher.FindAll()

            if ($null -ne $users)
            {
                foreach ($user in $users)
                {
                    $userObject = "" | Select-Object DistinguishedName, UserAccountControl, AccountExpires, MustChangePassword, ForwardingSMTPAddress, ForwardingAddress, DeliverAndRedirect, WhenCreated, WhenChanged, LastLogon
                    $userProperties = $user.Properties

                    if ($null -notlike $userProperties.distinguishedname)
                    {
                        $userObject.DistinguishedName = $userProperties.distinguishedname[0]
                    }

                    if ($null -notlike $userProperties.useraccountcontrol)
                    {
                        $userObject.UserAccountControl = $userProperties.useraccountcontrol[0]
                    }

                    if ($null -notlike $userProperties.msexchgenericforwardingaddress)
                    {
                        $userObject.ForwardingSMTPAddress = $userProperties.msexchgenericforwardingaddress[0]
                    }

                    if ($null -notlike $userProperties.altrecipient)
                    {
                        $userObject.ForwardingAddress = $userProperties.altrecipient[0]
                    }

                    if ($null -notlike $userProperties.deliverandredirect)
                    {
                        $userObject.DeliverAndRedirect = $userProperties.deliverandredirect[0]
                    }

                    if ($null -notlike $userProperties.whencreated)
                    {
                        $userObject.WhenCreated = $userProperties.whencreated[0]
                    }

                    if ($null -notlike $userProperties.whenchanged)
                    {
                        $userObject.WhenChanged = $userProperties.whenchanged[0]
                    }

                    if ($null -notlike $userProperties.lastlogon -and $userProperties.lastlogon[0] -notlike 0)
                    {
                        $userObject.LastLogon = [datetime]::FromFileTime($userProperties.lastlogon[0])
                    }

                    if ($null -notlike $userProperties.accountexpires -and $userProperties.accountexpires[0] -notlike 9223372036854775807 -and $userProperties.accountexpires[0] -notlike 0)
                    {
                        $userObject.AccountExpires = [datetime]::FromFileTime($userProperties.accountexpires[0])
                    }

                    if ($null -eq $userProperties.pwdlastset -or $userProperties.pwdlastset[0] -eq 0)
                    {
                        $userObject.MustChangePassword = "True"
                    }
                    else
                    {
                        $userObject.MustChangePassword = "False"
                    }

                    $allUsers += $userObject
                }
            }
        }
    }

    if ($null -ne $allUsers)
    {
        $allUsers
    }
    else
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to find Active Directory Users."
    }
}
