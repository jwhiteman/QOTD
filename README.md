# QOTD

A Quote of the Day Server

## Client

"GET authors\r\n"
"GET version\r\n"
"GET quote <author-id>\r\n"

MAX quote length: 512 bytes


## Server
"OK\r\n"
"<quote>"
"DONE\r\n"

or

"FAIL\r\n"
