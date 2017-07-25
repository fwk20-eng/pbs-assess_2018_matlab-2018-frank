# README
The following readme applies to all files in the TruckSim data extraction folder.

# Tickets

* [ ] **2017-05-12 - 1:** Ensure conformity in variable naming. This is directed mainly towards the structures that were created with variable names that have an initial capital letter. This is confusion, only structures should have capital letters I have tested the find and replace in all files in Visual Studio code and it does the trick Just be vigilant on which files are beibg modified.

# Future Log (To Do)

* [x] Results table for report. This needs to integrate the baseline as well as the actual combination. Perhaps the baseline results can be stored in a getBaseline function where you can store all of the baseline combinations that are currently used.
* [x] Write results table to tex file for report.
* [x] Compartmentalise the post processor to open up the possiblity for doing car-carrier assessments.
* [x] Add feature to asses a car carrier with top deck as well as unladen details in the combination tables and results table.

# Change Log

[2.0.0] - 2017-06-09

**Changed**
* File structure improved

[1.2.0] - 2017-06-08

**Added**
* PBS report date update
* PBS report table formats updated
* Centralised script to execute PBS assessment
* Ability to specify a start and end key to 

**Fixed**
* Code formatting (120 characters wide)

[1.1.1] - 2017-06-02

**Fixed**
* Backwards compatability with Matlab 2015a
* Combination structure variable pass through

[1.1.0] - 2017-05-31

**Added**
* Axle load rating to reports
* Function editCombinationCellRegexpBetweenText
* Function editCombinationCellSplitText
* Function extractInformationBetweenParenthesisInCellArray


**Fixed**
* Reference points Z coordinates
* Some code neatened up
* Moved all data extraction to getTruckSimSimulatonData
* Variable pass through

[1.0.0] - 2017-05-12

* First iteration of code that is being documented.
