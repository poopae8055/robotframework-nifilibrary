# acm-etax-report-service-robot

## Overview

This repository contains Robot Framework test cases for the ACM etax-report-service. The test suite focuses on validating the functionality and performance of the service's APIs, including:

* **GET Enable Summary Report Use Cases API:** Retrieves a list of enabled use cases for summary reports.
* **Search Enable Summary Report API:** Fetches paginated summary reports based on date ranges and use case codes.
* **Download Zip File API:** Downloads zip files containing detailed transaction data for specific use cases and dates.
* **Export Search Summary Report as CSV API:** Exports summary reports as CSV files.

## Setup

### Prerequisites

* **Robot Framework:** Install Robot Framework and the required libraries.
* **Oracle Database Connector:** Install the OracleDBConnector library for database interactions.
* **Requests Library:** Install the RequestsLibrary for handling HTTP requests.
* **JSON Library:** Install the JSONLibrary for working with JSON data.
* **Operating System Library:** Install the OperatingSystem library for file system operations.
* **String Library:** Install the String library for string manipulation.
* **SFTP Client:** Install an SFTP client for interacting with the SFTP server.

### Configuration

* **Database Connection:** Configure the database connection details in the `resources/imports.robot` file.
* **API Endpoints:** Define the API endpoint URLs in the `resources/imports.robot` file.
* **SFTP Credentials:** Provide the SFTP server credentials in the `resources/imports.robot` file.

## Running Tests

1. **Connect to the Database:** Run the `Connect to etax database` keyword in the `Suite Setup`.
2. **Execute Test Cases:** Run the test cases using the Robot Framework runner.
3. **Disconnect from the Database:** Run the `Disconnect` keyword in the `Suite Teardown`.

## Test Cases

The test suite includes the following test cases:

* **TC001 - Get Enabled Use Cases - Success:** Verifies the successful retrieval of enabled use cases.
* **TC002 - Basic summary report - Success:** Tests the API's ability to return a correct summary report.
* **TC003 - Pagination for summary report - Success:** Ensures correct pagination of summary report results.
* **TC004 - Summary Report with data more than three month - Success:** Validates report accuracy with data spanning over three months.
* **TC005 - Summary Report with no result data - Fail:** Checks the API's handling of empty results.
* **TC006 - Download zip file - Success:** Verifies the successful download of a zip file.
* **TC007 - Download zip file with no data found on SFTP - Fail:** Tests the API's response when no data is found on the SFTP server.
* **TC008 - Download CSV file - Success:** Ensures the successful download of a CSV file.

## Keywords

The test suite utilizes various keywords for common tasks, including:

* **Database Keywords:** Interact with the Oracle database, such as querying and inserting data.
* **API Keywords:** Send HTTP requests to the etax-report-service APIs.
* **Verification Keywords:** Assert expected outcomes, such as HTTP status codes and response data.
* **Common Keywords:** Perform common operations, such as date manipulation and file handling.
* **File Operation Keywords:** Handle file system operations, such as downloading and extracting files.

## Contribution Guidelines

* **Writing Tests:** Follow the existing test case structure and naming conventions.
* **Code Review:** All code changes should be reviewed before merging.
* **Documentation:** Update the README and keyword documentation as needed.

## Contact

For any questions or issues, please contact the repository owner or administrator.