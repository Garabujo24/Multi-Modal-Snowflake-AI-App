#!/usr/bin/env python3
"""
Multi-Modal Snowflake AI Demo Generator
=====================================
A reusable framework for creating customized Snowflake Cortex demos for any client.

This tool generates:
- Customized Streamlit applications
- Snowflake database schemas and tables
- Semantic models for Cortex Analyst
- Sample data appropriate for the client's industry
- SQL scripts for all Snowflake resources

Author: Snowflake Sales Engineer
Version: 1.0
"""

import streamlit as st
import requests
import json
import re
from urllib.parse import urlparse
import os
from datetime import datetime
from typing import Dict, List, Any, Tuple

class DemoGenerator:
    """Main class for generating customized Snowflake Cortex demos"""
    
    def __init__(self):
        self.client_info = {}
        self.industry_templates = {
            'retail': {
                'name': 'Retail & E-commerce',
                'icon': '🛍️',
                'primary_color': '#E53E3E',
                'secondary_color': '#FC8181',
                'accent_color': '#38B2AC',
                'categories': ['Fashion', 'Electronics', 'Home & Garden', 'Beauty', 'Sports', 'Books'],
                'metrics': ['Revenue', 'Transactions', 'New Customers', 'Inventory Alerts'],
                'use_cases': [
                    'Sales forecasting and demand planning',
                    'Customer sentiment analysis from reviews',
                    'Product image classification',
                    'Inventory optimization'
                ]
            },
            'financial': {
                'name': 'Financial Services',
                'icon': '🏦',
                'primary_color': '#1E40AF',
                'secondary_color': '#3B82F6',
                'accent_color': '#10B981',
                'categories': ['Checking', 'Savings', 'Loans', 'Investments', 'Insurance', 'Credit Cards'],
                'metrics': ['Assets Under Management', 'New Accounts', 'Customer Satisfaction', 'Risk Alerts'],
                'use_cases': [
                    'Fraud detection and risk assessment',
                    'Customer service automation',
                    'Document analysis and compliance',
                    'Market sentiment analysis'
                ]
            },
            'healthcare': {
                'name': 'Healthcare',
                'icon': '🏥',
                'primary_color': '#059669',
                'secondary_color': '#34D399',
                'accent_color': '#3B82F6',
                'categories': ['Emergency', 'Primary Care', 'Specialists', 'Surgery', 'Pharmacy', 'Diagnostics'],
                'metrics': ['Patient Satisfaction', 'Wait Times', 'Bed Occupancy', 'Critical Alerts'],
                'use_cases': [
                    'Patient outcome prediction',
                    'Medical document analysis',
                    'Treatment recommendation',
                    'Operational efficiency optimization'
                ]
            },
            'manufacturing': {
                'name': 'Manufacturing',
                'icon': '🏭',
                'primary_color': '#7C2D12',
                'secondary_color': '#EA580C',
                'accent_color': '#0891B2',
                'categories': ['Production', 'Quality Control', 'Maintenance', 'Supply Chain', 'Safety', 'R&D'],
                'metrics': ['Production Output', 'Quality Score', 'Downtime', 'Safety Incidents'],
                'use_cases': [
                    'Predictive maintenance',
                    'Quality control automation',
                    'Supply chain optimization',
                    'Equipment performance analysis'
                ]
            },
            'technology': {
                'name': 'Technology Services',
                'icon': '💻',
                'primary_color': '#1E3A8A',
                'secondary_color': '#3B82F6',
                'accent_color': '#10B981',
                'categories': ['Software', 'Hardware', 'Cloud Services', 'Consulting', 'Support', 'Training'],
                'metrics': ['Revenue', 'Active Users', 'Customer Satisfaction', 'System Alerts'],
                'use_cases': [
                    'User behavior analysis',
                    'Performance monitoring',
                    'Customer support automation',
                    'Product usage insights'
                ]
            }
        }
    
    def analyze_website(self, url: str) -> Dict[str, Any]:
        """Analyze a company website to extract business information"""
        try:
            # Normalize URL
            if not url.startswith(('http://', 'https://')):
                url = 'https://' + url
            
            # Extract domain info
            parsed_url = urlparse(url)
            domain = parsed_url.netloc.lower()
            
            # Company name from domain
            company_name = domain.replace('www.', '').split('.')[0].title()
            
            # Try to make a request to get basic info
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            
            try:
                response = requests.get(url, headers=headers, timeout=10)
                content = response.text.lower()
                
                # Simple keyword analysis to determine industry
                industry_keywords = {
                    'retail': ['shop', 'store', 'buy', 'product', 'cart', 'ecommerce', 'retail', 'fashion', 'clothing'],
                    'financial': ['bank', 'finance', 'investment', 'loan', 'credit', 'insurance', 'financial'],
                    'healthcare': ['health', 'medical', 'hospital', 'clinic', 'doctor', 'patient', 'healthcare'],
                    'manufacturing': ['manufacturing', 'factory', 'production', 'industrial', 'machinery', 'equipment'],
                    'technology': ['software', 'technology', 'tech', 'digital', 'cloud', 'api', 'platform']
                }
                
                industry_scores = {}
                for industry, keywords in industry_keywords.items():
                    score = sum(1 for keyword in keywords if keyword in content)
                    industry_scores[industry] = score
                
                # Determine best matching industry
                best_industry = max(industry_scores, key=industry_scores.get) if industry_scores else 'technology'
                
            except Exception:
                # Fallback to domain-based heuristics
                if any(word in domain for word in ['shop', 'store', 'retail', 'fashion']):
                    best_industry = 'retail'
                elif any(word in domain for word in ['bank', 'finance', 'invest']):
                    best_industry = 'financial'
                elif any(word in domain for word in ['health', 'medical', 'hospital']):
                    best_industry = 'healthcare'
                elif any(word in domain for word in ['manufacturing', 'industrial']):
                    best_industry = 'manufacturing'
                else:
                    best_industry = 'technology'
            
            return {
                'company_name': company_name,
                'domain': domain,
                'url': url,
                'industry': best_industry,
                'industry_confidence': industry_scores.get(best_industry, 0) if 'industry_scores' in locals() else 0
            }
            
        except Exception as e:
            st.error(f"Error analyzing website: {str(e)}")
            return {
                'company_name': 'Unknown Company',
                'domain': 'unknown.com',
                'url': url,
                'industry': 'technology',
                'industry_confidence': 0
            }
    
    def generate_database_name(self, company_name: str) -> str:
        """Generate a Snowflake database name from company name"""
        # Clean company name and make it Snowflake-compatible
        clean_name = re.sub(r'[^a-zA-Z0-9]', '_', company_name.upper())
        clean_name = re.sub(r'_+', '_', clean_name)  # Remove multiple underscores
        clean_name = clean_name.strip('_')  # Remove leading/trailing underscores
        return f"{clean_name}_CORTEX_DEMO"
    
    def generate_sample_data(self, industry: str, company_name: str) -> Dict[str, Any]:
        """Generate sample data appropriate for the industry"""
        template = self.industry_templates[industry]
        
        # Base data structure
        data = {
            'revenue_scale': self.get_revenue_scale(industry),
            'categories': template['categories'],
            'metrics': template['metrics'],
            'customers': self.generate_customer_segments(industry),
            'transactions': self.generate_transaction_patterns(industry),
            'use_cases': template['use_cases']
        }
        
        return data
    
    def get_revenue_scale(self, industry: str) -> Dict[str, int]:
        """Get appropriate revenue scale for industry"""
        scales = {
            'retail': {'monthly_base': 2000, 'unit': 'millions', 'currency': 'USD'},
            'financial': {'monthly_base': 5000, 'unit': 'millions', 'currency': 'USD'},
            'healthcare': {'monthly_base': 800, 'unit': 'millions', 'currency': 'USD'},
            'manufacturing': {'monthly_base': 1500, 'unit': 'millions', 'currency': 'USD'},
            'technology': {'monthly_base': 300, 'unit': 'millions', 'currency': 'USD'}
        }
        return scales.get(industry, scales['technology'])
    
    def generate_customer_segments(self, industry: str) -> List[str]:
        """Generate customer segments for industry"""
        segments = {
            'retail': ['Premium Members', 'Young Professionals', 'Family Shoppers', 'Senior Citizens', 'Fashion Enthusiasts'],
            'financial': ['High Net Worth', 'Young Professionals', 'Small Business', 'Retirees', 'First Time Buyers'],
            'healthcare': ['Emergency Patients', 'Regular Checkups', 'Chronic Care', 'Specialists', 'Preventive Care'],
            'manufacturing': ['Enterprise Clients', 'SMB Partners', 'Government Contracts', 'International Markets', 'Startups'],
            'technology': ['Enterprise', 'Mid-Market', 'SMB', 'Startups', 'Individual Users']
        }
        return segments.get(industry, segments['technology'])
    
    def generate_transaction_patterns(self, industry: str) -> Dict[str, List[int]]:
        """Generate realistic transaction patterns"""
        patterns = {
            'retail': {
                'daily_transactions': [450, 520, 480, 610, 550, 580, 620],
                'seasonal_multiplier': [0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.2, 1.0, 0.9, 1.5, 1.8]  # Holiday boost
            },
            'financial': {
                'daily_transactions': [1200, 1400, 1300, 1600, 1500, 1000, 900],
                'seasonal_multiplier': [1.0, 1.0, 1.1, 1.2, 1.1, 1.0, 1.0, 1.0, 1.1, 1.2, 1.1, 1.0]
            },
            'healthcare': {
                'daily_transactions': [300, 350, 380, 390, 385, 280, 200],
                'seasonal_multiplier': [1.3, 1.2, 1.0, 0.9, 0.8, 0.8, 0.8, 0.9, 1.0, 1.1, 1.2, 1.4]  # Flu season
            },
            'manufacturing': {
                'daily_transactions': [80, 95, 100, 105, 98, 60, 45],
                'seasonal_multiplier': [0.9, 0.9, 1.0, 1.1, 1.2, 1.3, 1.1, 1.2, 1.1, 1.0, 0.9, 0.8]
            },
            'technology': {
                'daily_transactions': [200, 250, 280, 290, 270, 180, 150],
                'seasonal_multiplier': [1.0, 1.0, 1.1, 1.1, 1.0, 1.0, 0.9, 0.9, 1.0, 1.1, 1.2, 1.1]
            }
        }
        return patterns.get(industry, patterns['technology'])
    
    def _generate_readme(self, client_info: Dict[str, Any], app_file: str, sql_files: Dict[str, str], model_file: str) -> str:
        """Generate README documentation for the demo"""
        
        company_name = client_info['name']
        website_info = client_info['website_info']
        industry = website_info['industry']
        template = self.industry_templates[industry]
        
        return f'''# {company_name} - Snowflake Cortex Demo Kit

## 📋 Overview

This demo kit contains a complete Snowflake Cortex demonstration tailored for **{company_name}** in the **{template['name']}** industry.

**Generated on:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}  
**Industry:** {template['name']} ({template['icon']})  
**Website:** {website_info['url']}  
**Demo Purpose:** {client_info['purpose']}

## 🎯 What's Included

### 📱 Streamlit Application
- **File:** `{os.path.basename(app_file)}`
- **Description:** Complete interactive demo application
- **Features:** 
  - Executive dashboard with KPIs
  - Cortex Analyst natural language queries
  - Cortex Search document retrieval
  - AISQL multimodal text analysis
  - ML predictive analytics and forecasting
  - Real-time alerts and monitoring

### 🗄️ SQL Setup Scripts
- **Setup Script:** `{os.path.basename(sql_files['setup'])}`
  - Creates database, schemas, warehouses, and roles
  - Sets up permissions and file formats
  - Configures Cortex prerequisites

- **Tables Script:** `{os.path.basename(sql_files['tables'])}`
  - Creates all business tables (transactions, customers, products, etc.)
  - Defines relationships and constraints
  - Sets up indexes for performance

- **Sample Data:** `{os.path.basename(sql_files['data'])}`
  - Loads realistic sample data (5,000+ transactions, 500+ customers)
  - Includes performance metrics and support tickets
  - Provides data for all demo scenarios

- **Views Script:** `{os.path.basename(sql_files['views'])}`
  - Creates analytical views for reporting
  - Optimizes data for Cortex Analyst
  - Provides aggregated business metrics

### 🧠 Semantic Model
- **File:** `{os.path.basename(model_file)}`
- **Description:** Cortex Analyst configuration
- **Features:**
  - Logical tables and relationships
  - Business metrics and dimensions
  - Verified queries for common questions
  - Industry-specific terminology

## 🚀 Quick Start Guide

### Prerequisites
- Snowflake account with Cortex enabled
- Python 3.8+ with Streamlit
- Appropriate Snowflake privileges (ACCOUNTADMIN recommended for setup)

### Step 1: Snowflake Setup
```sql
-- Run the scripts in this order:
-- 1. Database and warehouse setup
@{os.path.basename(sql_files['setup'])}

-- 2. Create tables and relationships  
@{os.path.basename(sql_files['tables'])}

-- 3. Load sample data
@{os.path.basename(sql_files['data'])}

-- 4. Create analytical views
@{os.path.basename(sql_files['views'])}
```

### Step 2: Configure Cortex Analyst
```bash
# Upload semantic model to Snowflake
snow cortex analyst create-model \\
  --file {os.path.basename(model_file)} \\
  --database {self.generate_database_name(company_name)} \\
  --schema ANALYTICS
```

### Step 3: Run Streamlit App
```bash
# Install dependencies
pip install streamlit snowflake-connector-python plotly pandas

# Configure Snowflake connection
# Create .streamlit/secrets.toml with your credentials:
# [snowflake]
# user = "your_username"
# password = "your_password" 
# account = "your_account"
# warehouse = "{self.generate_database_name(company_name)}_WH"

# Run the application
streamlit run {os.path.basename(app_file)}
```

## 📊 Demo Scenarios

### 🤖 Cortex Analyst
**Sample Questions to Try:**
- "What was our revenue last quarter?"
- "Which {template['categories'][0].lower()} products are performing best?"
- "Show me customer segment performance"
- "How are we trending compared to last year?"

### 🔍 Cortex Search  
**Documents Available:**
- {company_name} Operating Procedures
- {template['name']} Performance Standards
- Business Intelligence Best Practices
- System Administration Guidelines
- Strategic Planning Framework

### 🎯 AISQL Multimodal
**Features Demonstrated:**
- Customer feedback sentiment analysis
- Automated text classification
- Pattern recognition in data
- Content summarization

### 📈 ML Predictive
**Capabilities Shown:**
- Revenue forecasting
- Anomaly detection
- Customer behavior prediction
- Trend analysis

## 🛠️ Customization Guide

### Modifying Sample Data
Edit the data generation sections in `{os.path.basename(sql_files['data'])}`:
- Adjust customer segments for your target market
- Modify product categories to match your offerings
- Update regions and locations as needed
- Scale transaction volumes appropriately

### Updating the Semantic Model
Modify `{os.path.basename(model_file)}` to:
- Add industry-specific metrics
- Include custom dimensions
- Create additional verified queries
- Adjust table relationships

### Streamlit App Customization
Update `{os.path.basename(app_file)}` to:
- Change color scheme and branding
- Add new visualizations
- Modify KPIs and metrics
- Include custom business logic

## 🎨 Branding

**Color Palette:**
- Primary: {template['primary_color']} 
- Secondary: {template['secondary_color']}
- Accent: {template['accent_color']}

**Visual Elements:**
- Industry icon: {template['icon']}
- Company focus: {template['name']}
- Target use cases: {', '.join(template['use_cases'][:2])}

## 📞 Support

For questions about this demo kit:

1. **Technical Issues:** Check Snowflake documentation for Cortex setup
2. **Customization:** Modify the generated scripts as needed
3. **Business Questions:** Adapt the semantic model and sample data

## 📝 Notes

- All sample data is fictional and generated for demo purposes
- Adjust Snowflake warehouse sizes based on your demo environment
- Test all Cortex functions in your specific Snowflake region
- Some Cortex features may require additional account setup

---

**Generated by Multi-Modal Snowflake AI Demo Generator v1.0**  
*Empowering sales teams with industry-specific Cortex demonstrations*
'''


