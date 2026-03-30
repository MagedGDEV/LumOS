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
    Q_PROPERTY(bool voiceActive READ voiceActive WRITE setVoiceActive NOTIFY voiceActiveChanged)

public:
    explicit RoomManager(QObject *parent = nullptr);

    QVariantList rooms() const;
    bool voiceActive() const;
    void setVoiceActive(const bool value);

    Q_INVOKABLE void toggle(int index);
    Q_INVOKABLE void turnAllOn();
    Q_INVOKABLE void turnAllOff();
    Q_INVOKABLE bool isOn(int index) const;
    Q_INVOKABLE QString roomName(int index) const;
    Q_INVOKABLE int roomPin(int index) const;

public slots:
    void onVoiceCommand(const QString &action, const QString &room);
    void onWakeUpCommand(const bool awake);

signals:
    void roomsChanged();
    void voiceActiveChanged(const bool awake);

private:
    bool m_voiceActive = false;
    QList<LightController*> m_rooms;
};