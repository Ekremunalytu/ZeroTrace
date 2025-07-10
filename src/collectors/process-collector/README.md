# Process Collector

This service monitors system processes and collects data for security analysis.

## Build

```bash
# From main directory:
mkdir build && cd build
cmake ..
make process-collector

# Or to build only this service:
cd services/collectors/process-collector
mkdir build && cd build
cmake ..
make
```

## Run

```bash
./process-collector
```

## Development

- **Header files**: in `include/` folder
- **Source files**: in `src/` folder  
- **Tests**: in `tests/` folder (GTest will be used)

## TODO

- [ ] Read system process list
- [ ] Memory usage monitoring
- [ ] Network connections tracking
- [ ] Write unit tests with GTest
