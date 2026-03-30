#include "RoomManager.h"
#include <QDebug>

// -----------------------------------------
// Constructors & Destructors
// -----------------------------------------

RoomManager::RoomManager(QObject *parent) : QObject(parent)
{
    // Add your rooms here — name and GPIO pin
    m_rooms.append(new LightController("Living Room", 2, this));
    m_rooms.append(new LightController("Kitchen",     3, this));
    m_rooms.append(new LightController("Bedroom",     4, this));
    m_rooms.append(new LightController("Bathroom",    17, this));

    for (auto *room : m_rooms) {
        connect(room, &LightController::stateChanged,
                this, &RoomManager::roomsChanged);
    }

    qInfo() << "[RoomManager] Initialized with" << m_rooms.size() << "rooms";
}

// -----------------------------------------
// Public functions
// -----------------------------------------

QVariantList RoomManager::rooms() const
{
    QVariantList list;
    for (int i = 0; i < m_rooms.size(); i++) {
        QVariantMap map;
        map["index"] = i;
        map["name"]  = m_rooms[i]->name();
        map["isOn"]  = m_rooms[i]->state();
        map["pin"]   = m_rooms[i]->pinNum();
        list.append(map);
    }
    return list;
}

bool RoomManager::voiceActive() const
{ 
    return m_voiceActive;
}

void RoomManager::setVoiceActive(const bool value)
{
    if (m_voiceActive == value)
        return;

    m_voiceActive = value;
    emit voiceActiveChanged(m_voiceActive);
}

void RoomManager::toggle(int index)
{
    if (index < 0 || index >= m_rooms.size()) return;
    m_rooms[index]->toggle();
}

void RoomManager::turnAllOn()
{
    for (auto *room : m_rooms) room->turnOn();
}

void RoomManager::turnAllOff()
{
    for (auto *room : m_rooms) room->turnOff();
}

bool RoomManager::isOn(int index) const
{
    if (index < 0 || index >= m_rooms.size()) return false;
    return m_rooms[index]->state();
}

QString RoomManager::roomName(int index) const
{
    if (index < 0 || index >= m_rooms.size()) return "";
    return m_rooms[index]->name();
}

int RoomManager::roomPin(int index) const
{
    if (index < 0 || index >= m_rooms.size()) return -1;
    return m_rooms[index]->pinNum();
}

// -----------------------------------------
// Public slots 
// -----------------------------------------

void RoomManager::onVoiceCommand(const QString &action, const QString &room)
{
    qInfo() << "[Voice] action:" << action << "room:" << room;

    bool turnOn = (action == "turn_on");

    if (room == "all")
    {
        turnOn ? turnAllOn() : turnAllOff();
        return;
    }

    for (auto *r : m_rooms)
    {
        if (r->name().toLower() == room.toLower())
        {
            turnOn ? r->turnOn() : r->turnOff();
            return;
        }
    }

    qWarning() << "[Voice] Room not found:" << room;
}

void RoomManager::onWakeUpCommand(const bool awake)
{
    setVoiceActive(awake);
}