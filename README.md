# Server Monitoring Tool

A bash-based server monitoring application that allows you to monitor Linux servers without installing any additional software on the target servers.

### This app great for home users to manage multi VMs from any provider and any Linux OS.


## Features

- Monitor CPU, memory, disk, and network metrics
- Visualize metrics with command-line graphs
- Add, edit, and delete server configurations
- Secure storage of server credentials

## Prerequisites

- Bash shell environment (WSL on Windows, or any Linux distribution)
- SSH access to the target servers
- `sshpass` for password-based SSH authentication
- `bc` for floating-point calculations

## Installation

1. Clone or download this repository
2. Run the setup script:
```
./setup.sh
```

3. Start the application:
```
./server_monitor.sh

```

## Usage

### Main Menu

- **Monitor Server**: Select a server to view its metrics in real-time
- **Add Server**: Add a new server configuration
- **Edit Server**: Modify an existing server configuration
- **Delete Server**: Remove a server configuration
- **List Servers**: View all configured servers
- **Exit**: Quit the application

### Monitoring View

When monitoring a server, you'll see:
- CPU usage with historical graph
- Memory usage with historical graph
- Network traffic (RX/TX) with historical graphs
- Disk space usage

Press 'q' to return to the main menu.

## Screenshot:
![Description of the image](https://github.com/pooyanazad/Multi-VM-Monitoring-/blob/main/screen.png)


## Security Note

This application stores server credentials in a encrypted file (`servers.dat`). For production use, consider implementing a more secure credential storage method.

## License

This project is open source and available under the MIT License.
