# Herramientas
 Códigos para navegación inicial
 
  
**INTRODUCCIÓN PRÁCTICA AL USO DEL SUPERCOMPUTADOR KABRÉ**
_Acceso y navegación básica_

Para acceder a kabré usted recibirá un usuario y contraseña, tome en cuenta que esta es temporal y durará únicamente el semestre de este curso.
_Acceso_
Para acceder utilizaremos el protocolo ssh (secure shell), este es un protocolo de comunicación de red que permite a dos computadoras comunicarse. ¿Funcionaría para una computadora personal? 
R/

 Para acceder a Kabré:
`ssh -X ssolano@kabre.cenat.ac.cr  `
#el dominio de acceso puede cambiar dependiendo de la entidad, al igual que el usuario por ejemplo: stefany@cluster.una.ac.cr
 
Seguidamente se le solicitará una clave, digítela (no verá el texto digitado, es normal).
Si desea cambiar la clave por algo más intuitivo digite:
`passwd`
Y siga las instrucciones que se le presentan en la pantalla (anote bien su clave)
##

_Navegación básica_
1. Para listar su unidad de trabajo:
`ls`
2. Acceda a la carpeta Semana1 y liste su contenido
`cd Semana1`
`ls`
`ls -l` #esta es otra forma de listar, le brinda los resultados en formato de lista, esto es lo que se conoce como un _argumento_
####
_En caso que deba descargar la carpeta desde su computadora local sigue los siguientes pasos_
a. Abra una terminal y ubíquese en la carpeta de descarga manualmente y desde allí digite:
`scp -r Semana1 usuario@kabre.cenat.ac.cr:/home/usuario/` seguidamente dé enter y digite su clave de acceso a kabré
_(más adelante veremos en detalle el comando scp)_

####
3. Lea el contenido del documento areA_prot.fasta
`less areA_prot.fasta`
`cat areA_prot.fasta`
`more areA_prot.fasta`
#investigue las diferencias de visualización entre estos tres comandos y asegurese de entender:
- ¿Cuál es más efectivo para ver el inicio de un archivo?
- ¿Cuál es más efectivo para ver documentos extensos y pesados?
- ¿Qué similitudes/diferencias nota entre estos?
Nota: es más fácil de evidenciar las diferencias con un documento más extenso

4. ¿Tiene idea de en qué folder o directorio se encuentra?, sino digite el comando pwd (print working directory)
`pwd` 

5. Movilícese hasta el folder anterior (utilice el comando cd -change directory- y cree una carpeta con su Nombre_y_apellido (todo en mayúscula).
`cd ../`
`mkdir STEFANY_SOLANO`

6. Dentro de esta carpeta genere una nueva que se llame Datos
`cd STEFANY_SOLANO`
`mkdir Datos`

7. Regresese al directorio anterior, utilizando el comando cd y cree una carpeta que se llame Notas.
`cd ../`
`mkdir Notas`

## Uso de comandos básicos para edición, manipulación y procesamiento de texto

Comando

