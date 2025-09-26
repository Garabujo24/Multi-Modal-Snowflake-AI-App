#!/usr/bin/env python3

import markdown
import os

def main():
    # List of markdown files to convert
    md_files = [
        '01-servicios-banca-corporativa-monex.md',
        '02-productos-inversion-gestion-patrimonio-monex.md', 
        '03-servicios-divisas-pagos-internacionales-monex.md',
        '04-instrumentos-derivados-manejo-riesgos-monex.md'
    ]
    
    # Enhanced CSS for PDF-ready HTML
    css_content = '''
    <style>
    @page {
        margin: 2cm;
        size: A4;
    }
    
    @media print {
        .page-break {
            page-break-before: always;
        }
        
        h1 {
            page-break-after: avoid;
        }
        
        h2 {
            page-break-after: avoid;
        }
        
        table {
            page-break-inside: avoid;
            font-size: 9pt;
        }
        
        pre {
            page-break-inside: avoid;
        }
        
        .header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 1cm;
            text-align: center;
            font-size: 9pt;
            color: #666;
            border-bottom: 1px solid #e5e7eb;
            background: white;
            z-index: 1000;
        }
        
        .footer {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            height: 1cm;
            text-align: center;
            font-size: 9pt;
            color: #666;
            border-top: 1px solid #e5e7eb;
            background: white;
            z-index: 1000;
        }
        
        body {
            margin-top: 1.5cm;
            margin-bottom: 1.5cm;
        }
    }
    
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, Arial, sans-serif;
        font-size: 11pt;
        line-height: 1.6;
        color: #333;
        max-width: none;
        margin: 0;
        padding: 20px;
        background: white;
    }
    
    .container {
        max-width: 800px;
        margin: 0 auto;
        background: white;
    }
    
    h1 {
        color: #1e3a8a;
        font-size: 24pt;
        margin-top: 30pt;
        margin-bottom: 15pt;
        border-bottom: 3px solid #1e3a8a;
        padding-bottom: 8pt;
        font-weight: bold;
        text-align: center;
    }
    
    h2 {
        color: #1e40af;
        font-size: 18pt;
        margin-top: 25pt;
        margin-bottom: 12pt;
        border-bottom: 2px solid #e5e7eb;
        padding-bottom: 5pt;
        font-weight: bold;
    }
    
    h3 {
        color: #1e40af;
        font-size: 16pt;
        margin-top: 20pt;
        margin-bottom: 10pt;
        font-weight: bold;
    }
    
    h4 {
        color: #374151;
        font-size: 14pt;
        margin-top: 15pt;
        margin-bottom: 8pt;
        font-weight: bold;
    }
    
    h5 {
        color: #4b5563;
        font-size: 12pt;
        margin-top: 12pt;
        margin-bottom: 6pt;
        font-weight: bold;
    }
    
    p {
        margin: 8pt 0;
        text-align: justify;
        line-height: 1.6;
    }
    
    table {
        width: 100%;
        border-collapse: collapse;
        margin: 15pt 0;
        font-size: 10pt;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    th, td {
        border: 1px solid #d1d5db;
        padding: 8pt 12pt;
        text-align: left;
        vertical-align: top;
    }
    
    th {
        background: linear-gradient(to bottom, #f8f9fa, #e9ecef);
        font-weight: bold;
        color: #1f2937;
        text-align: center;
    }
    
    tr:nth-child(even) {
        background-color: #f9fafb;
    }
    
    tr:hover {
        background-color: #f3f4f6;
    }
    
    code {
        background-color: #f1f5f9;
        padding: 3pt 6pt;
        border-radius: 3pt;
        font-family: 'Monaco', 'Menlo', 'Courier New', monospace;
        font-size: 9pt;
        color: #1f2937;
        border: 1px solid #e5e7eb;
    }
    
    pre {
        background: linear-gradient(135deg, #f8fafc, #f1f5f9);
        padding: 15pt;
        border-radius: 6pt;
        border-left: 4pt solid #3b82f6;
        overflow-x: auto;
        font-family: 'Monaco', 'Menlo', 'Courier New', monospace;
        font-size: 9pt;
        margin: 15pt 0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        color: #1f2937;
        line-height: 1.4;
    }
    
    pre code {
        background: none;
        padding: 0;
        border: none;
        border-radius: 0;
    }
    
    blockquote {
        border-left: 4pt solid #3b82f6;
        padding: 15pt 20pt;
        margin: 15pt 0;
        font-style: italic;
        color: #4b5563;
        background: linear-gradient(to right, #f8fafc, white);
        border-radius: 0 6pt 6pt 0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    
    blockquote p {
        margin: 0;
    }
    
    ul, ol {
        padding-left: 25pt;
        margin: 10pt 0;
    }
    
    li {
        margin-bottom: 6pt;
        line-height: 1.5;
    }
    
    ul li {
        list-style-type: disc;
    }
    
    ol li {
        list-style-type: decimal;
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
        margin: 25pt 0;
        opacity: 0.7;
    }
    
    .toc {
        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
        padding: 20pt;
        border-radius: 8pt;
        margin: 20pt 0;
        border: 1px solid #dee2e6;
    }
    
    .toc h3 {
        margin-top: 0;
        color: #1e40af;
        text-align: center;
        border-bottom: 1px solid #1e40af;
        padding-bottom: 8pt;
    }
    
    .highlight {
        background-color: #fef3c7;
        padding: 2pt 4pt;
        border-radius: 2pt;
    }
    
    .monex-logo {
        text-align: center;
        font-size: 28pt;
        font-weight: bold;
        color: #1e3a8a;
        margin: 30pt 0;
        text-shadow: 1px 1px 2px rgba(0,0,0,0.1);
    }
    
    .document-title {
        text-align: center;
        font-size: 20pt;
        color: #1e40af;
        margin: 20pt 0;
        font-weight: normal;
    }
    
    .subtitle {
        text-align: center;
        font-size: 14pt;
        color: #6b7280;
        margin-bottom: 30pt;
        font-style: italic;
    }
    
    .footer-info {
        text-align: center;
        font-size: 9pt;
        color: #6b7280;
        margin-top: 30pt;
        padding-top: 15pt;
        border-top: 1px solid #e5e7eb;
        font-style: italic;
    }
    
    @media screen {
        body {
            background: #f5f5f5;
            padding: 20px;
        }
        
        .container {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
    }
    </style>
    '''
    
    converted_files = []
    
    for md_file in md_files:
        if os.path.exists(md_file):
            print(f'Converting {md_file}...')
            
            # Read markdown file
            with open(md_file, 'r', encoding='utf-8') as f:
                md_content = f.read()
            
            # Convert markdown to HTML
            html = markdown.markdown(md_content, extensions=['tables', 'fenced_code', 'codehilite', 'toc'])
            
            # Extract title from first h1 or use filename
            title_start = html.find('<h1>')
            title_end = html.find('</h1>')
            if title_start != -1 and title_end != -1:
                title = html[title_start+4:title_end]
            else:
                title = md_file.replace('.md', '').replace('-', ' ').title()
            
            # Create full HTML document
            full_html = f'''<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monex Grupo Financiero - {title}</title>
    {css_content}
</head>
<body>
    <div class="container">
        <div class="monex-logo">MONEX</div>
        <div class="document-title">{title}</div>
        <div class="subtitle">Grupo Financiero</div>
        
        <div class="header" style="display: none;">MONEX GRUPO FINANCIERO - DOCUMENTO CONFIDENCIAL</div>
        
        {html}
        
        <div class="footer-info">
            <p><strong>© 2024 Monex Grupo Financiero</strong></p>
            <p>Este documento contiene información confidencial y propietaria. Todos los derechos reservados.</p>
            <p>Para más información, visite: <strong>www.monex.com.mx</strong></p>
        </div>
        
        <div class="footer" style="display: none;">© 2024 Monex Grupo Financiero - Página <span id="pageNumber"></span></div>
    </div>
    
    <script>
        // Show header and footer only when printing
        window.addEventListener('beforeprint', function() {{
            document.querySelector('.header').style.display = 'block';
            document.querySelector('.footer').style.display = 'block';
        }});
        
        window.addEventListener('afterprint', function() {{
            document.querySelector('.header').style.display = 'none';
            document.querySelector('.footer').style.display = 'none';
        }});
    </script>
</body>
</html>'''
            
            # Write HTML file
            html_filename = md_file.replace('.md', '.html')
            with open(html_filename, 'w', encoding='utf-8') as f:
                f.write(full_html)
            
            converted_files.append(html_filename)
            print(f'Created: {html_filename}')
        else:
            print(f'File {md_file} not found')
    
    print(f'\\nConversion completed!')
    print(f'Files converted: {len(converted_files)}')
    
    print(f'\\n=== INSTRUCTIONS FOR PDF CONVERSION ===')
    print(f'To convert the HTML files to PDF:')
    print(f'1. Open each HTML file in a web browser (Chrome, Safari, Firefox)')
    print(f'2. Press Cmd+P (Mac) or Ctrl+P (Windows) to print')
    print(f'3. Select "Save as PDF" as the destination')
    print(f'4. Choose these settings for best results:')
    print(f'   - Paper size: A4')
    print(f'   - Margins: Normal or Custom (2cm all sides)')
    print(f'   - Include headers and footers: Yes')
    print(f'   - Background graphics: Yes')
    print(f'5. Save with the same name but .pdf extension')
    
    print(f'\\nFiles ready for PDF conversion:')
    for file in converted_files:
        print(f'  - {file}')
    
    print(f'\\nThe HTML files are optimized for printing and will produce professional-looking PDFs!')

if __name__ == "__main__":
    main()

