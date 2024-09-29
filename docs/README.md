[![codecov](https://codecov.io/github/poopae8055/robotframework-nifilibrary/branch/main/graph/badge.svg?token=UWQ02FZKKK)](https://codecov.io/github/poopae8055/robotframework-nifilibrary)
[![Build Status](https://app.travis-ci.com/poopae8055/robotframework-nifilibrary.svg?token=qyEYwbjyGpqh4SudnCnQ&branch=main)](https://app.travis-ci.com/poopae8055/robotframework-nifilibrary)
[![PyPI version](https://badge.fury.io/py/robotframework-nifilibrary.svg)](https://badge.fury.io/py/robotframework-nifilibrary)

# NifiLibrary
`NifiLibrary` is a [Robot Framework](http://www.robotframework.org) library that simplifies interactions with the Apache NiFi API, leveraging the powerful Nipyapi SDK to provide keywords for managing NiFi components, controlling data flows, and automating tasks. This makes it easier to test and automate NiFi workflows directly within Robot Framework.

# Usage
Install `robotframework-nifilibrary` via `pip` command

```bash
pip install -U robotframework-nifilibrary
```

# Example Test Case
| *** Settings ***      |                                                  |                          |                      |                     |                                         |             |
|-----------------------|--------------------------------------------------|--------------------------|----------------------|---------------------|-----------------------------------------|-------------|
| Library               | NifiLibrary                                      |                          |                      |                     |                                         |             |
| Library               | OperatingSystem                                  |                          |                      |                     |                                         |             |
| *** Test Cases ***    |                                                  |                          |                      |                     |                                         |             |
| Rename File - Success |                                                  |                          |                      |                     |                                         |             |
|                       | ${token}                                         | Create Nifi Session      | ${host}              | ${port}             | ${username}                             | ${password} |
|                       | Update Parameter Value Without Stopped Component | ${parameter_context_id}  | ${file_filter_param} | ${file_filter_name} |                                         |             |
|                       | Start Processor                                  | ${get_file_processor_id} |                      |                     |                                         |             |
|                       | List Directory                                   | ${local_folder_path}/    |                      |                     |                                         |             |
|                       | Wait Until Keyword Succeeds                      | 3x                       | 5s                   | File Should Exist   | ${local_folder_path}/${file_name_value} |             |

# Documentation