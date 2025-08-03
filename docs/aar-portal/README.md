# AAR Portal Documentation

## Overview

The **After Action Review (AAR) Portal** is a web-based interface for discovering, browsing, and analyzing AAR data from the DevOnboarder project. It provides an interactive dashboard built on top of the existing AAR infrastructure.

## Features

### 🔍 **Interactive Browsing**

- Filter AARs by quarter, type, and search terms
- Visual categorization with color-coded types
- Real-time search through AAR content
- Responsive Bootstrap 5 interface

### 📊 **Trend Analysis**

- Quarterly AAR counts and metrics
- Type distribution charts
- Files changed over time visualization
- Average metrics per AAR

### 🔗 **VSCode Integration**

- Direct "Open in VSCode" links for each AAR
- Seamless workflow integration
- Quick access to raw markdown files

### 🚀 **GitHub Pages Deployment**

- Automatic portal regeneration on AAR updates
- Static site hosting via GitHub Pages
- No server maintenance required

## Architecture

```text
AAR Portal System
├── .aar/                           # Source AAR data
├── scripts/generate_aar_portal.py  # Portal generator
├── docs/aar-portal/                # Generated HTML portal
│   ├── index.html                  # Main browse interface
│   ├── trends.html                 # Trends dashboard
│   ├── aar-data.json              # JSON API data
│   └── templates/                  # Jinja2 templates
└── .github/workflows/aar-portal.yml # Auto-generation workflow
```

## Quick Start

### Generate Portal Locally

```bash
# Install dependencies
pip install jinja2

# Generate portal
python scripts/generate_aar_portal.py

# View portal
open docs/aar-portal/index.html
```

### Serve Development Portal

```bash
# Generate and serve on localhost:8080
python scripts/generate_aar_portal.py --serve
```

### Command Line Options

```bash
python scripts/generate_aar_portal.py [OPTIONS]

Options:
  --aar-dir PATH        AAR data directory (default: .aar)
  --output-dir PATH     Portal output directory (default: docs/aar-portal)
  --serve              Start local development server
  --help               Show help message
```

## Portal Structure

### Main Interface (`index.html`)

**Filter Sidebar:**

- Quarter selection dropdown
- AAR type filter (PRs, Issues, Sprints, Incidents, Automation)
- Real-time search box
- Summary statistics

**AAR Grid:**

- Color-coded AAR cards by type
- Metrics badges (files changed, agents updated, action items)
- Label tags for categorization
- VSCode and file view links

**Interactive Features:**

- Live filtering without page reload
- Search through titles and content
- Responsive design for all screen sizes

### Trends Dashboard (`trends.html`)

**Summary Cards:**

- Total AAR count
- Average files per AAR
- Average agents updated per AAR
- Average action items per AAR

**Visualizations:**

- Doughnut chart: AAR distribution by type
- Line chart: Quarterly AAR trends
- Bar chart: Files changed and action items over time

**Technologies:**

- Chart.js for interactive visualizations
- Bootstrap 5 for responsive layout
- JSON data API for chart data

## Integration Points

### AAR Generation Workflow

The portal integrates with the existing AAR generation workflow:

1. **AAR Creation**: AARs are generated using `scripts/generate_aar.sh`
2. **Portal Regeneration**: `.github/workflows/aar-portal.yml` detects AAR changes
3. **Automatic Deployment**: Updated portal is committed and deployed to GitHub Pages
4. **VSCode Links**: Portal provides direct VSCode links for seamless editing

### GitHub Actions Integration

**Triggers:**

- Push to `.aar/**` directory
- Changes to portal generator script
- Daily scheduled regeneration (06:00 UTC)
- Manual workflow dispatch

**Permissions:**

- `contents: write` - Commit portal updates
- `pages: write` - Deploy to GitHub Pages
- `id-token: write` - GitHub Pages authentication

### Data Flow

```text
AAR Markdown Files (.aar/)
    ↓
Python Generator (generate_aar_portal.py)
    ↓
Jinja2 Templates (docs/aar-portal/templates/)
    ↓
Static HTML Portal (docs/aar-portal/)
    ↓
GitHub Pages Deployment
    ↓
Web-based AAR Discovery Interface
```

## Customization

### Adding New Templates

Create new templates in `docs/aar-portal/templates/`:

