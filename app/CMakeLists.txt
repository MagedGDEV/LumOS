cmake_minimum_required(VERSION 3.16)
project(app LANGUAGES CXX C)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(app
    src/main.cpp
)

qt_add_qml_module(app
    URI lumOS
    VERSION 1.0
    QML_FILES
        Main.qml
    RESOURCE_PREFIX /qt/qml
)

target_link_libraries(app
    PRIVATE
        Qt6::Quick
)