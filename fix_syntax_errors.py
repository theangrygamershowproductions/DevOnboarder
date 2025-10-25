#!/usr/bin/env python3
"""
Comprehensive syntax error fixer for DevOnboarder Python files.
Fixes common syntax errors introduced during development.
"""

import re
import sys
from pathlib import Path

def fix_file(file_path: Path) -> bool:
    """Fix syntax errors in a single file."""
    try:
        content = file_path.read_text(encoding='utf-8')
        original_content = content
        
        # Fix 1: Return type annotations - replace ") -> Type:" with ") -> Type:"
        content = re.sub(r'\)  ([A-Za-z_][A-Za-z0-9_\[\], \|\.]*):', r') -> \1:', content)
        
        # Fix 2: String concatenation - replace " + " with " + " for string operations
        # But be careful not to break f-strings or other valid syntax
        lines = content.split('\n')
        fixed_lines = []
        for line in lines:
            # Skip lines that are inside strings, comments, or f-strings
            if ('"' in line or "'" in line) and ('  ' in line):
                # More careful replacement - only replace spaces between variables/expressions
                # This is tricky, so let's use a more targeted approach
                # Replace "var1 + var2" with "var1 + var2" but avoid breaking other syntax
                line = re.sub(r'([a-zA-Z_][a-zA-Z0-9_]*)\s{2,}([a-zA-Z_][a-zA-Z0-9_]*(?:\([^)]*\))?)', r'\1 + \2', line)
            fixed_lines.append(line)
        content = '\n'.join(fixed_lines)
        
        # Fix 3: Arithmetic operations - replace " + " with " + " in arithmetic contexts
        content = re.sub(r'(\w+)\s{2,}(\d+)', r'\1 + \2', content)
        
        # Fix 4: List concatenation - replace "] + [" with "] + [" for list comprehensions
        content = re.sub(r'(\])\s{2,}(\[)', r'\1 + \2', content)
        
        # Fix 5: Dictionary concatenation - replace "} | {" with "} | {" for dict merging (Python 3.9+)
        content = re.sub(r'(\})\s{2,}(\{)', r'\1 | \2', content)
        
        # Fix 6: Path joining - replace " + os.pathsep + " with " + os.pathsep + "
        content = re.sub(r'\s{2,}os\.pathsep\s{2,}', ' + os.pathsep + ', content)
        
        # Fix 7: String literals concatenation - replace '"str1" + "str2"' with '"str1" + "str2"'
        content = re.sub(r'("[^"]*")\s{2,}("[^"]*")', r'\1 + \2', content)
        
        if content != original_content:
            file_path.write_text(content, encoding='utf-8')
            print(f"Fixed: {file_path}")
            return True
        return False
        
    except Exception as e:
        print(f"Error fixing {file_path}: {e}")
        return False

def main():
    """Main function."""
    if len(sys.argv) < 2:
        print("Usage: python fix_syntax_errors.py <file1> [file2] ...")
        sys.exit(1)
    
    fixed_count = 0
    total_count = 0
    
    for arg in sys.argv[1:]:
        file_path = Path(arg)
        if not file_path.exists():
            print(f"Warning: {file_path} does not exist")
            continue
        
        if file_path.suffix != '.py':
            print(f"Warning: {file_path} is not a Python file")
            continue
        
        total_count += 1
        if fix_file(file_path):
            fixed_count += 1
    
    print(f"Fixed {fixed_count}/{total_count} files")
    return 0 if fixed_count == total_count else 1

if __name__ == "__main__":
    sys.exit(main())
