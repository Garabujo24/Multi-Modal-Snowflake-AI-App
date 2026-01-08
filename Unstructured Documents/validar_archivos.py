"""
Script de Validación de Constancias Generadas
Cliente: Unstructured Docs
Propósito: Verificar integridad de archivos generados
"""

import os
import json
import csv
from pathlib import Path

def validar_pdfs():
    """Valida que todos los PDFs esperados existan"""
    print("📄 Validando PDFs...")
    
    rfc_esperados = [
        'TAS180523KL8', 'HESM850614J39', 'CAN200815RT6', 'GALR920327HG5',
        'CIB150309MN2', 'MARA881205QT7', 'SLP190722BC4', 'RAFC900518KP9',
        'DIC170411XY8', 'TOML870923FM2', 'MTO140627GH3', 'LOCF830712MK6',
        'EAS160105PL9'
    ]
    
    pdf_dir = Path('output/pdfs')
    errores = []
    exitosos = 0
    
    if not pdf_dir.exists():
        print("  ❌ Directorio output/pdfs no existe")
        return False
    
    for i, rfc in enumerate(rfc_esperados, 1):
        filename = f"CSF_{i:02d}_{rfc}.pdf"
        filepath = pdf_dir / filename
        
        if filepath.exists():
            size = filepath.stat().st_size
            if size > 0:
                exitosos += 1
                print(f"  ✓ {filename} ({size:,} bytes)")
            else:
                errores.append(f"{filename} está vacío")
        else:
            errores.append(f"{filename} no existe")
    
    if errores:
        print("\n  ⚠ Errores encontrados:")
        for error in errores:
            print(f"    - {error}")
        return False
    
    print(f"\n  ✓ {exitosos}/13 PDFs validados correctamente")
    return True

def validar_imagenes():
    """Valida que todas las imágenes esperadas existan"""
    print("\n🖼️  Validando imágenes...")
    
    rfc_esperados = [
        'TAS180523KL8', 'HESM850614J39', 'CAN200815RT6', 'GALR920327HG5',
        'CIB150309MN2', 'MARA881205QT7', 'SLP190722BC4', 'RAFC900518KP9',
        'DIC170411XY8', 'TOML870923FM2', 'MTO140627GH3', 'LOCF830712MK6',
        'EAS160105PL9'
    ]
    
    img_dir = Path('output/imagenes')
    errores = []
    exitosos = 0
    
    if not img_dir.exists():
        print("  ❌ Directorio output/imagenes no existe")
        return False
    
    for i, rfc in enumerate(rfc_esperados, 1):
        filename = f"CSF_{i:02d}_{rfc}.png"
        filepath = img_dir / filename
        
        if filepath.exists():
            size = filepath.stat().st_size
            if size > 0:
                exitosos += 1
                print(f"  ✓ {filename} ({size:,} bytes)")
            else:
                errores.append(f"{filename} está vacío")
        else:
            errores.append(f"{filename} no existe")
    
    if errores:
        print("\n  ⚠ Errores encontrados:")
        for error in errores:
            print(f"    - {error}")
        return False
    
    print(f"\n  ✓ {exitosos}/13 imágenes validadas correctamente")
    return True

def validar_csv():
    """Valida el archivo CSV de metadatos"""
    print("\n📊 Validando CSV de metadatos...")
    
    csv_path = Path('output/metadatos_constancias.csv')
    
    if not csv_path.exists():
        print("  ❌ Archivo metadatos_constancias.csv no existe")
        return False
    
    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            rows = list(reader)
            
            if len(rows) != 13:
                print(f"  ⚠ Se esperaban 13 registros, se encontraron {len(rows)}")
                return False
            
            # Validar campos requeridos
            campos_requeridos = ['RFC', 'NOMBRE_CONTRIBUYENTE', 'TIPO_PERSONA', 
                               'REGIMEN_FISCAL', 'ESTADO']
            
            for campo in campos_requeridos:
                if campo not in rows[0]:
                    print(f"  ❌ Campo requerido '{campo}' no encontrado")
                    return False
            
            # Validar que no haya valores vacíos en campos críticos
            for i, row in enumerate(rows, 1):
                for campo in campos_requeridos:
                    if not row.get(campo):
                        print(f"  ⚠ Registro {i}: campo '{campo}' está vacío")
                        return False
            
            print(f"  ✓ CSV validado: 13 registros, {len(rows[0])} campos")
            print(f"  ✓ Campos: {', '.join(list(rows[0].keys())[:5])}...")
            return True
            
    except Exception as e:
        print(f"  ❌ Error al leer CSV: {e}")
        return False

