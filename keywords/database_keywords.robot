*** Settings ***
Resource        ./data_dictionary.robot
Library           OracleDBConnector
Resource        ../resources/imports.robot

*** Keywords ***
Connect to etax database
    log  ${etax_database}
    ${conn}    OracleDBConnector.Connect    ${etax_database.username}    ${etax_database.password}    ${etax_database.url}
    Set Suite Variable    ${etax_database_conn}    ${conn}

Query etax transaction
    [Documentation]     It execute the given SQL query and return the results as a list of tuples
    [Arguments]    ${sql}
    ${query_results}    Query all    ${etax_database_conn}    ${sql}
    Log  \nQuery result\n${query_results}
    [Return]    ${query_results}

Run SQL action
    [Documentation]    Executes a given SQL query against the connected database.
    ...    *Pre-condition:* A database connection should be established beforehand.
    [Arguments]    ${sql}
    OracleDBConnector.Update    ${etax_database_conn}    ${sql}

Delete Transactions From ETAX ETL Report Database
    [Documentation]    Deletes transactions from the ETAX_ETL_REPORT database based on the provided date range and use case code.
    ...    *Pre-condition:* A database connection should be established beforehand.
    ...    ${date_from} - The start date of the transaction range to delete (format: YYYY-MM-DD).
    ...    ${date_to} - The end date of the transaction range to delete (format: YYYY-MM-DD).
    ...    ${use_case_code} - The use case code of the transactions to delete.
    [Arguments]    ${date_from}    ${date_to}    ${use_case_code}
    ${sql}    Set Variable    DELETE FROM ETAX_ETL.ETAX_ETL_REPORT eer WHERE eer.TRANS_DATE BETWEEN TO_DATE('${date_from} 00:00:00','YYYY-MM-DD HH24:MI:SS') AND TO_DATE('${date_to} 00:00:00','YYYY-MM-DD HH24:MI:SS') AND eer.USE_CASE_CODE='${use_case_code}'
    Run SQL Action    ${sql}

Get summary etax etl report Transactions From ETAX ETL Report Database By Date Range
    [Documentation]    Retrieves transactions for a specific use case from the ETAX_ETL_REPORT database based on the provided date range.
    ...    *Pre-condition:* A database connection should be established beforehand.
    ...    ${date_from} - The start date of the transaction range (format: YYYY-MM-DD).
    ...    ${date_to} - The end date of the transaction range (format: YYYY-MM-DD).
    ...    ${use_case_code} - The use case code of the transactions.
    [Arguments]    ${date_from}    ${date_to}    ${use_case_code}
    ${sql}    Set Variable    SELECT * FROM ETAX_ETL.ETAX_ETL_REPORT eer WHERE eer.TRANS_DATE BETWEEN TO_DATE('${date_from} 00:00:00','YYYY-MM-DD HH24:MI:SS') AND TO_DATE('${date_to} 00:00:00','YYYY-MM-DD HH24:MI:SS') AND eer.USE_CASE_CODE = '${use_case_code}' ORDER BY TRANS_DATE ASC, DOC_STATUS ASC
    ${query_results}    Query etax transaction    ${sql}
    [Return]    ${query_results}

Get Use Case Transactions From ETAX ETL Report Database By Date Range
    [Documentation]    Retrieves transactions for a specific use case from the ETAX_ETL_REPORT database based on the provided date range.
    ...    *Pre-condition:* A database connection should be established beforehand.
    ...    ${date_from} - The start date of the transaction range (format: YYYY-MM-DD).
    ...    ${date_to} - The end date of the transaction range (format: YYYY-MM-DD).
    ...    ${use_case_code} - The use case code of the transactions.
    [Arguments]    ${date_from}    ${date_to}    ${use_case_code}
    ${sql}    Set Variable    SELECT * FROM ETAX_ETL.ETAX_ETL_REPORT eer WHERE eer.TRANS_DATE BETWEEN TO_DATE('${date_from} 00:00:00','YYYY-MM-DD HH24:MI:SS') AND TO_DATE('${date_to} 00:00:00','YYYY-MM-DD HH24:MI:SS') AND eer.USE_CASE_CODE='${use_case_code}'
    ${query_results}    Query etax transaction    ${sql}
    [Return]    ${query_results}

Get Enabled Summary Use Cases From ETAX ETL Report Database
    [Documentation]    Retrieves a list of enabled summary use cases from the MS_USE_CASES table in the ETAX ETL Report Database.
    ...    *Pre-condition:* A database connection should be established beforehand.
    ...    *Returns:* A list of tuples, where each tuple represents a use case with its code and zip file prefix.
    ${query}    Set Variable    SELECT DISTINCT USE_CASE_CODE, ZIP_FILE_PREFIX FROM MS_USE_CASES WHERE ENABLE_SUM_TO_REPORT = 'Y' ORDER BY USE_CASE_CODE ASC
    ${query_results}    Query etax transaction    ${query}
    [Return]    ${query_results}

Get Use Cases File Prefix From ETAX ETL Report Database
    [Arguments]    ${use_case_code}
    ${query}    Set Variable    SELECT DISTINCT ZIP_FILE_PREFIX FROM MS_USE_CASES WHERE USE_CASE_CODE='${use_case_code}'
    ${query_results}    Query etax transaction    ${query}
    [Return]    ${query_results}

