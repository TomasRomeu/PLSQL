USE  SERVEROUTPUT ON;

--1º
CREATE TABLE CL_PERSONA 
(
ID_PERSONA INTEGER NOT NULL,
DESC_PERSONA VARCHAR2 (50 BYTE),
RELACION_MASCOTA VARCHAR2 (20 BYTE),
CONSTRAINT CL_PERSONA_PK PRIMARY KEY (ID_PERSONA)
);

--2º
CREATE TABLE CL_ESPECIE 
(
ID_ESPECIE CHAR (3 BYTE),
DESC_ESPECIE VARCHAR2 (25 BYTE),
CONSTRAINT CL_ESPECIE_PK PRIMARY KEY (ID_ESPECIE)
);

--3º
CREATE TABLE CL_FAMILIA (
ID_FAMILIA INTEGER,
DESC_FAMILIA VARCHAR2 (50 BYTE),
TELEFONO VARCHAR2 (50 BYTE),
PAIS VARCHAR2 (50 BYTE),
PROVINCIA VARCHAR2 (50 BYTE),
CIUDAD VARCHAR2 (50 BYTE),
BARRIO VARCHAR2 (50 BYTE),
DIRECCION VARCHAR2 (50 BYTE),
CONSTRAINT CL_FAMILIA_PK PRIMARY KEY (ID_FAMILIA)
);

--4º
CREATE TABLE CL_REL_FAMILIA_PERSONA 
(
ID_FAMILIA INTEGER NOT NULL,
ID_PERSONA INTEGER NOT NULL,
CONSTRAINT PK_FAMILIA_PERSONA PRIMARY KEY (ID_FAMILIA, ID_PERSONA),
CONSTRAINT FK_FAMILIA FOREIGN KEY (ID_FAMILIA) REFERENCES CL_FAMILIA (ID_FAMILIA),
CONSTRAINT FK_PERSONA FOREIGN KEY (ID_PERSONA) REFERENCES CL_PERSONA (ID_PERSONA)
);

--5º
CREATE TABLE CL_MASCOTA 
(
ID_MASCOTA INTEGER NOT NULL,
DESC_MASCOTA VARCHAR2 (40 BYTE),
ID_FAMILIA INTEGER NOT NULL,
ESPECIE CHAR (3 BYTE),
RAZA VARCHAR2 (30 BYTE),
FECHA_NACIMIENTO DATE,
CONSTRAINT PK_MASCOTA PRIMARY KEY (ID_MASCOTA, ID_FAMILIA),
CONSTRAINT FK_ESPECIE FOREIGN KEY (ESPECIE) REFERENCES CL_ESPECIE (ID_ESPECIE),
CONSTRAINT FK_FAMILIA_MASCOTA FOREIGN KEY (ID_FAMILIA) REFERENCES CL_FAMILIA (ID_FAMILIA)
);

--6º
CREATE TABLE CL_REGISTRO_MEDICO 
(
ID_REG_MEDICO INTEGER NOT NULL,
ID_MASCOTA INTEGER NOT NULL,
ID_FAMILIA INTEGER NOT NULL,
FECHA_CREACION DATE,
CONSTRAINT PK_REG_MED PRIMARY KEY (ID_REG_MEDICO),
CONSTRAINT FK_MASCOTA FOREIGN KEY (ID_MASCOTA, ID_FAMILIA) REFERENCES CL_MASCOTA (ID_MASCOTA, ID_FAMILIA)
);

--7º
CREATE TABLE CL_CITA 
(
ID_REG_MEDICO INTEGER NOT NULL,
NRO_CITA NUMBER (12),
DESC_CITA VARCHAR2 (30 BYTE),
COMENTARIO_CITA VARCHAR2 (100 BYTE),
VACUNA CHAR (1 BYTE),
FECHA_CITA DATE,
CONSTRAINT PK_CITA PRIMARY KEY (ID_REG_MEDICO,NRO_CITA),
CONSTRAINT FK_REG_MED FOREIGN KEY (ID_REG_MEDICO) REFERENCES CL_REGISTRO_MEDICO (ID_REG_MEDICO)
);

USE  SERVEROUTPUT ON;

