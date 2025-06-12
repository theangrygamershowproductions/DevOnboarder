---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation

# Displaying All Built-in Exceptions in Python

This guide explains how to list all built-in exception errors in Python. Python provides a `builtins` module where all built-in objects, including exceptions, are stored. By filtering for objects that are subclasses of `BaseException`, you can list only the exception errors.

## Code Example

Use the following code to display all built-in exception errors:

```python
import builtins

# Filter items in builtins to include only exceptions
exceptions = [item for item in dir(builtins) if isinstance(getattr(builtins, item), type) and issubclass(getattr(builtins, item), BaseException)]
print(exceptions)
```

### Output

The code will produce a list of all built-in exceptions, such as:

```plaintext
['ArithmeticError', 'AssertionError', 'AttributeError', 'BaseException', 'BufferError', 'EOFError', 'Exception', 
'FloatingPointError', 'GeneratorExit', 'ImportError', 'IndexError', 'KeyError', 'KeyboardInterrupt', 'LookupError', 
'MemoryError', 'ModuleNotFoundError', 'NameError', 'NotImplementedError', 'OSError', 'OverflowError', 'RecursionError', 
'ReferenceError', 'RuntimeError', 'StopIteration', 'SyntaxError', 'SystemError', 'SystemExit', 'TabError', 'TimeoutError', 
'TypeError', 'UnboundLocalError', 'UnicodeDecodeError', 'UnicodeEncodeError', 'UnicodeError', 'UnicodeTranslateError', 
'ValueError', 'ZeroDivisionError']
```

## Neatly Formatted Output

To print each exception on a new line, use this code:

```python
import builtins

# Filter items in builtins to include only exceptions
exceptions = [item for item in dir(builtins) if isinstance(getattr(builtins, item), type) and issubclass(getattr(builtins, item), BaseException)]

# Print each exception
for exception in exceptions:
    print(exception)
```

### Example Output

```plaintext
ArithmeticError
AssertionError
AttributeError
BaseException
BufferError
EOFError
...
```

## Notes

- This method uses the fact that all exceptions are subclasses of `BaseException`.
- The `dir()` function lists all attributes and objects within a module, which we filter to identify exceptions.

Feel free to use this script to better understand Python's exception hierarchy.
