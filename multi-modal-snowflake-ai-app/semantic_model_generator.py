#!/usr/bin/env python3
"""
Semantic Model Generator for Cortex Analyst
==========================================
Generates YAML semantic models for Snowflake Cortex Analyst.

This module creates semantic models that define:
- Logical tables and their relationships
- Metrics and dimensions
- Verified queries for common business questions
"""

import os
import yaml
from typing import Dict, Any, List
from datetime import datetime

class SemanticModelGenerator:
    """Generates semantic models for Cortex Analyst"""
    
    def __init__(self):
        self.base_metrics = self._define_base_metrics()
        self.base_dimensions = self._define_base_dimensions()
    
    def generate_semantic_model(self, client_info: Dict[str, Any], output_dir: str = "output") -> str:
        """Generate a complete semantic model for the client"""
        
        company_name = client_info['name']
        website_info = client_info['website_info']
        industry = website_info['industry']
        
        # Import industry template
        from demo_generator import DemoGenerator
        generator = DemoGenerator()
        template = generator.industry_templates[industry]
        sample_data = generator.generate_sample_data(industry, company_name)
        
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        # Generate database name
        db_name = generator.generate_database_name(company_name)
        
        # Build semantic model
        semantic_model = self._build_semantic_model(
            company_name, db_name, template, sample_data
        )
        
        # Write to file
        filename = f"{company_name.lower().replace(' ', '_')}_semantic_model.yaml"
        filepath = os.path.join(output_dir, filename)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            yaml.dump(semantic_model, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
        
        return filepath
    
    def _build_semantic_model(self, company_name: str, db_name: str, template: Dict[str, Any], sample_data: Dict[str, Any]) -> Dict[str, Any]:
        """Build the complete semantic model structure"""
        
        # Build logical tables
        logical_tables = self._build_logical_tables(db_name, template, sample_data)
        
        # Build metrics
        metrics = self._build_metrics(template, sample_data)
        
        # Build relationships
        relationships = self._build_relationships()
        
        # Build verified queries
        verified_queries = self._build_verified_queries(company_name, template, sample_data)
        
        # Assemble complete model
        semantic_model = {
            'semantic_model': {
                'name': f'{company_name.replace(" ", "_")}_Analytics',
                'description': f'Semantic model for {company_name} {template["name"]} analytics',
                'logical_tables': logical_tables,
                'metrics': metrics,
                'relationships': relationships,
                'verified_queries': verified_queries
            }
        }
        
        return semantic_model
    
    def _build_logical_tables(self, db_name: str, template: Dict[str, Any], sample_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Build logical tables configuration"""
        
        tables = []
        
        # Transactions fact table
        transactions_table = {
            'name': 'transactions',
            'description': 'Main transaction facts table',
            'base_table': {
                'name': f'{db_name}.ANALYTICS.TRANSACTIONS',
                'columns': [
                    {'name': 'transaction_id', 'data_type': 'varchar', 'description': 'Unique transaction identifier'},
                    {'name': 'customer_id', 'data_type': 'varchar', 'description': 'Customer identifier'},
                    {'name': 'product_id', 'data_type': 'varchar', 'description': 'Product identifier'},
                    {'name': 'transaction_date', 'data_type': 'timestamp', 'description': 'Transaction timestamp'},
                    {'name': 'quantity', 'data_type': 'number', 'description': 'Quantity purchased'},
                    {'name': 'unit_price', 'data_type': 'number', 'description': 'Unit price'},
                    {'name': 'total_amount', 'data_type': 'number', 'description': 'Total amount before discounts'},
                    {'name': 'discount_amount', 'data_type': 'number', 'description': 'Discount applied'},
                    {'name': 'final_amount', 'data_type': 'number', 'description': 'Final amount after discounts'},
                    {'name': 'payment_method', 'data_type': 'varchar', 'description': 'Payment method used'},
                    {'name': 'status', 'data_type': 'varchar', 'description': 'Transaction status'},
                    {'name': 'channel', 'data_type': 'varchar', 'description': 'Sales channel'},
                    {'name': 'region', 'data_type': 'varchar', 'description': 'Transaction region'}
                ]
            },
            'dimensions': [
                {'name': 'transaction_date', 'type': 'time'},
                {'name': 'payment_method', 'type': 'categorical'},
                {'name': 'status', 'type': 'categorical'},
                {'name': 'channel', 'type': 'categorical'},
                {'name': 'region', 'type': 'categorical'}
            ]
        }
        tables.append(transactions_table)
        
        # Products dimension table
        products_table = {
            'name': 'products',
            'description': 'Product information',
            'base_table': {
                'name': f'{db_name}.ANALYTICS.PRODUCTS',
                'columns': [
                    {'name': 'product_id', 'data_type': 'varchar', 'description': 'Product identifier'},
                    {'name': 'product_name', 'data_type': 'varchar', 'description': 'Product name'},
                    {'name': 'category_id', 'data_type': 'varchar', 'description': 'Category identifier'},
                    {'name': 'description', 'data_type': 'varchar', 'description': 'Product description'},
                    {'name': 'unit_price', 'data_type': 'number', 'description': 'Product unit price'},
                    {'name': 'cost_price', 'data_type': 'number', 'description': 'Product cost price'},
                    {'name': 'is_active', 'data_type': 'boolean', 'description': 'Product active status'}
                ]
            },
            'dimensions': [
                {'name': 'product_name', 'type': 'categorical'},
                {'name': 'is_active', 'type': 'categorical'}
            ]
        }
        tables.append(products_table)
        
        # Categories dimension table
        categories_table = {
            'name': 'categories',
            'description': 'Product categories',
            'base_table': {
                'name': f'{db_name}.ANALYTICS.CATEGORIES',
                'columns': [
                    {'name': 'category_id', 'data_type': 'varchar', 'description': 'Category identifier'},
                    {'name': 'category_name', 'data_type': 'varchar', 'description': 'Category name'},
                    {'name': 'description', 'data_type': 'varchar', 'description': 'Category description'},
                    {'name': 'parent_category_id', 'data_type': 'varchar', 'description': 'Parent category'},
                    {'name': 'is_active', 'data_type': 'boolean', 'description': 'Category active status'}
                ]
            },
            'dimensions': [
                {'name': 'category_name', 'type': 'categorical'},
                {'name': 'is_active', 'type': 'categorical'}
            ]
        }
        tables.append(categories_table)
        
        # Customers dimension table
        customers_table = {
            'name': 'customers',
            'description': 'Customer information',
            'base_table': {
                'name': f'{db_name}.ANALYTICS.CUSTOMERS',
                'columns': [
                    {'name': 'customer_id', 'data_type': 'varchar', 'description': 'Customer identifier'},
                    {'name': 'customer_name', 'data_type': 'varchar', 'description': 'Customer name'},
                    {'name': 'email', 'data_type': 'varchar', 'description': 'Customer email'},
                    {'name': 'segment_id', 'data_type': 'varchar', 'description': 'Customer segment'},
                    {'name': 'registration_date', 'data_type': 'date', 'description': 'Registration date'},
                    {'name': 'last_purchase_date', 'data_type': 'date', 'description': 'Last purchase date'},
                    {'name': 'total_purchases', 'data_type': 'number', 'description': 'Total purchase amount'},
                    {'name': 'region', 'data_type': 'varchar', 'description': 'Customer region'},
                    {'name': 'country', 'data_type': 'varchar', 'description': 'Customer country'}
                ]
            },
            'dimensions': [
                {'name': 'customer_name', 'type': 'categorical'},
                {'name': 'registration_date', 'type': 'time'},
                {'name': 'region', 'type': 'categorical'},
                {'name': 'country', 'type': 'categorical'}
            ]
        }
        tables.append(customers_table)
        
        # Customer segments dimension table
        segments_table = {
            'name': 'customer_segments',
            'description': 'Customer segments',
            'base_table': {
                'name': f'{db_name}.ANALYTICS.CUSTOMER_SEGMENTS',
                'columns': [
                    {'name': 'segment_id', 'data_type': 'varchar', 'description': 'Segment identifier'},
                    {'name': 'segment_name', 'data_type': 'varchar', 'description': 'Segment name'},
                    {'name': 'description', 'data_type': 'varchar', 'description': 'Segment description'}
                ]
            },
            'dimensions': [
                {'name': 'segment_name', 'type': 'categorical'}
            ]
        }
        tables.append(segments_table)
        
        return tables
    
    def _build_metrics(self, template: Dict[str, Any], sample_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Build metrics configuration"""
        
        metrics = []
        
        # Revenue metrics
        revenue_metric = {
            'name': 'total_revenue',
            'description': 'Total revenue from completed transactions',
            'type': 'sum',
            'sql': 'final_amount',
            'table': 'transactions',
            'filters': [
                {'column': 'status', 'operator': '=', 'value': 'COMPLETED'}
            ]
        }
        metrics.append(revenue_metric)
        
        # Transaction count
        transaction_count = {
            'name': 'transaction_count',
            'description': 'Number of transactions',
            'type': 'count',
            'sql': 'transaction_id',
            'table': 'transactions',
            'filters': [
                {'column': 'status', 'operator': '=', 'value': 'COMPLETED'}
            ]
        }
        metrics.append(transaction_count)
        
        # Average transaction value
        avg_transaction = {
            'name': 'average_transaction_value',
            'description': 'Average transaction value',
            'type': 'avg',
            'sql': 'final_amount',
            'table': 'transactions',
            'filters': [
                {'column': 'status', 'operator': '=', 'value': 'COMPLETED'}
            ]
        }
        metrics.append(avg_transaction)
        
        # Unique customers
        unique_customers = {
            'name': 'unique_customers',
            'description': 'Number of unique customers',
            'type': 'count_distinct',
            'sql': 'customer_id',
            'table': 'transactions',
            'filters': [
                {'column': 'status', 'operator': '=', 'value': 'COMPLETED'}
            ]
        }
        metrics.append(unique_customers)
        
        # Total quantity sold
        total_quantity = {
            'name': 'total_quantity',
            'description': 'Total quantity sold',
            'type': 'sum',
            'sql': 'quantity',
            'table': 'transactions',
            'filters': [
                {'column': 'status', 'operator': '=', 'value': 'COMPLETED'}
            ]
        }
        metrics.append(total_quantity)
        
        # Discount amount
        total_discounts = {
            'name': 'total_discounts',
            'description': 'Total discount amount given',
            'type': 'sum',
            'sql': 'discount_amount',
            'table': 'transactions',
            'filters': [
                {'column': 'status', 'operator': '=', 'value': 'COMPLETED'}
            ]
        }
        metrics.append(total_discounts)
        
        # Customer lifetime value
        customer_ltv = {
            'name': 'customer_lifetime_value',
            'description': 'Customer lifetime value',
            'type': 'avg',
            'sql': 'total_purchases',
            'table': 'customers'
        }
        metrics.append(customer_ltv)
        
        # Products sold
        products_sold = {
            'name': 'products_sold',
            'description': 'Number of different products sold',
            'type': 'count_distinct',
            'sql': 'product_id',
            'table': 'transactions',
            'filters': [
                {'column': 'status', 'operator': '=', 'value': 'COMPLETED'}
            ]
        }
        metrics.append(products_sold)
        
        return metrics
    
    def _build_relationships(self) -> List[Dict[str, Any]]:
        """Build table relationships"""
        
        relationships = []
        
        # Transactions to Customers
        trans_customer_rel = {
            'name': 'transactions_to_customers',
            'type': 'many_to_one',
            'from_table': 'transactions',
            'from_column': 'customer_id',
            'to_table': 'customers',
            'to_column': 'customer_id'
        }
        relationships.append(trans_customer_rel)
        
        # Transactions to Products
        trans_product_rel = {
            'name': 'transactions_to_products',
            'type': 'many_to_one',
            'from_table': 'transactions',
            'from_column': 'product_id',
            'to_table': 'products',
            'to_column': 'product_id'
        }
        relationships.append(trans_product_rel)
        
        # Products to Categories
        product_category_rel = {
            'name': 'products_to_categories',
            'type': 'many_to_one',
            'from_table': 'products',
            'from_column': 'category_id',
            'to_table': 'categories',
            'to_column': 'category_id'
        }
        relationships.append(product_category_rel)
        
        # Customers to Segments
        customer_segment_rel = {
            'name': 'customers_to_segments',
            'type': 'many_to_one',
            'from_table': 'customers',
            'from_column': 'segment_id',
            'to_table': 'customer_segments',
            'to_column': 'segment_id'
        }
        relationships.append(customer_segment_rel)
        
        return relationships
    
    def _build_verified_queries(self, company_name: str, template: Dict[str, Any], sample_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Build verified queries for common business questions"""
        
        queries = []
        
        # Monthly revenue trend
        monthly_revenue = {
            'name': 'monthly_revenue_trend',
            'question': 'What is our monthly revenue trend?',
            'use_as_onboarding_question': True,
            'sql': '''SELECT 
    DATE_TRUNC('MONTH', transaction_date) AS month,
    SUM(final_amount) AS total_revenue,
    COUNT(*) AS transaction_count,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM transactions 
WHERE status = 'COMPLETED'
    AND transaction_date >= DATEADD('MONTH', -12, CURRENT_DATE())
GROUP BY DATE_TRUNC('MONTH', transaction_date)
ORDER BY month''',
            'verified_by': 'System',
            'verified_at': datetime.now().isoformat()
        }
        queries.append(monthly_revenue)
        
        # Top categories by revenue
        top_categories = {
            'name': 'top_categories_by_revenue',
            'question': 'Which product categories generate the most revenue?',
            'use_as_onboarding_question': True,
            'sql': '''SELECT 
    c.category_name,
    SUM(t.final_amount) AS total_revenue,
    COUNT(t.transaction_id) AS transaction_count,
    AVG(t.final_amount) AS avg_transaction_value
FROM transactions t
JOIN products p ON t.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE t.status = 'COMPLETED'
    AND t.transaction_date >= DATEADD('QUARTER', -4, CURRENT_DATE())
GROUP BY c.category_name
ORDER BY total_revenue DESC''',
            'verified_by': 'System',
            'verified_at': datetime.now().isoformat()
        }
        queries.append(top_categories)
        
        # Customer segment analysis
        segment_analysis = {
            'name': 'customer_segment_performance',
            'question': 'How do different customer segments perform?',
            'use_as_onboarding_question': True,
            'sql': '''SELECT 
    cs.segment_name,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(t.final_amount) AS total_revenue,
    AVG(t.final_amount) AS avg_transaction_value,
    COUNT(t.transaction_id) AS total_transactions
FROM customer_segments cs
JOIN customers c ON cs.segment_id = c.segment_id
JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.status = 'COMPLETED'
    AND t.transaction_date >= DATEADD('QUARTER', -2, CURRENT_DATE())
GROUP BY cs.segment_name
ORDER BY total_revenue DESC''',
            'verified_by': 'System',
            'verified_at': datetime.now().isoformat()
        }
        queries.append(segment_analysis)
        
        # Regional performance
        regional_performance = {
            'name': 'regional_performance_analysis',
            'question': 'How are we performing across different regions?',
            'use_as_onboarding_question': False,
            'sql': '''SELECT 
    t.region,
    SUM(t.final_amount) AS total_revenue,
    COUNT(t.transaction_id) AS transaction_count,
    COUNT(DISTINCT t.customer_id) AS unique_customers,
    AVG(t.final_amount) AS avg_transaction_value
FROM transactions t
WHERE t.status = 'COMPLETED'
    AND t.transaction_date >= DATEADD('MONTH', -6, CURRENT_DATE())
GROUP BY t.region
ORDER BY total_revenue DESC''',
            'verified_by': 'System',
            'verified_at': datetime.now().isoformat()
        }
        queries.append(regional_performance)
        
        # Channel effectiveness
        channel_analysis = {
            'name': 'sales_channel_effectiveness',
            'question': 'Which sales channels are most effective?',
            'use_as_onboarding_question': False,
            'sql': '''SELECT 
    channel,
    COUNT(*) AS transaction_count,
    SUM(final_amount) AS total_revenue,
    AVG(final_amount) AS avg_transaction_value,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(discount_amount) AS total_discounts
FROM transactions
WHERE status = 'COMPLETED'
    AND transaction_date >= DATEADD('QUARTER', -2, CURRENT_DATE())
GROUP BY channel
ORDER BY total_revenue DESC''',
            'verified_by': 'System',
            'verified_at': datetime.now().isoformat()
        }
        queries.append(channel_analysis)
        
        # Customer acquisition trends
        acquisition_trends = {
            'name': 'customer_acquisition_trends',
            'question': 'What are our customer acquisition trends?',
            'use_as_onboarding_question': False,
            'sql': '''SELECT 
    DATE_TRUNC('MONTH', registration_date) AS month,
    COUNT(*) AS new_customers,
    AVG(total_purchases) AS avg_customer_value,
    COUNT(CASE WHEN region = 'CDMX' THEN 1 END) AS cdmx_customers,
    COUNT(CASE WHEN region != 'CDMX' THEN 1 END) AS other_regions
FROM customers
WHERE registration_date >= DATEADD('YEAR', -1, CURRENT_DATE())
GROUP BY DATE_TRUNC('MONTH', registration_date)
ORDER BY month''',
            'verified_by': 'System',
            'verified_at': datetime.now().isoformat()
        }
        queries.append(acquisition_trends)
        
        return queries
    
    def _define_base_metrics(self) -> List[str]:
        """Define common metrics across industries"""
        return [
            'revenue',
            'transactions',
            'customers',
            'growth_rate',
            'satisfaction',
            'performance'
        ]
    
    def _define_base_dimensions(self) -> List[str]:
        """Define common dimensions across industries"""
        return [
            'time',
            'geography',
            'category',
            'segment',
            'channel'
        ]