DECLARE
    ID cl_especie.id_especie%TYPE := 01;      
    especies cl_especie.desc_especie%TYPE;
    TYPE v_tipos IS VARRAY(2) OF VARCHAR(20); 
    tipos v_tipos := v_tipos('PER', 'GAT'); 
BEGIN
    LOOP 
         especies := tipos(ID);
         INSERT INTO cl_especie VALUES (ID, especies);
         ID := ID + 1; 
         EXIT WHEN ID > 2;                   
    END LOOP; 
END;

select * from CL_ESPECIE;

USE  SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE 
carga_persona(
        v1_persona cl_persona.id_persona%TYPE,
        v2_persona cl_persona.desc_persona%TYPE,
        v3_persona cl_persona.relacion_mascota%TYPE
        )
AS 
BEGIN
FOR cont IN 0..50 
  LOOP  
            INSERT INTO cl_persona VALUES (cont,v2_persona,v3_persona);
  END LOOP;
END;

begin 
    carga_persona(1,'Persona','Dueño');
end;

select * from CL_PERSONA;

--FAMILIA
DECLARE
    numero_aleatorio_tel INTEGER; 
    numero_aleatorio_prov INTEGER; 
    numero_aleatorio_ciudad INTEGER; 
    desc_familia VARCHAR2(50); 
   
      TYPE v_tel IS VARRAY(4) OF VARCHAR(50); 
      aleatorio_tel v_tel := v_tel('643512', '756312', '512341','649020'); 
    
      TYPE v_prov IS VARRAY(9) OF VARCHAR(50); 
      aleatorio_prov v_prov := v_prov('La Pampa','Buenos Aires', 'Cordoba','Santa Fe', 'Mendoza', 'Misiones'
      ,'Neuquen','San Juan', 'San Luis');  
    
    pais cl_familia.pais%TYPE := 'Argentina';
    
      TYPE v_ciu IS VARRAY(11) OF VARCHAR(50); 
      aleatorio_ciudad v_ciu := v_ciu('Córdoba','Carlos Paz','Rio Cuarto', 'Vicuña Maquena', 'Alta Gracia'
      ,'Jesús María','Arroyito', 'Deán Funes', 'Colonia Caroya','Cosquín', 'Oncativo');
    
    barrio cl_familia.barrio%TYPE := 'Nueva Cordoba'; 
    direccion cl_familia.direccion%TYPE := 'San Lorenzo n/n'; 

BEGIN    
    FOR cont IN 1..20 
    LOOP 
        desc_familia := '0' || cont || 'Familia';
        
        numero_aleatorio_tel := dbms_random.VALUE(1,4);
        numero_aleatorio_prov := dbms_random.VALUE(1,9);
        numero_aleatorio_ciudad := dbms_random.VALUE(1,11);
        
        INSERT INTO cl_familia(id_familia, desc_familia, telefono, pais, provincia, ciudad, barrio, direccion)
        VALUES (cont, desc_familia,aleatorio_tel(numero_aleatorio_tel),pais, 
        aleatorio_prov(numero_aleatorio_prov), 
        aleatorio_ciudad(numero_aleatorio_ciudad), 
        barrio, direccion); 
         
     END LOOP;
END;

SELECT * FROM cl_familia;


--Relacional de Familia-Persona: Una familia puede estar conformada por una o más personas
DECLARE
    v_id_f cl_rel_familia_persona.id_familia%TYPE := 1;
BEGIN
    FOR counter_people IN 1..50
    LOOP 
        IF v_id_f <= 20 THEN
            INSERT INTO cl_rel_familia_persona VALUES (v_id_f,counter_people);/* el dato que se guardo en el contador*/
        ELSE 
            INSERT INTO cl_rel_familia_persona VALUES (v_id_f - 1,counter_people);
            v_id_f := 1;
        END IF;
        v_id_f := v_id_f + 1;
    END LOOP;
END;

SELECT * FROM cl_rel_familia_persona r inner join cl_persona p on r.id_persona=p.id_persona where r.id_familia = 2 ; /* consulta para ver que coincidan los datos insertados con lo de la consulta siguiente*/

