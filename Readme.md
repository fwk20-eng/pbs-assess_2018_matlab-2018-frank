All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## To Do
[] Contemplate a manner in which the filename generation can be moved to the multi-choice post-processor. This will help consistency between all projects. I think all that is required is moving the write inertias line and to make a series of if statements depending on if inertial properties are to be written to file or not.

## [0.6.0] - 2017-06-08

**Added**
* Dummy axle support for SRT and HSTO manoeuvre
* Original Long Solve. The gradient correction needs to be cross validated before it is used
* Additional engine data

**Fixed**
* Excess code removed
* Write to excel functions moved to more efficient positions

## [0.5.0] - 2017-05-17

**Added**
* Engine parameters
* Appender for latex report
* Appender for baseline combination
* Copy TruckSim files to the project folder

**Fixed**
* File path generator location
* Create run log location
* Renamed remove m files

## [0.4.0] - 2017-03-29

* Start of keep at changelog and semantic versioning
* Long standard modified to account for the driven and non driven rolling resistance. See comparison of results below using the Scania G460 ADR as a test case:

[0] - Original code
[1] - Modified code

[0]: STA: 26.6, GRAa: 29.9, GRAb: 101.6, ACC: 17.86
[1]: STA: 26.6, GRAa: 29.9, GRAb: 101.6, ACC: 17.86

Hence there is negligible change in performance using the new formulation splitting the rolling resistance.

## [0.3.0] - 2017-03-27

* Fixed the axle load dependance in GraB and ACC standards
* Removed non-essential files from the folder
* Developed getEngine: Engine parameters can now be called with a single call to the getEngine function passing a unique string and the number of tyres present in the combination
* Developed getBin: Side tipper bins can now be called via a single function getBin by passing an additional parameter consisting of a unique string indicating the bin model.

## [0.2.0] - 2017-03-27

* Updated SG Coal 2016014 project parameters
* Moved individual project post process files into the project folders. The post processor can now be accessed using a addpath() command in the individual project files.
* Be aware that having multiple post processors added to the path may cause issues.

## [0.1.0] - 2017-03-16

* Updated project file: Rolfo Superlong
* Added axle load dependence on gradient into startability
* Added readme file

## [0.0.0] - 2017-03-16

* Committed the PostProcess in its new folder
