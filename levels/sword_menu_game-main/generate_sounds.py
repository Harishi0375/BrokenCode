import wave
import math
import struct
import random

def generate_wav(filename, duration, sample_rate=44100, generator_func=None):
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        
        for i in range(int(duration * sample_rate)):
            t = i / sample_rate
            val = generator_func(t, i)
            # Clamp and convert to 16-bit int
            val = max(-1.0, min(1.0, val))
            f.writeframes(struct.pack('h', int(val * 32767.0)))

# 1. Click: Short, high pitched square wave
def click_gen(t, i):
    # 800 Hz square wave, fading out over 0.1s
    freq = 800
    env = max(0, 1.0 - t / 0.1)
    val = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
    return val * env * 0.5

# 2. Intro: Heavy, dropping frequency (metallic/retro explosion)
def intro_gen(t, i):
    freq = 300 * math.exp(-5 * t) # Pitch drop
    val = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
    # Add some noise
    val += random.uniform(-0.5, 0.5)
    env = max(0, 1.0 - t / 1.5)
    return val * env * 0.4

# 3. Stab: Quick white noise burst with a low pass sweep effect
def stab_gen(t, i):
    env = max(0, 1.0 - t / 0.4)
    # Just pure noise for a swoosh/stab
    return random.uniform(-1.0, 1.0) * env * 0.5

# 4. Ambient: Low rumble + wind noise
def ambient_gen(t, i):
    # 50 Hz sine wave for rumble
    rumble = math.sin(2 * math.pi * 50 * t)
    # Filtered noise would be better, but pure noise with low volume is ok
    wind = random.uniform(-1.0, 1.0) * 0.1
    # Loop seamlessly (we'll just generate 5 seconds, Godot can loop it)
    # Fade in and out
    env = 1.0
    if t < 1.0: env = t
    elif t > 4.0: env = 5.0 - t
    return (rumble * 0.3 + wind) * env * 0.4

# 5. Grass: Intermittent rustling (bursts of noise)
def grass_gen(t, i):
    # Burst every 0.3 seconds
    phase = t % 0.3
    env = max(0, 1.0 - phase / 0.1)
    noise = random.uniform(-1.0, 1.0)
    return noise * env * 0.2

print("Generating sound files...")
generate_wav('click_sound.wav', 0.1, generator_func=click_gen)
generate_wav('intro_sound.wav', 1.5, generator_func=intro_gen)
generate_wav('stab_sound.wav', 0.4, generator_func=stab_gen)
generate_wav('ambient_sound.wav', 5.0, generator_func=ambient_gen)
generate_wav('grass_sound.wav', 2.8, generator_func=grass_gen)
print("Done!")
