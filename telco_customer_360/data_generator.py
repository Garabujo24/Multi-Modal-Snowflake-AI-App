import pandas as pd
import numpy as np
import datetime as dt
from datetime import timedelta
import random
from faker import Faker

fake = Faker()
np.random.seed(42)
random.seed(42)

def generate_customer_data(num_customers=1000):
    """Generate realistic customer data"""
    
    customers = []
    
    for i in range(num_customers):
        customer_id = f"CUST{str(i+1).zfill(6)}"
        
        # Basic demographics
        name = fake.name()
        email = fake.email()
        phone = fake.phone_number()
        address = fake.street_address()
        city = fake.city()
        state = fake.state_abbr()
        zip_code = fake.zipcode()
        
        # Account details
        account_types = ['Individual', 'Family', 'Business', 'Enterprise']
        account_type = np.random.choice(account_types, p=[0.4, 0.35, 0.2, 0.05])
        
        # Services (more likely to have multiple services for higher tier accounts)
        all_services = ['Mobile', 'Internet', 'TV', 'Phone', 'Security', 'Cloud', 'IoT']
        if account_type == 'Individual':
            num_services = np.random.choice([1, 2, 3], p=[0.5, 0.3, 0.2])
        elif account_type == 'Family':
            num_services = np.random.choice([2, 3, 4], p=[0.3, 0.4, 0.3])
        elif account_type == 'Business':
            num_services = np.random.choice([3, 4, 5], p=[0.3, 0.4, 0.3])
        else:  # Enterprise
            num_services = np.random.choice([4, 5, 6, 7], p=[0.2, 0.3, 0.3, 0.2])
        
        services = ','.join(np.random.choice(all_services, num_services, replace=False))
        
        # Signup date (last 5 years)
        signup_date = fake.date_between(start_date='-5y', end_date='today')
        
        # Credit score
        credit_score = np.random.normal(700, 80)
        credit_score = max(300, min(850, int(credit_score)))
        
        # Satisfaction score (1-10)
        satisfaction_score = np.random.choice(range(1, 11), p=[0.02, 0.03, 0.05, 0.08, 0.12, 0.15, 0.2, 0.15, 0.12, 0.08])
        
        # Churn risk factors
        tenure_months = (dt.datetime.now().date() - signup_date).days // 30
        
        # Calculate churn risk based on multiple factors
        churn_score = 0
        if satisfaction_score <= 5:
            churn_score += 0.3
        if tenure_months < 6:
            churn_score += 0.2
        if account_type in ['Individual', 'Family']:
            churn_score += 0.1
        
        churn_score += np.random.normal(0, 0.1)
        churn_score = max(0, min(1, churn_score))
        
        customers.append({
            'customer_id': customer_id,
            'name': name,
            'email': email,
            'phone': phone,
            'address': address,
            'city': city,
            'state': state,
            'zip_code': zip_code,
            'account_type': account_type,
            'services': services,
            'signup_date': signup_date,
            'credit_score': credit_score,
            'satisfaction_score': satisfaction_score,
            'churn_risk_score': churn_score,
            'tenure_months': tenure_months
        })
    
    return pd.DataFrame(customers)

def generate_usage_data(customers_df):
    """Generate usage data for the last 90 days"""
    
    usage_data = []
    end_date = dt.datetime.now().date()
    start_date = end_date - timedelta(days=90)
    
    for _, customer in customers_df.iterrows():
        customer_id = customer['customer_id']
        services = customer['services'].split(',')
        account_type = customer['account_type']
        
        # Generate data for each day
        current_date = start_date
        while current_date <= end_date:
            
            # Base usage patterns by account type
            if account_type == 'Individual':
                base_data_gb = np.random.normal(5, 2)
                base_call_minutes = np.random.normal(120, 40)
                base_sms = np.random.normal(50, 20)
            elif account_type == 'Family':
                base_data_gb = np.random.normal(15, 5)
                base_call_minutes = np.random.normal(300, 80)
                base_sms = np.random.normal(200, 60)
            elif account_type == 'Business':
                base_data_gb = np.random.normal(25, 8)
                base_call_minutes = np.random.normal(600, 150)
                base_sms = np.random.normal(100, 30)
            else:  # Enterprise
                base_data_gb = np.random.normal(100, 30)
                base_call_minutes = np.random.normal(1500, 300)
                base_sms = np.random.normal(500, 100)
            
            # Weekend vs weekday patterns
            if current_date.weekday() >= 5:  # Weekend
                data_usage_gb = base_data_gb * np.random.uniform(1.2, 1.8)
                call_minutes = base_call_minutes * np.random.uniform(0.6, 1.0)
            else:  # Weekday
                data_usage_gb = base_data_gb * np.random.uniform(0.8, 1.2)
                call_minutes = base_call_minutes * np.random.uniform(0.9, 1.3)
            
            # Ensure non-negative values
            data_usage_gb = max(0, data_usage_gb)
            call_minutes = max(0, call_minutes)
            sms_count = max(0, int(base_sms + np.random.normal(0, 10)))
            
            # Network quality (1-5 scale)
            network_quality = np.random.choice([1, 2, 3, 4, 5], p=[0.05, 0.1, 0.2, 0.4, 0.25])
            
            # Data roaming (occasional)
            roaming_gb = np.random.exponential(0.1) if np.random.random() < 0.05 else 0
            
            usage_data.append({
                'customer_id': customer_id,
                'date': current_date,
                'data_usage_gb': round(data_usage_gb, 2),
                'call_minutes': round(call_minutes, 0),
                'sms_count': sms_count,
                'network_quality': network_quality,
                'roaming_gb': round(roaming_gb, 2)
            })
            
            current_date += timedelta(days=1)
    
    return pd.DataFrame(usage_data)

