global main

extern printf
extern gets
extern sscanf

section .data
  msjIngreseCantObjetos db "Ingrese los cantidad (hasta 20 inclusive) de objetos a empaquetar: ",0
  contador dq 0
  formatoNum db "%lli",0

  msjSeparador db "-------------------------------------------------------------",10,0
  msjBienvenida db "Hola. Se le pedira que ingrese la cantidad de objetos que deben ser enviados por correo (entre 1 y 20 inclusive), y luego debera ingresar el peso (hasta 11 kg) y destino (M = Mar del Plata, B = Bariloche, P = Posadas) de cada uno de los objetos.",10,0
  msjIngreseUnPeso db "Ingrese el peso del objeto %lli: ",0
  msjErrorIngresarCantObjetos db "La cantidad de objetos ingresada no es valida. Se le pedira ingresarla nuevamente.",10,0
  msjErrorIngresarPeso db "El peso ingresado no es valido. Se le pedira ingresarlo nuevamente.",10,0
  msjIngreseUnDestino db "Ingrese el destino del objeto %lli: ",0
  msjErrorIngresarDestino db "El destino ingresado no es valido. Se le pedira ingresarlo nuevamente.",10,0
  msjSeListaranLosPaquetes db "Se listaran ahora los paquetes con sus respectivos destinos:",10,0
  msjImprimirNumeroDeObjetoInicial db " Objeto %lli",0 ;Se imprime el numero del objeto del principio del paquete
  msjImprimirNumeroDeObjeto db " + Objeto %lli",0 ;Se imprime el numero de uno de los objetos del paquete
  msjImprimirPeso db " (Peso %lli)",0 ;Se imprime el peso de uno de los objetos del paquete
  msjPaqueteConDestinoMarDelPlata db 10,"Paquete con destino a Mar del Plata:",0
  msjPaqueteConDestinoBariloche db 10,"Paquete con destino a Bariloche:",0
  msjPaqueteConDestinoPosadas db 10,"Paquete con destino a Posadas:",0

  vectorDestinosPosibles db "MBP" ;Es el vector que contiene los destinos posibles (se utiliza para validar el ingreso de los destinos)

  vectorPesos times 20 dq 0
              dq -1 ;Es el vector que contiene los "n" pesos de los "n" objetos (finaliza en -1, si hay menos de 20 objetos el peso es 0)

  vectorDestinos times 20 db "*"
                 db 0 ;Es el vector que contiene los "n" destinos de los "n" objetos (finaliza en 0, si hay menos de 20 objetos el destino es *)

  msjDebug db "Paso por aca",10,0
  msjDebugNum db "El numero es: %lli",10,0
  msjDebugCar db "El caracter es: %c",10,0

section .bss
  cantObjetos resq 1 ;La cantidad de objetos ingresados ("n" en la consigna)
  cantObjetosNum resq 1 ;Es la conversion a numero
  peso resq 1 ;Es el ultimo peso ingresado
  pesoNum resq 1 ;Es la conversion a numero
  destino resb 1 ;Es el ultimo destino ingresado
  pesoPaquete resq 1 ;Es el peso del paquete a armar
  destinoPaquete resb 1 ;Es el destino del paquete a armar

section .text
main:
    mov rbp, rsp; for correct debugging

  ;Imprimo mensaje separador
  mov rcx,msjSeparador
  sub rsp,32
  call printf
  add rsp,32

  ;Imprimo el mensaje de bienvenida
  mov rcx,msjBienvenida
  sub rsp,32
  call printf
  add rsp,32

  ;Se ingresan la cantidad de objetos (donde la cantidad es "n")
  sub rsp,32
  call ingresarCantObjetos
  add rsp,32

  ;Se ingresan los pesos y destinos de los "n" objetos
  sub rsp,32
  call ingresarNPesosYDestinos
  add rsp,32

  ;Ya se validaron los datos ingresados, ahora se arman los paquetes

  ;Imprimo mensaje separador
  mov rcx,msjSeparador
  sub rsp,32
  call printf
  add rsp,32

  ;Imprimo mensaje de que se van a armar los paquetes
  mov rcx,msjSeListaranLosPaquetes
  sub rsp,32
  call printf
  add rsp,32

  ;Se arman los paquetes
  sub rsp,32
  call armarPaquetes
  add rsp,32

  ;Voy al fin de programa
  jmp finDePrograma

