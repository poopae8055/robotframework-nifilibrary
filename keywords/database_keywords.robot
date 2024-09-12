*** Settings ***
Resource        ../resources/imports.robot
Library           OracleDBConnector

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
    ${count_transaction}    Run Keyword And Return Status    Check If Transaction Exists For Date    ${date}
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
    Run Keyword If    ${count} > 0    Return From Keyword    True
    Return From Keyword    False

Insert Default Transactions For Date
    [Documentation]    Inserts default transaction data into the ETAX_ETL_REPORT database for a specific date.
    ...    *Arguments:*
    ...        * `${transactions}` - A list of dictionaries, where each dictionary represents a transaction 
    ...          and contains the following keys:
    ...            - `date`: The transaction date (YYYY-MM-DD).
    ...            - `use_case_code`: The use case code.
    ...            - `total_amount`: The total amount.
    ...            - `total_trans`: The total number of transactions.
    ...            - `doc_status`: The document status (A, C, or O).
    [Arguments]    ${transactions}
    log  ${transactions}
    FOR    ${transaction}    IN    @{transactions}
        log  ${transaction}
        log  ${transaction.date}
        log  ${transaction.use_case_code}
        log  ${transaction.total_amount}
        log  ${transaction.total_trans}
        ${sql}    Set Variable  INSERT INTO ETAX_ETL.ETAX_ETL_REPORT (TRANS_DATE, USE_CASE_CODE, TYPE, TOTAL_AMOUNT, TOTAL_TRANS, DOC_STATUS, CREATED_DATE, CREATED_BY) VALUES (TO_DATE('${transaction.date}', 'YYYY-MM-DD'), '${transaction.use_case_code}', 'VAT', ${transaction.total_amount}, ${transaction.total_trans}, '${transaction.doc_status}', SYSDATE, 'etax-etl')
        Run SQL action    ${sql}
    END

Create data dictionary to insert transction to ETAX_ETL_REPORT
    [Arguments]    ${date}  ${use_case_code}
    ${transactions}    Create List
    ${transaction}    Create Dictionary
    ...    date=${date}
    ...    use_case_code=${use_case_code}
     ...    total_amount=100.50
     ...    total_trans=5
     ...    doc_status=A
    Append To List    ${transactions}    ${transaction}
    ${transaction}    Create Dictionary
     ...    date=${date}
     ...    use_case_code=${use_case_code}
     ...    total_amount=200.00
     ...    total_trans=2
     ...    doc_status=C
    Append To List    ${transactions}    ${transaction}
    ${transaction}    Create Dictionary
    ...    date=${date}
    ...    use_case_code=${use_case_code}
    ...    total_amount=0.00
    ...    total_trans=0
    ...    doc_status=O
    Append To List    ${transactions}    ${transaction}
    Set Test Variable    ${transactions}