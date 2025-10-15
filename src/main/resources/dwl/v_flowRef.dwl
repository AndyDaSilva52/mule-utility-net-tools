%dw 2.0
output application/java

var separator = '.' // default is ':'

var basePath = '/api'

// Define the list of allowed paths for GET requests for easy maintenance.
var allowedGetPaths = [
  "curl", "dns", "ping",
  "socket",
  "certest", "ciphertest", "traceroute"
]

// Extract the request path without the leading slash, e.g., "/ping" -> "ping".
var requestPath = (attributes.requestPath replace basePath with '')[1 to -1]
---
upper(attributes.method) match {
  case 'GET'  -> (
        if (allowedGetPaths contains requestPath)
            // If the path is in the allowed list, construct the flow name.
            // Example: "get.\ping.net-tools-config"
            {
                name: "get$(separator)\\" ++ requestPath ++ "$(separator)net-tools-config"
            }
        else
            {
                name: null,
                httpStatus: 404,
                message: "Resource [" ++ attributes.requestPath ++ "] not found."
            }
  )
  case 'POST' -> (
        requestPath match {
            case "curl" ->
                // Construct the flow name using the path and the sanitized content-type.
                // 1. Get content-type from headers, default if not present.
                // 2. Convert to lowercase.
                // 3. Replace '/' with '\' to match the required format.
                // Example Result: "post.\curl.text\plain.net-tools-config"
                {
                    name: "post$(separator)\\curl$(separator)" ++ (
                      ((lower(attributes.headers."content-type" default "application/octet-stream") replace "/" with "\\") splitBy ";")[0]
                    ) ++ "$(separator)net-tools-config"
                }
            else ->
                // If the path is not supported for POST, return a 404 error object.
                {
                    name: null,
                    httpStatus: 404,
                    message: "Resource [" ++ attributes.requestPath ++ "] not found."
                }
        }
  )
  else -> {
    name: null,
    httpStatus: 405,
    message: "Method [" ++ attributes.method ++ "] not allowed."
  }
}





/**
var rootFileName = 'net-tools'

var xml = readUrl('classpath://$(rootFileName).xml','application/xml')
var apikitFlows = ["$(rootFileName)-main","$(rootFileName)-console"]
var availableFlows = ( (xml.mule.*flow.@name -- apikitFlows) )

var separator = '.' // default is :

var requestAttributes = {
    method: attributes.method,
    rawRequestPath: attributes.rawRequestPath,
}


//* Finds a matching flow from a list based on the request's method and path,
//* following APIkit's naming convention.
//* @param attributes The request attributes, containing method and rawRequestPath.
//* @param flows An array of available flow names in the application.
//* @return The name of the matching flow, or null if not found.
//*
fun findMatchingFlow(attributes, flows) = do {
    
    var methodPrefix = lower(attributes.method) ++ "$(separator)"
    
    // 1. Filter flows to find potential candidates based on the HTTP method.
    var candidates = (flows filter ($ startsWith methodPrefix)) default []

    // 2. Map candidates to check if they match the request path.
    var matches = candidates map ((flowName, index) -> do {
        // A more robust way to extract the path pattern from the middle of the flow name.
        var pathPattern = dw::core::Strings::substringBefore(
            dw::core::Strings::substringAfter(
                flowName, methodPrefix
            )
        , "$(separator)$(rootFileName)-config")

        // Convert the APIkit URI parameter syntax `(param)` into a regex capture group `([^/]+)`.
        var pathRegex = ("^" ++ (pathPattern replace /\((.*?)\)/ with "([^\\\\/]+)") ++ "\$") as Regex
        ---
        {
            flowName: flowName,
            // FIX 2: Corrected the regex match syntax.
            // The `matches` operator is an infix operator (string matches regex),
            // not a function call `matches(string, regex)`.
            isMatch: true//attributes.rawRequestPath matches pathRegex
        }
    })
    ---
    // 3. Find the first flow that resulted in a match.
    (matches filter ($.isMatch))[0].flowName default null
}
---
{
  "request": {
    "method": attributes.method,
    "path"  : attributes.rawRequestPath,
  },
  "matchedFlow": findMatchingFlow(requestAttributes, availableFlows)
}
*/