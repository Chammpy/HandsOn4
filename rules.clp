(deftemplate Paciente
   (slot nombre)
   (slot en-quirofano)
   (slot en-espera)
   (slot en-intervencion)
   (slot peso)
   (slot tipo-operacion))

(deftemplate CirujanoEnJefe
   (slot nombre)
   (slot en-espera))

(deftemplate Cirujano2
   (slot nombre)
   (slot en-espera))

(deftemplate EnfermeraAsistente
   (slot nombre)
   (slot en-espera))

(deftemplate Anestesiologo
   (slot nombre)
   (slot en-espera))

(deftemplate Evento
   (slot nombre)
   (slot ocurrido))

(deffacts base-conocimiento
   (Paciente (nombre Alberto) (en-quirofano no) (en-espera si) (en-intervencion no) (peso 70) (tipo-operacion cirugia-inmediata))
   (CirujanoEnJefe (nombre Armando) (en-espera si))
   (Cirujano2 (nombre Enrique) (en-espera si))
   (EnfermeraAsistente (nombre Hilda) (en-espera si))
   (Anestesiologo (nombre Lisseth) (en-espera si))
   (Evento (nombre comienzo-operacion) (ocurrido no))
   (Evento (nombre ordenar-anestesia) (ocurrido no))
   (Evento (nombre confirmar-sedacion) (ocurrido no))
   (Evento (nombre comenzar-intervencion) (ocurrido no))
   (Evento (nombre solicitar-material) (ocurrido no))
   (Evento (nombre realizar-intervencion) (ocurrido no))
   (Evento (nombre informar-finalizacion) (ocurrido no))
   (Evento (nombre llevar-a-recuperacion) (ocurrido no))
)

(defrule paciente-en-quirofano-en-espera-en-intervencion
   ?p <- (Paciente (nombre ?nombre) (en-quirofano no) (en-espera si) (en-intervencion no))
   ?c <- (CirujanoEnJefe (nombre ?cNombre) (en-espera si))
   ?c2 <- (Cirujano2 (nombre ?c2Nombre) (en-espera si))
   ?e <- (EnfermeraAsistente (nombre ?eNombre) (en-espera si))
   ?a <- (Anestesiologo (nombre ?aNombre) (en-espera si))
   ?ev <- (Evento (nombre comienzo-operacion) (ocurrido no))
   =>
   (printout t "Comienza el proceso de intervención." crlf)
   (printout t "Paciente: " ?nombre " - Cirujano en Jefe: " ?cNombre " - Cirujano 2: " ?c2Nombre " - Enfermera Asistente: " ?eNombre " - Anestesiólogo: " ?aNombre crlf)
   (modify ?p (en-intervencion si))
   (modify ?ev (ocurrido si))
)

(defrule ordenar-anestesia
   ?c <- (CirujanoEnJefe (nombre ?cNombre) (en-espera si))
   ?a <- (Anestesiologo (nombre ?aNombre) (en-espera si))
   ?p <- (Paciente (nombre ?nombre) (en-intervencion si))
   ?ev <- (Evento (nombre ordenar-anestesia) (ocurrido no))
   (Evento (nombre comienzo-operacion) (ocurrido si))
   =>
   (printout t "Cirujano en Jefe " ?cNombre " ordena al Anestesiólogo " ?aNombre " confirmar el cálculo del anestésico y aplicarlo al paciente " ?nombre "." crlf)
   (modify ?ev (ocurrido si))
)

(defrule confirmar-sedacion
   ?a <- (Anestesiologo (nombre ?aNombre) (en-espera si))
   ?c <- (CirujanoEnJefe (nombre ?cNombre) (en-espera si))
   ?p <- (Paciente (nombre ?nombre) (en-intervencion si) (peso ?peso))
   ?ev <- (Evento (nombre confirmar-sedacion) (ocurrido no))
   (Evento (nombre ordenar-anestesia) (ocurrido si))
   =>
   (bind ?sedante (/ (* ?peso 0.05) 20)) ; Calcular la cantidad de sedante según el peso
   (printout t "Anestesiólogo " ?aNombre " confirma al Cirujano en Jefe " ?cNombre " que el paciente " ?nombre " se encuentra sedado con " ?sedante " ml de sedante." crlf)
   (modify ?ev (ocurrido si))
)

(defrule comenzar-intervencion
   ?c2 <- (Cirujano2 (nombre ?c2Nombre) (en-espera si))
   ?c <- (CirujanoEnJefe (nombre ?cNombre) (en-espera si))
   ?p <- (Paciente (nombre ?nombre) (en-intervencion si))
   ?ev <- (Evento (nombre comenzar-intervencion) (ocurrido no))
   (Evento (nombre confirmar-sedacion) (ocurrido si))
   =>
   (printout t "Cirujano en Jefe " ?cNombre " ordena al Cirujano 2 " ?c2Nombre " que puede comenzar la intervención." crlf)
   (modify ?ev (ocurrido si))
)

(defrule solicitar-material
   ?c2 <- (Cirujano2 (nombre ?c2Nombre) (en-espera si))
   ?e <- (EnfermeraAsistente (nombre ?eNombre) (en-espera si))
   ?p <- (Paciente (nombre ?nombre) (en-intervencion si) (tipo-operacion ?tipo-operacion))
   ?ev <- (Evento (nombre solicitar-material) (ocurrido no))
   (Evento (nombre comenzar-intervencion) (ocurrido si))
   =>
   (if (eq ?tipo-operacion cirugia-inmediata)
      then
      (printout t "Cirujano 2 " ?c2Nombre " solicita láser y lupa a la Enfermera Asistente " ?eNombre "." crlf)
      else
      (printout t "Cirujano 2 " ?c2Nombre " solicita bisturí, pinzas, tubo de extracción a la Enfermera Asistente " ?eNombre "." crlf)
   )
   (modify ?ev (ocurrido si))
)

(defrule realizar-intervencion
   ?c2 <- (Cirujano2 (nombre ?c2Nombre) (en-espera si))
   ?ev <- (Evento (nombre realizar-intervencion) (ocurrido no))
   (Evento (nombre solicitar-material) (ocurrido si))
   =>
   (printout t "Cirujano 2 " ?c2Nombre " realiza la intervención." crlf)
   (modify ?ev (ocurrido si))
)

(defrule informar-finalizacion
   ?c2 <- (Cirujano2 (nombre ?c2Nombre) (en-espera si))
   ?c <- (CirujanoEnJefe (nombre ?cNombre) (en-espera si))
   ?ev <- (Evento (nombre informar-finalizacion) (ocurrido no))
   (Evento (nombre realizar-intervencion) (ocurrido si))
   =>
   (printout t "Cirujano 2 " ?c2Nombre " informa al Cirujano en Jefe " ?cNombre " sobre la finalización de la intervención." crlf)
   (modify ?ev (ocurrido si))
)

(defrule llevar-a-recuperacion
   ?e <- (EnfermeraAsistente (nombre ?eNombre) (en-espera si))
   ?p <- (Paciente (nombre ?nombre) (en-intervencion si))
   ?ev <- (Evento (nombre llevar-a-recuperacion) (ocurrido no))
   (Evento (nombre informar-finalizacion) (ocurrido si))
   =>
   (printout t "Al finalizar la intervención, la Enfermera Asistente " ?eNombre " lleva al paciente " ?nombre " a la Sala de Recuperación." crlf)
   (modify ?ev (ocurrido si))
)