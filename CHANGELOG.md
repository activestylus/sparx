# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.6] - 2025-10-01

### Added
- Fixed bug for root links ie: [link]/

## [0.1.5] - 2025-09-20

### Added
- Definition lists (`:term: description` syntax)
- Details/summary tags (`+[summary]{ content }` syntax)

## [0.1.4] - 2025-08-05

### Added
- Responsive images with `src[]` elements
- Picture element support with media queries
- Format switching with brace expansion (`image.{webp,jpg}`)
- Srcset support with width descriptors

## [0.1.3] - 2025-07-29

### Added
- Basic image support (`i[alt]src.jpg` syntax)
- Image dimensions (`=WxH` suffix)
- Image titles/tooltips (`i[alt|title]src.jpg`)
- URL prefixes for images (`@prefix` references)

## [0.1.2] - 2025-07-03

### Added
- Container support (`$[id]{ content }`, `.{class}{ content }`)
- Block elements (`>{ content }`, `~{ content }`)
- Complex list items with block content
- Nested container processing

## [0.1.1] - 2025-06-30

### Added
- Basic formatting (`*[bold]`, `/[italic]`, `-[deleted]`)
- Link support with formatting prefixes
- Inline code blocks (`` `code` ``)
- Code blocks with syntax highlighting (``` ```language ```)
- Basic text parsing foundation

## [0.1.0] - 2025-06-12

### Added
- Initial gem structure
- Basic parser framework
- Project setup and documentation