*** Settings ***
Library    NifiLibrary   WITH NAME    NF
Library    OperatingSystem
Library    ../NifiLibrary/     WITH NAME    NF
Library          SeleniumLibrary
Library         OperatingSystem    WITH NAME    OS

*** Variables ***
#${base_url}   https://localhost:8443
${base_url}   https://nifi-gateway-qa.private-thn.ascendmoney.io
#${username}   admin
#${password}   admin1234567
${username}   nifi-robot
${password}   @Welcome2
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

*** Keywords ***
Open nifi Web page
    ${userAgent}=  set variable  --user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    --start-maximized
    Call Method    ${chrome_options}    add_argument    --headless
    Call Method    ${chrome_options}    add_argument    disable-gpu
    Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
    Call Method    ${chrome_options}    add_argument    ${userAgent}
    Call Method    ${chrome_options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    options=${chrome_options}
    go to  ${base_url}
    Wait until page contains  Sign in  40s
    Wait until element is visible   id=username   40s
    Login nifi

Login nifi
    input text  id=username    ${username}
    input text  name=password    ${password}
    Click button    id=kc-login
    Wait until page contains  Process Group    40s

Get access token
    ${cookie} =	Get Cookie	__Secure-Authorization-Bearer
    log  ${cookie.value}
    Set suite variable  ${nifi_token}  ${cookie.value}

Trigger schedule to summary etax data report
    Get Access Token
    #stop the processors that use the parameter we would like to update before updating them.
    Update all processor group to use same parameter context  ${nifi.dev_param_context_id}
    #update parameter value to the set date value
    Update parameter  ${nifi.dev_param_context_id}  date_manual  ${year}${month}${day}
    Update 'Manual run query doc status' processor state to 'RUN_ONCE'

*** Test Cases ***
#TC0001 Rename file - Success
#    Open nifi Web page
#    Get access token
#    NF.Set Nifi Access Token    nifi-gateway-qa.private-thn.ascendmoney.io  443  ${nifi_token}
#    ${resp}  NF.Update Parameter Value Without Stopped Component     f5ea2134-0184-1000-ec16-b45e6aabdb83  date_manual  20250106
#    Run Once Processor  9b78c4dc-cb4b-3f04-2bc3-6761487ee6ee  true
#    Close All Browsers

TC0001 Rename file - Success
    NF.Create Nifi Session    localhost  8443  admin  admin1234567
    #update parameter context of root to use automate
    NF.Update Process Group Parameter Context  root  182b103a-0192-1000-6b6a-5f6dc7a3bc90
    #update parameter value
    NF.Update Parameter Value With Stopped Component  182b103a-0192-1000-6b6a-5f6dc7a3bc90  change_name  new_name.txt
    #Triger flow
    NF.Stop Process Group  d5dec3b3-0190-1000-7c4d-5d58f55fdac0
    NF.Start Process Group  d5dec3b3-0190-1000-7c4d-5d58f55fdac0
    NF.Stop Process Group  d5dec3b3-0190-1000-7c4d-5d58f55fdac0
    #Verify the result
    OS.File Should Not Exist    ${expected_file_path}