Insert transaction in ETAX_ETL_REPORT database when there is no any transaction in '${year}' '${month}' '${day}' for '${use_case_code}'
    [Documentation]    Inserts default transaction data into the ETAX_ETL_REPORT database for a specific date if no transactions exist for that date.
    ...    *Arguments:*
    ...        * `${year}` - The year (YYYY) of the date to check and insert transactions for.
    ...        * `${month}` - The month (MM) of the date.
    ...        * `${day}` - The day (DD) of the date.
    ${date}    Set Variable    ${year}-${month}-${day}
    ${count_transaction}    Check If Transaction Exists For Date    ${date}
    log  ${count_transaction}
    Run Keyword If    ${count_transaction} == False    Create data dictionary to insert transction to ETAX_ETL_REPORT  ${date}  ${use_case_code}
    Run Keyword If    ${count_transaction} == False    Insert Default Transactions For Date    ${transactions}

Check If Transaction Exists For Date
    [Documentation]    Checks if any transactions exist in the ETAX_ETL_REPORT database for a specific date.
    ...    *Arguments:*
    ...        * `${date}` - The date (YYYY-MM-DD) to check for transactions.
    [Arguments]    ${date}
    ${sql}    Set Variable    SELECT COUNT(*) AS TOTAL_TRANS FROM ETAX_ETL.ETAX_ETL_REPORT WHERE TRANS_DATE = TO_DATE('${date}', 'YYYY-MM-DD')
    ${query_results}    Query etax transaction    ${sql}
    ${count}    Set Variable    ${query_results[0]['TOTAL_TRANS']}
    Log    Count: ${count}
    ${flag}    Run Keyword If    ${count} != 0   Set Variable     True
    ...  ELSE  Set Variable     False
    log  ${flag}
    [Return]    ${flag}

Insert Default Transactions For Date
    [Documentation]    Inserts default transaction data into the ETAX_ETL_REPORT database for the date specified in the '${date}' variable.
    ...    *Arguments:*
    ...        * `${use_case_code}` - The use case code for the transactions.
    [Arguments]    ${use_case_code}
    Create data dictionary to insert transction to ETAX_ETL_REPORT  ${date}  ${use_case_code}
    log  ${transactions}
    FOR    ${transaction}    IN    @{transactions}
        ${sql}    Set Variable  INSERT INTO ETAX_ETL.ETAX_ETL_REPORT (TRANS_DATE, USE_CASE_CODE, TYPE, TOTAL_AMOUNT, TOTAL_TRANS, DOC_STATUS, ZIP_FILE_PATH, CREATED_DATE, CREATED_BY) VALUES (TO_DATE('${transaction.date}', 'YYYY-MM-DD'), '${transaction.use_case_code}', 'VAT', ${transaction.total_amount}, ${transaction.total_trans}, '${transaction.doc_status}', '${transaction.zip_file_path}',SYSDATE, 'robot_ereport')
        Run SQL action    ${sql}
    END

Insert Transactions For Date Range If Not Exist
    [Documentation]    Inserts default transaction data into the ETAX_ETL_REPORT database for a date range if no transactions exist for those dates.
    ...    *Arguments:*
    ...        * `${date_from}` - The start date of the range (YYYY-MM-DD).
    ...        * `${date_to}` - The end date of the range (YYYY-MM-DD).
    ...        * `${use_case_code}` - The use case code for the transactions.
    [Arguments]    ${date_from}    ${date_to}    ${use_case_code}
    ${date_from_datetime}    Convert Date    ${date_from}    result_format=%Y-%m-%d
    ${date_to_datetime}    Convert Date    ${date_to}    result_format=%Y-%m-%d
    WHILE    $date_from_datetime <= $date_to_datetime
        ${date_string}    Convert Date    ${date_from_datetime}    result_format=%Y-%m-%d
        ${count_transaction}    Check If Transaction Exists For Date    ${date_string}
        log  ${count_transaction}
        Run Keyword If    ${count_transaction} == False    Create data dictionary to insert transction to ETAX_ETL_REPORT  ${date_string}  ${use_case_code}
        Run Keyword If    ${count_transaction} == False    Insert Default Transactions For Date    ${transactions}
        ${date_from_datetime}    Add Time To Date    ${date_from_datetime}    1 day  result_format=%Y-%m-%d
    END

Delete Default Transactions For Date
    [Documentation]    Deletes transactions from ETAX_ETL_REPORT for a specific date and use case.
    ...    *Arguments:*
    ...        * `${use_case_code}` - The use case code of transactions to delete.
    [Arguments]    ${use_case_code}
    Create data dictionary to insert transction to ETAX_ETL_REPORT  ${date}  ${use_case_code}
    log  ${transactions}
    FOR    ${transaction}    IN    @{transactions}
        ${sql}    Set Variable  DELETE FROM ETAX_ETL.ETAX_ETL_REPORT eer WHERE TRANS_DATE=TO_DATE('${transaction.date}', 'YYYY-MM-DD') AND eer.USE_CASE_CODE = '${use_case_code}'
        Run SQL action    ${sql}
    END

Update Default Transactions To Mockup ZIP_FILE_PATH
    [Documentation]    Updates the ZIP_FILE_PATH column in the ETAX_ETL_REPORT table to a mockup path for testing purposes.
    ...    This keyword iterates through a list of transactions and updates the corresponding records in the database.
    ...    *Arguments:*
    ...        * `${use_case_code}` - The use case code of transactions to update.
    [Arguments]    ${use_case_code}
    log  ${transactions}
    Create data dictionary to insert transction to ETAX_ETL_REPORT  ${date}  ${use_case_code}
    log  ${transactions}
    FOR    ${transaction}    IN    @{transactions}
        ${sql}    Set Variable  UPDATE ETAX_ETL.ETAX_ETL_REPORT SET ZIP_FILE_PATH='${sftp.utiba_etax_report_relative_path}/${date}/test.zip' WHERE TRANS_DATE=TO_DATE('${transaction.date}', 'YYYY-MM-DD') AND USE_CASE_CODE = '${use_case_code}'
        Run SQL action    ${sql}
    END