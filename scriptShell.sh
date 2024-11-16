#!/bin/bash

#Definir rutas del proyecto original y copia
RUTA_PROYECTO_ORIGINAL="/home/flavioabdon/Escritorio/Proyecto"  # Cambia esta ruta
RUTA_PROYECTO_COPIA="/home/flavioabdon/Escritorio/Proyecto-Copia"        # Cambia esta ruta

# Función para pedir y cambiar la fecha
cambiar_fecha() {
    echo "Introduce la fecha para este commit (formato: AAAA-MM-DD HH:MM:SS):"
    read fecha
    echo "Desactivando sincronización automática de hora..."
    sudo timedatectl set-ntp false
    echo "Cambiando la fecha a $fecha..."
    sudo timedatectl set-time "$fecha"
    echo "Estado actual del tiempo del sistema:"
    timedatectl status
}

#Crear la carpeta proyecto-copia si no existe
mkdir -p "$RUTA_PROYECTO_COPIA"

#Ir al directorio del proyecto original
cd "$RUTA_PROYECTO_ORIGINAL" || { echo "Ruta inválida: $RUTA_PROYECTO_ORIGINAL"; exit 1; }

#Obtener lista de commits en orden cronológico
commits=$(git rev-list --reverse HEAD)

#Inicializar el repositorio copia
cd "$RUTA_PROYECTO_COPIA" || { echo "Error al cambiar a $RUTA_PROYECTO_COPIA"; exit 1; }
git init

#Procesar cada commit
cd "$RUTA_PROYECTO_ORIGINAL" || exit
for commit in $commits; do
    # Cambiar al commit actual
    git checkout "$commit"

    # Eliminar archivos del proyecto copia
    echo "Eliminando archivos en $RUTA_PROYECTO_COPIA..."
    rm -rf "$RUTA_PROYECTO_COPIA"/*

    mensaje_commit=$(git log -1 --pretty=%B "$commit")

    # Copiar los archivos del commit actual al proyecto copia
    echo "Copiando archivos del commit $commit al proyecto copia..."
    cp -r ./* "$RUTA_PROYECTO_COPIA/"

    # Cambiar al directorio del proyecto copia
    cd "$RUTA_PROYECTO_COPIA" || exit

    # Pedir y cambiar la fecha para este commit
    cambiar_fecha

    # Agregar archivos y hacer el commit
    git add .
    
    echo "Mensaje del commit original: $mensaje_commit"
    echo "Introduce el mensaje para el nuevo commit (deja vacío para usar el original):"
    read mensaje_nuevo
    if [[ -z "$mensaje_nuevo" ]]; then
        mensaje_nuevo="$mensaje_commit"
    fi
    git commit -m "$mensaje_nuevo"

    # Volver al directorio del proyecto original para el siguiente commit
    cd "$RUTA_PROYECTO_ORIGINAL" || exit
done

echo "Proceso completado. Restaurando sincronización automática de hora..."
sudo timedatectl set-ntp true
