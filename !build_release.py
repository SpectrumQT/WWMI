# Assembles source files into release build, just run it and grab freshly built .zip from \!RELEASE\X.X.X

import os
import shutil
import re
import time

from pathlib import Path
from dataclasses import dataclass, field
from datetime import datetime


class Version:
    def __init__(self, wwmi_ini_path):
        self.wwmi_ini_path = wwmi_ini_path
        self.version = None
        self.parse_version()

    def parse_version(self):
        with open(self.wwmi_ini_path, "r") as f:

            version_pattern = re.compile(r'^global \$wwmi_version = (\d+)\.*(\d)(\d*)')

            for line in f.readlines():

                result = version_pattern.findall(line)

                if len(result) != 1:
                    continue

                result = list(result[0])

                if len(result) == 2:
                    result.append(0)

                if len(result) != 3:
                    raise ValueError(f'Malformed WWMI version!')

                self.version = result

                return

        raise ValueError(f'Failed to locate WWMI version!')

    def __str__(self) -> str:
        return f'{self.version[0]}.{self.version[1]}.{self.version[2]}'

    def as_float(self):
        return float(f'{self.version[0]}.{self.version[1]}{self.version[2]}')

    def as_ints(self):
        return [map(int, self.version)]


class Project:
    def __init__(self):
        self.root_dir = Path().resolve()
        self.trash_path = self.root_dir / '!TRASH'
        self.distr_dir = self.root_dir / 'WWMI'
        self.core_dir = self.distr_dir / 'Core'
        self.wwmi_dir = self.core_dir / 'WWMI'
        self.wwmi_ini_path = self.wwmi_dir / 'WuWa-Model-Importer.ini'
        self.wwmi_readme_path = self.root_dir / 'README.md'
        self.release_dir = self.root_dir / '!RELEASES'
        self.version = Version(self.wwmi_ini_path)
        self.version_dir = self.release_dir / str(self.version)

    def trash(self, target_path: Path):
        trashed_path = self.trash_path / target_path.name
        if trashed_path.is_dir():
            timestamp = datetime.now().strftime('%Y-%m-%d %H-%M-%S')
            trashed_path = trashed_path.with_name(f'{trashed_path.name} {timestamp}')
        shutil.move(target_path, trashed_path)

    def build(self):
        if self.version_dir.is_dir():
            remove_ok = input(f'Directory {self.version_dir} already exists! Overwrite? (y/n)')
            if remove_ok != 'y':
                print('Version building aborted!')
                return
            else:
                self.trash(self.version_dir)
                print(f'Existing directory sent to {self.trash_path}!')

        release_path = self.version_dir / 'WWMI'

        if self.distr_dir.is_dir():
            shutil.copytree(self.distr_dir, release_path)

        if self.wwmi_readme_path.is_file():
            shutil.copy2(self.wwmi_readme_path, release_path / 'README.md')

        if release_path.is_dir():
            shutil.make_archive(str(self.version_dir / f'{release_path.name}-v{self.version}'), 'zip', self.version_dir, release_path.name)


if __name__ == '__main__':
    try:
        project = Project()
        project.build()
    except Exception as e:
        print(f'Error:', e)
        input(f'Press eny key to exit')
