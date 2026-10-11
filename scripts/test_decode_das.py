import math,struct
from decode_das import frames_from,unwrap
w=[0]*16384
w[:16]=[0x44415331,0,16384,8,2,1,2,4,125000000,50000000,7,13,0,31250,1,0xffffffff]
w[16:24]=[0x10000009,0xffff000a,0x2000000b,0x8000000c,13,14,15,16]
w[-4:]=[0x434f4d54,0,0xffffffff,0x454e4421]
data=struct.pack('<16384I',*w)
frames=frames_from(data,1)
assert len(frames)==1
assert frames[0][2]==list(range(9,17))
assert frames[0][3]==[4096,-1,8192,-32768]
assert frames_from(data,0)==[] and frames_from(data[:-1],1)==[]
assert len(frames_from(data,1,15))==1
assert frames_from(data,1,16)==[]  # sequence 16 can already overwrite slot 0
assert frames_from(data,16)==[]
for index in (3,4,6,8,13):
    malformed=w.copy()
    malformed[index]=0
    if index in (4,6): malformed[7]=0
    assert frames_from(struct.pack('<16384I',*malformed),1,1)==[],index
w[-2]=0
assert frames_from(struct.pack('<16384I',*w),1)==[]
assert abs(unwrap([3.1,-3.1])[1]-(2*math.pi-3.1))<1e-9
print('DAS_DECODER_TEST_PASS: signed phase, scaled difference, stale/partial/torn and concurrent-overwrite rejection, nonzero dimensions/timing, unwrap')
