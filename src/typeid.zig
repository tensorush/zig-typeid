//! Root library file that exposes the public API.

const std = @import("std");
const Uuid = @import("Uuid");
const base32 = @import("base32.zig");

pub const Error = error{
    InvalidPrefixCharacter,
    InvalidSuffixCharacter,
    InvalidPrefixLength,
    InvalidSuffixLength,
    InvalidFormat,
    InvalidPrefix,
    NoGetPrefixFn,
} || Uuid.Error || std.fmt.BufPrintError;

const hasGetPrefixFn = std.meta.trait.hasFn("getPrefix");

/// Type-safe extension of UUIDv7.
pub fn TypeId(comptime T: type) Error!type {
    const type_prefix = if (hasGetPrefixFn(T))
        T.getPrefix()
    else
        return error.NoGetPrefixFn;

    if (type_prefix.len > 63) return Error.InvalidPrefixLength;

    if (type_prefix.len > 0) {
        for (type_prefix) |c| {
            if (!std.ascii.isLower(c)) {
                return error.InvalidPrefixCharacter;
            }
        }
    }

    return struct {
        const Self = @This();

        prefix: []const u8,
        suffix: [26]u8,

        /// Returns a new TypeID with the given prefix and a random suffix.
        pub fn new(prefix: []const u8) Error!Self {
            return try from(prefix, "");
        }

        /// Returns a new TypeID with the given prefix and suffix.
        pub fn from(prefix: []const u8, suffix: []const u8) Error!Self {
            if (!std.mem.eql(u8, prefix, type_prefix)) {
                return error.InvalidPrefix;
            }

            var suffix_base32: [26]u8 = undefined;
            if (suffix.len == 0) {
                const uuid = Uuid.V7.new();
                suffix_base32 = base32.encode(uuid.bytes);
            } else if (suffix.len == 26) {
                @memcpy(suffix_base32[0..], suffix);
                _ = try base32.decode(suffix_base32);
            } else {
                return error.InvalidSuffixLength;
            }

            return Self{ .prefix = prefix, .suffix = suffix_base32 };
        }

        /// Returns a new TypeID from a string formatted as <prefix>_<suffix>.
        pub fn fromString(str: []const u8) Error!Self {
            if (std.mem.lastIndexOfScalar(u8, str, '_')) |idx| {
                if (str[0..idx].len > 0) {
                    return try from(str[0..idx], str[idx + 1 ..]);
                }
            } else {
                return try from("", str);
            }
            return error.InvalidFormat;
        }

        /// Encodes the given hex string UUID as a TypeID with the given prefix.
        pub fn fromUuid(prefix: []const u8, uuid_str: []const u8) Error!Self {
            const uuid = try Uuid.fromString(uuid_str);
            const suffix = base32.encode(uuid.bytes);
            return try from(prefix, suffix[0..]);
        }

        /// Encodes the given UUID bytes as a TypeID with the given prefix.
        pub fn fromUuidBytes(prefix: []const u8, bytes: []const u8) Error!Self {
            var uuid_str: [36]u8 = undefined;
            _ = try std.fmt.bufPrint(uuid_str[0..], "{s}", .{Uuid.fromBytes(bytes)});
            return try fromUuid(prefix, uuid_str[0..]);
        }

        /// Returns the type prefix of the TypeID.
        pub fn getPrefix(self: Self) []const u8 {
            return self.prefix;
        }

        /// Returns the UUID suffix of the TypeID in its base32 representation.
        pub fn getSuffix(self: Self) []const u8 {
            return self.suffix[0..];
        }

        /// Decodes the TypeID's suffix as a UUID and returns its bytes.
        pub fn getUuidBytes(self: Self) Error![16]u8 {
            return try base32.decode(self.suffix);
        }

        /// Decodes the TypeID's suffix as a UUID and returns it as a hex string.
        pub fn getUuidString(self: Self) Error![36]u8 {
            var uuid_str: [36]u8 = undefined;
            const bytes = try self.getUuidBytes();
            _ = try std.fmt.bufPrint(uuid_str[0..], "{s}", .{Uuid.fromBytes(bytes[0..])});
            return uuid_str;
        }

        /// Formats the TypeID as <prefix>_<suffix>.
        pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) @TypeOf(writer).Error!void {
            if (self.prefix.len > 0) {
                try std.fmt.format(writer, "{s}_{s}", .{ self.prefix, self.suffix });
            } else {
                try std.fmt.format(writer, "{s}", .{self.suffix});
            }
        }
    };
}