```python
# In generate_aar_portal.py
new_template = self.jinja_env.get_template("new_template.html")
content = new_template.render(aar_data=aar_data, trends=trends)
```

### Extending Metrics

Add new metrics in the `extract_metrics_from_content()` method:

```python
def extract_metrics_from_content(self, content: str) -> Dict[str, Any]:
    metrics = {
        "existing_metric": extract_existing(content),
        "new_metric": extract_new_metric(content),  # Add here
    }
    return metrics
```

### Custom Styling

Modify the CSS in the base template or add new stylesheets:

```html
<style>
    .custom-style {
        /* Your custom styles */
    }
</style>
```

## Advanced Features

### JSON API

The portal generates `aar-data.json` for programmatic access:

```json
{
  "aar_data": {
    "quarters": {...},
    "total_aars": 42,
    "types": {...},
    "metrics": {...}
  },
  "trends": {
    "quarterly_counts": [...],
    "type_distribution": {...}
  },
  "generated": "2025-01-27T..."
}
```

### VSCode Protocol Links

Direct VSCode integration using `vscode://` protocol:

```html
<a href="vscode://file/{{ aar.absolute_path }}">Open in VSCode</a>
```

### Responsive Design

Bootstrap 5 ensures portal works on all devices:

- Desktop: Full sidebar and grid layout
- Tablet: Collapsible sidebar
- Mobile: Stacked layout with touch-friendly controls

## Maintenance

### Regular Tasks

1. **Monitor Portal Generation**: Check GitHub Actions for successful builds
2. **Review Metrics**: Use trends dashboard to identify patterns
3. **Update Dependencies**: Keep Jinja2 and other dependencies current
4. **Template Updates**: Enhance templates based on user feedback

### Troubleshooting

**Portal Not Generating:**

- Check `.aar/` directory structure
- Verify Jinja2 installation
- Review GitHub Actions logs

**Missing AARs:**

- Ensure AAR files are in correct quarterly structure
- Check file naming conventions
- Verify markdown format compliance

**Styling Issues:**

- Review Bootstrap 5 documentation
- Check responsive design on multiple devices
- Validate HTML/CSS

### Performance Optimization

**Large AAR Collections:**

- Portal generator handles hundreds of AARs efficiently
- Client-side filtering for responsive interaction
- Static generation eliminates server load
- CDN delivery via GitHub Pages

## Security Considerations

**Static Generation:**

- No server-side vulnerabilities
- All data is pre-rendered HTML
- No database or authentication required

**GitHub Pages:**

- Automatic HTTPS via GitHub
- No sensitive data exposure
- Read-only portal access

## Future Enhancements

### Planned Features

1. **Advanced Search**: Full-text search with highlighting
2. **Export Functionality**: PDF/CSV export of AAR data
3. **Collaboration Tools**: Comments and annotations
4. **Integration APIs**: Webhook support for external tools

### Technical Roadmap

1. **Enhanced Visualizations**: More chart types and interactivity
2. **Progressive Web App**: Offline support and mobile optimization
3. **Real-time Updates**: WebSocket integration for live updates
4. **AI Integration**: Automated insights and recommendations

## Contributing

### Development Setup

```bash
# Clone repository
git clone <repository-url>
cd DevOnboarder

# Create feature branch
git checkout -b feat/portal-enhancement

# Install dependencies
pip install jinja2

# Make changes to scripts/generate_aar_portal.py
# Test portal generation
python scripts/generate_aar_portal.py --serve

# Commit and push
git add .
git commit -m "feat: enhance AAR portal with new feature"
git push origin feat/portal-enhancement
```

### Code Standards

- Follow DevOnboarder coding standards
- Add comprehensive docstrings
- Include error handling
- Write responsive HTML/CSS
- Test on multiple browsers

### Testing

```bash
# Test portal generation
python scripts/generate_aar_portal.py

# Test with different AAR structures
python scripts/generate_aar_portal.py --aar-dir test-aars

# Validate HTML output
# Open generated HTML in browser and test all features
```

## Support

For questions, issues, or contributions related to the AAR Portal:

1. **GitHub Issues**: Report bugs or request features
2. **Documentation**: Refer to this README and code comments
3. **DevOnboarder Team**: Contact project maintainers

---

**Generated on:** {{ generation_date }}
**AAR Portal Version:** 1.0.0
**DevOnboarder Integration:** Complete
