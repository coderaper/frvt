cmake_minimum_required(VERSION 3.9)

# make default install path sub-path of binary directory
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set( CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install-frvt11" CACHE PATH "Default frvt11 install path" FORCE )
endif()

# Build FRVT 1:1 API library
add_subdirectory(frvt)

# Build the null FRVT 1:1 library implementation
add_subdirectory(frvt11_null_impl)

# Build the 1:1 test driver
add_subdirectory(testdriver)
