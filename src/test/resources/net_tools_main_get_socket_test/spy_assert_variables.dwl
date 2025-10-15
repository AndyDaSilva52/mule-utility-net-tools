%dw 2.0
import * from dw::test::Asserts
---
vars must [
  haveKey('basePath'),
  haveKey('flowRef'),
  $['basePath'] must equalTo("/api/*"),
  $['flowRef'] must equalTo({
    "name": "get.\\socket.net-tools-config"
  })
]