﻿#
# Module manifest for module 'ExchangeOnlineDiscovery'
#
# Generated by: Rackspace
#
# Generated on: 5/18/2018
#

@{

# Script module or binary module file associated with this manifest
ModuleToProcess = 'ExchangeOnlineDiscovery.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = 'a197534c-d974-4445-867a-b4830fc34c41'

# Author of this module
Author = 'Rackspace'

# Company or vendor of this module
CompanyName = 'Rackspace'

# Copyright statement for this module
Copyright = 'Rackspace 2019'

# Description of the functionality provided by this module
Description = 'Exchange Online Discovery'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '4.5'

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
    "Initialize-ExoPowerShell.ps1",
    "Get-ExoAcceptedDomains.ps1",
    "Get-ExoRecipientDataStatistics.ps1",
    "Get-ExoRecipients.ps1",
    "Get-ExoOrganizationRelationships.ps1",
    "Get-ExoFederationTrusts.ps1",
    "Get-ExoTransportRules.ps1",
    "Get-ExoTransportConfig.ps1",
    "Get-ExoEmailAddressPolicies.ps1",
    "Get-ExoOrganizationConfig.ps1",
    "Get-ExoATPPolicy.ps1",
    "Get-ExoSafeLinksPolicy.ps1",
    "Get-ExoSafeAttachmentPolicy.ps1",
    "Get-ExoMalwareFilterPolicies.ps1",

    "..\Common\Common.psd1",
    "..\Logging\Logging.psd1"
)

# Functions to export from this module
FunctionsToExport = @(
    "Start-ExchangeOnlineDiscovery",
    "Initialize-ExoPowerShell"
)

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