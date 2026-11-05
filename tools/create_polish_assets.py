"""Cria o pacote Cartoon v2 e sons próprios sem alterar o conjunto inicial."""
import argparse,math,random,struct,wave
from pathlib import Path
import create_starter_art as starter
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'assets/art/cartoon_v2'
AUDIO=ROOT/'assets/audio'

def polished_character(mood):
    s=starter.character(mood).replace('width="256" height="256"','width="512" height="512"',1)
    defs='''<defs><linearGradient id="skin" x2="0.8" y2="1"><stop stop-color="#ffd2a0"/><stop offset="1" stop-color="#cb865f"/></linearGradient><linearGradient id="suit" x2="0.4" y2="1"><stop stop-color="#ffe47c"/><stop offset="1" stop-color="#e3912f"/></linearGradient><linearGradient id="hair" x2="0.7" y2="1"><stop stop-color="#75504b"/><stop offset="1" stop-color="#30252f"/></linearGradient></defs>'''
    s=s.replace('<g stroke=',defs+'<g stroke=',1).replace('fill="#eab48d"','fill="url(#skin)"').replace('fill="#ffbd45"','fill="url(#suit)"').replace('fill="#48302d"','fill="url(#hair)"')
    detail='<g stroke-linecap="round" stroke-linejoin="round">'
    if not mood.startswith('zap'):
        detail+='<path d="M101 69Q98 72 99 77" fill="none" stroke="#ffe5b9" stroke-width="4"/><path d="M155 74Q164 109 141 121" fill="none" stroke="#ac674f" stroke-width="4" opacity="0.35"/><ellipse cx="104" cy="102" rx="7" ry="4" fill="#e99073" opacity="0.55"/><ellipse cx="151" cy="102" rx="7" ry="4" fill="#e99073" opacity="0.55"/><path d="M104 140L111 136M153 142L155 151" stroke="#fff0a7" stroke-width="3"/><path d="M128 132L119 146H128L124 154L140 140H131L136 132Z" fill="#49322b" opacity="0.7"/><path d="M105 195L115 196M145 196L155 195" stroke="#5b6d7a" stroke-width="4"/>'
    else:
        detail+='<path d="M99 133L77 143L64 119M155 133L179 142L193 119" fill="none" stroke="#f1eee1" stroke-width="5"/><circle cx="77" cy="143" r="4" fill="#f1eee1"/><circle cx="179" cy="142" r="4" fill="#f1eee1"/>'
    detail+='</g>'
    return s.replace('</svg>',detail+'</svg>')

def polished_chair(active):
    s=starter.chair(active).replace('width="256" height="256"','width="512" height="512"',1)
    s=s.replace('fill="#1e3343"','fill="#3c304a"').replace('#56717e','#77909b').replace('#253b49','#243545')
    details='<g fill="none" stroke-linecap="round"><path d="M86 78V121M169 78V121" stroke="#97778f" stroke-width="3" opacity="0.6"/><path d="M57 195Q23 190 28 145Q31 123 49 123M198 195Q235 188 230 145Q229 123 209 123" stroke="#09141e" stroke-width="9"/><path d="M57 195Q23 190 28 145Q31 123 49 123M198 195Q235 188 230 145Q229 123 209 123" stroke="'+('#ffcf5e'if active else '#527482')+'" stroke-width="3"/><path d="M91 224H165" stroke="#d6a441" stroke-width="5"/><path d="M98 222L93 228M114 222L109 228M130 222L125 228M146 222L141 228M162 222L157 228" stroke="#09141e" stroke-width="3"/></g>'
    return s.replace('</svg>',details+'</svg>')

def backgrounds():
    room='''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="320" viewBox="0 0 1024 320"><defs><linearGradient id="wall" x2="0" y2="1"><stop stop-color="#243b49"/><stop offset="1" stop-color="#101f2d"/></linearGradient><radialGradient id="lamp"><stop stop-color="#6ce1c4" stop-opacity="0.13"/><stop offset="1" stop-color="#6ce1c4" stop-opacity="0"/></radialGradient></defs><rect width="1024" height="320" fill="url(#wall)"/><ellipse cx="220" cy="155" rx="260" ry="180" fill="url(#lamp)"/><path d="M0 55H350V20H680V63H1024M0 230H410M750 230H1024" fill="none" stroke="#0a1722" stroke-width="18"/><path d="M0 55H350V20H680V63H1024" fill="none" stroke="#435864" stroke-width="5"/><path d="M362 0V288M735 0V288" stroke="#0b1a26" stroke-width="2"/><rect x="795" y="92" width="180" height="142" rx="12" fill="#152633" stroke="#314b59" stroke-width="4"/><path d="M820 115H950M820 131H950M820 147H950M820 163H950M820 179H950M820 195H950M820 211H950" stroke="#263e4c" stroke-width="5"/><rect x="55" y="275" width="914" height="45" fill="#182a36"/><path d="M0 276H1024" stroke="#465358" stroke-width="3"/><path d="M40 298H990" stroke="#bb9b42" stroke-width="11" opacity="0.28"/><path d="M50 288L32 310M100 288L82 310M150 288L132 310M200 288L182 310M250 288L232 310M300 288L282 310M350 288L332 310M400 288L382 310M450 288L432 310M500 288L482 310M550 288L532 310M600 288L582 310M650 288L632 310M700 288L682 310M750 288L732 310M800 288L782 310M850 288L832 310M900 288L882 310M950 288L932 310" stroke="#0b1823" stroke-width="9"/></svg>'''
    ui='''<svg xmlns="http://www.w3.org/2000/svg" width="720" height="1280" viewBox="0 0 720 1280"><defs><linearGradient id="bg" x2="0.4" y2="1"><stop stop-color="#192b39"/><stop offset="0.45" stop-color="#091722"/><stop offset="1" stop-color="#101f2d"/></linearGradient><radialGradient id="glow"><stop stop-color="#2e787c" stop-opacity="0.25"/><stop offset="1" stop-color="#2e787c" stop-opacity="0"/></radialGradient><pattern id="lines" width="48" height="48" patternUnits="userSpaceOnUse"><path d="M0 0L48 48" stroke="#9ab9c3" stroke-opacity="0.025"/></pattern></defs><rect width="720" height="1280" fill="url(#bg)"/><ellipse cx="520" cy="170" rx="440" ry="300" fill="url(#glow)"/><rect width="720" height="1280" fill="url(#lines)"/><g stroke="#334957" stroke-width="2" fill="none" opacity="0.5"><path d="M15 0V275L28 288V690L15 703V1280M705 0V275L692 288V690L705 703V1280"/><path d="M0 18H720M0 1262H720"/></g><g fill="#53707b" opacity="0.55"><circle cx="14" cy="15" r="4"/><circle cx="706" cy="15" r="4"/><circle cx="14" cy="1265" r="4"/><circle cx="706" cy="1265" r="4"/></g></svg>'''
    return room,ui

