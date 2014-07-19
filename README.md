# Proton IDE

Salesforce.com IDE for the Atom editor

## Installation
__Proton__ is available as an Atom package. Use `cmd+,` on a Mac to pull up your
Atom settings. Search for Proton IDE.

## Creating a new SFDC project

* Navigate to Packages -> Proton
* Select *New Project*
* Enter you username and password for a Salesforce instance (__NOTE:__ You may need to append your security token onto your password)
* Select the org type (Is it Production, Sandbox or Developer?)
* Click Login
* Click on the *Select Metadata* tab
* This will load all the available Metadata from your org (__NOTE:__ At this time, only the main dev resources are available)
* Enter a project name (no spaces)
* Click *Create Project*

## Saving your file to SFDC
Once you are done editing a file, you can save it by either:

* Right click anywhere in the active file window and click *Proton: Save to server*
* Navigate to Packages -> Proton and click *Save current file*

## Refreshing a file from SFDC
If you want to pull the most recent version of a file from SFDC:

* Right click anywhere in the active file window and click *Proton: Refresh from server*
* Navigate to Packages -> Proton and click *Refresh current file*
