# Verificar dependencias
check-dependencies:
	@echo "Verificando dependencias..."
	@command -v kubectl >/dev/null || { echo "kubectl no está instalado. Por favor instálalo."; exit 1; }
	@command -v helm >/dev/null || { echo "helm no está instalado. Por favor instálalo."; exit 1; }
	@command -v docker >/dev/null || { echo "docker no está instalado. Por favor instálalo."; exit 1; }
	@command -v kind >/dev/null || { echo "kind no está instalado. Por favor instálalo."; exit 1; }
	@echo "Todas las dependencias están instaladas."