cmake_minimum_required(VERSION 3.9)

# INTERFACE_LINK_LIBRARIES defines the link interface
cmake_policy( SET CMP0022 NEW )

# enforce double colon in target name means ALIAS or IMPORTED target
cmake_policy( SET CMP0028 NEW )

project( frvtmorph_null VERSION 2018.4.0 )

#include(GenerateExportHeader)

# make default install path sub-path of birary directory
#if ( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
#  set( CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install-frvt11" CACHE PATH "Default install path" FORCE )
#endif ()

list( APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}" )
#list( APPEND CMAKE_PREFIX_PATH "${CMAKE_BINARY_DIR}/exports" )

message( STATUS "CMAKE_PREFIX_PATH = ${CMAKE_PREFIX_PATH}")

#find_package( frvt REQUIRED )

# The FRVT MORPH null SDK product name
set( ${PROJECT_NAME}_PRODUCT_NAME "NIST Null Implementation" )

configure_file (
  "doc/version.txt.in"
  "${PROJECT_BINARY_DIR}/doc/version.txt"
   @ONLY
)

# Add the FRVT MORPH shared library
add_library( frvtmorph_null_001 SHARED )


target_sources( frvtmorph_null_001
  PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/nullimplfrvtmorph.cpp
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/nullimplfrvtmorph.h>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}/nullimplfrvtmorph.h>
)


# configure target link libraries
target_link_libraries( frvtmorph_null_001
  PUBLIC
    frvt::frvt
)


install( TARGETS frvtmorph_null_001
#  EXPORT frvt11_null_Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
  ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_PREFIX}/include/frvt
  INCLUDES DESTINATION ${CMAKE_INSTALL_PREFIX}/include/frvt
)


install( FILES "${PROJECT_BINARY_DIR}/doc/version.txt"
    DESTINATION ${CMAKE_INSTALL_PREFIX}/doc
    PERMISSIONS
      OWNER_WRITE OWNER_READ OWNER_EXECUTE
      GROUP_WRITE GROUP_READ GROUP_EXECUTE
#     WORLD_WRITE WORLD_READ WORLD_EXECUTE
)
