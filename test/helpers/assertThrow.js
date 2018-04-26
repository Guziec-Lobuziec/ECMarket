function assertError(error, s, message) {
    assert.isAbove(error.message.search(s), -1, message);
}

async function assertThrows(callback, message, errorCode) {
    try {
        await callback
    } catch (e) {
        return assertError(e, errorCode, message)
    }
    assert.fail('should have thrown before')
}

module.exports = {
    async assertJump(callback, message = 'should have failed with invalid JUMP') {
        return assertThrows(callback, message, 'invalid JUMP')
    },

    async assertInvalidOpcode(callback, message = 'should have failed with invalid opcode') {
        return assertThrows(callback, message, 'invalid opcode')
    },

    async assertRevert(callback, message = 'should have failed by reverting') {
        return assertThrows(callback, message, 'revert')
    },
}
