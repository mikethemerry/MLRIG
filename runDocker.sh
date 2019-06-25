#! /bin/bash

docker run \
    --name phdtf-gpu \
    --mount type=bind,source="$(pwd)",target=/root/app \
    --runtime=nvidia\
    --rm \
    -p 8787:8787 \
    -it \
    whsu014/phdtf-gpu ./app/runJupyter.sh