ingresarCantObjetos:

  ;Imprimo mensaje separador
  mov rcx,msjSeparador
  sub rsp,32
  call printf
  add rsp,32

  ;Pido que ingrese la cantidad de objetos
  mov rcx,msjIngreseCantObjetos
  sub rsp,32
  call printf
  add rsp,32

  ;Lo almaceno en "cantObjetos"
  mov rcx,cantObjetos
  sub rsp,32
  call gets
  add rsp,32

  ;Lo convierto a numero y almaceno en "cantObjetosNum"
  mov rcx,cantObjetos
  mov rdx,formatoNum
  mov r8,cantObjetosNum
  sub rsp,32
  call sscanf
  add rsp,32

  ;Valido que sea haya ingresado un numero (rax tiene que ser 1)
  cmp rax,1
  jl errorIngresarCantObjetos

  ;Verifico que el numero este entre 1 y 20, sino error
  cmp qword[cantObjetosNum],1
  jl errorIngresarCantObjetos

  cmp qword[cantObjetosNum],20
  jg errorIngresarCantObjetos

  ;Vuelvo al main
  ret

errorIngresarCantObjetos:

  ;Imprimo mensaje separador
  mov rcx,msjSeparador
  sub rsp,32
  call printf
  add rsp,32

  ;Imprimo mensaje de que hubo un error
  mov rcx,msjErrorIngresarCantObjetos
  sub rsp,32
  call printf
  add rsp,32

  ;Vuelvo a pedirle que ingrese la cantidad de objetos
  jmp ingresarCantObjetos 

ingresarNPesosYDestinos:

  ;Loop hasta que se terminan de ingresar los n pesos y destinos (el contador es igual que la cantidad de objetos)
  mov r12,[contador]
  cmp r12,[cantObjetosNum]
  je regresar

  ;Le agrego 1 al r12 para imprimir el mensaje
  inc r12

ingresarPeso:

  ;Imprimo mensaje separador
  mov rcx,msjSeparador
  sub rsp,32
  call printf
  add rsp,32

  ;Pido que ingrese el peso del objeto
  mov rcx,msjIngreseUnPeso
  mov rdx,r12 ;En r12 esta el contador + 1
  sub rsp,32
  call printf
  add rsp,32

  ;Lo almaceno en "peso"
  mov rcx,peso
  sub rsp,32
  call gets
  add rsp,32

  ;Convierto el peso a numero (y lo almaceno en "pesoNum")
  mov rcx,peso
  mov rdx,formatoNum
  mov r8,pesoNum
  sub rsp,32
  call sscanf
  add rsp,32

validarPesoIngresado:

  ;Valido que se haya ingresado un numero (rax tiene que ser 1)
  cmp rax,1
  jl errorIngresarPeso

  ;Valido el peso del objeto (tiene que ser mayor a 0 y menor o igual a 11)
  cmp qword[pesoNum],0
  jle errorIngresarPeso
  
  cmp qword[pesoNum],11 ;Como el peso del paquete no puede ser mayor a 11 kilos, entonces el peso de ningun objeto puede serlo
  jg errorIngresarPeso

ingresarDestino:

  ;Pido que ingrese un destino
  mov rcx,msjIngreseUnDestino
  mov rdx,r12 ;En r12 esta el contador + 1
  sub rsp,32
  call printf
  add rsp,32

  ;Lo almaceno en "destino"
  mov rcx,destino
  sub rsp,32
  call gets
  add rsp,32

validarDestinoIngresado:

  ;Inicializo rbx en 0 para verificar los destinos posibles
  mov rbx,0

_validarDestinoIngresado:

  ;Si rbx es mayor que 2, entonces hubo un error porque no encontro el destino ingresado entre los destinos posibles
  cmp rbx,2
  jg errorIngresarDestino

  ;Verifico que el destino se encuentre entre los destinos posibles
  mov rcx,1
  lea rsi,[destino]
  lea rdi,[vectorDestinosPosibles + rbx]
  repe cmpsb
  je _ingresarNPesosYDestinos ;Si son iguales, el destino ingresado es valido, entonces se continua el loop para el siguiente objeto

  ;Incremento rbx en 1 (para comparar con el siguiente destino posible)
  inc rbx
  
  ;Loop incondicional
  jmp _validarDestinoIngresado

_ingresarNPesosYDestinos:

  ;Si llego hasta aca, se valido exitosamente el peso y destino ingresado, y se encuentran almacenados en "pesoNum" y "destino" respectivamente

  ;Se almacena el peso en el vector
  call almacenarPesoEnVector ;Ahora el peso del objeto "n" quedara guardado en la posicion "n" del vector

  ;Se almacena el destino en el vector
  call almacenarDestinoEnVector ;Ehora el destino del objeto "n" quedara guardado en la posicion "n" del vector
  
  ;Continua el loop para el siguiente objeto

  ;Incremento el contador
  inc qword[contador]

  ;Loop incondicional (pasamos al siguiente objeto)
  jmp ingresarNPesosYDestinos

