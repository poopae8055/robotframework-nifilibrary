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
TC_ETAXRP_00001 - Get Enabled Use Cases - Success
    [Documentation]    To verify API returns 200 and correct response body structure when call Get Enable Summary Report Use Cases API.
    [Tags]  GET_EnableSummaryReportUseCasesAPI  regression  success
    Given Generate expected response data for get enable summary report use cases api
    When Send request to get enable summary report use cases api
    Then The http status should be '200'
    And Verify the response body matches the expected data

TC_ETAXRP_00002 - Basic Summary Report - Success
    [Documentation]    To ensure  the API returns a correct summary for the specified query parameters.
    [Tags]  SearchEnableSummaryReportAPI  regression  success
    [Setup]    Set Date With Subtraction From Current Date  1
    Given Insert transaction in ETAX_ETL_REPORT database when there is no any transaction in '${year}' '${month}' '${day}' for 'CO'
    And Set date from to yesterday date with format YYYY-MM-DD
    And Set date to to yesterday date with format YYYY-MM-DD
    And Generate Expected Response Data For Search Enable Summary Report API  CO  20  ${TRUE}
    When Get Summary Report With Pagination  CO  20
    Then The http status should be '200'
    And Verify Response Lists Match

TC_ETAXRP_00003 - Pagination For Summary Report - Success
    [Documentation]    To ensure the API correctly paginates the results.
    [Tags]  SearchEnableSummaryReportAPI   regression  success
    Given Set Date From to yesterday - 2
    And Set Date From to yesterday - 1
    And Insert Transactions For Date Range If Not Exist  ${date_from}    ${date_to}    CO
    And Generate Expected Response Data For Search Enable Summary Report API  CO  3  ${TRUE}
    When Get Summary Report With Pagination  CO  3
    Then The http status should be '200'
    And Verify Response Lists Match

TC_ETAXRP_00004 - Summary Report with Data More Than Three Month - Success
    [Documentation]  To verify Summary Report API accuracy with data spanning more than three months.
    [Tags]  SearchEnableSummaryReportAPI  regression  success
    Given Set Date From  2024  01  01
    And Set Date To  2024  01  02
    And Insert Transactions For Date Range If Not Exist  ${date_from}    ${date_to}    CO
    And Generate Expected Response Data For Search Enable Summary Report API  CO  20  ${FALSE}
    When Get Summary Report With Pagination  CO  20
    Then The http status should be '200'
    And Verify Response Lists Match

TC_ETAXRP_00005 - Summary Report with Data Not Found - Fail
    [Documentation]  To ensure the API handles empty results gracefully.
    [Tags]  SearchEnableSummaryReportAPI  regression  fail
    Given Set Date From  2023  01  01
    And Set Date To  2023  01  01
    When Get Summary Report With Expected Error  CO  20
    Then The http status should be '404'
    And Verify Data Not Found Response Message  CO

TC_ETAXRP_00006 - Download Zip File - Success
    [Documentation]  To ensure the API successfully downloads a zip file for the specified parameters.
    [Tags]  SearchEnableSummaryReportAPI  regression  success
    [Setup]    Run Keywords    Login to sftp server
    ...  Delete Downloaded Files Folder If Exists
    Given Set date variable to '2024' '09' '13'
    And Upload File If Not Exists  CO  C
    When Download Zip File  2024-09-13  CO  C
    Then Extract and Verify CSV File Name Match
    [Teardown]    Run Keywords  Delete Downloaded Files Folder If Exists

TC_ETAXRP_00007 - Download Zip File with Data Not Found on SFTP - Fail
    [Documentation]  To ensure the API handles empty results gracefully.
    [Tags]  SearchEnableSummaryReportAPI  regression  fail
    [Setup]    Login to sftp server
    Given Set date variable to '2024' '09' '12'
    And Prepare the transaction with Mockup ZIP_FILE_PATH
    When Download Zip File With Expected Error  2024-09-12  CO  A
    Then The http status should be '404'
    And Verify ZIP File Not Found On SFTP Response Message  CO

TC_ETAXRP_00008 - Export Summary Report as CSV File - Success
    [Documentation]  To ensure the API successfully downloads a CSV file for the specified parameters.
    [Tags]  ExportSearchSummaryReportAsCSVAPI  regression  success
    [Setup]    Delete Downloaded Files Folder If Exists
    Given Set Date From  2024  02  29
    And Set Date To  2024  02  31
    When Send request to export summary report as csv file with  CO
    Then The http status should be '200'
    And  Response header should be shown correctly  text/csv
    And Verify the export csv content file match
    [Teardown]    Run Keywords  Delete Downloaded Files Folder If Exists

TC_ETAXRP_00009 - Export Summary Report as CSV File with Data Not Found - Fail
    [Documentation]    To ensure the API handles data not found gracefully.
    [Tags]  ExportSearchSummaryReportAsCSVAPI  regression  fail
    Given Set Date From  2023  02  29
    And Set Date To  2023  02  31
    When Send request to export summary report as csv file With Expected Error  CO
    Then The http status should be '404'
    And Verify Data Not Found Response Message  CO

*** Keywords ***
Prepare the transaction with Mockup ZIP_FILE_PATH
    [Documentation]    Prepares transactions for testing by deleting existing transactions for the date,
    ...    inserting default transactions, and then updating the ZIP_FILE_PATH to a mockup path.
    ...    This simulates a scenario where transactions exist in the database but the corresponding ZIP files are not found on the SFTP server,
    ...    leading to a 404 error.
    Delete Default Transactions For Date  CO
    Insert Default Transactions For Date  CO
    Update Default Transactions To Mockup ZIP_FILE_PATH  CO