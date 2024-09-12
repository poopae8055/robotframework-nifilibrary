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
    [Tags]  GET_EnableSummaryReportUseCasesAPI  regression
    Given Generate expected response for get enable summary report use cases api
    When Send request to get enable summary report use cases api
    Then The http status should be '200'
    And Verify the response body matches the expected data

TC002 - Verify basic summary report - Success
    [Documentation]    Ensure the API returns a correct summary for the specified query parameters.
    [Tags]  SearchEnableSummaryReportAPI  regression
    [Setup]    Set Date With Subtraction From Current Date  1
    Given Insert transaction in ETAX_ETL_REPORT database when there is no any transaction in '${year}' '${month}' '${day}' for 'CO'
    Given Set date from to yesterday date with format YYYY-MM-DD
    And Set date to to yesterday date with format YYYY-MM-DD
    And Generate expected keywords for search enable summary report api for 'CO' and '20' page size number
    When Get Summary Report With Pagination  CO  20
    Then The http status should be '200'
    And Verify Response Lists Match

#TC003 - Verify pagination for summary report - Success
#    [Documentation]    Ensure the API correctly paginates the results.
#    [Tags]  SearchEnableSummaryReportAPI  regression
#    [Setup]    Set Date With Subtraction From Current Date  1
#    Given Insert transaction in ETAX_ETL_REPORT database when there is no any transaction in '${year}' '${month}' '${day}' for 'CO'
#    Given Set date from to yesterday date with format YYYY-MM-DD
#    And Set date to to yesterday date with format YYYY-MM-DD
##    And Generate expected keywords for search enable summary report api for 'CO' and '20' page size number
#    When Get Summary Report With Pagination  CO  20
##    Then The http status should be '200'
##    And Verify Response Lists Match
