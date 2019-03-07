# CS514-AppliedAI
Projects for CS 514 Applied Artificial Intelligence (Spring 19) at UIC

Project 1

Project 2
use the FuzzyJ toolkit, which can be found at http://rorchard.github.io/FuzzyJ/
Setup instructions:
1. Create a new Java project in eclipse. Make sure you include the JAR file “fuzzyJ-2.0.jar” under New Project > Libraries.
2. In the run configurations of the file, change “jess.Main” to “nrc.fuzzy.jess.FuzzyMain”. Run the project.
3. In case you run into any errors, make sure that the run configs is pointed to the FuzzyMain as by default it is usually shifted back to jess.Main.
You can choose a new domain or use the same domain for Project 2 as you used in Project 1. If you decide to keep the same domain, you will be converting boolean logic to fuzzy logic. Be careful, as it may be the case that not all the rules can be converted to fuzzy logic. Usually, rules which have a certain degree or continuity involved can be converted to fuzzy logic. 

Project 3
move on from Jess to NETICA to implement a Bayesian Network. Again, you have to choose a domain to implement.
1. An ideal Bayesian Network will have atleast 20-30 nodes in the network. 
2. The probabilities assigned and the connections between the nodes should have a logical basis which you will explain in your manual.
3. The latest versions available on NORSYS website will only be available with limited functionality. The limit includes a maximum node limit which is restrictive for your project. We have a password that you can use to access full functionality but it works with older versions. But these older versions should work just fine.
