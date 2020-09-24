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

# Specify minimum CMake version required to compile CSpice.
cmake_minimum_required(VERSION 3.3)

# Trick for recompiling changes for BUILD-TREE.
if (EXISTS "${CMAKE_BINARY_DIR}/CMakeCache.txt")
    file(REMOVE "${CMAKE_BINARY_DIR}/CMakeCache.txt")
endif ()

# Set cmake policy.
cmake_policy(SET CMP0069 NEW)

# Specific project name.
project(CSpice VERSION 66 LANGUAGES C)

# Get lower string name of PROJECT_NAME for directory configuration.
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
set(POSITION_INDEPENDENT_CODE True)

if (WIN32)
#    set(TKCOMPILEOPTIONS "/c /O2 /nologo -D_COMPLEX_DEFINED -DMSDOS -DOMIT_BLANK_CC -DNON_ANSI_STDIO")
    set(TKCOMPILEOPTIONS "/O2 /nologo -D_COMPLEX_DEFINED -DMSDOS -DOMIT_BLANK_CC -DNON_ANSI_STDIO")
    set(TKLINKOPTIONS "")
elseif (UNIX AND NOT APPLE)
#    set(TKCOMPILEOPTIONS "-c -std=c99 -m64 -fPIC -DNON_UNIX_STDIO")
    set(TKCOMPILEOPTIONS "-std=c99 -m64 -O2 -fPIC -DNON_UNIX_STDIO")
    set(TKLINKOPTIONS "-Wl,--whole-archive -lm -Wl,--no-whole-archive -m64")
elseif (UNIX)
#    set(TKCOMPILEOPTIONS "-m64 -c -std=c99 -fPIC -DNON_UNIX_STDIO")
    set(TKCOMPILEOPTIONS "-m64 -std=c99 -O2 -fPIC -DNON_UNIX_STDIO")
    set(TKLINKOPTIONS "-m64")
