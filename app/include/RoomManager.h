#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QList>
#include <QVariantList>
#include "LightController.h"

class RoomManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QVariantList rooms READ rooms NOTIFY roomsChanged)

public:
    explicit RoomManager(QObject *parent = nullptr);

    QVariantList rooms() const;

    Q_INVOKABLE void toggle(int index);
    Q_INVOKABLE void turnAllOn();
    Q_INVOKABLE void turnAllOff();
    Q_INVOKABLE bool isOn(int index) const;
    Q_INVOKABLE QString roomName(int index) const;
    Q_INVOKABLE int roomPin(int index) const;

signals:
    void roomsChanged();

private:
    QList<LightController*> m_rooms;
};