# Changelog

## v0.4.0
### Added
* Test MariaDB 10.2, 10.3, 10.4 in CI

### Changed
* Deleted `max_memory_used` from Long running queries

## v0.3.0
### Added
* Test MariaDB 10.6 in CI
* Query: Long running queries (#1)

### Changed
* Renamed `DBStatus` to `DbStatus`
* Pass query arguments inside `args` keyword list

### Fixed
* Convert Total table size to unsigned integer inside SQL query

## v0.2.1 (2021-10-14)
### Fixed
* Compile error when table_rex isn't loaded

## v0.2.0 (2021-10-11)
### Added
* Test MySQL 5.7 in CI
* Query: DB settings
* Query: DB status
* Query: Unused indexes
* Query: Records rank

### Changed
* Delete views from query results
* Exclude Primary key from Index size query

### Fixed
* Don't convert total index size inside SQL query

## v0.1.0 (2021-10-07)
### Added
* Initial commit
* Query: Index Size
* Query: Plugins
* Query: Table indexes size
* Query: Table size
* Query: Total index size
* Query: Total table size
