# Environment Discovery Utility (EDU)

A set of powershell scripts used to gather information about Active Directory and Exchange.

## Getting Started

### What We Collect

For an overview of the data collected, please see the [included document](/src/edu-data-collection-summary.pdf).

### Minimum Requirements

- Windows Server 2008 SP2
- Windows Server 2008 domain functional level
- .Net Framework 3.5
- PowerShell v2
- Exchange 2010
- The Exchange management tools should be installed on the computer running the module.  If the management tools are not found some types of data collection, like mailbox size statistics, will be skipped.
- Microsoft Cloud PowerShell modules, such as Azure Active Directory and Exchange Online Manegement PowerShell modules, require more modern components. We recommend running from a computer with Windows Management Framework 5 or above.

### Running the EDU Module

1. Download and extract the [latest release of EDU](https://github.com/rackerlabs/environment-discovery-utility/releases/latest) to your desktop.
2. Open PowerShell.
3. Run *Set-ExecutionPolicy RemoteSigned*.
4. Browse to the directory, run *Invoke-Discovery.ps1*. You may choose to run Invoke-Discovery.ps1 with the -Modules parameter to run specific modules. For example, use "Invoke-Discovery.ps1 -Modules Ad,Exchange" to run only on-premises modules or "InvokeDiscovery.ps1 -Modules AzureAD,ExchangeOnline"
5. Wait for the discovery process to complete, the execution time will vary widely depending on the size of environment and the modules being run.
6. Once completed, the module will indicate the location of the generated files. Copy these files and provide them to Rackspace for further processing.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Licenses

Original files contained with this distribution are licensed under the [MIT License](https://en.wikipedia.org/wiki/MIT_License).

You must agree to the terms of this [license](LICENSE.txt) and abide by them before using, modifying, or distributing source code contained within this distribution.

Some dependencies are under other licenses.
