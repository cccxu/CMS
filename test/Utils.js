module.exports = {
    utf82Hex: function(str) {
        return web3.utils.utf8ToHex(str);
    },
    
    hex2Utf8: function (hex) {
        return web3.utils.hexToUtf8(hex);
    }
}