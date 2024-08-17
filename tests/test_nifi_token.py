from NifiLibrary import NifiLibrary
import unittest
from unittest.mock import patch


class NifiTokenTest(unittest.TestCase):

    def setUp(self) -> None:
        self.nifi = NifiLibrary()
        self.base_url = "https://localhost:8443"
        self.username = "admin"
        self.password = "admin1234567"

    @patch('nipyapi.nifi.apis.access_api.AccessApi.create_access_token')
    @patch('nipyapi.utils.set_endpoint')
    def test_connect_to_nifi_success(self, mock_set_endpoint, mock_create_access_token):
        # Setup mock return values
        mock_create_access_token.return_value = 'mocked_token'
        mock_set_endpoint.return_value = None
        # Call the method under test
        token = self.nifi.connect_to_nifi(self.base_url, self.username, self.password, True)
        # Assertions to verify the expected outcomes
        self.assertEqual(token, 'mocked_token')
        mock_set_endpoint.assert_called_once_with('https://localhost:8443/nifi-api/')
        mock_create_access_token.assert_called_once_with(username=self.username, password=self.password)

    def test_connect_to_nifi_with_missing_parameters_raises_exception(self):
        with self.assertRaises(Exception) as context:
            self.nifi.connect_to_nifi(None, self.username, self.password, True)
        self.assertTrue('Require parameters cannot not be none' in str(context.exception))

    @patch('nipyapi.nifi.apis.access_api.AccessApi.create_access_token')
    def test_connect_to_nifi_api_call_fails_logs_error(self, mock_create_access_token):
        mock_create_access_token.side_effect = Exception('API call failed')
        with self.assertRaises(Exception) as context:
            self.nifi.connect_to_nifi(self.base_url, self.username, self.password, True)
        self.assertTrue('API call failed' in str(context.exception))

    @patch('nipyapi.security.set_service_auth_token')
    def test_set_endpoint_called_correctly(self, mock_set_service_auth_token):
        mock_set_service_auth_token.return_value = 'response'
        result = self.nifi.set_service_auth_token('valid_token', return_response=True)
        self.assertEqual(result, 'response')
        mock_set_service_auth_token.assert_called_once_with(token='valid_token', token_name='tokenAuth', service='nifi')

    @patch('nipyapi.security.set_service_auth_token')
    def test_set_service_auth_token_raises_exception_on_none_token(self, mock_set_service_auth_token):
        with self.assertRaises(Exception) as context:
            self.nifi.set_service_auth_token(None)
        self.assertTrue('Require parameters cannot not be none' in str(context.exception))
        mock_set_service_auth_token.assert_not_called()

    @patch('nipyapi.security.set_service_auth_token')
    def test_set_service_auth_token_handles_exception(self, mock_set_service_auth_token):
        mock_set_service_auth_token.side_effect = Exception('Error setting token')
        with self.assertRaises(Exception) as context:
            self.nifi.set_service_auth_token('valid_token')
        self.assertTrue('Error setting token' in str(context.exception))
        mock_set_service_auth_token.assert_called_once_with(token='valid_token', token_name='tokenAuth', service='nifi')

    if __name__ == '__main__':
        unittest.main()