const TestEmpty = struct {
    pub fn getPrefix() []const u8 {
        return "";
    }
};

const TestPrefix = struct {
    pub fn getPrefix() []const u8 {
        return "prefix";
    }
};

const TestCaps = struct {
    pub fn getPrefix() []const u8 {
        return "PREFIX";
    }
};

const TestNums = struct {
    pub fn getPrefix() []const u8 {
        return "12345";
    }
};

const TestDot = struct {
    pub fn getPrefix() []const u8 {
        return "pre.fix";
    }
};

const TestUnderscore = struct {
    pub fn getPrefix() []const u8 {
        return "pre_fix";
    }
};

const TestNonAscii = struct {
    pub fn getPrefix() []const u8 {
        return "préfix";
    }
};

const TestSpaces = struct {
    pub fn getPrefix() []const u8 {
        return "  prefix";
    }
};

const TestTooLarge = struct {
    pub fn getPrefix() []const u8 {
        return "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl";
    }
};

const TestType = union(enum) {
    empty: TestEmpty,
    prefix: TestPrefix,
    caps: TestCaps,
    nums: TestNums,
    dot: TestDot,
    underscore: TestUnderscore,
    non_ascii: TestNonAscii,
    spaces: TestSpaces,
    too_large: TestTooLarge,
};

const VALID_TESTS = [_]struct {
    T: TestType,
    tid: []const u8,
    prefix: []const u8,
    uuid: []const u8,
}{
    // Suffix is the nil UUIDv7.
    .{ .T = .{ .empty = TestEmpty{} }, .tid = "00000000000000000000000000", .prefix = "", .uuid = "00000000-0000-0000-0000-000000000000" },
    // Suffix is one.
    .{ .T = .{ .empty = TestEmpty{} }, .tid = "00000000000000000000000001", .prefix = "", .uuid = "00000000-0000-0000-0000-000000000001" },
    // Suffix is ten.
    .{ .T = .{ .empty = TestEmpty{} }, .tid = "0000000000000000000000000a", .prefix = "", .uuid = "00000000-0000-0000-0000-00000000000a" },
    // Suffix is 16.
    .{ .T = .{ .empty = TestEmpty{} }, .tid = "0000000000000000000000000g", .prefix = "", .uuid = "00000000-0000-0000-0000-000000000010" },
    // Suffix is 32.
    .{ .T = .{ .empty = TestEmpty{} }, .tid = "00000000000000000000000010", .prefix = "", .uuid = "00000000-0000-0000-0000-000000000020" },
    // Valid alphabet.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_0123456789abcdefghjkmnpqrs", .prefix = "prefix", .uuid = "0110c853-1d09-52d8-d73e-1194e95b5f19" },
    // Valid UUIDv7 suffix.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_01h455vb4pex5vsknk084sn02q", .prefix = "prefix", .uuid = "01890a5d-ac96-774b-bcce-b302099a8057" },
};