def main():
    st.set_page_config(
        page_title="Multi-Modal Snowflake AI Demo Generator",
        page_icon="🚀",
        layout="wide",
        initial_sidebar_state="expanded"
    )
    
    st.title("🚀 Multi-Modal Snowflake AI Demo Generator")
    st.markdown("**Create customized Snowflake Cortex demos for any client**")
    
    # Initialize generator
    generator = DemoGenerator()
    
    # Step 1: Client Information
    st.header("📋 Step 1: Client Information")
    
    col1, col2 = st.columns(2)
    
    with col1:
        client_name = st.text_input(
            "Client Company Name",
            placeholder="e.g., Acme Corporation",
            help="Enter the client's company name"
        )
        
        website_url = st.text_input(
            "Company Website",
            placeholder="e.g., https://www.company.com",
            help="Enter the client's website URL for automatic analysis"
        )
    
    with col2:
        manual_industry = st.selectbox(
            "Industry (optional - leave blank for auto-detection)",
            ["Auto-detect from website"] + list(generator.industry_templates.keys()),
            format_func=lambda x: "🔍 Auto-detect from website" if x == "Auto-detect from website" 
                                 else f"{generator.industry_templates[x]['icon']} {generator.industry_templates[x]['name']}"
        )
        
        demo_purpose = st.selectbox(
            "Demo Purpose",
            ["Sales Presentation", "POC Demo", "Training Session", "Executive Briefing"],
            help="What is the main purpose of this demo?"
        )
    
    # Analyze website button
    if st.button("🔍 Analyze Website & Generate Demo", disabled=not (client_name and website_url)):
        with st.spinner("Analyzing website and preparing demo..."):
            
            # Analyze website
            website_info = generator.analyze_website(website_url)
            
            # Use manual industry selection if provided
            if manual_industry != "Auto-detect from website":
                website_info['industry'] = manual_industry
            
            # Store in session state
            st.session_state['client_info'] = {
                'name': client_name,
                'website_info': website_info,
                'purpose': demo_purpose,
                'generated_at': datetime.now().isoformat()
            }
            
            st.success("✅ Website analyzed and demo configuration prepared!")
    
    # Show results if available
    if 'client_info' in st.session_state:
        client_info = st.session_state['client_info']
        website_info = client_info['website_info']
        industry = website_info['industry']
        
        st.header("📊 Step 2: Demo Configuration")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("🏢 Client Analysis")
            st.write(f"**Company:** {client_info['name']}")
            st.write(f"**Website:** {website_info['url']}")
            st.write(f"**Domain:** {website_info['domain']}")
            st.write(f"**Detected Industry:** {generator.industry_templates[industry]['icon']} {generator.industry_templates[industry]['name']}")
            if website_info['industry_confidence'] > 0:
                st.write(f"**Confidence:** {website_info['industry_confidence']} keywords matched")
        
        with col2:
            st.subheader("🎯 Demo Details")
            db_name = generator.generate_database_name(client_info['name'])
            st.write(f"**Database Name:** `{db_name}`")
            st.write(f"**Demo Purpose:** {client_info['purpose']}")
            st.write(f"**Generated:** {client_info['generated_at'][:10]}")
            
            # Color preview
            template = generator.industry_templates[industry]
            st.markdown(f"""
            **Color Scheme:**
            <div style="display: flex; gap: 10px; margin: 10px 0;">
                <div style="width: 30px; height: 30px; background: {template['primary_color']}; border-radius: 4px;" title="Primary"></div>
                <div style="width: 30px; height: 30px; background: {template['secondary_color']}; border-radius: 4px;" title="Secondary"></div>
                <div style="width: 30px; height: 30px; background: {template['accent_color']}; border-radius: 4px;" title="Accent"></div>
            </div>
            """, unsafe_allow_html=True)
        
        # Step 3: Generate Resources
        st.header("⚙️ Step 3: Generate Demo Resources")
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            if st.button("📊 Generate Streamlit App", use_container_width=True):
                with st.spinner("Generating customized Streamlit application..."):
                    try:
                        from streamlit_generator import StreamlitGenerator
                        streamlit_gen = StreamlitGenerator()
                        app_file = streamlit_gen.generate_app(client_info, "output")
                        st.success(f"✅ Streamlit app generated: `{app_file}`")
                        
                        # Show download link
                        with open(app_file, 'r', encoding='utf-8') as f:
                            app_content = f.read()
                        
                        st.download_button(
                            label="📥 Download Streamlit App",
                            data=app_content,
                            file_name=os.path.basename(app_file),
                            mime="text/plain"
                        )
                        
                    except Exception as e:
                        st.error(f"Error generating Streamlit app: {str(e)}")
        
        with col2:
            if st.button("🗄️ Generate SQL Scripts", use_container_width=True):
                with st.spinner("Generating database schemas and sample data..."):
                    try:
                        from sql_generator import SQLGenerator
                        sql_gen = SQLGenerator()
                        sql_files = sql_gen.generate_complete_setup(client_info, "output")
                        
                        st.success("✅ SQL scripts generated successfully!")
                        
                        for script_type, filepath in sql_files.items():
                            with open(filepath, 'r', encoding='utf-8') as f:
                                script_content = f.read()
                            
                            st.download_button(
                                label=f"📥 Download {script_type.title()} Script",
                                data=script_content,
                                file_name=os.path.basename(filepath),
                                mime="text/plain",
                                key=f"download_{script_type}"
                            )
                        
                    except Exception as e:
                        st.error(f"Error generating SQL scripts: {str(e)}")
        
        with col3:
            if st.button("🧠 Generate Semantic Model", use_container_width=True):
                with st.spinner("Creating Cortex Analyst semantic model..."):
                    try:
                        from semantic_model_generator import SemanticModelGenerator
                        semantic_gen = SemanticModelGenerator()
                        model_file = semantic_gen.generate_semantic_model(client_info, "output")
                        
                        st.success(f"✅ Semantic model generated: `{model_file}`")
                        
                        # Show download link
                        with open(model_file, 'r', encoding='utf-8') as f:
                            model_content = f.read()
                        
                        st.download_button(
                            label="📥 Download Semantic Model",
                            data=model_content,
                            file_name=os.path.basename(model_file),
                            mime="text/plain"
                        )
                        
                        # Show model preview
                        with st.expander("🔍 Preview Semantic Model"):
                            st.code(model_content, language='yaml')
                        
                    except Exception as e:
                        st.error(f"Error generating semantic model: {str(e)}")
        
        # Generate all button
        st.markdown("---")
        
        if st.button("🚀 Generate Complete Demo Package", use_container_width=True, type="primary"):
            with st.spinner("Generating complete demo package..."):
                try:
                    # Generate all components
                    from streamlit_generator import StreamlitGenerator
                    from sql_generator import SQLGenerator
                    from semantic_model_generator import SemanticModelGenerator
                    
                    streamlit_gen = StreamlitGenerator()
                    sql_gen = SQLGenerator()
                    semantic_gen = SemanticModelGenerator()
                    
                    # Generate all files
                    app_file = streamlit_gen.generate_app(client_info, "output")
                    sql_files = sql_gen.generate_complete_setup(client_info, "output")
                    model_file = semantic_gen.generate_semantic_model(client_info, "output")
                    
                    # Generate README
                    readme_content = self._generate_readme(client_info, app_file, sql_files, model_file)
                    readme_file = os.path.join("output", f"README_{client_info['name'].replace(' ', '_')}.md")
                    with open(readme_file, 'w', encoding='utf-8') as f:
                        f.write(readme_content)
                    
                    st.success("✅ Complete demo package generated successfully!")
                    
                    # Show summary
                    st.markdown("### 📦 Generated Files:")
                    
                    all_files = {
                        'Streamlit App': app_file,
                        'README': readme_file,
                        'Semantic Model': model_file,
                        **sql_files
                    }
                    
                    for file_type, filepath in all_files.items():
                        with open(filepath, 'r', encoding='utf-8') as f:
                            file_content = f.read()
                        
                        col1, col2 = st.columns([3, 1])
                        with col1:
                            st.write(f"📄 **{file_type}**: `{os.path.basename(filepath)}`")
                        with col2:
                            st.download_button(
                                label="📥 Download",
                                data=file_content,
                                file_name=os.path.basename(filepath),
                                mime="text/plain",
                                key=f"download_all_{file_type.replace(' ', '_').lower()}"
                            )
                    
                except Exception as e:
                    st.error(f"Error generating complete demo: {str(e)}")
        
        # Preview section
        st.header("👀 Step 4: Demo Preview")
        
        # Generate sample data for preview
        sample_data = generator.generate_sample_data(industry, client_info['name'])
        
        tab1, tab2, tab3 = st.tabs(["📊 Sample Data", "🎯 Use Cases", "📋 Resources"])
        
        with tab1:
            st.subheader("Sample Business Data")
            col1, col2 = st.columns(2)
            
            with col1:
                st.write("**Product/Service Categories:**")
                for i, category in enumerate(sample_data['categories'], 1):
                    st.write(f"{i}. {category}")
                
                st.write("**Key Metrics:**")
                for metric in sample_data['metrics']:
                    st.write(f"• {metric}")
            
            with col2:
                st.write("**Customer Segments:**")
                for segment in sample_data['customers']:
                    st.write(f"• {segment}")
                
                revenue_info = sample_data['revenue_scale']
                st.write(f"**Revenue Scale:** {revenue_info['monthly_base']} {revenue_info['unit']} {revenue_info['currency']} monthly")
        
        with tab2:
            st.subheader("Snowflake Cortex Use Cases")
            for i, use_case in enumerate(sample_data['use_cases'], 1):
                st.write(f"{i}. {use_case}")
        
        with tab3:
            st.subheader("Generated Resources")
            st.write("When you generate the demo, these files will be created:")
            
            resources = [
                f"📱 `{client_info['name'].lower().replace(' ', '_')}_cortex_demo.py` - Streamlit application",
                f"🗄️ `{db_name.lower()}_setup.sql` - Database setup script",
                f"📊 `{db_name.lower()}_sample_data.sql` - Sample data insertion",
                f"🧠 `{client_info['name'].lower().replace(' ', '_')}_semantic_model.yaml` - Cortex Analyst model",
                f"📋 `README_{client_info['name'].replace(' ', '_')}.md` - Setup instructions"
            ]
            
            for resource in resources:
                st.write(resource)


if __name__ == "__main__":
    main()
