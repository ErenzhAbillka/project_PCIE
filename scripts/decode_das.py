"""Decode a little-endian XDMA C2H dump of complete 64-KiB DAS slots."""
from pathlib import Path
import argparse, csv, math, struct

FRAME_BYTES=65536

def frames_from(data, completed=None, completed_after=None):
    if completed_after is not None and (completed is None or completed_after < completed):
        raise ValueError('Completion counters must bracket the read without reset or wrap.')
    # Exclude the slot being overwritten, including writes during the DMA read.
    oldest = max(0, (completed_after if completed_after is not None else completed or 0)-15)
    frames=[]
    for offset in range(0,len(data)-FRAME_BYTES+1,FRAME_BYTES):
        w=struct.unpack_from('<16384I',data,offset)
        if w[0]!=0x44415331 or w[2]!=16384: continue
        seq=w[1]
        if w[15]!=(~seq&0xffffffff) or w[-4:]!=(0x434f4d54,seq,~seq&0xffffffff,0x454e4421): continue
        if completed is not None and not oldest<=seq<completed: continue
        points,rows,start,width,total=w[3:8]
        if not points or not rows or not width or not w[8] or not w[13]: continue
        if rows*width!=total or start+width>points or max(points,total)>16364 or w[11]!=13 or w[14]!=1: continue
        if len(data)>=16*FRAME_BYTES and offset//FRAME_BYTES!=seq%16: continue
        payload=w[16:16+max(points,total)]
        differences=[v&65535 for v in payload[:points]]
        phases=[((v>>16)^32768)-32768 for v in payload[:total]]
        frames.append((seq,w[:16],differences,phases))
    return sorted(frames,key=lambda x:x[0])

def unwrap(values):
    out=[]
    for value in values:
        if not out: out.append(value)
        else: out.append(out[-1]+(value-out[-1]+math.pi)%(2*math.pi)-math.pi)
    return out

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('binary',type=Path)
    parser.add_argument('--completed',type=int,help='VIO probe_in8 DDR frames completed; excludes old/uncommitted slots')
    parser.add_argument('--completed-after',type=int,help='Same counter read after C2H completes; rejects slots overwritten during the read')
    parser.add_argument('--output',type=Path,default=Path('das_decoded'))
    args=parser.parse_args()
    frames=frames_from(args.binary.read_bytes(),args.completed,args.completed_after)
    if not frames: raise SystemExit('No complete matching DAS frame found; verify C2H address 0x00100000 and completion count.')
    args.output.mkdir(parents=True,exist_ok=True)
    with (args.output/'difference.csv').open('w',newline='') as df, (args.output/'phase_roi.csv').open('w',newline='') as pf, (args.output/'phase_relative.csv').open('w',newline='') as rf:
        dw,pw,rw=csv.writer(df),csv.writer(pf),csv.writer(rf)
        dw.writerow(['group','point','difference_u16','acc_shift'])
        pw.writerow(['group','trace','point','phase_q13','radians'])
        rw.writerow(['segment','group','trace','time_s','relative_phase_rad','temporal_unwrapped_rad'])
        previous_seq=None; segment=-1; last_unwrapped=None
        for seq,h,diffs,phases in frames:
            if previous_seq is None or seq!=previous_seq+1:
                segment+=1; last_unwrapped=None
            previous_seq=seq
            dw.writerows((seq,i,v,h[10]) for i,v in enumerate(diffs))
            for trace in range(h[4]):
                row=phases[trace*h[6]:(trace+1)*h[6]]
                pw.writerows((seq,trace,h[5]+i,v,v/8192) for i,v in enumerate(row))
                spatial=unwrap([v/8192 for v in row]); relative=spatial[-1]-spatial[0]
                temporal=relative if last_unwrapped is None else last_unwrapped+(relative-last_unwrapped+math.pi)%(2*math.pi)-math.pi
                last_unwrapped=temporal
                rw.writerow([segment,seq,trace,(seq*h[4]+trace)*h[13]/h[8],relative,temporal])
    print(f'Decoded {len(frames)} frames (groups {frames[0][0]}..{frames[-1][0]}) into {args.output.resolve()}')
    if args.completed is None: print('Completion count not provided: stale DDR slots from a previous run cannot be excluded.')
    elif args.completed_after is None: print('Post-read count not provided: concurrent DDR overwrite during the read cannot be excluded.')

if __name__=='__main__': main()
