cmake_minimum_required(VERSION 3.16)
project(LumOSApp LANGUAGES CXX C)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(LumOSApp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
)

qt_add_qml_module(LumOSApp
    URI lumOS
    VERSION 1.0
    QML_FILES
        Main.qml
    SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/include/Pin.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/LightController.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/RoomManager.h

        ${CMAKE_CURRENT_SOURCE_DIR}/src/Pin.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/LightController.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/RoomManager.cpp

    RESOURCE_PREFIX /qt/qml
)

target_include_directories(LumOSApp PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

target_link_libraries(LumOSApp
    PRIVATE
        Qt6::Quick
)