# CampusTareas Kubernetes

API Node.js, PostgreSQL y cliente web desplegados en un clúster kind de tres nodos.

Requisitos: Docker en modo Linux, kubectl, kind y PowerShell.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/01-Desplegar.ps1
```

- API NodePort: http://localhost:8080/v1/info
- Cliente web: ejecutar `scripts/04-Web.ps1` y abrir http://localhost:8081.
- Métricas y HPA: `scripts/02-Metricas.ps1`, `scripts/03-Escalado.ps1` y `scripts/03-Escalado.ps1 -DetenerCarga`.
- Retos: scripts 05 a 08; restaurar el nodo con `scripts/05-Interrupciones.ps1 -RestaurarNodo` antes de continuar.
- Ingress: http://campustareas.localhost, tras ejecutar el script 08. Sustituye la exposición NodePort de la API por ClusterIP.
- Limpieza: `scripts/09-Limpiar.ps1`. Elimina el clúster y sus volúmenes locales.

El Secret contiene credenciales de demostración indicadas por la práctica. No deben utilizarse en producción. La migración a StatefulSet se realiza sin escrituras concurrentes y conserva una copia de la base en `resultados/`, excluida de Git.
