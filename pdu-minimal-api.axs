/**
 * This is a minimal API designed to allow quick hacking with the PDU.
 *
 * NOT FOR USE IN A PRODUCTION ENVIRONMENT.
 */
PROGRAM_NAME='main'


include 'fudi'


define_device

pduBase = 85:1:0
serial = 5001:1:0
socket = 0:first_local_port:0


define_constant

constant long IP_PORT = 1234


define_variable

dev pdu[8]


define_function buildPduArray(dev baseAddress) {
	stack_var integer x
	for (x = 0; x < 8; x++) {
		pdu[x + 1] = baseAddress.NUMBER + x:1:baseAddress.SYSTEM
	}
	set_length_array(pdu, 8)
	rebuild_event()
}

define_function send(char atoms[][]) {
	stack_var char msg[1024]

	set_length_array(atoms, max_length_array(atoms))
	msg = fudiPack(atoms)

	send_string serial, msg
	send_string socket, msg
}

define_function openSocket() {
	ip_server_open(socket.port, IP_PORT, IP_TCP)
}

define_function handleReceive(char x[]) {
	stack_var char atoms[8][12]
	fudiUnpack(x, atoms)

	switch (lower_string(atoms[1])) {

		// turn on the circuit
		case 'on': {
			on[pdu[atoi(atoms[2])], 1]
		}

		// turn off the circuit
		case 'off': {
			off[pdu[atoi(atoms[2])], 1]
		}

		// reset the energy counter
		case 'reset-energy': {
			send_level pdu[atoi(atoms[2])], 4, 0
		}

	}
}


define_event

// circuit state
channel_event[pdu, 1] {

	on: {
		stack_var char atoms[2][16]
		atoms[1] = 'on'
		atoms[2] = itoa(get_last(pdu))
		send(atoms)
	}

	off: {
		stack_var char atoms[2][16]
		atoms[1] = 'off'
		atoms[2] = itoa(get_last(pdu))
		send(atoms)
	}

}

// Power (Watts)
level_event[pdu, 1] {
	stack_var char atoms[3][16]
	atoms[1] = 'power'
	atoms[2] = itoa(get_last(pdu))
	atoms[3] = format('%.1f', 0.1 * level.value)
	send(atoms)
}

// Current (Amps)
level_event[pdu, 2] {
	stack_var char atoms[3][16]
	atoms[1] = 'current'
	atoms[2] = itoa(get_last(pdu))
	atoms[3] = format('%.1f', 0.1 * level.value)
	send(atoms)
}

// Power factor (W/VA)
level_event[pdu, 3] {
	stack_var char atoms[3][16]
	atoms[1] = 'power-factor'
	atoms[2] = itoa(get_last(pdu))
	atoms[3] = format('%.2f', 0.01 * (level.value - 100.0))
	send(atoms)
}

// Energy (W-hr)
level_event[pdu, 4] {
	stack_var char atoms[3][16]
	atoms[1] = 'energy'
	atoms[2] = itoa(get_last(pdu))
	atoms[3] = format('%.1f', 0.1 * level.value)
	send(atoms)
}

data_event[serial] {

	online: {
		send_command data.device, 'SET BAUD 9600,N,8,1'
	}

	string: {
		handleReceive(data.text)
	}

}

data_event[socket] {

	offline: {
		openSocket()
	}

	onerror: {
		// TODO gracefully handle bork outs
	}

	string: {
		handleReceive(data.text)
	}

}


define_start

buildPduArray(pduBase)
openSocket()
