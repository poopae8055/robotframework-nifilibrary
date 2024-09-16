*** Settings ***
Resource        ../resources/imports.robot
Resource        ./common_keywords.robot
Library          OperatingSystem    WITH NAME    OS
Library          SSHLibrary    WITH NAME    SSH

*** Keywords ***
Login to sftp server
    SSH.Open Connection    ${sftp.host}  alias=etax_sftp_server
    SSH.Login    ${sftp.username}    ${sftp.password}

Refresh directory
    [Arguments]  ${file_directory}
    SSH.List Directory  ${file_directory}
    ${pwd}=    SSH.Execute Command   pwd

Upload File If Not Exists
    [Documentation]    Uploads a file to the SFTP server if it doesn't already exist.
    ...    *Arguments:*
    ...        * `${use_case_code}` - The use case code to determine the file prefix.
    ...        * `${doc_status}` - The document status to determine the file infix.
    [Arguments]    ${use_case_code}  ${doc_status}

    ${file_infix}    Set ETAX ETL Report File Infix    ${doc_status}
    ${query_usecase_results}    Get Use Cases File Prefix From ETAX ETL Report Database  ${use_case_code}
    ${use_case_name}    Set Variable    ${query_usecase_results[0]['ZIP_FILE_PREFIX']}
    ${year}  ${month}  ${day}    Split Date String    ${date}
    ${file_name}    Set Variable    TMN_${use_case_name}_${file_infix}_${year}${month}${day}.zip
    ${local_file}    Set Variable    ${EXECDIR}${/}/resources/testdata/file/UtibaETaxReport/${year}-${month}-${day}/${file_name}
    ${remote_file}    Set Variable    ${sftp.utiba_etax_report_relative_path}${use_case_name}/${date}/${file_name}

    ${exists}    Run Keyword And Return Status    SSH.File Should Exist    ${remote_file}
    Run Keyword If    not ${exists}    SSH.Put File    ${local_file}    ${remote_file}
    Wait Until Keyword Succeeds    5x  5s    SSH.File Should Exist    ${remote_file}

Download file
    [Arguments]    ${file_path}  ${response_content}
    Create Binary File    ${file_path}    ${response_content}

Delete Downloaded Files Folder If Exists
    [Documentation]    Deletes the 'downloaded_files' folder if it exists.
    ${folders}    OS.List Directory    ${EXECDIR}
    log  ${folders}
    ${downloaded_files_folder_exists}    Run Keyword And Return Status    List Should Contain Value    ${folders}    downloaded_files
    Run Keyword If    ${downloaded_files_folder_exists}    OS.Remove Directory    ${EXECDIR}${/}downloaded_files    recursive=True
    Wait Until Keyword Succeeds    5x  5s  Should Not Exist  ${EXECDIR}${/}downloaded_files
    ${folders}    OS.List Directory    ${EXECDIR}
    log  ${folders}