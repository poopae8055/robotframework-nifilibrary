*** Settings ***
Library    NifiLibrary
Library    OperatingSystem

*** Variables ***
${base_url}   https://localhost:8443
${username}   test
${password}   A12345678901011
${file_filter_param}  filefiltername
${file_filter_name}  test.csv
${file_name_param}  filename
${file_name_value}  test_rename.csv
${rename_processor_group_id}  9db695ff-018b-1000-64fd-94990205f41a
${get_file_processor_id}  9db7073b-018b-1000-fcf2-aebaaddf59de
${rename_file_processor_id}  9db8e198-018b-1000-ef7d-e9086cd5908e
${put_file_processor_id}  9db92b00-018b-1000-07f2-69b36681a283
${parameter_context_id}  9dcace32-018b-1000-bb1e-812cafdbaeb8
${local_folder_path}  /Users/weerapornpaisingkhon/Documents/nifi/nifi_output

*** Test Cases ***
TC0001 Rename file - Success
    Get Nifi Token
    Stop Process Group  ${rename_processor_group_id}
    Update Parameter Value  ${parameter_context_id}  ${file_filter_param}  ${file_filter_name}
    Update Parameter Value  ${parameter_context_id}  ${file_name_param}  ${file_name_value}
    Start Processor  ${rename_file_processor_id}
    Start Processor  ${put_file_processor_id}
    Start Processor  ${get_file_processor_id}
    Stop Processor  ${get_file_processor_id}
    ${dic}  List Directory  ${local_folder_path}/
    Wait Until Keyword Succeeds  3x  5s  File Should Exist  ${local_folder_path}/${file_name_value}

