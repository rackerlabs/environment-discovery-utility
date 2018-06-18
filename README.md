# Environment Discovery Utility (EDU)

A set of powershell scripts used to gather information about Active Directory and Exchange.

## Getting Started

### Installing the EDU Module

#### Import Module Local Directory

1. Download and extract the latest release of EDU into a local directory.
2. Open PowerShell as Administrator and run 'Import-Module ./EnvironmentDiscoveryUtility.psm1'.

#### Install Module Using Windows PowerShell Modules Directory

1. Download and extract the latest release of EDU into the [Powershell Module Installation Directory.](https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx#Anchor_0) (TODO: link to download latest release).
2. Open powershell and run 'Import-Module EnvironmentDiscoveryUtility'

### Running the EDU Module

- You can use the Get-Help command to get the most current information on how to run the module.
- The module can be run without parameters to use the default configuration and run all modules.
- The alias 'sedu' can be used in place of Start-EnvironmentDiscovery.
- You may have to change your execution policy in order to run the module, depending on your organization's configuration.
  - 'Set-ExecutionPolicy Unrestricted' will allow you to run the module.  
  - You can view your current Execution Policy using Get-ExecutionPolicy cmdlet and revert the change once the module is completed if desired.

1. Ensure the module is loaded into the current PowerShell session.
2. Type 'Start-EnvironmentDiscovery'.
3. Wait for the discovery process to complete, the execution time will vary widely depending on the size of environment and the modules being run.
4. Once completed, the module will indicate the location of the generated files. Copy these files and provide them to Rackspace for further processing.

### Minimum Requirements

- Windows Server 2008 SP2
- Windows Server 2008 domain functional level 
- .Net Framework 3.5
- PowerShell v2
- Exchange 2010
- The Exchange managament tools must be installed on the computer running the module in order for some data to be returned by the Exchange discovery module.  If the module is unable to connect to Exchange PowerShell it will collect only the data that is available by querying Active Directory.  For example, mailbox size statistics would be skipped.

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

#### What Do We Collect?

We make an effort to only include data that is relevant to the discovery phase of the project.  We do not store email addresses, usernames, public folder names, or other sensitive information.  In some cases, if we need to be able to relate one object to another we will use a GUID.  The full list of properties that are included in the module's output are listed below.

##### Exchange
  * Servers
    * DistinguishedName
    * InstalledRoles
    * Name
    * Site
    * Version
  * DatabaseJournaling
    * TargetGuid
    * TargetObjectClass
  * FederationTrust
    * ObjectGuid
  * DynamicGroups
    * MemberCount
    * ObjectGuid
  * AcceptedDomains
    * AcceptedDomainFlags
    * Name
  * Recipients
    * ItemCount
    * ObjectGuid
    * PrimaryMatchesUpn
    * PrimarySmtpDomain
    * RecipientDisplayType
    * RecipientTypeDetails
    * RemoteRecipientType
    * TotalItemSizeKB
    * UserPrincipalNameSuffix
  * VirtualDirectories
    * ComputerName
    * DistinguishedName
    * ExternalAuthenticationMethods
    * ExternalHostName
    * InternalAuthenticationMethods
    * InternalHostName
    * Name
    * ObjectClasses
  * PublicFolders
    * Databases
      * ObjectGuid
      * ParentServer
    * Mailboxes
      * MailboxDatabase
      * ObjectGuid
      * ParentDatabase
    * Statistics
      * Identity
      * ItemCount
      * TotalItemSizeKB
  * TransportRules
    * Action
    * Condition
    * Exemption
    * ObjectGuid
    * Type
  * OrganizationalRelationships
    * Enabled
    * EnabledActions
    * ObjectGuid
##### ActiveDirectory
  * Forest
    * Name
    * Mode
    * NamingRoleOwner
    * RootDomain
    * Schema
    * SchemaRoleOwner
    * SiteLinks
    * Sites
      * Name
      * AdjacentSites
      * SiteLinks
      * Subnets
    * ApplicationPartitions
    * Domains
      * Children
      * DomainControllers
      * Mode
      * InfrastructureRoleOwner
      * Name
      * Parent
      * PdcRoleOwner
      * RidRoleOwner
