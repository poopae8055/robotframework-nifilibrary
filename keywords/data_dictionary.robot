*** Settings ***
Resource        ../resources/imports.robot
Resource        ./common_keywords.robot

*** Keywords ***
Create data dictionary to insert transction to ETAX_ETL_REPORT
    [Arguments]    ${date}  ${use_case_code}
    ${year}  ${month}  ${day}  Split Date String    ${date}
    ${transactions}    Create List
    ${transaction}    Create Dictionary
    ...     date=${date}
    ...     use_case_code=${use_case_code}
     ...    total_amount=100.50
     ...    total_trans=5
     ...    doc_status=A
     ...    zip_file_path=${sftp.utiba_etax_report_relative_path}/${date}/TMN_CashOutCIMB_GeneratedTransactions_${year}${month}${day}.zip
    Append To List    ${transactions}    ${transaction}
    ${transaction}    Create Dictionary
     ...    date=${date}
     ...    use_case_code=${use_case_code}
     ...    total_amount=2010.99
     ...    total_trans=2000
     ...    doc_status=C
     ...    zip_file_path=${sftp.utiba_etax_report_relative_path}/${date}/TMN_CashOutCIMB_CanceledTransactions(withinday)_${year}${month}${day}.zip
    Append To List    ${transactions}    ${transaction}
    ${transaction}    Create Dictionary
    ...    date=${date}
    ...    use_case_code=${use_case_code}
    ...    total_amount=0.00
    ...    total_trans=0
    ...    doc_status=O
    ...    zip_file_path=${sftp.utiba_etax_report_relative_path}/${date}/TMN_CashOutCIMB_CanceledTransactions(others)_${year}${month}${day}.zip
    Append To List    ${transactions}    ${transaction}
    Set Test Variable    ${transactions}