
# Contributing to Environment Discovery Utility (EDU)

The following is a quick set of guidelines for contributing to EDU.

## Github

#### **Everything starts with a GitHub Issue**

* Search for the issue or feature in the issues list on GitHub.
* If there is no existing issue, create an issue with a descriptive subject and description.  Non-descriptive issues will be closed.
* Use existing labels when possible.
* Get feedback on the request in the issue you created.
* Create a branch using the following format: descriptive-feature-name
* Once ready to merge, initiate a pull request.
* Pull requests should include refences to the issues being worked using [keywords](https://help.github.com/articles/closing-issues-using-keywords/) like `closes #234`
* The team will perform a code review and provide feedback, which may require adjustments in code.
* Once your pull request is approved, merge your branch into master.  Be sure all associated CI builds complete successfully.

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

#### Additional Guidelines

Highlighted standards or anything not covered by the preceding guidelines.

##### Scopes

Please be sure to scope ($Global:, $Script:, etc) your variable correctly.  Refer to [this article](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-6&viewFallbackFrom=powershell-Microsoft.PowerShell.Core) for details

## Project Structure

#### Folders

root<br>
|<br>
-> README.md<br>
-> CONTRIBUTING.md<br>
-> src<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> Start-EnvironmentDiscovery.ps1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> manifest.json<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ext<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> common<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> [area]<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> script1.ps1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> script2.ps1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> script3.ps1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> [another area]<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> script1.ps1<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> script2.ps1<br>

| Name           | Description     |
|:------------- |:------------- |
| **Run-Discovery.ps1**      | Arbitrary name, entry point for all operations. |
| **manifest.json**      | Tracks location of everything, used by all scripts for location references. |
| **common**      | Shared scripts used throughout the code base. |
| **[areas]**    | Scripts grouped by functionality, for example "active-directory" or "exchange". |

## Additional Notes

These guidelines are open for changes, please feel free to contribute to the style guide itself.
