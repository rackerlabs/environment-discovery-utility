# Environment Discovery Utility (EDU)

A set of powershell scripts used to gather information about Active Directory and Exchange.

## Getting Started

1. Download and extract the latest zip file from the releases into the [Powershell Module Installation Directory.](https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx#Anchor_0) (TODO: link to download latest release).
2. Open powershell and run 'Import-Module EnvironmentDiscoveryUtility'
3. Run 'Start-EnvironmentDiscovery' to run the module.  Use 'Get-Help Start-EnvironmentDiscovery' for more details.

### Minimum Requirements

- Windows Server 2008 SP2
- Windows Server 2008 domain functional level 
- .Net Framework 3.5
- PowerShell v2
- Exchange 2010
- Exchange must be installed in the same forest the script is run in.

## Contributing

Please read [CONTRIBUTING.md](https://github.rackspace.com/MicrosoftEng/environment-discovery-utility/blob/master/CONTRIBUTING.md) for details.

### Credentials
https://passwordsafe.corp.rackspace.com/projects/22502

### Windows Server 2008 / Exchange 2010 Static Lab

|Role| Hostname  | IP |
| ------------- | ------------- | ------------- |
|Domain Controller| AD01  | 172.29.20.11 |
|Client Access| CAS01  | 172.29.20.12 |
|Mailbox / Hub Transport| CHM01  | 172.29.20.13  |
