import zipfile

def unzip_with_password(zip_file_path, password, extract_path):
    """Unzips a password-protected zip file to a specified path.

  Args:
    zip_file_path: Path to the zip file.
    password: Password for the zip file.
    extract_path: Path to the directory where files should be extracted.

  Returns:
    True if the unzip was successful, False otherwise.
  """

    try:
        with zipfile.ZipFile(zip_file_path, 'r') as zip_file:
            zip_file.extractall(path=extract_path, pwd=password.encode())
        return True
    except (RuntimeError, zipfile.BadZipFile) as e:
        print(f"Error unzipping file: {e}")
        return False

