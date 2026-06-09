--Actividad 1:
-- ====================================================================
-- PLAN DE RESPALDO Y RECUPERACIÓN (ESQUEMA: curso_topicos)
-- ====================================================================
-- Frecuencia del Full Backup: Todos los sábados a medianoche.
-- Frecuencia del Incremental: Lunes a viernes al finalizar la jornada.
-- Política de Retención: 7 días de ventana de recuperación (1 semana).
-- Destino: Almacenamiento local en disco (/u01/backup).
-- ====================================================================

-- Conexión a la herramienta de respaldos físicos
rman target /

-- 1. Configuraciones iniciales del entorno
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/u01/backup/mi_respaldo_%U';
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;

-- 2. Ejecución del Respaldo Completo (Full)
RUN {
    BACKUP DATABASE PLUS ARCHIVELOG;
    DELETE OBSOLETE;
}

-- 3. Ejecución del Respaldo Incremental (Diario)
RUN {
    BACKUP INCREMENTAL LEVEL 1 DATABASE;
    BACKUP ARCHIVELOG ALL;
}

-- 4. Verificación en consola de los respaldos generados
LIST BACKUP;

--Actividad 2:

--Eliminacion de la tabla Productos para provocar el error ORA-00942
DROP TABLE Productos;
SELECT Nombre, Precio FROM Productos;
--Recuperación mediante Flashback Table
FLASHBACK TABLE Productos TO BEFORE DROP;
--Verificación de la recuperación
SELECT Nombre, Precio FROM Productos;

-- ALTERNATIVA: RECUPERACIÓN MEDIANTE RMAN 
rman target /
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;

RUN {
    RESTORE TABLE curso_topicos.Productos;
    RECOVER TABLE curso_topicos.Productos;
}
ALTER DATABASE OPEN;
--Verificación de la recuperación
SELECT Nombre, Precio FROM Productos;
  