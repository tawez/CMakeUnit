function(add_cmake_test file name)
    set(options SKIP WILL_FAIL)
    set(oneValueArgs "")
    set(multiValueArgs "")
    cmake_parse_arguments(test "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_filename_component(path "${file}" ABSOLUTE)
    if (IS_DIRECTORY "${path}")
        cmake_path(APPEND file "CMakeLists.txt")
    endif ()
    get_filename_component(path "${file}" ABSOLUTE)
    if (NOT EXISTS "${path}")
        message(FATAL_ERROR "${file} not found")
    elseif (IS_DIRECTORY "${path}")
        message(FATAL_ERROR "${file} is not a file")
    endif ()

    if (${test_SKIP})
        add_test(
            NAME "${name}"
            COMMAND ${CMAKE_COMMAND} -E echo "SKIP THIS TEST"
        )
        set_property(TEST "${name}" PROPERTY SKIP_REGULAR_EXPRESSION "SKIP THIS TEST")
        return()
    endif ()

    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/${file}"
        "${CMAKE_CURRENT_BINARY_DIR}/${file}"
        @ONLY
    )

    add_test(
        NAME "${name}"
        COMMAND ${CMAKE_COMMAND}
        ${test_UNPARSED_ARGUMENTS}
        "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
        -P "${CMAKE_CURRENT_BINARY_DIR}/${file}"
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


#See also the Floating-Point Comparison assertions to compare floating-point numbers and avoid problems caused by rounding.
#EXPECT_EQ
#
#EXPECT_EQ(val1,val2)
#ASSERT_EQ(val1,val2)
#
#Verifies that val1==val2.
#
#Does pointer equality on pointers. If used on two C strings, it tests if they are in the same memory location, not if they have the same value. Use EXPECT_STREQ to compare C strings (e.g. const char*) by value.
#
#When comparing a pointer to NULL, use EXPECT_EQ(ptr, nullptr) instead of EXPECT_EQ(ptr, NULL).
#EXPECT_NE
#
#EXPECT_NE(val1,val2)
#ASSERT_NE(val1,val2)
#
#Verifies that val1!=val2.
#
#Does pointer equality on pointers. If used on two C strings, it tests if they are in different memory locations, not if they have different values. Use EXPECT_STRNE to compare C strings (e.g. const char*) by value.
#
#When comparing a pointer to NULL, use EXPECT_NE(ptr, nullptr) instead of EXPECT_NE(ptr, NULL).
#EXPECT_LT
#
#EXPECT_LT(val1,val2)
#ASSERT_LT(val1,val2)
#
#Verifies that val1<val2.
#EXPECT_LE
#
#EXPECT_LE(val1,val2)
#ASSERT_LE(val1,val2)
#
#Verifies that val1<=val2.
#EXPECT_GT
#
#EXPECT_GT(val1,val2)
#ASSERT_GT(val1,val2)
#
#Verifies that val1>val2.
#EXPECT_GE
#
#EXPECT_GE(val1,val2)
#ASSERT_GE(val1,val2)

# }}} Assertions
