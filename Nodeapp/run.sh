#!/bin/bash
docker build -i ./dockerfile -t myapp:latest
docker run -itd -p 3000:3000 myapp:latest 