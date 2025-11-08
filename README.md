
# Net Tools API

The Net Tools API is a deployable Mule app that you can deploy to CloudHub or any worker cloud. The app will then expose a very simple UI that will allow you to do basic networking commands. The idea is that most networking related issues with your CloudHub VPC and VPN are related to connectivity to your on-prem systems, and most of those issues end up being resolved on the customer end. If you have this tool available to you, you can work with your Networking team to test connectivity to various on-prem systems and verify that firewall and routing rules are working.  It can also be used to generate some traffic that can help with diagnosing networking issues.

This supports HTTP and HTTPS connections with a configurable port for each.

## Technical Stack

- Mule Runtime: 4.9.x+
- Java 17+
- Build Tool: Maven
- Authentication: Basic Auth
- API Specification: RAML 1.0
- UI Dependencies: jQuery 1.12.4, Toastr 2.1.4

## Features

### Network Diagnostic Tools
- **DNS lookups**: Resolve hostnames using specified DNS servers
- **Ping**: ICMP connectivity testing
- **TraceRoute**: Network path analysis
- **TCP Socket**: Test direct TCP connections
- **Curl**: HTTP(S) requests with custom headers
  - GET requests with optional headers
  - POST requests with payload support
- **SSL/TLS Tools**:
  - Certificate inspection
  - Cipher suite compatibility testing

### Additional Features
- Web-based UI for easy access
- Secure authentication
- Configurable HTTP/HTTPS ports
- CloudHub 1.0/2.0 and RTF compatibility
- Comprehensive error handling

## Latest build

Latest build can be found here: https://github.com/mulesoft-catalyst/mulesoft-net-tools/releases

# Usage

The UI can be accessed by using the base URL for the app.  The options are listed below.

- CloudHub Shared Load Balancer: `http://{app-name}.{region}.cloudhub.io` where the app-name and region are specific to the deployed app.
- Dedicated Load Balancer: `custom url`.  See *Configuration* section to update settings.

- CloudHub Private Space: https://{app-name}-{environment}.{private-space}.{region}.cloudhub.io

The UI is protected by Basic Authentication, and the default credentials are listed in the *Configuration* section.

# Configuration

## Application Properties
The properties below can be set on the app to override the default settings. The proper ports must be set to accommodate load balancer and VPC firewall rule settings. The default settings are for the CloudHub shared load balancer HTTP endpoint.

| Property       | Description         | Default       | Notes                        |
| -------------- | ------------------- | ------------- | ---------------------------- |
| `user`         | User name for login | `vpc-tools`   | Used for Basic Auth          |
| `pass`         | Password for login  | `SomePass`    | Used for Basic Auth          |
| `httpPort`     | HTTP listener port  | `8081`        | Must differ from `httpsPort` |
| `httpsPort`    | HTTPS listener port | `8082`        | Must differ from `httpPort`  |
| `httpListener` | HTTP endpoint state | `started`     | Options: `started`/`stopped` |
| `ignoreFiles`  | Files to ignore     | `favicon.ico` | Comma-delimited list         |

## API Endpoints

All endpoints are available under the `/api` base path and require Basic Authentication.

### Network Endpoints
- `GET /api/dns?host={hostname}&dnsServer={optional_dns_server}`
- `GET /api/ping?host={hostname}`
- `GET /api/traceroute?host={hostname}`
- `GET /api/socket?host={hostname}&port={port_number}`

### HTTP/Curl Endpoints
- `GET /api/curl?url={target_url}&header={optional_headers}&insecure={boolean}`
- `POST /api/curl?url={target_url}&header={optional_headers}`

### SSL/TLS Endpoints
- `GET /api/certest?host={hostname}&port={port_number}`
- `GET /api/ciphertest?host={hostname}&port={port_number}`

## Network Considerations

### Port Configuration
- `httpsPort` and `httpPort` **must always** be different numbers, even if `httpListener=stopped`
  - Both HTTP and HTTPS listener configurations are created at startup
  - Using same port numbers will cause startup failures
- CloudHub 2.0 and RTF specific:
  - Only supports single port for HTTP listener
  - Can run either HTTP or HTTPS, not both simultaneously
  - Set unused protocol's port to a different number
  - Enable *Last-Mile Security* in app's Ingress tab for HTTPS
- Does not use standard `http.port`/`https.port` properties
  - These are overridden in CloudHub 2.0/RTF
  - Would cause port conflicts due to same-port assignment

### Deployment Guidelines
1. **CloudHub 1.0**:
   - Supports both HTTP/HTTPS simultaneously
   - Use default ports if behind shared load balancer
   - Configure custom ports for dedicated load balancer

2. **CloudHub 2.0/RTF**:
   - Choose either HTTP or HTTPS
   - Configure single port properly
   - Enable Last-Mile Security for HTTPS
   - Set unused protocol's port to different number

3. **General**:
   - Verify VPC firewall rules allow chosen ports
   - Ensure load balancer configuration matches ports
   - Test connectivity after deployment

## Development

### Building the Project
```bash
mvn clean package
```

### Running Tests
```bash
mvn test
```

### Project Structure
```
src/
├── main/
│   ├── java/          # Java network utility implementations
│   ├── mule/          # Mule configuration files
│   └── resources/
│       ├── api/       # RAML API definition
│       ├── dwl/       # DataWeave transformations
│       ├── schemas/   # JSON validation schemas
│       └── web/       # Static web UI assets
└── test/
    ├── munit/        # MUnit test suites
    └── resources/    # Test resources and mock data
```

# References
- [CloudHub 2.0 Infrastructure Considerations](https://docs.mulesoft.com/cloudhub-2/ch2-comparison#infrastructure-considerations)
- [CloudHub 1.0 Load Balancer Architecture](https://docs.mulesoft.com/cloudhub-1/lb-architecture)
- [Enable Last Mile Security in RTF](https://help.mulesoft.com/s/article/How-to-Enable-both-Last-Mile-Security-and-Mutual-TLS-in-Runtime-Fabric)
- [Original repository](https://github.com/mulesoft-labs/net-tools-api)

# Maintenance
This uses the JS libraries below.
- jQuery 1.12.4 [min](https://code.jquery.com/jquery-1.12.4.min.js) and [map](https://code.jquery.com/jquery-1.12.4.min.map)
- [Toastr](https://github.com/CodeSeven/toastr) 2.1.4 [min, map, and css](https://cdnjs.com/libraries/toastr.js)

# Contributors

- Jorge Luis García Pérez - Mule 3 version creator and maintainer
- Facundo Lopez Kaufmann - Mule 4 upgrade
