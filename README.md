# MLRIG

## Use of Docker

A dockerfile and some associated `.sh` files have been created to make running
experiments with a reproducible environment more straight forward.

To build the docker environment, on a device with docker installed, use

```
./rebuildDocker.sh
```

To run the docker, you can use 

```
./runDocker.sh
```

This has all of the configuration required to bind the current working directory
to the docker image, reinstall dependencies if needed, and it then calls
`./runJupyter.sh`. This file is set up to facilitate managing the dependencies
and the specific configuration of the jupyter launch so that it works easily.