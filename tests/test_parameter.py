from NifiLibrary import NifiLibrary
import unittest
from unittest.mock import MagicMock, patch


class NifiParameterTest(unittest.TestCase):

    def setUp(self) -> None:
        self.nifi = NifiLibrary()
        self.param_context_id = "f0110f6c-ba7f-3ac0-00fc-677aa1a4054c"
        self.param_context_name = "test_param_context"
        self.parameter_name = "name"
        self.parameter_value = "Mr.AAA"

    # @patch('nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi.update_process_group')
    # @patch('nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi.get_process_group', return_value=MagicMock())
    # def test_updating_parameter_context_succeeds(self, mock_update_process_group,
    #                                              mock_get_process_group):
    #     self.revision = MagicMock(version=1)
    #     mock_process_group_response = MagicMock(version=1)
    #     mock_get_process_group.return_value = mock_process_group_response
    #     mock_update_process_group.return_value = 'Success'
    #     result = self.nifi.update_process_group_parameter_context('group_id', 'context_id')
    #     self.assertEqual(result, 'Success')
        # mock_get_process_group.assert_called_once_with('group_id')
        # mock_update_process_group.assert_called_once()

    # @patch('NifiLibrary.NifiLibrary.get_process_group')
    # @patch('nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi.get_process_group', return_value=MagicMock())
    # def test_updating_parameter_context_fails_due_to_invalid_group_id(self, mock_get_process_group):
    #     mock_get_process_group.side_effect = Exception('Invalid group ID')
    #     with self.assertRaises(Exception) as context:
    #         self.nifi.update_process_group_parameter_context('invalid_group_id', 'context_id')
    #     self.assertTrue('Invalid group ID' in str(context.exception))

    # @patch('NifiLibrary.NifiLibrary.get_process_group')
    # @patch('nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi.update_process_group')
    # @patch('nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi.get_process_group', return_value=MagicMock())
    # def test_updating_parameter_context_fails_due_to_invalid_context_id(self, mock_update_process_group,
    #                                                                     mock_get_process_group):
    #     self.revision = MagicMock(version=1)
    #     mock_process_group_response = MagicMock(version=1)
    #     mock_get_process_group.return_value = mock_process_group_response
    #     mock_update_process_group.side_effect = Exception('Invalid context ID')
    #     with self.assertRaises(Exception) as context:
    #         self.nifi.update_process_group_parameter_context('group_id', 'invalid_context_id')
    #     self.assertTrue('Invalid context ID' in str(context.exception))

    def test_updating_parameter_context_fails_with_none_parameters(self):
        with self.assertRaises(Exception) as context:
            self.nifi.update_process_group_parameter_context(None, None)
        self.assertTrue('Require parameters cannot be none' in str(context.exception))

    @patch('nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi.get_parameter_context')
    def test_successful_get_parameter_context_returns_context(self, mock_get_parameter_context):
        expected_response = {'id': 'example_id', 'component': {'name': 'example_name'}}
        mock_get_parameter_context.return_value = expected_response
        response = self.nifi.get_parameter_context('example_id')
        self.assertEqual(response, expected_response)
        mock_get_parameter_context.assert_called_once_with(id='example_id')

    def test_get_parameter_context_with_none_id_raises_exception(self):
        with self.assertRaises(Exception) as context:
            self.nifi.get_parameter_context(None)
        self.assertTrue('Require parameters cannot be none' in str(context.exception))

    @patch('nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi.get_parameter_context')
    def test_get_parameter_context_api_call_fails_logs_error(self, mock_get_parameter_context):
        mock_get_parameter_context.side_effect = Exception('API call failed')
        with self.assertRaises(Exception) as context:
            self.nifi.get_parameter_context('example_id')
        self.assertTrue('API call failed' in str(context.exception))

    # @patch('nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi.update_parameter_context')
    # @patch('nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi.get_parameter_context')
    # def test_update_parameter_value_without_stopped_component_updates_parameter_successfully(self,
    #                                                                                          mock_update_parameter_context,
    #                                                                                          mock_get_parameter_context):
    #     mock_param_context_response = MockParameterContextResponse(revision_version=1, param_id='param_id',
    #                                                                param_component_id='param_component_id')
    #     mock_get_parameter_context.return_value = mock_param_context_response
    #     mock_update_parameter_context.return_value = 'Success'
    #
    #     result = self.nifi.update_parameter_value_without_stopped_component(self.param_context_id, self.parameter_name,
    #                                                                         self.parameter_value)
    #
    #     assert result == 'Success'
        # mock_get_parameter_context.assert_called_once_with(self.param_context_id)
        # mock_update_parameter_context.assert_called_once()

    def test_update_parameter_value_without_stopped_component_raises_exception_for_missing_param_context_id(self):

        try:
            self.nifi.update_parameter_value_without_stopped_component(None, self.parameter_name, self.parameter_value)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    def test_update_parameter_value_without_stopped_component_raises_exception_for_missing_parameter_name(self):
        try:
            self.nifi.update_parameter_value_without_stopped_component(self.param_context_id, None, self.parameter_value)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    def test_update_parameter_value_without_stopped_component_raises_exception_for_missing_parameter_value(self):
        try:
            self.nifi.update_parameter_value_without_stopped_component(self.param_context_id, self.parameter_name, None)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    # @patch('NifiLibrary.NifiLibrary.NifiLibrary.get_parameter_context')
    # @patch('nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi.submit_parameter_context_update')
    # @patch('nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi.get_parameter_context_update')
    # @patch('nipyapi.nifi.apis.parameter_contexts_api.ParameterContextsApi.delete_update_request')
    # def test_update_parameter_value_with_stopped_component_updates_parameter_successfully(self,
    #                                                                                       mock_delete_update_request,
    #                                                                                       mock_get_parameter_context_update,
    #                                                                                       mock_submit_parameter_context_update,
    #                                                                                       mock_get_parameter_context):
    #     mock_param_context_response = MagicMock()
    #     mock_param_context_response.revision.version = 1
    #     mock_param_context_response.id = 'param_id'
    #     mock_param_context_response.component.id = 'param_component_id'
    #     mock_get_parameter_context.return_value = mock_param_context_response
    #
    #     mock_post_response = MagicMock()
    #     mock_post_response.request.request_id = 'request_id'
    #     mock_submit_parameter_context_update.return_value = mock_post_response
    #
    #     mock_get_response = MagicMock()
    #     mock_get_response.request.complete = True
    #     mock_get_parameter_context_update.return_value = mock_get_response
    #
    #     result = self.nifi.update_parameter_value_with_stopped_component(self.param_context_id, self.parameter_name,
    #                                                                         self.parameter_value, return_response=True)
    #
    #     assert result is True
    #     mock_get_parameter_context.assert_called_once_with(self.param_context_id)
    #     mock_submit_parameter_context_update.assert_called_once()
    #     mock_get_parameter_context_update.assert_called()
    #     mock_delete_update_request.assert_called_once_with(context_id=self.param_context_id, request_id='request_id')

    def test_update_parameter_value_with_stopped_component_raises_exception_for_missing_param_context_id(self):
        try:
            self.nifi.update_parameter_value_with_stopped_component(None, self.parameter_name, self.parameter_value)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    def test_update_parameter_value_with_stopped_component_raises_exception_for_missing_parameter_name(self):
        try:
            self.nifi.update_parameter_value_with_stopped_component(self.param_context_id, None, self.parameter_value)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    def test_update_parameter_value_with_stopped_component_raises_exception_for_missing_parameter_value(self):
        try:
            self.nifi.update_parameter_value_with_stopped_component(self.param_context_id, self.parameter_name, None)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    if __name__ == '__main__':
        unittest.main()


class MockParameterContextResponse:
    def __init__(self, revision_version, param_id, param_component_id):
        self.revision = MagicMock(version=revision_version)
        self.id = param_id
        self.component = MagicMock(id=param_component_id)
