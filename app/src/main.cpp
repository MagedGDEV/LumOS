#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "RoomManager.h"
#include "SocketServer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);


    QQmlApplicationEngine engine;
    auto roomManager = engine.singletonInstance<RoomManager*>("lumOS", "RoomManager");
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
    );

    engine.loadFromModule("lumOS", "Main");
    if (engine.rootObjects().isEmpty())
        return -1;

    SocketServer socketServer;
    socketServer.start();

    QObject::connect(&socketServer, &SocketServer::commandReceived,
                     roomManager,   &RoomManager::onVoiceCommand);
    QObject::connect(&socketServer, &SocketServer::wakeStateChanged,
                     roomManager,   &RoomManager::onWakeUpCommand);

    return app.exec();
}