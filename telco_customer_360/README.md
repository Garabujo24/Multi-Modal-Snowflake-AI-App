# 📱 Telco Customer 360 Dashboard

A comprehensive Streamlit dashboard designed for telecom sales teams to analyze customer 360° data and improve customer interactions.

## 🌟 Features

### 📊 **Multi-Page Dashboard**
- **Customer Overview**: Complete customer profile and key metrics
- **Usage Analytics**: Data usage patterns, call minutes, and trends
- **Billing & Revenue**: Payment history, revenue analysis, and billing trends
- **Churn Risk Analysis**: AI-powered churn prediction with retention recommendations
- **Customer Journey**: Timeline of interactions and support history
- **Sales Opportunities**: Intelligent upsell and cross-sell recommendations

### 🎯 **Sales Team Benefits**
- **Customer 360° View**: All customer data in one place
- **Interactive Analytics**: Dynamic charts and visualizations
- **Risk Assessment**: Proactive churn prevention insights
- **Revenue Optimization**: Identify upsell/cross-sell opportunities
- **Data-Driven Decisions**: Real-time metrics and trends

### 📈 **Key Metrics Tracked**
- Customer tenure and satisfaction scores
- Usage patterns (data, calls, SMS)
- Billing history and payment status
- Support ticket analysis
- Churn risk scoring
- Revenue per customer

## 🚀 Quick Start

### Prerequisites
- Python 3.8 or higher
- pip (Python package installer)

### Installation

1. **Clone or download the files**:
   ```bash
   cd telco_customer_360
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the dashboard**:
   ```bash
   streamlit run app.py
   ```

4. **Open your browser** to `http://localhost:8501`

## 📊 Generated Data

The dashboard includes realistic generated data for:

### 👥 **Customer Profiles** (1,000 customers)
- Demographics (name, contact, address)
- Account types (Individual, Family, Business, Enterprise)
- Service subscriptions (Mobile, Internet, TV, Phone, Security, Cloud, IoT)
- Credit scores and satisfaction ratings

### 📈 **Usage Data** (90 days)
- Daily data usage patterns
- Call minutes and SMS counts
- Network quality metrics
- Roaming usage

### 💰 **Billing History** (12 months)
- Monthly billing amounts
- Payment status tracking
- Service-based pricing
- Overage charges

### 🎫 **Support Interactions** (6 months)
- Ticket types and priorities
- Resolution times
- Agent assignments
- Customer satisfaction

## 🎨 Dashboard Pages

### 🏠 **Customer Overview**
- Customer basic information and contact details
- Account type and active services
- Key metrics (tenure, credit score, revenue)
- Recent activity summary

### 📊 **Usage Analytics**
- Interactive usage trend charts
- Weekly and monthly patterns
- Usage distribution analysis
- Comparative statistics

### 💰 **Billing & Revenue**
- Revenue metrics and trends
- Payment status breakdown
- Billing history table
- Late payment tracking

### ⚠️ **Churn Risk Analysis**
- AI-powered churn risk scoring
- Risk factor identification
- Retention recommendations
- Proactive intervention strategies

### 🎯 **Customer Journey**
- Customer timeline and milestones
- Support interaction history
- Journey insights and patterns
- Positive indicators vs. concerns

### 📈 **Sales Opportunities**
- Intelligent opportunity scoring
- Service expansion recommendations
- Usage-based upsell suggestions
- Revenue potential calculations

## 🔧 Customization

### **Data Generation**
Modify `data_generator.py` to:
- Adjust customer demographics
- Change usage patterns
- Customize service offerings
- Modify billing structures

### **Styling**
Update the CSS in `app.py` to:
- Change color schemes
- Modify layout components
- Add custom branding
- Enhance visual elements

### **Metrics**
Add new metrics by:
- Extending data generation functions
- Creating new visualization components
- Adding custom calculations
- Implementing new KPIs

## 📱 Mobile-Friendly

The dashboard is responsive and works on:
- Desktop browsers
- Tablets
- Mobile devices (with touch navigation)

## 🎯 Sales Use Cases

### **Pre-Call Preparation**
- Review customer 360° profile
- Identify potential opportunities
- Understand usage patterns
- Check payment history

### **Customer Retention**
- Monitor churn risk scores
- Identify at-risk customers
- Implement retention strategies
- Track satisfaction trends

### **Revenue Growth**
- Discover upsell opportunities
- Analyze usage for plan upgrades
- Cross-sell additional services
- Calculate revenue potential

### **Customer Success**
- Track customer journey milestones
- Monitor support interactions
- Ensure service satisfaction
- Build long-term relationships

## 📊 Technical Details

### **Technologies Used**
- **Streamlit**: Web application framework
- **Pandas**: Data manipulation and analysis
- **Plotly**: Interactive visualizations
- **NumPy**: Numerical computing
- **Faker**: Realistic test data generation

### **Performance**
- Data caching for fast loading
- Efficient data processing
- Responsive design
- Optimized visualizations

### **Data Structure**
```
customers_df:    Customer profiles and demographics
usage_df:        Daily usage patterns (90 days)
billing_df:      Monthly billing history (12 months)
support_df:      Support ticket interactions (6 months)
```

## 🔄 Future Enhancements

### **Planned Features**
- Real-time data integration
- Advanced ML models for churn prediction
- Automated report generation
- Email/SMS integration for outreach
- Team collaboration features
- Custom dashboard widgets

### **API Integration**
- CRM system connectivity
- Billing system integration
- Support ticket APIs
- Usage monitoring systems

## 🤝 Support

For questions or issues:
1. Check the generated data for realistic examples
2. Review the code comments for functionality details
3. Modify data generation parameters as needed
4. Customize visualizations for specific requirements

## 📝 License

This project is provided as-is for demonstration and educational purposes.

---

**Ready to transform your telco sales process? Start the dashboard and explore the customer 360° insights!**

```bash
streamlit run app.py
``` 