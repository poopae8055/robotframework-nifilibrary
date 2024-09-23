from robot.api import logger
from robot.api.deco import keyword
import nipyapi
from time import sleep
from .version import VERSION

__version__ = VERSION

class NifiLibraryKeywords(object):
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    # disable TLS check, do at your own risk
    nipyapi.config.nifi_config.verify_ssl = False
    nipyapi.config.registry_config.verify_ssl = False

    def __init__(self):
        self._endpoint = None
        self._accessToken = None

    @keyword('Connect To Nifi')
    def connect_to_nifi(self, base_url=None, username=None, password=None, return_response=False):
        """
        Connect to NiFi and obtain an access token.

        Arguments
            - base_url (str): NiFi domain (e.g., 'https://localhost:8443')
            - username (str): NiFi username
            - password (str): NiFi password
            - return_response (bool, optional): True to return token, False to return None. Defaults to False.
            Returns:
            - access_token: The obtained access token

        Examples
        | Connect To Nifi |  https://localhost:8443 | ${username} | ${password} |

        """
        if not base_url or not username or not password:
            raise Exception('Require parameters cannot not be none')
        # connect to Nifi
        self._endpoint = nipyapi.utils.set_endpoint(f"{base_url}/nifi-api/")
        try:
            # Create an access token
            self._accessToken = nipyapi.nifi.apis.access_api.AccessApi(
                api_client=nipyapi.config.nifi_config.api_client).create_access_token(
                username=username,
                password=password
            )
            # Set the service auth token
            nipyapi.security.set_service_auth_token(token=self._accessToken, token_name='tokenAuth', service='nifi')
            if return_response:
                return self._accessToken
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Set Access Token')
    def set_service_auth_token(self, access_token=None, return_response=False):
        """
        Connect to NiFi and set the service authentication token.

        Arguments
        - access_token (str): The authentication token to be set.
        - return_response (bool, optional): Boolean flag to indicate if the kaywords should be returned. Default is False.

        Returns
        - If return_response is True, returns the kaywords from setting the service auth token.

        Examples
        | Set Access Token |  ${token} |
        """
        if not access_token:
            raise Exception('Require parameters cannot not be none')
        try:
            # Set the service auth token
            response = nipyapi.security.set_service_auth_token(token=access_token, token_name='tokenAuth', service='nifi')
            if return_response:
                return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Start Process Group')
    def start_process_group(self, processor_group_id=None, return_response=False):
        """
        Start Process Group

         This method starts a specified NiFi process group by updating its state to 'RUNNING'.

        Arguments
            - base_url (str): NiFi domain
            - token (str): NiFi token it can be get by using <Get Nifi Token> kaywords
            - processor_group_id (str): id of processor group
            - return_response (bool, optional): Boolean flag to indicate if the kaywords should be returned. Default is False.

        Returns
            The kaywords from the update process group state call if return_response is True.

        Examples
        | Start Process Group | ${processor_group_id} |

        """
        if not processor_group_id:
            raise Exception('Require parameters cannot be none')
        try:
            response = self.update_process_group_state(processor_group_id, 'RUNNING')
            if return_response:
                return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Stop Process Group')
    def stop_process_group(self, processor_group_id=None, return_response=False):
        """
        Stop a NiFi process group.

        This method stops a specified NiFi process group by updating its state to 'STOPPED'.

        Arguments
            - processor_group_id (str): id of processor group
            - return_response (bool, optional): Boolean flag to indicate if the kaywords should be returned. Default is False.

        Returns
            The kaywords from the update process group state call if return_response is True.

        Examples
        | Stop Process Group |  {processor_id} |

        """
        if not processor_group_id:
            raise Exception('Require parameters cannot be none')
        try:
            response = self.update_process_group_state(processor_group_id, 'STOPPED')
            if return_response:
                return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Get Process Group')
    def get_process_group(self, processor_group_id):
        """
        To get process group detail

        Arguments
            - processor_group_id (str): id of processor group

         Returns
             The kaywords containing the process group details

        Examples
        | Get Process Group | ${processor_group_id} |

        """
        if not processor_group_id:
            raise Exception('Require parameters cannot be none')
        try:
            response = nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi(
                api_client=nipyapi.config.nifi_config.api_client).get_process_group(
                id=processor_group_id)
            return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Get Root Process Group')
    def get_root_process_group(self):
        """
         Get root process group detail.

        This method retrieves the details of the root process group in NiFi.

        Returns
            The kaywords containing the root process group details.

        Examples
        | ${res}= | Get Root Process Group |

        """
        try:
            response = nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi(
                api_client=nipyapi.config.nifi_config.api_client).get_processors(
                id="root")
            return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Update Process Group Parameter Context')
    def update_process_group_parameter_context(self, processor_group_id=None,
                                               param_context_id=None):
        """
        Update the parameter context of a NiFi process group.

        This method updates the parameter context of a specified NiFi process group.

        Arguments
            - processor_group_id (str): The ID of the processor group.
            - param_context_id (str): The ID of the parameter context.

        Returns
            The kaywords from the update process group call.

        Examples
            | Update Process Group Parameter Context | ${processor_group_id} | ${param_context_name} |
        """
        if not processor_group_id or not param_context_id:
            raise Exception('Require parameters cannot be none')

        processor_group_detail = self.get_process_group(processor_group_id)
        processor_group_version = processor_group_detail.revision.version
        data = {
            "revision": {"clientId": param_context_id, "version": int(processor_group_version)},
            "component": {"id": processor_group_id, "parameterContext": {"id": param_context_id, "component": {
                "id": param_context_id}}}}
        try:
            response = nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi(
                api_client=nipyapi.config.nifi_config.api_client).update_process_group(
                id=processor_group_id,
                body=data)
            return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Get Parameter Context')
    def get_parameter_context(self, param_context_id=None):
        """
        Get parameter context detail.

        This method retrieves the details of a specified parameter context in NiFi.

        Arguments
            - param_context_id (str): The ID of the parameter context.

        Returns
            The kaywords containing the parameter context details.


        Examples
        | Get Parameter Contexts |  https://localhost:8443 | ${token} | ${param_context_id}

        """
        if not param_context_id:
            raise Exception('Require parameters cannot be none')

        try:
            response = nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi(
                api_client=nipyapi.config.nifi_config.api_client).get_parameter_context(
                id=param_context_id)
            return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Update Parameter Value Without Stopped Component')
    def update_parameter_value_without_stopped_component(self, param_context_id=None, parameter_name=None,
                                                         parameter_value=None):
        """
        Update parameter value at parameter context without stopping components.

        This method updates the value of a parameter in a specified parameter context in NiFi.
        Note that this request will fail if any component is running and is referencing a Parameter in the Parameter Context.
        In order to update a Parameter in a Parameter Context, all components that reference the Parameter must be stopped.

        Arguments
            - param_context_id (str): The ID of the parameter context.
            - parameter_name (str): The name of the parameter to update.
            - parameter_value (str): The new value of the parameter.

        Returns
            The kaywords from the update parameter context call.

        Examples
            | Update Parameter Value Without Stopped Component | ${param_context_id} | ${parameter_name} | ${parameter_value} |
        """
        if not param_context_id or not parameter_name or not parameter_value:
            raise Exception('Require parameters cannot be none')

        param_response = self.get_parameter_context(param_context_id)
        param_version = param_response.revision.version
        param_id = param_response.id
        param_component_id = param_response.component.id

        param = [{"parameter": {"name": parameter_name, "value": parameter_value}}]
        data = {"id": param_id, "revision": {"version": param_version},
                "component": {"id": param_component_id, "parameters": param}}
        try:
            response = nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi(
                api_client=nipyapi.config.nifi_config.api_client).update_parameter_context(
                id=param_context_id,
                body=data
            )
            return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Update Parameter Value With Stopped Component')
    def update_parameter_value_with_stopped_component(self, param_context_id=None, parameter_name=None,
                                                      parameter_value=None, return_response=False):
        """
        Update parameter value at parameter context with stopped components.

        This method updates the value of a parameter in a specified parameter context in NiFi.
        Note that changing the value of a Parameter may require that one or more components be stopped
        and restarted, so this action may take significantly more time than many other REST API actions.

        Arguments
            - param_context_id (str): The ID of the parameter context.
            - parameter_name (str): The name of the parameter to update.
            - parameter_value (str): The new value of the parameter.
            - return_response (bool, optional): Boolean flag to indicate if the kaywords should be returned. Default is False.


        Returns
            bool: True if the update is successful and return_response is True, otherwise None.

        Examples
            | Update Parameter Value With Stopped Component | ${param_context_id} | ${parameter_name} | ${parameter_value} |
        """
        get_response = None
        sleep_time = 2
        num_retries = 4
        if not param_context_id or not parameter_name or not parameter_value:
            raise Exception('Require parameters cannot be none')

        param_response = self.get_parameter_context(param_context_id)
        param_version = param_response.revision.version
        param_id = param_response.id
        param_component_id = param_response.component.id
        param = [{"parameter": {"name": parameter_name, "value": parameter_value}}]
        data = {"id": param_id, "revision": {"version": param_version},
                "component": {"id": param_component_id, "parameters": param}}
        try:
            post_response = nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi(
                api_client=nipyapi.config.nifi_config.api_client).submit_parameter_context_update(
                context_id=param_context_id,
                body=data
            )
            for x in range(0, num_retries):
                get_response = nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi(
                    api_client=nipyapi.config.nifi_config.api_client).get_parameter_context_update(
                    context_id=param_context_id,
                    request_id=post_response.request.request_id
                )
                if not get_response.request.complete:
                    sleep(sleep_time)  # wait before trying to fetch the data again
                    sleep_time *= 2  # backoff algorithm i.e. exponential backoff
                else:
                    break

            nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi(
                api_client=nipyapi.config.nifi_config.api_client).delete_update_request(
                context_id=param_context_id,
                request_id=post_response.request.request_id
            )
            print(get_response)
            if return_response:
                return get_response.request.complete
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Get Processor')
    def get_processor(self, processor_id=None):
        """
         To get processor detail

         Arguments
            - processor_id: id of processor

        Examples
        | Get Processor |  {processor_id} |

        """
        if not processor_id:
            raise Exception('Require parameters cannot be none')
        try:
            response = nipyapi.nifi.apis.processors_api.ProcessorsApi(
                api_client=nipyapi.config.nifi_config.api_client).get_processor(
                id=processor_id)
            return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Stop Processor')
    def stop_processor(self, processor_id=None, return_response=False):
        """
         To stop processor

         Arguments
            - processor_id: id of processor

        Examples
        | Stop Processor |  {processor_id} |
        | Stop Processor |  {processor_id} |  True |

        """
        if not processor_id:
            raise Exception('Require parameters cannot be none')
        try:
            response = self.update_process_state(processor_id, "STOPPED")
            if return_response:
                return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Start Processor')
    def start_processor(self, processor_id=None, return_response=False):
        """
         To start processor

         Arguments
            - processor_id: id of processor

        Examples
        | Start Processor |  {processor_id} |
        | Start Processor |  {processor_id} |  True |

        """
        if not processor_id:
            raise Exception('Require parameters cannot be none')
        try:
            response = self.update_process_state(processor_id, "RUNNING")
            if return_response:
                return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Run Once Processor')
    def run_once_processor(self, processor_id=None, return_response=False):
        """
         To run once processor

         Arguments
            - processor_id: id of processor

        Examples
        | Run Once Processor |  {processor_id} |

        """
        if not processor_id:
            raise Exception('Require parameters cannot be none')
        try:
            response = self.update_process_state(processor_id, "RUN_ONCE")
            if return_response:
                return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Disable Processor')
    def disable_processor(self, processor_id=None, return_response=False):
        """
         To disable processor

         Arguments
            - processor_id: id of processor

        Examples
        | Disable Processor |  {processor_id} |

        """
        if not processor_id:
            raise Exception('Require parameters cannot be none')
        try:
            response = self.update_process_state(processor_id, "DISABLED")
            if return_response:
                return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Get processor state')
    def get_processor_state(self, processor_id=None):
        """
         To get state of processor

         Arguments
            - processor_id: id of processor

        Examples
        | Get Processor State | {processor_id} |

        """
        if not processor_id:
            raise Exception('Require parameters cannot be none')

        try:
            response = nipyapi.nifi.apis.processors_api.ProcessorsApi(
                api_client=nipyapi.config.nifi_config.api_client).get_processor(
                id=processor_id)
            return response.component.state
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    @keyword('Clear Processor State')
    def clear_processor_state(self, processor_id=None, return_response=False):
        """
         To clear state of processor

         Arguments:
            - processor_id: id of processor

        Examples:
        | Clear Processor State |  {processor_id} |
        | Clear Processor State | {processor_id} | True |

        """
        if not processor_id:
            raise Exception('Require parameters cannot be none')
        try:
            response = nipyapi.nifi.apis.processors_api.ProcessorsApi(
                api_client=nipyapi.config.nifi_config.api_client).clear_state(
                id=processor_id
            )
            if return_response:
                return response
        except Exception as ex:
            logger.error(f"Failed to clear processor state: {str(ex)}")
            raise Exception(str(ex))

    def update_process_group_state(self, processor_group_id=None, state=None):

        data = {'id': str(processor_group_id), 'state': str(state)}
        try:
            response = nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi(
                api_client=nipyapi.config.nifi_config.api_client).update_process_group(
                id=processor_group_id,
                body=data
            )
            return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))

    def update_process_state(self, processor_id=None, state=None):
        """
         To update processor state to "RUNNING" or "STOPPED" or "RUN_ONCE" or "DISABLE"

         Argument
            - processor_id: id of processor
            - state: state of processor

        Example
        | Update Process State | {processor_id} | RUN_ONCE |

        """
        processor_res = nipyapi.nifi.apis.processors_api.ProcessorsApi(
            api_client=nipyapi.config.nifi_config.api_client).get_processor(
            id=processor_id)
        print(processor_res)
        processor_version = processor_res.revision.version
        processor_id = processor_res.id
        print(processor_id)
        data = {"revision": {"clientId": processor_id,
                             "version": processor_version},
                "state": state}
        try:
            response = nipyapi.nifi.apis.processors_api.ProcessorsApi(
                api_client=nipyapi.config.nifi_config.api_client).update_run_status(
                id=processor_id,
                body=data
            )
            return response
        except Exception as ex:
            logger.error(str(ex))
            raise Exception(str(ex))