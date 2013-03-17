# AMX PDU Minimal API
The AMX PDU minimal API is a simple API for interacting with an AMX power distribution unit. This is a temporary API that has been formed to allow you to experiment quickly. It is not intended for use in a production environment.

# Basics
All communication is based on the [FUDI](http://en.wikipedia.org/wiki/FUDI) protocol.

FUDI is a packet oriented protocol.

Each message consists of one or more atoms, separated by one or more whitespace characters, and it's terminated by a semicolon character.

An atom is a sequence of one or more characters; whitespaces inside atoms can be escaped by the backslash (ascii 92) character.

A whitespace is either a space (ascii 32), a tab (ascii 9) or a newline (ascii 10).

A semicolon (ascii 59) is mandatory to terminate (and send) a message. A newline is just treated as whitespace and not needed for message termination.

# Connection
An identical API is present on serial interface 1 of the control system and port 1234 of the network interface.

## Authentication
There is none. Hack away.

# Controlling Circuit Power
Individual circuits can be powered on or off by forming a message where the first atom is the desired state and the second it the circuit number.

For example to turn on circuit 2 you would send

    on 2;

Similarly circuit 6 can be turned off by sending

    off 6;

# Monitoring Circuits
The simple API will provide asynchronous feedback whenever the device state changes. There is no need to query or poll anything. If something interesting happens, don't worry, we'll tell you.

All feedback is provided in the following format:

    <feedback-type> <circuit-number> <value>;

Where

`<feedback-type>` is identifier for the data type,

`<circuit number>` is in the range of 1 - 8, and

`<value>` is a string representation of the data value.

## Power (Watts)

    power <circuit-number> <value>;

`<value>` has a resolution of 0.1 and is always >= 0.0.

## Current (Amps)

    current <circuit-number> <value>;

`<value>` has a resolution of 0.1 and is always >= 0.0.

## Power Factor (W/VA)

    power-factor <circuit-number> <value>;

`<value>` has a resolution of 0.01 and -1.00 <= *value* <= 1.00.
Where the value is negative the power factor is lagging and positive translates to a leading current.

## Energy (W-hr)

    energy <circuit-number> <value>;

`<value>` has a resolution of 0.1 and is always >= 0.0.

This is the accumulated energy usage on the circuit since the PDU was powered on or the counter last reset.

The counter can be set at any time by sending

    reset-energy <circuit-number>;

## Examples
`current 3 0.2;` would indicate that circuit 3 was drawing 0.2A of power.

`power 1 20.4;` would indicate that the load on circuit 1 was using 20.4W of energy.

`current 5 1.3;` indicates that circuit 5 was drawing 1.3A of power.

`energy 7 60.0;` would indicate that circuit 7 had used 60.0W-hr's of energy, or 0.06kWh's.

`power-factor 2 -0.04;` would indicate that circuit 2's current power factor was -0.04 denoting a capacitive load.