errorIngresarPeso:

  ;Imprimo mensaje de que hubo un error
  mov rcx,msjErrorIngresarPeso
  sub rsp,32
  call printf
  add rsp,32

  ;Vuelvo a pedirle que ingrese el peso del objeto
  jmp ingresarPeso

errorIngresarDestino:

  ;Imprimo mensaje de que hubo un error
  mov rcx,msjErrorIngresarDestino
  sub rsp,32
  call printf
  add rsp,32

  ;Vuelvo a pedirle que ingrese el destino del objeto
  jmp ingresarDestino

almacenarPesoEnVector:

  ;Calculo el desplazamiento (recordemos que en "contador" tenemos el "n - 1" del objeto)
  mov rbx,[contador]
  imul rbx,8 ;El 8 sale de la longitud del elemento (ahora me queda en rbx el desplazamiento)

  mov r10,[pesoNum]
  mov [vectorPesos + rbx],r10

  ;Fin del call
  ret

almacenarDestinoEnVector:

  ;Calculo el desplazamiento (recordemos que en "contador" tenemos el "n - 1" del objeto)
  mov rbx,[contador]
  imul rbx,1 ;El 1 sale de la longitud del elemento (es redundante, pero bueno. Ahora me queda en rbx el desplazamiento)

  mov r10b,[destino] ;Uso el "b" porque es 1 byte (1 caracter) lo que quiero almacenar en el vector (y es el tamaño de destino)
  mov [vectorDestinos + rbx],r10b

  ;Fin del call
  ret

armarPaquetes:

  ;Inicializo el peso del paquete en 0
  mov qword[pesoPaquete],0
  
  ;Inicializo el contador en 0 (lo voy a utilizar para el desplazamiento)
  mov qword[contador],0

  ;Me pongo a iterar en el vector de pesos hasta encontrar un objeto que no tenga peso 0 (y a partir de dicho objeto armo el paquete)

_armarPaquetes:

  ;Calculo el desplazamiento
  mov rbx,[contador] ;No le resto 1 porque el contador ya lo inicialice en 0
  imul rbx,8 ;El 8 sale de la longitud del elemento

  ;Me guardo el peso del objeto en r12
  mov r12,[vectorPesos + rbx]

  ;Si el peso del objeto es -1, entonces ya termine de armar todos los paquetes (se termino el vector, todos los objetos tienen peso 0, es decir ya se agregaron al paquete)
  cmp r12,-1
  je regresar ;Vuelvo al main para que finalice el programa

  ;Si el peso del objeto es distinto a 0, entonces todavia no se agrego a ningun paquete (lo agrego)
  cmp r12,0
  jne armarNuevoPaquete

  ;Incremento el contador en 1 (para pasar al siguiente objeto)
  inc qword[contador]

  ;Loop incondicional (sigo buscando el siguiente objeto)
  jmp _armarPaquetes

armarNuevoPaquete:

  ;Agrego el peso del objeto al nuevo paquete
  add qword[pesoPaquete],r12 ;Recordemos que en r12 esta el peso del objeto

  ;Cambio el valor del peso del objeto en el vector a 0 (es como si lo estuviera quitando del vector para el algoritmo)
  mov qword[vectorPesos + rbx],0 ;Recordemos que en rbx teniamos el desplazamiento para el vector de pesos

  ;Calculo el desplazamiento para el vector de destinos
  mov rbx,[contador] ;No le resto 1 porque el contador lo inicialice en 0
  imul rbx,1 ;El 1 sale de la longitud del elemento (redundante, pero bueno)

  ;Me guardo el destino de este nuevo paquete (que es el destino de dicho objeto)
  mov rcx,1
  lea rsi,[vectorDestinos + rbx]
  lea rdi,[destinoPaquete]
  rep movsb

  ;Empiezo a imprimir el paquete
  sub rsp,32
  call imprimirDestinoDelPaquete ;Primero imprimo su destino
  add rsp,32

  mov rcx,msjImprimirNumeroDeObjetoInicial
  mov rdx,[contador]
  add rdx,1 ;Le sumo 1 al rdx para que imprimir el numero del objeto
  sub rsp,32
  call printf ;Imprimo el numero del objeto
  add rsp,32

  mov rcx,msjImprimirPeso
  mov rdx,r12
  sub rsp,32
  call printf ;Imprimo el primer peso del paquete
  add rsp,32

agregarObjetosAlPaquete:

  ;Incremento el contador para pasar al siguiente objeto
  inc qword[contador]

