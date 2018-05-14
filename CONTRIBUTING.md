
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

Additionally, we implement the following:

#### Scopes

Please be sure to scope ($Global:, $Script:, etc) your variable correctly.  Refer to [this article](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-6&viewFallbackFrom=powershell-Microsoft.PowerShell.Core) for details

## Additional Notes

These guidelines are open for changes, please feel free to contribute to the style guide itself.
