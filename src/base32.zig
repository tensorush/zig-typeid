//! Optimized Crockford base32 encoding.
//! Source: https://www.crockford.com/base32.html

const std = @import("std");
const Base32 = @import("Base32");

const SET = "0123456789abcdefghjkmnpqrstvwxyz";

const DEC = [_]u8{
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x01,
    0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0A, 0x0B, 0x0C,
    0x0D, 0x0E, 0x0F, 0x10, 0x11, 0xFF, 0x12, 0x13, 0xFF, 0x14,
    0x15, 0xFF, 0x16, 0x17, 0x18, 0x19, 0x1A, 0xFF, 0x1B, 0x1C,
    0x1D, 0x1E, 0x1F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
};

/// Encodes UUID into a base32 string.
pub fn encode(src: [16]u8) [26]u8 {
    var dst: [26]u8 = undefined;

    dst[0] = SET[(src[0] & 224) >> 5];
    dst[1] = SET[src[0] & 31];
    dst[2] = SET[(src[1] & 248) >> 3];
    dst[3] = SET[((src[1] & 7) << 2) | ((src[2] & 192) >> 6)];
    dst[4] = SET[(src[2] & 62) >> 1];
    dst[5] = SET[((src[2] & 1) << 4) | ((src[3] & 240) >> 4)];
    dst[6] = SET[((src[3] & 15) << 1) | ((src[4] & 128) >> 7)];
    dst[7] = SET[(src[4] & 124) >> 2];
    dst[8] = SET[((src[4] & 3) << 3) | ((src[5] & 224) >> 5)];
    dst[9] = SET[src[5] & 31];
    dst[10] = SET[(src[6] & 248) >> 3];
    dst[11] = SET[((src[6] & 7) << 2) | ((src[7] & 192) >> 6)];
    dst[12] = SET[(src[7] & 62) >> 1];
    dst[13] = SET[((src[7] & 1) << 4) | ((src[8] & 240) >> 4)];
    dst[14] = SET[((src[8] & 15) << 1) | ((src[9] & 128) >> 7)];
    dst[15] = SET[(src[9] & 124) >> 2];
    dst[16] = SET[((src[9] & 3) << 3) | ((src[10] & 224) >> 5)];
    dst[17] = SET[src[10] & 31];
    dst[18] = SET[(src[11] & 248) >> 3];
    dst[19] = SET[((src[11] & 7) << 2) | ((src[12] & 192) >> 6)];
    dst[20] = SET[(src[12] & 62) >> 1];
    dst[21] = SET[((src[12] & 1) << 4) | ((src[13] & 240) >> 4)];
    dst[22] = SET[((src[13] & 15) << 1) | ((src[14] & 128) >> 7)];
    dst[23] = SET[(src[14] & 124) >> 2];
    dst[24] = SET[((src[14] & 3) << 3) | ((src[15] & 224) >> 5)];
    dst[25] = SET[src[15] & 31];

    return dst;
}

/// Decodes UUID from a base32 string.
pub fn decode(str: [26]u8) error{InvalidSuffixCharacter}![16]u8 {
    if (DEC[str[0]] == 0xFF or
        DEC[str[1]] == 0xFF or
        DEC[str[2]] == 0xFF or
        DEC[str[3]] == 0xFF or
        DEC[str[4]] == 0xFF or
        DEC[str[5]] == 0xFF or
        DEC[str[6]] == 0xFF or
        DEC[str[7]] == 0xFF or
        DEC[str[8]] == 0xFF or
        DEC[str[9]] == 0xFF or
        DEC[str[10]] == 0xFF or
        DEC[str[11]] == 0xFF or
        DEC[str[12]] == 0xFF or
        DEC[str[13]] == 0xFF or
        DEC[str[14]] == 0xFF or
        DEC[str[15]] == 0xFF or
        DEC[str[16]] == 0xFF or
        DEC[str[17]] == 0xFF or
        DEC[str[18]] == 0xFF or
        DEC[str[19]] == 0xFF or
        DEC[str[20]] == 0xFF or
        DEC[str[21]] == 0xFF or
        DEC[str[22]] == 0xFF or
        DEC[str[23]] == 0xFF or
        DEC[str[24]] == 0xFF or
        DEC[str[25]] == 0xFF)
    {
        return error.InvalidSuffixCharacter;
    }

    var id: [16]u8 = undefined;

    id[0] = (DEC[str[0]] << 5) | DEC[str[1]];
    id[1] = (DEC[str[2]] << 3) | (DEC[str[3]] >> 2);
    id[2] = (DEC[str[3]] << 6) | (DEC[str[4]] << 1) | (DEC[str[5]] >> 4);
    id[3] = (DEC[str[5]] << 4) | (DEC[str[6]] >> 1);
    id[4] = (DEC[str[6]] << 7) | (DEC[str[7]] << 2) | (DEC[str[8]] >> 3);
    id[5] = (DEC[str[8]] << 5) | DEC[str[9]];
    id[6] = (DEC[str[10]] << 3) | (DEC[str[11]] >> 2);
    id[7] = (DEC[str[11]] << 6) | (DEC[str[12]] << 1) | (DEC[str[13]] >> 4);
    id[8] = (DEC[str[13]] << 4) | (DEC[str[14]] >> 1);
    id[9] = (DEC[str[14]] << 7) | (DEC[str[15]] << 2) | (DEC[str[16]] >> 3);
    id[10] = (DEC[str[16]] << 5) | DEC[str[17]];
    id[11] = (DEC[str[18]] << 3) | DEC[str[19]] >> 2;
    id[12] = (DEC[str[19]] << 6) | (DEC[str[20]] << 1) | (DEC[str[21]] >> 4);
    id[13] = (DEC[str[21]] << 4) | (DEC[str[22]] >> 1);
    id[14] = (DEC[str[22]] << 7) | (DEC[str[23]] << 2) | (DEC[str[24]] >> 3);
    id[15] = (DEC[str[24]] << 5) | DEC[str[25]];

    return id;
}

test "encode/decode" {
    var i: u16 = 0;
    while (i < 1000) : (i += 1) {
        var bytes: [16]u8 = undefined;
        const encoder = Base32.initWithPadding(SET, '=');
        var prng = std.rand.DefaultPrng.init(0);
        const random = prng.random();
        random.bytes(bytes[0..]);

        var encoded = encode(bytes);
        var expected: [32]u8 = undefined;
        const padded_bytes = ([1]u8{0x00} ** 4) ++ bytes;
        var expected_slice = encoder.encode(expected[0..], padded_bytes[0..])[6..32];
        try std.testing.expectEqualSlices(u8, expected_slice, encoded[0..]);

        const decoded = try decode(encoded);
        try std.testing.expectEqual(bytes, decoded);
    }
}
