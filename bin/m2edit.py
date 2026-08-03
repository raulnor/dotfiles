# /// script
# requires-python = ">=3.11"
# ///
"""Read and write Mordor II beta character records."""

import argparse
import os
import struct
import sys
from pathlib import Path

BASE, STRIDE, NAME_LEN = 0x1838, 3100, 30

FIELDS = {
    'name':  (0x000, '<30s', 'ascii'),
    'str':   (0x038, '<h', 'int'),
    'int':   (0x03a, '<h', 'int'),
    'wis':   (0x03c, '<h', 'int'),
    'con':   (0x03e, '<h', 'int'),
    'cha':   (0x040, '<h', 'int'),
    'dex':   (0x042, '<h', 'int'),
    'gold':  (0x676, '<q', 'currency'),
}

class CharacterNotFoundError(RuntimeError): pass
class ConfigError(RuntimeError): pass

def get_data_dir() -> Path:
    env_dir = os.environ.get("M2_DATA_DIR")
    if env_dir:
        return Path(env_dir)
    else:
        raise ConfigError("M2_DATA_DIR not set")

def decode(fmt, tag, value):
    if tag == 'ascii':
        return value.decode('ascii', 'replace').rstrip(' \x00')
    elif tag == 'currency':
        return int(round(float(value) / 10000))
    else:
        return value

def encode(fmt, tag, value):
    size = None
    if fmt.endswith('s'):
        size = int(fmt[:-1]) # '30s' -> 30
    if tag == 'ascii':
        raw = value.encode('ascii')[:size] # truncate
        raw = raw.ljust(size, b' ') # pad
        return raw
    elif tag == 'int':
        return int(value)
    elif tag == 'currency':
        return int(round(float(value) * 10000))
    else:
        return value

def get_character_name(data, o):
    return data[o:o+NAME_LEN].decode('ascii', 'replace').rstrip(' \x00').strip()

def get_character_start(data, name):
    want = name.strip().lower()
    for o in range(BASE, len(data) - STRIDE + 1, STRIDE):
        rec = get_character_name(data, o)
        if rec.lower() == want:
            return o
    raise CharacterNotFoundError(f"character not found: {name}")

def get_character_value(data, character, key): 
    start = get_character_start(data, character)
    (offset, fmt, tag) = FIELDS[key]
    (value,) = struct.unpack_from(fmt, data, start+offset)
    return decode(fmt, tag, value)

def set_character_value(data, character, key, value): 
    start = get_character_start(data, character)
    (offset, fmt, tag) = FIELDS[key]
    struct.pack_into(fmt, data, start + offset, encode(fmt, tag, value))
    return data

def print_characters(data):
    for i in range((len(data)-BASE)//STRIDE):
        o = BASE + i*STRIDE
        name = get_character_name(data, o)
        if not name: continue
        hp   = struct.unpack_from('<f', data, o+0x30)[0]
        stats= struct.unpack_from('<6h', data, o+0x38)
        print(f"{name:12} hp={hp:6.1f} stats={stats}")

def main():
    p = argparse.ArgumentParser(description="Mordor II character field editor")
    p.add_argument('character', nargs='?')
    p.add_argument('verb', nargs='?', choices=['get', 'set'])
    p.add_argument('key', nargs='?')
    p.add_argument('value', nargs='?')
    a = p.parse_args()
    try:
        path = get_data_dir() / 'MDATA4.MDR'
        data = bytearray(path.read_bytes())
    except ConfigError as e:
        print("M2_DATA_DIR not set in environment or config!", file=sys.stderr)
        return 64
    except OSError as e:
        print(f"no data file at {e.filename} — is the path right?", file=sys.stderr)
        return 65
    if a.character is None:
        print_characters(data)
        return 0
    try:
        if a.verb == 'get':
            print(get_character_value(data, a.character, a.key))
        elif a.verb == 'set':
            new_data = set_character_value(data, a.character, a.key, a.value)
            tmp = path.with_suffix(path.suffix + '.tmp')
            tmp.write_bytes(new_data)
            os.replace(tmp, path)
        else:
            p.error("No action given - choose get / set")   
    except CharacterNotFoundError as e:
        print_characters(data)
        print(e, file=sys.stderr)
        return 66
    return 0

if __name__ == '__main__':
    sys.exit(main())
