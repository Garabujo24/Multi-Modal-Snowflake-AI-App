import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import datetime as dt
from datetime import timedelta
import random
from data_generator import generate_customer_data, generate_usage_data, generate_billing_data, generate_support_data
import warnings
warnings.filterwarnings('ignore')

# Page configuration
st.set_page_config(
    page_title="Telco Customer 360 Dashboard",
    page_icon="📱",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for styling
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: bold;
        color: #1f77b4;
        text-align: center;
        padding: 1rem 0;
        border-bottom: 2px solid #e0e0e0;
        margin-bottom: 2rem;
    }
    
    .metric-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 1.5rem;
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        margin: 0.5rem 0;
    }
    
    .customer-card {
        background: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        padding: 1rem;
        margin: 0.5rem 0;
    }
    
    .risk-high { color: #dc3545; font-weight: bold; }
    .risk-medium { color: #ffc107; font-weight: bold; }
    .risk-low { color: #28a745; font-weight: bold; }
    
    .sidebar .sidebar-content {
        background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
    }
</style>
""", unsafe_allow_html=True)

# Load or generate data
@st.cache_data
def load_data():
    """Load all the telco customer data"""
    customers = generate_customer_data(1000)
    usage = generate_usage_data(customers)
    billing = generate_billing_data(customers)
    support = generate_support_data(customers)
    
    return customers, usage, billing, support

def main():
    """Main application function"""
    
    # Load data
    customers_df, usage_df, billing_df, support_df = load_data()
    
    # Sidebar navigation
    st.sidebar.title("📱 Telco Customer 360")
    st.sidebar.markdown("---")
    
    page = st.sidebar.selectbox(
        "Choose a page:",
        ["🏠 Customer Overview", "📊 Usage Analytics", "💰 Billing & Revenue", 
         "⚠️ Churn Risk Analysis", "🎯 Customer Journey", "📈 Sales Opportunities"]
    )
    
    # Customer selector
    st.sidebar.markdown("### Select Customer")
    customer_list = customers_df[['customer_id', 'name']].copy()
    customer_list['display'] = customer_list['customer_id'] + " - " + customer_list['name']
    
    selected_customer = st.sidebar.selectbox(
        "Customer:",
        customer_list['display'].tolist(),
        help="Select a customer to view their 360° profile"
    )
    
    customer_id = selected_customer.split(" - ")[0]
    
    # Page routing
    if page == "🏠 Customer Overview":
        show_customer_overview(customers_df, usage_df, billing_df, support_df, customer_id)
    elif page == "📊 Usage Analytics":
        show_usage_analytics(customers_df, usage_df, customer_id)
    elif page == "💰 Billing & Revenue":
        show_billing_revenue(customers_df, billing_df, customer_id)
    elif page == "⚠️ Churn Risk Analysis":
        show_churn_analysis(customers_df, usage_df, billing_df, support_df, customer_id)
    elif page == "🎯 Customer Journey":
        show_customer_journey(customers_df, support_df, customer_id)
    elif page == "📈 Sales Opportunities":
        show_sales_opportunities(customers_df, usage_df, billing_df, customer_id)

def show_customer_overview(customers_df, usage_df, billing_df, support_df, customer_id):
    """Customer Overview page"""
    
    st.markdown('<div class="main-header">🏠 Customer Overview</div>', unsafe_allow_html=True)
    
    # Get customer data
    customer = customers_df[customers_df['customer_id'] == customer_id].iloc[0]
    
    # Customer basic info
    col1, col2, col3 = st.columns([2, 1, 1])
    
    with col1:
        st.markdown(f"""
        <div class="customer-card">
            <h3>{customer['name']}</h3>
            <p><strong>Customer ID:</strong> {customer['customer_id']}</p>
            <p><strong>Phone:</strong> {customer['phone']}</p>
            <p><strong>Email:</strong> {customer['email']}</p>
            <p><strong>Address:</strong> {customer['address']}, {customer['city']}, {customer['state']}</p>
            <p><strong>Account Type:</strong> {customer['account_type']}</p>
            <p><strong>Customer Since:</strong> {customer['signup_date']}</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        tenure_months = (dt.datetime.now() - pd.to_datetime(customer['signup_date'])).days // 30
        st.metric("Tenure (Months)", tenure_months)
        st.metric("Credit Score", customer['credit_score'])
        
    with col3:
        # Calculate monthly revenue
        customer_billing = billing_df[billing_df['customer_id'] == customer_id]
        avg_monthly_revenue = customer_billing['amount'].mean() if not customer_billing.empty else 0
        
        st.metric("Monthly Revenue", f"${avg_monthly_revenue:.2f}")
        st.metric("Total Services", len(customer['services'].split(',')))
    
    # Services breakdown
    st.markdown("### 📱 Active Services")
    services = customer['services'].split(',')
    
    col1, col2, col3, col4 = st.columns(4)
    service_icons = {
        'Mobile': '📱', 'Internet': '🌐', 'TV': '📺', 'Phone': '☎️',
        'Security': '🔒', 'Cloud': '☁️', 'IoT': '📡'
    }
    
    for i, service in enumerate(services):
        service = service.strip()
        with [col1, col2, col3, col4][i % 4]:
            icon = service_icons.get(service, '📋')
            st.markdown(f"""
            <div style="text-align: center; padding: 1rem; background: #f0f2f6; border-radius: 8px; margin: 0.25rem;">
                <div style="font-size: 2rem;">{icon}</div>
                <div style="font-weight: bold;">{service}</div>
            </div>
            """, unsafe_allow_html=True)
    
    # Recent activity summary
    st.markdown("### 📈 Recent Activity Summary")
    
    col1, col2, col3, col4 = st.columns(4)
    
    # Get recent data
    recent_usage = usage_df[(usage_df['customer_id'] == customer_id) & 
                           (usage_df['date'] >= (dt.datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d'))]
    
    recent_support = support_df[(support_df['customer_id'] == customer_id) & 
                               (support_df['date'] >= (dt.datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d'))]
    
    with col1:
        avg_data_usage = recent_usage['data_usage_gb'].mean() if not recent_usage.empty else 0
        st.metric("Avg Daily Data (GB)", f"{avg_data_usage:.1f}")
    
    with col2:
        total_calls = recent_usage['call_minutes'].sum() if not recent_usage.empty else 0
        st.metric("Total Call Minutes", f"{total_calls:.0f}")
    
    with col3:
        support_tickets = len(recent_support)
        st.metric("Support Tickets (30d)", support_tickets)
    
    with col4:
        satisfaction = customer['satisfaction_score']
        st.metric("Satisfaction Score", f"{satisfaction}/10")

def show_usage_analytics(customers_df, usage_df, customer_id):
    """Usage Analytics page"""
    
    st.markdown('<div class="main-header">📊 Usage Analytics</div>', unsafe_allow_html=True)
    
    # Get customer and usage data
    customer = customers_df[customers_df['customer_id'] == customer_id].iloc[0]
    customer_usage = usage_df[usage_df['customer_id'] == customer_id].copy()
    customer_usage['date'] = pd.to_datetime(customer_usage['date'])
    customer_usage = customer_usage.sort_values('date')
    
    # Usage trends
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### 📱 Data Usage Trend")
        fig_data = px.line(customer_usage, x='date', y='data_usage_gb',
                          title='Daily Data Usage (GB)',
                          line_shape='spline')
        fig_data.update_layout(height=400)
        st.plotly_chart(fig_data, use_container_width=True)
    
    with col2:
        st.markdown("### ☎️ Call Minutes Trend")
        fig_calls = px.line(customer_usage, x='date', y='call_minutes',
                           title='Daily Call Minutes',
                           line_shape='spline', color_discrete_sequence=['#ff7f0e'])
        fig_calls.update_layout(height=400)
        st.plotly_chart(fig_calls, use_container_width=True)
    
    # Usage patterns
    st.markdown("### 📈 Usage Patterns Analysis")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        # Weekly pattern
        customer_usage['day_of_week'] = customer_usage['date'].dt.day_name()
        weekly_pattern = customer_usage.groupby('day_of_week')['data_usage_gb'].mean().reindex([
            'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
        ])
        
        fig_weekly = px.bar(x=weekly_pattern.index, y=weekly_pattern.values,
                           title='Average Data Usage by Day of Week')
        fig_weekly.update_layout(height=300)
        st.plotly_chart(fig_weekly, use_container_width=True)
    
    with col2:
        # Monthly trend
        customer_usage['month'] = customer_usage['date'].dt.strftime('%Y-%m')
        monthly_trend = customer_usage.groupby('month')['data_usage_gb'].sum()
        
        fig_monthly = px.bar(x=monthly_trend.index, y=monthly_trend.values,
                            title='Monthly Data Usage (GB)')
        fig_monthly.update_layout(height=300)
        st.plotly_chart(fig_monthly, use_container_width=True)
    
    with col3:
        # Usage distribution
        fig_dist = px.histogram(customer_usage, x='data_usage_gb', bins=20,
                               title='Data Usage Distribution')
        fig_dist.update_layout(height=300)
        st.plotly_chart(fig_dist, use_container_width=True)
    
    # Usage statistics
    st.markdown("### 📊 Usage Statistics")
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        avg_daily_data = customer_usage['data_usage_gb'].mean()
        st.metric("Avg Daily Data", f"{avg_daily_data:.2f} GB")
    
    with col2:
        max_daily_data = customer_usage['data_usage_gb'].max()
        st.metric("Peak Daily Data", f"{max_daily_data:.2f} GB")
    
    with col3:
        avg_daily_calls = customer_usage['call_minutes'].mean()
        st.metric("Avg Daily Calls", f"{avg_daily_calls:.0f} min")
    
    with col4:
        total_sms = customer_usage['sms_count'].sum()
        st.metric("Total SMS", f"{total_sms:,}")

def show_billing_revenue(customers_df, billing_df, customer_id):
    """Billing & Revenue page"""
    
    st.markdown('<div class="main-header">💰 Billing & Revenue</div>', unsafe_allow_html=True)
    
    # Get customer and billing data
    customer = customers_df[customers_df['customer_id'] == customer_id].iloc[0]
    customer_billing = billing_df[billing_df['customer_id'] == customer_id].copy()
    customer_billing['bill_date'] = pd.to_datetime(customer_billing['bill_date'])
    customer_billing = customer_billing.sort_values('bill_date')
    
    # Revenue metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_revenue = customer_billing['amount'].sum()
        st.metric("Total Revenue (12m)", f"${total_revenue:,.2f}")
    
    with col2:
        avg_monthly = customer_billing['amount'].mean()
        st.metric("Avg Monthly Bill", f"${avg_monthly:.2f}")
    
    with col3:
        late_payments = len(customer_billing[customer_billing['payment_status'] == 'Late'])
        st.metric("Late Payments", late_payments)
    
    with col4:
        pending_amount = customer_billing[customer_billing['payment_status'] == 'Pending']['amount'].sum()
        st.metric("Pending Amount", f"${pending_amount:.2f}")
    
    # Billing trends
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### 📈 Monthly Billing Trend")
        fig_billing = px.line(customer_billing, x='bill_date', y='amount',
                             title='Monthly Bill Amount',
                             line_shape='spline')
        fig_billing.update_layout(height=400)
        st.plotly_chart(fig_billing, use_container_width=True)
    
    with col2:
        st.markdown("### 💳 Payment Status Distribution")
        payment_counts = customer_billing['payment_status'].value_counts()
        fig_payment = px.pie(values=payment_counts.values, names=payment_counts.index,
                            title='Payment Status Breakdown')
        fig_payment.update_layout(height=400)
        st.plotly_chart(fig_payment, use_container_width=True)
    
    # Billing history table
    st.markdown("### 📋 Recent Billing History")
    recent_bills = customer_billing.head(6)[['bill_date', 'amount', 'payment_status', 'due_date']]
    recent_bills['bill_date'] = recent_bills['bill_date'].dt.strftime('%Y-%m-%d')
    recent_bills['due_date'] = pd.to_datetime(recent_bills['due_date']).dt.strftime('%Y-%m-%d')
    st.dataframe(recent_bills, use_container_width=True)

def show_churn_analysis(customers_df, usage_df, billing_df, support_df, customer_id):
    """Churn Risk Analysis page"""
    
    st.markdown('<div class="main-header">⚠️ Churn Risk Analysis</div>', unsafe_allow_html=True)
    
    # Get customer data
    customer = customers_df[customers_df['customer_id'] == customer_id].iloc[0]
    churn_risk = customer['churn_risk_score']
    
    # Risk level classification
    if churn_risk >= 0.7:
        risk_level = "HIGH"
        risk_color = "🔴"
        risk_class = "risk-high"
    elif churn_risk >= 0.4:
        risk_level = "MEDIUM"
        risk_color = "🟡"
        risk_class = "risk-medium"
    else:
        risk_level = "LOW"
        risk_color = "🟢"
        risk_class = "risk-low"
    
    # Risk overview
    col1, col2, col3 = st.columns([1, 1, 2])
    
    with col1:
        st.markdown(f"""
        <div style="text-align: center; padding: 2rem; background: #f8f9fa; border-radius: 10px;">
            <div style="font-size: 4rem;">{risk_color}</div>
            <div class="{risk_class}" style="font-size: 1.5rem;">{risk_level} RISK</div>
            <div style="font-size: 1.2rem; margin-top: 0.5rem;">Score: {churn_risk:.2f}</div>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        st.metric("Satisfaction Score", f"{customer['satisfaction_score']}/10")
        st.metric("Tenure (Months)", customer['tenure_months'])
        st.metric("Account Type", customer['account_type'])
    
    with col3:
        # Risk factors analysis
        st.markdown("### 🎯 Risk Factors")
        
        risk_factors = []
        if customer['satisfaction_score'] <= 5:
            risk_factors.append("❌ Low satisfaction score")
        if customer['tenure_months'] < 6:
            risk_factors.append("❌ New customer (< 6 months)")
        
        # Check recent support tickets
        recent_support = support_df[(support_df['customer_id'] == customer_id) & 
                                   (support_df['date'] >= (dt.datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d'))]
        if len(recent_support) > 3:
            risk_factors.append("❌ High support ticket volume")
        
        # Check payment history
        late_payments = len(billing_df[(billing_df['customer_id'] == customer_id) & 
                                      (billing_df['payment_status'] == 'Late')])
        if late_payments > 2:
            risk_factors.append("❌ Multiple late payments")
        
        if not risk_factors:
            risk_factors = ["✅ No major risk factors identified"]
        
        for factor in risk_factors:
            st.markdown(factor)
    
    # Churn prevention recommendations
    st.markdown("### 🎯 Retention Recommendations")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("#### 💡 Immediate Actions")
        if churn_risk >= 0.7:
            actions = [
                "📞 Schedule urgent retention call",
                "🎁 Offer loyalty discount (10-15%)",
                "📋 Address outstanding support issues",
                "🎯 Propose service upgrade with benefits"
            ]
        elif churn_risk >= 0.4:
            actions = [
                "📧 Send personalized engagement email",
                "🎯 Offer relevant service add-ons",
                "📊 Share usage insights and benefits",
                "❓ Conduct satisfaction survey"
            ]
        else:
            actions = [
                "✅ Continue regular engagement",
                "🎯 Monitor for usage pattern changes",
                "💬 Quarterly check-in call",
                "🆙 Explore upsell opportunities"
            ]
        
        for action in actions:
            st.markdown(f"- {action}")
    
    with col2:
        st.markdown("#### 📈 Long-term Strategy")
        strategies = [
            "🎓 Provide customer education resources",
            "🔄 Regular service optimization reviews",
            "🏆 Implement loyalty program benefits",
            "📱 Proactive technology updates",
            "👥 Assign dedicated account manager",
            "📊 Monitor satisfaction trends"
        ]
        
        for strategy in strategies:
            st.markdown(f"- {strategy}")

def show_customer_journey(customers_df, support_df, customer_id):
    """Customer Journey page"""
    
    st.markdown('<div class="main-header">🎯 Customer Journey</div>', unsafe_allow_html=True)
    
    # Get customer and support data
    customer = customers_df[customers_df['customer_id'] == customer_id].iloc[0]
    customer_support = support_df[support_df['customer_id'] == customer_id].copy()
    customer_support['date'] = pd.to_datetime(customer_support['date'])
    customer_support = customer_support.sort_values('date', ascending=False)
    
    # Journey timeline
    st.markdown("### 📅 Customer Timeline")
    
    # Key milestones
    signup_date = pd.to_datetime(customer['signup_date'])
    today = pd.Timestamp.now()
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.markdown(f"""
        <div style="padding: 1rem; background: #e3f2fd; border-radius: 8px;">
            <h4>🎉 Customer Acquisition</h4>
            <p><strong>Date:</strong> {signup_date.strftime('%Y-%m-%d')}</p>
            <p><strong>Account Type:</strong> {customer['account_type']}</p>
            <p><strong>Initial Services:</strong> {len(customer['services'].split(','))}</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        # Find major milestones in support history
        total_tickets = len(customer_support)
        resolved_tickets = len(customer_support[customer_support['status'] == 'Resolved'])
        
        st.markdown(f"""
        <div style="padding: 1rem; background: #f3e5f5; border-radius: 8px;">
            <h4>🔧 Service Interactions</h4>
            <p><strong>Total Tickets:</strong> {total_tickets}</p>
            <p><strong>Resolved:</strong> {resolved_tickets}</p>
            <p><strong>Resolution Rate:</strong> {(resolved_tickets/total_tickets*100 if total_tickets > 0 else 0):.1f}%</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col3:
        tenure_days = (today - signup_date).days
        st.markdown(f"""
        <div style="padding: 1rem; background: #e8f5e8; border-radius: 8px;">
            <h4>📊 Current Status</h4>
            <p><strong>Tenure:</strong> {tenure_days} days</p>
            <p><strong>Satisfaction:</strong> {customer['satisfaction_score']}/10</p>
            <p><strong>Churn Risk:</strong> {customer['churn_risk_score']:.2f}</p>
        </div>
        """, unsafe_allow_html=True)
    
    # Support interaction history
    st.markdown("### 🎫 Support Interaction History")
    
    if not customer_support.empty:
        # Support trends
        col1, col2 = st.columns(2)
        
        with col1:
            # Support tickets over time
            customer_support['month'] = customer_support['date'].dt.to_period('M')
            monthly_tickets = customer_support.groupby('month').size()
            
            fig_tickets = px.bar(x=[str(m) for m in monthly_tickets.index], 
                               y=monthly_tickets.values,
                               title='Support Tickets by Month')
            fig_tickets.update_layout(height=300)
            st.plotly_chart(fig_tickets, use_container_width=True)
        
        with col2:
            # Ticket types breakdown
            type_counts = customer_support['type'].value_counts()
            fig_types = px.pie(values=type_counts.values, names=type_counts.index,
                              title='Support Ticket Types')
            fig_types.update_layout(height=300)
            st.plotly_chart(fig_types, use_container_width=True)
        
        # Recent tickets table
        st.markdown("#### Recent Support Tickets")
        recent_tickets = customer_support.head(10)[['date', 'ticket_id', 'type', 'priority', 'status', 'resolution_hours']]
        recent_tickets['date'] = recent_tickets['date'].dt.strftime('%Y-%m-%d')
        st.dataframe(recent_tickets, use_container_width=True)
    else:
        st.info("No support interactions found for this customer.")
    
    # Journey insights
    st.markdown("### 💡 Journey Insights")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("#### Positive Indicators")
        positive = [
            f"✅ {customer['tenure_months']} months of loyalty",
            f"✅ {customer['satisfaction_score']}/10 satisfaction score",
            f"✅ {len(customer['services'].split(','))} active services"
        ]
        
        if customer['churn_risk_score'] < 0.4:
            positive.append("✅ Low churn risk")
        
        for item in positive:
            st.markdown(item)
    
    with col2:
        st.markdown("#### Areas for Attention")
        attention = []
        
        if customer['satisfaction_score'] <= 6:
            attention.append("⚠️ Satisfaction score could be improved")
        
        if len(customer_support[customer_support['status'] != 'Resolved']) > 0:
            attention.append("⚠️ Has open support tickets")
        
        if customer['churn_risk_score'] >= 0.4:
            attention.append("⚠️ Elevated churn risk")
        
        if not attention:
            attention = ["✅ No major concerns identified"]
        
        for item in attention:
            st.markdown(item)

def show_sales_opportunities(customers_df, usage_df, billing_df, customer_id):
    """Sales Opportunities page"""
    
    st.markdown('<div class="main-header">📈 Sales Opportunities</div>', unsafe_allow_html=True)
    
    # Get customer data
    customer = customers_df[customers_df['customer_id'] == customer_id].iloc[0]
    customer_usage = usage_df[usage_df['customer_id'] == customer_id]
    customer_billing = billing_df[billing_df['customer_id'] == customer_id]
    
    # Opportunity scoring
    st.markdown("### 🎯 Opportunity Assessment")
    
    current_services = set(service.strip() for service in customer['services'].split(','))
    all_services = {'Mobile', 'Internet', 'TV', 'Phone', 'Security', 'Cloud', 'IoT'}
    missing_services = all_services - current_services
    
    # Calculate opportunity scores
    opportunities = []
    
    # Service expansion opportunities
    for service in missing_services:
        score = random.uniform(0.3, 0.9)  # Simplified scoring
        
        # Adjust score based on customer profile
        if customer['account_type'] == 'Enterprise' and service in ['Security', 'Cloud', 'IoT']:
            score += 0.2
        elif customer['account_type'] == 'Family' and service in ['TV', 'Security']:
            score += 0.15
        
        opportunities.append({
            'type': 'Service Addition',
            'service': service,
            'opportunity': f"Add {service} Service",
            'score': min(1.0, score),
            'potential_revenue': random.uniform(25, 150),
            'reasoning': f"Customer profile suggests good fit for {service}"
        })
    
    # Usage-based opportunities
    if not customer_usage.empty:
        avg_data_usage = customer_usage['data_usage_gb'].mean()
        
        if avg_data_usage > 20:  # High data usage
            opportunities.append({
                'type': 'Plan Upgrade',
                'service': 'Data Plan',
                'opportunity': 'Unlimited Data Plan',
                'score': 0.8,
                'potential_revenue': 35,
                'reasoning': f'High data usage ({avg_data_usage:.1f}GB avg) suggests need for unlimited plan'
            })
        
        if customer['account_type'] in ['Business', 'Enterprise']:
            opportunities.append({
                'type': 'Service Upgrade',
                'service': 'Priority Support',
                'opportunity': 'Premium Support Package',
                'score': 0.7,
                'potential_revenue': 75,
                'reasoning': 'Business customers benefit from priority support'
            })
    
    # Display opportunities
    opportunities.sort(key=lambda x: x['score'], reverse=True)
    
    col1, col2 = st.columns([2, 1])
    
    with col1:
        st.markdown("#### 🚀 Top Opportunities")
        
        for i, opp in enumerate(opportunities[:5]):
            score_color = "#28a745" if opp['score'] >= 0.7 else "#ffc107" if opp['score'] >= 0.5 else "#dc3545"
            
            st.markdown(f"""
            <div style="border: 1px solid #dee2e6; border-radius: 8px; padding: 1rem; margin: 0.5rem 0; background: #f8f9fa;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <h4 style="margin: 0; color: #333;">{opp['opportunity']}</h4>
                    <span style="background: {score_color}; color: white; padding: 0.25rem 0.5rem; border-radius: 4px; font-weight: bold;">
                        {opp['score']:.2f}
                    </span>
                </div>
                <p style="margin: 0.5rem 0; color: #666;"><strong>Type:</strong> {opp['type']} | <strong>Service:</strong> {opp['service']}</p>
                <p style="margin: 0.5rem 0; color: #666;"><strong>Potential Revenue:</strong> +${opp['potential_revenue']:.2f}/month</p>
                <p style="margin: 0; color: #666;"><em>{opp['reasoning']}</em></p>
            </div>
            """, unsafe_allow_html=True)
    
    with col2:
        # Opportunity summary
        total_potential = sum(opp['potential_revenue'] for opp in opportunities)
        high_score_opps = len([opp for opp in opportunities if opp['score'] >= 0.7])
        
        st.metric("Total Opportunities", len(opportunities))
        st.metric("High-Score Opportunities", high_score_opps)
        st.metric("Potential Monthly Revenue", f"${total_potential:.2f}")
        
        # Current revenue for comparison
        if not customer_billing.empty:
            current_revenue = customer_billing['amount'].mean()
            potential_increase = (total_potential / current_revenue) * 100 if current_revenue > 0 else 0
            st.metric("Potential Increase", f"{potential_increase:.1f}%")
    
    # Next best actions
    st.markdown("### 📋 Recommended Next Actions")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("#### 📞 Immediate Actions")
        actions = [
            f"🎯 Focus on {opportunities[0]['opportunity']} (highest score)",
            "📊 Prepare usage analysis to support recommendations",
            "💰 Calculate custom pricing for service bundle",
            "📅 Schedule consultative sales call"
        ]
        
        for action in actions:
            st.markdown(f"- {action}")
    
    with col2:
        st.markdown("#### 📈 Follow-up Strategy")
        strategy = [
            "📧 Send personalized proposal within 48 hours",
            "🎁 Prepare limited-time promotional offers",
            "📋 Schedule follow-up in 1 week if no response",
            "🔄 Review and update opportunities monthly"
        ]
        
        for item in strategy:
            st.markdown(f"- {item}")

if __name__ == "__main__":
    main() 