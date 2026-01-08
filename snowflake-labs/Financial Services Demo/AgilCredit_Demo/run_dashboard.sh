#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
#                    AGILCREDIT - INTELLIGENCE COSTS DASHBOARD
#                         Script de Inicio Rápido
# ═══════════════════════════════════════════════════════════════════════════

echo "🚀 Iniciando AgilCredit Intelligence Costs Dashboard..."
echo ""

# Verificar si streamlit está instalado
if ! command -v streamlit &> /dev/null
then
    echo "❌ Streamlit no está instalado."
    echo ""
    echo "📦 Instalando dependencias..."
    pip install -r requirements_dashboard.txt
    echo ""
fi

# Verificar archivo principal
if [ ! -f "agilcredit_intelligence_costs_dashboard.py" ]; then
    echo "❌ Error: No se encuentra el archivo agilcredit_intelligence_costs_dashboard.py"
    echo "   Asegúrate de estar en el directorio correcto."
    exit 1
fi

echo "✅ Todo listo!"
echo ""
echo "📊 Abriendo dashboard en tu navegador..."
echo "   URL: http://localhost:8501"
echo ""
echo "💡 Tip: Configura tus credenciales de Snowflake en la barra lateral"
echo ""
echo "🛑 Para detener el dashboard, presiona Ctrl+C"
echo ""
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

# Ejecutar streamlit
streamlit run agilcredit_intelligence_costs_dashboard.py --server.port=8501 --server.address=localhost