SELECT id_familia, LISTAGG(id_persona, ', ') WITHIN GROUP (ORDER BY id_persona) AS lista_familias FROM cl_rel_familia_persona GROUP BY id_familia;

--INSERTAR MASCOTAS
DECLARE
    contador INT := 1;
    CURSOR cursorfamilia IS SELECT * FROM cl_familia; 
    familia cursorfamilia%rowtype ;
    fecha_nacimiento cl_mascota.fecha_nacimiento%TYPE;
    v_especie cl_especie.id_especie%TYPE;

BEGIN
OPEN cursorfamilia;
LOOP
FETCH cursorfamilia INTO familia;
    IF (MOD(contador,2)=0) THEN 
    v_especie := 'PER'; 
    ELSE
    v_especie := 'GAT';
    END IF;
    fecha_nacimiento := TO_DATE(TRUNC(dbms_random.VALUE(to_char(TO_DATE('01/01/1997','dd-mm-yyyy'),'J'),to_char(TO_DATE('01/01/2021','dd-mm-yyyy'),'J'))), 'J');
       IF (familia.id_familia <= 10) THEN
           INSERT INTO cl_mascota (id_mascota, desc_mascota, id_familia, especie, fecha_nacimiento)
           VALUES (contador, contador || '_Mascota', familia.id_familia , 'PER', fecha_nacimiento);
           INSERT INTO cl_mascota (id_mascota, desc_mascota, id_familia, especie, fecha_nacimiento)
           VALUES ((contador + 1), contador || '_Mascota', familia.id_familia , 'GAT', fecha_nacimiento);
          contador := contador + 2;
        ELSE
            INSERT INTO cl_mascota (id_mascota, desc_mascota, id_familia, especie, fecha_nacimiento)
           VALUES (contador, contador || '_Mascota', familia.id_familia , v_especie, fecha_nacimiento);
            contador := contador + 1;
    END IF;
    EXIT WHEN (contador > 30); 
    END LOOP;
    CLOSE cursorfamilia;
    END;

SELECT * FROM cl_mascota;

--REGISTRO MEDICO
declare
id_reg cl_registro_medico.id_reg_medico%type := 1;
id_mas cl_registro_medico.id_mascota%type;
id_flia cl_registro_medico.id_familia%type;
fecha cl_registro_medico.fecha_creacion%type;
cursor mascotas is select id_mascota, id_familia, fecha_nacimiento
from cl_mascota;
v_filas mascotas%rowtype;
cursor cantidad_flias is select count(*) from cl_mascota;
v_cant_flias number(8);
begin
    open mascotas;
    open cantidad_flias;
    loop
        fetch mascotas into v_filas;
        fetch cantidad_flias into v_cant_flias;
        insert into cl_registro_medico values (id_reg, v_filas.id_mascota, v_filas.id_familia, v_filas.fecha_nacimiento + 60);
        exit when id_reg = v_cant_flias;
        id_reg := id_reg + 1;
    end loop;
    close mascotas;
    close cantidad_flias;
END;

SELECT * FROM cl_registro_medico;

--CITA
DECLARE
CURSOR cur_cant_f IS SELECT * FROM CL_REGISTRO_MEDICO;
V_REG cur_cant_f%ROWTYPE;
contador INT := 1;
v_comentario CL_CITA.COMENTARIO_CITA%TYPE;
v_vacuna CL_CITA.VACUNA%TYPE;
BEGIN
  OPEN cur_cant_f;
 LOOP
     FETCH cur_cant_f INTO V_REG;
     if (mod(contador,2)=0) then
        v_vacuna := 'S';
        v_comentario := 'Vacunacion';
    ELSE
        v_vacuna := 'N';
        v_comentario := 'Consulta';
     END IF;

           INSERT INTO CL_CITA (ID_REG_MEDICO, NRO_CITA, DESC_CITA, COMENTARIO_CITA, VACUNA, FECHA_CITA)
           VALUES (V_REG.ID_REG_MEDICO,contador, contador || '_CITA', v_comentario , v_vacuna, v_reg.fecha_creacion + 60);
        contador := contador + 1;
    exit when (contador > 30);
    END LOOP;
 CLOSE cur_cant_f;
END;

SELECT * FROM cl_cita;