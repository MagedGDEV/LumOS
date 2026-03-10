#pragma once

#include <QObject>
#include <QString>
#include <memory>

#include "Pin.h"

class LightController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool state READ state NOTIFY stateChanged)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(int pinNum READ pinNum CONSTANT)

public:
    explicit LightController(const QString &name, int pin, QObject *parent = nullptr);

    bool state() const;
    QString name() const;
    int pinNum() const;
    
    Q_INVOKABLE void turnOn();
    Q_INVOKABLE void turnOff();
    Q_INVOKABLE void toggle();

signals:
    void stateChanged();

private:
    QString m_name {};
    int m_pinNum {};
    bool m_state = {false};
    std::unique_ptr<Pin> m_pin;
};