_agregarObjetosAlPaquete:

  ;Vuelvo a calcular el desplazamiento para el vector de pesos
  mov rbx,[contador] ;Como el contador arranco en 0, no hace falta restarle 1
  imul rbx,8 ;El 8 sale de la longitud del elemento

  ;Me guardo el peso del objeto actual en r12
  mov r12,[vectorPesos + rbx]

  ;Si el peso es -1 ya termine de armar el paquete (ya itere todo el vector de pesos y no encontre mas objetos candidatos a sumarse al paquete)
  cmp r12,-1
  je armarPaquetes

  ;Si el peso es 0 sigo iterando
  cmp r12,0
  je agregarObjetosAlPaquete

  ;Si llego hasta aca el peso no es 0, entonces es posible candidato. Hay que ver si la suma de los pesos no supera 11 kgs y coincide con el destino del paquete

  ;Veo si la suma de los pesos no supera 11 kgs
  add [pesoPaquete],r12 ;En r12 esta el peso del objeto actual
  cmp qword[pesoPaquete],11
  jg superaPesoMaximo

  ;La suma de los pesos no supera 11 kgs. Si el destino coincide se agrega el objeto al paquete

  ;Vuelvo a calcular el desplazamiento para el vector de destinos
  mov rbx,[contador] ;Como el contador arranca en 0, no hace falta restarle 1
  imul rbx,1 ;El 1 sale de la longitud del elemento (redundante, pero bueno)

  ;Me guardo el destino del objeto en r10b
  mov r10b,[vectorDestinos + rbx]

  ;Veo si el destino del objeto coincide con el del paquete
  cmp r10b,[destinoPaquete]
  jne destinoNoCoincide

seAgregaElObjetoAlPaquete:

  ;Si llego hasta aca, hay que agregarlo
  mov rcx,msjImprimirNumeroDeObjeto
  mov rdx,[contador]
  add rdx,1 ;Le sumo 1 para imprimir el numero del objeto correctamente
  sub rsp,32
  call printf
  add rsp,32

  mov rcx,msjImprimirPeso
  mov rdx,r12
  sub rsp,32
  call printf ;Imprimo el peso del paquete
  add rsp,32

  ;Ahora lo tengo que eliminar del vector de pesos

  ;Vuelvo a calcular el desplazamiento para el vector de pesos
  mov rbx,[contador] ;Como el contador arranco en 0, no hace falta restarle 1
  imul rbx,8 ;El 8 sale de la longitud del elemento

  ;Lo elimino del vector de pesos
  mov qword[vectorPesos + rbx],0

  ;Loop incondicional. Pasamos al siguiente objeto
  jmp agregarObjetosAlPaquete

superaPesoMaximo:

  ;Si llego hasta aca es porque el peso es del paquete iba a ser mayor a 11. Le resto el peso del objeto que sume al peso total del paquete y continuo iterando
  sub [pesoPaquete],r12
  jmp agregarObjetosAlPaquete

destinoNoCoincide:

  ;Si llego hasta aca es porque el destino del objeto no es el mismo que el del paquete. Le resto el peso del objeto que sume al peso total del paquete y continuo iterando
  sub [pesoPaquete],r12
  jmp agregarObjetosAlPaquete

imprimirDestinoDelPaquete:

  ;En funcion del "destinoPaquete" busco el destino pertinente (M = "Mar del Plata", B = "Bariloche", P = "Posadas")
  cmp byte[destinoPaquete],"M"
  je destinoPaqueteEsMarDelPlata

  cmp byte[destinoPaquete],"B"
  je destinoPaqueteEsBariloche

  cmp byte[destinoPaquete],"P"
  je destinoPaqueteEsPosadas

destinoPaqueteEsMarDelPlata:

  ;Se imprime el destino del paquete a Mar del Plata
  mov rcx,msjPaqueteConDestinoMarDelPlata
  sub rsp,32
  call printf ;Imprimo su destino
  add rsp,32

  ;Se finaliza el llamado del call
  jmp regresar

destinoPaqueteEsBariloche:

  ;Se imprime el destino del paquete a Bariloche
  mov rcx,msjPaqueteConDestinoBariloche
  sub rsp,32
  call printf ;Imprimo su destino
  add rsp,32

  ;Se finaliza el llamado del call
  jmp regresar

destinoPaqueteEsPosadas:

  ;Se imprime el destino del paquete a Posadas
  mov rcx,msjPaqueteConDestinoPosadas
  sub rsp,32
  call printf ;Imprimo su destino
  add rsp,32

  ;Se finaliza el llamado del call
  jmp regresar

regresar:

  ret ;Utilizado para finalizar un "call"

finDePrograma:

  ret ;Finaliza el programa