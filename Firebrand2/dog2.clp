(import nrc.fuzzy.*)
(import nrc.fuzzy.jess.FuzzyMain)
(import nrc.fuzzy.jess.*)
(load-package nrc.fuzzy.jess.FuzzyFunctions)



;Following are defglobals for dog's attributes and are all Fuzzy variable.
(defglobal ?*dog_age* = (new FuzzyVariable "Dog Age" 0.0 240.0 "months"))
(defglobal ?*dog_breed* = (new FuzzyVariable "Adult Breed Size" 0.0 40.0 "kgs"))
(defglobal ?*dog_weight* = (new FuzzyVariable "Dog weight" 0.0 70.0 "kgs"))
(defglobal ?*dog_deworm* = (new FuzzyVariable "Dog deworming" 0.0 240.0 "months"))
(defglobal ?*dog_vaccine* = (new FuzzyVariable "Dog vaccination" 0.0 240.0 "months"))



; The non-fuzzy global variables
(defglobal  ?*user* = ""
			?*dog* = ""
    		?*recommend* = ""
    		?*weight* = ""
 			?*next* = "")

;user's enter dog status
(defglobal ?*dog_age_user* = "" 
		   ?*dog_breed_user* = "" 
 		   ?*dog_weight_user* = "" 
    	   ?*dog_deworm_user* = ""	   
    	   ?*dog_vaccine_user* = ""
    )


;template for question and answer of user inputs
(deftemplate question
    (slot text)
    (slot type)
    (slot ident))

(deftemplate answer
    (slot ident)
    (slot text))


(deffunction is-of-type (?answer ?type)
    "validation of input"
    (if (eq ?type l-m-h) then
             (return (or(eq ?answer low)(eq ?answer medium)(eq ?answer high)))
        else (if (eq ?type stage) then
             (return (or(eq ?answer one)(eq ?answer two)(eq ?answer three)))
            else (if (eq ?type number) then
            (return (and (numberp ?answer)(> ?answer 0)))
            else (if (eq ?type breed-size) then
                (return (or(eq ?answer small)(eq ?answer medium)(eq ?answer large)))
            else (return (> (str-length ?answer) 0))
            	)
        	)
    	)
  	)  
)

(deffunction ask-user (?question ?type)
    "Ask a question, and return the answer"
    (bind ?answer "")
    (while (not (is-of-type ?answer ?type)) do
        (printout t ?question " ")
        (if (eq ?type number) then
            (printout t crlf"Positive numbers only."crlf))
        (if (eq ?type l-m-h) then
            (printout t crlf"Valid Options: Low/Medium/High."crlf))
        (if (eq ?type stage) then
            (printout t crlf"Valid Options: One/Two/Three."crlf))
        (if (eq ?type breed-size) then
            (printout t crlf"Valid Options: Small/Medium/Large."crlf))
        (bind ?answer (read)))
    (return ?answer))


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




;Taking in the user input
(defmodule start)
(defrule init
    =>
    (printout t crlf crlf)
	(printout t " Welcome to Complete Dog owner's Guide!" crlf)
	(printout t "What's your name?" crlf)
    (bind ?*user* (read))
    (printout t crlf)
    
    (printout t " Hey, " ?*user* ". Great name! And what is your dog's name? " crlf)
    (bind ?*dog* (read))
    (printout t crlf)
    
    (printout t ?*dog* "! Wow! Another great name!" crlf)
    (printout t " Now, select correct answers for the following questions." crlf)

    
    )

;Question asked to user which are validated
(deffacts questions
    "The questions that are asked to user."
    (question (ident current) (type number)
        (text "How much does your dog weigh? (Numeric value in Kgs)"))
    (question (ident age) (type l-m-h)
        (text "How old is your dog? (Low = Less than 2 years | Medium = 2 to 12 years | High = 12 to 20 years)"))
    (question (ident breed) (type breed-size)
        (text "Is your dog small, medium or large?"))
    (question (ident weight) (type l-m-h)
        (text "What is the weight of your dog (in kgs)? (Low = Less than 25kgs | Medium = 25 to 40kgs | High = more than 40kgs)"))
    (question (ident deworm) (type stage)
        (text "When was your dog dewormed last? (In months)"))
    (question (ident vaccine) (type stage)
        (text "Till which stage is your dog vaccinated? (In months)"))
    )