def validar_json():
    """Valida el archivo JSON de metadatos"""
    print("\n📋 Validando JSON de metadatos...")
    
    json_path = Path('output/metadatos_constancias.json')
    
    if not json_path.exists():
        print("  ❌ Archivo metadatos_constancias.json no existe")
        return False
    
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
            if not isinstance(data, list):
                print("  ❌ JSON debe ser un array")
                return False
            
            if len(data) != 13:
                print(f"  ⚠ Se esperaban 13 registros, se encontraron {len(data)}")
                return False
            
            # Validar estructura de cada objeto
            for i, obj in enumerate(data, 1):
                if 'identificacion' not in obj:
                    print(f"  ❌ Registro {i}: falta sección 'identificacion'")
                    return False
                
                if 'rfc' not in obj['identificacion']:
                    print(f"  ❌ Registro {i}: falta campo 'rfc'")
                    return False
            
            print(f"  ✓ JSON validado: 13 registros")
            print(f"  ✓ Estructura correcta con secciones: identificacion, regimen_fiscal, domicilio, etc.")
            return True
            
    except json.JSONDecodeError as e:
        print(f"  ❌ Error al parsear JSON: {e}")
        return False
    except Exception as e:
        print(f"  ❌ Error al leer JSON: {e}")
        return False

def calcular_tamanos():
    """Calcula tamaños totales de archivos"""
    print("\n💾 Calculando tamaños...")
    
    total_pdfs = 0
    total_imgs = 0
    
    pdf_dir = Path('output/pdfs')
    if pdf_dir.exists():
        for file in pdf_dir.glob('*.pdf'):
            total_pdfs += file.stat().st_size
    
    img_dir = Path('output/imagenes')
    if img_dir.exists():
        for file in img_dir.glob('*.png'):
            total_imgs += file.stat().st_size
    
    csv_path = Path('output/metadatos_constancias.csv')
    csv_size = csv_path.stat().st_size if csv_path.exists() else 0
    
    json_path = Path('output/metadatos_constancias.json')
    json_size = json_path.stat().st_size if json_path.exists() else 0
    
    total = total_pdfs + total_imgs + csv_size + json_size
    
    print(f"  📄 PDFs: {total_pdfs:,} bytes ({total_pdfs/1024:.1f} KB)")
    print(f"  🖼️  Imágenes: {total_imgs:,} bytes ({total_imgs/1024:.1f} KB)")
    print(f"  📊 CSV: {csv_size:,} bytes ({csv_size/1024:.1f} KB)")
    print(f"  📋 JSON: {json_size:,} bytes ({json_size/1024:.1f} KB)")
    print(f"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"  💾 Total: {total:,} bytes ({total/1024:.1f} KB)")
    
    return total

def listar_archivos():
    """Lista todos los archivos generados"""
    print("\n📁 Archivos generados:")
    
    output_dir = Path('output')
    if not output_dir.exists():
        print("  ❌ Directorio output no existe")
        return
    
    archivos = []
    
    for root, dirs, files in os.walk(output_dir):
        for file in files:
            filepath = Path(root) / file
            archivos.append(filepath)
    
    archivos.sort()
    
    for archivo in archivos:
        rel_path = archivo.relative_to(Path('.'))
        size = archivo.stat().st_size
        print(f"  • {rel_path} ({size:,} bytes)")
    
    print(f"\n  Total archivos: {len(archivos)}")

def main():
    """Función principal de validación"""
    print("="*70)
    print("VALIDACIÓN DE CONSTANCIAS GENERADAS")
    print("Cliente: Unstructured Docs")
    print("="*70)
    
    resultados = {
        'PDFs': validar_pdfs(),
        'Imágenes': validar_imagenes(),
        'CSV': validar_csv(),
        'JSON': validar_json()
    }
    
    calcular_tamanos()
    listar_archivos()
    
    print("\n" + "="*70)
    print("RESUMEN DE VALIDACIÓN")
    print("="*70)
    
    for categoria, resultado in resultados.items():
        estado = "✅ CORRECTO" if resultado else "❌ ERROR"
        print(f"  {categoria:15} {estado}")
    
    print("="*70)
    
    if all(resultados.values()):
        print("\n✅ TODOS LOS ARCHIVOS VALIDADOS CORRECTAMENTE")
        print("\n🎯 Próximos pasos:")
        print("   1. Revisar archivos en output/")
        print("   2. Ejecutar setup_cortex_search.sql en Snowflake")
        print("   3. Cargar PDFs con comando PUT")
        print("   4. Probar búsquedas con Cortex Search")
        print("\n📖 Consulta GUIA_RAPIDA.md para más detalles")
    else:
        print("\n⚠️  SE ENCONTRARON ERRORES")
        print("   Revisa los mensajes anteriores y regenera los archivos si es necesario")
        print("\n   Para regenerar:")
        print("   python3 generar_constancias_sat.py")
        print("   python3 generar_metadatos_csv.py")
    
    print("="*70)
    
    return all(resultados.values())

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)



