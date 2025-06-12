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
# Introduction to Programming in Python - D335  Chad A. Reesey Dec 1 2024

## Table of Contents
1. [Introduction](#introduction)
2. [Setup](#setup)
3. [VS Code Extensions](#vs-code-extensions)
4. [Python Basics](#python-basics)
5. [Control Structures](#control-structures)
6. [Functions](#functions)
7. [Data Structures](#data-structures)
8. [File I/O](#file-io)
9. [Object Oriented Programming](#Object-Oriented-Programming)
10. [Modules](#modules)
11. [Exceptions](#exceptions)
12. [Regular Expressions](#regex)
13. [Unit Testing](#unit-testing)
14. [Debugging](#debugging)
15. [Performance](#performance)
16. [Conclusion](#conclusion)

## Introduction

Python is a high-level, interpreted programming language that is widely used in the software development industry. It is known for its simplicity and readability, making it an excellent choice for beginners and experienced programmers alike. Python is a versatile language that can be used for a wide range of applications, including web development, data analysis, artificial intelligence, and more.

This guide is designed to provide an introduction to programming in Python, covering the basics of the language and its core features. Whether you are new to programming or looking to expand your skills, this guide will help you get started with Python and build a solid foundation for further learning.  

## Setup

To prevent issues with module contamination with system modules, it is recommended to use a virtual environment. Follow these steps to set up a virtual environment:

1. Create a virtual environment:

    ```sh
    python -m venv venv
    ```

2. Activate the virtual environment:

    - On Windows:

        ```sh
        .\venv\Scripts\activate
        ```

    - On macOS and Linux:

        ```sh
        source venv/bin/activate
        ```

3. Install the required packages:

    ```sh
    pip install -r requirements.txt
    ```

By following these steps, you can ensure that your project's dependencies are isolated from the system-wide Python packages, preventing potential conflicts and issues.


## VS Code Extensions

To enhance your development experience in Visual Studio Code, it is recommended to install the following extensions:
For the project-wide configuration, see [VS Code Integrations README](../../.vscode-integrations/README.md).

1. **Python** - Provides rich support for the Python language, including features such as IntelliSense, linting, debugging, and more.
2. **Pylance** - A performant, feature-rich language server for Python in VS Code.
3. **Jupyter** - Provides support for Jupyter Notebooks in VS Code.
4. **GitLens** - Enhances the built-in Git capabilities of VS Code.
5. **Prettier - Code formatter** - An opinionated code formatter that supports many languages.
6. **ESLint** - Integrates ESLint JavaScript into VS Code.

By installing these extensions, you can improve your productivity and make the development process smoother.


## Python Basics

Python is a dynamically typed language, which means that you do not need to declare the type of a variable when you create it. Python uses indentation to define the structure of the code, so it is important to use consistent indentation throughout your program. Here is an example of a simple Python program that prints "Hello, World!":

```python
print("Hello, World!")
```

## Control Structures

Python provides several control structures that allow you to change the flow of your program based on certain conditions. These include if statements, for loops, while loops, and more. Here is an example of an if statement in Python:

    ```python
    x = 10
    if x > 5:
        print("x is greater than 5")
    else:
        print("x is less than or equal to 5")
    ```



## Functions

Functions are blocks of code that perform a specific task and can be reused throughout your program. You can define your own functions in Python using the `def` keyword. Here is an example of a simple function that adds two numbers together:

    ```python
    def add_numbers(x, y):
        return x + y

    result = add_numbers(5, 10)
    print(result) # Output: 15
    ```

## Data Structures

Python provides several built-in data structures, including lists, tuples, sets, and dictionaries. Here is an example of a list in Python:

    ```python
    fruits = ["apple", "banana", "cherry"]
    print(fruits[1]) # Output: banana
    ```
Additional information may be found in the
[Data Structures](docs/DataStructures.md) documentation.

## File I/O

Python allows you to read from and write to files using the built-in `open()` function. Here is an example of reading from a file in Python:

    ```python
    with open("example.txt", "r") as file:
        data = file.read()
        print(data)
    ```

## Object Oriented Programming

Python is an object-oriented programming language, which means that you can create classes and objects to model real-world entities. Here is an example of a simple class in Python:

    ```python
    class Person:
    if x > 5:
        print("x is greater than 5")
    else:
        print("x is less than or equal to 5")
    ```

    ```python
    class Person:
        def __init__(self, name, age):
            self.name = name
            self.age = age

        def greet(self):
            print(f"Hello, my name is {self.name} and I am {self.age} years old.")

    person = Person("Alice", 30)
    person.greet() # Output: Hello, my name is Alice and I am 30 years old.
    ```

    ```python
    fruits = ["apple", "banana", "cherry"]
    print(fruits[1]) # Output: banana
    ```

## Modules  

Python modules are files that contain Python code, which can be imported and used in other Python programs. You can create your own modules or use existing modules from the Python Standard Library or third-party libraries. Here is an example of importing a module in Python:

    ```python
    import math

    print(math.sqrt(16)) # Output: 4.0
    ```

## Exceptions

Exceptions are errors that occur during the execution of a program. Python provides a way to handle exceptions using `try`, `except`, and `finally` blocks. Here is an example of handling an exception in Python:

    ```python
    try:
        x = 1 / 0
    except ZeroDivisionError:
        print("Cannot divide by zero!")
    finally:
        print("This will always execute.")
    ```

Additional Exception information may be found in the [Exceptions](docs/Exceptions.md) documentation.

## Regular Expressions


## Jupyter Notebooks

Jupyter Notebooks are a popular tool for data analysis, visualization, and machine learning in Python. They allow you to create and share documents that contain live code, equations, visualizations, and narrative text. Here is an example of a Jupyter Notebook cell that prints "Hello, World!":

    ```python
    print("Hello, World!")
    ```

    ## Starting Jupyter from the Command Line

    To start Jupyter Notebook from the command line, follow these steps:

    1. Ensure you have Jupyter installed. If not, you can install it using pip:

        ```sh
        pip install jupyter
        ```

    2. Navigate to the directory where you want to save your notebooks.

3. Start Jupyter Notebook by running the following command: (NO BROWSER SUPPORT)

        ```sh
        jupyter notebook --no-browser --ip=0.0.0.0
        ```

    This will open a new tab in your default web browser with the Jupyter Notebook interface. You can now create and manage your notebooks from there.
