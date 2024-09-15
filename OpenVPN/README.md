# MikroTik OpenVPN Setup Script

Welcome to the **OpenVPN Server Setup Script for MikroTik RouterOS**! This script automates the process of configuring an OpenVPN server on your MikroTik router, making it easy to set up secure VPN connections for your clients.
It handles various tasks such as creating bridges, setting IP addresses, managing firewall rules, generating certificates, adding users, and more.
More imprtantly it can implement certificate revocation as well.

**Tested on MikroTik RouterOS 7.15.3.**

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Usage](#usage)
- [License](#license)
- [Contributing](#contributing)
- [Support](#support)

## Features



- **Automated Bridge Setup**: Creates a bridge interface for VPN connections.
- **IP Address Configuration**: Assigns IP addresses to the bridge.bridge.
- **IP Pool Creation**: Sets up an IP pool for OpenVPN clients.
- **Firewall Configuration**: Adds firewall rules to allow OpenVPN traffic and NAT for client traffic.
- **Certificate Management**: Generates CA, server, and client certificates.
- **OpenVPN Server**: Configure and enable OpenVPN server on MikroTik.
- **CRL Implementation**: Implements a Certificate Revoation List for enhanced security.
- **User Management**: Adds PPP users for OpenVPN authentication.
- **Dry Run Support**: Run the script in a dry run mode to see the output without applying changes.

## Prerequisites

- MikroTik RouterOS 7.15.3 or higher. (It should work on RoS 6 as well)
- Basic understanding of MikroTik RouterOS and its command-line interface.

- Access to the router's terminal for script execution.

## Usage

1. Copy the script to your text editor. (https://github.com/MoLuke-CA/MikroTik-Snippets/blob/main/OpenVPN/setup-openvpn-server-with-bridge.rsc)[]
2. Modify the variables in the script to match your environment (e.g., IP addresses, certificate details, etc.).
3. Paste the script into your MikroTik terminal and execute it.
or
3. Save it in a file, copy the file to the router and run it using ```import file-name=NAMEOFFILE.rsc```


## Configuration

The script is highly configurable. You can adjust the settings by modifying the script variables.

### Important Variables

- **`dryrun`**: If set to `true`, the script will only print the commands to the screen without executing them.
- **`SRVBRIP`**: The IP address to be assigned to the VPN bridge (in CIDR format).
- **`VPNPool`**: IP range for OpenVPN clients.
- **`OVPNPort`**: The port to be used by OpenVPN (default is 1194).
- **`OVPNProto`**: Protocol for OpenVPN (TCP or UDP).
- **`OVPNCiphers`**: Supported encryption ciphers for OpenVPN.
- **`OVPNUsers` & `OVPNPasses`**: Arrays containing OpenVPN users and their respective passwords.
- **Certificate Variables**: Customize the CA and client certificate details by adjusting the values of variables such as `CAname`, `CAcountry`, `CAstate`, `CAorg`, etc.

### Other Parameters

- **Certificate Details**:
```
:local CAname "MYCA01"
:local CAcountry "CA"
:local CAstate "BC"
:local CAlocality "WV"
:local CAorg "Company"
:local CAunit "Sysadmin"
:local CAcommonname "domain.example.com"

```
- ** Server and Clinet Names**: Set the server and client certificate names.
```
:local SRVname "SERVER"
:local CL01name "CLIENT-01"
:local CL01commonname "CLIENT01"
:local CL01exportpass "your-export-passphrase"
```

- **Network Settings**: Define IP addresses and Pools.
```
:local SRVBRIP "192.168.211.1/24"
:local VPNPool "192.168.211.100-192.168.211.200"
:local NATRange "192.168.211.0/24"
```

- **Adjust OpenVPN server Settings**:
```
:local OVPNPort "1194"
:local OVPNProto "tcp"
:local OVPNCiphers "aes128-cbc,aes192-cbc,aes256-cbc"
```

- **User Credentials**:
```
:local OVPNUsers  {"user1";"user2"}
:local OVPNPasses {"pass1*pass1";"pass2*pass2"}
```


## Usage

1. **Dry Run Mode**: Test the script without making actual changes. to understand the script output
2. **Running the script**: You can copy paste the script in the terminal or you can save it in a file and move it to the RouterOS and then import it
3. **Check logs**: when it is not in `dry run` you can see the logs for more details
4. Move certificate files to the client router
5. Import certificates on the clint router
6. Setup OpenVPN Clint and test the connection
7. For revocation test, revoke `CLIENT-01` on the server, `download` the CRL on server (`/system certificates crl->download`) and be sure the results show number of revoked certificates and try to re-connect the openVPN client




## License
This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.


You are free to:

Share — copy and redistribute the material in any medium or format.
Adapt — remix, transform, and build upon the material.
Under the following terms:

Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made.
NonCommercial — You may not use the material for commercial purposes without prior permission.


## Contributing
Contributions are welcome! Please submit a pull request or open an issue to discuss improvements or fixes.

## Support
If you encounter any problems or have questions, feel free to connect through https://www.moluke.com/contact