---

project: "Potato"
module: "Math"
phase: "Reference"
tags: ["C955", "C957", "algorithms", "cheat-sheet"]
version: "v1.0.0"
author: "Chad Reesey"
email: "[education@thenagrygamershow.com](mailto:education@thenagrygamershow.com)"
updated: "27 May 2025 11:41 (EDT)"
description: "Key algorithmic concepts and formulas from C955 (Applied Probability and Statistics) and C957 (Applied Algebra) to support academic mastery and reference."
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# C955 & C957 Algorithm Cheat Sheet

This cheat sheet summarizes the key algorithms and procedural methods required for success in:

* **C955: Applied Probability and Statistics**
* **C957: Applied Algebra**

---

# 🧠 C955 — Applied Probability and Statistics Algorithms

## 1. Measures of Central Tendency

* **Mean**: $\bar{x} = \frac{\sum x}{n}$
* **Median**: Middle value (ordered data)
* **Mode**: Most frequent value
* **Range**: $\text{max} - \text{min}$

### 2. Spread and Distribution

* **Variance**: $\sigma^2 = \frac{\sum (x - \mu)^2}{n}$
* **Standard Deviation**: $\sigma = \sqrt{\text{variance}}$
* **Z-Score**: $z = \frac{x - \mu}{\sigma}$

### 3. Probability Rules

* **Theoretical**: $P(E) = \frac{\text{favorable outcomes}}{\text{total outcomes}}$
* **Empirical**: $P(E) = \frac{\text{observed frequency}}{\text{total trials}}$
* **Independent Events**: $P(A \cap B) = P(A) \cdot P(B)$
* **Dependent Events**: $P(A \cap B) = P(A) \cdot P(B|A)$

### 4. Counting Techniques

* **Permutations**: $P(n, r) = \frac{n!}{(n - r)!}$
* **Combinations**: $C(n, r) = \frac{n!}{r!(n - r)!}$

### 5. Binomial Probability

$$
P(x) = C(n, x) \cdot p^x \cdot (1 - p)^{n - x}
$$

### 6. Regression & Data Modeling

* **Line of Best Fit**: $y = mx + b$
* Analyze residual plots and R² values

---

## 📐 C957 — Applied Algebra Algorithms

### 1. Function Evaluation

* Plug values into $f(x)$, e.g. $f(3) = 2(3) + 1 = 7$

### 2. Rate of Change

* **Slope**: $m = \frac{y_2 - y_1}{x_2 - x_1}$
* **Average Rate**: $\frac{f(b) - f(a)}{b - a}$

### 3. Intercepts

* **Y-intercept**: Set $x = 0$
* **X-intercept**: Set $y = 0$

### 4. Concavity Analysis

* **Concave Up**: Slope increases (U-shaped)
* **Concave Down**: Slope decreases (∩-shaped)

### 5. Maxima and Minima

* **Vertex Formula** for quadratics: $x = -\frac{b}{2a}$
* Analyze symmetry and turning points

### 6. Asymptotes

* **Vertical**: Undefined x-values (denominator = 0)
* **Horizontal**: Limit behavior as $x \to \infty$

### 7. Function Types

| Type        | Behavior           | Example             |
| ----------- | ------------------ | ------------------- |
| Linear      | Constant rate      | $y = mx + b$        |
| Quadratic   | Symmetric curve    | $y = ax^2 + bx + c$ |
| Exponential | Rapid growth/decay | $y = a \cdot b^x$   |

### 8. Regression Modeling

* Use data points to fit equations
* Estimate future values

---

This reference can be used throughout your C955 and C957 studies to refresh key concepts and formulaic procedures.
