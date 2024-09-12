*** Setting ***
Library            String
Library            Collections
Variables        configs/${env}/env_config.yaml
Resource         resource_url.robot

*** Variables ***
${env}            local    #  local, dev, staging