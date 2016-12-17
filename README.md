# QOTD

A Quote of the Day Server

## Client

"GET authors\r\n"
"GET version\r\n"
"GET quote <author-id>\r\n"

MAX quote length: 512 bytes


## Server
"OK quote\r\n"
"<quote>"
"DONE\r\n"

"OK version\r\n
"<version>"
"DONE\r\n"

"OK authors\r\n"
"<author-1>\n"
"<author-2>\n"
"<author-3>\n"
"DONE\r\n"

"FAIL\r\n"
"DONE\r\n"
