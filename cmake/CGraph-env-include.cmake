
# 本cmake文件，供三方引入CGraph引用，用于屏蔽系统和C++版本的区别

# 根据当前 CGraph-env-include.cmake 文件的位置，定位CGraph整体工程的路径
# 从而解决并兼容了直接引入和三方库引入的路径不匹配问题
get_filename_component(CGRAPH_PROJECT_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
set(CGRAPH_PROJECT_ROOT_DIR "${CGRAPH_PROJECT_CMAKE_DIR}/../")
file(GLOB_RECURSE CGRAPH_PROJECT_SRC_LIST "${CGRAPH_PROJECT_ROOT_DIR}/src/*.cpp")

IF(APPLE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m64 -O2 \
        -finline-functions -Wno-deprecated-declarations -Wno-c++17-extensions")
    add_definitions(-D_ENABLE_LIKELY_)
ELSEIF(UNIX)
    # linux平台，加入多线程内容
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -pthread -Wno-format-overflow")
    add_definitions(-D_ENABLE_LIKELY_)
ELSEIF(WIN32)
    IF(MSVC)
        # windows平台，加入utf-8设置。否则无法通过编译
        # 直接Download ZIP文件，导致无法编译通过问题的解决方法，参考：https://github.com/ChunelFeng/CGraph/issues/12
        add_definitions(/utf-8)

        # 禁止几处warning级别提示
        add_compile_options(/wd4996)
        add_compile_options(/wd4267)
        add_compile_options(/wd4018)
    ENDIF()
    # 本工程也支持在windows平台上的mingw环境使用
ENDIF()

#include_directories(${CGRAPH_PROJECT_ROOT_DIR}/src/)    # 直接加入"CGraph.h"文件对应的位置

# 以下三选一，本地编译执行，推荐OBJECT方式
# add_library(CGraph OBJECT ${CGRAPH_PROJECT_SRC_LIST})      # 通过代码编译
add_library(CGraph SHARED ${CGRAPH_PROJECT_SRC_LIST})    # 编译libCGraph动态库
# add_library(CGraph STATIC ${CGRAPH_PROJECT_SRC_LIST})    # 编译libCGraph静态库

target_include_directories(${CMAKE_PROJECT_NAME}
  PUBLIC
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include/>
    $<BUILD_INTERFACE:${CGRAPH_PROJECT_ROOT_DIR}/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  PRIVATE
    $<BUILD_INTERFACE:${CGRAPH_PROJECT_ROOT_DIR}/src>
)

###############
# For Windows export
##
include(GenerateExportHeader)
generate_export_header (
  ${CMAKE_PROJECT_NAME}
  EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}Export.h"
)

###############
# Installation
##

include(GNUInstallDirs)

install(TARGETS ${CMAKE_PROJECT_NAME}
  EXPORT ${CMAKE_PROJECT_NAME}Targets

  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(DIRECTORY ${CGRAPH_PROJECT_ROOT_DIR}/src/ DESTINATION include FILES_MATCHING PATTERN "*.h" PATTERN "*.inl")

install(EXPORT ${CMAKE_PROJECT_NAME}Targets
  FILE ${CMAKE_PROJECT_NAME}Targets.cmake
  NAMESPACE ${CMAKE_PROJECT_NAME}::
  DESTINATION share/CGraph
)

include(CMakePackageConfigHelpers)

write_basic_package_version_file( "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}ConfigVersion.cmake" 
  COMPATIBILITY SameMajorVersion 
)

configure_package_config_file(${CGRAPH_PROJECT_ROOT_DIR}/cmake/${CMAKE_PROJECT_NAME}Config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION share/CGraph
)

install(FILES
  ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}Config.cmake
  ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}ConfigVersion.cmake
  DESTINATION share/CGraph
)


install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}Export.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${project_name}
)