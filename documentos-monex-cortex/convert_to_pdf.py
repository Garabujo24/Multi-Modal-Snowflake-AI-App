#!/usr/bin/env python3

import markdown
import os
import sys

def install_and_import(package):
    """Install and import a package if not available"""
    try:
        __import__(package)
    except ImportError:
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        globals()[package] = __import__(package)

# Try to import required packages, install if needed
try:
    from weasyprint import HTML, CSS
    weasyprint_available = True
except ImportError:
    weasyprint_available = False
    print("WeasyPrint not available, trying alternative method...")

def convert_with_simple_html(md_content, output_file):
    """Convert markdown to PDF using simple HTML and print to PDF"""
    html = markdown.markdown(md_content, extensions=['tables', 'fenced_code', 'codehilite'])
    
    # Enhanced CSS for better PDF formatting
    css_content = '''
    <style>
    @page {
        margin: 2cm;
        size: A4;
    }
    
    body {
        font-family: Arial, sans-serif;
        font-size: 11pt;
        line-height: 1.4;
        color: #333;
        max-width: none;
    }
    
    h1 {
        color: #1e3a8a;
        font-size: 20pt;
        margin-top: 20pt;
        margin-bottom: 12pt;
        border-bottom: 2px solid #1e3a8a;
        padding-bottom: 5pt;
    }
    
    h2 {
        color: #1e40af;
        font-size: 16pt;
        margin-top: 16pt;
        margin-bottom: 8pt;
        border-bottom: 1px solid #e5e7eb;
        padding-bottom: 3pt;
    }
    
    h3 {
        color: #1e40af;
        font-size: 14pt;
        margin-top: 12pt;
        margin-bottom: 6pt;
    }
    
    h4 {
        color: #374151;
        font-size: 12pt;
        margin-top: 10pt;
        margin-bottom: 4pt;
        font-weight: bold;
    }
    
    table {
        width: 100%;
        border-collapse: collapse;
        margin: 10pt 0;
        font-size: 10pt;
    }
    
    th, td {
        border: 1px solid #ccc;
        padding: 6pt;
        text-align: left;
        vertical-align: top;
    }
    
    th {
        background-color: #f8f9fa;
        font-weight: bold;
        color: #1f2937;
    }
    
    tr:nth-child(even) {
        background-color: #f9fafb;
    }
    
    code {
        background-color: #f1f5f9;
        padding: 2pt 4pt;
        border-radius: 2pt;
        font-family: 'Courier New', monospace;
        font-size: 9pt;
    }
    
    pre {
        background-color: #f8f9fa;
        padding: 10pt;
        border-radius: 4pt;
        border-left: 4pt solid #1e40af;
        overflow-x: auto;
        font-family: 'Courier New', monospace;
        font-size: 9pt;
        margin: 10pt 0;
    }
    
    blockquote {
        border-left: 4pt solid #1e40af;
        padding-left: 16pt;
        margin-left: 0;
        font-style: italic;
        color: #4b5563;
        background-color: #f8fafc;
        padding: 10pt 16pt;
        margin: 10pt 0;
    }
    
    ul, ol {
        padding-left: 20pt;
        margin: 8pt 0;
    }
    
    li {
        margin-bottom: 4pt;
    }
    
    strong {
        font-weight: bold;
        color: #1f2937;
    }
    
    em {
        font-style: italic;
        color: #4b5563;
    }
    
    hr {
        border: none;
        border-top: 2px solid #e5e7eb;
        margin: 20pt 0;
    }
    
    .toc {
        background-color: #f8f9fa;
        padding: 15pt;
        border-radius: 5pt;
        margin: 15pt 0;
    }
    
    .footer {
        position: fixed;
        bottom: 1cm;
        left: 0;
        right: 0;
        text-align: center;
        font-size: 9pt;
        color: #666;
    }
    
    .header {
        position: fixed;
        top: 1cm;
        left: 0;
        right: 0;
        text-align: center;
        font-size: 9pt;
        color: #666;
        border-bottom: 1px solid #e5e7eb;
        padding-bottom: 5pt;
    }
    
    @media print {
        .page-break {
            page-break-before: always;
        }
        
        h1, h2 {
            page-break-after: avoid;
        }
        
        table {
            page-break-inside: avoid;
        }
    }
    </style>
    '''
    
    # Create full HTML document
    full_html = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Monex Grupo Financiero - {output_file.replace('.pdf', '').replace('-', ' ').title()}</title>
    {css_content}
