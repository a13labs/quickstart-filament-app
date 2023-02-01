function(AddExecutable TGT_NAME)

  set(
    oneValueArgs 
    CPP_STD 
  )

  cmake_parse_arguments(CALL_ARGS "" "${oneValueArgs}" "" ${ARGN})

  if (${CALL_ARGS_CPP_STD})
      set(PRG_CPP_STD ${CALL_ARGS_CPP_STD})
  else()
      set(CPP_STD ${APP_LANG_STD})    
  endif()

  set(APP_CURRENT_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/src/${TGT_NAME}" )
  set(APP_CURRENT_TARGET ${TGT_NAME})
  

  if(NOT IS_DIRECTORY "${APP_CURRENT_SOURCE}")
    message(FATAL_ERROR "Source folder does not exists '${APP_CURRENT_SOURCE}'")
  endif()

  message(STATUS "Adding executable: '${APP_CURRENT_TARGET}' from '${APP_CURRENT_SOURCE}'")
  # Add all source files recursively
  FILE(GLOB_RECURSE PRG_SRCS "${APP_CURRENT_SOURCE}/*.cpp")
  FILE(GLOB_RECURSE PRG_HDRS "${APP_CURRENT_SOURCE}/*.hpp")

  add_executable(${APP_CURRENT_TARGET} ${PRG_SRCS} ${PRG_HDRS})

  target_compile_features(
    ${APP_CURRENT_TARGET} 
    PUBLIC ${APP_CPP_STD}
  )

  # Include custom configuration if required
  if(EXISTS "${APP_CURRENT_SOURCE}/config.cmake")
    message(STATUS "Adding custom configuration: ${APP_CURRENT_SOURCE}/config.cmake")
    include("${APP_CURRENT_SOURCE}/config.cmake")
  endif()

  install(
    TARGETS ${APP_CURRENT_TARGET}
    RUNTIME 
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    CONFIGURATIONS All
  )

endfunction()

function(AddLibrary TGT_NAME)

  set(
    oneValueArgs 
    CPP_STD 
  )

  cmake_parse_arguments(CALL_ARGS "" "${oneValueArgs}" "" ${ARGN})

  if (${CALL_ARGS_CPP_STD})
      set(PRG_CPP_STD ${CALL_ARGS_CPP_STD})
  else()
      set(CPP_STD ${APP_LANG_STD})    
  endif()

  set(APP_CURRENT_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/src/${TGT_NAME}" )
  set(APP_CURRENT_TARGET ${TGT_NAME})

  if(NOT IS_DIRECTORY "${APP_CURRENT_SOURCE}")
    message(FATAL_ERROR "Source folder does not exists '${APP_CURRENT_SOURCE}'")
  endif()

  message(STATUS "Adding library: '${APP_CURRENT_TARGET}' from '${APP_CURRENT_SOURCE}'")
  
  # Add all source files recursively
  FILE(GLOB_RECURSE PRG_SRCS "${APP_CURRENT_SOURCE}/*.cpp")
  FILE(GLOB_RECURSE PRG_HDRS "${APP_CURRENT_SOURCE}/*.hpp")

  add_library(${APP_CURRENT_TARGET} ${PRG_SRCS} ${PRG_HDRS})
  add_library("${APP_CURRENT_TARGET}::${APP_CURRENT_TARGET}" ALIAS ${APP_CURRENT_TARGET})

  target_compile_features(
    ${APP_CURRENT_TARGET} 
    PUBLIC ${APP_CPP_STD}
  )

  # Include custom configuration if required
  if(EXISTS "${APP_CURRENT_SOURCE}/config.cmake")
    message(STATUS "Adding custom configuration: ${APP_CURRENT_SOURCE}/config.cmake")
    include("${APP_CURRENT_SOURCE}/config.cmake")
  endif()

  install(
    TARGETS ${APP_CURRENT_TARGET}
    RUNTIME 
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    CONFIGURATIONS All
  )

endfunction()