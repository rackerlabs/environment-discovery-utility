function Get-ADGroups
{

    <# 
  
        .SYNOPSIS 
            Discover all Active Directory Groups in the on premises directory. 
  
        .DESCRIPTION 
            Uses the ADSISearcher type accelerator to discover all Groups. 
  
        .OUTPUTS 
            Returns the Name, DistinguishedName, GroupType, and Member Count of all Groups within Active Directory. 
  
        .EXAMPLE 
            Get-ADGroups
  
    #> 

    [CmdletBinding()] 
    param (
       #An array of domains.
       [array]
       $Domains
    )

    $activity = "Active Directory Groups"
    Write-Log -Level "INFO" -Activity $activity -Message "Discovering Active Directory Groups." -WriteProgress

    $allGroups = @()

    if ($null -ne $domains)
    {
        foreach ($domain in $domains)
        {
            $domainDistinguishedName = "DC="+($domain.Name.Replace(".",",DC="))
            $groupSearcher = [ADSISearcher]'ObjectClass=Group'
            $groupSearcher.PageSize = 1000
            $groupSearcher.SearchRoot = "LDAP://"+$domainDistinguishedName
            $groups = $groupSearcher.FindAll()

            if ($null -ne $groups)
            {
                foreach ($group in $groups)
                {
                    $groupObject = "" | Select-Object Name, DistinguishedName, Type, MemberCount, FSPMemberCount, displayName, givenName, mail, mailNickname, proxyAddresses, targetAddress
                    $groupProperties = $group.Properties
                    $groupObject.Name = $groupProperties.name
                    $groupObject.DistinguishedName = $groupProperties.distinguishedname

                    switch ($groupProperties.grouptype)
                    {
                        -2147483646 { $groupObject.Type = "Global Security Group" }
                        -2147483644 { $groupObject.Type = "Domain Local Security Group" }
                        -2147483643 { $groupObject.Type = "Builtin Local Security Group" }
                        -2147483640 { $groupObject.Type = "Universal Security Group" }
                        2 { $groupObject.Type = "Global Distribution Group" }
                        4 { $groupObject.Type = "Domain Local Distribution Group" }
                        8 { $groupObject.Type = "Universal Distribution Group" }
                    }

                    $groupMembers = @()
                    $groupMembers = ([ADSI]("LDAP://"+$groupObject.DistinguishedName)).member
                    $fspMembers = $groupMembers | Where-Object {$_ -like "*S-1-5-*"}

                    if ($null -notlike $fspMembers)
                    {
                        $groupObject.FSPMemberCount = $fspMembers.count
                    }
                    else
                    {
                        $groupObject.FSPMemberCount = 0
                    }

                    $groupObject.MemberCount = $groupMembers.count

                    if ($null -notlike $groupProperties.displayname)
                    {
                        $groupObject.displayName = $groupProperties.displayname[0]
                    }

                    if ($null -notlike $groupProperties.givenname)
                    {
                        $groupObject.givenName = $groupProperties.givenname[0]
                    }

                    if ($null -notlike $groupProperties.mail)
                    {
                        $groupObject.mail = $groupProperties.mail[0]
                    }

                    if ($null -notlike $groupProperties.mailnickname)
                    {
                        $groupObject.mailNickname = $groupProperties.mailnickname[0]
                    }

                    if ($null -notlike $groupProperties.proxyaddresses)
                    {
                        $groupObject.proxyAddresses = [array] $groupProperties.proxyaddresses
                    }

                    if ($null -notlike $groupProperties.targetaddress)
                    {
                        $groupObject.targetAddress = $groupProperties.targetaddress[0]
                    }

                    $allGroups += $groupObject
                }
            }
        }
    }

    if ($null -ne $allgroups)
    {
        $allgroups
    }
    else
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to find Active Directory Groups."
    }
}
