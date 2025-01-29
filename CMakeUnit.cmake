function(set_cmake_test_name variable test)
    cmake_path(GET CMAKE_CURRENT_SOURCE_DIR STEM suite)
    string(REPLACE "/" "::" test "${test}")
    set(${variable} "${suite}::${test}" PARENT_SCOPE)
endfunction()


function(add_cmake_test test)
    cmake_parse_arguments(arg "WILL_FAIL" "" "" ${ARGN})

    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/${test}.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${test}.cmake"
        @ONLY
    )

    set_cmake_test_name(testName "${test}")

    add_test(
        NAME "${testName}"
        COMMAND ${CMAKE_COMMAND}
        ${arg_UNPARSED_ARGUMENTS}
        "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
        -P "${CMAKE_CURRENT_BINARY_DIR}/${test}.cmake"
    )
    if (${arg_WILL_FAIL})
        set_property(TEST "${testName}" PROPERTY WILL_FAIL true)
    endif ()
endfunction()


function(xadd_cmake_test test)
    set_cmake_test_name(testName "${test}")

    add_test(
        NAME "${testName}"
        COMMAND ${CMAKE_COMMAND} -E echo "SKIP THIS TEST"
    )
    set_property(TEST "${testName}" PROPERTY SKIP_REGULAR_EXPRESSION "SKIP THIS TEST")
endfunction()


macro(add_cmakeunit_target name)
    add_custom_target(
        "${name}"
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        ${ARGN}
    )
endmacro()


# {{{ Assertions
macro(FAIL)
    if ("${ARGN}" STREQUAL "")
        message(SEND_ERROR "Failed")
    else ()
        message(SEND_ERROR "${ARGN}")
    endif ()
endmacro()


macro(EXPECT_TRUE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (NOT ${value})
            message(SEND_ERROR "'${value}' is expected to be 'true'")
        endif ()
    endblock()
endmacro()

macro(EXPECT_FALSE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (${value})
            message(SEND_ERROR "'${value} is expected to be 'false'")
        endif ()
    endblock()
endmacro()


macro(EXPECT_DEFINED variable)
    if (NOT DEFINED ${variable})
        message(SEND_ERROR "${variable} is expected to be defined")
    endif ()
endmacro()

macro(EXPECT_NOT_DEFINED variable)
    if (DEFINED ${variable})
        message(SEND_ERROR "${variable} is expected not to be defined")
    endif ()
endmacro()

macro(EXPECT_STREQ value expected)
    if (NOT "${value}" STREQUAL "${expected}")
        message(SEND_ERROR "'${variable}' is expected to be '${expected}'")
    endif ()
endmacro()

macro(EXPECT_NOT_STREQ value expected)
    if ("${value}" STREQUAL "${expected}")
        message(SEND_ERROR "'${variable}' is expected not to be '${expected}'")
    endif ()
endmacro()


macro(EXPECT_MATCH value regexp)
    if (NOT "${value}" MATCHES "${regexp}")
        message(SEND_ERROR "'${value}' is expected to match '${regexp}'")
    endif ()
endmacro()


macro(EXPECT_NOT_MATCH value regexp)
    if ("${value}" MATCHES "${regexp}")
        message(SEND_ERROR "'${value}' is expected not to match '${regexp}'")
    endif ()
endmacro()

# }}} Assertions
