[![codecov](https://codecov.io/github/poopae8055/robotframework-nifilibrary/branch/main/graph/badge.svg?token=UWQ02FZKKK)](https://codecov.io/github/poopae8055/robotframework-nifilibrary)

# NifiLibrary
`NifiLibrary` is a [Robot Framework](http://www.robotframework.org) test library which provides keywords to work with Apache Nifi api

# Usage
Install `robotframework-nifilibrary` via `pip` command

```bash
pip install -U robotframework-nifilibrary
```

# Example Test Case
| *** Settings ***      |                                                  |                          |                      |                     |                                         |                     |
|-----------------------|--------------------------------------------------|--------------------------|----------------------|---------------------|-----------------------------------------|---------------------|
| Library               | NifiLibrary                                      |                          |                      |                     |                                         |                     |
| Library               | OperatingSystem                                  |                          |                      |                     |                                         |                     |
| *** Test Cases ***    |                                                  |                          |                      |                     |                                         |                     |
| Rename File - Success |                                                  |                          |                      |                     |                                         |                     |
|                       | ${token}                                         | Connect to Nifi          | ${base_url}          | ${username}         | ${password}                             |                     |
|                       | Update Parameter Value Without Stopped Component | ${parameter_context_id}  | ${file_filter_param} | ${file_filter_name} |                                         |                     |
|                       | Run Once Processor                               | ${get_file_processor_id} |                      |                     |                                         |                     |
|                       | List Directory                                   | ${local_folder_path}/    |                      |                     |                                         |                     |
|                       | Wait Until Keyword Succeeds                      | 3x                       | 5s                   | File Should Exist   | ${local_folder_path}/${file_name_value} |                     |

# Documentation