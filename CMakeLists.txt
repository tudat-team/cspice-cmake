#     Copyright (c) 2010-2012 Delft University of Technology.
#
#    This software is protected by national and international copyright.
#    Any unauthorized use, reproduction or modification is unlawful and
#    will be prosecuted. Commercial and non-private application of the
#    software in any form is strictly prohibited unless otherwise granted
#    by the authors.
#
#    The code is provided without any warranty; without even the implied
#    warranty of merchantibility or fitness for a particular purpose.
#
#    Changelog
#      YYMMDD    Author            Comment
#      110820    S.M. Persson      File created.
#      111025    K. Kumar          Adapted file to work with Revision 194.
#      111026    K. Kumar          Adapted file so all headers show in project tree in Qt Creator.
#      130111    D. Dirkx          Modified for separate spice compilation
#/

# Specify minimum CMake version required to compile Tudat.
cmake_minimum_required( VERSION 2.6 )

# Specific Tudat project name.
project( CSpice )

# Define the basic input (trunk).
set(SRCROOT ${PROJECT_SOURCE_DIR})

set(LIBROOT "${SRCROOT}/lib")
set(BINROOT "${SRCROOT}/bin")

 set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall -g -Woverloaded-virtual -Wold-style-cast -Wnon-virtual-dtor")


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
