cmake_minimum_required(VERSION 3.16)
project(ZeroTrace)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable testing
enable_testing()

# Include subdirectories with CMake projects
add_subdirectory(src/collectors/process-collector)

# Add any additional configuration here
message(STATUS "Configuring ZeroTrace project...")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Add compiler flags
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(-g -O0)
    else()
        add_compile_options(-O3)
    endif()
endif()

# Add install targets
# Note: Add specific targets when implementing actual executables
# install(TARGETS process-collector DESTINATION bin)
