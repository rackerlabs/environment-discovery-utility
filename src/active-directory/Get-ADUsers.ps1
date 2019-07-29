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
    Write-Log -Level "INFO" -Activity $activity -Message "Discovering Active Directory Users."
   
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
                    $userObject = "" | Select-Object DistinguishedName, UserAccountControl, AccountExpires, MustChangePassword, ForwardingSMTPAddress, ForwardingAddress, DeliverAndRedirect, WhenCreated, WhenChanged, CannotChangePassword, LastLogon
                    $userProperties = $user.GetDirectoryEntry() | Select DistinguishedName, UserAccountControl, msExchGenericForwardingAddress, altRecipient, DeliverAndRedirect, WhenCreated, WhenChanged
                    $userObject.DistinguishedName = $userProperties | Select -ExpandProperty DistinguishedName
                    $userObject.UserAccountControl = $userProperties | Select -ExpandProperty UserAccountControl
                    $userObject.ForwardingSMTPAddress = $userProperties | Select -ExpandProperty msExchGenericForwardingAddress
                    $userObject.ForwardingAddress = $userProperties | Select -ExpandProperty altRecipient
                    $userObject.DeliverAndRedirect = $userProperties | Select -ExpandProperty DeliverAndRedirect
                    $userObject.WhenCreated = $userProperties | Select -ExpandProperty WhenCreated
                    $userObject.WhenChanged = $userProperties | Select -ExpandProperty WhenChanged
                    
                    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
                    $contextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
                    $context = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $contextType, $domain.Name
                    $idType = [System.DirectoryServices.AccountManagement.IdentityType]::DistinguishedName         
                    $otherUserProperties = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($context, $idType, $userObject.DistinguishedName) | Select UserCannotChangePassword, LastPasswordSet, AccountExpirationDate, LastLogon
                    $userObject.CannotChangePassword = $otherUserProperties.UserCannotChangePassword
                    $userObject.LastLogon = $otherUserProperties.LastLogon

                    if ($null -eq $otherUserProperties.LastPasswordSet)
                    {
                        $userObject.MustChangePassword = "True"
                    }
                    else
                    {
                        $userObject.MustChangePassword = "False"
                    }

                    if ($null -eq $otherUserProperties.AccountExpirationDate)
                    {
                        $userObject.AccountExpires = "Never"
                    }
                    else
                    {
                        $userObject.AccountExpires = $otherUserProperties.AccountExpirationDate
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