endif ()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${TKCOMPILEOPTIONS} ${TKLINKOPTIONS}")
message(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")

# +============================================================================
# BUILD OPTIONS
#  Offer the user the choice of defining the build variation.
# +============================================================================
# Build static library instead of dynamic.
option(CSPICE_BUILD_STATIC_LIBRARY "Build sofa as a static library, instead of dynamic." OFF)

# +============================================================================
# INSTALL TREE CONFIGURATION (Project name independent)
#  Offer the user the choice of overriding the installation directories.
# +============================================================================
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib/" CACHE PATH "Installation directory for libraries")
set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin/" CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/include/" CACHE PATH "Installation directory for header files")
set(INSTALL_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data/" CACHE PATH "Installation directory for data files")
set(INSTALL_MAN_DIR "${CMAKE_INSTALL_PREFIX}/" CACHE PATH "Installation directory for man documentation")
set(INSTALL_TESTS_DIR "${CMAKE_BINARY_DIR}/tests/" CACHE PATH "Installation directory for tests (default=OFF)")
set(INSTALL_CMAKE_DIR "${INSTALL_LIB_DIR}/cmake/${PROJECT_NAME_LOWER}" CACHE PATH "Installation directory for cmake config files")

# Make relative paths absolute (needed later on)
foreach (p LIB BIN INCLUDE DATA CMAKE)
    set(var INSTALL_${p}_DIR)
    set(RELATIVE_INSTALL_${p}_DIR ${INSTALL_${p}_DIR})
    if (NOT IS_ABSOLUTE "${${var}}")
        set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
    endif ()
endforeach ()

# Find relative paths for cmake-config file. (for find_package)
file(RELATIVE_PATH rel_include_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_INCLUDE_DIR}")
file(RELATIVE_PATH rel_lib_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_LIB_DIR}")
file(RELATIVE_PATH rel_data_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_DATA_DIR}")
file(RELATIVE_PATH rel_bin_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_BIN_DIR}")
file(RELATIVE_PATH rel_man_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_MAN_DIR}")

# Set relative paths for config.cmake.
foreach (p include lib data bin man)
    string(TOUPPER ${p} P)
    set(RELATIVE_INSTALL_${P}_DIR ${rel_${p}_dir})
endforeach ()

## +============================================================================
## CMAKE BUILD TREE CONFIGURATION
## +============================================================================
#set(${PROJECT_NAME_UPPER}_BINARY_LIB_DIR      "${CMAKE_BINARY_DIR}/lib/"                            CACHE PATH "Build directory for libraries")
#set(${PROJECT_NAME_UPPER}_BINARY_BIN_DIR      "${CMAKE_BINARY_DIR}/bin/"                            CACHE PATH "Build directory for executables")
#set(${PROJECT_NAME_UPPER}_BINARY_INCLUDE_DIR  "${CMAKE_BINARY_DIR}/include/"                        CACHE PATH "Build directory for header files")
#set(${PROJECT_NAME_UPPER}_BINARY_DATA_DIR     "${CMAKE_INSTALL_PREFIX}/data/${PROJECT_NAME_LOWER}/" CACHE PATH "Build directory for data files (default=OFF)")
#set(${PROJECT_NAME_UPPER}_BINARY_MAN_DIR      "${CMAKE_BINARY_DIR}/"                                CACHE PATH "Build directory for man documentation")
#set(${PROJECT_NAME_UPPER}_BINARY_TESTS_DIR    "${CMAKE_BINARY_DIR}/tests/"                          CACHE PATH "Build directory for tests")
#set(${PROJECT_NAME_UPPER}_BINARY_CMAKE_DIR    "${BINARY_LIB_DIR}/cmake/${PROJECT_NAME_LOWER}"       CACHE PATH "Build directory for cmake config files")

# Set the source and header files.
file(GLOB_RECURSE CSPICE_HEADER_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/cspice*.h)
file(GLOB_RECURSE CSPICE_SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/cspice/*.c)
message(STATUS CSPICE_SOURCE_FILES ${CSPICE_SOURCE_FILES})
# Setup of library.

if (CSPICE_BUILD_STATIC_LIBRARY)
    add_library(cspice STATIC "${CSPICE_SOURCE_FILES}")
else ()
    add_library(cspice SHARED "${CSPICE_SOURCE_FILES}")
endif ()

# Add headers to library target.
target_include_directories(cspice PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/cspice>
        $<INSTALL_INTERFACE:include/cspice>
        )

# Setup of namespaced library.
add_library(CSpice::cspice ALIAS cspice)

# Silence warnings.'
if (NOT MSVC)
    set_property(TARGET cspice APPEND PROPERTY COMPILE_OPTIONS
            "-Wno-implicit-int"
            "-Wunused-result"
            "-Wno-incompatible-pointer-types"
            "-Wno-pointer-to-int-cast"
            "-Wno-shift-op-parentheses"
            "-Wno-logical-op-parentheses"
            "-Wno-parentheses"
            "-Wno-tautological-compare"
            "-Wno-format"
            "-Wno-unsequenced")
elseif (MSVC)
    set_property(TARGET cspice APPEND PROPERTY COMPILE_OPTIONS
            "-wd4267"
            "-wd4554"
            "-wd4723"
            "-wd4244"
            "-wd4273"
            "-wd4477"
            "-wd4996"
            "-wd4311"
            "-wd4013" # src\cspice\err.c(202): warning C4013: 'isatty' undefined; assuming extern returning int (due to fix)
            "-wd4101" # src\cspice\inquire.c(16): warning C4101: 'n': unreferenced local variable
            "-wd4018" # src\cspice\zzfcstring.c(354): warning C4018: '>=': signed/unsigned mismatch
            )
endif (NOT MSVC)

set_target_properties(cspice
        PROPERTIES
        LINKER_LANGUAGE C
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        )

# Add test
add_executable(test_cspice "${CMAKE_CURRENT_SOURCE_DIR}/test/test_cspice.c")
target_link_libraries(test_cspice PUBLIC cspice)
target_include_directories(test_cspice PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>  # <prefix>/include/mylib
        )
enable_testing()
add_test(test_cspice ${CMAKE_CURRENT_BINARY_DIR}/test_cspice)

# Installation of the library.
install(TARGETS cspice
        EXPORT cspice_export
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin
        )

# Set <project>_LIBRARIES for <project>-config.cmake.
set(CSpice_LIBRARIES CSpice::cspice)

# Add to parent scope if project is added via add_subdirectory().
if (NOT ${CMAKE_PROJECT_NAME} STREQUAL ${PROJECT_NAME})
    set(CSpice_LIBRARIES CSpice::cspice PARENT_SCOPE)
endif ()

# Installation of the header files.
install(DIRECTORY include/ DESTINATION "${INSTALL_INCLUDE_DIR}")

# Installation of the data files.
install(DIRECTORY data/ DESTINATION "${INSTALL_DATA_DIR}/${PROJECT_NAME_LOWER}")

# Add all targets to the build-tree export set
export(TARGETS cspice NAMESPACE ${PROJECT_NAME}:: FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}_export.cmake")

# Installation of the export modules.
install(EXPORT ${PROJECT_NAME_LOWER}_export NAMESPACE ${PROJECT_NAME}:: DESTINATION "${RELATIVE_INSTALL_CMAKE_DIR}")

# Export the package for use from the build-tree
# (this registers the build-tree with a global CMake-registry)
set(CMAKE_EXPORT_PACKAGE_REGISTRY ON)
export(PACKAGE ${PROJECT_NAME})

# +============================================================================
# PROJECT CONFIG
#  Add the targets, libraries and tests.
# +============================================================================
configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME_LOWER}-config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config.cmake" @ONLY
)

install(
        FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config.cmake"
        DESTINATION "${INSTALL_CMAKE_DIR}"
)

# Take care of versioning.
include(CMakePackageConfigHelpers)
# NOTE: SameMinorVersion available only
# since CMake 3.11.
if (${CMAKE_VERSION} VERSION_LESS "3.11.0")
    write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config-version.cmake" VERSION ${${PROJECT_NAME}_VERSION}
            COMPATIBILITY SameMajorVersion)
else ()
    write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config-version.cmake" VERSION ${${PROJECT_NAME}_VERSION}
            COMPATIBILITY SameMinorVersion)
endif ()
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config-version.cmake" DESTINATION "${INSTALL_CMAKE_DIR}")

# +============================================================================
# CLEAN UP (Project name independent)
#  Cleanup in case project is not top level.
# +============================================================================
unset(INSTALL_LIB_DIR)
unset(INSTALL_BIN_DIR)
unset(INSTALL_INCLUDE_DIR)
unset(INSTALL_DATA_DIR)
unset(INSTALL_MAN_DIR)
unset(INSTALL_TESTS_DIR)
unset(INSTALL_CMAKE_DIR)

unset(RELATIVE_INSTALL_LIB_DIR)
unset(RELATIVE_INSTALL_BIN_DIR)
unset(RELATIVE_INSTALL_INCLUDE_DIR)
unset(RELATIVE_INSTALL_DATA_DIR)
unset(RELATIVE_INSTALL_MAN_DIR)
unset(RELATIVE_INSTALL_TESTS_DIR)
unset(RELATIVE_INSTALL_CMAKE_DIR)
