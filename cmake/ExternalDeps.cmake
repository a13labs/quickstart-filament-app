include(ExternalProject)

function(AddExternalProject PRJ_NAME GIT_REPOSITORY GIT_TAG)

    set(
        oneValueArgs 
        CMAKE_VERSION 
        CONFIGURE_COMMAND
        BUILD_COMMAND
        INSTALL_COMMAND
        TEST_COMMAND
    )
    
    cmake_parse_arguments(CALL_ARGS "" "${oneValueArgs}" "" ${ARGN})

    if (${CALL_ARGS_CMAKE_VERSION})
        set(PRJ_CMAKE_VERSION ${CALL_ARGS_CMAKE_VERSION})
    else()
        set(PRJ_CMAKE_VERSION 3.5)    
    endif()
    
    if (${CALL_ARGS_CONFIGURE_COMMAND})
        set(PRJ_CONFIGURE_COMMAND ${CALL_ARGS_CONFIGURE_COMMAND})
    else()
        set(PRJ_CONFIGURE_COMMAND "")    
    endif()
    
    if (${CALL_ARGS_BUILD_COMMAND})
        set(PRJ_BUILD_COMMAND ${CALL_ARGS_BUILD_COMMAND})
    else()
        set(PRJ_BUILD_COMMAND "")    
    endif()
    
    if (${CALL_ARGS_INSTALL_COMMAND})
        set(PRJ_INSTALL_COMMAND ${CALL_ARGS_INSTALL_COMMAND})
    else()
        set(PRJ_INSTALL_COMMAND "")    
    endif()
    
    if (${CALL_ARGS_TEST_COMMAND})
        set(PRJ_TEST_COMMAND ${CALL_ARGS_TEST_COMMAND})
    else()
        set(PRJ_TEST_COMMAND "")    
    endif()
    set (PRJ_WORK_DIR "${CMAKE_CURRENT_BINARY_DIR}/3rdparty/${PRJ_NAME}")

    # Download and unpack package at configure time
    configure_file(
        "cmake/ExternalCMakeProj.in.cmake"
        "3rdparty/${PRJ_NAME}/CMakeLists.txt"
    )

    message(STATUS "Preparing external project '${PRJ_NAME}' from '${GIT_REPOSITORY}', revision '${GIT_TAG}'")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" . 
        RESULT_VARIABLE result
        WORKING_DIRECTORY ${PRJ_WORK_DIR}
    )

    if(result)
        message(FATAL_ERROR "CMake step for package ${PRJ_NAME} failed: ${result}")
    endif()

    message(STATUS "Building project '${PRJ_NAME}'.")
    execute_process(
        COMMAND ${CMAKE_COMMAND} --build . 
        RESULT_VARIABLE result
        WORKING_DIRECTORY ${PRJ_WORK_DIR}
    )

    if(result)
        message(FATAL_ERROR "Build step for ${PRJ_NAME} failed: ${result}")
    endif()

    add_subdirectory(
        ${CMAKE_CURRENT_BINARY_DIR}/${PRJ_NAME}-src
        ${CMAKE_CURRENT_BINARY_DIR}/${PRJ_NAME}-build
        EXCLUDE_FROM_ALL
    )

endfunction()
