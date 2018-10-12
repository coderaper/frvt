cmake_minimum_required(VERSION 3.9)

# INTERFACE_LINK_LIBRARIES defines the link interface
cmake_policy( SET CMP0022 NEW )

# enforce double colon in target name means ALIAS or IMPORTED target
cmake_policy( SET CMP0028 NEW )

# make default install path sub-path of birary directory
#if ( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
#  set( CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install-frvt11" CACHE PATH "Default install path" FORCE )
#endif ()

list( APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}" )


project( testdriver )

#find_package( frvt CONFIG REQUIRED )

# If library implementation name is not defined try to get it from environment
if ( NOT DEFINED FRVTMORPH_IMPL_LIB )
  message( STATUS "FRVTMORPH_IMPL_LIB is not defined, going to check environment." )
  if ( NOT "$ENV{FRVTMORPH_IMPL_LIB}" STREQUAL "" )
    set( FRVTMORPH_IMPL_LIB $ENV{FRVTMORPH_IMPL_LIB}  CACHE INTERNAL "FRVTMORPH_IMPL_LIB copy from environment variable")
  else()
    message( STATUS "There is no FRVTMORPH_IMPL_LIB environment variable defined." )
  endif ()
endif ( NOT DEFINED FRVTMORPH_IMPL_LIB )

# Check if library implementation name is available and valid
if ( NOT DEFINED FRVTMORPH_IMPL_LIB )
 message( FATAL_ERROR "FRVTMORPH_IMPL_LIB is not defined!\n CMake will exit." )
else ( NOT DEFINED FRVTMORPH_IMPL_LIB )
  if ( "${FRVTMORPH_IMPL_LIB}" STREQUAL "" )
    message( FATAL_ERROR "FRVTMORPH_IMPL_LIB is empty!\n CMake will exit." )
  endif ( "${FRVTMORPH_IMPL_LIB}" STREQUAL "" )
endif ( NOT DEFINED FRVTMORPH_IMPL_LIB )