</head>
<body>
    <div class="header">MONEX GRUPO FINANCIERO - DOCUMENTO CONFIDENCIAL</div>
    {html}
    <div class="footer">© 2024 Monex Grupo Financiero - Todos los derechos reservados</div>
</body>
</html>'''
    
    # Write HTML file
    html_file = output_file.replace('.pdf', '.html')
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(full_html)
    
    print(f"HTML file created: {html_file}")
    print(f"To convert to PDF, open {html_file} in a browser and use 'Print to PDF'")
    return html_file

def convert_with_weasyprint(md_content, output_file):
    """Convert using WeasyPrint if available"""
    html = markdown.markdown(md_content, extensions=['tables', 'fenced_code'])
    
    css_content = '''
    @page {
        margin: 2cm;
        size: A4;
        @top-center {
            content: "MONEX Grupo Financiero";
            font-size: 10pt;
            color: #666;
        }
        @bottom-center {
            content: "Página " counter(page);
            font-size: 10pt;
            color: #666;
        }
    }
    
    body {
        font-family: Arial, sans-serif;
        font-size: 11pt;
        line-height: 1.4;
        color: #333;
    }
    
    h1 {
        color: #1e3a8a;
        font-size: 18pt;
        margin-top: 20pt;
        margin-bottom: 12pt;
    }
    
    h2 {
        color: #1e40af;
        font-size: 16pt;
        margin-top: 16pt;
        margin-bottom: 8pt;
    }
    
    h3 {
        color: #1e40af;
        font-size: 14pt;
        margin-top: 12pt;
        margin-bottom: 6pt;
    }
    
    table {
        width: 100%;
        border-collapse: collapse;
        margin: 10pt 0;
    }
    
    th, td {
        border: 1px solid #ccc;
        padding: 8pt;
        text-align: left;
    }
    
    th {
        background-color: #f8f9fa;
        font-weight: bold;
    }
    '''
    
    full_html = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Monex - {output_file}</title>
</head>
<body>
    {html}
</body>
</html>'''
    
    HTML(string=full_html).write_pdf(output_file, stylesheets=[CSS(string=css_content)])
    print(f"PDF created: {output_file}")

def main():
    # List of markdown files to convert
    md_files = [
        '01-servicios-banca-corporativa-monex.md',
        '02-productos-inversion-gestion-patrimonio-monex.md', 
        '03-servicios-divisas-pagos-internacionales-monex.md',
        '04-instrumentos-derivados-manejo-riesgos-monex.md'
    ]
    
    converted_files = []
    
    for md_file in md_files:
        if os.path.exists(md_file):
            print(f'\nProcessing {md_file}...')
            
            # Read markdown file
            with open(md_file, 'r', encoding='utf-8') as f:
                md_content = f.read()
            
            # Generate output filename
            pdf_filename = md_file.replace('.md', '.pdf')
            
            try:
                if weasyprint_available:
                    convert_with_weasyprint(md_content, pdf_filename)
                    converted_files.append(pdf_filename)
                else:
                    html_file = convert_with_simple_html(md_content, pdf_filename)
                    converted_files.append(html_file)
            except Exception as e:
                print(f"Error converting {md_file}: {e}")
                # Fallback to HTML
                html_file = convert_with_simple_html(md_content, pdf_filename)
                converted_files.append(html_file)
        else:
            print(f'File {md_file} not found')
    
    print(f'\nConversion completed!')
    print(f'Files processed: {len(converted_files)}')
    for file in converted_files:
        print(f'  - {file}')
    
    if not weasyprint_available:
        print(f'\nNote: WeasyPrint not available. HTML files created instead.')
        print(f'To get PDF files, open each HTML file in a web browser and use "Print to PDF"')

if __name__ == "__main__":
    main()

