"""
Setup script para RSERVER
Compatível com setuptools e pip
"""

from setuptools import setup, find_packages
from pathlib import Path

# Ler README
readme_file = Path(__file__).parent.parent / "README.md"
long_description = readme_file.read_text(encoding="utf-8") if readme_file.exists() else ""

setup(
    name="rserver",
    version="0.0.2",
    description="Remote Server Control - CLI multiplataforma para gerenciar serviços remotos",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="RSERVER Team",
    author_email="team@rserver.dev",
    url="https://github.com/KelvinSilvaDev/rserver",
    license="MIT",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Operating System :: OS Independent",
        "Topic :: System :: Systems Administration",
    ],
    packages=find_packages(where=".", include=["rsctl", "rsctl.*"]),
    package_dir={"": "."},
    package_data={
        "rsctl": ["services.json"],
    },
    python_requires=">=3.7",
    install_requires=[
        # Adicione dependências aqui se necessário
    ],
    entry_points={
        "console_scripts": [
            "rserver=rsctl.cli.commands:main",
        ],
    },
    include_package_data=True,
    zip_safe=False,
)
