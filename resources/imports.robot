*** Settings ***
Library            String
Library            Collections
Library           OracleDBConnector
Variables       configs/${env}/env_config.yaml
Resource       ./resource_url.robot
Variables       ./common_config.yaml

*** Variables ***
${env}            local