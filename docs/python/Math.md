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
To list the functions (or any attributes) of a module in Python after importing it, you can use the built-in **`dir()`** function. This function returns a list of all attributes of the module, including functions, classes, and variables.

Here’s how you can do it:

### Example

```python
import math  # Example module

# List all attributes (functions, variables, etc.) of the math module
print(dir(math))
print(getattr(math, 'sqrt'))
print(getattr(math, 'pi'))
print(inspect.isfunction(getattr(math, 'sqrt')))
```

---

### Filtering for Functions
To filter only the functions from the module, you can use the **`inspect`** module to check if each attribute is a callable function.

```python
import math
import inspect

# List only the functions in the math module
functions = [func for func in dir(math) if inspect.isfunction(getattr(math, func))]
print(functions)
```

---

### Explanation:
1. **`dir(module)`**:
   - Lists all the attributes of the module, including functions, classes, variables, and private/internal attributes.

2. **`getattr(module, attr)`**:
   - Retrieves the actual attribute from the module, which allows you to check its type.

3. **`inspect.isfunction()`**:
   - Verifies if the attribute is a function.

---

### Output Example (Using the `math` Module)
For the `math` module, the output might look like this:

```python
['acos', 'acosh', 'asin', 'asinh', 'atan', 'atan2', 'atanh', 'ceil', 'copysign',
 'cos', 'cosh', 'degrees', 'erf', 'erfc', 'exp', 'expm1', 'fabs', 'factorial',
 'floor', 'fmod', 'frexp', 'fsum', 'gamma', 'gcd', 'hypot', 'isclose',
 'isfinite', 'isinf', 'isnan', 'ldexp', 'lgamma', 'log', 'log10', 'log1p',
 'log2', 'modf', 'pow', 'radians', 'remainder', 'sin', 'sinh', 'sqrt', 'tan',
 'tanh', 'trunc']
```

This approach helps you efficiently list and filter the functions of any imported module.
