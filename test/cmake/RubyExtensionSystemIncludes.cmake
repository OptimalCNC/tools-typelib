if(NOT DEFINED TYPELIB_SOURCE_DIR)
    message(FATAL_ERROR "TYPELIB_SOURCE_DIR is required")
endif()

if(NOT DEFINED TYPELIB_TEST_BINARY_DIR)
    message(FATAL_ERROR "TYPELIB_TEST_BINARY_DIR is required")
endif()

set(test_source_dir "${TYPELIB_SOURCE_DIR}/test/cmake/ruby_extension_system_includes")
set(test_binary_dir "${TYPELIB_TEST_BINARY_DIR}/cmake/ruby_extension_system_includes")

file(REMOVE_RECURSE "${test_binary_dir}")
execute_process(
    COMMAND "${CMAKE_COMMAND}"
        -DTYPELIB_SOURCE_DIR:PATH=${TYPELIB_SOURCE_DIR}
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
        -S "${test_source_dir}"
        -B "${test_binary_dir}"
    RESULT_VARIABLE configure_result)
if(NOT configure_result EQUAL 0)
    message(FATAL_ERROR "Ruby extension CMake fixture failed to configure")
endif()

file(READ "${test_binary_dir}/compile_commands.json" compile_commands)
file(READ "${test_binary_dir}/ruby_include_paths.txt" ruby_include_paths)

foreach(ruby_include IN LISTS ruby_include_paths)
    string(FIND "${compile_commands}" "-isystem ${ruby_include}" ruby_include_index)
    if(ruby_include_index EQUAL -1)
        message(FATAL_ERROR "Ruby extension include is not passed as a system include: ${ruby_include}")
    endif()
endforeach()
