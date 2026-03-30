#pragma once

#include <QObject>
#include <QLocalServer>
#include <QLocalSocket>

class SocketServer : public QObject
{
    Q_OBJECT

public:
    explicit SocketServer(QObject *parent = nullptr);
    void start();

private slots:
    void onNewConnection();
    void onDataReceived();

signals:
    void commandReceived(const QString &action, const QString &room);
    void wakeStateChanged(bool awake); 

private:
    QLocalServer *m_server  = nullptr;
    QLocalSocket *m_client  = nullptr;
};