# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


---

## [0.3.0] - 2025-12-05

### Added

- Added support for **baud rate** configuration via `config.ini`  
  (`<device>=<baud>,<tcp_port>`)

### Updated

- Updated configuration examples in `config.ini` to use the new `<baud>,<port>` format.
- Improved internal comments and structure inside `launch.sh` for readability and maintenance.



## [0.2.0] - 2025-11-14

### Added

- Systemd service support

### Changed

**launch.sh** rewritten for improved structure and reliability

- Migrated from direct TCP bridging to UNIX socket + ncat broker architecture.
- Added clear startup, shutdown, and status output messages.
- Added automatic cleanup of stale UNIX socket files.
- Improved process detection and graceful termination.

### Updated

- Updated installation instructions to include both `socat` and `ncat`.
- Added new section: Test the Serial TCP Server with examples.
- Added Systemd Service Integration guide.
- Added Architecture & Design Rationale section including both legacy and new architectures.
- Improved formatting and examples in the “Script Usage” section.



## [0.1.0] - 2025-11-10

### Added
- `config.ini` for defining serial-to-TCP port mappings.
- `launch.sh` for starting, stopping, and checking multiple `socat` TCP bridges.
- Support for configuration via simple INI format (no external dependencies).
- MIT License file.
- Initial project documentation and structure.

---

## [0.0.0] - 2025-11-10
### Added
- Initial release of `serial-tcp-server`.
- Basic multi-port TCP bridge functionality using `socat`.

---

### Author
Howard Cheng  
2025 © MIT License
