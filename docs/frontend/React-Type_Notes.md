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
### 🧩 Project Note: Difference Between ReactNode and ReactElement

#### ✅ ReactNode (Flexible)
Represents anything React can render:
```ts
string | number | boolean | null | undefined | ReactElement | ReactFragment | ReactPortal | Iterable<ReactNode>
```

**Common Use Case:**
- When accepting or rendering children (e.g. `<Component>{children}</Component>`)

**Example:**
```ts
interface Props {
  children: ReactNode;
}
```

```tsx
<MyComponent>
  <div>Hello</div>
  Text is okay too
  {[<A />, <B />]}
</MyComponent>
```

#### 🔒 ReactElement (Strict)
Represents a valid JSX element object returned by calling `React.createElement()` or writing JSX.

**Common Use Case:**
- When expecting a single valid JSX element

**Example:**
```ts
interface Props {
  component: ReactElement;
}
```

```tsx
<MyComponent>
  <div>Only one JSX element</div>
</MyComponent>
```

---

### 🚦 When To Use
| Use Case                                    | Recommended Type |
|--------------------------------------------|------------------|
| General children or layout wrapper         | ReactNode        |
| Strict rendering of one JSX element        | ReactElement     |
| Custom render prop pattern                 | ReactElement     |

---

### ✅ Summary
- **Use `ReactNode`** when you want flexibility.
- **Use `ReactElement`** when you want stricter validation on JSX elements.

---

> 📌 Add this reference if component typing or test stubbing breaks due to mismatched React types.
