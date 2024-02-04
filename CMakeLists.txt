cmake_minimum_required(VERSION 3.16)
project(rgbd_viewer LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Quick3D)

enable_language("RC")
set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/icons/rgbd_viewer.rc")

qt_add_executable(rgbd_viewer
    src/main.cpp
    ${app_icon_resource_windows}
)

set_target_properties(rgbd_viewer PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(rgbd_viewer PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Quick
    Qt::Quick3D
)

target_include_directories(rgbd_viewer PRIVATE src)

qt_add_qml_module(rgbd_viewer
    URI TexturedSurfaceGeometry
    VERSION 1.0
    QML_FILES
        src/qml/Main.qml
        src/qml/Viewer.qml
        src/qml/ImageDialog.qml
        src/qml/CustomButton.qml
        src/qml/CustomDialog.qml
    SOURCES
        src/surfacegeometry.cpp src/surfacegeometry.h
    IMPORTS
        QtQuick3D
)

file(COPY img icons DESTINATION ${CMAKE_BINARY_DIR})