# Set default validation input location if no custom one is defined
if ( NOT DEFINED VALIDATION_INPUT_SRC_DIR )
    set( VALIDATION_INPUT_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/input" )
endif ( NOT DEFINED VALIDATION_INPUT_SRC_DIR )

if ( NOT DEFINED VALIDATION_INPUT_SRC_DIR )
 message( FATAL_ERROR "VALIDATION_INPUT_SRC_DIR is not defined!\n CMake will exit." )
else ( NOT DEFINED VALIDATION_INPUT_SRC_DIR )
  if( NOT EXISTS "${VALIDATION_INPUT_SRC_DIR}" )
    message( FATAL_ERROR "VALIDATION_INPUT_SRC_DIR does not exist!\n CMake will exit." )
  endif ( NOT EXISTS "${VALIDATION_INPUT_SRC_DIR}" )
  if( NOT IS_DIRECTORY "${VALIDATION_INPUT_SRC_DIR}" )
    message( FATAL_ERROR "VALIDATION_INPUT_SRC_DIR is not a directory!\n CMake will exit." )
  endif ( NOT IS_DIRECTORY "${VALIDATION_INPUT_SRC_DIR}" )
endif ( NOT DEFINED VALIDATION_INPUT_SRC_DIR )


# Set default validation images location if no custom one is defined
if ( NOT DEFINED VALIDATION_IMAGES_SRC_DIR )
    set( VALIDATION_IMAGES_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/images" )
endif ( NOT DEFINED VALIDATION_IMAGES_SRC_DIR )

if ( NOT DEFINED VALIDATION_IMAGES_SRC_DIR )
 message( FATAL_ERROR "VALIDATION_IMAGES_SRC_DIR is not defined!\n CMake will exit." )
else ( NOT DEFINED VALIDATION_IMAGES_SRC_DIR )
  if( NOT EXISTS "${VALIDATION_IMAGES_SRC_DIR}" )
    message( FATAL_ERROR "VALIDATION_IMAGES_SRC_DIR does not exist!\n CMake will exit." )
  endif ( NOT EXISTS "${VALIDATION_IMAGES_SRC_DIR}" )
  if( NOT IS_DIRECTORY "${VALIDATION_IMAGES_SRC_DIR}" )
    message( FATAL_ERROR "VALIDATION_IMAGES_SRC_DIR is not a directory!\n CMake will exit." )
  endif ( NOT IS_DIRECTORY "${VALIDATION_IMAGES_SRC_DIR}" )
endif ( NOT DEFINED VALIDATION_IMAGES_SRC_DIR )


set( TESTDRIVER_TARGET_NAME "validatemorph_${FRVTMORPH_IMPL_LIB}" )

#link_directories( ${CMAKE_INSTALL_PREFIX}/lib )

add_executable ( ${TESTDRIVER_TARGET_NAME}
  ${CMAKE_CURRENT_LIST_DIR}/src/validate.cpp
  ${CMAKE_CURRENT_LIST_DIR}/include/frvt/util.h
  ${CMAKE_CURRENT_LIST_DIR}/src/util.cpp
)

# require C++11 standard
set_target_properties( ${TESTDRIVER_TARGET_NAME}
  PROPERTIES
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
)

# Build executable link to dependent libraries
#add_executable (validate11 util.cpp validate11.cpp)
#target_link_libraries (validate11 ${FRVT_IMPL_LIB})

# configure target include directories
target_include_directories( ${TESTDRIVER_TARGET_NAME}
  PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/include
    ${CMAKE_CURRENT_LIST_DIR}/src
    ${PROJECT_BINARY_DIR}/include
)

# configure target link libraries
target_link_libraries( ${TESTDRIVER_TARGET_NAME}
  PRIVATE
#    frvt::frvt
    ${FRVTMORPH_IMPL_LIB}
)

set_target_properties( ${TESTDRIVER_TARGET_NAME}
  PROPERTIES
    INSTALL_RPATH "$ORIGIN/../lib:$ORIGIN"
)


install( TARGETS ${TESTDRIVER_TARGET_NAME}
  RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
  ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
#  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_PREFIX}/include/frvt
#  INCLUDES DESTINATION ${CMAKE_INSTALL_PREFIX}/include/frvt
)


set( VALIDATION_IMAGES_LINK_DIR ${CMAKE_INSTALL_PREFIX}/images )
add_custom_target( link_validation_images
                   COMMAND ${CMAKE_COMMAND} -E create_symlink
                   ${VALIDATION_IMAGES_SRC_DIR}
                   ${VALIDATION_IMAGES_LINK_DIR}
                   DEPENDS ${VALIDATION_IMAGES_SRC_DIR}
                   BYPRODUCTS ${VALIDATION_IMAGES_LINK_DIR}
                   COMMENT "Creating symbolic link to the validation images..."
)


set( VALIDATION_INPUT_LINK_DIR ${CMAKE_INSTALL_PREFIX}/input )
add_custom_target( link_validation_input
                   COMMAND ${CMAKE_COMMAND} -E create_symlink
                   ${VALIDATION_INPUT_SRC_DIR}
                   ${VALIDATION_INPUT_LINK_DIR}
                   DEPENDS ${VALIDATION_INPUT_SRC_DIR}
                   BYPRODUCTS ${VALIDATION_INPUT_LINK_DIR}
                   COMMENT "Creating symbolic link to the validation input..."
)


install(
    FILES
      ${CMAKE_CURRENT_LIST_DIR}/scripts/compileAndLink.sh
      ${CMAKE_CURRENT_LIST_DIR}/scripts/buildImpl.sh
      ${CMAKE_CURRENT_LIST_DIR}/scripts/runTestdriver.sh
    DESTINATION ${CMAKE_INSTALL_PREFIX}/scripts
    PERMISSIONS
      OWNER_WRITE OWNER_READ OWNER_EXECUTE
      GROUP_WRITE GROUP_READ GROUP_EXECUTE
#     WORLD_WRITE WORLD_READ WORLD_EXECUTE
)


install(
    FILES
      ${CMAKE_CURRENT_LIST_DIR}/scripts/runValidate.sh
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    PERMISSIONS
      OWNER_WRITE OWNER_READ OWNER_EXECUTE
      GROUP_WRITE GROUP_READ GROUP_EXECUTE
#     WORLD_WRITE WORLD_READ WORLD_EXECUTE
)


install( CODE "execute_process( COMMAND \"${CMAKE_COMMAND}\"
  --build \"${CMAKE_CURRENT_BINARY_DIR}\"
  --target link_validation_images )"
)


install( CODE "execute_process( COMMAND \"${CMAKE_COMMAND}\"
  --build \"${CMAKE_CURRENT_BINARY_DIR}\"
  --target link_validation_input )"
)
