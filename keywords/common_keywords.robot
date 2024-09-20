*** Settings ***
Library           DateTime
Library          OperatingSystem    WITH NAME    OS
Library          SSHLibrary    WITH NAME    SSH
Resource      ../resources/imports.robot
Resource      ./database_keywords.robot

*** Keywords ***
Set today date
    ${date}=    Get Current Date
    ${today_date}=    Convert Date    ${date}    result_format=%Y-%m-%d
    ${today_year}=    Convert Date    ${today_date}    result_format=%Y
    ${today_month}=    Convert Date    ${today_date}    result_format=%m
    ${today_day}=    Convert Date    ${today_date}    result_format=%d
    Set Suite Variable    ${year}    ${today_year}
    Set Suite Variable    ${month}   ${today_month}
    Set Suite Variable    ${day}    ${today_day}
    Set Suite Variable    ${date}

Set Date With Subtraction From Current Date
    [Documentation]    Calculates a date by subtracting a specified number of days from the current date and sets date components as suite variables.
    ...    *Arguments:*
    ...        * `${subtract_date}` - The number of days to subtract from the current date.
    [Arguments]    ${subtract_date}
    ${date}=    Get Current Date
    ${date_subtract}=    Subtract Time From Date    ${date}    ${subtract_date} days
    ${date}=    Convert Date    ${date_subtract}    result_format=%Y-%m-%d
    ${year}=    Convert Date    ${date_subtract}    result_format=%Y
    ${month}=    Convert Date    ${date_subtract}    result_format=%m
    ${day}=    Convert Date    ${date_subtract}    result_format=%d
    Set Suite Variable    ${date}    ${date}
    Set Suite Variable    ${year}    ${year}
    Set Suite Variable    ${month}    ${month}
    Set Suite Variable    ${day}    ${day}

Set date variable to '${year}' '${month}' '${day}'
    Set Suite Variable    ${year}
    Set Suite Variable    ${month}
    Set Suite Variable    ${day}
    Set Suite Variable    ${date}  ${year}-${month}-${day}

Set date from to today date with format YYYY-MM-DD
    Set today date
    Set Suite Variable    ${date_from}    ${date}

Set date to to today date with format YYYY-MM-DD
    Set today date
    Set Suite Variable    ${date_to}    ${date}

Set date from to yesterday date with format YYYY-MM-DD
    [Documentation]    Sets the suite variable `${date_from}` to yesterday's date in YYYY-MM-DD format.
    Set Date With Subtraction From Current Date  1
    Set Suite Variable    ${date_from}    ${date}

Set date to to yesterday date with format YYYY-MM-DD
    [Documentation]    Sets the suite variable `${date_to}` to yesterday's date in YYYY-MM-DD format.
    Set Date With Subtraction From Current Date  1
    Set Suite Variable    ${date_to}    ${date}

Set Date From With Subtraction From Current Date
    [Documentation]    Calculates a date by subtracting a specified number of days from the current date, formats it as YYYY-MM-DD, and sets it to the `${date_to}` variable.
    ...    *Arguments:*
    ...        * `${num}` - The number of days to subtract from the current date.
    [Arguments]    ${num}
    Set Date With Subtraction From Current Date  ${num}
    Set Suite Variable    ${date_from}    ${date}

Set Date To With Subtraction From Current Date
    [Documentation]    Calculates a date by subtracting a specified number of days from the current date, formats it as YYYY-MM-DD, and sets it to the `${date_to}` variable.
    ...    *Arguments:*
    ...        * `${num}` - The number of days to subtract from the current date.
    [Arguments]    ${num}
    Set Date With Subtraction From Current Date  ${num}
    Set Suite Variable    ${date_to}    ${date}

Set Date From
    [Documentation]    Sets the suite variable `${date_from}` to a specific date in YYYY-MM-DD format.
    ...    *Arguments:*
    ...        * `${year}` - The year (YYYY).
    ...        * `${month}` - The month (MM).
    ...        * `${day}` - The day (DD).
    [Arguments]    ${year}    ${month}    ${day}
    Set Suite Variable    ${date_from}    ${year}-${month}-${day}

Set Date To
    [Documentation]    Sets the suite variable `${date_to}` to a specific date in YYYY-MM-DD format.
    ...    *Arguments:*
    ...        * `${year}` - The year (YYYY).
    ...        * `${month}` - The month (MM).
    ...        * `${day}` - The day (DD).
    [Arguments]    ${year}    ${month}    ${day}
    Set Suite Variable    ${date_to}    ${year}-${month}-${day}

Set Document Description
    [Documentation]    Sets a variable with a description based on the document status.
    [Arguments]    ${doc_status}
    ${description}    Set Variable If    '${doc_status}' == 'A'    Generated transactions (Not include canceled)
    ...    '${doc_status}' == 'C'    Canceled transactions (Within transaction date)
    ...    Canceled transactions (Not within transaction date / Others)
    RETURN    ${description}

Set ETAX ETL Report File Infix
    [Documentation]    Sets the file infix based on the document status.
    [Arguments]    ${doc_status}
    ${file_infix}    Set Variable If    '${doc_status}' == 'A'    GeneratedTransactions
    ...    '${doc_status}' == 'C'    CanceledTransactions\(withinday\)
    ...    CanceledTransactions\(others\)
    RETURN    ${file_infix}

Split Date String
    [Documentation]  Splits a date string in YYYY-MM-DD format into year, month, and day variables.
    [Arguments]    ${date_string}
    ${year}    Set Variable    ${date_string.split('-')[0]}
    ${month}   Set Variable    ${date_string.split('-')[1]}
    ${day}    Set Variable    ${date_string.split('-')[2]}
    RETURN    ${year}  ${month}  ${day}

Set Date From to yesterday - 2
    Set Date With Subtraction From Current Date  2
    Set Date From  ${year}  ${month}  ${day}

Set Date From to yesterday - 1
    Set Date With Subtraction From Current Date  1
    Set Date To  ${year}  ${month}  ${day}