const INVALID_TESTS = [_]struct {
    T: TestType,
    tid: []const u8,
    err: Error,
}{
    // The prefix should be lowercase with no uppercase letters.
    .{ .T = .{ .caps = TestCaps{} }, .tid = "PREFIX_00000000000000000000000000", .err = Error.InvalidPrefixCharacter },
    // The prefix can't have numbers, it needs to be alphabetic.
    .{ .T = .{ .nums = TestNums{} }, .tid = "12345_00000000000000000000000000", .err = Error.InvalidPrefixCharacter },
    // The prefix can't have symbols, it needs to be alphabetic.
    .{ .T = .{ .dot = TestDot{} }, .tid = "pre.fix_00000000000000000000000000", .err = Error.InvalidPrefixCharacter },
    // The prefix can't have symbols, it needs to be alphabetic.
    .{ .T = .{ .underscore = TestUnderscore{} }, .tid = "pre_fix_00000000000000000000000000", .err = Error.InvalidPrefixCharacter },
    // The prefix can only have ASCII letters.
    .{ .T = .{ .non_ascii = TestNonAscii{} }, .tid = "préfix_00000000000000000000000000", .err = Error.InvalidPrefixCharacter },
    // The prefix can't have any spaces.
    .{ .T = .{ .spaces = TestSpaces{} }, .tid = "  prefix_00000000000000000000000000", .err = Error.InvalidPrefixCharacter },
    // The prefix can't be 64 characters, it needs to be 63 characters or less.
    .{ .T = .{ .too_large = TestTooLarge{} }, .tid = "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl_00000000000000000000000000", .err = Error.InvalidPrefixLength },
    // If the prefix is empty, the separator should not be there.
    .{ .T = .{ .empty = TestEmpty{} }, .tid = "_00000000000000000000000000", .err = Error.InvalidFormat },
    // A separator by itself should not be treated as the empty string.
    .{ .T = .{ .empty = TestEmpty{} }, .tid = "_", .err = Error.InvalidFormat },
    // The suffix can't be 25 characters, it needs to be exactly 26 characters.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_1234567890123456789012345", .err = Error.InvalidSuffixLength },
    // The suffix can't be 27 characters, it needs to be exactly 26 characters.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_123456789012345678901234567", .err = Error.InvalidSuffixLength },
    // The suffix can't have any spaces.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_1234567890123456789012345 ", .err = Error.InvalidSuffixCharacter },
    // The suffix should be lowercase with no uppercase letters.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_0123456789ABCDEFGHJKMNPQRS", .err = Error.InvalidSuffixCharacter },
    // The suffix should be lowercase with no uppercase letters.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_123456789-123456789-123456", .err = Error.InvalidSuffixCharacter },
    // The suffix should only have letters from the spec's alphabet.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_ooooooiiiiiiuuuuuuulllllll", .err = Error.InvalidSuffixCharacter },
    // The suffix should not have any ambiguous characters from the base32 encoding.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_i23456789ol23456789oi23456", .err = Error.InvalidSuffixCharacter },
    // The suffix can't ignore hyphens as in the base32 encoding.
    .{ .T = .{ .prefix = TestPrefix{} }, .tid = "prefix_123456789-0123456789-0123456", .err = Error.InvalidSuffixLength },
};

test "new/fromString" {
    const prefix_tid = try TypeId(TestPrefix);
    const empty_tid = try TypeId(TestEmpty);
    var i: u16 = 0;
    while (i < 1000) : (i += 1) {
        const exp_prefix_tid = try prefix_tid.new("prefix");
        var exp_str: [33]u8 = undefined;
        const actual_prefix_tid = try prefix_tid.fromString(try std.fmt.bufPrint(exp_str[0..], "{s}", .{exp_prefix_tid}));
        try std.testing.expectEqualDeep(exp_prefix_tid, actual_prefix_tid);

        var exp_empty_tid = try empty_tid.new("");
        var actual_empty_tid = try empty_tid.fromString(try std.fmt.bufPrint(exp_str[0..], "{s}", .{exp_empty_tid}));
        try std.testing.expectEqualDeep(exp_empty_tid, actual_empty_tid);
    }
}

test "valid" {
    inline for (VALID_TESTS) |t| {
        const Tid = switch (t.T) {
            inline else => |test_type| try TypeId(@TypeOf(test_type)),
        };
        const tid = try Tid.fromString(t.tid);
        try std.testing.expectEqualSlices(u8, t.prefix, tid.getPrefix());
        try std.testing.expectEqualSlices(u8, t.uuid, (try tid.getUuidString())[0..]);
    }
}

test "invalid" {
    inline for (INVALID_TESTS) |t| {
        const Tid = switch (t.T) {
            inline else => |test_type| TypeId(@TypeOf(test_type)) catch |err| try std.testing.expectError(t.err, @as(Error!type, err)),
        };
        if (@TypeOf(Tid) == void) {
            continue;
        }
        try std.testing.expectError(t.err, Tid.fromString(t.tid));
    }
}

test {
    std.testing.refAllDecls(@This());
}
