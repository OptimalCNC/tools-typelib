# This module finds the Ruby package and defines a ADD_RUBY_EXTENSION macro to
# build and install Ruby extensions
#
# Upon loading, it sets a RUBY_EXTENSIONS_AVAILABLE variable to true if Ruby
# extensions can be built.
#
# The ADD_RUBY_EXTENSION macro can be used as follows:
#  ADD_RUBY_EXTENSION(target_name source1 source2 source3 ...)
#
#

FIND_PACKAGE(Ruby)
IF(NOT RUBY_INCLUDE_PATH)
    MESSAGE(STATUS "Ruby library not found. Cannot build Ruby extensions")
ELSEIF(NOT RUBY_EXTENSIONS_AVAILABLE)
    SET(RUBY_EXTENSIONS_AVAILABLE TRUE)
    STRING(REGEX REPLACE ".*(lib|share)(32|64)?/?" "\\1/" RUBY_EXTENSIONS_INSTALL_DIR ${RUBY_ARCH_DIR})
    STRING(REGEX REPLACE ".*(lib|share)(32|64)?/?" "\\1/" RUBY_LIBRARY_INSTALL_DIR ${RUBY_RUBY_LIB_PATH})

    FIND_PROGRAM(RDOC_EXECUTABLE NAMES rdoc1.9 rdoc1.8 rdoc)
    FIND_PROGRAM(YARD_EXECUTABLE NAMES yard)

    EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "puts RUBY_VERSION"
       OUTPUT_VARIABLE RUBY_VERSION)
    STRING(REPLACE "\n" "" RUBY_VERSION ${RUBY_VERSION})
    message(STATUS "using Ruby version ${RUBY_VERSION}")

    EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "puts RbConfig::CONFIG['CFLAGS']"
       OUTPUT_VARIABLE RUBY_CFLAGS)
    STRING(REPLACE "\n" "" RUBY_CFLAGS ${RUBY_CFLAGS})

    EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "puts RbConfig::CONFIG['CXXFLAGS']"
       OUTPUT_VARIABLE RUBY_CXXFLAGS)
    STRING(REPLACE "\n" "" RUBY_CXXFLAGS ${RUBY_CXXFLAGS})

    MACRO(ADD_RUBY_EXTENSION target)
        list(GET RUBY_INCLUDE_PATH 0 ruby_path)
        GET_FILENAME_COMPONENT(rubylib_path ${ruby_path} PATH)
        LINK_DIRECTORIES(${rubylib_path})

        INCLUDE_DIRECTORIES(SYSTEM ${RUBY_INCLUDE_PATH})
        ADD_LIBRARY(${target} MODULE ${ARGN})
        foreach(source ${ARGN})
            get_filename_component(source_extension "${source}" EXT)
            if(source_extension MATCHES "^\\.(cc|cpp|cxx|C|c\\+\\+)$")
                SET_SOURCE_FILES_PROPERTIES(${source} PROPERTIES COMPILE_FLAGS "${RUBY_CXXFLAGS}")
            else()
                SET_SOURCE_FILES_PROPERTIES(${source} PROPERTIES COMPILE_FLAGS "${RUBY_CFLAGS}")
            endif()
        endforeach()
        target_link_libraries(${target} ${RUBY_LIBRARY})
        SET_TARGET_PROPERTIES(${target} PROPERTIES PREFIX "")
        if(WIN32)
            SET_TARGET_PROPERTIES(${target} PROPERTIES SUFFIX ".so")
        endif()
    ENDMACRO(ADD_RUBY_EXTENSION)
ENDIF(NOT RUBY_INCLUDE_PATH)
