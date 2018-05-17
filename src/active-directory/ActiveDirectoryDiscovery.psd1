﻿#
# Module manifest for module 'ActiveDirectoryDiscovery'
#
# Generated by: Rackspace
#
# Generated on: 5/14/2018
#

@{

# Script module or binary module file associated with this manifest
ModuleToProcess = 'ActiveDirectoryDiscovery.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '3dcfbe1b-f4c6-4f6c-b74d-5ecfc2c26de3'

# Author of this module
Author = 'Rackspace'

# Company or vendor of this module
CompanyName = 'Rackspace'

# Copyright statement for this module
Copyright = 'Rackspace 2018'

# Description of the functionality provided by this module
Description = 'Active Directory Discovery'

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
NestedModules = @("Get-ActiveDirectoryCurrentForest.ps1","Get-ActiveDirectoryDomains.ps1","Get-ActiveDirectorySites.ps1")

# Functions to export from this module
FunctionsToExport = 'Start-ActiveDirectoryDiscovery'

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