*** Settings ***
Resource        ./request_keywords.robot
#Resource        ./response_keywords.robot
Resource        ./database_keywords.robot
Library            JSONLibrary
Library           RequestsLibrary

*** Keywords ***
Generate expected response for get enable summary report use cases api
    [Documentation]     retrieves active use cases from a database, constructs an expected JSON response containing those use cases,
    ...  and prepares to test an API related to "etax transactions".
    ${query_results}    Get Enabled Summary Use Cases From ETAX ETL Report Database
    ${usecases}    Create List
    FOR    ${index}    IN RANGE    len(${query_results})
        Log To Console   ${query_results[${index}]}
        ${usecase}    Create Dictionary
        ...  useCaseCode=${query_results[${index}]['USE_CASE_CODE']}
        ...  useCaseName=${query_results[${index}]['ZIP_FILE_PREFIX']}
        Append To List    ${usecases}    ${usecase}
   END
    ${expected_status}    Create Dictionary    message=Success    description=Success    namespace=etax
    ${expected_json}    Create Dictionary    status=${expected_status}    usecases=${usecases}
    Log  \nExpected JSON Response:\n${expected_json}
    Set Test Variable    ${expected_json}

Send request to get enable summary report use cases api
    Create request header
    Send GET request without query parameter  alias=etax  path=${get_enable_summary_report_use_cases_path}  headers=${headers}

Get Summary Report With Pagination
    [Documentation]    Sends a GET request to the Summary Report API with pagination.
    ...    Loops through all pages and logs the response for each page.
    ...    Requires the following arguments:
    ...        - useCaseCode: The use case code for the report.
    ...        - pageSize: The number of records per page.
    [Arguments]    ${useCaseCode}    ${pageSize}
    Create request header
    # Create the dictionary with initial values (pageNumber will be updated in the loop)
    ${query_parameters_with_the_first_page}    Create Dictionary    dateFrom=${date_from}    dateTo=${date_to}    useCaseCode=${useCaseCode}    pageSize=${pageSize}  pageNumber=1

    # Initial request to get total pages (you can keep this part)
    Send GET request with query parameter  etax  ${search_enable_summary_report_path}  ${query_parameters_with_the_first_page}  ${headers}
    ${total_pages}    Set Variable    ${response.json()['pageMetadata']['totalPages']}
    Log    Total Pages: ${total_pages}

    ${query_parameters}    Create Dictionary    dateFrom=${date_from}    dateTo=${date_to}    useCaseCode=${useCaseCode}    pageSize=${pageSize}
    ${actual_response_list_all_pages}    Create List
    # Loop through all pages
    log  ${actual_response_list_all_pages}
    FOR    ${page_number}    IN RANGE    1    ${total_pages} + 1
        # Dynamically update the pageNumber in the query parameters
        Set To Dictionary    ${query_parameters}    pageNumber=${page_number}
        log  ${actual_response_list_all_pages}
        Send GET request with query parameter  etax  ${search_enable_summary_report_path}  ${query_parameters}  ${headers}
        Log  \nResponse for Page ${page_number}:\n${response.json()}
        Append To List    ${actual_response_list_all_pages}  ${response.json()}
        log  ${actual_response_list_all_pages}
    END
    log  ${actual_response_list_all_pages}
    Set Test Variable    ${actual_response_list_all_pages}

Generate Expected Keywords For Search Enable Summary Report API
    [Documentation]    Generates the expected JSON response for the Search Enable Summary Report API.
    ...    * This keyword assumes you have already set the following suite variables:
    ...        * `${date_from}` - The start date of the report range (format: YYYY-MM-DD).
    ...        * `${date_to}` - The end date of the report range (format: YYYY-MM-DD).
    ...        * `${use_case_code}` - The use case code for the report.
    ...        * `${include_doc_status}` - Boolean flag to include or exclude 'docStatus' in the expected response.
    [Arguments]    ${use_case_code}  ${page_size}  ${include_doc_status}
    ${query_results}    Get Summary Etax ETL Report Transactions From ETAX ETL Report Database By Date Range  ${date_from}    ${date_to}    ${use_case_code}
    log  ${query_results}
    ${query_usecase_results}    Get Use Cases File Prefix From ETAX ETL Report Database  ${use_case_code}
    ${useCase}    Set Variable  ${query_usecase_results[0]['ZIP_FILE_PREFIX']}
    log  ${query_usecase_results}
    ${page_size}    Set Variable    ${page_size}
    ${total_elements}    Get Length    ${query_results}
    ${total_pages}    Evaluate    math.ceil(${total_elements} / ${page_size})
    log  ${total_pages}
    ${expected_response_list_all_pages}    Create List

    FOR    ${page_number}    IN RANGE    1    ${total_pages} + 1
        ${start_index}    Evaluate    (${page_number} - 1) * ${page_size}
        ${end_index}    Evaluate    ${page_number} * ${page_size}
        ${page_data}    Get Slice From List    ${query_results}    ${start_index}    ${end_index}

        # Create data list for the current page
        ${data}    Create List
        FOR    ${trans}    IN    @{page_data}
            ${trans_date}    Convert Date    ${trans['TRANS_DATE']}    result_format=%d/%m/%Y
            ${total_amount}    Set Variable    0.00
            ${total_transactions}    Set Variable    0
            ${total_amount}    Evaluate    ${total_amount} + ${trans['TOTAL_AMOUNT']}
            ${total_transactions}    Set Variable    ${trans['TOTAL_TRANS']}
            ${documentDescription}=    Run Keyword If    '${trans['DOC_STATUS']}' == 'A'    Set Variable    Generated transactions (Not include canceled)
            ...   ELSE IF    '${trans['DOC_STATUS']}' == 'C'    Set Variable    Canceled transactions (Within transaction date)
            ...   ELSE    Set Variable    Canceled transactions (Not within transaction date / Others)

            ${total_amount_formatted}=  Evaluate  "%.2f" % ${total_amount}

            ${data_entry}    Create Dictionary
            ...    transDate=${trans_date}
            ...    useCase=${useCase}
            ...    type=${trans['TYPE']}
            ...    documentDescription=${documentDescription}
            ...    totalAmount=${total_amount_formatted}
            ...    totalTransactions=${total_transactions}
            ...    useCaseCode=${use_case_code}

            Run Keyword If    ${include_doc_status}    Set To Dictionary    ${data_entry}    docStatus=${trans['DOC_STATUS']}
            ...    ELSE    Set To Dictionary    ${data_entry}    docStatus=${NONE}

            Append To List    ${data}    ${data_entry}
        END

        # Create the expected JSON response structure for the current page
        ${expected_status}    Create Dictionary    message=Success    description=Success    namespace=etax
        ${page_size_int}    Convert To Integer    ${page_size}
        ${page_metadata}    Create Dictionary    size=${page_size_int}    totalElements=${total_elements}    totalPages=${total_pages}    number=${page_number}
        ${expected_json}    Create Dictionary    status=${expected_status}    data=${data}    pageMetadata=${page_metadata}
        Log  \nExpected JSON Response for Page ${page_number}:\n${expected_json}
        Append To List    ${expected_response_list_all_pages}  ${expected_json}
    END
    log  ${expected_response_list_all_pages}
    Set Test Variable    ${expected_response_list_all_pages}