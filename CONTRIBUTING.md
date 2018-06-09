
# Contributing to Environment Discovery Utility (EDU)

The following is a set of guidelines for contributing to EDU.

## Github

### **Everything starts with a GitHub Issue**

* Search for the issue or feature in the issues list on GitHub.
* If there is no existing issue, create an issue with a descriptive subject and description.  Non-descriptive issues will be closed.
* Use existing labels when possible and assign the issue to the correct person performing the work.
* Get feedback on the request in the issue you created.

### **Branching**
* Create a branch using the following format: feature-name.
* Branch names should be short and concise.

### **Testing**
* Once work in your branch is complete, merge your branch into the [develop branch](https://github.rackspace.com/MicrosoftEng/environment-discovery-utility/tree/develop).
* Our build server (BUILD01-ORD1.mgmt.mlsrvr.com) runs [Jenkins](https://jenkins.io/) which monitors the develop branch, any changes to this branch will kick off a new CI build.
* The CI build will automatically deploy and test the updated to code using our lab automation infrastructure.
* It is important to monitor the results of the CI build.  If there are any errors, the build will fail.  
    - This first place to check is in the #edu Slack channel.  
    - If your build failed or no output is showing in Slack, please log into our [Jenkins instance](https://jenkins.mseng.mlsrvr.com/job/edu_ci/) using MGMT credentials.  
    - Once logged in, you can view the build output directly using [this link](https://jenkins.mseng.mlsrvr.com/job/edu_ci)
    - To view detailed logs, click your build number in the left pane, then click Console Output in the left menu. 
* If your build fails, switch back to the original branch, correct the errors and restart the testing procedure.

#### **Pull Requests**
* Once ready to merge, initiate a pull request.
* Pull requests should include refences to the issues being worked using [keywords](https://help.github.com/articles/closing-issues-using-keywords/) like `closes #234`.
* The team will perform a code review and provide feedback, which may require adjustments in code.
* Once your pull request is approved, merge your branch into master.

## Styleguides

### PowerShell Quick Start

| Identifier            | Camel   | Lower  | Pascal | Examples and Notes |
|:--------------------- |:-------:|:------:|:------:|:------------------ |
| Language keyword      |  | :white_check_mark: |  | `try`, `catch`, `foreach`, `switch` |
| Process block keyword |  | :white_check_mark: |  | `begin`, `process`, `end` |
| Comment help keyword  |  |  | :white_check_mark: | `.Synopsis`, `.Example` |
| Package or module     |  |  | :white_check_mark: |  |
| Class                 |  |  | :white_check_mark: |  |
| Exception             |  |  | :white_check_mark: |  |
| Constant              |  |  | :white_check_mark: |  |
| Global variable       |  |  | :white_check_mark: | `$Global:$SomeVariable`, `$Script:$AnotherVariable` |
| Local variable        | :white_check_mark: |  |  | `$someOtherVariable` |
| Function              |  |  | :white_check_mark: |  |
| Private function      |  |  | :white_check_mark: |  |

### PowerShell Styleguide

We draw heavily from the [The PowerShell Best Practices and Style Guide](https://github.com/PoshCode/PowerShellPracticeAndStyle).  Please review this documentation, in particular the [Style Guide](https://github.com/PoshCode/PowerShellPracticeAndStyle/blob/master/Style-Guide/Introduction.md) sections.

If a particular matter is not address by the PoshCode style guide, we fall back to .Net coding guidelines.

[Capitalization Conventions](https://docs.microsoft.com/en-us/dotnet/standard/design-guidelines/capitalization-conventions)

[Strongly Encouraged Development Guidelines](https://msdn.microsoft.com/en-us/library/dd878270%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396)

### Additional PowerShell Guidelines

Highlighted standards or anything not covered by the preceding guidelines.

#### Nested Expression Whitespace

The style guide calls out nested expressions as needed a space on the inside of the perenthesis like `$( Some-Command )`.  We prefer to not have spaces where not needed like this: `$(Some-Command)`. This should not be confused with script blocks which should have a single whitespace for padding `{ Some-Command }`.

#### Comment Based Help

All scripts should be written with the appropriate inline documentation, please refer to this template when adding help to your script.

```powershell
<#

.SYNOPSIS
    A brief description of the function or script.

.DESCRIPTION
    A longer description.

.PARAMETER FirstParameter
    Description of each of the parameters
    Note:
    To make it easier to keep the comments synchronized with changes to the parameters, 
    the preferred location for parameter documentation comments is not here, 
    but within the param block, directly above each parameter.

.PARAMETER SecondParameter
    Description of each of the parameters

.INPUTS
    Description of objects that can be piped to the script

.OUTPUTS
    Description of objects that are output by the script

.EXAMPLE
    Example of how to run the script

.LINK
    Links to further documentation

.NOTES
    Detail on what the script does, if this is needed

#>
```

#### Curly Braces

Curly braces should go on their own line to help improve readability.

Correct:

```powershell
function Get-Noun
{
    if ($Wide)
    {
        Get-Command | Sort-Object Noun -Unique | Format-Wide Noun
    }
    else
    {
        Get-Command | Sort-Object Noun -Unique | Select-Object -Expand Noun
    }
}
```

Incorrect:

```powershell
function Get-Noun {
    if ($Wide) {
        Get-Command | Sort-Object Noun -Unique | Format-Wide Noun
    }
    else {
        Get-Command | Sort-Object Noun -Unique | Select-Object -Expand Noun
    }
}
```

#### Spaces vs Tabs

Several editors default to tabs for indentations rather than spaces, which causes display problems when viewing code on Github.  Please be sure to "untabify" your code before checking in.

* Visual Studio
  * Highlight all your code, go to Edit -> Advanced -> Untabify select lines
  
* Notepad++
  * Go to Edit -> Blank Operations -> TAB to space

#### Scopes
When explicitly scoping variables ($Global:, $Script:, etc) please do so correctly.  Refer to [this article](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-6&viewFallbackFrom=powershell-Microsoft.PowerShell.Core) for details

## Project Structure

#### Folders

root<br>
|<br>
-> README.md<br>
-> CONTRIBUTING.md<br>
-> build<br>
-> src<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> EnvironmentDiscoveryUtility.psd1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> EnvironmentDiscoveryUtility.psm1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ext<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> NLog.dll<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> Json.Net.dll<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> common<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> Common.psd1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> Common.psm1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> [area]<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ActiveDirectory.psd1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ActiveDirectory.psm1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> [area]<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> Exchange.psd1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> Exchange.psm1<br>

| Name           | Description   |
|:-------------- |:------------- |
| **EnvironmentDiscoveryUtility.psm1** | Main module which loads all other modules and scripts. |
| **EnvironmentDiscoveryUtility.psd1** | Manifest file. |
| **common** | Shared scripts used throughout the code base. |
| **ext** | External binaries and libraries, for example Nlog or Json.Net. |
| **[area]** | Scripts grouped by functionality, for example [area] would be "active-directory" or "exchange". |

# Logging
## Logging Module
I've added a Logging module to the project.  It is currently in a directory under src/logging.  
This module is simply a wrapper module for the [Enhanced Script Logging module](https://gallery.technet.microsoft.com/scriptcenter/Enhanced-Script-Logging-27615f85) which exists as a nested module in the /src/logging/PowerShellLogging directory.  

## Stream Interception
We use Enable-OutputSubscriber from the PowerShellLogging module to intercept the different streams and use our own Write-Log function to write to file.  We are still unable to stop the Exchange tips from coming to the screen, but we can/do clear the screen once we can.

## Log File
We are logging to the environment-session.log file in the current directory.

### Sample log file from JMLLab
[environment-4a884b49-11ad-4b18-a095-15e8fe58c477_log.txt](https://github.rackspace.com/MicrosoftEng/environment-discovery-utility/files/344/environment-4a884b49-11ad-4b18-a095-15e8fe58c477_log.txt)

## Logging in JSON Return
We take the log entries from the session and include them in the environment report json under the Log element..


Sample log entry
`{
            "Activity": "Exchange Recipient Discovery",
            "Date": "2018-06-08T16:18:18.9463254Z",
            "Level": "DEBUG",
            "Message": "Gathering Exchange recipient details 1180 / 1193"
  }`

### Sample Updated JSON output file from JMLLab
[environment-4a884b49-11ad-4b18-a095-15e8fe58c477_json.txt](https://github.rackspace.com/MicrosoftEng/environment-discovery-utility/files/343/environment-4a884b49-11ad-4b18-a095-15e8fe58c477_json.txt)

## Logging Something
Functions have an 'activity' variable for logging.  I'm not extremely fond of this and have considered using a method I found to set the activity to the name of the function

## Example Usage
- Write a warning message without writing progress bar
`Write-Log -Level 'WARNING' -Activity $activity -Message 'Failed to do something that is not critical but we would want to know about.'`
- Write a verbose message with progress
`Write-Log -Level 'VERBOSE' -Activity $activity -Message 'Gathering Public Folder statistics. This may take some time without feedback.' -WriteProgress`
- Write a verbose message with progress and completion percentage
`Write-Log -Level 'DEBUG' -Activity $activity -Message "Gathering Exchange recipient details $x / $($recipients.Count)" -PercentComplete $percentComplete -WriteProgress`

## Progress Bars
Progress bars are built into the Write-Log function.  See the below notes for more information on usage.
- Demo of Progress Bars
![progress_demo](https://media.github.rackspace.com/user/1619/files/75fb5c94-6a99-11e8-916f-310749c5e360)


## Additional Notes

This document is open for changes, please feel free to contribute to the style guide itself.
