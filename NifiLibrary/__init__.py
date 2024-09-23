from .NifiLibraryKeywords import NifiLibraryKeywords
from .version import VERSION

__version__ = VERSION

__author__ = 'Weeraporn.pai'
__email__ = 'poopae1322@gmail.com'

class NifiLibrary(NifiLibraryKeywords):
    """NifiLibrary is a robotframework library to call Apache Nifi api via nipyapi SDK.

    == Example Test Cases ==
    | ***** Settings *****       |
    | Library                | NifiLibrary   |
    | Library                | OperatingSystem   |
    |                        |
    | ***** Test Cases *****     |
    | TC0001 Rename file - Success |
    | Connect to Nifi  | ${base_url}  | ${username} | ${password} |
    |  Stop Process Group  | ${rename_processor_group_id} |
    | Update Parameter Value With Stopped Component  | ${parameter_context_id}  | ${file_filter_param}  | ${file_filter_name} |
    | Update Parameter Value With Stopped Component  | ${parameter_context_id}  | ${file_name_param}  | ${file_name_value} |
    | Run Once Processor  | ${rename_file_starter_id} |
    | ${dic} | List Directory  | ${local_folder_path} |
    |  Wait Until Keyword Succeeds  | 3x  | 5s  | File Should Exist  | ${local_folder_path}/${file_name_value} |
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LIBRARY_DOC_FORMAT = "ROBOT"
    ROBOT_LIBRARY_VERSION = VERSION
