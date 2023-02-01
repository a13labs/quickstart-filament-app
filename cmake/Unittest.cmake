
function(ListTests RESULT)
# Get all available tests from APP_TESTS_FOLDER (tests_* folders)
set(APP_TESTS_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/tests" )
set(UNITTESTS "")
message(STATUS "Searching for tests in '${APP_TESTS_FOLDER}'")
file(GLOB CHILDREN RELATIVE ${APP_TESTS_FOLDER} ${APP_TESTS_FOLDER}/test\_*)
foreach(child ${CHILDREN})
  if(IS_DIRECTORY ${APP_TESTS_FOLDER}/${child})
    list(APPEND UNITTESTS ${child})
  endif()
endforeach()
set(${RESULT} ${UNITTESTS} PARENT_SCOPE)
endfunction()

function(AddUnitTest UNITTEST)
# Add a unit test the project

set(APP_CURRENT_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/tests/${UNITTEST}" )
set(APP_CURRENT_TARGET ${UNITTEST})

message(STATUS "APP_CURRENT_SOURCE: ${APP_CURRENT_SOURCE}")
message(STATUS "APP_CURRENT_TARGET: ${APP_CURRENT_TARGET}")

if(NOT IS_DIRECTORY "${APP_CURRENT_SOURCE}")
  message(FATAL_ERROR "Source folder does not exists '${APP_CURRENT_SOURCE}'")
endif()

message(STATUS "Adding test '${UNITTEST}'")
file(GLOB_RECURSE TEST_SRCS "${APP_CURRENT_SOURCE}/*.cpp")
file(GLOB_RECURSE TEST_HDRS "${APP_CURRENT_SOURCE}/*.hpp")

add_executable(
  ${UNITTEST} 
  ${TEST_SRCS}
  ${TEST_HDRS} 
)

# Unit Testing
# https://github.com/google/googletest.git
target_link_libraries(
  ${UNITTEST}
  PUBLIC 
  gtest
)

target_include_directories( 
  ${APP_CURRENT_TARGET}
  PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Include custom configuration if required
if(EXISTS "${APP_CURRENT_SOURCE}/config.cmake")
  message(STATUS "Adding custom configuration: ${APP_CURRENT_SOURCE}/config.cmake")
  include("${APP_CURRENT_SOURCE}/config.cmake")
endif()

add_test(
  NAME  "${UNITTEST}"
  COMMAND "${UNITTEST}"
) 

endfunction()