from NifiLibrary.NifiLibrary import NifiLibrary
import unittest
from unittest.mock import MagicMock, patch


class NifiProcessor(unittest.TestCase):

    def setUp(self) -> None:
        self.nifi = NifiLibrary()
        self.processor_id = "Af0110f6c-ba7f-3ac0-00fc-677aa1a4054c"
        self.processor_name = "A_group"
        
    @patch('nipyapi.nifi.apis.processors_api.ProcessorsApi.get_processor')
    def test_get_processor_returns_processor_details_successfully(self, mock_get_processor):
        mock_response = MagicMock()
        mock_get_processor.return_value = mock_response

        result = self.nifi.get_processor(self.processor_id)

        assert result == mock_response
        mock_get_processor.assert_called_once_with(id=self.processor_id)

    def test_get_processor_raises_exception_for_missing_processor_id(self):
        try:
            self.nifi.get_processor(None)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    @patch('nipyapi.nifi.apis.processors_api.ProcessorsApi.get_processor')
    def test_get_processor_logs_error_on_failure(self, mock_get_processor):
        mock_get_processor.side_effect = Exception('Failed to get processor')

        try:
            self.nifi.get_processor(self.processor_id)
        except Exception as e:
            assert str(e) == 'Failed to get processor'
        mock_get_processor.assert_called_once_with(id=self.processor_id)
        
    @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_state')
    def test_stop_processor_stops_processor_successfully(self, mock_update_process_state):
        mock_update_process_state.return_value = 'Success'

        result = self.nifi.stop_processor(self.processor_id, return_response=True)

        assert result == 'Success'
        mock_update_process_state.assert_called_once_with(self.processor_id, 'STOPPED')

    def test_stop_processor_raises_exception_for_missing_processor_id(self):
        try:
            self.nifi.stop_processor(None)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_state')
    def test_stop_processor_logs_error_on_failure(self, mock_update_process_state):
        mock_update_process_state.side_effect = Exception('Failed to stop processor')

        try:
            self.nifi.stop_processor(self.processor_id)
        except Exception as e:
            assert str(e) == 'Failed to stop processor'
        mock_update_process_state.assert_called_once_with(self.processor_id, 'STOPPED')

    @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_state')
    def test_start_processor_starts_processor_successfully(self, mock_update_process_state):
        mock_update_process_state.return_value = 'Success'

        result = self.nifi.start_processor(self.processor_id, return_response=True)

        assert result == 'Success'
        mock_update_process_state.assert_called_once_with(self.processor_id, 'RUNNING')

    def test_start_processor_raises_exception_for_missing_processor_id(self):
        try:
            self.nifi.start_processor(None)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_state')
    def test_start_processor_logs_error_on_failure(self, mock_update_process_state):
        mock_update_process_state.side_effect = Exception('Failed to start processor')

        try:
            self.nifi.start_processor(self.processor_id)
        except Exception as e:
            assert str(e) == 'Failed to start processor'
        mock_update_process_state.assert_called_once_with(self.processor_id, 'RUNNING')

    @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_state')
    def test_run_once_processor_runs_successfully(self, mock_update_process_state):
        mock_update_process_state.return_value = 'Success'

        result = self.nifi.run_once_processor(self.processor_id, return_response=True)

        assert result == 'Success'
        mock_update_process_state.assert_called_once_with(self.processor_id, 'RUN_ONCE')

    def test_run_once_processor_raises_exception_for_missing_processor_id(self):
        try:
            self.nifi.run_once_processor(None)
        except Exception as e:
            assert str(e) == 'Require parameters cannot be none'

    @patch('NifiLibrary.NifiLibrary.NifiLibrary.update_process_state')
    def test_run_once_processor_logs_error_on_failure(self, mock_update_process_state):
        mock_update_process_state.side_effect = Exception('Failed to run processor once')

        try:
            self.nifi.run_once_processor(self.processor_id)
        except Exception as e:
            assert str(e) == 'Failed to run processor once'
        mock_update_process_state.assert_called_once_with(self.processor_id, 'RUN_ONCE')
        
    if __name__ == '__main__':
        unittest.main()