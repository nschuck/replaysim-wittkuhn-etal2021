# Replay Simulations

Code for Review illustration in Wittkuhn, Chien, McMaster, Schuck

## Citation

```
Wittkuhn, L., Chien, S., Hall-McMaster, S., and Schuck, N. W. (2021). *Replay in minds and machines*. Neuroscience & Biobehavioral Reviews, 129:367–388. doi: [10.1016/j.neubiorev.2021.08.002](https://doi.org/10.1016/j.neubiorev.2021.08.002)
```

## Build

### Make

```bash
make all
```

### Docker

```bash
docker login
```

```bash
docker build -t lennartwittkuhn/replaysim-wittkuhn-etal2021:latest .
```

```bash
docker push lennartwittkuhn/replaysim-wittkuhn-etal2021:latest
```

```bash
docker run --rm -v $PWD:/home lennartwittkuhn/replaysim-wittkuhn-etal2021 /bin/sh -c "cd /home; make all"
```
