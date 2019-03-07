;Loan Application Evaluation

;Templates
(deftemplate applicant
	(slot live (default 0))
	(slot space (default 0))
	(slot kids (default 0))
	(slot exper (default 0))
	(slot otherpets (default 0))
	(slot personality (default 0))
	(slot barking (default 0))
	(slot playtime (default 0))
	(slot alonetime (default 0))
	(slot size (default 0))
	(slot shed (default 0))
	(slot noise (default 0)))
(deftemplate live-check (slot rating (default 0)))
(deftemplate space-check (slot rating (default 0)))
(deftemplate kids-check (slot rating (default 0)))
(deftemplate size-check (slot rating (default 0) ))
(deftemplate question (slot text) (slot type) (slot ident))
(deftemplate answer (slot ident) (slot text))
(deftemplate final-result (slot text))

;Questions
(deffacts questions
"The questions that are asked to the user by the system."
(question (ident live) (type number)
(text "Where will your dog live? <1>Apartment <2>House"))
(question (ident space) (type number)
(text "How much space will it have to play? <1>Small yard <2>Average yard <3>Huge yard"))
(question (ident kids) (type number)
(text "Do you have any kids? <1>Yes <2>No"))
(question (ident exper) (type number)
(text "Have you owned a dog before? <1>Yes <2>No"))
(question (ident otherpets) (type number)
(text "Do you have any other pets? <1>Yes <2>No"))
(question (ident personality) (type number)
(text "Which best describes your future pet’s personality? <1>Protective <2>Friendly")) 
(question (ident barking) (type number)
(text "In terms of barking, how much noise can you tolerate? <1>None <2>Barking is not an issue"))
(question (ident playtime) (type number)
(text "How much will your dog be able to play with you? <1>Indoors only <2>Everyday runs"))
(question (ident alonetime) (type number)
(text "How much time will your new dog be spending alone? <1>Less than 4 hours <2>More than 4 hours"))
(question (ident size) (type number)
(text "How big or small will your new dog be? <1>Small <2>Medium big <3>Huge"))
(question (ident shed) (type number)
(text "How important is having a dog that doesn't shed much? <1>Little shedding is okay <2>Shedding is not an issue"))
(question (ident noise) (type number)
(text "In terms of barking, how much noise can you tolerate? <1>None <2>Barking is not an issue")))

;Functions
(deffunction ask-user (?question)
"Ask a question, and return the answer"
(printout t ?question " ")
(return (read)))

(defmodule ask)
(defrule ask::ask-question-by-id
"Ask a question and assert the answer"
(declare (auto-focus TRUE))
(MAIN::question (ident ?id) (text ?text) (type ?type))
(not (MAIN::answer (ident ?id)))
?ask <- (MAIN::ask ?id)
=>
(bind ?answer (ask-user ?text ?type))
(assert (MAIN::answer (ident ?id) (text ?answer)))
(retract ?ask)
(return))

;Startup module
(defmodule app-startup)
(defrule welcome
=>
(printout t "Lets get you a new dog!" crlf)
(printout t "What is your name?")
(bind ?name (read))
(printout t "Let us begin " ?name "." crlf)
)


;Module requesting details and asserting the answers
(defmodule request-details)
(defrule request-live
=>
(assert (ask live)))
(defrule request-space
=>
(assert (ask space)))
(defrule request-kids
=>
(assert (ask kids)))
(defrule request-exper
=>
(assert (ask exper)))
(defrule request-otherpets
=>
(assert (ask otherpets)))
(defrule request-personality
=>
(assert (ask personality)))
(defrule request-barking
=>
(assert (ask barking)))
(defrule request-playtime
=>
(assert (ask playtime)))
(defrule request-alonetime
=>
(assert (ask alonetime)))
(defrule request-size
=>
(assert (ask size)))
(defrule request-shed
=>
(assert (ask shed)))
(defrule request-noise
=>
(assert (ask noise)))

;Assert all the answers as facts
(defrule assert-applicant-fact
(answer (ident live) (text ?live1))
(answer (ident space) (text ?space1))
(answer (ident kids) (text ?kids1))
(answer (ident exper) (text ?exper1))
(answer (ident otherpets) (text ?otherpets1))
(answer (ident personality) (text ?personality1))
(answer (ident barking) (text ?barking1))
(answer (ident playtime) (text ?playtime1))
(answer (ident alonetime) (text ?alonetime1))
(answer (ident size) (text ?size1))
(answer (ident shed) (text ?shed1))
(answer (ident noise) (text ?noise1))
=>
(assert (applicant (live ?live1) (space ?space1) (kids ?kids1) (exper ?exper1) (otherpets ?otherpets1) (personality ?personality1) (barking ?barking1) (playtime ?playtime1) (alonetime ?alonetime1) (size ?size) (shed ?shed) (noise ?noise))))

;Modules to determine dog breed
(defmodule breed-selector)
(defrule check-live
(applicant (live ?live1))
=>
(if (< ?live 2) then
(assert (live-check (rating 1)))
else
(assert (live-check (rating 0)))))

(defrule check-space
(applicant (space ?space1))
=>
(if (< ?space 2) then
(assert (space-check (rating 1)))
else
(assert (space-check (rating 0)))))

(defrule check-kids
(applicant (kids ?kids1))
=>
(if (< ?kids 2) then
(assert (kids-check (rating 1)))
else
(assert (kids-check (rating 0)))))

(defrule check-size
(applicant (size ?size1))
=>
(if (< ?size 2) then
(assert (size-check (rating 1)))
else
(assert (size1-check (rating 0)))))

;Considering living space, size, personality all together
(defrule check-eligibilty
(live-check (rating ?r1))
(space-check (rating ?r2))
(kids-check (rating ?r3))
(size-check (rating ?r4))
=>
(bind ?total (+ ?r1 ?r2 ?r3 ?r4))
(if (eq ?total 4) then
(assert (final-result (text "A small sized dog with a friendly attitude that does not shed much is a good fit
for you. Your best buddy would be a Poodle Terrier mix. Enjoy your day!")))
else
(assert (final-result (text "A large sized protective dog is a good fit for you. Your best buddy would be a
German Shephard. Enjoy your day!")))))

;Module that contains the rules to print out the final result of the evaluation
;Print the results.
(defmodule result)
(defrule print-result
?p1 <- (final-result (text ?t))
=>
(printout t ?t crlf crlf))
 


;Function to run the various modules of the application in the correct order

(deffunction run-application ()
(reset)
(focus app-startup request-details breed-selector result)
(run))

;Run the above function in a loop to get back the prompt every time we have to enter the values for another owner or re-run the program

(while TRUE
(run-application))
