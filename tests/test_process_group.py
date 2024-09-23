from NifiLibrary import NifiLibrary
import unittest
from unittest.mock import MagicMock, patch


class NifiProcessGroupTest(unittest.TestCase):

    def setUp(self) -> None:
        self.nifi = NifiLibrary()
        self.processor_group_id = "Af0110f6c-ba7f-3ac0-00fc-677aa1a4054c"
        self.processor_group_name = "A_group"

    # @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_group_state')
    # def test_start_process_group_starts_group_successfully(self, mock_update_process_group_state):
    #     mock_update_process_group_state.return_value = 'Success'
    #
    #     result = self.nifi.start_process_group(self.processor_group_id, return_response=True)
    #
    #     assert result == 'Success'
    #     mock_update_process_group_state.assert_called_once_with(self.processor_group_id, 'RUNNING')
    #
    # def test_start_process_group_raises_exception_for_missing_processor_group_id(self):
    #     try:
    #         self.nifi.start_process_group(None)
    #     except Exception as e:
    #         assert str(e) == 'Require parameters cannot be none'
    #
    # @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_group_state')
    # def test_start_process_group_logs_error_on_failure(self, mock_update_process_group_state):
    #     mock_update_process_group_state.side_effect = Exception('Failed to start process group')
    #
    #     try:
    #         self.nifi.start_process_group(self.processor_group_id)
    #     except Exception as e:
    #         assert str(e) == 'Failed to start process group'
    #     mock_update_process_group_state.assert_called_once_with(self.processor_group_id, 'RUNNING')
    #
    # @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_group_state')
    # def test_stop_process_group_stops_group_successfully(self, mock_update_process_group_state):
    #     mock_update_process_group_state.return_value = 'Success'
    #
    #     result = self.nifi.stop_process_group(self.processor_group_id, return_response=True)
    #
    #     assert result == 'Success'
    #     mock_update_process_group_state.assert_called_once_with(self.processor_group_id, 'STOPPED')

    def test_stop_process_group_raises_exception_for_missing_processor_group_id(self):
        try:
            self.nifi.stop_process_group(None)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    # @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_group_state')
    # def test_stop_process_group_logs_error_on_failure(self, mock_update_process_group_state):
    #     mock_update_process_group_state.side_effect = Exception('Failed to stop process group')
    #
    #     try:
    #         self.nifi.stop_process_group(self.processor_group_id)
    #     except Exception as e:
    #         assert str(e) == 'Failed to stop process group'
    #     mock_update_process_group_state.assert_called_once_with(self.processor_group_id, 'STOPPED')

    @patch('nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi.get_process_group')
    def test_get_process_group_returns_group_details_successfully(self, mock_get_process_group):
        mock_response = MagicMock()
        mock_get_process_group.return_value = mock_response

        result = self.nifi.get_process_group(self.processor_group_id)

        assert result == mock_response
        mock_get_process_group.assert_called_once_with(id=self.processor_group_id)

    def test_get_process_group_raises_exception_for_missing_processor_group_id(self):
        try:
            self.nifi.get_process_group(None)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    @patch('nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi.get_process_group')
    def test_get_process_group_logs_error_on_failure(self, mock_get_process_group):
        mock_get_process_group.side_effect = Exception('Failed to get process group')

        try:
            self.nifi.get_process_group(self.processor_group_id)
        except Exception as e:
            assert str(e) == 'Failed to get process group'
        mock_get_process_group.assert_called_once_with(id=self.processor_group_id)

    @patch('nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi.get_processors')
    def test_get_root_process_group_returns_group_details_successfully(self, mock_get_processors):
        mock_response = MagicMock()
        mock_get_processors.return_value = mock_response

        result = self.nifi.get_root_process_group()

        assert result == mock_response
        mock_get_processors.assert_called_once_with(id='root')

    @patch('nipyapi.nifi.apis.process_groups_api.ProcessGroupsApi.get_processors')
    def test_get_root_process_group_logs_error_on_failure(self, mock_get_processors):
        mock_get_processors.side_effect = Exception('Failed to get root process group')

        try:
            self.nifi.get_root_process_group()
        except Exception as e:
            assert str(e) == 'Failed to get root process group'
        mock_get_processors.assert_called_once_with(id='root')

    if __name__ == '__main__':
        unittest.main()
