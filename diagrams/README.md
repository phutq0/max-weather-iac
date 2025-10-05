### Diagrams as Code

Generate the Max Weather architecture and data flow diagrams using Python and the `diagrams` library.

#### Prerequisites
- Python 3.9+
- Graphviz installed on your system (binary):
  - macOS (brew): `brew install graphviz`
  - Ubuntu/Debian: `sudo apt-get install -y graphviz`
  - Amazon Linux: `sudo yum install -y graphviz`

#### Install Python dependencies
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r diagrams/requirements.txt
```

#### Generate diagrams
```bash
python diagrams/architecture.py
python diagrams/data_flow.py
```

This will produce `architecture.png` and `data_flow.png` in the repo root by default.


