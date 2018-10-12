cmake_minimum_required(VERSION 3.9)

# INTERFACE_LINK_LIBRARIES defines the link interface
cmake_policy( SET CMP0022 NEW )

# enforce double colon in target name means ALIAS or IMPORTED target
cmake_policy( SET CMP0028 NEW )

# Version schema: major = year, minor = submission phase, patch = patch version
project( frvt VERSION 2018.4.0 )

# make default install path sub-path of binary directory
#if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
#  set( CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install-frvt1N" CACHE PATH "Default frvt1N install path" FORCE )
#endif()

# Configure the default installation directories but offer the user the choice
# of overriding the locations
set( INCLUDE_INSTALL_DIR include CACHE PATH "Installation directory for header files" )
set( LIB_INSTALL_DIR lib CACHE PATH "Installation directory for libraries" )
set( BIN_INSTALL_DIR bin CACHE PATH "Installation directory for executables" )
set( CMAKE_INSTALL_DIR ${LIB_INSTALL_DIR}/cmake/${PROJECT_NAME} CACHE PATH "Installation directory for CMake files" )


set( ${PROJECT_NAME}_PUBLIC_HEADERS
    ${CMAKE_CURRENT_LIST_DIR}/include/${PROJECT_NAME}/frvt1N.h
    ${CMAKE_CURRENT_LIST_DIR}/include/${PROJECT_NAME}/frvt_structs.h
    #${CMAKE_CURRENT_LIST_DIR}/include/${PROJECT_NAME}/frvt_platform.h
)


add_library( ${PROJECT_NAME} INTERFACE )
add_library( ${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME} )


target_sources( ${PROJECT_NAME} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include/${PROJECT_NAME}/frvt1N.h>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include/${PROJECT_NAME}/frvt_structs.h>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}/frvt1N.h>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}/frvt_structs.h>
)


target_compile_features( ${PROJECT_NAME}
  INTERFACE
    cxx_std_11
)


# setup include directories
target_include_directories( ${PROJECT_NAME}
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
    $<INSTALL_INTERFACE:include>
)


install(
  TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}Targets
)


install(
  EXPORT ${PROJECT_NAME}Targets
  FILE ${PROJECT_NAME}Targets.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION lib/cmake/${PROJECT_NAME}
)


include(CMakePackageConfigHelpers)
configure_package_config_file(${PROJECT_NAME}Config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_DIR}
  PATH_VARS INCLUDE_INSTALL_DIR LIB_INSTALL_DIR BIN_INSTALL_DIR CMAKE_INSTALL_DIR
)


### Create a common ${PROJECT_NAME}ConfigVersion.cmake file for both build and install tree
configure_file( ${PROJECT_NAME}ConfigVersion.cmake.in
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake" @ONLY
)


# create export file which can be imported by other cmake projects
install( EXPORT frvtTargets
  DESTINATION lib/cmake/${PROJECT_NAME}
)


install( FILES
  $<TARGET_PROPERTY:${PROJECT_NAME},INTERFACE_SOURCES>
  DESTINATION include/${PROJECT_NAME} )


install( FILES
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  DESTINATION lib/cmake/${PROJECT_NAME}
)