;Answer for the question
(defmodule request-dog-details)
(defrule request-current
    (declare (salience 31))
    =>
    (assert (ask current)))

(defrule request-age
    (declare (salience 30))
    =>
    (assert (ask age)))

(defrule request-breed
    (declare (salience 29))
    =>
    (assert (ask breed)))

(defrule request-weight
    (declare (salience 28))
    =>
    (assert (ask weight)))

(defrule request-deworm
    (declare (salience 27))
    =>
    (assert (ask deworm)))

(defrule request-vaccine
    (declare (salience 26))
    =>
    (assert (ask vaccine)))


;asserting  the user data.
 (defrule assert-dog-fact   
    (answer (ident current) (text ?c))
    (answer (ident age) (text ?a))
    (answer (ident breed) (text ?b))
    (answer (ident weight) (text ?w))
    (answer (ident deworm) (text ?d))
    (answer (ident vaccine) (text ?v))
    =>
    (bind ?*weight* ?c)
    (bind ?*dog_age_user* ?a)
    (bind ?*dog_breed_user* ?b)
    (bind ?*dog_weight_user* ?w)
    (bind ?*dog_deworm_user* ?d)
    (bind ?*dog_vaccine_user* ?v)    
    (assert (user-dog-age (new FuzzyValue ?*dog_age* ?*dog_age_user*)))
  	(assert (user-dog-breed (new FuzzyValue ?*dog_breed* ?*dog_breed_user*)))
	(assert (user-dog-weight (new FuzzyValue ?*dog_weight* ?*dog_weight_user*)))
    (assert (user-dog-deworm (new FuzzyValue ?*dog_deworm* ?*dog_deworm_user*)))
    (assert (user-dog-vaccine (new FuzzyValue ?*dog_vaccine* ?*dog_vaccine_user*)))    
    (printout t crlf)

)

;Initialize all the global variables.
(defrule initialize-fuzzy-variables
    (declare (salience 100))  
    =>
    (?*dog_age* addTerm "low" (new ZFuzzySet 1 3))
	(?*dog_age* addTerm "medium" (new TriangleFuzzySet 7 5))
    (?*dog_age* addTerm "high" (new SFuzzySet 12 240))

    
    (?*dog_breed* addTerm "small" (new ZFuzzySet 1 10))
	(?*dog_breed* addTerm "medium" (new TriangleFuzzySet 17 8))
    (?*dog_breed* addTerm "large" (new SFuzzySet 25 40))

 	(?*dog_weight* addTerm "low" (new ZFuzzySet 1 25))
	(?*dog_weight* addTerm "medium" (new TriangleFuzzySet 33 8))
    (?*dog_weight* addTerm "high" (new SFuzzySet 40 70))
    
 	(?*dog_deworm* addTerm "one" (new ZFuzzySet 1 4))
	(?*dog_deworm* addTerm "two" (new TriangleFuzzySet 7 5))
    (?*dog_deworm* addTerm "three" (new SFuzzySet 12 240))  
    
    (?*dog_vaccine* addTerm "one" (new ZFuzzySet 1 3))
	(?*dog_vaccine* addTerm "two" (new TriangleFuzzySet 4 2))
    (?*dog_vaccine* addTerm "three" (new SFuzzySet 6 240))   
    
)

; Rule for dog
;Growth Stage of dog

(defrule rule-1
    "Age is less than 2 months"
    (declare (salience 18))
    (user-dog-age ?a&:(fuzzy-match ?a "low"))
      =>
	(printout t "Your puppy is still in the weaning stage."crlf" You need to keep your dog on its mother's milk." crlf)
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )

