cmake_minimum_required(VERSION 3.5)

include(Project.cmake)
include(cmake/Unittest.cmake)
include(cmake/ExternalDeps.cmake)
include(cmake/Build.cmake)

project(
  CPP_APP
  VERSION ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${APP_VERSION_RELEASE}
  DESCRIPTION ${APP_DESCRIPTION}
  HOMEPAGE_URL ${APP_HOMEPAGE_URL}
  LANGUAGES CXX C
)

if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
  add_definitions(-DCPP_APP_DEBUG)
endif()

# Support both 32 and 64 bit builds
if (${CMAKE_SIZEOF_VOID_P} MATCHES 8)
  set(BUILD_ARCH "x64")
else ()
  set(BUILD_ARCH "x86")
endif ()

# Platform specific configuration
if(WIN32)
  add_definitions(-DCPP_APP_PLATFORM_WINDOWS)
elseif (UNIX)
  add_definitions(-DCPP_APP_PLATFORM_LINUX)
endif(WIN32)

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  # Find CMake file for Clang
  find_package(Clang REQUIRED)
  message(STATUS "CLANG_INCLUDE_DIRS : ${CLANG_INCLUDE_DIRS}")
  include_directories(
    ${CLANG_INCLUDE_DIRS}
    "${CLANG_INCLUDE_DIRS}/c++/v1/"
  )
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libstdc++ -Wall -Wno-c++17-extensions -fno-builtin")
  # POSIX Threads
  find_package(Threads REQUIRED)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  message(FATAL_ERROR "GCC not supported yet")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  # using Intel C++
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -W3")
endif()

# Specify build paths
set(PROJECT_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/output")
file(MAKE_DIRECTORY ${PROJECT_OUTPUT_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_OUTPUT_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_OUTPUT_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_OUTPUT_DIR}/bin")
set(CMAKE_INSTALL_PREFIX "${PROJECT_OUTPUT_DIR}/dist")

# Activate Unit Testing
if(NOT DEFINED ENV{CPP_APP_NO_TESTS})
  add_definitions(-DCPP_APP_TESTS)
endif()

# Pass version variables to Application
configure_file(config.h.in config.h @ONLY)

# Allow config.h to be visible
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Include custom configuration if required
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/config.cmake")
  message(STATUS "Adding custom configuration: config.cmake")
  include("${CMAKE_CURRENT_SOURCE_DIR}/config.cmake")
endif()

while(APP_EXTERNAL_PROJECTS)
  list(POP_FRONT APP_EXTERNAL_PROJECTS PRJ_NAME PRJ_GIT_REPO PRJ_GIT_TAG)
  message(STATUS ${PRJ_NAME} ${PRJ_GIT_REPO} ${PRJ_GIT_TAG} )
  AddExternalProject(${PRJ_NAME} ${PRJ_GIT_REPO} ${PRJ_GIT_TAG})
endwhile()

# Google Filament
AddExternalProject(filament git@github.com:alexyz79/filament.git main)
set(FILAMENT_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/filament-src/filament/include")

set(FILAMENT_LIBS 
  filament 
  backend 
  bluegl 
  bluevk 
  filabridge 
  filaflat 
  utils 
  geometry 
  smol-v 
  vkshaders 
  ibl
)

# Application/Libraries Source
foreach(APP_LIB ${APP_LIBRARIES})
  message(STATUS "Adding library: '${APP_LIB}'")
endforeach()

foreach(APP_EXECUTABLE ${APP_EXECUTABLES})
  message(STATUS "Adding executable: '${APP_EXECUTABLE}'")
  AddExecutable(${APP_EXECUTABLE})
endforeach()

if(DEFINED ENV{APP_NO_BUILD_TESTS})
  set(APP_BUILD_TESTS OFF)
endif()

if(APP_BUILD_TESTS)

  # Since filament already have google test we just reuse it
  include_directories("${CMAKE_CURRENT_BINARY_DIR}/filament-src/third_party/libgtest/googletest/include")

  enable_testing()
  include(Dart)

  ListTests(UNITTESTS)

  foreach(UNITTEST ${UNITTESTS})
    AddUnitTest(${UNITTEST})
  endforeach()

endif() 

# Debug CMake Vars, uncomment to show CMake vars
# get_cmake_property(_variableNames VARIABLES)
# list (SORT _variableNames)
# foreach (_variableName ${_variableNames})
#     message(STATUS "${_variableName}=${${_variableName}}")
# endforeach()