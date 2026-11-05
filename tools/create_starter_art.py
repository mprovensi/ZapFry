"""Sprites SVG iniciais e recurso Godot. Nunca sobrescreve arte sem --overwrite."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'assets/art/starter'
INK = '#09141e'

def svg(body):
    return '<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">'+body+'</svg>\n'

def character(mood):
    zap = mood.startswith('zap')
    raised = mood in ('anticipation','zap_a','zap_b','recover','win')
    spiky = mood in ('zap_a','zap_b','recover','win')
    body = f'<g stroke="{INK}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">'
    body += '<path d="M106 175L101 217H118L124 182M150 175L157 217H139L132 182" fill="#293847"/>'
    body += '<path d="M94 214Q105 209 121 217L119 230H88Q85 220 94 214ZM141 217Q155 208 164 217L174 230H140Z" fill="#152431"/>'
    body += '<path d="M101 124Q127 113 155 124L168 181Q130 199 89 180Z" fill="'+('#263747' if zap else '#ffbd45')+'"/>'
    body += '<path d="M92 159H165L167 172H90Z" fill="#344756"/><rect x="120" y="157" width="19" height="18" rx="3" fill="#8fa8ac"/>'
    if raised:
        body += '<path d="M99 133L76 143L64 119M155 133L180 142L193 119" fill="none" stroke="'+('#e8eee0' if zap else '#ffbd45')+'" stroke-width="17"/>'
        body += '<path d="M58 119L54 108M64 116L63 103M192 116L194 103M198 119L204 108" stroke="#e6ad84" stroke-width="9"/>'
    else:
        body += '<path d="M99 133L78 157L65 155M155 133L178 158L191 155" fill="none" stroke="#ffbd45" stroke-width="17"/>'
        body += '<path d="M59 154L72 158M185 158L199 154" stroke="#e6ad84" stroke-width="10"/>'
    body += '<path d="M109 126L126 140L146 124" fill="#d38a35"/>'
    body += '<path d="M110 55Q127 45 151 56L161 102Q151 126 126 128Q99 124 91 102L94 68Z" fill="'+('#f1eee1' if zap else '#eab48d')+'"/>'
    body += '<ellipse cx="90" cy="87" rx="8" ry="13" fill="'+('#f1eee1' if zap else '#eab48d')+'"/><ellipse cx="163" cy="87" rx="8" ry="13" fill="'+('#f1eee1' if zap else '#eab48d')+'"/>'
    if spiky:
        body += '<path d="M94 71L82 39L107 47L113 20L131 43L150 25L153 49L176 41L162 73L147 59L132 64L112 57Z" fill="#48302d"/>'
    else:
        body += '<path d="M94 71Q81 41 110 38L118 29L134 39Q162 34 166 70L149 60Q127 65 112 51Z" fill="#48302d"/>'
    if zap:
        body += '<ellipse cx="111" cy="85" rx="13" ry="16" fill="#09141e"/><ellipse cx="144" cy="85" rx="13" ry="16" fill="#09141e"/><path d="M126 94L120 104H132Z" fill="#09141e"/>'
        body += '<rect x="110" y="109" width="35" height="12" rx="4" fill="#f1eee1"/><path d="M120 111V119M133 111V119M128 139V182M113 143L141 148M112 156L142 161M117 170H140" stroke="#f1eee1" stroke-width="5"/>'
        if mood=='zap_b': body += '<path d="M45 65L31 86H46L35 109M209 57L223 78H209L220 101" fill="none" stroke="#ffce49" stroke-width="8"/>'
    elif mood=='idle_blink':
        body += '<path d="M101 85Q111 91 122 84M134 85Q145 91 155 84" fill="none" stroke-width="5"/><path d="M115 109Q127 104 141 111" fill="none" stroke-width="4"/>'
    elif mood=='anticipation':
        body += '<path d="M101 81L120 89L102 94M154 81L136 89L154 94" fill="none" stroke-width="5"/><rect x="111" y="106" width="33" height="13" rx="4" fill="#f1eee1"/><path d="M120 108V116M133 108V116" stroke-width="3"/>'
    else:
        body += '<ellipse cx="111" cy="84" rx="12" ry="15" fill="#fff8e9"/><ellipse cx="145" cy="84" rx="12" ry="15" fill="#fff8e9"/>'
        body += '<ellipse cx="'+('108' if mood=='lose' else '115')+'" cy="86" rx="5" ry="7" fill="#09141e"/><ellipse cx="'+('141' if mood=='lose' else '149')+'" cy="86" rx="5" ry="7" fill="#09141e"/>'
        body += '<path d="M99 65L120 71M135 71L157 64" fill="none" stroke-width="5"/>'
        if mood in ('win','recover'):
            body += '<path d="M110 105Q128 121 147 104L141 121Q124 129 112 117Z" fill="#fff8e9"/>'
        elif mood in ('worried','lose'):
            body += '<path d="M112 114Q123 102 143 112" fill="none" stroke-width="4"/><path d="M175 72Q183 84 176 88Q169 88 175 72Z" fill="#6ce1c4" stroke-width="3"/>'
        else: body += '<path d="M116 109Q130 102 143 113" fill="none" stroke-width="4"/>'
    body += '</g>'
    if mood in ('recover','win'):
        body += '<g fill="none" stroke="#94adb8" stroke-width="5" stroke-linecap="round" opacity="0.6"><path d="M66 77Q48 64 59 51Q70 40 61 26"/><path d="M194 79Q211 68 200 55Q188 43 202 28"/></g>'
    return svg(body)

def chair(active):
    glow='#6ce1c4' if active else '#63818e'
    return svg(f'''<defs><linearGradient id="metal" x2="1" y2="1"><stop stop-color="#56717e"/><stop offset="1" stop-color="#253b49"/></linearGradient></defs>
    <g stroke="{INK}" stroke-width="6" stroke-linejoin="round"><ellipse cx="128" cy="239" rx="105" ry="10" fill="#09141e" opacity="0.5"/>
    <path d="M77 179L68 234H90L105 183M153 183L166 234H188L179 179" fill="#344c5a"/>
    <rect x="70" y="52" width="116" height="140" rx="19" fill="url(#metal)"/><rect x="83" y="67" width="90" height="104" rx="10" fill="#1e3343"/>
    <path d="M77 54V28H58V88M179 54V28H198V88" fill="none" stroke="#82999e" stroke-width="10"/>
    <path d="M46 45H70M46 59H70M186 45H210M186 59H210" stroke="{glow}" stroke-width="8"/>
    <path d="M57 149V179H198V150" fill="#627c88"/><path d="M74 193H184" stroke="#82999e" stroke-width="10"/>
    <rect x="44" y="137" width="36" height="23" rx="5" fill="#344c5a"/><rect x="176" y="137" width="36" height="23" rx="5" fill="#344c5a"/>
    <circle cx="61" cy="148" r="5" fill="#fa8e74"/><circle cx="194" cy="148" r="5" fill="{glow}"/>
    <circle cx="82" cy="62" r="4" fill="#c4d1cd"/><circle cx="174" cy="62" r="4" fill="#c4d1cd"/>
    </g>''')

def wire(kind,live):
    paths={'straight':'M128 0V256','curve':'M128 0V128H256','tee':'M0 128H256M128 128V0'}
    path=paths[kind]; color='#ffce49' if live else '#8fa5ae';inner='#fff0a1' if live else '#c1cfd0'
    return svg(f'<g fill="none" stroke-linecap="butt" stroke-linejoin="round"><path d="{path}" stroke="#09141e" stroke-width="62"/><path d="{path}" stroke="'+('#a87931' if live else '#405c68')+f'" stroke-width="48"/><path d="{path}" stroke="{color}" stroke-width="29"/><path d="{path}" stroke="{inner}" stroke-width="7"/></g><circle cx="128" cy="128" r="23" fill="#09141e"/><circle cx="128" cy="128" r="15" fill="{color}"/><path d="M121 128H135" stroke="{inner}" stroke-width="5"/>')

def resource():
    character_names=['idle','idle_blink','worried','anticipation','zap_a','zap_b','recover','win','lose']
    files=['character_'+n for n in character_names]+['chair_idle','chair_active']+[k+s for k in ['straight','curve','tee'] for s in ['', '_live']]+['blocker']
    ids={name:str(i+2) for i,name in enumerate(files)}
    clips={'idle':(['character_idle','character_idle_blink'],[9.0,1.0],2.0,True), 'worried':(['character_worried'],[1.0],1.0,True),
           'anticipation':(['character_anticipation'],[1.0],6.0,False),'zap':(['character_zap_a','character_zap_b'],[1.0,1.0],10.0,True),
           'zap_soft':(['character_anticipation'],[1.0],1.0,False),'recover':(['character_recover'],[1.0],2.0,False),
           'win':(['character_win'],[1.0],1.0,False),'lose':(['character_lose'],[1.0],1.0,False)}
    def anim(name,images,durations,speed,loop):
        frames=', '.join('{"duration": '+str(d)+', "texture": ExtResource("'+ids[image]+'")} 'for image,d in zip(images,durations))
        return '{"frames": ['+frames+'], "loop": '+str(loop).lower()+', "name": &"'+name+'", "speed": '+str(speed)+'}'
    lines=[f'[gd_resource type="Resource" script_class="" load_steps={len(files)+4} format=3]', '', '[ext_resource type="Script" path="res://scripts/art_pack.gd" id="1"]']
    lines += [f'[ext_resource type="Texture2D" path="res://assets/art/starter/{name}.svg" id="{ids[name]}"]' for name in files]
    lines+=['','[sub_resource type="SpriteFrames" id="CharacterFrames"]','animations = ['+',\n'.join(anim(name,*clip) for name,clip in clips.items())+']']
    chair_clips=[]
    for name in clips:
        images=['chair_active']if name in ('anticipation','zap_soft')else ['chair_active','chair_idle']if name=='zap'else ['chair_idle']
        chair_clips.append(anim(name,images,[1.0]*len(images),10.0 if name=='zap'else 1.0,name=='zap'))
    lines+=['','[sub_resource type="SpriteFrames" id="ChairFrames"]','animations = ['+',\n'.join(chair_clips)+']', '', '[resource]', 'script = ExtResource("1")', 'pack_name = "Cartoon inicial v1"', 'character = SubResource("CharacterFrames")','chair = SubResource("ChairFrames")']
    lines += [f'{name} = ExtResource("{ids[name]}")'for name in files if not name.startswith(('character_','chair_'))]
    return '\n'.join(lines)+'\n'

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--overwrite',action='store_true');args=parser.parse_args()
    assets={f'character_{mood}.svg':character(mood)for mood in ['idle','idle_blink','worried','anticipation','zap_a','zap_b','recover','win','lose']}
    assets.update({'chair_idle.svg':chair(False),'chair_active.svg':chair(True)})
    assets.update({kind+('_live'if live else '')+'.svg':wire(kind,live)for kind in ['straight','curve','tee']for live in [False,True]})
    assets['blocker.svg']=svg('<g stroke="#09141e" stroke-width="8"><rect x="64" y="80" width="128" height="96" rx="15" fill="#253a47"/><path d="M45 88V168M211 88V168" stroke="#82999e" stroke-width="16"/><path d="M99 101L157 155M99 155L157 101" stroke="#fa8e74" stroke-width="15" stroke-linecap="round"/></g>')
    files={ART/name:content for name,content in assets.items()};files[ART.parent/'default_art.tres']=resource()
    if not args.overwrite and any(path.exists()for path in files):parser.error('Arte já existe; use --overwrite somente para reconstruir os sprites iniciais.')
    ART.mkdir(parents=True,exist_ok=True)
    for path,content in files.items():path.write_text(content,encoding='utf-8')
    print(f'{len(assets)} sprites SVG e default_art.tres gravados.')

if __name__=='__main__':main()
