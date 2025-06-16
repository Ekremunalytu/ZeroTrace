cmake_minimum_required(VERSION 3.16)
project(ProcessCollector)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include directories
include_directories(include)

# Source files
set(SOURCES
    src/main.cpp
)

# Create executable
add_executable(process-collector ${SOURCES})

# For future: Google Test integration
# find_package(GTest REQUIRED)
# enable_testing()
# add_subdirectory(tests)
