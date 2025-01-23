## The Crisis of Divided Government

This repository contains the code and data for my research project on ****effect of Democratic Backsliding on Legislative Oversight in Venezuela****.

**1. Introduction**

* **Research Question:** Within the possible functions, a legislature performs in a political system, which ones are affected the most by democratic backsliding? Subsequently, are there any differences between types of episodes of regime transition during democratic backsliding?
* **Objective:** Subsequently, the internal dynamics of a country under democratic backsliding are understudied using inferential methods. By providing a casual inference perspective, this novel research using Venezuela as a country case aims to capture nuances and dynamics often overlooked by cross-national and large-n studies
* **Significance:** Despite enjoying a long 40-year period of democracy, Venezuela spiraled back as one of the countries in the region to suffer democratic backsliding under the pink wave at the end of the twentieth century. Not only did Venezuela fall into an authoritarian regime, but it also suffered one of the biggest decreases in liberal democracy in recent times. 
* **Background:** Previous political science research regarding democratic backsliding has successfully noticed certain patterns, especially by crafting a periodization and highlighting the underlying mechanisms of it (Luhrmann 2020, Wilson 2020, Sato 2022). On the studies relating to Venezuela and its democratic backsliding, most of them have been carried out using qualitative approaches (Alarcon216, Pantoulas 2019, Corrales 2020, Jimenez 2021). Less studied, however, are the inner dynamics regarding the functions a legislature must carry. I also use a novel quantitative approach based on causal inference.

**2. Data**

* **Data Sources:**
    * I investigate the effect of democratic backsliding on legislative constraints in the executive and its four components, taken from the V-Dem Project dataset (Coppedge 2022).
    * I also utilized the Episode of Regime Transformation (ERT) dataset from the V-Dem Project in order to characterize and differentiate between the two episode that Venezuela underwent under Chávez (democratic breakdon) and Maduro (regressed autocracy).

* **Data Description:**
    * This research aims to tackle the dynamics between the executive and the legislature under episodes of democratic backsliding, more specifically, the **legislative constraints in the executive** the sub-components of the constraints a legislature can impose on the executive:
    * Legislature needs to question officials
    * Executive oversight
    * Legislature investigates in practice
    * Opposition parties in the legislature

**3. Methodology**

* **Research Design:** 
    * Following Abadie et. al (2010, 2015), I aim to elucidate the effects of democratic backsliding in the function carried out by a legislature, using Venezuela as a country case using the synthetic control method (SCM). 
    * The pool of donors for constructing a synthetic Venezuela was selected following a heuristic with these conditions. First, none of these countries have suffered an episode of democratic backsliding. This is important because, if they have to serve as controls, they need to be free of the treatment. To control for possible endogeneity, the regime classification variable was selected to discriminate between countries that suffered an episode of democratic backsliding constructed by Freedom House (2022).
* **Software and Packages:**
    * To conduct this research I used Stata v17 and the [synth](http://fmwww.bc.edu/repec/bocode/s/synth.html) package to run the Synthetic Control Method experiment.

**4. Code**

* **Structure:** 
    * The repository contains the following scripts: 
        * `demback_on_legover_scm.do`: Cleans and prepares the data, executes the main experiments.
        * `Robustness Checks/3rd Democratization Wave/demback_on_legover_scm.do`: Performs the robustness checks with countries that democratized after the 3rd wave.

**5. Results**

* **Key Findings:** 
    * Despite Hugo Chávez's longer tenure than Maduro's, the biggest drop in the legislature constraints in the executive index was during the second episode of regressed autocracy.
    * Also, during a regressed autocracy episode, the executive will have more power to divide and coopt the opposition and ignore any subpoenas that may originate from the legislative body. This result is backed by the overwhelming decrease in Executive oversight, Legislature opposition parties, and Legislature questions officials in practice sub-components during the regressed autocracy period.
* **Visualizations:** 
    * See the following plots for visualizations of the key findings and results from the SCM experiments, more results and robustsness checks can be seen on the plots and results directories: 
        * [Legislative Constraints on the Executive](https://github.com/pablohernandezb/the-crisis-of-divided-government/blob/main/plots/scm_v2xlg_legcon.png)
            * [Legislature Investigates in Practice](https://github.com/pablohernandezb/the-crisis-of-divided-government/blob/main/plots/scm_v2lginvstp.png)
            * [Legislature Opposition Parties](https://github.com/pablohernandezb/the-crisis-of-divided-government/blob/main/plots/scm_v2lgoppart.png)
            * [Executive Oversight](https://github.com/pablohernandezb/the-crisis-of-divided-government/blob/main/plots/scm_v2lgotovst.png)
            * [Legislature Questions Officials in Practice](https://github.com/pablohernandezb/the-crisis-of-divided-government/blob/main/plots/scm_v2lgqstexp.png)

**6. Conclusion**

* This study showed the internal dynamics of executive-legislature relations under a context of democratic backsliding. In Venezuela, during the first two episodes of democratic backsliding of the 21st century, there are substantive differences in which the president operates to diminish institutional control and further promote executive aggrandizement.
* The use of synthetic control methods in political science has been further extended and used for two novel approaches in this study. First, previous uses like Abadie et al. (2010, 2015) state, have been to study phenomena in the economic realm while taking advantage of the Varieties of Democracies dataset that includes time-series variables that capture dynamics of political phenomena like legislative constraints on the executive and its sub-components.

**7. Contributing**

* Contributions to this project are welcome. You can contribute by:
    * Reporting bugs or issues
    * Suggesting improvements to the code
    * Contributing new features or analyses

**8. License**

* This code is released under the MIT License

**9. Contact**

* For any inquiries, please contact me at hi at pablohernandezb.dev
