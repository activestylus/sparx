# Sparx - Markup That Sparks Joy ⚡

**Markdown was revolutionary in 2004. It's 2025. Time for the next evolution.**

Born from the same "spark joy" philosophy as the **[Joys](https://github.com/activestylus/joys)** view engine, Sparx eliminates the daily frustrations that make developers want to scream at their markup. Clean syntax. Semantic HTML. Zero compromise.

---

## ⚡ Why Sparx Exists

### The Problem With Markdown

After 20 years, we're still fighting the same battles:

- `**bold**` vs `__bold__` vs `*italic*` confusion
- Broken nesting: `[link with **bold**](url)` → broken markup
- HTML soup whenever you need anything semantic
- Copy-pasting URLs everywhere like it's 1999
- Zero support for modern responsive images
- Tables that require ASCII art skills
- Academic citations? Good luck.

**Sparx solves every single one of these problems.**

### Quick Taste: Before & After

**Markdown:**
```markdown
**Bold** and *italic* with [broken **nesting**](https://example.com).

![Image](https://cdn.example.com/very/long/path/image.jpg)

<details>
<summary>Advanced Content</summary>
More HTML soup when you need structure.
</details>
```

**Sparx:**
```markdown
*[Bold] and /[italic] with perfect */[nesting]https://example.com.

i[Image]@cdn/image.jpg

+[Advanced Content]{
  Clean structure without HTML soup.
}

@cdn: https://cdn.example.com/very/long/path/
```

```html
<strong>Bold</strong> and <em>italic</em> with <strong><em><a href="https://example.com">nesting</a></em></strong>.

<img src="https://cdn.example.com/very/long/path/image.jpg" alt="Image">

<details>
<summary>Advanced Content</summary>
<p>Clean structure without HTML soup.</p>
</details>
```

**Same result. 17% fewer characters. Semantic HTML throughout. URLs defined once.**

---

## 🎯 Quick Reference

### Text Formatting
```markdown
*[bold] /[italic] -[strikethrough] `code`
s[small text] .highlight[styled span]
*/[bold italic] -[strikethrough *[with bold]]  # Perfect nesting!
```

### Links (So Much Better!)
```markdown
[Simple link]https://example.com
[Link with title|Hover text]https://example.com
[External link]https://example.com^
*/[Bold italic link]https://example.com        # Formatted links!
[Call us]tel:+1-555-0123                       # Protocol links
```

### Media & Code
```markdown
i[Alt text]image.jpg
i[Alt|Title]image.jpg=300x200

```ruby
def hello = "Multiline Code"
```

`One line of code`
```

### Containers & Structure
```markdown
$[section-id]{ content }                       # Sections
.[class-name]{ content }                       # Divs
>{ content }                                   # Blockquotes  
+[Summary]{ content }                          # Details/Summary
:term: definition                              # Definition lists
```

### References
```markdown
[Link text]@reference                          # URL references
[Citation]:1                                   # Numbered citations
@reference: https://example.com "Title"        # Define once
1[Source]https://example.com "Description"     # Citation definition
```

---

## 🚀 Installation & Usage

### Standalone

```ruby
gem install sparx
require 'sparx'

html = Sparx.parse(your_content)
# Use safe mode for user-generated content:
html = Sparx.parse(user_content, safe: true)
```

### With Joys Framework
```ruby
gem install sparx

Joys::Config.markup_parser = ->(content) { 
  Sparx.parse(content, safe: true)
}

# In your template:
div? "This is *[awesome]!"
# Adding ? to any DOM method enables automatic parsing!
```

**Love Ruby templates?** You're in for a treat! **[Joys](https://github.com/activestylus/joys)** is the view engine that renders 100x faster than ERB and makes building UI components an absolute joy.

### Command Line
```bash
sparx convert document.sparx
sparx convert document.sparx --safe
sparx convert input.sparx output.html
```

**File extensions:** `.sparx` or `.sx`

---

## 📝 Core Syntax Deep Dive

### Text Formatting That Makes Sense
Every formatting element follows the same pattern: `symbol[content]`. No exceptions. No edge cases.

```markdown
*[bold text]
/[italic text]  
-[strikethrough text]
s[small text]
.[class-name][styled text]
`inline code`
```

```html
<strong>bold text</strong>
<em>italic text</em>  
<del>strikethrough text</del>
<small>small text</small>
<span class="class-name">styled text</span>
<code>inline code</code>
```

### The Magic of Perfect Nesting
```markdown
*/[bold italic] -[strikethrough *[with bold]]
```

```html
<strong><em>bold italic</em></strong> <del><strong>with bold</strong></del>
```

No more broken `[link with **bold**](url)` - it just works!

### Links That Don't Break Your Flow
```markdown
[Simple link]https://example.com
[Link with title|Hover text]https://example.com
[External link]https://example.com^
[Custom target]https://example.com^myframe
*/[Bold italic link]https://example.com
```

```html
<a href="https://example.com">Simple link</a>
<a href="https://example.com" title="Hover text">Link with title</a>
<a href="https://example.com" target="_blank">External link</a>
<a href="https://example.com" target="myframe">Custom target</a>
<strong><em><a href="https://example.com">Bold italic link</a></em></strong>
```

### Protocol Links Built-In
```markdown
[Call us]tel:+1-555-0123
[Email team]mailto:dev@example.com
[Text us]sms:+1-555-0123
[Location]geo:40.7128,-74.0060
[Open in VS Code]vscode://file/path
```

**Supported protocols:** `tel:`, `mailto:`, `sms:`, `facetime:`, `skype:`, `whatsapp:`, `zoom:`, `spotify:`, `vscode:`, `geo:`

### URL References (DRY Principle)
Define once, use everywhere:

```markdown
[Documentation]@docs and [API Reference]@docs/api

@docs: https://sparkdown.dev/docs "Complete Documentation"
```

```html
<a href="https://sparkdown.dev/docs" title="Complete Documentation">Documentation</a> and <a href="https://sparkdown.dev/docs/api">API Reference</a>
```

Change your domain? Update one line. It's that simple.

---

## 🏗️ Building Blocks

### Sections with Automatic IDs
```markdown
$[introduction]{
  # Welcome to Sparx
  
  This content is in a semantic section.
}

[Jump to intro]#introduction
```

```html
<section id="introduction">
  <h1>Welcome to Sparx</h1>
  <p>This content is in a semantic section.</p>
</section>
<a href="#introduction">Jump to intro</a>
```

### Blockquotes with Citations
```markdown
>{
  This is a simple blockquote.
}

>[https://source.com]{
  This blockquote has a semantic citation.
}
```

```html
<blockquote>
  <p>This is a simple blockquote.</p>
</blockquote>

<blockquote cite="https://source.com">
  <p>This blockquote has a semantic citation.</p>
</blockquote>
```

### Styled Divs
```markdown
.highlight{
  This content is in a highlighted div.
}

.warning[This is a short warning]
```

```html
<div class="highlight">
  <p>This content is in a highlighted div.</p>
</div>

<div class="warning">This is a short warning</div>
```

### Semantic Asides
```markdown
~{
  This is aside content, properly marked up for screen readers.
}
```

```html
<aside>
  <p>This is aside content, properly marked up for screen readers.</p>
</aside>
```

---

## 📚 Advanced Content Structures

### Lists That Actually Work

**Simple Lists:**
```markdown
- Item one
- Item two
- Item three

+ First item  
+ Second item
+ Third item
```

**Complex List Items:**
```markdown
- Simple item
-{
  ## Complex item with full power
  
  Complete *[markup support], [links]@docs, and more.
  
  >{
    Even blockquotes work perfectly inside lists.
  }
}
- Back to simple
```

```html
<ul>
  <li>Simple item</li>
  <li>
    <h2>Complex item with full power</h2>
    <p>Complete <strong>markup support</strong>, <a href="https://sparkdown.dev/docs">links</a>, and more.</p>
    <blockquote>
      <p>Even blockquotes work perfectly inside lists.</p>
    </blockquote>
  </li>
  <li>Back to simple</li>
</ul>
```

### Definition Lists
```markdown
:HTML: HyperText Markup Language
:CSS: Cascading Style Sheets
:JavaScript:{
  A programming language for interactive web content.
  
  Used by *[billions] of websites worldwide.
}
```

```html
<dl>
  <dt>HTML</dt>
  <dd>HyperText Markup Language</dd>
  <dt>CSS</dt>
  <dd>Cascading Style Sheets</dd>
  <dt>JavaScript</dt>
  <dd>
    <p>A programming language for interactive web content.</p>
    <p>Used by <strong>billions</strong> of websites worldwide.</p>
  </dd>
</dl>
```

### Details/Summary
```markdown
+[Click to expand]{
  This content is hidden by default.
  
  - List items work
  - *[Formatting] works
  - [Links]https://example.com work
}
```

```html
<details>
  <summary>Click to expand</summary>
  <p>This content is hidden by default.</p>
  <ul>
    <li>List items work</li>
    <li><strong>Formatting</strong> works</li>
    <li><a href="https://example.com">Links</a> work</li>
  </ul>
</details>
```

### Figures with Captions
```markdown
f[Figure 1: Architecture Diagram]{
  i[System components]diagram.png
  
  The diagram shows our microservices architecture
  and how they communicate via REST APIs.
}
```

```html
<figure>
  <img src="diagram.png" alt="System components">
  <p>The diagram shows our microservices architecture and how they communicate via REST APIs.</p>
  <figcaption>Figure 1: Architecture Diagram</figcaption>
</figure>
```

---

## 🖼️ Responsive Images Made Simple

### Basic Responsive Images
```markdown
i[Hero]hero.jpg 400w|hero@2x.jpg 800w|hero@3x.jpg 1200w
```

```html
<img src="hero.jpg" 
     srcset="hero.jpg 400w, hero@2x.jpg 800w, hero@3x.jpg 1200w" 
     alt="Hero">
```

### Art Direction
```markdown
src[>1024px]desktop.jpg
src[>768px]tablet.jpg
i[Hero]mobile.jpg
```

```html
<picture>
  <source srcset="desktop.jpg" media="(min-width: 1024px)">
  <source srcset="tablet.jpg" media="(min-width: 768px)">
  <img src="mobile.jpg" alt="Hero">
</picture>
```

### Format Switching
```markdown
src[>800px]image.{webp,jpg}
i[Fallback]image.jpg
```

```html
<picture>
  <source srcset="image.webp" type="image/webp" media="(min-width: 800px)">
  <source srcset="image.jpg" type="image/jpeg" media="(min-width: 800px)">
  <img src="image.jpg" alt="Fallback">
</picture>
```

---

## 📚 Academic Features

### Citations
```markdown
Research indicates[performance improvements]:1 in modern systems.

1[Important Study]https://journal.com/study "Peer-reviewed research"
```

```html
<p>Research indicates<a href="#cite-1">performance improvements<sup>1</sup></a> in modern systems.</p>

<section class="citations">
  <cite id="cite-1"><span class="cite-number">1</span> <a href="https://journal.com/study" title="Peer-reviewed research">Important Study</a></cite>
</section>
```

---

## 🛡️ Security

```ruby
# Safe mode for user-generated content
html = Sparx.parse(user_content, safe: true)
```

**Safe mode automatically:**
- Escapes HTML tags (`<script>` → `&lt;script&gt;`)
- Blocks dangerous protocols (`javascript:`, `data:`, `vbscript:`)
- Sanitizes attribute values
- Preserves code blocks exactly as written

---

## ⚡ Performance

Sparx balances speed with advanced functionality. While pure Markdown parsers prioritize raw throughput, Sparx generates semantic HTML5 with features impossible in traditional markup languages.

### Benchmark Results

*Tested on Ruby 3.3.5 (arm64-darwin23) across three document types*

#### Blog Post (746 characters)

| Parser | Speed (ops/sec) | Relative | Memory |
|--------|-----------------|----------|--------|
| Redcarpet | 257,851 | **1.0x** | <1 KB |
| **Sparx** | **4,576** | **56x slower** | **64 KB** |
| Kramdown | 2,207 | 117x slower | 3,520 KB |
| CommonMarker | 478 | 539x slower | 2,608 KB |

#### Technical Documentation (2,367 characters)

| Parser | Speed (ops/sec) | Relative | Memory |
|--------|-----------------|----------|--------|
| Redcarpet | 79,432 | **1.0x** | <1 KB|
| **Sparx** | **1,450** | **55x slower** | **<1 KB** |
| Kramdown | 840 | 95x slower | <1 KB |
| CommonMarker | 147 | 541x slower | 384 KB |

#### Novel Chapter (27,465 characters)

| Parser | Speed (ops/sec) | Relative | Memory |
|--------|-----------------|----------|--------|
| Redcarpet | 12,738 | **1.0x** | 48 KB |
| CommonMarker | 898 | 14x slower | 432 KB |
| **Sparx** | **457** | **28x slower** | **16 KB** |
| Kramdown | 290 | 44x slower | 16 KB |

### What These Numbers Mean

#### The Speed Tradeoff
- **Redcarpet wins on pure speed** but only handles basic Markdown
- **Sparx is 2x faster than Kramdown** while delivering dramatically more features
- **Performance scales well** with document size (28x slower vs 56x slower)

### Feature Comparison

| Feature | Redcarpet | Kramdown | CommonMarker | **Sparx** |
|---------|-----------|----------|--------------|---------------|
| Basic Markdown | ✅ | ✅ | ✅ | ✅ |
| Semantic HTML5 | ❌ | Limited | ❌ | **✅** |
| URL References | ❌ | ❌ | ❌ | **✅** |
| Responsive Images | ❌ | ❌ | ❌ | **✅** |
| Citations | ❌ | ❌ | ❌ | **✅** |
| Complex Containers | ❌ | Limited | ❌ | **✅** |
| Definition Lists | ❌ | ✅ | ❌ | **✅** |
| Perfect Nesting | ❌ | ❌ | ❌ | **✅** |


---

## 🎯 When to Use Sparx

**Perfect for:**
- Technical documentation requiring semantic structure
- Content sites where HTML5 semantics matter
- Academic writing with proper citations
- Any project where Markdown feels limiting
- Teams tired of mixed HTML/Markdown soup

**Stick with Markdown when:**
- Writing simple blog posts without complex structure
- Your toolchain is deeply invested in Markdown  
- Your team values familiarity over power

---

## 🎊 The Bottom Line

Markdown taught us that writing shouldn't require thinking about HTML. Sparx teaches us that **developers** shouldn't need to compromise on semantic markup quality.

It's 2025. Your markup language should be as sophisticated as your code.

**Does your current markup spark joy?**

```ruby
gem install sparx
```

---

*Sparx is part of the [Joys](https://github.com/activestylus/joys) ecosystem - Ruby tools that spark joy for developers.*