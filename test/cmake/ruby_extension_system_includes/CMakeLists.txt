cmake_minimum_required(VERSION 3.10)

project(ruby_extension_system_includes C)

if(NOT DEFINED TYPELIB_SOURCE_DIR)
    message(FATAL_ERROR "TYPELIB_SOURCE_DIR is required")
endif()

list(PREPEND CMAKE_MODULE_PATH "${TYPELIB_SOURCE_DIR}/cmake")
include(RubyExtensions)

if(NOT RUBY_EXTENSIONS_AVAILABLE)
    message(FATAL_ERROR "Ruby extensions must be available for this regression test")
endif()

ADD_RUBY_EXTENSION(ruby_extension_system_includes ruby_extension.c)
file(WRITE "${CMAKE_BINARY_DIR}/ruby_include_paths.txt" "${RUBY_INCLUDE_PATH}")
