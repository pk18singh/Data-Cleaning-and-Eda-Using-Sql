SELECT * FROM sql_cx_live.laptop;
use sql_cx_live;
select * from laptop;

ALTER TABLE laptop MODIFY COLUMN Inches DECIMAL(10,1);

ALTER TABLE laptop RENAME COLUMN `Unnamed: 0` TO  indexes;

UPDATE laptop l1
JOIN (
    SELECT indexes, REPLACE(Ram, 'GB', '') AS new_Ram
    FROM laptop
) l2 ON l1.indexes = l2.indexes
SET l1.Ram = l2.new_Ram;

ALTER TABLE laptop MODIFY COLUMN Ram INTEGER;

select data_length/1024  from information_schema.TABLES
where table_schema = 'sql_cx_live' and
table_name = 'laptop';


UPDATE laptop l1
JOIN (
    SELECT Weight, REPLACE(Weight, 'kg', '') AS new_weight
    FROM laptop
) l2 ON l1.Weight = l2.Weight
SET l1.Weight = l2.new_weight;

SELECT *
FROM laptop
WHERE Weight REGEXP '[^0-9.]';

UPDATE laptop
SET Weight = NULL
WHERE Weight REGEXP '[^0-9.]';

ALTER TABLE laptop MODIFY COLUMN Weight DECIMAL(10,1);

UPDATE laptop l1
JOIN (SELECT indexes, ROUND(Price) AS rounded_price
      FROM laptop) l2
ON l1.indexes = l2.indexes
SET l1.Price = l2.rounded_price;

select * from laptop;

SELECT DISTINCT OpSys FROM laptop;

SELECT OpSys,
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END AS 'os_brand'
FROM laptop;

UPDATE laptop
SET OpSys = 
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END;

SELECT * FROM laptop;

ALTER TABLE laptop
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

UPDATE laptop l1
JOIN (
    SELECT indexes, SUBSTRING_INDEX(Gpu, ' ', 1) AS gpu_brand
    FROM laptop
) l2 ON l1.indexes = l2.indexes
SET l1.gpu_brand = l2.gpu_brand;

UPDATE laptop l1
JOIN (
    SELECT indexes, gpu_brand, REPLACE(Gpu, gpu_brand, '') AS new_gpu_name
    FROM laptop
) l2 ON l1.indexes = l2.indexes
SET l1.gpu_name = l2.new_gpu_name;

ALTER TABLE laptop DROP COLUMN Gpu;

SELECT * FROM laptop;

ALTER TABLE laptop
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

UPDATE laptop l1
JOIN (
    SELECT indexes, SUBSTRING_INDEX(Cpu, ' ', 1) AS cpu_brand
    FROM laptop
) l2 ON l1.indexes = l2.indexes
SET l1.cpu_brand = l2.cpu_brand;


UPDATE laptop l1
JOIN (
    SELECT indexes, CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '') AS DECIMAL(10, 2)) 
    AS updated_speed
    FROM laptop
) l2 ON l1.indexes = l2.indexes
SET l1.cpu_speed = l2.updated_speed;

UPDATE laptop l1
JOIN (
    SELECT indexes, 
        REPLACE(
            REPLACE(Cpu, cpu_brand, ''),
            SUBSTRING_INDEX(REPLACE(Cpu, cpu_brand, ''), ' ', -1),
            ''
        ) AS updated_cpu_name
    FROM laptop
) l2 ON l1.indexes = l2.indexes
SET l1.cpu_name = l2.updated_cpu_name;

SELECT * FROM laptop;

ALTER TABLE laptop DROP COLUMN Cpu;

SELECT ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)
FROM laptop;

ALTER TABLE laptop 
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

UPDATE laptop
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);

ALTER TABLE laptop 
ADD COLUMN touchscreen INTEGER AFTER resolution_height;

SELECT ScreenResolution LIKE '%Touch%' FROM laptop;

UPDATE laptop
SET touchscreen = ScreenResolution LIKE '%Touch%';

ALTER TABLE laptop
DROP COLUMN ScreenResolution;

SELECT * FROM laptop;

SELECT cpu_name,
SUBSTRING_INDEX(TRIM(cpu_name),' ',2)
FROM laptop;

UPDATE laptop
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

ALTER TABLE laptop
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

SELECT Memory,
CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END AS 'memory_type'
FROM laptop;

UPDATE laptop
SET memory_type = CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;

SELECT Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
FROM laptop;

UPDATE laptop
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

SELECT 
primary_storage,
CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage,
CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END
FROM laptop;

UPDATE laptop
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

SELECT * FROM laptop;

ALTER TABLE laptop DROP COLUMN Memory;

ALTER TABLE laptop DROP COLUMN gpu_name;

SELECT * FROM laptop;


























