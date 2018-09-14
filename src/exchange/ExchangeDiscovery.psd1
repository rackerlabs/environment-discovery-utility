﻿#
# Module manifest for module 'ExchangeDiscovery'
#
# Generated by: Rackspace
#
# Generated on: 5/18/2018
#

@{

# Script module or binary module file associated with this manifest
ModuleToProcess = 'ExchangeDiscovery.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '92eea597-64c5-4acd-9ad6-bbf97649141f'

# Author of this module
Author = 'Rackspace'

# Company or vendor of this module
CompanyName = 'Rackspace'

# Copyright statement for this module
Copyright = 'Rackspace 2018'

# Description of the functionality provided by this module
Description = 'Exchange Discovery'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Name of the Windows PowerShell host required by this module
PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '3.5'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = ''

# Processor architecture (None, X86, Amd64, IA64) required by this module
ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @()

# Modules to import as nested modules of the module specified in ModuleToProcess
NestedModules = @(
    "Get-ExchangeServers.ps1", 
    "Get-ExchangeAcceptedDomains.ps1", 
    "Get-ExchangeVirtualDirectories.ps1", 
    "Get-ExchangeRecipients.ps1", 
    "Initialize-ExchangePowershell.ps1", 
    "Get-ExchangeEmailAddressPolicies.ps1",
    "Get-ExchangeMobileDevicePolicies.ps1",
    "Get-ExchangeRecipientDataStatistics.ps1", 
    "Get-ExchangePublicFolderStatistics.ps1", 
    "Get-ExchangePublicFolderMailboxes.ps1", 
    "Get-ExchangePublicFolderDatabases.ps1",
    "Get-ExchangeDynamicGroups.ps1",
    "Get-ExchangeFederationTrust.ps1",
    "Get-ExchangeOrganizationalRelationship.ps1", 
    "Get-ExchangeDatabaseJournaling.ps1",
    "Get-ExchangeImapPopSettings.ps1", 
    "Get-ExchangeTransportRules.ps1",
    "Get-ExchangeReceiveConnectors.ps1",
    "Get-ExchangeTransportConfig.ps1",
    "Get-ExchangeSendConnectors.ps1",
    "Get-ExchangeOrganizationConfig.ps1",
    "Get-ExchangeClientAccessConfig.ps1",
    "Start-PublicFolderDiscovery.ps1",
    "Convert-ExchangeDataStatisticToKb.ps1",
    "Get-ExchangeRetentionPolicies.ps1",
    "Invoke-RemoteExchangeCommand.ps1",
    "..\Common\Common.psd1",
    "..\Logging\Logging.psd1"
)

# Functions to export from this module
FunctionsToExport = 'Start-ExchangeDiscovery'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
ModuleList = @()

# List of all files packaged with this module
FileList = @()

# Private data to pass to the module specified in ModuleToProcess
PrivateData = ''

}