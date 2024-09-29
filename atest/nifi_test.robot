*** Settings ***
Library    NifiLibrary   WITH NAME    NF
Library   SeleniumLibrary
Library   OperatingSystem    WITH NAME    OS
Library   RequestsLibrary
Library   Collections

*** Variables ***
${host}  localhost
${port}  8443
${username}  admin
${password}  admin1234567
${expected_file_path}   ${CURDIR}${/}../../../Documents/test_rename
${expected_file}  new_name.txt
${get_file_processor_id}  d5dec3b3-0190-1000-7c4d-5d58f55fdac0
${automate_parameter_context_id}  182b103a-0192-1000-6b6a-5f6dc7a3bc90

*** Test Cases ***
TC0001 Rename file - Success
    NF.Create Nifi Session    ${host}  ${port}  ${username}  ${password}
    #update parameter value
    NF.Update Parameter Value With Stopped Component  ${automate_parameter_context_id}  change_name  ${expected_file}
    #update parameter context of root to use automate
    NF.Update Process Group Parameter Context  d5482ad2-0190-1000-199b-8696a8e7e5b4  ${automate_parameter_context_id}
    #Triger flow
    NF.Stop Processor  ${get_file_processor_id}
    NF.Start Processor  ${get_file_processor_id}
    NF.Stop Processor  ${get_file_processor_id}
    #Verify the result
    OS.File Should Exist    ${expected_file_path}${expected_file}
