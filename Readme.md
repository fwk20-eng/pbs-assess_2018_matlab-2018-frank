##Post Processor To-Do List
[] Move any calculations from the individual project files to the main multi-choice post-processor
[] Move standard parameters that do not change between projects to the multi-choice post-processor
[] Contemplate a manner in which the filename generation can be moved to the multi-choice post-processor. This will help consistency between all projects. I think all that is required is moving the write inertias line and to make a series of if statements depending on if inertial properties are to be written to file or not.