*** Settings ***
Resource        ../keywords/api_keywords.robot
Resource        ../keywords/response_keywords.robot
Resource        ../keywords/database_keywords.robot
Resource        ../keywords/common_keywords.robot
Resource        ../resources/imports.robot
Library           OracleDBConnector

Suite Setup    Connect to etax database
Suite Teardown    Disconnect

*** Test Cases ***
TC001 - Verify API returns 200 and correct response body structure when call Get Enable Summary Report Use Cases API
    [Documentation]    To ensure the API returns a list of use cases with ENABLE_SUM_TO_REPORT = 'Y'.
    [Tags]  GET_EnableSummaryReportUseCasesAPI  regression
    Given Generate expected response for get enable summary report use cases api
    When Send request to get enable summary report use cases api
    Then The http status should be '200'
    And Verify the response body matches the expected data

TC002 - Verify basic summary report - Success
    [Documentation]    To ensure  the API returns a correct summary for the specified query parameters.
    [Tags]  SearchEnableSummaryReportAPI  regression
    [Setup]    Set Date With Subtraction From Current Date  1
    Given Insert transaction in ETAX_ETL_REPORT database when there is no any transaction in '${year}' '${month}' '${day}' for 'CO'
    Given Set date from to yesterday date with format YYYY-MM-DD
    And Set date to to yesterday date with format YYYY-MM-DD
    And Generate Expected Keywords For Search Enable Summary Report API  CO  20  ${TRUE}
    When Get Summary Report With Pagination  CO  20
    Then The http status should be '200'
    And Verify Response Lists Match

TC003 - Verify pagination for summary report - Success
    [Documentation]    To ensure the API correctly paginates the results.
    [Tags]  SearchEnableSummaryReportAPI  regression
    Given Set Date From to yesterday - 2
    And Set Date From to yesterday - 1
    Given Insert transaction in ETAX_ETL_REPORT database when there is no any transaction in '${year}' '${month}' '${day}' for 'CO'
    And Insert Transactions For Date Range If Not Exist  ${date_from}    ${date_to}    CO
    And Generate Expected Keywords For Search Enable Summary Report API  CO  3  ${TRUE}
    When Get Summary Report With Pagination  CO  3
    Then The http status should be '200'
    And Verify Response Lists Match

TC004 - Verify Summary Report with data more than three month
    [Documentation]  To verify Summary Report API accuracy with data spanning more than three months.
    [Tags]  SearchEnableSummaryReportAPI  regression
    Given Set Date From  2024  01  01
    And Set Date To  2024  01  02
    And Insert Transactions For Date Range If Not Exist  ${date_from}    ${date_to}    CO
    And Generate Expected Keywords For Search Enable Summary Report API  CO  20  ${FALSE}
    When Get Summary Report With Pagination  CO  20
    Then The http status should be '200'
    And Verify Response Lists Match

*** Keywords ***
Set Date From to yesterday - 2
    Set Date With Subtraction From Current Date  2
    Set Date From  ${year}  ${month}  ${day}

Set Date From to yesterday - 1
    Set Date With Subtraction From Current Date  1
    Set Date To  ${year}  ${month}  ${day}