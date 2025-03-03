# CMakeUnit v1.0.0
# https://github.com/tawez/CMakeUnit
#
# MIT License
#
# Copyright (c) 2025 Maciej Stankiewicz
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function(add_cmake_test name path)
    set(options SKIP WILL_FAIL)
    set(oneValueArgs "")
    set(multiValueArgs OPTIONS)
    cmake_parse_arguments(test "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_filename_component(testPath "${path}" ABSOLUTE)
    if (IS_DIRECTORY "${testPath}")
        cmake_path(APPEND path "CMakeLists.txt")
    endif ()
    get_filename_component(testPath "${path}" ABSOLUTE)
    if (NOT EXISTS "${testPath}")
        message(FATAL_ERROR "${path} not found")
    elseif (IS_DIRECTORY "${testPath}")
        message(FATAL_ERROR "${path} is not a file")
    endif ()

    if (${test_SKIP})
        add_test(
            NAME "${name}"
            COMMAND ${CMAKE_COMMAND} -E echo "Skip '${name}' test"
        )
        set_property(TEST "${name}" PROPERTY SKIP_REGULAR_EXPRESSION "Skip '${name}' test")
        return()
    endif ()

    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/${path}"
        "${CMAKE_CURRENT_BINARY_DIR}/${path}"
        @ONLY
    )

    add_test(
        NAME "${name}"
        COMMAND ${CMAKE_COMMAND}
        ${test_OPTIONS}
        "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
        -P "${CMAKE_CURRENT_BINARY_DIR}/${path}"
    )
    if (${test_WILL_FAIL})
        set_property(TEST "${name}" PROPERTY WILL_FAIL true)
    endif ()
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
    message(SEND_ERROR "${ARGN}")
endmacro()

macro(FATAL)
    message(FATAL_ERROR "${ARGN}")
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
            message(SEND_ERROR "'${value}' is expected to be 'false'")
        endif ()
    endblock()
endmacro()

macro(EXPECT_DEFINED variable)
    if (NOT DEFINED ${variable})
        message(SEND_ERROR "'${variable}' is expected to be defined")
    endif ()
endmacro()

macro(EXPECT_UNDEFINED variable)
    if (DEFINED ${variable})
        message(SEND_ERROR "'${variable}' is expected not to be defined")
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
