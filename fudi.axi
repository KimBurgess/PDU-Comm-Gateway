PROGRAM_NAME='fudi'
#if_not_defined __LIB_FUDI
#define __LIB_FUDI


define_constant
FUDI_PACKED_SIZE_LIMIT	= 1024
FUDI_ATOM_SIZE_LIMIT = 256


/**
 * Checks if a character is one of the FUDI defined whitespace characters.
 *
 * @param	c			the character to check
 * @return				a boolean, true if the character is considered
 *						whitespace
 */
define_function char isFudiWhitespace(char c) {
	return $20 == c || $09 == c || $0A == c
}

/**
 * Escape whitespace within a FUDI atom.
 *
 * @param	atom		a string containing the atom to escape
 * @return				the encoded atom
 */
define_function char[FUDI_ATOM_SIZE_LIMIT] fudiEncode(char atom[]) {
	stack_var char ret[FUDI_ATOM_SIZE_LIMIT]
	stack_var integer i

	for (i = 1; i <= length_string(atom); i++) {
		if (isFudiWhitespace(atom[i])) {
			ret = "ret, '\', atom[i]"
		} else {
			ret = "ret, atom[i]"
		}
	}

	return ret
}

/**
 * Unescape any characters within a single fudi atom.
 *
 * @param	atom		a string contianing the encoded fudi string
 * @return				the decoded atom
 */
define_function char[FUDI_ATOM_SIZE_LIMIT] fudiDecode(char atom[]) {
	stack_var char ret[FUDI_ATOM_SIZE_LIMIT]
	stack_var integer i

	i = 1
	while (i < length_array(atom)) {
		if ('\' == atom[i] && isFudiWhitespace(atom[i + 1])) {
			i++
		}
		ret = "ret, atom[i]"
		i++
	}

	return ret
}

/**
 * Packs a set of FUDI atoms into a string ready for transmission.
 *
 * @param	atoms		an array of string containing
 */
define_function char[FUDI_PACKED_SIZE_LIMIT] fudiPack(char atoms[][]) {
	stack_var char ret[FUDI_PACKED_SIZE_LIMIT]
	stack_var integer i

	for (i = 1; i < length_array(atoms); i++) {
		ret = "ret, fudiEncode(atoms[i]), ' '"
	}
	ret = "ret, fudiEncode(atoms[i]), ';', $0A"

	return ret
}

/**
 * Unpacks a FUDI string into its component atoms.
 *
 * @param	fudiString	a string containing the FUDI command to unpack
 * @param	atoms		a multidimensional array to unpack the atoms in to
 * @return				the number of component atoms unpacked
 */
define_function integer fudiUnpack(char fudiString[], char atoms[][]) {
	stack_var integer atom
	stack_var integer i
	stack_var integer end

	end = find_string(fudiString, "';'", 1)
	if (!end) {
		return 0
	}

	atom = 1
	i = 1

	while (isFudiWhitespace(fudiString[i])) {
		i++
		if (i >= end) {
			return 0
		}
	}

	while (i < end) {
		if ('\' == fudiString[i]) {
			i++
			if (i >= end) {
				break
			}
		}

		atoms[atom] = "atoms[atom], fudiString[i]"
		i++
		if (i >= end) {
			break
		}

		if (isFudiWhitespace(fudiString[i])) {
			atom++
			while (isFudiWhitespace(fudiString[i])) {
				i++
				if (i >= end) {
					break
				}
			}
		}
	}

	return atom
}


#end_if