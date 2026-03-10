#include "Pin.h"

#include <QFile>
#include <QTextStream>
#include <QThread>
#include <QDebug>

// -----------------------------------------
// Constructors & Destructors
// -----------------------------------------

Pin::Pin(int pin, Pin::Direction direction) : m_pin(pin), m_direction(direction)
{
    exportPin();
    // Sleep before manipulating the pin
    QThread::msleep(80);
    setDirection(direction);
}

Pin::~Pin()
{
    if (m_direction == Output)
        setPin(Pin::Low);
    unExportPin();
}

// -----------------------------------------
// Public functions
// -----------------------------------------

void Pin::setPin(PinState pinState)
{
    if (m_direction == Input) 
    {
        qWarning() << "[GPIO] pin" << m_pin << "is input, cannot write";
        return;
    }

    if (!m_ready) 
    {
        qDebug() << "[GPIO] host mode pin" << m_pin 
            << (pinState ? "HIGH" : "LOW");
        return;
    }

    QString path = QString("/sys/class/gpio/gpio%1/value").arg(m_pin);
    QFile f(path);
    if (f.open(QIODevice::WriteOnly)) 
    {
        QTextStream s(&f);
        s << (pinState ? "1" : "0");
    } 
    else
        qWarning() << "[GPIO] Failed to write pin" << m_pin;
}

void Pin::setDirection(Direction direction)
{
    QString path = QString("/sys/class/gpio/gpio%1/direction").arg(m_pin);
    QFile f(path);
    if (f.open(QIODevice::WriteOnly)) 
    {
        QTextStream s(&f);
        s << (direction == Direction::Output ? "out" : "in");
        m_ready = true;
        qInfo() << "[GPIO] pin" << m_pin
                << "direction:" << (direction == Direction::Output ? "output" : "input");
        m_direction = direction;
    } 
    else 
        qWarning() << "[GPIO] Could not set direction for pin" << m_pin;
}

bool Pin::isPinReady() const
{
    return m_ready;
}

Pin::PinState Pin::readPin()
{
    QString path = QString("/sys/class/gpio/gpio%1/value").arg(m_pin);
    QFile f(path);
    if (f.open(QIODevice::ReadOnly)) 
    {
        QTextStream s(&f);
        if (s.readAll().trimmed() == "1")
            return Pin::High;
    }

    qWarning() << "[GPIO] Failed to read pin" << m_pin;
    return Pin::Low;
}

// -----------------------------------------
// Private functions
// -----------------------------------------

void Pin::exportPin()
{
    QString gpioPath = QString("/sys/class/gpio/gpio%1").arg(m_pin);
    if (QFile::exists(gpioPath)) 
    {
        qInfo() << "[GPIO] pin" << m_pin << "already exported";
        m_ready = true;
        return;
    }

    QFile f("/sys/class/gpio/export");
    if (f.open(QIODevice::WriteOnly)) 
    {
        QTextStream s(&f);
        s << m_pin;
        qInfo() << "[GPIO] Exported pin" << m_pin;
    } 
    else
        qWarning() << "[GPIO] Could not export pin" << m_pin;
}

void Pin::unExportPin()
{
    QFile f("/sys/class/gpio/unexport");
    if (f.open(QIODevice::WriteOnly)) 
    {
        QTextStream s(&f);
        s << m_pin;
    }
}