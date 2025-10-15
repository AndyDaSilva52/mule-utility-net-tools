%dw 2.0
import * from dw::test::Asserts
---
vars must [
  haveKey('basePath'),
  haveKey('flowRef'),
  $['basePath'] must equalTo("/api/*"),
  $['flowRef'] must equalTo({
    "name": "post.\\curl.text\plain.net-tools-config"
  })
]