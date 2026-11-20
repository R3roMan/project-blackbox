#!/usr/bin/env python3
"""Install only Blackbox-owned user packages, with a reversible manifest."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
from datetime import datetime, timezone

SOURCE=Path(__file__).resolve().parent
ROOT=SOURCE.parent
CUBE_EFFECT='kwin/effects/org.projectblackbox.cube'
PACKAGES={
    'project-blackbox':None,
    'plasma/wallpapers/org.projectblackbox.wallpaper':'wallpaper',
    'plasma/plasmoids/org.projectblackbox.controls':'applet',
    'kwin/scripts/org.projectblackbox.visibility':'visibility',
    CUBE_EFFECT:'effect',
    'plasma/desktoptheme/org.projectblackbox.blood':'theme',
}
def copy(src,dst):
    shutil.copytree(src,dst,dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__','*.pyc','tests'))
def hashes(path):
    return {str(p.relative_to(path)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(path.rglob('*')) if p.is_file()}
def stage(destination):
    subprocess.run(['cmake','-S',str(SOURCE/'native'),'-B',str(SOURCE/'build'),'-DCMAKE_BUILD_TYPE=Release'],check=True)
    subprocess.run(['cmake','--build',str(SOURCE/'build'),'-j2'],check=True)
    qsb=shutil.which('qsb') or '/usr/lib/qt6/bin/qsb'
    for folder in [ROOT/'Demo/shaders',ROOT/'Demo/game/shaders']:
        for shader in folder.glob('*.frag'):
            subprocess.run([qsb,'--glsl','100 es,120,150','--hlsl','50','--msl','12','-o',str(shader)+'.qsb',str(shader)],check=True)
    destination.mkdir(parents=True,exist_ok=True)
    for relative,source in PACKAGES.items():
        path=destination/relative
        if path.exists():shutil.rmtree(path)
        if source:copy(SOURCE/source,path)
        else:
            path.mkdir(parents=True)
            for folder in ['Demo','V0.1']:copy(ROOT/folder,path/folder)
            copy(SOURCE/'runtime',path/'runtime')
            copy(SOURCE/'build/native',path/'native')
            shutil.copy2(SOURCE/'native/vendor/libvterm/LICENSE',path/'native/libvterm-LICENSE')
            (path/'build-info.json').write_text(json.dumps({'qt':subprocess.check_output(['pkg-config','--modversion','Qt6Core'],text=True).strip(),'version':'0.4.17','built':datetime.now(timezone.utc).isoformat()},indent=2))
    return destination

def install(data):
    staging=stage(SOURCE/'stage/share')
    stamp=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    history=data/'project-blackbox-installations'/stamp
    history.mkdir(parents=True)
    manifest={'version':1,'dataRoot':str(data),'installed':stamp,'packages':{}}
    latest=data/'project-blackbox-installations/latest'
    manifest['previousManifest']=latest.read_text().strip() if latest.exists() else ''
    # Finish all copying before touching an existing installed package.
    for relative in PACKAGES:
        target=data/relative
        if target.is_symlink() or target.exists() and not target.is_dir():
            raise SystemExit('Refusing to replace a non-directory package path: '+str(target))
        copy(staging/relative,history/'new'/relative)
        manifest['packages'][relative]={'previous':(data/relative).exists(),'hashes':hashes(history/'new'/relative)}
    replaced=[]
    try:
        for relative in PACKAGES:
            target=data/relative
            target.parent.mkdir(parents=True,exist_ok=True)
            previous=history/'previous'/relative
            if target.exists():
                previous.parent.mkdir(parents=True,exist_ok=True)
                target.rename(previous)
            try:
                (history/'new'/relative).rename(target)
            except BaseException:
                if previous.exists():previous.rename(target)
                raise
            replaced.append(relative)
    except BaseException:
        for relative in reversed(replaced):
            target=data/relative
            if target.exists():shutil.rmtree(target)
            previous=history/'previous'/relative
            if previous.exists():previous.rename(target)
        raise
    file=history/'manifest.json';file.write_text(json.dumps(manifest,indent=2))
    (history.parent/'latest').write_text(str(file))
    print('Installed Blackbox user packages. No active wallpaper, theme, panel or KWin configuration was changed.')
    print('Manifest:',file)
    print('Activate in Desktop and Wallpaper settings; add Blackbox Controls to your panel and enable Blackbox desktop visibility in KWin Scripts. Blackbox Cube is optional in Desktop Effects.')

def remove(data):
    latest=data/'project-blackbox-installations/latest'
    if not latest.exists():raise SystemExit('No Blackbox installation manifest found.')
    manifest_path=Path(latest.read_text().strip())
    info=json.loads(manifest_path.read_text())
    manifest_packages=set(info['packages'])
    known_packages=set(PACKAGES)
    if manifest_packages not in (known_packages,known_packages-{CUBE_EFFECT}) or Path(info['dataRoot'])!=data:
        raise SystemExit('Manifest target check failed.')
    history=manifest_path.parent
    for relative,entry in info['packages'].items():
        target=data/relative
        if target.exists():
            if hashes(target)!=entry['hashes']:
                copy(target,history/'changes-after-install'/relative)
                print('Preserved edited package:',history/'changes-after-install'/relative)
            shutil.rmtree(target)
        if entry['previous']:copy(history/'previous'/relative,target)
    previous_manifest=info.get("previousManifest","")
    if previous_manifest and Path(previous_manifest).is_file():latest.write_text(previous_manifest)
    else:latest.unlink()
    print('Removed this Blackbox installation and restored previous Blackbox packages, if any. Saves and backups were kept.')
    print('Select your previous wallpaper/style and remove the panel widget before logging in again. Disable Blackbox Cube in Desktop Effects and Blackbox desktop visibility in KWin Scripts if enabled.')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action',choices=['stage','install','remove'])
    parser.add_argument('--data-root',type=Path,default=Path(os.environ.get('XDG_DATA_HOME',Path.home()/'.local/share')))
    parser.add_argument('--destination',type=Path,default=SOURCE/'stage/share')
    args=parser.parse_args()
    data=args.data_root.expanduser().resolve()
    if args.action=='stage':print('Staged at',stage(args.destination.resolve()))
    elif args.action=='install':install(data)
    else:remove(data)
if __name__=='__main__':main()
