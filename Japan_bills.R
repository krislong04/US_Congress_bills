
# File info ---------------------------------------------------------------
  # Organization: KU Trade War Lab
  # Author: Kris Long
  # Date: February 2024
  # Purpose: tidy data on bills downloaded from Congress.gov

# More Notes:
  # This code is an example of how to tidy data you download from Congress.gov. 
  # The example here uses Senate bills with the keyword "Japan", but you could
  # use similar code for any keyword with any variables the Library of Congress
  # records. 

# Set up work space -------------------------------------------------------

# Clear R
rm(list = ls())

# Set working directory (yours will be different)
setwd("/Users/kristopherlong/Desktop/KU/Research/Trade_War_Lab/Senate_tough_Japan")

# Load packages
library(tidyverse)
library(readxl)
library(openxlsx)
library(dplyr)
library(stringr)

# Go to Congress.gov and search for bills according to the key term(s) you want.
# You can use the filter options on the left-hand side to narrow your search down
# further. You can theoretically download up to 5,000 results at a time, but in my 
# experience any more than 2,000 crashes your browser. If you need more than 2,000 
# observations download them in separate files and use the "join" function (not in this 
# code file but just Google it). Use the download button on the top left side to download 
# as a csv. When you click the download button it will let you pick which variables you 
# would like to download. It is not a good idea to download every  variable because it will
# create a very large file that's difficult to manage, so only pick the ones you need. Save 
# it in the file you're using as your working  directory. This code assumes you use "Sponsor", 
# "Sponsor Party", "Date of Introduction", and "Last Action Date", but the general format 
# should work for any variables.

# Load data
Bills <- read_csv("Japan_bills.csv")

# Remove top three rows because they are not usful information
Bills <- Bills[-c(1,2,3),]

# Data tidying ------------------------------------------------------------

# Separate variables into their own columns

# The column you are separating is named according the time you downloaded it, 
# so the "col = " argument needs to be changed before you run this code.
# The last column is called "extra" because some senators decided to be fancy
# and include suffixes in their names (ie. "Jr" or "IV"), which adds a comma a
# and messes up the comma separation function because they are listed as, for 
# example, "Joseph R. Biden, Jr". If you don't include the "extra" column R will 
# delete the last variable value. For now, the observations will be misaligned, 
# but we will fix this by hand later (unless you can figure out how to do it in R,
# in which case good for you because I can't)

Bills <- Bills %>% 
  separate(col="14:29:57 EST", 
           into=c("congress_num","last_spnsr_name","spnsr_name","spnsr_party",
                  "year_introduced","yr_last_act","extra"), 
           sep=",", remove=TRUE, convert=FALSE)

# rename column to match TWL
Bills <- rename(Bills, "legislation_num" = "Downloaded on")

# drop URL column (your column will have a different name)
Bills <- select(Bills, !`02/18/2024`)


# Outside of R ------------------------------------------------------------

# Now it's time to fix the observations that were messed up because of the suffixes.
# I can't figure out how to do it in R, so I downloaded the bills object as an
# excel file and edited the data by hand. This is pretty fast with 500 observations,
# but if you data is a lot bigger it will suck.
write.xlsx(Bills, "Japan_bills.xlsx")

# Once you've re-saved the data as an excel after editing it, re upload it as the 
# "Bills" object. Make sure you delete the "extra" column head before downloading.
Bills <- read_xlsx("Japan_bills.xlsx")


# Make this data look like other TWL data -------------------------------------

# Join first and last names, separated by commas, into one variable
Bills <- unite(Bills, "spnsr_name", c("last_spnsr_name", "spnsr_name"), sep = ", ")

# Remove weird stuff in front of their party identifier
Bills$spnsr_name <- gsub("Sen.-","",as.character(Bills$spnsr_name))

# Add "Sen." before Senator's names
Bills$spnsr_name <- paste("Sen. ", Bills$spnsr_name, sep= "")

# Take all the other stuff out of the Congress #
Bills$congress_num <- parse_number(Bills$congress_num)

# Re-code party as 1s and 0s
Bills <-
Bills%>%
  mutate(spnsr_party = case_when(Bills$spnsr_party == "Democratic" ~ 0,
                                 Bills$spnsr_party == "Republican" ~ 1,
                                 Bills$spnsr_party == "Independent" ~ 2))

# Reformat dates to be just years
Bills$year_introduced <- substr(Bills$year_introduced, 7, 10)
Bills$yr_last_act <- substr(Bills$yr_last_act, 7, 10)


#Now, write as an excel file and upload to whoever needs the data
write.xlsx(Bills, "Japan_bills.xlsx")







