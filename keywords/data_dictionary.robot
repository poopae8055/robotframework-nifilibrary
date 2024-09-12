*** Settings ***
Resource        ../resources/imports.robot

*** Keywords ***
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