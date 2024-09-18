*** Settings ***
Library            JSONLibrary
Library           OracleDBConnector
Library           RequestsLibrary
Library           ../pythonlibs/unzip_with_password.py
Resource        ../resources/imports.robot

*** Keywords ***
The http status should be '${expected_status_code}'
    [Documentation]    Verifies that the HTTP status code of the response matches the expected status code.
    ...    *Pre-condition: An HTTP request has been sent and a response object is available.*
    ...    ${expected_status_code} - The expected HTTP status code (e.g., 200, 400, 500).
    Should Be Equal As Integers    ${response.status_code}    ${expected_status_code}

Verify the response body matches the expected data
        [Documentation]    Verifies that the actual JSON response body matches the expected JSON data.
    ...    *Pre-condition:  An HTTP request has been sent and a response object is available.
    ...    * The expected JSON data is stored in the `${expected_json}` variable.
     ...    ${expected_json} - The expected JSON data as a dictionary or list.
     log  ${response.json()}
     log  ${expected_json}
    Should Be Equal    ${response.json()}    ${expected_json}

Verify Response Lists Match
    [Documentation]    Verifies that the actual API response list matches the expected response list, taking pagination into account.
    ...    It iterates through each page of both the expected and actual response lists
    ...    and uses `Dictionaries Should Be Equal` to compare the corresponding pages.
    ...    *Pre-condition:*
    ...        * An HTTP request has been sent and a response object is available.
    ...        * The expected JSON data for all pages is stored in the `${expected_response_list_all_pages}` variable.
    ...        * The actual JSON data for all pages is stored in the `${actual_response_list_all_pages}` variable.
    ...    *Assumption:*
    ...        * Both lists have the same length (representing the same number of pages).
    ...        * Each item in the lists is a dictionary representing a single page response.
    ${list_length}    Get Length    ${expected_response_list_all_pages}
    Should Be Equal    ${list_length}    ${actual_response_list_all_pages.__len__()}    msg=The number of pages in the expected and actual responses do not match.
    FOR    ${index}    IN RANGE    ${list_length}
        ${expected_response}    Set Variable    ${expected_response_list_all_pages}[${index}]
        ${actual_response}    Set Variable    ${actual_response_list_all_pages}[${index}]
        log  ${actual_response}
        log  ${expected_response}
        Dictionaries Should Be Equal    ${expected_response}    ${actual_response}    msg=Response data for page ${index + 1} does not match.
    END

Verify Data Not Found Response Message
    [Documentation]    Verifies the API response for a "data not found" error.
    ...    Checks if the response status code is 404 and the response body
    ...    contains the expected error message, description, and namespace.
    ...    *Arguments:*
    ...        * `${use_case_code}` - The use case code for which data was not found.
    [Arguments]    ${use_case_code}
    ${expected_response_message}    Set Variable   data not found
    ${expected_response_description}    Set Variable   data from ${date_from} to ${date_to} use case ${use_case_code} not found
    ${expected_response_namespace}    Set Variable   etax
    Verify Error Response  ${expected_response_message}  ${expected_response_description}  ${expected_response_namespace}

Verify Error Response
    [Documentation]    Verifies the API error response against expected values.
    ...    Checks if the response body contains the expected error message,
    ...    description, and namespace.
    ...    *Arguments:*
    ...        * `${expected_message}` - The expected error message.
    ...        * `${expected_description}` - The expected error description.
    ...        * `${expected_namespace}` - The expected error namespace.
    [Arguments]    ${expected_message}  ${expected_description}  ${expected_namespace}
    ${body}=    Set Variable    ${response.json()}
    Should Be Equal    ${body['status']['message']}    ${expected_message}    msg=Error message does not match.
    Should Be Equal    ${body['status']['description']}    ${expected_description}    msg=Error description does not match.
    Should Be Equal    ${body['status']['namespace']}    ${expected_namespace}    msg=Error namespace does not match.

Extract and Verify CSV File Name Match
    [Documentation]    need to call Send Download Zip File API  first to get ${use_case_name}, ${file_infix} and ${the_downloaded_file} path
    ...  and call Set date variable to '${year}' '${month}' '${day}' for ${year}${month}${day}
    ${csv_file_folder_name}  Set Variable  TMN_${use_case_name}_${file_infix}_${year}${month}${day}
    ${expected_csv_file_name}  Set Variable  TMN_${use_case_name}_${file_infix}_${year}${month}${day}-1.csv
    ${extract_dir}    Set Variable    ${EXECDIR}${/}downloaded_files${/}${csv_file_folder_name}
    log  ${summary_zip_file_password}
    Unzip with password  ${the_downloaded_file}  ${summary_zip_file_password}  ${extract_dir}
    ${files}    OS.List Directory    ${extract_dir}
    List Should Contain Value    ${files}  ${expected_csv_file_name}

Verify ZIP File Not Found On SFTP Response Message
    [Documentation]    Verifies the API response for a "ZIP file not found on SFTP" error.
    ...    Checks if the response status code is 404 and the response body
    ...    contains the expected error message, description, and namespace.
    ...    *Arguments:*
    ...        * `${use_case_code}` - The use case code for which the ZIP file was not found.
    [Arguments]    ${use_case_code}
    ${expected_message}    Set Variable   data not found
    ${expected_description}    Set Variable   zip file of date ${year}-${month}-${day} use case ${use_case_code} not found
    ${expected_namespace}    Set Variable   etax
    Verify Error Response  ${expected_message}  ${expected_description}  ${expected_namespace}

Response header should be shown correctly
    [Documentation]    Verifies that the response header 'Content-Type' matches the expected content type and character set.
    [Arguments]    ${expected_content_type}  ${expected_charset}=${NONE}
    ${response_header}  Set Variable    ${response.headers}
    ${actual_content_type}  Set Variable  ${response_header['Content-Type']}
    ${actual_charset}  Set Variable  ${response_header['Content-Type']}
    Should Be Equal    ${actual_content_type}    ${expected_content_type}
    Should Be Equal    ${actual_charset}    ${expected_charset}

Verify the export csv content file match
    [Documentation]    Verifies that the content of the exported CSV file matches the expected content from a resource file.
    ...    This keyword assumes that the CSV file has been exported and the file path is available in the variable `${the_exported_download_file}`.
    ${the_exported_download_file}    OS.Get File    ${the_exported_download_file}
    ${expected_csv_content}    OS.Get File    ${CURDIR}/../resources/testdata/file/export.csv
    Validate downloaded file matches the expected file content   ${the_exported_download_file}     ${expected_csv_content}

Validate downloaded file matches the expected file content
    [Documentation]    This keyword will validate the downloaded file content with the expected file content.
    ...  It should be exactly the same.
   [Arguments]  ${expected_content_file}  ${actual_content_file}
   ${expected_list}=    Split String    ${expected_content_file}   \n
   ${actual_list}=    Split String    ${actual_content_file}   \n
   ${expected_list_length}  Get Length    ${expected_list}
   ${actual_list_length}  Get Length    ${actual_list}
    FOR    ${i}    IN RANGE    0    ${expected_list_length}
        ${expected_data}=  Set Variable  ${expected_list[${i}]}
        ${actual_data}=  Set Variable  ${actual_list[${i}]}
        log  ${expected_data}
        log  ${actual_data}
        ${actual_length}  Get Length    ${actual_data}
        ${expected_length}  Get Length    ${expected_data}
        log  ${actual_length}
        log  ${expected_length}
        Should Be Equal As Integers  ${expected_length}  ${actual_length}
        Should Match  ${expected_data}  ${actual_data}
    END