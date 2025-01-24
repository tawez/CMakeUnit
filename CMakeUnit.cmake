macro(set_cmake_test_name variable test)
    cmake_path(GET CMAKE_CURRENT_SOURCE_DIR STEM suite)
    set(${variable} "${suite}::${test}" ${ARGN})
endmacro()


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
