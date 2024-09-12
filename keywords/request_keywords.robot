*** Settings ***
Resource        ../resources/imports.robot
Library            JSONLibrary
Library           OracleDBConnector
Library           RequestsLibrary

*** Keywords ***
Create request header
     [Documentation]    Creates a dictionary containing common request headers for JSON content.
    ${headers}    Create Dictionary    Content-Type=application/json
    Set Test Variable    ${headers}

Send GET request without query parameter
    [Arguments]    ${alias}  ${path}  ${headers}
    Create Session    ${alias}    ${etax_report_host}
    ${response}    GET On Session    ${alias}    ${path}    headers=${headers}
    Set Test Variable    ${response}

Send GET request with query parameter
    [Arguments]    ${alias}  ${path}  ${params}  ${headers}
    Create Session    ${alias}    ${etax_report_host}
    ${response}    GET On Session    ${alias}    ${path}    headers=${headers}  params=${params}
    Set Test Variable    ${response}

The http status should be '${expected_status_code}'
    [Documentation]    Verifies that the HTTP status code of the response matches the expected status code.
    ...    *Pre-condition: An HTTP request has been sent and a response object is available.*
    ...    ${expected_status_code} - The expected HTTP status code (e.g., 200, 400, 500).
    Should Be Equal As Integers    ${response.status_code}    ${expected_status_code}