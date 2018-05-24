function Get-ExchangeMoveRequests
{
    Param
    (
        [parameter]$domainDN
    )
    if (!($domainDN))
    {
        $domain = [ADSI]"LDAP://RootDSE"
        [string]$domainDN = $domain.rootDomainNamingContext 
    }

    $count= 0
    $inProgressCount = 0
    $completedCount = 0
    $completedWarningCount = 0
    $failedCount = 0
    $otherCount = 0
    $searcher = [adsisearcher]"(&(objectCategory=user)(msexchmailboxmovestatus=*))"
    $searcher.searchRoot = [adsi]"LDAP://$($domainDN)"
    $searcher.PageSize = 300000
    $searcher.PropertiesToLoad.AddRange(('name','msExchMailboxMoveStatus'))
    $results = $searcher.FindAll()
    
    foreach ($result in $results)
    {
        $count++
        switch ($result.properties.msexchmailboxmovestatus)
        {
            1{$inProgressCount++}
            10{$completedCount++}
            11{$completedWarningCount++}
            99{$failedCount++}
            default{$otherCount++}
        }
    }

    $total = New-Object -TypeName PSObject
    $total | Add-Member -MemberType NoteProperty -Name DomainDN -Value $domainDN
    $total | Add-Member -MemberType NoteProperty -Name TotalMoveRequests -Value $count
    $total | Add-Member -MemberType NoteProperty -Name InProgress -Value $inProgressCount
    $total | Add-Member -MemberType NoteProperty -Name Completed -Value $completedcount
    $total | Add-Member -MemberType NoteProperty -Name Completed/Warning -Value $completedWarningCount
    $total | Add-Member -MemberType NoteProperty -Name Failed -Value $failedCount
    $total | Add-Member -MemberType NoteProperty -Name Other -Value $otherCount

    $total
}