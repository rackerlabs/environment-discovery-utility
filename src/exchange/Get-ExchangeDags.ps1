function Get-ExchangeDags
{ 
     <# 
  
         .SYNOPSIS 
             Discover all Exchange database availability groups in the on premises deployment. 
  
         .DESCRIPTION 
             Uses Exchange PowerShell to enumerate Exchange database availability groups. 
  
         .OUTPUTS 
             Returns an array containing a list of Exchange database availability groups and their noteworthy properties. 
  
         .EXAMPLE 
             Get-ExchangeDags
  
     #> 

         
     [CmdletBinding()] 
     param ( 
         # An array of Exchange server objects.
         [array] 
         $Servers 
     ) 

     $activity = "Database Availability Groups"
     Write-Log -Level "INFO" -Activity $activity -Message "Enumerating database availability groups."
     
     if ($Servers | Where { $_.Version.Major -ge 14 })
     {
        $dags = Get-DatabaseAvailabilityGroup -ErrorAction SilentlyContinue
        
        if ($null -notlike $dags)

        {
           $daginfo = @()
           
           foreach ($dag in $dags)
           {
              $dagobject = "" | select Name,Servers,WitnessServer,WitnessDirectory
              $dagobject.Name = $dag.Name
              [array]$dagobject.Servers = $dag.Servers
              $dagobject.WitnessServer = $dag.WitnessServer
              $dagobject.WitnessDirectory = $dag.WitnessDirectory
              $daginfo += $dagobject
           }

           $daginfo
        }
        else
        {
           Write-Log -Level "INFO" -Activity $activity -Message "No database availability groups found."
        }
     }
     else
     {
        Write-Log -Level "Info" -Activity $activity -Message "Database availability groups only exist in Exchange 2010 and above."
     }
}
