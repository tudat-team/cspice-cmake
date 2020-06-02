
# defined since 2.8.3
if (CMAKE_VERSION VERSION_LESS 2.8.3)
  get_filename_component (CMAKE_CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_FILE} PATH)
endif ()

# Tell the user project where to find our headers and libraries

set (CSpice_VERSION "1.0.0")

set (CSpice_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../../include")
set (CSpice_LIBRARY_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../")
set (CSpice_DATA_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../../data")

# Allows loading CSpice settings from another project
set (CSpice_CONFIG_FILE "${CMAKE_CURRENT_LIST_FILE}")

# List of compilation flags -DTOTO to export
set (CSpice_DEFINITIONS "")

# Our library dependencies (contains definitions for IMPORTED targets)
include ("${CMAKE_CURRENT_LIST_DIR}/cspice_export.cmake")

# These are IMPORTED targets created by NLOPTLibraryDepends.cmake
set (CSpice_LIBRARIES "")

if (CMAKE_VERSION VERSION_LESS 2.8.3)
  set (CMAKE_CURRENT_LIST_DIR)
endif ()

