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

# Specify build paths
set(PROJECT_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/output")
file(MAKE_DIRECTORY ${PROJECT_OUTPUT_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_OUTPUT_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_OUTPUT_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_OUTPUT_DIR}/bin")
set(CMAKE_INSTALL_PREFIX "${PROJECT_OUTPUT_DIR}/dist")

# Google Filament
if (UNIX AND NOT APPLE AND NOT ANDROID AND NOT WEBGL)
    set(LINUX TRUE)
else()
    # since cmake 3.25 LINUX is automatically set based on CMAKE_SYSTEM_NAME, which the android
    # cmake files are setting to "Linux".
    set(LINUX FALSE)
endif()

# Backup default CXX flags
set(DEFAULT_CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})

if (LINUX)
  execute_process( COMMAND ${CMAKE_CXX_COMPILER} --version OUTPUT_VARIABLE clang_full_version_string )
  string (REGEX REPLACE ".*clang version ([0-9]+\\.[0-9]+).*" "\\1" CLANG_VERSION_STRING ${clang_full_version_string})
  if (CLANG_VERSION_STRING VERSION_GREATER_EQUAL 14)
    message(STATUS "Detected clang ${CLANG_VERSION_STRING}>=14.0 Adding -fno-builtin and -lm.")
    set(CMAKE_CXX_FLAGS "-fno-builtin")
    link_libraries("-lm")
  endif()
endif()

AddExternalProject(filament https://github.com/google/filament.git v1.31.2)
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

# Restore default CXX flags
set(CMAKE_CXX_FLAGS ${DEFAULT_CMAKE_CXX_FLAGS})

if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
  add_definitions(-DAPP_DEBUG)
endif()

# Support both 32 and 64 bit builds
if (${CMAKE_SIZEOF_VOID_P} MATCHES 8)
  set(BUILD_ARCH "x64")
else ()
  set(BUILD_ARCH "x86")
endif ()

# Platform specific configuration
if(WIN32)
  add_definitions(-DPLATFORM_WINDOWS)
elseif (UNIX)
  add_definitions(-DPLATFORM_LINUX)
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -Wall -Werror -Wno-c++17-extensions -Wno-unused-command-line-argument")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  message(FATAL_ERROR "GCC not supported yet")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  # using Intel C++
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -W3")
endif()

if (LINUX)
  find_package(Threads REQUIRED)
  link_libraries("-static-libgcc -static-libstdc++")
  link_libraries(libc++.a)
  link_libraries(libc++abi.a)  
endif()

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

# Application/Libraries Source
foreach(APP_LIB ${APP_LIBRARIES})
  message(STATUS "Adding library: '${APP_LIB}'")
endforeach()

foreach(APP_EXECUTABLE ${APP_EXECUTABLES})
  message(STATUS "Adding executable: '${APP_EXECUTABLE}'")
  AddExecutable(${APP_EXECUTABLE})
endforeach()

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