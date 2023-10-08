# Testing out the random number generator used in vapor.
#

import bitarray
import copy

def rotateleft(b: bitarray.bitarray, n: int = 1) -> bitarray.bitarray:
    c = copy.deepcopy(b)
    c1 = c[:n]
    c2 = c[n:]
    c2.extend(c1)
    c = c2
    return c

init_state = bitarray.bitarray([0,0,0,0,0,0,0,1])
lfsr = copy.deepcopy(init_state)
print(f"init_state: {init_state}, {int.from_bytes(lfsr.tobytes(), 'big')}")

period = 0
original_state = copy.deepcopy(lfsr)
for n in range(255):
    lfsr ^= lfsr >> 2
    lfsr ^= lfsr << 5
    lfsr ^= lfsr >> 7
    print(f"next_state: {lfsr}, {int.from_bytes(lfsr.tobytes(), 'big')}")

    period += 1
    if lfsr == original_state:
        print(f"period: {period}")
        break

