*** Settings ***
Library    NifiLibrary
Library    OperatingSystem
#Library    ../NifiLibrary/

*** Variables ***
${base_url}   https://localhost:8443
${username}   admin
${password}   admin1234567
${file_filter_param}  filefiltername
${file_filter_name}  test.csv
${file_name_param}  filename
${file_name_value}  test_rename.csv
${rename_processor_group_id}  9db695ff-018b-1000-64fd-94990205f41a
${get_file_processor_id}  9db7073b-018b-1000-fcf2-aebaaddf59de
${rename_file_processor_id}  9db8e198-018b-1000-ef7d-e9086cd5908e
${put_file_processor_id}  9db92b00-018b-1000-07f2-69b36681a283
${parameter_context_id}  9dcace32-018b-1000-bb1e-812cafdbaeb8
${rename_file_starter_id}  d5dec3b3-0190-1000-7c4d-5d58f55fdac0
${local_folder_path}  /Users/weerapornpaisingkhon/Documents/nifi/nifi_output

*** Test Cases ***
TC0001 Rename file - Success
    Get Nifi Token  ${base_url}  ${username}  ${password}
    Stop Process Group  ${rename_processor_group_id}
    Update Parameter Value With Stopped Component  ${parameter_context_id}  ${file_filter_param}  ${file_filter_name}
    Update Parameter Value With Stopped Component  ${parameter_context_id}  ${file_name_param}  ${file_name_value}
    Run Once Processor  ${rename_file_starter_id}
    ${dic}  List Directory  ${local_folder_path}/
    Wait Until Keyword Succeeds  3x  5s  File Should Exist  ${local_folder_path}/${file_name_value}

