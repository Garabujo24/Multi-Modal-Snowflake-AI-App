# 🚀 Multi-Modal Snowflake AI Demo Generator

**A reusable framework for creating customized Snowflake Cortex demos for any client**

Generate complete, professional Snowflake Cortex demonstrations tailored to specific clients and industries in minutes instead of hours.

## 🎯 What It Does

This tool analyzes any company's website and automatically generates:

- **📱 Custom Streamlit Applications** - Full-featured demo apps with industry-specific branding
- **🗄️ Complete SQL Setup Scripts** - Database schemas, sample data, and views
- **🧠 Semantic Models** - Ready-to-use Cortex Analyst configurations
- **📋 Documentation** - Setup guides and customization instructions

## ✨ Key Features

### 🔍 **Intelligent Industry Detection**
- Analyzes company websites automatically
- Supports 5 major industries (Retail, Financial, Healthcare, Manufacturing, Technology)
- Generates industry-appropriate data and use cases

### 🎨 **Automatic Branding**
- Extracts company information from websites
- Applies industry-specific color schemes and icons
- Creates professional, client-ready interfaces

### 📊 **Complete Demo Coverage**
- **Cortex Analyst**: Natural language business queries
- **Cortex Search**: Document retrieval and knowledge mining
- **AISQL Multimodal**: Text analysis and sentiment processing
- **ML Predictive**: Forecasting and anomaly detection
- **Executive Dashboard**: KPIs and real-time monitoring

### 🚀 **Production Ready**
- Generates 5,000+ realistic transactions
- 500+ customers across multiple segments
- Performance metrics and support tickets
- Industry-specific product catalogs

## 🏃‍♂️ Quick Start

### Prerequisites
- Python 3.8+
- Streamlit
- Internet connection (for website analysis)

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd multi-modal-snowflake-ai-app

# Install dependencies
pip install -r requirements.txt

# Run the application
streamlit run main.py
```

### Usage
1. **Enter Client Information**
   - Company name
   - Website URL
   - Demo purpose

2. **Review Analysis**
   - Verify detected industry
   - Check color scheme and branding
   - Review sample data structure

3. **Generate Resources**
   - Individual components or complete package
   - Download all generated files
   - Follow setup instructions

## 🏭 Supported Industries

| Industry | Icon | Sample Categories | Key Metrics |
|----------|------|-------------------|-------------|
| **Retail & E-commerce** | 🛍️ | Fashion, Electronics, Home | Revenue, Inventory, Customer Satisfaction |
| **Financial Services** | 🏦 | Banking, Investments, Insurance | Assets, Risk, Compliance |
| **Healthcare** | 🏥 | Patient Care, Diagnostics, Pharmacy | Outcomes, Efficiency, Safety |
| **Manufacturing** | 🏭 | Production, Quality, Supply Chain | Output, Downtime, Quality Score |
| **Technology Services** | 💻 | Software, Cloud, Consulting | Usage, Performance, Support |

## 📦 Generated Components

### Streamlit Application
```python
# Complete demo with:
- Executive dashboard with real-time KPIs
- Natural language query interface
- Document search capabilities  
- AI-powered text analysis
- Predictive analytics visualizations
- Alert monitoring system
```

### SQL Infrastructure
```sql
-- Database setup (example)
CREATE DATABASE COMPANY_CORTEX_DEMO;
CREATE SCHEMA ANALYTICS;
CREATE WAREHOUSE COMPANY_WH;

-- Sample tables
- TRANSACTIONS (5,000+ records)
- CUSTOMERS (500+ records)  
- PRODUCTS (industry-specific)
- PERFORMANCE_METRICS
- SUPPORT_TICKETS
```

### Semantic Model
```yaml
# Cortex Analyst configuration
semantic_model:
  name: Company_Analytics
  logical_tables: [...]
  metrics: [...]
  relationships: [...]
  verified_queries: [...]
```

## 🎨 Customization

### Industry Templates
Add new industries by extending the `industry_templates` dictionary:

```python
'new_industry': {
    'name': 'Industry Name',
    'icon': '🏢',
    'primary_color': '#000000',
    'categories': ['Cat1', 'Cat2'],
    'use_cases': ['Use case 1', 'Use case 2']
}
```

### Data Generation
Modify the SQL and data generators to:
- Add new product categories
- Adjust customer segments
- Scale transaction volumes
- Include industry-specific metrics

### UI Customization
Update Streamlit generators for:
- Custom color schemes
- Additional visualizations
- New KPI definitions
- Industry-specific features

## 🔧 Technical Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Website       │    │    Industry      │    │   Component     │
│   Analyzer      ├───►│    Detection     ├───►│   Generators    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Company       │    │   Template       │    │   Generated     │
│   Information   │    │   Selection      │    │   Demo Files    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Core Modules
- `demo_generator.py` - Main Streamlit application and orchestration
- `streamlit_generator.py` - Streamlit app code generation
- `sql_generator.py` - Database schema and data generation
- `semantic_model_generator.py` - Cortex Analyst model creation

## 📊 Sample Outputs

### For Liverpool México (Retail)
```bash
output/
├── liverpool_mexico_cortex_demo.py     # Retail-focused Streamlit app
├── liverpool_cortex_demo_setup.sql     # Database setup
├── liverpool_cortex_demo_tables.sql    # Table definitions
├── liverpool_cortex_demo_sample_data.sql # Sample retail data
├── liverpool_cortex_demo_views.sql     # Analytical views
├── liverpool_mexico_semantic_model.yaml # Cortex Analyst model
└── README_Liverpool_Mexico.md          # Setup instructions
```

### For BBVA (Financial)
```bash
output/
├── bbva_cortex_demo.py                  # Banking-focused Streamlit app
├── bbva_cortex_demo_setup.sql          # Database setup
├── bbva_cortex_demo_tables.sql         # Financial tables
├── bbva_cortex_demo_sample_data.sql    # Banking transaction data
├── bbva_cortex_demo_views.sql          # Financial analytics views
├── bbva_semantic_model.yaml            # Banking metrics model
└── README_BBVA.md                      # Setup instructions
```

## 🎯 Use Cases

### Sales Engineering
- **Client Demos**: Generate industry-specific demos in minutes
- **POC Development**: Create realistic environments for proof-of-concepts
- **Competitive Differentiation**: Show Cortex capabilities with client's context

### Training & Education
- **Snowflake Training**: Provide hands-on Cortex experience
- **Partner Enablement**: Equip partners with demo capabilities
- **Customer Workshops**: Interactive learning environments

### Solution Architecture
- **Reference Implementations**: Best-practice Cortex architectures
- **Rapid Prototyping**: Quick validation of technical approaches
- **Template Library**: Reusable components for future projects

## 🤝 Contributing

We welcome contributions! Areas for enhancement:

- **New Industries**: Add templates for additional verticals
- **Advanced Analytics**: More sophisticated ML models
- **UI Components**: Additional Streamlit visualizations
- **Integrations**: Connect with external data sources
- **Localization**: Multi-language support

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙋‍♂️ Support

For questions or issues:

1. Check the generated README files for specific setup guidance
2. Review Snowflake Cortex documentation
3. Test in your specific Snowflake environment first
4. Customize templates based on your client needs

---

**Built for Snowflake Sales Engineers by Snowflake Sales Engineers** 🚀

*Streamlining demo creation so you can focus on selling solutions, not building infrastructure.*




