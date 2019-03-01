# Changelog
All notable changes to WebCAT will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) as much as possible.
**All versions before 1.0 should consider minor version changes breaking, as the API isn't stable yet.**
## [0.2.0](#0.2.0)
## Added
- Website footer [#6](https://github.com/PERLMSU/webCAT/issues/6)
    - Version
    - Build date
    - Link to changelog
- Feedback Editor [#7](https://github.com/PERLMSU/webCAT/issues/7)
    - Browse by categories
    - Add feedback from a single observation at a time
- Changelog
    - Renders the changelog from markdown at compile time
    - Allows users to keep up with changes to functionality without explicit communication
## Security
- HTTPS/SSL is now forced in production environment
## [0.1.0](#0.1.0) - 2019-02-26
### Added
- Classroom Control Panel
    - Create, edit, and view data
- Data import from spreadsheet ([#1](https://github.com/PERLMSU/webCAT/issues/1))
- User profile page
    - Change password functionality
- Password reset
- Basic system dashboard
- Deletion safeguards ([#4](https://github.com/PERLMSU/webCAT/issues/4))
### Fixed
- A ton of misc. bugs caught by tests ([#5](https://github.com/PERLMSU/webCAT/issues/5)).