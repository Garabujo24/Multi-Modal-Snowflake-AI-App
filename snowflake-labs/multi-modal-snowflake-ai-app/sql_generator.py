#!/usr/bin/env python3
"""
SQL Generator for Snowflake Resources
====================================
Generates complete SQL scripts for databases, schemas, tables, and sample data.

This module creates all Snowflake resources needed for the demo including:
- Database and schema creation
- Table definitions with appropriate data types
- Sample data insertion scripts
- Warehouse and role setup
"""

import os
from typing import Dict, Any, List
from datetime import datetime, timedelta
import random
import json

class SQLGenerator:
    """Generates SQL scripts for Snowflake demo setup"""
    
    def __init__(self):
        self.sql_templates = self._load_sql_templates()
    
    def generate_complete_setup(self, client_info: Dict[str, Any], output_dir: str = "output") -> Dict[str, str]:
        """Generate complete SQL setup for the client demo"""
        
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
        
        # Generate all SQL components
        setup_sql = self._generate_setup_script(company_name, db_name, template)
        tables_sql = self._generate_tables_script(company_name, db_name, template, sample_data)
        data_sql = self._generate_sample_data_script(company_name, db_name, template, sample_data)
        views_sql = self._generate_views_script(company_name, db_name, template, sample_data)
        
        # Write files
        files_created = {}
        
        setup_file = os.path.join(output_dir, f"{db_name.lower()}_setup.sql")
        with open(setup_file, 'w', encoding='utf-8') as f:
            f.write(setup_sql)
        files_created['setup'] = setup_file
        
        tables_file = os.path.join(output_dir, f"{db_name.lower()}_tables.sql")
        with open(tables_file, 'w', encoding='utf-8') as f:
            f.write(tables_sql)
        files_created['tables'] = tables_file
        
        data_file = os.path.join(output_dir, f"{db_name.lower()}_sample_data.sql")
        with open(data_file, 'w', encoding='utf-8') as f:
            f.write(data_sql)
        files_created['data'] = data_file
        
        views_file = os.path.join(output_dir, f"{db_name.lower()}_views.sql")
        with open(views_file, 'w', encoding='utf-8') as f:
            f.write(views_sql)
        files_created['views'] = views_file
        
        return files_created
    
    def _generate_setup_script(self, company_name: str, db_name: str, template: Dict[str, Any]) -> str:
        """Generate database and schema setup script"""
        
        safe_company_name = company_name.replace("'", "''")
        warehouse_name = f"{db_name}_WH"
        role_name = f"{db_name}_ROLE"
        
        return f'''-- =====================================================
-- {safe_company_name} - Snowflake Cortex Demo Setup
-- =====================================================
-- Generated on: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
-- Industry: {template['name']}
-- Purpose: Complete Snowflake environment setup for Cortex demo

-- =====================================================
-- STEP 1: CREATE WAREHOUSE
-- =====================================================

CREATE OR REPLACE WAREHOUSE {warehouse_name}
WITH 
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
    COMMENT = 'Warehouse for {safe_company_name} Cortex Demo';

-- =====================================================
-- STEP 2: CREATE ROLE AND GRANT PERMISSIONS
-- =====================================================

CREATE OR REPLACE ROLE {role_name}
    COMMENT = 'Role for {safe_company_name} Cortex Demo users';

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE {warehouse_name} TO ROLE {role_name};
GRANT OPERATE ON WAREHOUSE {warehouse_name} TO ROLE {role_name};

-- Grant role to current user (modify as needed)
GRANT ROLE {role_name} TO USER CURRENT_USER();

-- =====================================================
-- STEP 3: CREATE DATABASE AND SCHEMAS
-- =====================================================

CREATE OR REPLACE DATABASE {db_name}
    COMMENT = '{safe_company_name} Snowflake Cortex Demo Database - {template["name"]} Industry';

-- Use the database
USE DATABASE {db_name};

-- Create main schemas
CREATE OR REPLACE SCHEMA ANALYTICS
    COMMENT = 'Main analytics schema for business data';

CREATE OR REPLACE SCHEMA CORTEX_DEMO
    COMMENT = 'Schema for Cortex AI demonstrations';

CREATE OR REPLACE SCHEMA STAGING
    COMMENT = 'Staging area for data loading and processing';

CREATE OR REPLACE SCHEMA UTILITIES
    COMMENT = 'Utility functions and procedures';

-- Grant schema permissions
GRANT USAGE ON DATABASE {db_name} TO ROLE {role_name};
GRANT USAGE ON SCHEMA {db_name}.ANALYTICS TO ROLE {role_name};
GRANT USAGE ON SCHEMA {db_name}.CORTEX_DEMO TO ROLE {role_name};
GRANT USAGE ON SCHEMA {db_name}.STAGING TO ROLE {role_name};
GRANT USAGE ON SCHEMA {db_name}.UTILITIES TO ROLE {role_name};

-- Grant table permissions (to be applied to all future tables)
GRANT CREATE TABLE ON SCHEMA {db_name}.ANALYTICS TO ROLE {role_name};
GRANT CREATE TABLE ON SCHEMA {db_name}.CORTEX_DEMO TO ROLE {role_name};
GRANT CREATE TABLE ON SCHEMA {db_name}.STAGING TO ROLE {role_name};
GRANT CREATE VIEW ON SCHEMA {db_name}.ANALYTICS TO ROLE {role_name};
GRANT CREATE VIEW ON SCHEMA {db_name}.CORTEX_DEMO TO ROLE {role_name};

-- =====================================================
-- STEP 4: CREATE FILE FORMATS
-- =====================================================

CREATE OR REPLACE FILE FORMAT {db_name}.UTILITIES.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ESCAPE = 'NONE'
    ESCAPE_UNENCLOSED_FIELD = '\\134'
    DATE_FORMAT = 'YYYY-MM-DD'
    TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
    NULL_IF = ('NULL', 'null', '', '\\N');

CREATE OR REPLACE FILE FORMAT {db_name}.UTILITIES.JSON_FORMAT
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
    COMMENT = 'JSON file format for structured data import';

-- =====================================================
-- STEP 5: CREATE STAGES FOR DATA LOADING
-- =====================================================

CREATE OR REPLACE STAGE {db_name}.STAGING.INTERNAL_STAGE
    COMMENT = 'Internal stage for data loading';

CREATE OR REPLACE STAGE {db_name}.STAGING.CORTEX_FILES
    COMMENT = 'Stage for Cortex Search documents and files';

-- =====================================================
-- STEP 6: GRANT CORTEX PERMISSIONS
-- =====================================================

-- Grant Cortex functions usage (adjust based on account setup)
GRANT USAGE ON INTEGRATION SNOWPARK_OPTIMIZED_WAREHOUSE TO ROLE {role_name};

-- Note: Additional Cortex permissions may need to be granted by ACCOUNTADMIN
-- These typically include:
-- GRANT USAGE ON CORTEX SEARCH TO ROLE {role_name};
-- GRANT USAGE ON CORTEX ANALYST TO ROLE {role_name};

-- =====================================================
-- SETUP COMPLETE
-- =====================================================

-- Use the role and warehouse for subsequent operations
USE ROLE {role_name};
USE WAREHOUSE {warehouse_name};
USE DATABASE {db_name};
USE SCHEMA ANALYTICS;

SELECT 'Setup completed successfully for {safe_company_name} Cortex Demo' AS SETUP_STATUS;

-- Next steps:
-- 1. Run the tables creation script
-- 2. Load sample data
-- 3. Create views and semantic model
-- 4. Test Cortex functions'''

    def _generate_tables_script(self, company_name: str, db_name: str, template: Dict[str, Any], sample_data: Dict[str, Any]) -> str:
        """Generate table creation script"""
        
        safe_company_name = company_name.replace("'", "''")
        categories = sample_data['categories']
        customers = sample_data['customers']
        
        return f'''-- =====================================================
-- {safe_company_name} - Tables Creation Script
-- =====================================================
-- Generated on: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
-- Industry: {template['name']}

USE DATABASE {db_name};
USE SCHEMA ANALYTICS;

-- =====================================================
-- CORE BUSINESS TABLES
-- =====================================================

-- Categories/Products table
CREATE OR REPLACE TABLE CATEGORIES (
    CATEGORY_ID VARCHAR(10) PRIMARY KEY,
    CATEGORY_NAME VARCHAR(100) NOT NULL,
    DESCRIPTION TEXT,
    PARENT_CATEGORY_ID VARCHAR(10),
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Products/Services table  
CREATE OR REPLACE TABLE PRODUCTS (
    PRODUCT_ID VARCHAR(20) PRIMARY KEY,
    PRODUCT_NAME VARCHAR(200) NOT NULL,
    CATEGORY_ID VARCHAR(10),
    DESCRIPTION TEXT,
    UNIT_PRICE DECIMAL(10,2),
    COST_PRICE DECIMAL(10,2),
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (CATEGORY_ID) REFERENCES CATEGORIES(CATEGORY_ID)
);

-- Customer segments table
CREATE OR REPLACE TABLE CUSTOMER_SEGMENTS (
    SEGMENT_ID VARCHAR(10) PRIMARY KEY,
    SEGMENT_NAME VARCHAR(100) NOT NULL,
    DESCRIPTION TEXT,
    TARGET_DEMOGRAPHICS TEXT,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Customers table
CREATE OR REPLACE TABLE CUSTOMERS (
    CUSTOMER_ID VARCHAR(20) PRIMARY KEY,
    CUSTOMER_NAME VARCHAR(200),
    EMAIL VARCHAR(255),
    PHONE VARCHAR(50),
    SEGMENT_ID VARCHAR(10),
    REGISTRATION_DATE DATE,
    LAST_PURCHASE_DATE DATE,
    TOTAL_PURCHASES DECIMAL(12,2) DEFAULT 0,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    REGION VARCHAR(100),
    COUNTRY VARCHAR(100) DEFAULT 'Mexico',
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (SEGMENT_ID) REFERENCES CUSTOMER_SEGMENTS(SEGMENT_ID)
);

-- Transactions table
CREATE OR REPLACE TABLE TRANSACTIONS (
    TRANSACTION_ID VARCHAR(30) PRIMARY KEY,
    CUSTOMER_ID VARCHAR(20),
    PRODUCT_ID VARCHAR(20),
    TRANSACTION_DATE TIMESTAMP_NTZ,
    QUANTITY INTEGER,
    UNIT_PRICE DECIMAL(10,2),
    TOTAL_AMOUNT DECIMAL(12,2),
    DISCOUNT_AMOUNT DECIMAL(10,2) DEFAULT 0,
    FINAL_AMOUNT DECIMAL(12,2),
    PAYMENT_METHOD VARCHAR(50),
    STATUS VARCHAR(20) DEFAULT 'COMPLETED',
    CHANNEL VARCHAR(50),
    REGION VARCHAR(100),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID),
    FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID)
);

-- Performance metrics table
CREATE OR REPLACE TABLE PERFORMANCE_METRICS (
    METRIC_ID VARCHAR(20) PRIMARY KEY,
    METRIC_DATE DATE,
    METRIC_NAME VARCHAR(100),
    METRIC_VALUE DECIMAL(15,2),
    METRIC_TARGET DECIMAL(15,2),
    CATEGORY VARCHAR(100),
    REGION VARCHAR(100),
    MEASUREMENT_UNIT VARCHAR(50),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =====================================================
-- SUPPORT AND FEEDBACK TABLES
-- =====================================================

-- Support tickets table
CREATE OR REPLACE TABLE SUPPORT_TICKETS (
    TICKET_ID VARCHAR(20) PRIMARY KEY,
    CUSTOMER_ID VARCHAR(20),
    SUBJECT VARCHAR(500),
    DESCRIPTION TEXT,
    PRIORITY VARCHAR(20) DEFAULT 'MEDIUM',
    STATUS VARCHAR(20) DEFAULT 'OPEN',
    CATEGORY VARCHAR(100),
    ASSIGNED_TO VARCHAR(100),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    RESOLVED_DATE TIMESTAMP_NTZ,
    SATISFACTION_RATING DECIMAL(3,1),
    FEEDBACK_TEXT TEXT,
    FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID)
);

-- Marketing campaigns table
CREATE OR REPLACE TABLE MARKETING_CAMPAIGNS (
    CAMPAIGN_ID VARCHAR(20) PRIMARY KEY,
    CAMPAIGN_NAME VARCHAR(200),
    DESCRIPTION TEXT,
    START_DATE DATE,
    END_DATE DATE,
    BUDGET DECIMAL(12,2),
    CHANNEL VARCHAR(100),
    TARGET_SEGMENT VARCHAR(100),
    IMPRESSIONS INTEGER DEFAULT 0,
    CLICKS INTEGER DEFAULT 0,
    CONVERSIONS INTEGER DEFAULT 0,
    REVENUE_GENERATED DECIMAL(12,2) DEFAULT 0,
    STATUS VARCHAR(20) DEFAULT 'ACTIVE',
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =====================================================
-- CORTEX DEMO SPECIFIC TABLES
-- =====================================================

USE SCHEMA CORTEX_DEMO;

-- Documents for Cortex Search
CREATE OR REPLACE TABLE KNOWLEDGE_BASE (
    DOCUMENT_ID VARCHAR(20) PRIMARY KEY,
    TITLE VARCHAR(500),
    CONTENT TEXT,
    DOCUMENT_TYPE VARCHAR(100),
    CATEGORY VARCHAR(100),
    AUTHOR VARCHAR(200),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    TAGS ARRAY,
    METADATA VARIANT
);

-- Customer feedback for sentiment analysis
CREATE OR REPLACE TABLE CUSTOMER_FEEDBACK (
    FEEDBACK_ID VARCHAR(20) PRIMARY KEY,
    CUSTOMER_ID VARCHAR(20),
    PRODUCT_ID VARCHAR(20),
    FEEDBACK_TEXT TEXT,
    RATING INTEGER,
    FEEDBACK_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE VARCHAR(100),
    SENTIMENT_SCORE DECIMAL(3,2),
    SENTIMENT_LABEL VARCHAR(20),
    PROCESSED_DATE TIMESTAMP_NTZ,
    KEYWORDS ARRAY,
    THEMES ARRAY
);

-- Image analysis table (for multimodal demos)
CREATE OR REPLACE TABLE PRODUCT_IMAGES (
    IMAGE_ID VARCHAR(20) PRIMARY KEY,
    PRODUCT_ID VARCHAR(20),
    IMAGE_URL VARCHAR(1000),
    IMAGE_TYPE VARCHAR(50),
    DESCRIPTION TEXT,
    AI_ANALYSIS_RESULT VARIANT,
    UPLOAD_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    ANALYSIS_DATE TIMESTAMP_NTZ,
    IS_PRIMARY BOOLEAN DEFAULT FALSE
);

-- Predictive analytics results
CREATE OR REPLACE TABLE PREDICTIONS (
    PREDICTION_ID VARCHAR(20) PRIMARY KEY,
    MODEL_NAME VARCHAR(100),
    PREDICTION_TYPE VARCHAR(100),
    INPUT_DATA VARIANT,
    PREDICTION_RESULT VARIANT,
    CONFIDENCE_SCORE DECIMAL(5,4),
    PREDICTION_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    EXPIRY_DATE TIMESTAMP_NTZ,
    MODEL_VERSION VARCHAR(50),
    FEATURES_USED ARRAY
);

-- =====================================================
-- INDEXES AND CONSTRAINTS
-- =====================================================

-- Add indexes for better query performance
USE SCHEMA ANALYTICS;

-- Indexes on frequently queried columns
CREATE INDEX IF NOT EXISTS IDX_TRANSACTIONS_DATE ON TRANSACTIONS(TRANSACTION_DATE);
CREATE INDEX IF NOT EXISTS IDX_TRANSACTIONS_CUSTOMER ON TRANSACTIONS(CUSTOMER_ID);
CREATE INDEX IF NOT EXISTS IDX_CUSTOMERS_SEGMENT ON CUSTOMERS(SEGMENT_ID);
CREATE INDEX IF NOT EXISTS IDX_SUPPORT_STATUS ON SUPPORT_TICKETS(STATUS);
CREATE INDEX IF NOT EXISTS IDX_PERFORMANCE_DATE ON PERFORMANCE_METRICS(METRIC_DATE);

-- =====================================================
-- GRANTS AND PERMISSIONS
-- =====================================================

-- Grant table access to the demo role
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA {db_name}.ANALYTICS TO ROLE {db_name}_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA {db_name}.CORTEX_DEMO TO ROLE {db_name}_ROLE;

-- Grant future table access
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA {db_name}.ANALYTICS TO ROLE {db_name}_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA {db_name}.CORTEX_DEMO TO ROLE {db_name}_ROLE;

SELECT 'Tables created successfully for {safe_company_name}' AS STATUS;

-- Next: Load sample data using the data loading script'''

    def _generate_sample_data_script(self, company_name: str, db_name: str, template: Dict[str, Any], sample_data: Dict[str, Any]) -> str:
        """Generate sample data insertion script"""
        
        safe_company_name = company_name.replace("'", "''")
        categories = sample_data['categories']
        customers = sample_data['customers']
        revenue_scale = sample_data['revenue_scale']
        
        # Generate sample data
        category_inserts = self._generate_category_data(categories)
        product_inserts = self._generate_product_data(categories)
        customer_segment_inserts = self._generate_customer_segment_data(customers)
        customer_inserts = self._generate_customer_data(customers)
        transaction_inserts = self._generate_transaction_data(revenue_scale)
        performance_inserts = self._generate_performance_data(categories)
        support_inserts = self._generate_support_data()
        knowledge_base_inserts = self._generate_knowledge_base_data(company_name, template)
        feedback_inserts = self._generate_feedback_data()
        
        return f'''-- =====================================================
-- {safe_company_name} - Sample Data Loading Script
-- =====================================================
-- Generated on: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
-- Industry: {template['name']}

USE DATABASE {db_name};
USE SCHEMA ANALYTICS;

-- =====================================================
-- CATEGORY DATA
-- =====================================================

{category_inserts}

-- =====================================================
-- PRODUCT DATA
-- =====================================================

{product_inserts}

-- =====================================================
-- CUSTOMER SEGMENT DATA
-- =====================================================

{customer_segment_inserts}

-- =====================================================
-- CUSTOMER DATA
-- =====================================================

{customer_inserts}

-- =====================================================
-- TRANSACTION DATA
-- =====================================================

{transaction_inserts}

-- =====================================================
-- PERFORMANCE METRICS DATA
-- =====================================================

{performance_inserts}

-- =====================================================
-- SUPPORT TICKETS DATA
-- =====================================================

{support_inserts}

-- =====================================================
-- CORTEX DEMO DATA
-- =====================================================

USE SCHEMA CORTEX_DEMO;

-- Knowledge Base Documents
{knowledge_base_inserts}

-- Customer Feedback
{feedback_inserts}

-- =====================================================
-- DATA VALIDATION
-- =====================================================

USE SCHEMA ANALYTICS;

SELECT 'Data Loading Summary:' AS INFO;
SELECT 'Categories: ' || COUNT(*) || ' records' AS SUMMARY FROM CATEGORIES;
SELECT 'Products: ' || COUNT(*) || ' records' AS SUMMARY FROM PRODUCTS;
SELECT 'Customer Segments: ' || COUNT(*) || ' records' AS SUMMARY FROM CUSTOMER_SEGMENTS;
SELECT 'Customers: ' || COUNT(*) || ' records' AS SUMMARY FROM CUSTOMERS;
SELECT 'Transactions: ' || COUNT(*) || ' records' AS SUMMARY FROM TRANSACTIONS;
SELECT 'Performance Metrics: ' || COUNT(*) || ' records' AS SUMMARY FROM PERFORMANCE_METRICS;
SELECT 'Support Tickets: ' || COUNT(*) || ' records' AS SUMMARY FROM SUPPORT_TICKETS;

USE SCHEMA CORTEX_DEMO;
SELECT 'Knowledge Base: ' || COUNT(*) || ' records' AS SUMMARY FROM KNOWLEDGE_BASE;
SELECT 'Customer Feedback: ' || COUNT(*) || ' records' AS SUMMARY FROM CUSTOMER_FEEDBACK;

SELECT 'Sample data loaded successfully for {safe_company_name}' AS STATUS;'''

    def _generate_views_script(self, company_name: str, db_name: str, template: Dict[str, Any], sample_data: Dict[str, Any]) -> str:
        """Generate analytical views for the semantic model"""
        
        safe_company_name = company_name.replace("'", "''")
        
        return f'''-- =====================================================
-- {safe_company_name} - Analytical Views Creation
-- =====================================================
-- Generated on: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
-- Industry: {template['name']}

USE DATABASE {db_name};
USE SCHEMA ANALYTICS;

-- =====================================================
-- PERFORMANCE SUMMARY VIEWS
-- =====================================================

-- Monthly performance summary
CREATE OR REPLACE VIEW V_MONTHLY_PERFORMANCE AS
SELECT 
    DATE_TRUNC('MONTH', TRANSACTION_DATE) AS MONTH,
    COUNT(*) AS TOTAL_TRANSACTIONS,
    COUNT(DISTINCT CUSTOMER_ID) AS UNIQUE_CUSTOMERS,
    SUM(FINAL_AMOUNT) AS TOTAL_REVENUE,
    AVG(FINAL_AMOUNT) AS AVG_TRANSACTION_VALUE,
    SUM(QUANTITY) AS TOTAL_QUANTITY,
    COUNT(DISTINCT PRODUCT_ID) AS PRODUCTS_SOLD
FROM TRANSACTIONS 
WHERE STATUS = 'COMPLETED'
GROUP BY DATE_TRUNC('MONTH', TRANSACTION_DATE)
ORDER BY MONTH;

-- Category performance view
CREATE OR REPLACE VIEW V_CATEGORY_PERFORMANCE AS
SELECT 
    c.CATEGORY_NAME,
    c.CATEGORY_ID,
    COUNT(DISTINCT p.PRODUCT_ID) AS TOTAL_PRODUCTS,
    COUNT(t.TRANSACTION_ID) AS TOTAL_TRANSACTIONS,
    SUM(t.FINAL_AMOUNT) AS TOTAL_REVENUE,
    AVG(t.FINAL_AMOUNT) AS AVG_TRANSACTION_VALUE,
    SUM(t.QUANTITY) AS TOTAL_QUANTITY
FROM CATEGORIES c
LEFT JOIN PRODUCTS p ON c.CATEGORY_ID = p.CATEGORY_ID
LEFT JOIN TRANSACTIONS t ON p.PRODUCT_ID = t.PRODUCT_ID 
    AND t.STATUS = 'COMPLETED'
GROUP BY c.CATEGORY_ID, c.CATEGORY_NAME
ORDER BY TOTAL_REVENUE DESC;

-- Customer segment analysis
CREATE OR REPLACE VIEW V_CUSTOMER_SEGMENT_ANALYSIS AS
SELECT 
    cs.SEGMENT_NAME,
    cs.SEGMENT_ID,
    COUNT(DISTINCT c.CUSTOMER_ID) AS TOTAL_CUSTOMERS,
    COUNT(t.TRANSACTION_ID) AS TOTAL_TRANSACTIONS,
    SUM(t.FINAL_AMOUNT) AS TOTAL_REVENUE,
    AVG(t.FINAL_AMOUNT) AS AVG_TRANSACTION_VALUE,
    SUM(t.FINAL_AMOUNT) / COUNT(DISTINCT c.CUSTOMER_ID) AS REVENUE_PER_CUSTOMER,
    AVG(CASE WHEN t.TRANSACTION_DATE >= DATEADD('DAY', -90, CURRENT_DATE()) THEN 1 ELSE 0 END) AS ACTIVITY_RATE_90D
FROM CUSTOMER_SEGMENTS cs
LEFT JOIN CUSTOMERS c ON cs.SEGMENT_ID = c.SEGMENT_ID
LEFT JOIN TRANSACTIONS t ON c.CUSTOMER_ID = t.CUSTOMER_ID 
    AND t.STATUS = 'COMPLETED'
GROUP BY cs.SEGMENT_ID, cs.SEGMENT_NAME
ORDER BY TOTAL_REVENUE DESC;

-- =====================================================
-- OPERATIONAL VIEWS
-- =====================================================

-- Support ticket summary
CREATE OR REPLACE VIEW V_SUPPORT_SUMMARY AS
SELECT 
    DATE_TRUNC('MONTH', CREATED_DATE) AS MONTH,
    PRIORITY,
    STATUS,
    COUNT(*) AS TICKET_COUNT,
    AVG(SATISFACTION_RATING) AS AVG_SATISFACTION,
    AVG(DATEDIFF('HOUR', CREATED_DATE, RESOLVED_DATE)) AS AVG_RESOLUTION_HOURS
FROM SUPPORT_TICKETS
GROUP BY DATE_TRUNC('MONTH', CREATED_DATE), PRIORITY, STATUS
ORDER BY MONTH DESC, PRIORITY;

-- Customer churn risk analysis
CREATE OR REPLACE VIEW V_CUSTOMER_CHURN_RISK AS
SELECT 
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME,
    c.SEGMENT_ID,
    cs.SEGMENT_NAME,
    c.REGISTRATION_DATE,
    c.LAST_PURCHASE_DATE,
    DATEDIFF('DAY', c.LAST_PURCHASE_DATE, CURRENT_DATE()) AS DAYS_SINCE_LAST_PURCHASE,
    c.TOTAL_PURCHASES,
    COUNT(t.TRANSACTION_ID) AS TRANSACTION_COUNT_6M,
    SUM(t.FINAL_AMOUNT) AS REVENUE_6M,
    CASE 
        WHEN DATEDIFF('DAY', c.LAST_PURCHASE_DATE, CURRENT_DATE()) > 180 THEN 'HIGH'
        WHEN DATEDIFF('DAY', c.LAST_PURCHASE_DATE, CURRENT_DATE()) > 90 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS CHURN_RISK_LEVEL
FROM CUSTOMERS c
LEFT JOIN CUSTOMER_SEGMENTS cs ON c.SEGMENT_ID = cs.SEGMENT_ID
LEFT JOIN TRANSACTIONS t ON c.CUSTOMER_ID = t.CUSTOMER_ID 
    AND t.TRANSACTION_DATE >= DATEADD('MONTH', -6, CURRENT_DATE())
    AND t.STATUS = 'COMPLETED'
WHERE c.IS_ACTIVE = TRUE
GROUP BY c.CUSTOMER_ID, c.CUSTOMER_NAME, c.SEGMENT_ID, cs.SEGMENT_NAME,
         c.REGISTRATION_DATE, c.LAST_PURCHASE_DATE, c.TOTAL_PURCHASES
ORDER BY CHURN_RISK_LEVEL DESC, DAYS_SINCE_LAST_PURCHASE DESC;

-- =====================================================
-- CORTEX ANALYST OPTIMIZED VIEWS
-- =====================================================

-- Simplified metrics view for semantic model
CREATE OR REPLACE VIEW V_BUSINESS_METRICS AS
SELECT 
    'revenue' AS metric_name,
    DATE_TRUNC('MONTH', TRANSACTION_DATE) AS period,
    'monthly' AS period_type,
    SUM(FINAL_AMOUNT) AS metric_value,
    'currency' AS metric_type,
    REGION AS dimension_1,
    NULL AS dimension_2
FROM TRANSACTIONS 
WHERE STATUS = 'COMPLETED'
GROUP BY DATE_TRUNC('MONTH', TRANSACTION_DATE), REGION

UNION ALL

SELECT 
    'transactions' AS metric_name,
    DATE_TRUNC('MONTH', TRANSACTION_DATE) AS period,
    'monthly' AS period_type,
    COUNT(*) AS metric_value,
    'count' AS metric_type,
    REGION AS dimension_1,
    NULL AS dimension_2
FROM TRANSACTIONS 
WHERE STATUS = 'COMPLETED'
GROUP BY DATE_TRUNC('MONTH', TRANSACTION_DATE), REGION

UNION ALL

SELECT 
    'customers' AS metric_name,
    DATE_TRUNC('MONTH', TRANSACTION_DATE) AS period,
    'monthly' AS period_type,
    COUNT(DISTINCT CUSTOMER_ID) AS metric_value,
    'count' AS metric_type,
    REGION AS dimension_1,
    NULL AS dimension_2
FROM TRANSACTIONS 
WHERE STATUS = 'COMPLETED'
GROUP BY DATE_TRUNC('MONTH', TRANSACTION_DATE), REGION;

-- Product performance view for semantic model
CREATE OR REPLACE VIEW V_PRODUCT_METRICS AS
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_NAME,
    c.CATEGORY_NAME,
    COUNT(t.TRANSACTION_ID) AS total_transactions,
    SUM(t.FINAL_AMOUNT) AS total_revenue,
    SUM(t.QUANTITY) AS total_quantity,
    AVG(t.FINAL_AMOUNT) AS avg_transaction_value,
    COUNT(DISTINCT t.CUSTOMER_ID) AS unique_customers,
    DATE_TRUNC('MONTH', t.TRANSACTION_DATE) AS month
FROM PRODUCTS p
LEFT JOIN CATEGORIES c ON p.CATEGORY_ID = c.CATEGORY_ID
LEFT JOIN TRANSACTIONS t ON p.PRODUCT_ID = t.PRODUCT_ID 
    AND t.STATUS = 'COMPLETED'
GROUP BY p.PRODUCT_ID, p.PRODUCT_NAME, c.CATEGORY_NAME, DATE_TRUNC('MONTH', t.TRANSACTION_DATE)
ORDER BY month DESC, total_revenue DESC;

-- =====================================================
-- PERMISSIONS
-- =====================================================

-- Grant view access to demo role
GRANT SELECT ON ALL VIEWS IN SCHEMA {db_name}.ANALYTICS TO ROLE {db_name}_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA {db_name}.ANALYTICS TO ROLE {db_name}_ROLE;

SELECT 'Analytical views created successfully for {safe_company_name}' AS STATUS;

-- Views are ready for Cortex Analyst semantic model configuration'''

    def _generate_category_data(self, categories: List[str]) -> str:
        """Generate category data inserts"""
        inserts = []
        for i, category in enumerate(categories, 1):
            category_id = f"CAT{i:03d}"
            description = f"Premium {category.lower()} products and services"
            inserts.append(f"('{category_id}', '{category}', '{description}', NULL, TRUE)")
        
        return f"""INSERT INTO CATEGORIES (CATEGORY_ID, CATEGORY_NAME, DESCRIPTION, PARENT_CATEGORY_ID, IS_ACTIVE) VALUES
{','.join(inserts)};"""

    def _generate_product_data(self, categories: List[str]) -> str:
        """Generate product data inserts"""
        inserts = []
        product_counter = 1
        
        product_templates = {
            'Fashion': ['Premium Clothing Line', 'Designer Accessories', 'Seasonal Collection', 'Athletic Wear'],
            'Home': ['Modern Furniture Set', 'Kitchen Appliances', 'Home Decor Collection', 'Bedding Essentials'],
            'Electronics': ['Smart Device Collection', 'Audio Equipment', 'Computer Accessories', 'Mobile Tech'],
            'Beauty': ['Skincare Essentials', 'Makeup Collection', 'Fragrance Line', 'Hair Care Products'],
            'Sports': ['Fitness Equipment', 'Outdoor Gear', 'Athletic Accessories', 'Sports Apparel'],
            'Luxury': ['Premium Collection', 'Exclusive Items', 'Limited Edition', 'VIP Products']
        }
        
        for i, category in enumerate(categories, 1):
            category_id = f"CAT{i:03d}"
            
            # Get product templates or use generic ones
            templates = product_templates.get(category, ['Premium Product', 'Standard Product', 'Basic Product'])
            
            for template in templates:
                product_id = f"PROD{product_counter:04d}"
                product_name = f"{category} - {template}"
                description = f"High-quality {template.lower()} from our {category.lower()} collection"
                unit_price = random.randint(50, 1000)
                cost_price = round(unit_price * 0.6, 2)
                
                inserts.append(f"('{product_id}', '{product_name}', '{category_id}', '{description}', {unit_price}, {cost_price}, TRUE)")
                product_counter += 1
        
        return f"""INSERT INTO PRODUCTS (PRODUCT_ID, PRODUCT_NAME, CATEGORY_ID, DESCRIPTION, UNIT_PRICE, COST_PRICE, IS_ACTIVE) VALUES
{','.join(inserts)};"""

    def _generate_customer_segment_data(self, segments: List[str]) -> str:
        """Generate customer segment data inserts"""
        inserts = []
        segment_descriptions = {
            'Premium Members': 'High-value customers with exclusive benefits',
            'Young Professionals': 'Career-focused individuals aged 25-35',
            'Family Shoppers': 'Families with children making household purchases',
            'Senior Citizens': 'Mature customers aged 65+ with specific needs',
            'Fashion Enthusiasts': 'Style-conscious customers following latest trends',
            'High Net Worth': 'Wealthy individuals with premium financial needs',
            'Small Business': 'Small business owners and entrepreneurs',
            'Retirees': 'Retired individuals managing their finances',
            'First Time Buyers': 'New customers making their first purchases'
        }
        
        for i, segment in enumerate(segments, 1):
            segment_id = f"SEG{i:03d}"
            description = segment_descriptions.get(segment, f"Customer segment for {segment.lower()}")
            demographics = f"Target demographic for {segment.lower()} customer base"
            
            inserts.append(f"('{segment_id}', '{segment}', '{description}', '{demographics}', TRUE)")
        
        return f"""INSERT INTO CUSTOMER_SEGMENTS (SEGMENT_ID, SEGMENT_NAME, DESCRIPTION, TARGET_DEMOGRAPHICS, IS_ACTIVE) VALUES
{','.join(inserts)};"""

    def _generate_customer_data(self, segments: List[str]) -> str:
        """Generate customer data inserts"""
        inserts = []
        
        first_names = ['Juan', 'María', 'Carlos', 'Ana', 'Luis', 'Carmen', 'Jorge', 'Patricia', 'Miguel', 'Rosa',
                      'Fernando', 'Guadalupe', 'Rafael', 'Isabel', 'Antonio', 'Margarita', 'José', 'Leticia']
        
        last_names = ['García', 'Rodríguez', 'Martínez', 'González', 'López', 'Hernández', 'Pérez', 'Sánchez',
                     'Ramírez', 'Torres', 'Flores', 'Rivera', 'Gómez', 'Díaz', 'Cruz', 'Morales', 'Jiménez']
        
        regions = ['CDMX', 'Guadalajara', 'Monterrey', 'Puebla', 'Tijuana', 'León', 'Querétaro', 'Mérida']
        
        for customer_id in range(1, 501):  # Generate 500 customers
            customer_name = f"{random.choice(first_names)} {random.choice(last_names)}"
            email = f"{customer_name.lower().replace(' ', '.')}@email.com"
            phone = f"+52 55 {random.randint(1000, 9999)} {random.randint(1000, 9999)}"
            segment_id = f"SEG{random.randint(1, len(segments)):03d}"
            
            # Random registration date in the last 3 years
            reg_date = datetime.now() - timedelta(days=random.randint(1, 1095))
            last_purchase = reg_date + timedelta(days=random.randint(1, (datetime.now() - reg_date).days))
            
            total_purchases = round(random.uniform(100, 10000), 2)
            region = random.choice(regions)
            
            customer_id_str = f"CUST{customer_id:06d}"
            
            inserts.append(f"('{customer_id_str}', '{customer_name}', '{email}', '{phone}', '{segment_id}', "
                          f"'{reg_date.strftime('%Y-%m-%d')}', '{last_purchase.strftime('%Y-%m-%d')}', "
                          f"{total_purchases}, TRUE, '{region}', 'Mexico')")
        
        # Split inserts into batches of 50
        batch_size = 50
        batches = [inserts[i:i + batch_size] for i in range(0, len(inserts), batch_size)]
        
        result = ""
        for i, batch in enumerate(batches):
            result += f"""INSERT INTO CUSTOMERS (CUSTOMER_ID, CUSTOMER_NAME, EMAIL, PHONE, SEGMENT_ID, 
REGISTRATION_DATE, LAST_PURCHASE_DATE, TOTAL_PURCHASES, IS_ACTIVE, REGION, COUNTRY) VALUES
{','.join(batch)};

"""
        
        return result

    def _generate_transaction_data(self, revenue_scale: Dict[str, Any]) -> str:
        """Generate transaction data inserts"""
        inserts = []
        
        channels = ['Online', 'Store', 'Mobile App', 'Call Center', 'Partner']
        payment_methods = ['Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer', 'Cash']
        regions = ['CDMX', 'Guadalajara', 'Monterrey', 'Puebla', 'Tijuana', 'León', 'Querétaro', 'Mérida']
        
        # Generate transactions for the last 18 months
        start_date = datetime.now() - timedelta(days=540)
        
        for transaction_id in range(1, 5001):  # Generate 5000 transactions
            trans_date = start_date + timedelta(days=random.randint(0, 540))
            customer_id = f"CUST{random.randint(1, 500):06d}"
            product_id = f"PROD{random.randint(1, 24):04d}"  # Assuming 24 products (6 categories × 4 products)
            
            quantity = random.randint(1, 5)
            unit_price = round(random.uniform(50, 1000), 2)
            total_amount = round(quantity * unit_price, 2)
            discount = round(random.uniform(0, total_amount * 0.2), 2) if random.random() < 0.3 else 0
            final_amount = round(total_amount - discount, 2)
            
            payment_method = random.choice(payment_methods)
            status = 'COMPLETED' if random.random() < 0.95 else random.choice(['PENDING', 'CANCELLED'])
            channel = random.choice(channels)
            region = random.choice(regions)
            
            transaction_id_str = f"TXN{transaction_id:08d}"
            
            inserts.append(f"('{transaction_id_str}', '{customer_id}', '{product_id}', "
                          f"'{trans_date.strftime('%Y-%m-%d %H:%M:%S')}', {quantity}, {unit_price}, "
                          f"{total_amount}, {discount}, {final_amount}, '{payment_method}', "
                          f"'{status}', '{channel}', '{region}')")
        
        # Split into batches
        batch_size = 100
        batches = [inserts[i:i + batch_size] for i in range(0, len(inserts), batch_size)]
        
        result = ""
        for i, batch in enumerate(batches):
            result += f"""INSERT INTO TRANSACTIONS (TRANSACTION_ID, CUSTOMER_ID, PRODUCT_ID, TRANSACTION_DATE, 
QUANTITY, UNIT_PRICE, TOTAL_AMOUNT, DISCOUNT_AMOUNT, FINAL_AMOUNT, PAYMENT_METHOD, 
STATUS, CHANNEL, REGION) VALUES
{','.join(batch)};

"""
        
        return result

    def _generate_performance_data(self, categories: List[str]) -> str:
        """Generate performance metrics data"""
        inserts = []
        
        metrics = [
            ('Revenue', 'currency', 'MXN'),
            ('Transactions', 'count', 'units'),
            ('Customer Satisfaction', 'rating', 'score'),
            ('Market Share', 'percentage', 'percent'),
            ('Growth Rate', 'percentage', 'percent')
        ]
        
        regions = ['CDMX', 'Guadalajara', 'Monterrey', 'Puebla', 'National']
        
        # Generate metrics for the last 24 months
        start_date = datetime.now() - timedelta(days=730)
        
        metric_counter = 1
        for month_offset in range(24):
            metric_date = (start_date + timedelta(days=month_offset * 30)).date()
            
            for metric_name, metric_type, unit in metrics:
                for region in regions:
                    for category in categories:
                        metric_id = f"MET{metric_counter:06d}"
                        
                        # Generate realistic values based on metric type
                        if metric_type == 'currency':
                            value = round(random.uniform(50000, 500000), 2)
                            target = round(value * random.uniform(0.9, 1.1), 2)
                        elif metric_type == 'count':
                            value = random.randint(100, 2000)
                            target = int(value * random.uniform(0.9, 1.1))
                        elif metric_type == 'rating':
                            value = round(random.uniform(3.5, 5.0), 1)
                            target = 4.5
                        else:  # percentage
                            value = round(random.uniform(0, 100), 1)
                            target = round(value * random.uniform(0.9, 1.1), 1)
                        
                        category_name = f"{category} - {metric_name}"
                        
                        inserts.append(f"('{metric_id}', '{metric_date}', '{metric_name}', "
                                      f"{value}, {target}, '{category_name}', '{region}', '{unit}')")
                        
                        metric_counter += 1
        
        # Split into batches
        batch_size = 200
        batches = [inserts[i:i + batch_size] for i in range(0, len(inserts), batch_size)]
        
        result = ""
        for i, batch in enumerate(batches):
            result += f"""INSERT INTO PERFORMANCE_METRICS (METRIC_ID, METRIC_DATE, METRIC_NAME, METRIC_VALUE, 
METRIC_TARGET, CATEGORY, REGION, MEASUREMENT_UNIT) VALUES
{','.join(batch)};

"""
        
        return result

    def _generate_support_data(self) -> str:
        """Generate support ticket data"""
        inserts = []
        
        subjects = [
            'Product inquiry and specifications',
            'Order status and delivery questions',
            'Technical support request',
            'Billing and payment issues',
            'Return and refund request',
            'Account access problems',
            'Product quality concerns',
            'Feature request and suggestions',
            'General customer service inquiry'
        ]
        
        categories = ['Technical', 'Billing', 'Sales', 'General', 'Returns', 'Account']
        priorities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
        statuses = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']
        agents = ['Agent001', 'Agent002', 'Agent003', 'Agent004', 'Agent005']
        
        # Generate tickets for the last 6 months
        start_date = datetime.now() - timedelta(days=180)
        
        for ticket_id in range(1, 1001):  # Generate 1000 tickets
            created_date = start_date + timedelta(days=random.randint(0, 180))
            customer_id = f"CUST{random.randint(1, 500):06d}"
            subject = random.choice(subjects)
            description = f"Customer inquiry regarding {subject.lower()}. Detailed description of the issue and customer requirements."
            
            priority = random.choice(priorities)
            status = random.choice(statuses)
            category = random.choice(categories)
            agent = random.choice(agents)
            
            # Generate resolved date if ticket is resolved/closed
            resolved_date = None
            if status in ['RESOLVED', 'CLOSED']:
                resolve_days = random.randint(1, 7)
                resolved_date = created_date + timedelta(days=resolve_days)
                resolved_date_str = f"'{resolved_date.strftime('%Y-%m-%d %H:%M:%S')}'"
            else:
                resolved_date_str = "NULL"
            
            # Generate satisfaction rating for resolved tickets
            satisfaction = None
            if status in ['RESOLVED', 'CLOSED'] and random.random() < 0.8:
                satisfaction = round(random.uniform(3.0, 5.0), 1)
                satisfaction_str = str(satisfaction)
            else:
                satisfaction_str = "NULL"
            
            feedback_text = f"Customer feedback for ticket regarding {category.lower()} issue" if satisfaction else "NULL"
            if feedback_text != "NULL":
                feedback_text = f"'{feedback_text}'"
            
            ticket_id_str = f"TICK{ticket_id:06d}"
            
            inserts.append(f"('{ticket_id_str}', '{customer_id}', '{subject}', '{description}', "
                          f"'{priority}', '{status}', '{category}', '{agent}', "
                          f"'{created_date.strftime('%Y-%m-%d %H:%M:%S')}', {resolved_date_str}, "
                          f"{satisfaction_str}, {feedback_text})")
        
        # Split into batches
        batch_size = 100
        batches = [inserts[i:i + batch_size] for i in range(0, len(inserts), batch_size)]
        
        result = ""
        for i, batch in enumerate(batches):
            result += f"""INSERT INTO SUPPORT_TICKETS (TICKET_ID, CUSTOMER_ID, SUBJECT, DESCRIPTION, PRIORITY, 
STATUS, CATEGORY, ASSIGNED_TO, CREATED_DATE, RESOLVED_DATE, SATISFACTION_RATING, FEEDBACK_TEXT) VALUES
{','.join(batch)};

"""
        
        return result

    def _generate_knowledge_base_data(self, company_name: str, template: Dict[str, Any]) -> str:
        """Generate knowledge base documents for Cortex Search"""
        
        documents = [
            {
                'id': 'DOC001',
                'title': f'{company_name} - Operating Procedures Manual',
                'content': f'Comprehensive operating procedures for {company_name} covering standard workflows, quality control processes, and operational guidelines for {template["name"].lower()} operations.',
                'type': 'Manual',
                'category': 'Operations'
            },
            {
                'id': 'DOC002',
                'title': f'{template["name"]} Performance Standards Guide',
                'content': f'Performance standards and benchmarks for {template["name"].lower()} industry operations including KPIs, quality metrics, and performance evaluation criteria.',
                'type': 'Guide',
                'category': 'Standards'
            },
            {
                'id': 'DOC003',
                'title': 'Business Intelligence Best Practices',
                'content': 'Best practices for business intelligence implementation, data analysis methodologies, and reporting standards for effective decision making.',
                'type': 'Best Practices',
                'category': 'Analytics'
            },
            {
                'id': 'DOC004',
                'title': 'System Administration Guidelines',
                'content': 'Technical guidelines for system administration, data management, security protocols, and system maintenance procedures.',
                'type': 'Guidelines',
                'category': 'Technical'
            },
            {
                'id': 'DOC005',
                'title': 'Strategic Planning Framework 2024',
                'content': f'Strategic planning framework for {company_name} including vision, mission, strategic objectives, and implementation roadmap for 2024.',
                'type': 'Framework',
                'category': 'Strategy'
            }
        ]
        
        inserts = []
        for doc in documents:
            tags = f"ARRAY_CONSTRUCT('{doc['category']}', '{doc['type']}', '{template['name']}')"
            metadata = f"OBJECT_CONSTRUCT('author', 'System', 'version', '1.0', 'category', '{doc['category']}')"
            
            inserts.append(f"('{doc['id']}', '{doc['title']}', '{doc['content']}', "
                          f"'{doc['type']}', '{doc['category']}', 'System Administrator', "
                          f"CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), TRUE, {tags}, {metadata})")
        
        return f"""INSERT INTO KNOWLEDGE_BASE (DOCUMENT_ID, TITLE, CONTENT, DOCUMENT_TYPE, CATEGORY, 
AUTHOR, CREATED_DATE, UPDATED_DATE, IS_ACTIVE, TAGS, METADATA) VALUES
{','.join(inserts)};"""

    def _generate_feedback_data(self) -> str:
        """Generate customer feedback data for sentiment analysis"""
        
        feedback_texts = [
            'Excellent service and high quality products. Very satisfied with my purchase.',
            'Product quality could be improved. Had some issues with delivery timing.',
            'Outstanding customer service team. They resolved my issue quickly and professionally.',
            'The product exceeded my expectations. Will definitely recommend to others.',
            'Had a minor issue with the order but customer service handled it perfectly.',
            'Good value for money. Product quality is decent for the price range.',
            'Disappointed with the product quality. Not as described on the website.',
            'Fast delivery and great packaging. Product arrived in perfect condition.',
            'Customer service needs improvement. Took too long to get a response.',
            'Amazing product! Exactly what I was looking for. Five stars!'
        ]
        
        sources = ['Website', 'Email', 'Phone', 'Chat', 'Survey', 'Social Media']
        
        inserts = []
        for feedback_id in range(1, 501):  # Generate 500 feedback records
            customer_id = f"CUST{random.randint(1, 500):06d}"
            product_id = f"PROD{random.randint(1, 24):04d}"
            
            feedback_text = random.choice(feedback_texts)
            rating = random.randint(1, 5)
            source = random.choice(sources)
            
            # Simple sentiment based on rating
            if rating >= 4:
                sentiment_score = round(random.uniform(0.6, 1.0), 2)
                sentiment_label = 'POSITIVE'
            elif rating >= 3:
                sentiment_score = round(random.uniform(-0.2, 0.2), 2)
                sentiment_label = 'NEUTRAL'
            else:
                sentiment_score = round(random.uniform(-1.0, -0.3), 2)
                sentiment_label = 'NEGATIVE'
            
            feedback_date = datetime.now() - timedelta(days=random.randint(1, 180))
            processed_date = feedback_date + timedelta(hours=random.randint(1, 24))
            
            keywords = "ARRAY_CONSTRUCT('quality', 'service', 'delivery')"
            themes = f"ARRAY_CONSTRUCT('{sentiment_label.lower()}', 'product_feedback')"
            
            feedback_id_str = f"FB{feedback_id:06d}"
            
            inserts.append(f"('{feedback_id_str}', '{customer_id}', '{product_id}', "
                          f"'{feedback_text}', {rating}, '{feedback_date.strftime('%Y-%m-%d %H:%M:%S')}', "
                          f"'{source}', {sentiment_score}, '{sentiment_label}', "
                          f"'{processed_date.strftime('%Y-%m-%d %H:%M:%S')}', {keywords}, {themes})")
        
        # Split into batches
        batch_size = 100
        batches = [inserts[i:i + batch_size] for i in range(0, len(inserts), batch_size)]
        
        result = ""
        for i, batch in enumerate(batches):
            result += f"""INSERT INTO CUSTOMER_FEEDBACK (FEEDBACK_ID, CUSTOMER_ID, PRODUCT_ID, FEEDBACK_TEXT, 
RATING, FEEDBACK_DATE, SOURCE, SENTIMENT_SCORE, SENTIMENT_LABEL, PROCESSED_DATE, KEYWORDS, THEMES) VALUES
{','.join(batch)};

"""
        
        return result

    def _load_sql_templates(self) -> Dict[str, str]:
        """Load SQL templates for different components"""
        return {
            'setup': '',
            'tables': '',
            'data': '',
            'views': ''
        }




