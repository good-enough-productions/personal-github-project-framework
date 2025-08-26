# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Setup

1. **Create virtual environment:**
   ```bash
   python -m venv venv
   ```

2. **Activate virtual environment:**
   ```bash
   # Windows
   venv\Scripts\activate
   
   # Linux/Mac
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

## Usage

```bash
python main.py
```

## Project Structure

```
{{PROJECT_NAME}}/
├── main.py              # Main application entry point
├── requirements.txt     # Python dependencies
├── .gitignore          # Git ignore rules
├── README.md           # This file
└── venv/               # Virtual environment (not tracked)
```

## Development

- **Add dependencies:** `pip install package_name` then `pip freeze > requirements.txt`
- **Run tests:** `python -m pytest` (if tests are added)
- **Code formatting:** `black .` (if black is installed)

## Notes

Created on {{DATE}} using Enhanced GitHub Project Creator.

---

*This project was generated from the Python Basic template.*
