#! /usr/bin/fish
# ulimit defined below will override configuration in Occlum.json
ulimit -Sv 13240000 # virtual memory size 100M (including heap, stack, mmap size)

/bin/python3 /bin/src/main.py