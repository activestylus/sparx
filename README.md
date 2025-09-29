# Sparx - Markup That Sparks Joy

**Markdown was revolutionary in 2004. It's 2025. Time for the next evolution.**

Born from the same "spark joy" philosophy as the **[Joys](https://github.com/activestylus/joys)** view engine, Sparx eliminates the daily frustrations that developers face, thanks to its clean syntax, semantic HTML and zero compromise on ergonomics and features.

---

## The Problem With Markdown

After 20 years, we're still fighting the same battles:
- `**bold**` vs `__bold__` vs `*italic*` confusion
- Broken nesting in complex formatting
- HTML soup whenever you need anything semantic
- Copying URLs everywhere like it's 1999
- Zero support for modern responsive images
- Academic citations? Good luck.

**Sparx** solves every single one of these problems.

---

## Quick Taste: Before & After

### The Old Way (Markdown)
```markdown
**Bold** and *italic* with [broken **nesting**](https://example.com).

![Image](https://cdn.example.com/very/long/path/image.jpg)

<details>
<summary>Advanced Content</summary>
More HTML soup when you need structure.
</details>
```

### The Sparx Way
```sparx
*[Bold] and /[italic] with perfect */[nesting]https://example.com.

i[Image]@cdn/image.jpg

+[Advanced Content]{
  Clean structure without HTML soup.
}

@cdn: https://cdn.example.com/very/long/path/
```

Same result. Half the characters. Semantic HTML throughout. URLs defined once.

---

## Installation & Usage

### Standalone
```ruby
gem install sparx
require 'sparx'

html = Sparx.parse(your_content)
```

### With Joys Framework
```ruby
gem install sparx

Joys::Config.markup_parser = ->(content) { 
  Sparx.parse(content, safe: true)
}

# In your template:

div? "This is *[awesome]!"

# Adding the ? to any dom method gets you automatic parsing!
```

Note: If you love ruby template engines and haven't heard of **Joys**, then you're in for a treat!

**[Visit Joys on Github](https://github.com/activestylus/joys)**

---

## Core Philosophy: Consistency Over Convention

### Logical, Predictable Formatting

**Input:**
```
*[bold] /[italic] -[deleted] `code`
*/[bold italic] -*[bold deleted] 
```

**Output:**
```html
<strong>bold</strong> <em>italic</em> <del>deleted</del> <code>code</code>
<strong><em>bold italic</em></strong> <del><strong>bold deleted</strong></del>
```

Every formatting element follows the same pattern: `symbol[content]`. No exceptions. No edge cases. Perfect nesting every time.

### Links That Don't Break Your Flow

**Input:**
```
[GitHub]https://github.com
[Docs|Complete documentation]@docs^
[Call us]tel:+1-555-0199

@docs: https://sparx.dev/docs
```

**Output:**
```html
<a href="https://github.com">GitHub</a>
<a href="https://sparx.dev/docs" title="Complete documentation" target="_blank">Docs</a>
<a href="tel:+1-555-0199">Call us</a>
```

Links, tooltips, targets, and protocols all work the same way. Define URLs once with `@references`, use them everywhere.

---

## Where Sparx Shines: Complex Content

### Responsive Images (Finally!)

**Basic responsive images:**
```
i[Hero]hero.jpg 400w|hero@2x.jpg 800w|hero@3x.jpg 1200w
```

**Art direction with format fallbacks:**
```
src[>800px]desktop.{webp,jpg}
src[>400px]tablet.{webp,jpg}
i[Hero]mobile.jpg
```

**Output:**
```html
<picture>
  <source srcset="desktop.webp" type="image/webp" media="(min-width: 800px)">
  <source srcset="desktop.jpg" type="image/jpeg" media="(min-width: 800px)">
  <source srcset="tablet.webp" type="image/webp" media="(min-width: 400px)">
  <source srcset="tablet.jpg" type="image/jpeg" media="(min-width: 400px)">
  <img src="mobile.jpg" alt="Hero">
</picture>
```

One input. Perfect responsive HTML5. Try doing this in Markdown!

### Semantic Containers

You can create linkable sections with very simple syntax:

`$[dom-id] { fully parseable content }`

**Input:**
```
$[hero]{
  # Welcome to */[the future]@site

  >{
    Finally, markup that doesn't make me want to scream.
    - Every developer who tries Sparx
  }

  .warning{
    This will change how you think about markup.
  }

  +[Technical Details]{
    :Performance: 100x faster parsing than traditional regex approaches
    :Output: Clean, semantic HTML5 throughout
    :DRY: URL references eliminate repetition
  }
}

@site: https://sparx.dev
```

**Output:**
```html
<section id="hero">
<h1>Welcome to <strong><em><a href="https://sparx.dev">the future</a></em></strong></h1>
<blockquote>
<p>Finally, markup that doesn't make me want to scream.</p>
<p>- Every developer who tries Sparx</p>
</blockquote>
<div class="warning">
<p>This will change how you think about markup.</p>
</div>
<details>
<summary>Technical Details</summary>
<dl>
<dt>Performance</dt><dd>100x faster parsing than traditional regex approaches</dd>
<dt>Output</dt><dd>Clean, semantic HTML5 throughout</dd>
<dt>DRY</dt><dd>URL references eliminate repetition</dd>
</dl>
</details>
</section>
```

Every element generates proper semantic HTML. Your accessibility audits will love you.

Links to these sections can then be easily created:

`[Go To Hero]#hero`

---

## Real-World Comparison

### Documentation Page: Markdown vs Sparx

**Markdown approach:**
```markdown
## API Authentication

> **Warning:** Never commit tokens to version control.

See our [security guide](https://docs.example.com/security) and 
[API docs](https://docs.example.com/api).

<details>
<summary>Troubleshooting</summary>

**Token Issues:**
- Check for whitespace
- Verify token type

**Expired Tokens:**
- Tokens expire in 30 days
- Generate new ones [here](https://app.example.com/tokens)

</details>

References:
1. [OAuth 2.0](https://tools.ietf.org/html/rfc6749) - Official spec
2. [JWT Guide](https://jwt.io/introduction/) - Token format
```

**Sparx approach:**
```
## API Authentication

>{
  *[Never commit tokens to version control.]
}

See our [security guide]@docs/security and [API docs]@docs/api.

+[Troubleshooting]{
  :Token Issues:{
    - Check for whitespace  
    - Verify token type
  }
  :Expired Tokens:{
    - Tokens expire in 30 days
    - Generate new ones [here]@app/tokens
  }
}

See the [OAuth 2.0 spec]:1 and [JWT guide]:2 for details.

@docs: https://docs.example.com
@app: https://app.example.com

1[OAuth 2.0]https://tools.ietf.org/html/rfc6749 "Official spec"
2[JWT Guide]https://jwt.io/introduction/ "Token format"
```

**Result:** 17% shorter, semantic HTML throughout, DRY URLs, automatic citations.

---

## Advanced Features

### Academic Citations
```
Research shows[significant performance gains]:1 in modern applications.

1[Performance Study]https://journal.example.com "Peer-reviewed research"
```

Automatic numbering, proper linking, and citation sections.

### Complex Lists
```
- Simple item
-{
  ## Complex item with full formatting
  
  Complete *[markup support], [links]@docs, and more.
  
  >{
    Even blockquotes work perfectly inside lists.
  }
}
- Back to simple
```

Try nesting a blockquote inside a Markdown list item. I'll wait.

### Protocol Links
```
[Email us]mailto:hello@example.com
[Call support]tel:+1-555-0199
[Text us]sms:+1-555-0199
[Video chat]facetime:user@example.com
[Open in VS Code]vscode://file/path/to/file
```

Built-in support for `tel:`, `mailto:`, `sms:`, `facetime:`, `skype:`, `whatsapp:`, `zoom:`, `spotify:`, `vscode:`, and `geo:` protocols.

---

## Security: Safe Mode

Processing user-generated content? Sparx's safe mode protects against XSS while preserving all formatting functionality.

```ruby
# Safe mode ON - for user content
html = Sparx.parse(user_content, safe: true)

# Safe mode OFF - for trusted content  
html = Sparx.parse(trusted_content)
```

Automatically escapes HTML tags, blocks dangerous protocols (`javascript:`, `data:`), and sanitizes attributes while preserving code blocks exactly as written.

---
## Performance

Sparx prioritizes developer experience and semantic output over raw speed. While pure Markdown parsers like Redcarpet are faster for basic formatting, Sparx delivers significantly more functionality:

### Performance Benchmarks

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

### Real-World Performance

For typical use cases, Sparx's parsing time is negligible:

- **Blog post** (746 chars): **0.22ms** to parse
- **Documentation** (2.3K chars): **0.69ms** to parse  
- **Long content** (27K chars): **2.19ms** to parse

The development time saved by consistent syntax and semantic output far outweighs the microseconds spent parsing.

## Bottom Line

**Choose based on your needs:**

- **Need raw speed only?** Redcarpet is unbeatable for basic Markdown
- **Need features + reasonable speed?** Sparx delivers 2x better performance than Kramdown with 10x more functionality
- **Building semantic, accessible content?** Sparx is the only option that generates proper HTML5 throughout

*Performance measured in iterations per second. Higher is better. Memory usage measured as RSS delta during parsing.*

Conclusion: For most real-world use cases, the parsing time is negligible compared to the development time saved by cleaner syntax and semantic output.

---

## When to Use Sparx

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

## The Bottom Line

Markdown taught us that writing shouldn't require thinking about HTML. Sparx teaches us that **developers** shouldn't need to compromise on semantic markup quality.

It's 2025. Your markup language should be as sophisticated as your code.

**Does your current markup spark joy?**

```ruby
gem install sparx
```

---

*Sparx is part of the [Joys](https://github.com/activestylus/joys) ecosystem - Ruby tools that spark joy for developers.*