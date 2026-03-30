#include "SocketServer.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

SocketServer::SocketServer(QObject *parent) : QObject(parent)
{
    m_server = new QLocalServer(this);
}

void SocketServer::start()
{
    QLocalServer::removeServer("/tmp/lumos.sock");

    if (!m_server->listen("/tmp/lumos.sock"))
    {
        qWarning() << "[Socket] Failed to start server";
        return;
    }

    connect(m_server, &QLocalServer::newConnection,
            this,     &SocketServer::onNewConnection);

    qInfo() << "[Socket] Server listening at /tmp/lumos.sock";
}

void SocketServer::onNewConnection()
{
    m_client = m_server->nextPendingConnection();

    connect(m_client, &QLocalSocket::readyRead,
            this,     &SocketServer::onDataReceived);

    qInfo() << "[Socket] Python client connected";
}

void SocketServer::onDataReceived()
{
    QByteArray data = m_client->readAll();
    QJsonObject obj = QJsonDocument::fromJson(data).object();

    if (obj.contains("state"))
    {
        bool awake = obj["state"].toBool();
        qInfo() << "[Socket] Wake state received —" << (awake ? "awake" : "sleeping");
        emit wakeStateChanged(awake);
    }
    else if (obj.contains("action"))
    {
        QString action = obj["action"].toString();
        QString room   = obj["room"].toString();

        qInfo() << "[Socket] Command received — action:" << action << "room:" << room;
        emit commandReceived(action, room);
    }
    else 
    {
        qWarning() << "[Socket] Unknown message format:" << data;
    }
}