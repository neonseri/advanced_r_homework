# Josemari Feliciano
# Homework 11






######################################################################################################

#Function: election_simulator()

#Author: Josemari Feliciano

#Creation Date: December 1, 2018 (version 3.4.0)

#Purpose: - To print on the console the probabilities of Democrats and Republics winning the US presidency, 
#                 also prints the probability of having an undecided election given all the simulations
#         - To plot the distribution of electocal vote distribution for Democrats and Republicans in the same graph using specific method

# Required Parameters: 
#      - file_location = file path of csv data that will be used for analysis
#             subrequirements:
#               for each state, need to include the following variables as columns variables called: 
#                 - Democrat_Per = % of registered Democrats
#                 - Republican_Per = % of registered Republicans
#                 - Other_Per = % of registered voters who do not identify as Dem or Rep
#                 - Electoral.Votes = number of electoral votes for each state
#      - seed_num = the seed number that will be set to make output reproducible 
#      - num_sim = the number of election simulations that will be performed
#      - method = the method number that will be used to assume how non-Democrats and non-Republicans voters would vote
#           method = 1: assumes that non-Democrats and non-Republicans voters would vote for a third party
#           method = 2: assumes that all non-Democrats and non-Republicans voters would only vote for Democrats
#           method = 3: assumes that all non-Democrats and non-Republicans voters would only vote for Republicans 
#           method = 4: assumes that all non-Democrats and non-Republicans voters would vote on 50%-50% split between Dems and Reps.  

#Output: No direct return value. 
#        It will print the following however:
#           - on console, prints the probabilities of Democrats and Republicans outright winning, along with probability of undecided election
#           - creates a plot, produces a single histogram (overlay) of the distribution of electoral votes for Republicans and Democrats 

#Example: election_simulator(file_location="/Users/jfeliciano/Election_Data.csv", seed_num=1234, num_sim=999, method=1)
########################################################################################################




election_simulator <- function(file_location, seed_num, num_sim, method){
  
  # reads the file
  election_data <- read.csv(file_location, header=TRUE)
  
  #stops if the expected variables in the dataset do not exist or have length 0
  if(length(election_data[,'Democrat_Per']) == 0 ||  length(election_data[,'Republican_Per']) == 0 || length(election_data[,'Other_Per']) == 0 || length(election_data[,'Electoral.Votes']) == 0) {
    stop("Error: one (or more) of the required column variables is empty or undeclared; make sure to name your variables correctly as specified in documentation")
  }
  
  # sets the seed that user has specified
  set.seed(seed_num)
  
  # creates the tally of electoral college for each party for each simulation
  dem_ec_tally <- rep(0,num_sim)
  rep_ec_tally <- rep(0,num_sim)
  
  # calculates the electoral college votes for each state in all simulation
  for(state in 1:nrow(election_data)) {
    
    # determines the distribution of wins for each state for num_sim simulations for all 4 different methods
    # for binomial distribution, multinomial is utilized since binomial with two prob is just a subset of multinomial dist.
    if(method==1) { 
      current_state <- rmultinom(num_sim, 1, prob = c(election_data[state,'Democrat_Per'], election_data[state,'Republican_Per'],  election_data[state,'Other_Per']))
    }else if(method==2) {
      current_state <- rmultinom(num_sim, 1, prob = c(election_data[state,'Democrat_Per'] + election_data[state,'Other_Per'], election_data[state,'Republican_Per']))
    }else if(method==3) {
      current_state <- rmultinom(num_sim, 1, prob = c(election_data[state,'Democrat_Per'], election_data[state,'Republican_Per'] + election_data[state,'Other_Per']))
    }else if(method==4) {
      current_state <- rmultinom(num_sim, 1, prob = c(election_data[state,'Democrat_Per'] + election_data[state,'Other_Per']/2, election_data[state,'Republican_Per'] + election_data[state,'Other_Per']/2))
    }
    
    # adds the electoral votes to the vector of winner for current state for every single num_sim simulations
    for(col in 1:ncol(current_state)) {
      if(current_state[1,col] == 1) {
        dem_ec_tally[col] <- dem_ec_tally[col] + election_data[state,"Electoral.Votes"] 
      }else if(current_state[2,col] == 1) {
        rep_ec_tally[col] <- rep_ec_tally[col] + election_data[state,"Electoral.Votes"] 
      }
    }
  }
   
  # once all calculations are done, creates a histogram with labels and a yellow line for 270 electors threshold
  hist(dem_ec_tally, col=rgb(0,0,1,0.2), xlim=c(0, 540), main=paste0("Simulated Electoral College Distribution\nUsing Method ",method," with ",num_sim, " simulations"), xlab="Electoral College Accrual")
  hist(rep_ec_tally, col=rgb(1,0,0,0.2), add=T)
  legend("topright", c("Democratic", "Republican", "Overlap", "Required EC To Win"), fill=c("Blue", "Red", "Purple", "Yellow"), cex=0.60)
  box()
  abline(v = 270, lwd=4, col="yellow")
  
  # declares wins as 0, will be used to tabulate probabilities later
  dem_win <- 0 
  rep_win <- 0 
  undecided <- 0
  
  # for each simulation, calculate who wins (whenever election is not undecided)
  for(index in 1:num_sim) {
    if(dem_ec_tally[index] > rep_ec_tally[index] && dem_ec_tally[index] >= 270) {
      dem_win <- dem_win + 1
    }else if(dem_ec_tally[index] < rep_ec_tally[index] && rep_ec_tally[index] >= 270) {
      rep_win <- rep_win + 1
    }else{
      undecided <- undecided + 1
    }
  }
  
  # prints the probabilities for dem, rep, undecided
  print(paste0("Using Method ",method, ", the probabilities for the Democrats and Republicans to outright win are ",dem_win/num_sim, " and ",rep_win/num_sim,", respectively."," The probability of an undecided election is ",undecided/num_sim))
  
}




#### FUNCTION CALLS FOR REQUESTED OUTPUT





# sets the working directory as directed
wd<-"/Users/jfeliciano/Documents/advancedr/homework/Assignment11"
setwd(wd) 

# all the function calls to perform 4 homework prompts
# each function should take 10 seconds each
election_simulator(file_location="Election data.csv", seed_num=12, num_sim=10000, method=1)
election_simulator(file_location="Election data.csv", seed_num=12, num_sim=10000, method=2)
election_simulator(file_location="Election data.csv", seed_num=12, num_sim=10000, method=3)
election_simulator(file_location="Election data.csv", seed_num=12, num_sim=10000, method=4)

