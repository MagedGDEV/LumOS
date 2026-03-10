#include "LightController.h"

#include <QDebug>

// -----------------------------------------
// Constructors & Destructors
// -----------------------------------------

LightController::LightController (const QString &name, int pinNum, QObject *parent)
    : QObject(parent), m_name(name), m_pinNum(pinNum), m_pin(std::make_unique<Pin>(pinNum, Pin::Output))
{
    qInfo() << "[Light]" << m_name << "initialized on pin" << m_pinNum;
}

// -----------------------------------------
// Public functions
// -----------------------------------------

bool LightController::state() const { return m_state; }
QString LightController::name() const { return m_name; }
int LightController::pinNum()  const { return m_pinNum; }

// -----------------------------------------
// QML invokable functions
// -----------------------------------------

void LightController::turnOn()
{
    m_state = true;
    m_pin->setPin(Pin::High);
    emit stateChanged();
    qInfo() << "[Light]" << m_name << "ON";
}

void LightController::turnOff()
{
    m_state = false;
    m_pin->setPin(Pin::Low);
    emit stateChanged();
    qInfo() << "[Light]" << m_name << "OFF";
}

void LightController::toggle()
{
    m_state ? turnOff() : turnOn();
}

// -----------------------------------------
// Private functions
// -----------------------------------------