def generate_billing_data(customers_df):
    """Generate billing data for the last 12 months"""
    
    billing_data = []
    
    for _, customer in customers_df.iterrows():
        customer_id = customer['customer_id']
        services = customer['services'].split(',')
        account_type = customer['account_type']
        
        # Base monthly charges by service
        service_costs = {
            'Mobile': 45, 'Internet': 65, 'TV': 85, 'Phone': 25,
            'Security': 35, 'Cloud': 55, 'IoT': 15
        }
        
        # Account type multipliers
        type_multipliers = {
            'Individual': 1.0, 'Family': 1.8, 'Business': 2.5, 'Enterprise': 5.0
        }
        
        base_monthly_cost = sum([service_costs.get(service.strip(), 30) for service in services])
        base_monthly_cost *= type_multipliers[account_type]
        
        # Generate last 12 months
        for month_offset in range(12):
            bill_date = (dt.datetime.now().date().replace(day=1) - timedelta(days=30*month_offset))
            
            # Add some variation to monthly bills
            monthly_variation = np.random.normal(1.0, 0.15)
            amount = base_monthly_cost * monthly_variation
            
            # Add overage charges occasionally
            if np.random.random() < 0.2:
                overage = np.random.uniform(10, 50)
                amount += overage
            
            # Payment status
            payment_status = np.random.choice(['Paid', 'Late', 'Pending'], p=[0.85, 0.1, 0.05])
            
            # Late fees
            if payment_status == 'Late':
                amount += np.random.uniform(5, 25)
            
            billing_data.append({
                'customer_id': customer_id,
                'bill_date': bill_date,
                'amount': round(amount, 2),
                'payment_status': payment_status,
                'due_date': bill_date + timedelta(days=30),
                'services_billed': len(services)
            })
    
    return pd.DataFrame(billing_data)

def generate_support_data(customers_df):
    """Generate customer support interaction data"""
    
    support_data = []
    
    for _, customer in customers_df.iterrows():
        customer_id = customer['customer_id']
        satisfaction = customer['satisfaction_score']
        
        # Number of support tickets based on satisfaction
        if satisfaction <= 3:
            avg_tickets = 8
        elif satisfaction <= 6:
            avg_tickets = 4
        else:
            avg_tickets = 1
        
        num_tickets = np.random.poisson(avg_tickets)
        
        for _ in range(num_tickets):
            # Random date in last 6 months
            ticket_date = fake.date_between(start_date='-6m', end_date='today')
            
            # Ticket types and priorities
            ticket_types = ['Billing', 'Technical', 'Service', 'Sales', 'Complaint']
            ticket_type = np.random.choice(ticket_types, p=[0.3, 0.25, 0.2, 0.15, 0.1])
            
            priorities = ['Low', 'Medium', 'High', 'Critical']
            if ticket_type == 'Complaint':
                priority = np.random.choice(priorities, p=[0.1, 0.3, 0.4, 0.2])
            else:
                priority = np.random.choice(priorities, p=[0.4, 0.35, 0.2, 0.05])
            
            # Resolution time based on priority
            if priority == 'Critical':
                resolution_hours = np.random.uniform(1, 6)
            elif priority == 'High':
                resolution_hours = np.random.uniform(4, 24)
            elif priority == 'Medium':
                resolution_hours = np.random.uniform(12, 72)
            else:
                resolution_hours = np.random.uniform(24, 168)
            
            # Status
            status = np.random.choice(['Resolved', 'Open', 'In Progress'], p=[0.8, 0.1, 0.1])
            
            support_data.append({
                'customer_id': customer_id,
                'ticket_id': f"TKT{fake.random_number(digits=8)}",
                'date': ticket_date,
                'type': ticket_type,
                'priority': priority,
                'status': status,
                'resolution_hours': round(resolution_hours, 1),
                'agent_id': f"AGT{fake.random_number(digits=4)}"
            })
    
    return pd.DataFrame(support_data) 