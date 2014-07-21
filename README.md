# Proton IDE

Salesforce.com IDE for the Atom editor

## Installation
__Proton__ is available as an Atom package. Use `cmd+,` on a Mac to pull up your
Atom settings. Search for Proton IDE.

### Configuration
Once the install is complete, we need to set the project directory
(where all your projects will be saved). To do this:

* Click *Atom* in the menu and click *Open Your Config*
* Find the following lines (it will be near the very bottom of the configuration file):

```
'proton':
  'project_path': ''
```
* In between the empty single quotes, add the full path to your project. __NOTE:__
  This directory must exist so make sure to create it if it doesn't.
* Do not add a trailing slash. For example, if you're on a Mac and you want your project
  to be in your home directory in a folder called atom you would use: `/Users/yourusername/atom`

That's it! Keep reading for instructions on using the Proton IDE.

## Creating a new SFDC project

* Navigate to Packages -> Proton
* Select *New Project*
* Enter you username and password for a Salesforce instance (__NOTE:__ You may need to append your security token onto your password)
* Select the org type (Is it Production, Sandbox or Developer?)
* Click Login
* When you see a successful login message, click on the *Select Metadata* tab
* This will load all the available Metadata from your org (__NOTE:__ At this time, only the main dev resources are available)
* Enter a project name (no spaces)
* Click *Create Project*

## Saving your file to SFDC
To deploy the changes you made to a file:

* Right click anywhere in the active file window and click *Proton: Save to server*
__OR__
* Navigate to __Packages -> Proton__ and click *Save current file*

## Refreshing a file from SFDC
If you want to pull the most recent version of a file from SFDC:

* Right click anywhere in the active file window and click *Proton: Refresh from server*
__OR__
* Navigate to __Packages -> Proton__ and click *Refresh current file*

## Deleting a file from SFDC
If you want to delete a file from SFDC (and locally):

* Right click anywhere in the active file window and click *Proton: Delete from server*
  __OR__
* Navigate to __Packages -> Proton__ and click *Delete current file*

## Creating new metadata
You can create new Classes/Triggers/Pages/Components right from the IDE.

* Navigate to __Packages -> Proton -> Create Metadata__
* Click on the metadata type that you'd like to create
* Fill in all required fields
* Click create
