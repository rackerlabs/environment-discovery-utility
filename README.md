# Environment Discovery Utility (EDU)

A set of powershell scripts used to gather information about Active Directory and Exchange.

## Getting Started

### Install Module

#### Import Module Local Directory

1. Download and extract the latest release of EDU into a local directory.
2. Open PowerShell and run 'Import-Module ./EnvironmentDiscoveryUtility.psm1'


#### Install Module Using Windows PowerShell Modules Directory

1. Download and extract the latest release of EDU into the [Powershell Module Installation Directory.](https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx#Anchor_0) (TODO: link to download latest release).
2. Open powershell and run 'Import-Module EnvironmentDiscoveryUtility'

### Running the Environment Discovery Utility

- You can use the Get-Help command to get the most current information on how to run the module.
- The module can be run without parameters to use the default configuration and run all modules.
- The alias 'sedu' can be used in place of Start-EnvironmentDiscovery

1. Ensure the module is loaded into the current PowerShell session.
2. Type 'Start-EnvironmentDiscovery'
3. Wait for the discovery process to complete, the execution time will vary widely depending on the size of environment and the modules being run.
4. Once completed, the module will indicate the location of the generated files. Copy these files and provide them to Rackspace for further processing

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

#### What do we collect?