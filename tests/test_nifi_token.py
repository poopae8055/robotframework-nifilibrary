from NifiLibrary.NifiLibrary import NifiLibrary
import unittest
from unittest.mock import patch
import requests


class NifiTokenTest(unittest.TestCase):

    def setUp(self) -> None:
        self.nifi = NifiLibrary()
        self.base_url = "https://localhost:8443"
        self.username = "admin"
        self.password = "admin1234567"

    @patch('nipyapi.nifi.apis.access_api.AccessApi.create_access_token')
    @patch('nipyapi.utils.set_endpoint')
    def test_get_nifi_token_success(self, mock_set_endpoint, mock_create_access_token):
        # Setup mock return values
        mock_create_access_token.return_value = 'mocked_token'
        mock_set_endpoint.return_value = None
        # Call the method under test
        token = self.nifi.get_nifi_token('https://localhost:8443', 'username', 'password', True)
        print("token", token)
        # Assertions to verify the expected outcomes
        self.assertEqual(token, 'mocked_token')
        mock_set_endpoint.assert_called_once_with('https://localhost:8443/nifi-api/')
        mock_create_access_token.assert_called_once_with(username='username', password='password')

    def test_get_nifi_token_with_missing_parameters_raises_exception(self):
        with self.assertRaises(Exception) as context:
            self.nifi.get_nifi_token(None, 'username', 'password', True)
        self.assertTrue('Require parameters cannot not be none' in str(context.exception))

    @patch('nipyapi.nifi.apis.access_api.AccessApi.create_access_token')
    def test_get_nifi_token_api_call_fails_logs_error(self, mock_create_access_token):
        mock_create_access_token.side_effect = Exception('API call failed')
        with self.assertRaises(Exception) as context:
            self.nifi.get_nifi_token('https://localhost:8443', 'username', 'password', True)
        self.assertTrue('API call failed' in str(context.exception))

    if __name__ == '__main__':
        unittest.main()