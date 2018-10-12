cmake_minimum_required(VERSION 3.9)

# make default install path sub-path of binary directory
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set( CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install-morph" CACHE PATH "Default frvt11 install path" FORCE )
endif()

# Build FRVT MORPH API library
add_subdirectory(frvt)

# Build the null FRVT MORPH library implementation
add_subdirectory(morph_null_impl)

# Build the MORPH test driver
add_subdirectory(testdriver)
