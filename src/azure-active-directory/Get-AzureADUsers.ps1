function Get-AzureADUsers
{
    <#

        .SYNOPSIS
            Discover Azure AD Users

        .DESCRIPTION
            Query Azure AD for Users

        .OUTPUTS
            Returns a custom object containing Azure AD Users

        .EXAMPLE
            Get-AzureADUsers

    #>

    [CmdletBinding()]
    param ()

    $activity = "AzureAD Users"
    [System.Collections.ArrayList]$allUsers = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query AzureAD for Users." -WriteProgress
        $Users = Get-AzureADUser -All $true | Select-Object ObjectId, ObjectType, UserPrincipalName, ImmutableId, AccountEnabled, Mail, SipProxyAddress, DirSyncEnabled, LastDirSyncTime, UsageLocation, PasswordPolicies
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query AzureAD for Users. $($_.Exception.Message)"
        return
    }

    if ($Users)
    {
        foreach ($user in $Users)
        {
            $userObject = "" | Select-Object ObjectId, ObjectType, UserPrincipalName, ImmutableId, AccountEnabled, Mail, SipProxyAddress, DirSyncEnabled, LastDirSyncTime, UsageLocation, PasswordPolicies
            $userObject.ObjectId = $user.ObjectId
            $userObject.ObjectType = $user.ObjectType
            $userObject.UserPrincipalName = $user.UserPrincipalName
            $userObject.AccountEnabled = $user.AccountEnabled
            $userObject.Mail = $user.Mail
            $userObject.SipProxyAddress = $user.SipProxyAddress
            $userObject.DirSyncEnabled = $user.DirSyncEnabled
            $userObject.LastDirSyncTime = $user.LastDirSyncTime
            $userObject.UsageLocation = $user.UsageLocation
            $userObject.PasswordPolicies = $user.PasswordPolicies -split ','

            if ($null -ne $user.ImmutableId)
            {
                [guid]$userObject.ImmutableId = [System.Convert]::FromBase64String($user.ImmutableId)
            }

            $allUsers.Add($userObject) | Out-Null
        }
    }

    if ($allUsers.Count -ne 0)
    {
        $allUsers
    }
    else
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to find Azure Active Directory Users."
    }
}
