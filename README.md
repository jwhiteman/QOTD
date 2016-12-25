# QOTD

This is a just-for-fun [Quote of the Day Server](https://en.wikipedia.org/wiki/QOTD), in Ruby.

There are 6 modes to choose from, via the config hash:
- evented
- thread pool
- prefork
- process-per-request
- thread-per-request
- serial

Both the process-per-request and thread-per-request are not using any limiting at all, so both will grow without bound if enough concurrent requests come in.

## Usage

```
Usage: bin/server [options]
    -s, --strategy STRATEGY          Strategy to be used
    -p, --processes PROCESSES        Number of processes (Prefork only)
    -P, --port PORT                  Port to use
    -H, --host HOST                  Host to use
    -t, --threads THREADS            Number of threads (Thread Pool only)
    -v, --verbose                    Use verbose output
    -h, --help                       Prints this help
```

After you launch the server you can make requests via the command line.

Assuming that you run the server on "127.0.0.1" and are using port 10017:

`echo "GET authors\r\n" | nc localhost 10017`

This will return a list of authors to choose from.

To get the day's quote from any particular author:

`echo "GET quote orwell\r\n" | nc localhost 10017`

The above line would return a quote from orwell.

## Benchmarking

There is a not-so-great benchmarking script that's still pretty fun to play around with:

```
Usage: bin/benchmark [options]
    -c, --clients CLIENTS            Number of clients
    -r, --requests REQUESTS          Number of requests
    -p, --processes PROCESSES        Number of processes (Prefork only)
    -t, --threads THREADS            Number of threads (Thread Pool only)
    -v, --verbose                    Use verbose output
    -h, --help                       Prints this help
```

You could run it like so:

`bin/benchmark -c 50 -r 10 -p 4 -t 25`

In this example, you'd create 50 concurrent clients, each making 10 requests. The prefork strategy would use 4 processes, the thread pool would have 25 threads.
