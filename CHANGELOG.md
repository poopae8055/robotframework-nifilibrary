# Changelog
## [2.1.3] - 2024-09-04
### Added
- Added a keyword to directly call the NiFi API and update the run status to "RUN_ONCE".
## [2.1.2] - 2024-08-17
### Changed
- Updated keywords to support setting the NiFi endpoint. 
- Comment run_once_processor function because Nipyapi still does not allow RUN_ONCE state.
## [2.1.0] - 2024-08-17
### Added
- added new keyword `Set access token` to set the access token for the NiFi instance.
### Changed
- Updated the documentation.
## [2.0.0] - 2024-07-18
### Changed
- Updated all functions to use `nipyapi` SDK instead of NiFi API directly.