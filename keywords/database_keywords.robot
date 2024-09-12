*** Settings ***
Resource        ../resources/imports.robot
Library           OracleDBConnector

*** Keywords ***
Connect to etax database
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