def sound(name):
    rate=22050;durations={'rotate':0.065,'ui':0.045,'denied':0.12,'hint':0.26,'zap':0.48,'win':0.62,'lose':0.45,'warning':0.13,'hum':0.5}
    count=int(rate*durations[name]);rng=random.Random(491);pcm=[]
    for i in range(count):
        t=i/rate;u=i/max(count-1,1);envelope=min(1,t*180)*(1-u)**2
        if name in ('rotate','ui'):value=(rng.uniform(-1,1)*0.25+math.sin(2*math.pi*(760 if name=='rotate'else 1100)*t)*0.35)*envelope
        elif name=='denied':value=(math.sin(2*math.pi*155*t)+0.2*math.sin(2*math.pi*310*t))*0.35*envelope
        elif name=='hint':value=math.sin(2*math.pi*(550*t+1100*t*t))*0.5*envelope
        elif name=='zap':value=(0.25*rng.uniform(-1,1)+0.3*math.sin(2*math.pi*92*t)+0.2*math.sin(2*math.pi*(920*t-400*t*t)))*(0.65+0.35*math.sin(2*math.pi*33*t))*envelope
        elif name in ('win','lose'):
            frequencies=[523.25,659.25,783.99,1046.5]if name=='win'else [330,246.94,196]
            index=min(int(u*len(frequencies)),len(frequencies)-1);local=(u*len(frequencies))%1
            value=(math.sin(2*math.pi*frequencies[index]*t)+0.18*math.sin(4*math.pi*frequencies[index]*t))*0.43*min(1,local*20)*(1-local)**0.7*min(1,t*100)*(1-u)**0.3
        elif name=='warning':value=math.sin(2*math.pi*880*t)*0.32*envelope
        else:value=0.18*math.sin(2*math.pi*50*t)+0.07*math.sin(2*math.pi*100*t)+0.025*math.sin(2*math.pi*150*t)
        pcm.append(max(-0.85,min(0.85,value)))
    if name!='hum':pcm[0]=0;pcm[-1]=0
    return rate,b''.join(struct.pack('<h',round(v*32767))for v in pcm)

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--overwrite',action='store_true');args=parser.parse_args()
    names=['idle','idle_blink','worried','anticipation','zap_a','zap_b','recover','win','lose']
    files={ART/f'character_{n}.svg':polished_character(n)for n in names}
    files.update({ART/'chair_idle.svg':polished_chair(False),ART/'chair_active.svg':polished_chair(True)})
    room,ui=backgrounds();files[ART/'room_background.svg']=room;files[ART/'ui_background.svg']=ui
    resource=(ROOT/'assets/art/default_art.tres').read_text(encoding='utf-8').replace('load_steps=22','load_steps=24').replace('Cartoon inicial v1','Cartoon laboratório v2')
    for n in [f'character_{n}'for n in names]+['chair_idle','chair_active']:
        resource=resource.replace('starter/'+n+'.svg','cartoon_v2/'+n+'.svg')
    resource=resource.replace('[sub_resource type="SpriteFrames" id="CharacterFrames"]','[ext_resource type="Texture2D" path="res://assets/art/cartoon_v2/room_background.svg" id="20"]\n[ext_resource type="Texture2D" path="res://assets/art/cartoon_v2/ui_background.svg" id="21"]\n\n[sub_resource type="SpriteFrames" id="CharacterFrames"]')
    resource+='room_background = ExtResource("20")\nui_background = ExtResource("21")\n'
    files[ART.parent/'cartoon_v2.tres']=resource
    if not args.overwrite and any(p.exists()for p in files):parser.error('Pacote v2 já existe. Use --overwrite somente para reconstruí-lo.')
    for p,s in files.items():p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf-8')
    AUDIO.mkdir(parents=True,exist_ok=True)
    for n in ['rotate','ui','denied','hint','zap','win','lose','warning','hum']:
        path=AUDIO/(n+'.wav')
        if path.exists()and not args.overwrite:parser.error('Sons já existem; --overwrite para reconstruir.')
        rate,pcm=sound(n)
        with wave.open(str(path),'wb')as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(pcm)
    print('Pacote visual v2 e nove sons próprios criados.')
if __name__=='__main__':main()
