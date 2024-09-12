*** Settings ***
Resource        ../resources/imports.robot
Library            JSONLibrary
Library           OracleDBConnector
Library           RequestsLibrary

*** Keywords ***
Verify the response body matches the expected data
        [Documentation]    Verifies that the actual JSON response body matches the expected JSON data.
    ...    *Pre-condition:  An HTTP request has been sent and a response object is available.
    ...    * The expected JSON data is stored in the `${expected_json}` variable.
     ...    ${expected_json} - The expected JSON data as a dictionary or list.
     log  ${response.json()}
     log  ${expected_json}
    Should Be Equal    ${response.json()}    ${expected_json}

Verify Response Lists Match
    [Documentation]    Verifies that two response lists match, taking into account pagination.
    ...    This keyword assumes that both lists contain dictionaries representing paginated responses.
#    [Arguments]    ${expected_response_list_all_pages}    ${actual_response_list_all_pages}
    ${list_length}    Get Length    ${expected_response_list_all_pages}
    Should Be Equal    ${list_length}    ${actual_response_list_all_pages.__len__()}    msg=The number of pages in the expected and actual responses do not match.
    FOR    ${index}    IN RANGE    ${list_length}
        ${expected_response}    Set Variable    ${expected_response_list_all_pages}[${index}]
        ${actual_response}    Set Variable    ${actual_response_list_all_pages}[${index}]
        log  ${actual_response}
        log  ${expected_response}
        Dictionaries Should Be Equal    ${expected_response}    ${actual_response}    msg=Response data for page ${index + 1} does not match.
    END