from .NifiLibraryKeywords import NifiLibraryKeywords
from .version import VERSION

__version__ = VERSION

__author__ = 'Weeraporn.pai'
__email__ = 'poopae1322@gmail.com'

class NifiLibrary(NifiLibraryKeywords):
    """
    NifiLibrary is a robotframework library that simplifies interactions with the Apache NiFi API,
    leveraging the powerful Nipyapi SDK to provide keywords for managing NiFi components,
    controlling data flows, and automating tasks. This makes it easier to test and automate NiFi workflows directly
    within Robot Framework.

    == Example Test Cases ==
    | ***** Settings *****       |
    | Library                | NifiLibrary   |
    | Library                | OperatingSystem   |
    |                        |
    | ***** Test Cases *****     |
     | TC0001 Rename file - Success |
    | Create Nifi Session | ${host} | ${port}  | ${username} | ${password} |
    | Update Parameter Value With Stopped Component | ${parameter_context_id} | change_name | ${expected_file} |
    | Update Process Group Parameter Context | ${processor_group_id} | ${parameter_context_id} |
    | Stop Processor | ${get_file_processor_id} |
    | Start Processor | ${get_file_processor_id} |
    | Stop Processor | ${get_file_processor_id} |
    | OS.File Should Exist | ${expected_file_path}/${expected_file} |
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LIBRARY_DOC_FORMAT = "ROBOT"
    ROBOT_LIBRARY_VERSION = VERSION
