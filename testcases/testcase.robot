*** Settings ***
Resource        ../keywords/api_keywords.robot
Resource        ../keywords/response_keywords.robot
Resource        ../keywords/database_keywords.robot
Resource        ../keywords/common_keywords.robot
Resource        ../resources/imports.robot
Library           OracleDBConnector

Suite Setup    Connect to etax database

*** Test Cases ***
TC001 - Verify API returns 200 and correct response body structure when call Get Enable Summary Report Use Cases API
    [Tags]  GET_EnableSummaryReportUseCasesAPI  HappyPath
    Given Generate expected response for get enable summary report use cases api
    When Send request to get enable summary report use cases api
    Then The http status should be '200'
    And Verify the response body matches the expected data

TC002 - Verify API returns 200 and correct kaywords body structure when call Search Enable Summary Report API with valid request
    [Tags]  SearchEnableSummaryReportAPI  HappyPath
#    [Setup]    Insert transaction in database when there is no any transaction in yesterday date
    Given Set date from to yesterday date with format YYYY-MM-DD
    And Set date to to yesterday date with format YYYY-MM-DD
    And Get Summary Report With Pagination  CO  2
    And Generate expected keywords for search enable summary report api for 'CO' and '2' page size number
    Then The http status should be '200'
    And Verify Response Lists Match
