const std = @import("std");
const lightmix = @import("lightmix");
const lightmix_filters = @import("lightmix_filters");
const lightmix_synths = @import("lightmix_synths");
const lightmix_temperaments = @import("lightmix_temperaments");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;
const Scale = lightmix_temperaments.TwelveEqualTemperament;

pub fn gen() !Wave(f128) {
    const allocator = std.heap.page_allocator;

    var sine: Wave(f128) = try lightmix_synths.Basic.Sine.gen(f128, .{
        .frequency = Scale.gen(.{ .code = .c, .octave = 4 }),
        .amplitude = 1.0,
        .length = 88200,
        .allocator = allocator,

        .sample_rate = 44100,
        .channels = 1,
    });
    try sine.filter(normalize);

    return sine;
}

fn normalize(comptime T: type, original_wave: Wave(T)) !Wave(T) {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(T, null) = .empty;

    var max_volume: T = 0.0;
    for (original_wave.samples) |sample| {
        if (@abs(sample) > max_volume)
            max_volume = @abs(sample);
    }

    for (original_wave.samples) |sample| {
        const volume: T = 1.0 / max_volume;

        const new_sample: T = sample * volume;
        try result.append(allocator, new_sample);
    }

    return Wave(T){
        .samples = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
    };
}