(defrule rule-2
    "Age is between 3 to 12 months"
    (declare (salience 17))
    (user-dog-age ?a&:(fuzzy-match ?a "medium"))
      =>
	(printout t "Your puppy is still in the weaning stage."crlf"You can now start to feed it dry food and take it off its mother's milk." crlf)
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )

(defrule rule-3
    "Age is above 12 months"
    (declare (salience 16))
    (user-dog-age ?a&:(fuzzy-match ?a "high"))
      =>
	(printout t "Now your pup has become a dog! You must be so proud!" crlf)
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )


;Weight recommended and difference

(defrule rule-4
    "Recommended weight for age less than 2 months"
    (declare (salience 15))
    (user-dog-age ?a&:(fuzzy-match ?a "low"))
	(user-dog-breed ?b)
    =>
	(if (fuzzy-match ?b "small") then
        (printout t "Your dog is a small breed and is still a pup."crlf"The recommended weight is about 3kgs.")
        (bind ?*recommend* 3)
    	(if(> ?*recommend* ?*weight*) then
        	(printout t crlf "Weight less by "(- ?*recommend* ?*weight*)" kgs."))
        (if(< ?*recommend* ?*weight*) then
        	(printout t crlf "Weight more by "(- ?*weight* ?*recommend*)" kgs."))
        (if(eq ?*recommend* ?*weight*) then
        	(printout t crlf "Weight equal to recommended weight"crlf))
        )
    (if (fuzzy-match ?b "medium") then
        (printout t "Your dog is a medium breed and is still a pup."crlf"The recommended weight is about 5 kgs.")
        (bind ?*recommend* 5)
    	(if(> ?*recommend* ?*weight*) then
        	(printout t crlf "Weight less by "(- ?*recommend* ?*weight*)" kgs."))
        (if(< ?*recommend* ?*weight*) then
        	(printout t crlf "Weight more by "(- ?*weight* ?*recommend*)" kgs."))
        (if(eq ?*recommend* ?*weight*) then
        	(printout t crlf "Weight equal to recommended weight"crlf))
        )
    (if (fuzzy-match ?b "large") then
        (printout t "Your dog is a large breed and is still a pup."crlf"The recommended weight is 8 kgs.")
        (bind ?*recommend* 9)
    	(if(> ?*recommend* ?*weight*) then
        	(printout t crlf "Weight less by "(- ?*recommend* ?*weight*)" kgs."))
        (if(< ?*recommend* ?*weight*) then
        	(printout t crlf "Weight more by "(- ?*weight* ?*recommend*)" kgs."))
        (if(eq ?*recommend* ?*weight*) then
        	(printout t crlf "Weight equal to recommended weight"crlf))
        )
    	(printout t crlf "Press any key and hit Enter/Return key to continue.")
    	(bind ?*next* (read t))
    )




