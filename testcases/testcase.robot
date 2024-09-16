*** Settings ***
Resource        ../keywords/api_keywords.robot
Resource        ../keywords/verify_keywords.robot
Resource        ../keywords/database_keywords.robot
Resource        ../keywords/common_keywords.robot
Resource        ../keywords/file_operation_keywords.robot
Resource        ../resources/imports.robot
Library           OracleDBConnector
Library          OperatingSystem
Library  String

Suite Setup    Connect to etax database
Suite Teardown    Disconnect

*** Test Cases ***
TC001 - Get Enabled Use Cases - Success
    [Documentation]    To verify API returns 200 and correct response body structure when call Get Enable Summary Report Use Cases API.
    [Tags]  GET_EnableSummaryReportUseCasesAPI  regression  success
    Given Generate expected response for get enable summary report use cases api
    When Send request to get enable summary report use cases api
    Then The http status should be '200'
    And Verify the response body matches the expected data

TC002 - Basic summary report - Success
    [Documentation]    To ensure  the API returns a correct summary for the specified query parameters.
    [Tags]  SearchEnableSummaryReportAPI  regression  success
    [Setup]    Set Date With Subtraction From Current Date  1
    Given Insert transaction in ETAX_ETL_REPORT database when there is no any transaction in '${year}' '${month}' '${day}' for 'CO'
    And Set date from to yesterday date with format YYYY-MM-DD
    And Set date to to yesterday date with format YYYY-MM-DD
    And Generate Expected Keywords For Search Enable Summary Report API  CO  20  ${TRUE}
    When Get Summary Report With Pagination  CO  20
    Then The http status should be '200'
    And Verify Response Lists Match

TC003 - Pagination for summary report - Success
    [Documentation]    To ensure the API correctly paginates the results.
    [Tags]  SearchEnableSummaryReportAPI   regression  success
    Given Set Date From to yesterday - 2
    And Set Date From to yesterday - 1
    Given Insert Transactions For Date Range If Not Exist  ${date_from}    ${date_to}    CO
    And Generate Expected Keywords For Search Enable Summary Report API  CO  3  ${TRUE}
    When Get Summary Report With Pagination  CO  3
    Then The http status should be '200'
    And Verify Response Lists Match

TC004 - Summary Report with data more than three month - Success
    [Documentation]  To verify Summary Report API accuracy with data spanning more than three months.
    [Tags]  SearchEnableSummaryReportAPI  regression  success
    Given Set Date From  2024  01  01
    And Set Date To  2024  01  02
    And Insert Transactions For Date Range If Not Exist  ${date_from}    ${date_to}    CO
    And Generate Expected Keywords For Search Enable Summary Report API  CO  20  ${FALSE}
    When Get Summary Report With Pagination  CO  20
    Then The http status should be '200'
    And Verify Response Lists Match

TC005 - Summary Report with no result data - Fail
    [Documentation]  To ensure the API handles empty results gracefully.
    [Tags]  SearchEnableSummaryReportAPI  regression  fail
    Given Set Date From  2023  01  01
    And Set Date To  2023  01  01
    When Get Summary Report With Expected Error  CO  20
    Then The http status should be '404'
    And Verify Data Not Found Response Message  CO

TC006 - Download zip file - Success
    [Documentation]  To ensure the API successfully downloads a zip file for the specified parameters.
    [Tags]  SearchEnableSummaryReportAPI  regression  success
    [Setup]    Login to sftp server
    Given Delete Downloaded Files Folder If Exists
    And Set date variable to '2024' '09' '13'
    And Upload File If Not Exists  CO  C
    When Download Zip File  2024-09-13  CO  C
    Then Verify the extract csv file match
    [Teardown]    Run Keywords  Delete Downloaded Files Folder If Exists

TC006 - Download zip file with no data found on SFTP - Fail
    [Documentation]  To ensure the API handles empty results gracefully.
    [Tags]  SearchEnableSummaryReportAPI  regression  fail
    [Setup]    Login to sftp server
    Given Set date variable to '2024' '09' '12'
    And Prepare the transaction with Mockup ZIP_FILE_PATH
    When Download Zip File With Expected Error  2024-09-12  CO  A
    Then The http status should be '404'
    And Verify ZIP File Not Found On SFTP Response Message  CO

*** Keywords ***
Prepare the transaction with Mockup ZIP_FILE_PATH
    Delete Default Transactions For Date  CO
    Insert Default Transactions For Date  CO
    Update Default Transactions To Mockup ZIP_FILE_PATH  CO