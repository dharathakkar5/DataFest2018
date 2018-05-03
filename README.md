# [ASU](http://www.amstat.org/) DataFest2018
Penn State University

Team : Analytical Assassins

Members: Karpagalakshmi Rajagopalan @radha90, Jackie Markle @JSMarkle, Dhara Thakkar, Ashish Chauhan, Harsha Polisetty @harshapolisetty

Team won the **Most creative Award** and emerged as **Runner up** from 77 teams.

Data Source Provided : Indeed.com The world's largest job search engine.

Details: The data is a snapshot of jobs added to the website everyday by employers. It consists of 14+ million records. Each record consists of information about the posted job or the company on that particular day and is identified by a combination of job ID, company ID and the date.

External Data used: US/Canada/Germany population and unemployment data by state and city.

Questions Answered:

1) What is the relation between supply and demand of the jobs on indeed?
2) What are the top 5 best and worst jobs available?
3) What are the factors that the company could focus on to improve their customer base?

Analysis Approach:

1) What is the relation between supply and demand of the jobs on indeed?

To answer this question, we first defined a variable called "job_demand", which is the number of clicks/job_age. In the data given, the job_age was a running total where as the number of clicks was for each day for that job. Therefore, we found that running total of number of clicks for each unique job and then calculated the job_demand. The number of jobs posted is the supply.


For each country (US, Canada and Germany), we visualized the demand of jobs in each state by date, using an animated geospatial map on Tableau.  We found that there is a boom in demand for jobs in Georgia in April 2017 which is not matched by jobs that is currently available in market.

2) What are the top 5 best and worst jobs available?

The job_demand in each state is normalized based on population in that state. This new variable is named "demand_index". When the demand_index is greater than or equal to 90%, the job is categorized as "high in demand", otherwise it is "Not in demand". Using this data, we were able to visualize which are the best and worst jobs that are available in market, in each state. This will help students to make informed decisions about choosing a major that will ensure a better future for them.

3) What are the factors that the company could focus on to improve their customer base?

For determing the factors that could have positive impact on the job demand/interests, we created regression models using randomForest, GBM and NeuralNet. The target variable used is demand_index. The best results were obtained using randomForest regression with a root mean squared error value of 1.87. To handle memory issues in R while running the models, we used h2o.ai package for R.

[Here](https://public.tableau.com/profile/karpagalakshmi#!/vizhome/DataFest1_0/Story1?publish=yes) is a link to the Visualization.