(defrule rule-5
    "If age is above 2 to 12 months"
    (declare (salience 14))
    (user-dog-age ?a&:(fuzzy-match ?a "medium"))
	(user-dog-breed ?b)
    =>
    (printout t crlf "The following tells you about your dog's recommened weight:" crlf crlf) 
	(if (fuzzy-match ?b "small") then
        (printout t "Your dog is a small breed and is between 2 to 12 months old."crlf"The recommended weight is 11 kgs.")
        (bind ?*recommend* 11)
    	(if(> ?*recommend* ?*weight*) then
        	(printout t crlf "Weight less by "(- ?*recommend* ?*weight*)" kgs."))
        (if(< ?*recommend* ?*weight*) then
        	(printout t crlf "Weight more by "(- ?*weight* ?*recommend*)" kgs."))
        (if(eq ?*recommend* ?*weight*) then
        	(printout t crlf "Weight equal to recommended weight"crlf))
        )
    (if (fuzzy-match ?b "medium") then
        (printout t "Your dog is a medium breed and is between 2 to 12 months old."crlf"The recommended weight is 22 kgs.")
		(bind ?*recommend* 22)
    	(if(> ?*recommend* ?*weight*) then
        	(printout t crlf "Weight less by "(- ?*recommend* ?*weight*)" kgs."))
        (if(< ?*recommend* ?*weight*) then
        	(printout t crlf "Weight more by "(- ?*weight* ?*recommend*)" kgs."))
        (if(eq ?*recommend* ?*weight*) then
        	(printout t crlf "Weight equal to recommended weight"crlf))
        )
    (if (fuzzy-match ?b "large") then
        (printout t "Your dog is a large breed and is between 2 to 12 months old."crlf"The recommended weight is 35 kgs.")
        (bind ?*recommend* 35)
    	(if(> ?*recommend* ?*weight*) then
        	(printout t crlf "Weight less by "(- ?*recommend* ?*weight*)" kgs."))
        (if(< ?*recommend* ?*weight*) then
        	(printout t crlf "Weight more by "(- ?*weight* ?*recommend*)" kgs."))
        (if(eq ?*recommend* ?*weight*) then
        	(printout t crlf "Weight equal to recommended weight"crlf))
        )
    	(printout t crlf "Press any key and hit Enter/Return key to continue.")
    	(bind ?*next* (read t))
    )

(defrule rule-6
    "If age is more than 12 months"
    (declare (salience 13))
    (user-dog-age ?a&:(fuzzy-match ?a "high"))
	(user-dog-breed ?b)
    => 
	(if (fuzzy-match ?b "small") then
        (printout t  "Your dog is a small breed and older than 12 months."crlf"The recommended weight is about 12 kgs.")
		(bind ?*recommend* 15)
    	(if(> ?*recommend* ?*weight*) then
        	(printout t crlf "Weight less by "(- ?*recommend* ?*weight*)" kgs."))
        (if(< ?*recommend* ?*weight*) then
        	(printout t crlf "Weight more by "(- ?*weight* ?*recommend*)" kgs."))
        (if(eq ?*recommend* ?*weight*) then
        	(printout t crlf "Weight equal to recommended weight"crlf))
        )
    (if (fuzzy-match ?b "medium") then
        (printout t "Your dog is a medium breed and older than 12 months old."crlf"The recommended weight is 25 kgs.")
		(bind ?*recommend* 29)
    	(if(> ?*recommend* ?*weight*) then
        	(printout t crlf "Weight less by "(- ?*recommend* ?*weight*)" kgs."))
        (if(< ?*recommend* ?*weight*) then
        	(printout t crlf "Weight more by "(- ?*weight* ?*recommend*)" kgs."))
        (if(eq ?*recommend* ?*weight*) then
        	(printout t crlf "Weight equal to recommended weight"crlf))
        )
    (if (fuzzy-match ?b "large") then
        (printout t "Your dog is a large breed and older than 12 months old."crlf"The recommended weight is 40 kgs.")
		(bind ?*recommend* 48)
    	(if(> ?*recommend* ?*weight*) then
        	(printout t crlf "Weight less by "(- ?*recommend* ?*weight*)" kgs."))
        (if(< ?*recommend* ?*weight*) then
        	(printout t crlf "Weight more by "(- ?*weight* ?*recommend*)" kgs."))
        (if(eq ?*recommend* ?*weight*) then
        	(printout t crlf "Weight equal to recommended weight"crlf))
        )
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )


