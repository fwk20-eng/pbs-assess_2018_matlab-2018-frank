All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased
[x] Move any calculations from the individual project files to the main multi-choice post-processor
[x] Move standard parameters that do not change between projects to the multi-choice post-processor
[] Contemplate a manner in which the filename generation can be moved to the multi-choice post-processor. This will help consistency between all projects. I think all that is required is moving the write inertias line and to make a series of if statements depending on if inertial properties are to be written to file or not.

## [1.0.0] - 2017-03-28

* Start of keep at changelog and semantic versioning
* Long standard modified to account for the driven and non driven rolling resistance. See comparison of results below using the Scania G460 ADR as a test case:

[0] - Original code
[1] - Modified code

[0]: STA: 26.6, GRAa: 29.9, GRAb: 101.6, ACC: 17.86
[1]: STA: 26.6, GRAa: 29.9, GRAb: 101.6, ACC: 17.86

Hence there is negligible change in performance using the new formulation splitting the rolling resistance.
