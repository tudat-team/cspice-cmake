#    Copyright (c) 2010-2019, Delft University of Technology
#    All rigths reserved
#
#    This file is part of the Tudat. Redistribution and use in source and
#    binary forms, with or without modification, are permitted exclusively
#    under the terms of the Modified BSD license. You should have received
#    a copy of the license with this file. If not, please or visit:
#    http://tudat.tudelft.nl/LICENSE.
#
#    Note that this license only applies to this CMakeLists.txt file, not the
#    cspice library itself
#

# Specify minimum CMake version required to compile cspice.
cmake_minimum_required( VERSION 2.6 )

# Specific project name.
project( CSpice )

# Detect if CSPICE is build standalone or from within project
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
  message(STATUS "Building ${PROJECT_NAME} standalone.")
  include("${CMAKE_CURRENT_SOURCE_DIR}/UserSettings.txt" OPTIONAL)
else()
  message(STATUS "Building ${PROJECT_NAME} from within ${CMAKE_PROJECT_NAME}.")
  include("${CMAKE_CURRENT_SOURCE_DIR}/UserSettings.txt" OPTIONAL)
  include("${CMAKE_SOURCE_DIR}/UserSettings.txt" OPTIONAL)
  set(PROJECTROOT ${PROJECTROOT} PARENT_SCOPE)
endif()

# Define the basic input (trunk).
set(SRCROOT ${PROJECT_SOURCE_DIR})

set(LIBROOT "${SRCROOT}/lib")
set(BINROOT "${SRCROOT}/bin")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -g -Wno-incompatible-pointer-types")
# Hide warnings for implicit-int and incompatible-pointer-types

# Set CMake build-type. If it not supplied by the user (either directly as an argument of through
# the "UserSettings.txt" file, the default built type is "Release". NB: It is important this
# section is placed AFTER the "UserSettings.txt" file is included, to ensure that that the correct
# indiciation is given for which build type has been selected.
if((NOT CMAKE_BUILD_TYPE) OR (CMAKE_BUILD_TYPE STREQUAL "Release"))
   message(STATUS "WARNING: building release version!")
   set(CMAKE_BUILD_TYPE Release)
elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
   message(STATUS "WARNING: building debug version!")
endif()

# Set the global macros for setting up targets.
macro(setup_library_target target_name CUSTOM_OUTPUT_PATH)
 set_property(TARGET ${target_name} PROPERTY LIBRARY_OUTPUT_DIRECTORY "${LIBROOT}")
 set_property(TARGET ${target_name} PROPERTY ARCHIVE_OUTPUT_DIRECTORY "${LIBROOT}")
 install(TARGETS ${target_name} LIBRARY DESTINATION "${BINROOT}" ARCHIVE DESTINATION "${LIBROOT}")
endmacro(setup_library_target)

#Set the source files.
file(GLOB_RECURSE CSPICE_HEADERS ${SRCROOT}/src/cspice RELATIVE ${SRCROOT} *.h)
file(GLOB_RECURSE CSPICE_SOURCES ${SRCROOT}/src/cspice RELATIVE ${SRCROOT} *.c)


# Add static libraries.
add_library(cspice STATIC ${CSPICE_SOURCES} ${CSPICE_HEADERS})
setup_library_target(cspice "${SRCROOT}/src/cspice")

# End of file.
