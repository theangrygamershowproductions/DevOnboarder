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
### Python Module Imports Tutorial

In this tutorial, we will learn how to separate code into multiple files using Python modules and import them to organize the program better. By doing so, you can keep your code neat, reusable, and easy to maintain. Let's walk through the concepts step by step.

#### 1. Creating a Module

A module in Python is simply a file that contains Python code, such as variables, functions, or classes. Here's how to create a module called `names.py` that stores some information:

**names.py**:
```python
first = 'Larry'
last = 'David'
```

In this example, `names.py` contains two variables, `first` and `last`. These variables will be used in another script to print a greeting.

#### 2. Importing the Module

To use the variables defined in `names.py`, create a new script called `print_name.py`. In this script, you will import `names.py` and use its contents.

**print_name.py**:
```python
import names

print('Hi', end=' ')
print(names.first, end=' ')
print(names.last)
```

Here, the script imports the `names` module and accesses its contents using dot notation (`names.first` and `names.last`). This approach helps keep the code organized and modular.

#### 3. Running the Script

To execute the `print_name.py` script, run the following command in your terminal or command prompt:

```sh
$ python print_name.py
```

The output will be:
```
Hi Larry David
```

### Explanation

- **Dot Notation**: The `import` statement is used to include the `names` module in the script. By using `names.first` and `names.last`, you can access the variables defined in `names.py`.

- **Code Separation**: This approach allows you to separate data (such as names) into different files, making it easier to reuse and maintain.

### Practice Exercise

1. Create a new file named `greetings.py` and define a variable `greeting` with the value "Hello".
2. Update the `print_name.py` script to import `greetings` and use it in the print statement.

**greetings.py**:
```python
greeting = 'Hello'
```

**Updated print_name.py**:
```python
import names
import greetings

print(greetings.greeting, end=' ')
print(names.first, end=' ')
print(names.last)
```

Run the updated script to see the new output:
```
Hello Larry David
```

### Benefits of Using Modules

- **Reusability**: You can use the same module across multiple scripts without rewriting code.

- **Organization**: Code that is broken into smaller, logical files is easier to manage and understand.

- **Maintainability**: Changes can be made to a single module, and those changes will be reflected wherever the module is used.

### Next Steps

To continue learning, try the following:
- Create additional modules with functions and classes, and import them into different scripts.
- Experiment with using `from module import item` to import specific components from a module.

Feel free to reach out if you have any questions or need further guidance!

