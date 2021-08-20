# Replay Simulations

[![Build](https://github.com/nschuck/replaysim-wittkuhn-etal2021/actions/workflows/main.yml/badge.svg)](https://github.com/nschuck/replaysim-wittkuhn-etal2021/actions/workflows/main.yml)

Code for Review illustration in Wittkuhn, Chien, McMaster, Schuck

## Citation

```
Wittkuhn, L., Chien, S., Hall-McMaster, S., and Schuck, N. W. (2021). *Replay in minds and machines*. Neuroscience & Biobehavioral Reviews, 129:367–388. doi: [10.1016/j.neubiorev.2021.08.002](https://doi.org/10.1016/j.neubiorev.2021.08.002)
```

## Build

### Make

You can also run the code using `make` by running the following command.

```bash
make all
```

### Docker

We've created a Docker container (see [Dockerfile](Dockerfile)) and [uploaded it](https://hub.docker.com/r/lennartwittkuhn/replaysim-wittkuhn-etal2021) to dockerhub.

#### Running the container

You can run the `make` command inside the Docker container:

```bash
docker run --rm -v $PWD:/home lennartwittkuhn/replaysim-wittkuhn-etal2021 /bin/sh -c "cd /home; make all"
```

The figures created by the simulation can be retrieved as Build Artifacts.
Search the latest executed workflow and Build Artifacts [here](https://github.com/lnnrtwttkhn/replaysim-wittkuhn-etal2021/actions/) to download the figures.

#### Building the container

The commands below were used by us to create the container.
They are listed here for documentation purposes.

```bash
docker login
```

```bash
docker build -t lennartwittkuhn/replaysim-wittkuhn-etal2021:latest .
```

```bash
docker push lennartwittkuhn/replaysim-wittkuhn-etal2021:latest
```