;Food quantity chart
(defrule rule-7
    "If age is till 2 months"
    (declare (salience 12))
    (user-dog-age ?a&:(fuzzy-match ?a "low"))
	(user-dog-breed ?b)
    =>
	(printout t "Since Your Dog is in weaning stage it needs a lot of food." crlf)
    (printout t crlf "FUN FACT: Puppies need more food than an adult dogs.") 
    (if (fuzzy-match ?b "small") then
        (printout t crlf crlf"Your dog is a small breed and less than 2 months old."crlf"The recommended food quantity is 0.44 kgs per day."crlf crlf))
    (if (fuzzy-match ?b "medium") then
        (printout t crlf crlf "Your dog is a medium breed and less than 2 months old."crlf"The recommended food quantity is 0.97 kgs per day."crlf crlf))
    (if (fuzzy-match ?b "large") then
        (printout t crlf crlf "Your dog is a large breed and less than 2 months old."crlf"The recommended food quantity is 1.42 kgs per day."crlf crlf))
    (printout t "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )

(defrule rule-8
    "If age is 2 to 12 months"
    (declare (salience 11))
    (user-dog-age ?a&:(fuzzy-match ?a "medium"))
	(user-dog-breed ?b)
    =>
	(printout t "Since Your Dog is in Growing stage and needs to eat in the recommend quantity to avoid getting overweight at adulthood" crlf)
    (printout t crlf "Puppies need more food than an adult dog") 
    (if (fuzzy-match ?b "small") then
        (printout t crlf crlf "Your dog is a small breed and is between 3 to 12 months old."crlf"The recommended food quantity is 0.32 kgs per day."crlf crlf))
    (if (fuzzy-match ?b "medium") then
        (printout t crlf crlf "Your dog is a medium breed and is between 3 to 12 months old."crlf"The recommended food quantity is 0.65 kgs per day."crlf crlf))
    (if (fuzzy-match ?b "large") then
        (printout t crlf crlf "Your dog is a large breed and is between 3 to 12 months old."crlf"The recommended food quantity is 1.04 kgs per day."crlf crlf))
    (printout t "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )

(defrule rule-9
    "If age above 12 months"
    (declare (salience 10))
    (user-dog-age ?a&:(fuzzy-match ?a "high"))
	(user-dog-breed ?b)
    =>
	(printout t "Your dog is now an adult and needs to have a balanced diet" crlf)
    (printout t crlf "Puppies need more food than an adult dog") 
    (if (fuzzy-match ?b "small") then
        (printout t crlf crlf "Your dog is a small breed and is above 12 months old."crlf"The recommended food quantity is 0.29 kgs per day."crlf crlf))
    (if (fuzzy-match ?b "medium") then
        (printout t crlf crlf"Your dog is a medium breed and is above 12 months old."crlf"The recommended food quantity is 0.57 kgs per day."crlf crlf))
    (if (fuzzy-match ?b "large") then
        (printout t crlf crlf"Your dog is a large breed and is above 12 months old."crlf"The recommended food quantity is 0.95 kgs per day."crlf crlf))
    (printout t "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )


;Food Number of time per day

(defrule rule-10
    "If breed is small"
    (declare (salience 9))
    (user-dog-breed ?b&:(fuzzy-match ?b "small"))
	(user-dog-age ?a)
    =>
    (printout t crlf "A puppy eats more times a day than an adult dog." crlf)
	(printout t crlf "but you need to equally divide the food." crlf)
    (printout t crlf "Your total intake should not cross recommended food quantity."crlf)
    (if (fuzzy-match ?a "low") then
        (printout t  "Your dog is a small breed and is still puppy less than 2 months."crlf"You should feed your dog 3 to 4 times a day."crlf))
    (if (fuzzy-match ?a "medium") then
        (printout t "Your dog is a small breed and is between 2 to 12 months old."crlf"You should feed your dog 3 times a day."crlf))
    (if (fuzzy-match ?a "high") then
        (printout t "Your dog is a small breed and is above 12 months "crlf"You should feed your dog 2 times a day."crlf))
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )


(defrule rule-11
    "If breed is medium"
    (declare (salience 8))
    (user-dog-breed ?b&:(fuzzy-match ?b "medium"))
	(user-dog-age ?a)
    =>
    (printout t crlf "A puppy eats more times a day than an adult dog" crlf "Reason being that puppy's digestive system is still not fully developed" crlf)
	(printout t crlf "NOTE: You need to equally divide the recommend food quantity per day into the number of times feeding is required." crlf)
    (printout t crlf "Your total intake should not cross recommended food quantity (kgs per day)"crlf)
    (if (fuzzy-match ?a "low") then
        (printout t  "Your dog is a medium breed and is still puppy less than 2 months."crlf"You should feed your dog 3 to 4 times a day."crlf))
    (if (fuzzy-match ?a "medium") then
        (printout t "Your dog is a medium breed and is between 2 to 12 months old."crlf"You should feed your dog 3 times a day."crlf))
    (if (fuzzy-match ?a "high") then
        (printout t "Your dog is a medium breed and is above 12 months old."crlf"You should feed your dog 2 times a day."crlf))
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )

(defrule rule-12
    "If breed is large"
    (declare (salience 7))
    (user-dog-breed ?b&:(fuzzy-match ?b "large"))
	(user-dog-age ?a)
    =>
    (printout t crlf "A puppy eats more times a day than an adult dog" crlf "Reason being that puppy's digestive system is still not fully developed" crlf)
	(printout t crlf "NOTE: You need to equally divide the recommend food quantity per day into the number of times feeding is required." crlf)
    (printout t crlf "Your total intake should not cross recommended food quantity (kgs per day)"crlf)
    (if (fuzzy-match ?a "low") then
        (printout t  "Your dog is a large breed and is still puppy less than 2 months."crlf"You should feed your dog 3 to 4 times a day."crlf))
    (if (fuzzy-match ?a "medium") then
        (printout t "Your dog is a large breed and is between 2 to 12 months old."crlf"You should feed your dog 3 times a day."crlf))
    (if (fuzzy-match ?a "high") then
        (printout t "Your dog is a large breed and is above 12 months old."crlf"You should feed your dog 2 times a day."crlf))
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )


; Recommended food brands


(defrule rule-13
    "Less than 2 months"
    (declare (salience 6))
    (user-dog-breed ?b)
	(user-dog-age ?a&:(fuzzy-match ?a "low"))
    =>
	(printout t "Your pup needs all the nutrients the best quality food." crlf)
    (if (fuzzy-match ?b "small") then
        (printout t crlf crlf "Here are some milk powder brands for your pup."crlf"1)Brand 13A"crlf"2)Brand 13B"crlf"3)Brand 13C"crlf))
    (if (fuzzy-match ?b "medium") then
        (printout t crlf crlf "Here are some milk powder brands for your pup."crlf"1)Brand 13D"crlf"2)Brand 13E"crlf"3)Brand 13F"crlf))
    (if (fuzzy-match ?b "large") then
        (printout t crlf crlf "Here are some milk powder brands for your pup."crlf"1)Brand 13G"crlf"2)Brand 13H"crlf"3)Brand 13I"crlf))
    
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )



(defrule rule-14
    "If age is 2 to 12 months"
    (declare (salience 5))
    (user-dog-breed ?b)
	(user-dog-age ?a&:(fuzzy-match ?a "medium"))
    =>
	(printout t "Since Your Dog is not an adult and needs to get nutrients essential from weaning till adult stage" crlf)
    (if (fuzzy-match ?b "small") then
        (printout t crlf crlf "Here are some milk powder brands for your pup."crlf"1)Brand 14A"crlf"2)Brand 14B"crlf"3)Brand 14C"crlf))
    (if (fuzzy-match ?b "medium") then
        (printout t crlf crlf "Here are some milk powder brands for your pup."crlf"1)Brand 14D"crlf"2)Brand 14E"crlf"3)Brand 14F"crlf))
    (if (fuzzy-match ?b "large") then
        (printout t crlf crlf "Here are some milk powder brands for your pup."crlf"1)Brand 14G"crlf"2)Brand 14H"crlf"3)Brand 14I"crlf))
    
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )



(defrule rule-15
    "If age is 12 to more"
    (declare (salience 4))
    (user-dog-breed ?b)
	(user-dog-age ?a&:(fuzzy-match ?a "high"))
    =>
	(printout t "Your adult dog needs best food to keep its health." crlf)
    (if (fuzzy-match ?b "small") then
        (printout t crlf crlf "Here are some milk powder brands for your pup."crlf"1)Brand 15A"crlf"2)Brand 15B"crlf"3)Brand 15C"crlf))
    (if (fuzzy-match ?b "medium") then
        (printout t crlf crlf "Here are some milk powder brands for your pup."crlf"1)Brand 15D"crlf"2)Brand 15E"crlf"3)Brand 15F"crlf))
    (if (fuzzy-match ?b "large") then
        (printout t crlf crlf "Here are some milk powder brands for your pup."crlf"1)Brand 15G"crlf"2)Brand 15H"crlf"3)Brand 15I"crlf))
    
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )

;Life expectancy

(defrule rule-16
    "Life expectancy according to breed"
    (declare (salience 3))
    (user-dog-breed ?b)
    =>
	(if (fuzzy-match ?b "small") then
        (printout t crlf" Yours is a small dog. Its life expectancy is about 15 to 16 years."crlf))    
    (if (fuzzy-match ?b "medium") then
        (printout t crlf"Yours is a medium dog. Its life expectancy is about 11 to 13 years."crlf))
    (if (fuzzy-match ?b "large") then
        (printout t crlf"Yours is a small dog. Its life expectancy is about 10 to 12 years "crlf))
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    )


;Deworming

(defrule rule-17
    "Deworming according to age"
    (declare (salience 2))
    (user-dog-deworm ?d)
    =>
    (printout t crlf "Worms are very serious problem for a dogs' health." crlf)
    (printout t crlf "Deworming of dog is essential to make sure it recieves all the nutrients properly." crlf)
    (printout t "Good to know you have dewormed your dog."crlf"But you still need to do deworming at regular intervals.")
    (if(fuzzy-match ?d "one") then
        	(printout t crlf "You need to deworm your dog at 6th and 8th week"crlf"Then again at 3rd and 4th month"crlf"Again at 6th and 12th month"crlf"After that once every Year."))
        (if(fuzzy-match ?d "two") then
        	(printout t crlf "You need to deworm your dog again at 6th and 12th month"crlf"After that once every Year."))
        (if(fuzzy-match ?d "three") then
        	(printout t crlf "As you dog is adult you need to deworm your dog after once every year."))
        
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
)
    
    
;Vaccination

(defrule rule-18
    "Vaccination according to age"
    (declare (salience 1))
    (user-dog-vaccine ?v)
    =>
    (printout t crlf "Vaccination information." crlf)
    (printout t "Good to know you have vaccinated your dog."crlf"But you still need to do vaccination again at regular intervals.")
    	(if(fuzzy-match ?v "one") then
        	(printout t crlf "You need to give next vaccination to your dog by 3rd Month:"crlf"Vaccinations: DHPP (vaccines for distemper, adenovirus [hepatitis], parainfluenza, and parvovirus)"crlf"Then again at 6th month of :"crlf"Vaccinations: Rabies, DHPP"crlf"Again after 12th month you should give:"crlf"Vaccinations: DHPP- Every 1 - 2 Years"crlf"Rabies- Every 1-3 Years"))
        (if(fuzzy-match ?v "two") then
        	(printout t crlf "You need to give next vaccination again at 6th month of :"crlf"Vaccinations: Rabies, DHPP"crlf"Again after 12th month you should give:"crlf"Vaccinations: DHPP- Every 1 - 2 Years"crlf"Rabies- Every 1-3 Years"))
        (if(fuzzy-match ?v "three") then
        	(printout t crlf "After 12th month you should give:"crlf"Vaccinations: DHPP- Every 1 - 2 Years"crlf"Rabies- Every 1-3 Years"))
        
    (printout t crlf "Press any key and hit Enter/Return key to continue.")
    (bind ?*next* (read t))
    
    
    (printout t crlf "Hope this was helpful!")
    
    )


(deffunction run-application ()
    (reset)
    (focus start request-dog-details)
    (run))

(while TRUE 
    (run-application))