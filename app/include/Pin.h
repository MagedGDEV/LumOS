#pragma once

class Pin 
{
public:

    enum Direction 
    {
        Input,
        Output
    };
    
    enum PinState
    {
        Low,
        High
    };

    Pin(int pin, Direction direction);
    ~Pin();

    void setPin(PinState pinState);
    void setDirection(Direction direction);
    bool isPinReady() const;
    PinState readPin();

private:
    void exportPin();
    void unExportPin();

    int m_pin;
    Direction m_direction = Output;
    bool m_ready = false;
};