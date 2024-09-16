*** Settings ***
Library            JSONLibrary
Library           OracleDBConnector
Library           RequestsLibrary
Resource        ../resources/imports.robot

*** Keywords ***
Create request header
     [Documentation]    Creates a dictionary containing common request headers for JSON content.
    ${headers}    Create Dictionary    Content-Type=application/json
    Set Test Variable    ${headers}

Send GET request without query parameter
    [Arguments]    ${alias}  ${path}  ${headers}
    Create Session    ${alias}    ${etax_report_host}
    ${response}    GET On Session    ${alias}    ${path}    headers=${headers}  expected_status=anything
    Set Test Variable    ${response}

Send GET request with query parameter
    [Arguments]    ${alias}  ${path}  ${params}  ${headers}
    Create Session    ${alias}    ${etax_report_host}
    ${response}    GET On Session      ${alias}    ${path}    headers=${headers}  params=${params}
    ...  expected_status=anything
    log  ${response}
    Set Test Variable    ${response}