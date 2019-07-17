function Get-Groups
{

    <# 
  
        .SYNOPSIS 
            Discover all Active Directory Groups in the on premises directory. 
  
        .DESCRIPTION 
            Uses the ADSISearcher type accelerator to discover all Groups. 
  
        .OUTPUTS 
            Returns the Name, DistinguishedName, GroupType, and Member Count of all Groups within Active Directory. 
  
        .EXAMPLE 
            Get-Groups
  
    #> 

    [CmdletBinding()] 
    param (
       #An array of domains.
       [array]
       $Domains
    ) 

    $activity = "Active Directory Groups"
    Write-Log -Level "INFO" -Activity $activity -Message "Discovering Active Directory Groups."
   
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
                    $groupObject = "" | Select-Object Name, DistinguishedName, Type, MemberCount, FSPMemberCount
                    $groupProperties = $group.GetDirectoryEntry() | Select Name, DistinguishedName, GroupType
                    $groupObject.Name = $groupProperties | Select -ExpandProperty Name
                    $groupObject.DistinguishedName = $groupProperties | Select -ExpandProperty DistinguishedName
                  
                    switch ($groupProperties.groupType)
                       {   
                           -2147483646 { $result = "Global Security Group" }
                           -2147483644 { $result = "Domain Local Security Group" }
                           -2147483643 { $result = "Builtin Local Security Group" }
                           -2147483640 { $result = "Universal Security Group" }
                                     2 { $result = "Global Distribution Group" }
                                     4 { $result = "Domain Local Distribution Group" }
                                     8 { $result = "Universal Distribution Group" }
                       }
                
                    $groupObject.Type = $result
                    $groupObject.MemberCount = ([ADSI]("LDAP://"+$groupObject.DistinguishedName)).member.count
                    $groupObject.FSPMemberCount = (([ADSI]("LDAP://"+$groupObject.DistinguishedName)).member | ? {$_ -like "*S-1-5-*"}).count
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
