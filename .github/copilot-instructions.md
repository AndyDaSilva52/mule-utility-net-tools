## Quick orientation

This is a Mule 4 application (Mule runtime 4.9.x) that exposes a small UI and a set of network diagnostic HTTP endpoints (DNS, ping, traceroute, socket/curl/certs). The app uses APIkit-style flows and a Java helper class for the heavy lifting.

Key locations
- Flows and orchestration: `src/main/mule/*.xml` (especially `net-tools.xml`, `http.xml`, `global.xml`, `error.xml`)
- Static web UI and RAML: `src/main/resources/web/*` and `src/main/resources/api/net-tools.raml`
- DataWeave routing logic: `src/main/resources/dwl/v_flowRef.dwl`
- JSON schemas: `src/main/resources/schemas/*.json` used for request validation
- Java helpers: `src/main/java/com/mulesoft/tool/network/NetworkUtils.java` — contains native process calls (ping, curl, openssl, dig, traceroute)
- Properties and keystore: `src/main/resources/properties.yaml` and `server.jceks`

## Big picture / architecture
- A small HTTP UI flow serves static assets (UI) and requires basic auth (credentials in `properties.yaml` + `beans.xml`).
- API endpoints are under `/api/*`. `http.xml` contains listener configuration that delegates to `net-tools-main` in `net-tools.xml`.
- Request routing uses the DataWeave `v_flowRef.dwl` to map paths+methods to flows following APIkit naming conventions (e.g. `get.\\ping.net-tools-config`). When `v_flowRef` finds a flow, the main `net-tools-main` flow does a `flow-ref` into the specific flow.
- Individual flows validate incoming attributes against JSON schemas (`src/main/resources/schemas/*`) and call static Java methods in `NetworkUtils` via DataWeave import (java!com::mulesoft::tool::network::NetworkUtils).

## Important project conventions (be explicit)
- Flow naming follows APIkit-style patterns. Use `get.` / `post.` prefixes and `.` separators, e.g. `get.\\curl.net-tools-config`.
- DataWeave imports call Java static methods; signatures are in `NetworkUtils.java`. Do not change the public method names/signatures without updating all DWL callers.
- The app creates both HTTP and HTTPS listener configs; `httpPort` and `httpsPort` must be different (see `global.xml` and README notes). Changing listener names or ports affects how the UI/static assets load.
- Sensitive props: `pass` is listed under `mule-artifact.json` secureProperties; secrets may be stored in `server.jceks`. Avoid leaking these values in logs or in generated code.

## Build / test / debug workflows (concrete commands)
- Build package and run unit/munit tests (uses Maven and Mule Maven plugin):

  mvn clean package

- Run MUnit tests and generate coverage report (configured in `pom.xml`):

  mvn test

- Notes: project targets Java 17 (see `mule-artifact.json`) and requires Mule dependencies available from MuleSoft repositories configured in `pom.xml`. If Maven fails to resolve Mule plugins, ensure Anypoint repo credentials are configured in your Maven settings (not included in repo).

## Integration & external dependencies
- `NetworkUtils` executes native commands (curl, openssl, ping, traceroute, dig). These must be available on the host where the app runs (CloudHub worker images or local dev container). When editing or testing, prefer unit tests that mock calls rather than invoking native binaries.
- Maven repositories: Anypoint Exchange and MuleSoft releases are required to fetch plugin artifacts (see `pom.xml` repository entries).

## Files to inspect when making changes
- When changing an endpoint: update `src/main/mule/net-tools.xml` (flow), `src/main/resources/schemas/*` (validation), and `src/main/resources/dwl/v_flowRef.dwl` (routing rules) if the route pattern changes.
- When changing auth or credentials: check `src/main/resources/properties.yaml` and `src/main/resources/beans.xml`.
- When changing UI assets: check `src/main/resources/web/` and `src/main/mule/net-tools.xml` which maps MIME types via DWL scripts in `src/main/resources/dwl`.

## Quick examples (copyable snippets)
- DWL import example used across flows:

  %dw 2.0
  output application/java
  import java!com::mulesoft::tool::network::NetworkUtils

  ---
  NetworkUtils::ping("example.com")

- How flows validate parameters: look for `<json:validate-schema schema="/schemas/ping-get.schema.json">` in `net-tools.xml`.

## What to avoid / gotchas
- Don't run or rely on native binaries in CI without explicit mocking — tests in `src/test/munit/` mock `NetworkUtils` behavior.
- Changing public Java APIs (NetworkUtils) requires updating DWL calls and MUnit tests.
- The app includes both HTTP and HTTPS listener-configs; setting both ports to the same value will prevent the app from starting in some runtimes (see README). Keep `httpPort` != `httpsPort`.

If anything above is unclear or you want more detail (test running locally, MUnit specifics, or a short dev container setup), tell me which area to expand and I will iterate.
