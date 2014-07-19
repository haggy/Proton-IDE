# Proton IDE

Salesforce.com IDE for the Atom editor

## Installation
__Proton__ is available as an Atom package. Use `cmd+,` on a Mac to pull up your
Atom settings. Search for Proton IDE.

### Configuration
Once the install is complete, we need to set the project directory
(where all your projects will be saved. __Please note__ that in the future,
 we will automate this). To do this:

* Click *Atom* in the menu and click *Open Your Config*
* Add the following to the very bottom of the configuration file:
`
'proton':
  'project_path': 'YOUR_PROJECT_PATH'
`
* Replace `YOUR_PROJECT_PATH` with the full path to your project

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
* Navigate to __Packages -> Proton__ and click *Save current file*

## Refreshing a file from SFDC
If you want to pull the most recent version of a file from SFDC:

* Right click anywhere in the active file window and click *Proton: Refresh from server*
* Navigate to __Packages -> Proton__ and click *Refresh current file*
